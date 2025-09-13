# Routing example: GRE

For creating a basic network configuration in [GRE](https://en.wikipedia.org/wiki/Generic_Routing_Encapsulation "https://en.wikipedia.org/wiki/Generic_Routing_Encapsulation") like it shows in the picture.

[![gre.jpeg](/_media/docs/guide-user/network/gre.jpeg?w=800&tok=2b4dbd "gre.jpeg")](/_detail/docs/guide-user/network/gre.jpeg?id=docs%3Aguide-user%3Anetwork%3Arouting%3Aexamples%3Arouting_in_gre "docs:guide-user:network:gre.jpeg")

In this example, we will use 3 routers and 2 PCs.

## Router R1

```
# /etc/config/network
 
config interface 'lan'
	option device 'eth1'
	option proto 'static'
	option ipaddr '172.16.1.1'
	option netmask '255.255.255.0'
	option ip6assign '60'
 
config interface 'wan'
	option device 'eth0'
	option proto 'static'
	option ipaddr '10.1.1.1'
	option netmask '255.255.255.252'
	option gateway '10.1.1.2'
 
config interface 'mygre'
	option ipaddr '10.1.1.1'
	option peeraddr '10.2.2.1'
	option proto 'gre'
 
config interface 'mygre_static'
	option proto 'static'
	option device '@mygre'
	option ipaddr '172.16.12.1'
	option netmask '255.255.255.252'
 
config route 'tunnel'
	option interface 'mygre_static'
	option target '172.16.2.0'
	option netmask '255.255.255.0'
	option gateway '172.16.12.2'
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
 
config interface 'mygre'
	option ipaddr '10.2.2.1'
	option peeraddr '10.1.1.1'
	option proto 'gre'
 
config interface 'mygre_static'
	option proto 'static'
	option device '@mygre'
	option ipaddr '172.16.12.2'
	option netmask '255.255.255.252'
 
config route 'tunnel'
	option interface 'mygre_static'
	option target '172.16.1.0'
	option netmask '255.255.255.0'
	option gateway '172.16.12.1'
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
