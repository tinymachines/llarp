# Dual VPN with mwan3

Objective: Open two VPN tunnels, one through main WAN and one through LTE backup, automatic failover to LTE when WAN fails.

See also: [Forum post](https://forum.openwrt.org/t/openvpn-dual-wan-failover/65504 "https://forum.openwrt.org/t/openvpn-dual-wan-failover/65504")

## WAN

Navigate to **LuCI → Network → Switch** to create second VLAN.

[![](/_media/media/docs/howto/dual-vpn-switch.png?w=400&tok=5da520)](/_detail/media/docs/howto/dual-vpn-switch.png?id=docs%3Aguide-user%3Arouting%3Aexamples%3Adual-wan "media:docs:howto:dual-vpn-switch.png")

Navigate to **LuCI → Network → Interfaces** to create WAN2 interface. Assign WAN2 to the VLAN and to firewall WAN zone.

If you disable WAN you should now be able to use WAN2 to reach the internet from LAN. If both are enabled the WAN with the lower gateway metric wins. Through ssh you can use ping to check whether both WAN ports work.

```
ping -I eth1.2 openwrt.org
ping -I eth1.3 openwrt.org
```

## VPN

Create unmanaged VPN interfaces, bring up on boot, firewall wan zone

[![](/_media/media/docs/howto/dual-vpn-interfaces.png?w=400&tok=1fe15c)](/_detail/media/docs/howto/dual-vpn-interfaces.png?id=docs%3Aguide-user%3Arouting%3Aexamples%3Adual-wan "media:docs:howto:dual-vpn-interfaces.png")

Create two VPN connections for your VPN provider. Be sure to explicitly utilize the VPN interfaces created beforehand. Bind each VPN profile to the respective WAN interface. Prevent routes from getting pushed.

```
# /etc/openvpn/vpn1.ovpn
client
dev tun0
proto udp
local $WAN_IP
pull-filter ignore redirect-gateway
remote $VPN1_IP1 $PORT
remote $VPN1_IP2 $PORT
remote $VPN1_IP3 $PORT
...
 
# /etc/openvpn/vpn2.ovpn
dev tun1
proto udp
local $WAN2_IP
pull-filter ignore redirect-gateway
remote $VPN2_IP1 $PORT
remote $VPN2_IP2 $PORT
remote $VPN2_IP3 $PORT
...
```

## Routing

You should now be able to use both VPNs. You can start both and check whether it works.

```
ping -I tun0 openwrt.org
ping -I tun1 openwrt.org
```

But all traffic for tun1 gets routed through WAN not WAN2, therefore we need static routes to make traffic destined for VPN2 go through WAN2.

Take the remotes VPNX\_IPX from the VPN config and route them through the appropriate interface in **LuCI → Network → Static Routes**.

[![dual-vpn-routes.jpg](/_media/media/docs/howto/dual-vpn-routes.jpg?w=400&tok=da799f "dual-vpn-routes.jpg")](/_detail/media/docs/howto/dual-vpn-routes.jpg?id=docs%3Aguide-user%3Arouting%3Aexamples%3Adual-wan "media:docs:howto:dual-vpn-routes.jpg")

Now start both VPNs and unplug WAN and check:

```
# Should not work
ping -I tun0 openwrt.org
 
# Should work
ping -I tun1 openwrt.org
```

If you unplug WAN2 and plug in WAN it is the other way around. Congratulations both VPNs work and traffic for the VPN1 remote gets routed through WAN and VPN2 through WAN2

If both VPNs are running the routes should look like this:

```
# route
Kernel IP routing table
Destination    Gateway    Genmask         Flags Metric Ref    Use Iface
default        $WAN_GW    0.0.0.0         UG    10     0        0 eth1.2
default        $WAN2_GW   0.0.0.0         UG    20     0        0 eth1.3
10.50.0.0      *          255.255.0.0     U     0      0        0 tun1
10.52.0.0      *          255.255.0.0     U     0      0        0 tun0
$VPN1_IP1      $WAN_GW    255.255.255.255 UGH   10     0        0 eth1.2
$VPN1_IP2      $WAN_GW    255.255.255.255 UGH   10     0        0 eth1.2
$VPN1_IP3      $WAN_GW    255.255.255.255 UGH   10     0        0 eth1.2
$VPN2_IP1      $WAN2_GW   255.255.255.255 UGH   20     0        0 eth1.3
$VPN2_IP2      $WAN2_GW   255.255.255.255 UGH   20     0        0 eth1.3
$VPN2_IP3      $WAN2_GW   255.255.255.255 UGH   20     0        0 eth1.3
$WAN           *          255.255.255.0   U     10     0        0 eth1.2
$WAN2          *          255.255.255.0   U     20     0        0 eth1.3
$LAN           *          255.255.255.0   U     0      0        0 br-lan
```

## MWAN3

Now install and configure MWAN3.

```
# /etc/config/mwan3
 
config globals 'globals'
	option mmx_mask '0x3F00'
	option rtmon_interval '5'
 
config rule 'default_rule'
	option dest_ip '0.0.0.0/0'
	option proto 'all'
	option sticky '0'
	option use_policy 'vpn_failover'
 
config interface 'tun0'
	option enabled '1'
	option initial_state 'online'
	option family 'ipv4'
	list track_ip '8.8.8.8'
	list track_ip '8.8.4.4'
	option track_method 'ping'
	option reliability '1'
	option count '1'
	option size '56'
	option max_ttl '60'
	option check_quality '0'
	option timeout '2'
	option down '3'
	option up '3'
	option interval '3'
	option recovery_interval '3'
	option failure_interval '3'
 
config interface 'tun1'
	option enabled '1'
	option initial_state 'online'
	option family 'ipv4'
	list track_ip '8.8.8.8'
	list track_ip '8.8.4.4'
	option track_method 'ping'
	option reliability '1'
	option count '1'
	option size '56'
	option max_ttl '60'
	option check_quality '0'
	option timeout '2'
	option down '3'
	option up '3'
	option interval '3'
	option failure_interval '3'
	option recovery_interval '3'
 
config member 'tun0_m3_w3'
	option interface 'tun0'
	option metric '3'
	option weight '3'
 
config member 'tun1_m5_w10'
	option interface 'tun1'
	option metric '5'
	option weight '10'
 
config policy 'vpn_failover'
	list use_member 'tun0_m3_w3'
	list use_member 'tun1_m5_w10'
	option last_resort 'unreachable'
```
