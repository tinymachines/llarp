## WireGuard routing all traffic

## Introduction

For some reasons you would like to force all traffic behind your router going through a Wireguard tunnel.

## Prerequisites

- A working Wireguard server
- All informations needed by a wireguard peer:
  
  - Endpoint IP or FQDN
  - Endpoint Port
  - Peer IP
  - Server Public Key
  - Peer Private Key
  - Preshared Key
- Optional: In order to avoid DNS leaks:
  
  - DNS Server reachable on Wireguard Server

## Install the prerequisite packages

```
opkg update
opkg install wireguard-tools
```

## Create Wireguard interface

Here we create the Wireguard interface named: “wg0\_int”

```
 # /etc/config/network
config interface 'wg0_int'
    option proto 'wireguard'
    option private_key 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
    list addresses '192.168.3.100/32'
```

This second part define the peer.

In our case the peer is the “Wireguard Server” you want redirect all traffic to.

```
config wireguard_wg0_int
    option description '<Peer_name>'
    option public_key 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
    option preshared_key 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
    list allowed_ips '0.0.0.0/0'
    option route_allowed_ips '1'
    option endpoint_port '<Peer_port>'
    option persistent_keepalive '15'
    option endpoint_host '<Peer_IP_or_FQDN>'
```

## Configure Firewall

Here the idea is to replace the default forward rule

```
 # /etc/config/firewall
config forwarding
    option src 'lan'
    option dest 'wan'
```

by this one, forwarding lan traffic to wg0\_zone instead of wan.

```
 # /etc/config/firewall
config forwarding
    option src 'lan'
    option dest 'wg0_zone'
```

Also you need to activate “Masquerading” on wg0\_zone:

```
 # /etc/config/firewall
config zone
    option name 'wg0_zone'
    option input 'DROP'
    option forward 'DROP'
    list network 'wg0_int'
    option masq '1'
    option output 'DROP'
```

## DNS Configuration

In order to avoid DNS Leak it is also a good idea to use a DNS Server hosted on the “Wireguard Server” (Same Public IP).

Here we just tell dnsmask to forward request to this other DNS.

(Pihole can be a good solution)

```
 # /etc/config/dhcp
config dnsmasq
    list server '<DNS_server_to_forward_request_to_(peer_internal_wg0_ip)>'
```

## Example Configuration

This is a full working configuration.

- All traffic from lan\_zone is forwarded to wg0\_zone
- Firewall default behevior is DROP. Only necessary traffic is allowed
- DNS request are forwarded

```
# /etc/config/network
config interface 'loopback'
    option device 'lo'
    option proto 'static'
    option ipaddr '127.0.0.1'
    option netmask '255.0.0.0'
 
config interface 'wan_int'
    option proto 'dhcp'
    option device 'eth0'
 
config interface 'wg0_int'
    option proto 'wireguard'
    option private_key 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
    list addresses '192.168.3.100/32'
 
config wireguard_wg0_int
    option description '<Peer_name>'
    option public_key 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
    option preshared_key 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
    list allowed_ips '0.0.0.0/0'
    option route_allowed_ips '1'
    option endpoint_port '<Peer_port>'
    option persistent_keepalive '15'
    option endpoint_host '<Peer_IP_or_FQDN>'
 
config interface 'lan_int'
    option proto 'static'
    option device 'eth2'
    option ipaddr '192.168.1.1'
    option netmask '255.255.255.0'
    option delegate '0'
    option defaultroute '0'
```

```
# /etc/config/firewall
config defaults
    option synflood_protect '1'
    option drop_invalid '1'
    option input 'DROP'
    option output 'DROP'
    option forward 'DROP'
 
config zone
    option name 'lan_zone'
    list network 'lan_int'
    option forward 'DROP'
    option input 'DROP'
    option output 'DROP'
 
config zone
    option name 'wan_zone'
    option masq '1'
    option mtu_fix '1'
    option forward 'DROP'
    option input 'DROP'
    list network 'wan_int'
    option output 'DROP'
 
config rule
    option name 'Allow-DHCP-Renew'
    option src 'wan_zone'
    option proto 'udp'
    option dest_port '68'
    option target 'ACCEPT'
    option family 'ipv4'
 
config rule
    option name 'Allow-IGMP'
    option src 'wan_zone'
    option proto 'igmp'
    option family 'ipv4'
    option target 'ACCEPT'
 
config include
    option path '/etc/firewall.user'
 
config zone
    option name 'wg0_zone'
    option input 'DROP'
    option forward 'DROP'
    list network 'wg0_int'
    option masq '1'
    option output 'DROP'
 
config rule
    option name 'Allow_DNS_IN'
    option family 'ipv4'
    option src 'lan_zone'
    option dest_port '53'
    option target 'ACCEPT'
 
config rule
    option name 'Allow_SSH_OUT'
    option family 'ipv4'
    list proto 'tcp'
    option dest 'lan_zone'
    option dest_port '22'
    option target 'ACCEPT'
 
config forwarding
    option src 'lan_zone'
    option dest 'wg0_zone'
 
config rule
    option name 'Allow_Wireguard_OUT'
    option family 'ipv4'
    list proto 'udp'
    option dest 'wan_zone'
    list dest_ip '<Wireguard_server_IP>'
    option dest_port '<Wireguard_server_port>'
    option target 'ACCEPT'
 
config rule
    option name 'Allow_DHCP_IN'
    option family 'ipv4'
    list proto 'udp'
    option dest_port '67'
    option target 'ACCEPT'
    option src 'lan_zone'
 
config rule
    option name 'Allow_DHCP_OUT'
    option family 'ipv4'
    list proto 'udp'
    option dest_port '68'
    option target 'ACCEPT'
    option dest 'lan_zone'
 
config rule
    option family 'ipv4'
    option dest 'wg0_zone'
    option target 'ACCEPT'
    option name 'Allow_DNS_OUT'
    list proto 'tcp'
    list proto 'udp'
    option dest_port '53'
 
config rule
    option name 'Allow_HTTP(S)_OUT'
    option family 'ipv4'
    list proto 'tcp'
    option dest 'wg0_zone'
    option dest_port '80 443'
    option target 'ACCEPT'
 
config rule
    option name 'Allow_NTP_OUT'
    option family 'ipv4'
    list proto 'udp'
    option dest 'wg0_zone'
    option dest_port '123'
    option target 'ACCEPT'
```

```
 # /etc/config/dhcp
config dnsmasq
    option domainneeded '1'
    option localise_queries '1'
    option rebind_protection '1'
    option rebind_localhost '1'
    option local '/lan/'
    option domain 'lan'
    option expandhosts '1'
    option authoritative '1'
    option readethers '1'
    option leasefile '/tmp/dhcp.leases'
    option resolvfile '/tmp/resolv.conf.d/resolv.conf.auto'
    option localservice '1'
    option ednspacket_max '1232'
    list server '<DNS_server_to_forward_request_to_(peer_internal_wg0_ip)>'
```

#### Screenshot Example

[![](/_media/media/wireguard/1.png?w=500&tok=9300dc)](/_media/media/wireguard/1.png "media:wireguard:1.png") [![](/_media/media/wireguard/2.png?w=500&tok=02ca44)](/_media/media/wireguard/2.png "media:wireguard:2.png") [![](/_media/media/wireguard/3.png?w=600&tok=fa9d3c)](/_media/media/wireguard/3.png "media:wireguard:3.png")
