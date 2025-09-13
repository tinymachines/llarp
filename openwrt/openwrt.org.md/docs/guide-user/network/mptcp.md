# Multipath TCP and OpenWrt

This page discusses the Multipath TCP support in OpenWrt.

## Start

**this is now part of the trunk since commit [https://github.com/openwrt/openwrt/commit/c8d5abd62b70137c70bf12e83b6d0708b980abb3](https://github.com/openwrt/openwrt/commit/c8d5abd62b70137c70bf12e83b6d0708b980abb3 "https://github.com/openwrt/openwrt/commit/c8d5abd62b70137c70bf12e83b6d0708b980abb3")**

It is available in 24.10.

## Multipath TCP

Multipath TCP (MPTCP) is an effort towards enabling the simultaneous use of several IP-addresses/interfaces by a modification of TCP that presents a regular TCP interface to applications, while in fact spreading data across several sub-flows. Benefits of this include better resource utilisation, better throughput and smoother reaction to failures.

You must run an MPTCP capable kernel on both sender/receiver devices that are involved in a Multipath TCP connection. If these devices are PCs, more info can be found at [http://multipath-tcp.org](http://multipath-tcp.org "http://multipath-tcp.org")

If your PC and Server have an ordinary TCP-connection, your router cannot use MPTCP by default. To make it work, you have two possible solutions:

- Use a proxy on the router
- Use a VPN to an endpoint with faster network. In this way, you can use all uplinks for all traffic, even traffic to a non MPTCP capable server.

### Configuration

MPTCP runs without any configuration. But if you want to use multiple interfaces on your device you have to configure them.

To enable MPTCP globally

```
uci set network.globals.multipath=enable
```

Set each interface with:

```
uci set network.<name>.multipath=<option>
```

Where `<option>` is one of:

on No special config master Like “on” but also set the default route for all other traffic (**use it for one interface!**) off Disable the interface for mp-tcp (default option) backup Use this interface but don't forward traffic until no other interface are available (faster switch) handover Establish a connection only if no other interface available (slower switch but normally none traffic)

Save your changes with:

- uci commit
- /etc/init.d/network restart

The script generates multiple default routes in different tables and rules. These can cause problems with other packages. I'm sure that it will **not work with multiwan**

### Test

you can see all current connections by using:

```
multipath -c
```

If you have installed the patched net-tools on your pc you can see MPTCPs behaviour in a better way by using

```
netstat -m
```

The patched version of netstat is not yet ported to the openwrt repos.

## VPN Example

This is an example for a VPN over 2 WAN connections. It routes the entire network to the VPN endpoint and sends the data to the internet there, consequently it needs a back route from there which is why you should (also) implement NAT on the remote side of the VPN tunnel.

The following configuration has **no encryption** on the VPN link. This is faster but it is not secure. The configuration also updates the MAC address to prevent problems in case you have 2 ISP clients but the same address.

```
network.globals.multipath=enable

network.wan1=interface
network.wan1.proto=dhcp
network.wan1.ifname=eth0.1
network.wan1.macaddr=XX:XX:XX:XX:XX:01
network.wan1.multipath=master

network.wan2=interface
network.wan2.proto=dhcp
network.wan2.ifname=eth0.2
network.wan2.macaddr=XX:XX:XX:XX:XX:02
network.wan2.multipath=on

network.tap1337=interface
network.tap1337.proto=none
network.tap1337.ifname=tap1337


firewall.@zone[1].name=wan
firewall.@zone[1].network=wan1 wan2

firewall.@zone[2]=zone
firewall.@zone[2].name=vpn
firewall.@zone[2].input=ACCEPT
firewall.@zone[2].output=ACCEPT
firewall.@zone[2].network=tap1337
firewall.@zone[2].forward=ACCEPT

firewall.@forwarding[0]=forwarding
firewall.@forwarding[0].dest=vpn
firewall.@forwarding[0].src=lan
firewall.@forwarding[2]=forwarding
firewall.@forwarding[2].dest=lan
firewall.@forwarding[2].src=vpn


openvpn.mptcp=openvpn
openvpn.mptcp.enabled=1
openvpn.mptcp.client=1
openvpn.mptcp.dev=tap1337
openvpn.mptcp.proto=tcp
openvpn.mptcp.remote=X.X.X.X 1194
openvpn.mptcp.resolv_retry=infinite
openvpn.mptcp.nobind=1
openvpn.mptcp.persist_key=1
openvpn.mptcp.persist_tun=1
openvpn.mptcp.ca=/etc/openvpn/ca.crt
openvpn.mptcp.cert=/etc/openvpn/client.crt
openvpn.mptcp.key=/etc/openvpn/client.key
openvpn.mptcp.cipher=none
openvpn.mptcp.verb=3
openvpn.mptcp.link_mtu=1480
openvpn.mptcp.script_security=2
openvpn.mptcp.up=/etc/openvpn/up.sh
openvpn.mptcp.down=/etc/openvpn/down.sh
```

/etc/openvpn/up.sh

```
#!/bin/sh
# ^ must be the first line
# set the execution bit by 'chmod +x /etc/openvpn/up.sh'

# Route the traffic from the bridged interface "lan" via table 1
# multipath-tcp will use the table 2 and up
ip rule add iif br-lan table 1
# set the default route via vpn (only table 1)
ip route add 10.9.8.0/24 via 10.9.8.1 dev $1 table 1
ip route add default via 10.9.8.1 dev $1 table 1
# refresh the routes
ip route flush cache
```

/etc/openvpn/down.sh

```
#!/bin/sh

ip rule del table 1
ip route flush table 1
ip route flush cache
```

**Server Configuration**

OpenVPN

```
port 1194
proto tcp
dev tap

ca      /etc/openvpn/keys/ca.crt    # generated keys
cert    /etc/openvpn/keys/server.crt
key     /etc/openvpn/keys/server.key  # keep secret
dh      /etc/openvpn/keys/dh1024.pem

server 10.9.8.0 255.255.255.0  # internal tun0 connection IP
ifconfig-pool-persist ipp.txt
keepalive 10 120

#comp-lzo         # Compression - must be turned on at both ends
persist-key
persist-tun
cipher none       # < No encryption!!!
status /var/log/openvpn-status.log
verb 3
client-to-client
link-mtu 1480 
script-security 2
up /etc/openvpn/up.sh  # < Set the back route in this script.
```

Example of the server up.sh *(replace 192.168.1.0 with your own value)*.

```
#!/bin/sh
#The client IPs are fixed in the ipp.txt
ip route add 192.168.1.0/24 via 10.9.8.2 dev $1
```

Don't forget to implement NAT at the Server. *(for examples, browse “debian nat”)*
