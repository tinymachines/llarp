# Multiwan

**multiwan is old and no longer maintained, you should use [mwan3](/docs/guide-user/network/wan/multiwan/mwan3 "docs:guide-user:network:wan:multiwan:mwan3") instead.**

The *multiwan* package is an agent script that makes Multi-WAN configuration simple, easy to use and manageable. It comes complete with load balancing, failover and an easy to manage traffic ruleset. The uci configuration file `/etc/config/multiwan` is provided as part of the *multiwan* package.

Unlike “channel bonding” or “link aggregation” which routes individual ethernet frames, multiwan routes individual sessions over the least busy WAN interface and that session continues to use the same WAN until terminated.

Note: Multiwan will NOT work if the WAN connections are on the same subnet and share the same default gateway.

Note2: Multiwan (at least on Barrier Breaker r39404) does not accept WAN interfaces with “\_” or other special characters

## Installation

### With LuCI interface

Using the LuCI GUI navigate to:

- System → Software → Update package lists
- System → Software → Scroll down to Available packages → Click the “Install” link for the *luci-app-multiwan* package.

For Chaos Calmer snapshots instead:

- System → Software → Scroll down to Available packages → Click the “Install” link for the *luci-app-mwan3* package.

You should now find the *multiwan* configuration page under Network → Multi-WAN

### With Command Line Interface (CLI)

```
opkg update
opkg install multiwan
/etc/init.d/multiwan enable
/etc/init.d/multiwan start
/etc/init.d/multiwan single
```

## Configuration

### With Command Line Interface (CLI)

#### General options

```
config 'multiwan' 'config'
        option 'default_route' 'balancer'
```

Name Default Options Description `default_route` *balancer* *balancer*/fastbalancer/&lt;interface&gt; Selects the default path for all unspecified traffic `health_monitor` *parallel* *parallel/serial* Memory footprint related `debug` *0* *0/1* Output debug to log `lan_if` *lan* *&lt;firewall lan zone&gt;*

```
uci set multiwan.config.health_monitor=serial
uci commit multiwan
/etc/init.d/multiwan restart
```

- Load Balancing using *netfilter* is referred to as the “Fast Balancer (Best Distribution)”
- Load Balancing using *iproute2* is referred to as “Load Balancer (Best Compatibility)”
- wanrule for the “Fast Balancer” is now `fastbalancer`
- wanrule for the “Load Balancer” is still just `balancer`

It seems that `fastbalancer` is superior to `balancer` in terms of stability but you will need to try each setting to see which works best for you.

#### WAN Interfaces

```
config 'interface' 'wan'
        option 'weight' '10'
        option 'health_interval' '10'
        option 'icmp_hosts' 'dns'
        option 'timeout' '3'
        option 'health_fail_retries' '3'
        option 'health_recovery_retries' '5'
        option 'failover_to' 'wan2'
        option 'dns' 'auto'

config 'interface' 'wan2'
        option 'weight' '10'
        option 'health_interval' '10'
        option 'icmp_hosts' 'dns'
        option 'timeout' '3'
        option 'health_fail_retries' '3'
        option 'health_recovery_retries' '5'
        option 'failover_to' 'wan'
        option 'dns' 'auto'
```

Name Default Options Description `weight` *10* *disable/1-10* Load Balancer Distribution `health_interval` *10* *disable/5/10/20/30/60/120* Health Monitor Interval in seconds `icmp_hosts` *?* *disable/dns/gateway/&lt;host&gt;* Health Monitor ICMP Host(s) `timeout` *?* *disable/1-5/10* Health Monitor ICMP Timeout `health_fail_retries` *?* *1/3/5/10/15/20* Attempts Before WAN Failover `health_recovery_retries` *?* *1/3/5/10/15/20* Attempts Before WAN Recovery `failover_to` *?* *disable/balancer/fastbalancer/&lt;interface&gt;* Failover Traffic Destination `dns` *auto* *auto/&lt;dns&gt;* DNS Server(s)

```
uci delete multiwan.wan2
uci set multiwan.wwan=interface
uci set multiwan.wwan.weight=3
uci set multiwan.wwan.health_interval=disable
uci set multiwan.wwan.icmp_hosts=disable
uci set multiwan.wwan.timeout=3
uci set multiwan.wwan.health_fail_retries=3
uci set multiwan.wwan.health_recovery_retries=5
uci set multiwan.wwan.failover_to=fastbalancer
uci set multiwan.wwan.dns=auto
uci commit multiwan
/etc/init.d/multiwan restart
```

For PPP 3G WAN interfaces, manually set DNS servers for each WAN in multiwan configuration. In case of issues with multiple 3G dongles, add the following lines for each interface in the etc/config/network:

```
option 'peerdns' '0'
option 'defaultroute' '0'
```

#### Outbound Traffic Rules

In the case of duplicate rule entries, the last rule will take precedent.

```
config 'mwanfw'
	option 'src' '192.168.1.0/24'
	option 'proto' 'udp'
	option 'port_type' 'source-ports'
	option 'ports' '5060,16384:16482'
	option 'wanrule' 'wan'
```

Name Default Options Description src *all* *all/&lt;IP&gt;/&lt;hostname&gt;* Source Address dst *all* *all/&lt;IP&gt;/&lt;hostname&gt;* Destination Address port\_type *dports* *dports/source-ports* ports *all* *all/&lt;port,port:range&gt;* Ports proto *all* *all/tcp/udp/icmp/&lt;custom&gt;* Protocol wanrule *balancer/fastbalancer/&lt;interface&gt;* WAN Uplink failover\_to *balancer/fastbalancer/&lt;interface&gt;* [multiwan\_per\_mwanfw\_failover.patch.txt](http://pio.longstair.com/misc/multiwan_per_mwanfw_failover.patch.txt "http://pio.longstair.com/misc/multiwan_per_mwanfw_failover.patch.txt")

```
uci add multiwan mwanfw
uci set multiwan.@mwanfw[-1].src=192.168.2.0/24
uci set multiwan.@mwanfw[-1].dst=www.whatismyip.com
uci set multiwan.@mwanfw[-1].wanrule=fastbalancer
uci commit multiwan
/etc/init.d/multiwan restart
```

## Simple Multiwan Setup

### 1. Create VLAN for WAN2

```
vconfig add eth0 2
```

### 2. Configure VLANs and Network Interfaces

Using `/etc/config/network.`

- Move LAN port “0” from default eth0\_0 to eth0\_2.

<!--THE END-->

- Configure WAN and WAN2 'proto' as 'dhcp' initially and use the web interface to reconfigure to PPPOE or static IP later if needed.
- Use the DNS servers configured below if you're having DNS problems. Some ISPs only allow DNS connections from their own IP blocks.

```
# The following assumes a six port switch, the default WAN port is switch port 0, 
# the default LAN ports (1-4) are switch ports (1-4) and the internal switch port 
# connection to the router mainboard is switch port 5.
 
# Although a common configuration, some routers are configured with a 5 port switch,
# a separate physical network interface for the WAN port and the numbering system 
# may be different.

config 'switch' 'eth0'
        option 'enable' '1'

# Note: The internal switch port 5 is tagged "5t" in the following configuration
# to allow it to be shared by multiple VLANs (eth0.0., eth0.1, eth0.2)

# Configure 3 external LAN ports on VLAN0.
config 'switch_vlan' 'eth0_0'
        option 'device' 'eth0'
        option 'vlan' '0'
        option 'ports' '2 3 4 5t'

# Configure default WAN port on VLAN1.
config 'switch_vlan' 'eth0_1'
        option 'device' 'eth0'
        option 'vlan' '1'
        option 'ports' '1 5t'

# Configure WAN2 port on VLAN2.
config 'switch_vlan' 'eth0_2'
        option 'device' 'eth0'
        option 'vlan' '2'
        option 'ports' '0 5t'

# Default loopback interface.
config 'interface' 'loopback'
        option 'ifname' 'lo'
        option 'proto' 'static'
        option 'ipaddr' '127.0.0.1'
        option 'netmask' '255.0.0.0'

# Default 'lan' interface configured with Spanning Tree Protocol activated.
config 'interface' 'lan'
        option 'type' 'bridge'
        # On some routers the default 'lan' interface is configured directly
        # to the physical network interface eth0. This has to be changed to 
        # a VLAN, in this case eth0.0
        option 'ifname' 'eth0.0'
        option 'proto' 'static'
        option 'stp' '1'
        option 'ipaddr' '192.168.1.1'
        option 'netmask' '255.255.255.0'

# wan interface
config 'interface' 'wan'
        option 'ifname' 'eth0.1'
        option 'proto' 'dhcp'
        option 'dns' '216.146.35.113 216.146.36.113 8.8.8.8 8.8.4.4'

# wan2 interface
config 'interface' 'wan2'
        option 'ifname' 'eth0.2'
        option 'proto' 'dhcp'
        option 'dns' '216.146.35.113 216.146.36.113 8.8.8.8 8.8.4.4'
```

### 3. Configure WANs and multiwan

##### WANs:

Network &gt; Interfaces &gt; WAN/WAN2 - Add WAN2 to the WAN firewall zone.

##### Multiwan:

Network &gt; Multiwan checkout the bottom page to see samples of the settings. here's how i got mine setup:

- a. I only have two internet connections so I always remove the last two wan interfaces. I also comment out MWAN3 and MWAN4 in /etc/iproute2/rt\_tables (although it may not be necessary).
- b. Load Balancer Distribution = 1 for even connection distribution

Failover = LoadBalancer for both links

- c.Traffic Rules

![:!:](/lib/images/smileys/exclaim.svg) checkout the examples Source, Destination, protocol, Ports, WAN Uplink all, all,all,all, Load Balancer all, all, UDP, all, wan ←- this is so all vpn and voip connection goes through 1 gateway only that's it!

### 3. Test

1. Status &gt; Interfaces should show traffic going through both interfaces.
2. route distribution
   
   ```
    root@culiat-wg:~# ip route show table 123
    192.168.2.0/24 dev eth0.2  proto kernel  scope link  src 192.168.2.214
    192.168.1.0/24 dev br-lan  proto kernel  scope link  src 192.168.1.1
    114.108.201.0/24 dev eth0.1  proto kernel  scope link  src 114.108.201.49
    default  proto static
           nexthop via 114.108.201.1  dev eth0.1 weight 1
           nexthop via 192.168.2.1  dev eth0.2 weight 1
   ```
3. The `route` command should display two default gateways.
4. Try a torrent with lots of seeders. If *multiwan* is working properly you should see a download rate greater than your fastest WAN connection.
5. Disconnecting one WAN port should NOT interrupt your connection.

### 4. Troubleshooting

There's a problem if:

1. you refresh the Interface status page and the transfer rates of one interface do not change.
2. only one WAN interface appears on the “Interface Status” page.
3. you enter the `route` command and it only displays one default gateway.
4. the `ip route show table 123` command doesn't display `nexthops`
