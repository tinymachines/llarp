# Routing example: OpenVPN

For creating a basic network configuration in OpenVPN like it shows in the picture.

[![openvpn.jpeg](/_media/docs/guide-user/network/openvpn.jpeg?w=800&tok=2265b0 "openvpn.jpeg")](/_detail/docs/guide-user/network/openvpn.jpeg?id=docs%3Aguide-user%3Anetwork%3Arouting%3Aexamples%3Arouting_in_openvpn "docs:guide-user:network:openvpn.jpeg")

In this example, we will use 3 routers and 2 stations (computers).

## Router R1

```
# /etc/config/network
 
config interface 'lan'
	option device 'eth1'
	option proto 'static'
	option ipaddr '172.16.1.1'
	option netmask '255.255.255.0'
 
config interface 'wan'
	option device 'eth0'
	option proto 'static'
	option ipaddr '10.1.1.1'
	option netmask '255.255.255.252'
	option gateway '10.1.1.2'
 
# /etc/config/openvpn
 
uci import openvpn < /dev/null
uci set openvpn.myvpn=openvpn
uci set openvpn.myvpn.enabled=1
uci set openvpn.myvpn.dev=tun
uci set openvpn.myvpn.proto=udp
uci set openvpn.myvpn.verb=3
uci set openvpn.myvpn.ca=/etc/openvpn/ca.crt
uci set openvpn.myvpn.cert=/etc/openvpn/my-client.crt
uci set openvpn.myvpn.key=/etc/openvpn/my-client.key
uci set openvpn.myvpn.client=1
uci set openvpn.myvpn.remote_cert_tls=server
uci set openvpn.myvpn.remote="SERVER_IP_ADDRESS 1194"
uci commit openvpn
```

## Router R2

```
# /etc/config/network
 
config interface 'lan'
	option device 'eth0'
	option proto 'static'
	option ipaddr '172.16.2.1'
	option netmask '255.255.255.0'
 
config interface 'wan'
	option device 'eth1'
	option proto 'static'
	option ipaddr '10.2.2.1'
	option netmask '255.255.255.252'
	option gateway '10.2.2.2'
 
# /etc/config/openvpn
 
uci import openvpn < /dev/null
uci set openvpn.myvpn=openvpn
uci set openvpn.myvpn.enabled=1
uci set openvpn.myvpn.verb=3
uci set openvpn.myvpn.port=1194
uci set openvpn.myvpn.proto=udp
uci set openvpn.myvpn.dev=tun
uci set openvpn.myvpn.server='10.8.0.0 255.255.255.0'
uci set openvpn.myvpn.keepalive='10 120'
uci set openvpn.myvpn.ca=/etc/openvpn/ca.crt
uci set openvpn.myvpn.cert=/etc/openvpn/my-server.crt
uci set openvpn.myvpn.key=/etc/openvpn/my-server.key
uci set openvpn.myvpn.dh=/etc/openvpn/dh2048.pem
uci commit openvpn
```

## Router WAN

```
# /etc/config/network
 
config interface 'lan1'
	option device 'eth0'
	option proto 'static'
	option ipaddr '10.1.1.2'
	option netmask '255.255.255.252'
 
config interface 'lan2'
	option device 'eth1'
	option proto 'static'
	option ipaddr '10.2.2.2'
	option netmask '255.255.255.252'
 
config route 'net1'
	option interface 'lan1'
	option target '172.16.1.0'
	option netmask '255.255.255.0'
	option gateway '10.1.1.1'
 
config route 'net2'
	option interface 'lan2'
	option target '172.16.2.0'
	option netmask '255.255.255.0'
	option gateway '10.2.2.1'
```

## Client PCs

For the PCs configuration, we just set up the IP addresses in each station.

```
# PC1
address 172.16.1.3/24
gateway 172.16.1.1
 
# PC2 
address 172.16.2.3/24
gateway 172.16.2.1 
```
