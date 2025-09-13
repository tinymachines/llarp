![:!:](/lib/images/smileys/exclaim.svg) most of this assumes you're familiar with openwrt, basic networking concepts and are able to tinker around the command-line ![:!:](/lib/images/smileys/exclaim.svg)

# High availability

*High availability* is a term that can be used to refer to systems that are designed to remain functional despite some hardware and/or software failures and/or despite planned maintenance (e.g. upgrades). Actual measured availability (e.g. percentage of time or requests that succeed) can vary.

This page describes a simple two router setup, in an active/backup configuration. The two devices will share a virtual ip address that hosts on the lan can use as a gateway to reach the internet. In case the active router fails or is rebooted, a backup router will take over.

We're using keepalived to implement healthchecking and ip failover, and conntrack-tools to implement firewall/nat syncing.

Most of openwrt configuration required (but not all) is doable from luci web ui as well.

## Preparation, assumptions, description of environment

- You have 2 openwrt routers and a static WAN IP. (could also be a private IP+DMZ).
- If you're not doing NAT or connection tracking based firewalling, skip the conntrackd/conntrack-tools sections.
- DHCP dynamic WAN IP is possible with keepalived, but requires extra scripting and is not going to be described here.
- VPNs and tunnel setups and failing those over is not covered.
- Failing over PPPoE WAN is not implemented here, best bet: let the modem do PPPoE and setup your virtual wan ip to DMZ.

## Individual Router Configuration

### 1. Configure 1st openwrt router

- Internal LAN ip: 192.168.1.2/24 (change so 192.168.1.1 is available for initial configuration of 2nd router)
- WAN IP, gateway: static 192.168.0.2/24 gw 192.168.0.1 metric 10 (using double nat / dmz on the isp provided router)
- DHCP on defaults is fine, we'll configure it later.

### 2. Configure 2nd openwrt router

- Interface LAN ip: 192.168.1.3/24 (change so that when you connect the second router to the same network you can configure it)
- WAN IP, gateway: static 192.168.0.3/24 gw 192.168.0.1 metric 10 (using double nat / dmz on the isp provided router)
- DHCP on defaults is fine for now, if you have any static leases in dhcp, or fixed host entries, make sure they're the same as on 1st router.

##### verification and troubleshooting

- change a client to use gw 192.168.1.3 and dns 192.168.1.3, make sure second router is working as well
- hosts that have IPs issued with one dnsmasq might not be resolvable using the second dnsmasq, assigning static leases helps.

## Both router configuration

### 3. Configure keepalived

**keepalived** is a linux daemon that uses VRRP (Virtual Router Redundancy Protocol) to healthcheck and elect a router on the network that will serve a particular IP. We'll be using a small subset of its features in our use case.

`opkg update && opkg install keepalived`

Much work has been done to set up keepalived to use a uci config file, however this config file format has not yet been documented. The following example uses a keepalived.conf configuration, and will enter an option in the uci config file to read it on startup instead.

The following configuration in `/etc/keepalived/keepalived.conf` assumes routers are symmetrical, ie. they're of the same priority, they start up in backup mode and they will not preemept the other router until they establish other router is gone. You will need to adjust the interfaces to match your device.

```
! Configuration File for keepalived

! failover E1 and I1 at the same time
vrrp_sync_group G1 {
  group {
    E1
    I1
  }
}

! internal
vrrp_instance I1 {
  state backup
  interface br-lan
  virtual_router_id 51
  priority 101
  advert_int 1
  virtual_ipaddress {
    10.9.8.4/24
  }
  authentication {
    auth_type PASS
    auth_pass s3cret
  }
  nopreempt
}

! external
vrrp_instance E1 {
  state backup
  interface eth0.2
  virtual_router_id 51
  priority 101
  advert_int 1
  virtual_ipaddress {
    192.168.0.4/24
  }
  virtual_routes {
    src 192.168.0.4 to 0.0.0.0/0 via 192.168.0.1 dev eth0.2 metric 5
  }
  authentication {
    auth_type PASS
    auth_pass s3cret
  }
  nopreempt
}
```

To ensure \`/etc/init.d/keepalived\` script starts the daemon pointed at your config, write an entry in \`/etc/config/keepalived\` referencing your alternate configuation file. In 19.07 and earlier:

```
config global_defs 'globals'
   option alt_config_file          "/etc/keepalived/keepalived.conf"
```

In 21.02 and later:

```
config globals 'globals'
   option alt_config_file          "/etc/keepalived/keepalived.conf"
```

This will tell the keepalived service to use the configuration file you wrote at /etc/keepalived/keepalived.conf instead of building a new config file on the fly at /tmp/keepalived.conf using a uci-based config.

### 4. Configure conntrackd

This step is optional, keepalived will be failing over (successing over?) the ip address with or without conntrackd, however, as NAT relies on tracking connection state in a (network address) table that links external ip:port with internal ip:port (per given protocol, tcp or udp), connections might be broken on failover to backup openwrt instance. New connections (such as application level reconnects) will work just fine. This is because the backup instance will not know who to send outgoing packets to.

Below is a simple config file for conntrackd. It would be advisable to navigate to /etc/conntrackd/ in order to rename the original config. Creating a brand new “conntrackd.conf” file allows you to browse back to the old one for reference.

```
Sync {
    Mode FTFW {
        DisableExternalCache Off
        CommitTimeout 1800
        PurgeTimeout 5
    }

    UDP {
        IPv4_address "ip addr of host router"
        IPv4_Destination_Address "ip addr of partner router"
        Port 3780
        Interface eth*
        SndSocketBuffer 1249280
        RcvSocketBuffer 1249280
        Checksum on
    }
}

General {
    Nice -20
    HashSize 32768
    HashLimit 131072
    LogFile on
    Syslog on
    LockFile /var/lock/conntrack.lock
    UNIX {
        Path /var/run/conntrackd.ctl
        Backlog 20
    }
    NetlinkBufferSize 2097152
    NetlinkBufferSizeMaxGrowth 8388608
    Filter From Userspace {
        Protocol Accept {
            TCP
            UDP
            ICMP # This requires a Linux kernel >= 2.6.31
        }
        Address Ignore {
            IPv4_address 127.0.0.1 # loopback
        }
    }
}

```

Run simple commands to verify functionality

```
Summary of connected devices:

conntrackd -s
```

```
Resync nodes:

conntrackd -n
```

### 5. Configure dhcp

You'll want DHCP (dnsmasq) to serve 192.168.0.4 (vip address) to hosts on the lan, both as their gateway and DNS. Here's an excerpt from `/etc/config/dhcp` that instructs dnsmasq to do that.

```
...
config dhcp 'lan'
        ...
        option force '1'
        list dhcp_option '3,192.168.1.4'
        list dhcp_option '6,192.168.1.4'
...
```

option force '1' is needed for dnsmasq to not deactivate when it sees the other dhcp server. dhcp\_option 3 is gateway, dhcp\_option 6 is DNS.

Now we need to configure synchronization of the dhcp leases. Both devices will have a dhcp server and both will assign dynamic IPs to clients. But each will only update its own dhcp lease list.

Dnsmasq stores current leases in a text file called **/tmp/dhcp.leases** by default in OpenWrt (it's also a configuration option you can change from UCI or Luci web interface (**Network → DHCP and DNS → Resolv and Hosts files → Lease File** )

This is what it looks like on my OpenWrt router VM

```
root@VM-router:~# cat /tmp/dhcp.leases
1633703346 00:1c:42:0f:b1:c7 192.168.222.244 hostname1 01:00:1c:42:0f:b1:c7
1633703352 c4:41:1e:68:97:62 192.168.222.243 hostname2 01:c4:41:1e:68:97:62
1633703161 c0:10:b1:2c:e4:e6 192.168.123.148 * 01:c0:10:b1:2c:e4:e6
1633703141 e8:f4:08:1f:9c:67 192.168.123.69 hostname3 01:e8:f4:08:1f:9c:67
```

The first number is a timestamp (seconds since Unix “beginning of time” date which is somewhere in 1970, so it should be consistent with another device if the clocks are set correctly), then there is mac address of the device, then IP, then hostname (I redacted the hostnames of my devices above), then it seems another mac address but I'm not sure of what that is.

So we add a simple and dumb script that just merges the files on both devices every X time, and it assumes that dnsmasq will automatically drop the entries when their lease is up.

We must do the following on both routers.

Import the public SSH key of the router 1 in router 2 (and the reverse) so they can scp to each other without writing the password this to read the current public key [extras](/docs/guide-user/security/dropbear.public-key.auth#extras "docs:guide-user:security:dropbear.public-key.auth") and this to write the key [web\_interface\_instructions](/docs/guide-user/security/dropbear.public-key.auth#web_interface_instructions "docs:guide-user:security:dropbear.public-key.auth")

Then copy the following script to **/bin/dnsmasq-lease-sync.sh** and edit the IP address (so it can point to the other router)

```
#!/bin/sh
#syncs contents of dnsmasq dhcp leases

other_router=192.168.11.254

scp root@$other_router:/tmp/dhcp.leases /tmp/dhcp_lease_temp

cat /tmp/dhcp.leases /tmp/dhcp_lease_temp | sort -u > /tmp/dhcp_lease_new

mv /tmp/dhcp_lease_new /tmp/dhcp.leases
```

then make it executable

```
chmod u+x /bin/dnsmasq-lease-sync.sh
```

Then add a scheduled task to execute this script every minute and enable cron (scheduled tasks) service. (can be done from luci as well [cron](/docs/guide-user/base-system/cron "docs:guide-user:base-system:cron"))

```
echo '*/1 * * * *  /bin/dnsmasq-lease-sync.sh' >>  /etc/crontabs/root
echo 'root' >> /etc/crontabs/cron.update
service cron start
```

### 6. Sysupgrade backup add dirs

Add the following directories to `/etc/sysupgrade.conf`. (can be done from luci as well).

```
...
/etc/keepalived/
/etc/conntrackd/
/bin/dnsmasq-lease-sync.sh
```

## Testing and verification

TODO(risk): restarting keepalived with logread -f open, pulling cables with ssh / telnet / http sessions open, forcing dhcp renewal with tcpdump running, ensure
