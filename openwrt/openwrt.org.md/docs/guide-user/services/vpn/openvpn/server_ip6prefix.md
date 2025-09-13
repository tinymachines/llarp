# OpenVPN server with dynamic IPv6 GUA prefix

Follow the [OpenVPN server](/docs/guide-user/services/vpn/openvpn/server "docs:guide-user:services:vpn:openvpn:server") article to set up a basic server. To assign a global-unicast (GUA) IPv6 address from the IPv6 prefix of the WAN interface to OpenVPN clients, we must assign a free subnet of the delegated WAN IPv6 prefix to the OpenVPN server via the openvpn config option `server_ipv6`. However, as for most users the delegated IPv6 prefix is non-static, a dynamic/automatic assignment is required.

To dynamically assign a free subnet, in this example /64, of the delegated WAN prefix to the OpenVPN server, we must define a dedicated VPN interface of type `static`. In this example, the interface is named `LANvpn` and the device is `tun1`. Refer to [this](https://forum.openwrt.org/t/openvpn-dynamically-assign-client-ipv6-gua-with-dynamic-wan-ipv6-prefix/104590/5 "https://forum.openwrt.org/t/openvpn-dynamically-assign-client-ipv6-gua-with-dynamic-wan-ipv6-prefix/104590/5") for a detailed discussion.

```
config interface 'LANvpn'
	option proto 'static'
	option device 'tun1'
	option ip6assign '64'
	option ip6class 'wan6'
```

Next, we add the following hotplug script `/etc/hotplug.d/iface/30-ipv6pdchange` to assign the IPv6 subnet of the `LANvpn` interface to our OpenVPN server. This way, we can rely on the subnetting routines of OpenWRT to find a free subnet for the OpenVPN server considering the IPv6 configurations of other interfaces. The hotplug script is triggered only on IPv6 prefix changes and assumes the OpenVPN server is named `LAN` and is defined in `/etc/config/openvpn`.

```
#!/bin/sh
 
# if ipv6 address has changed on WAN6 go for it
if [ "$INTERFACE" = "wan6" -a "$IFUPDATE_ADDRESSES" = "1" ]
then
    ##################
    # PD fix
    ##################
    # reload interface to update PD to downstream interfaces, refer to bug described here https://forum.openwrt.org/t/delegated-ipv6-prefix-not-updated/56135
    /sbin/ifup wan6
 
    # wait some time to get IPv6 up
    sleep 30
 
    ##################
    # IPv6 OpenVPN assignment
    ##################
 
    # source network functions
    source /lib/functions/network.sh
 
    # get IPv6 of openvpn interface
    network_get_ipaddr6 IPV6_OVPN "LANvpn"
 
    if [[ ! -z $IPV6_OVPN ]]
    then	    
	    # get subnet size of OpenVPN interface
	    NET_ASSIGN="$(uci get network.LANvpn.ip6assign)"
 
	    # set openvpn server-ipv6 option
	    uci set openvpn.LAN.server_ipv6="$IPV6_OVPN/$NET_ASSIGN"
	    uci commit openvpn
 
	    # reload openvpn
	    service openvpn reload	    
    fi
fi
```
