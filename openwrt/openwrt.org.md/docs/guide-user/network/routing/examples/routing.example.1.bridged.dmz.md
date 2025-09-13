# Routing example: Bridged DMZ

[![](/_media/media/doc/howtos/bridgeddmz2.png)](/_detail/media/doc/howtos/bridgeddmz2.png?id=docs%3Aguide-user%3Anetwork%3Arouting%3Aexamples%3Arouting.example.1.bridged.dmz "media:doc:howtos:bridgeddmz2.png")

## Router A

```
# /etc/config/network
 
config switch 'eth0'
	option enable		'1'
 
config switch_vlan 'eth0_0'
	option device		'eth0'
	option vlan		'0'
	option ports		'0 5'
 
config switch_vlan 'eth0_1'
	option device		'eth0'
	option vlan		'1'
	option ports		'4 5'
 
config switch_vlan 'eth0_2'
	option device		'eth0'
	option vlan		'2'
	option ports		'1 2 3 5*'
 
config interface 'wan'
	option device		'eth0.0'
	option proto		'pppoe'
	option username		'MikeRophone'
	option password		'fnord!'
	option keepalive	'10'
	option defaultroute	'1'
 
config interface 'lan'
	option device		'eth0.2'
	option proto		'static'
	option ipaddr		'192.168.2.1'
	option netmask		'255.255.255.0'
 
config interface 'dmz'
	option device		'br-dmz'
	option proto		'static'
	option ipaddr		'192.168.1.1'
	option netmask		'255.255.255.0'
 
config device 'dmz_dev'
	option name		'br-dmz'
	option type		'bridge'
	list ports		'eth0.0'
	list ports		'eth0.1'
 
# /etc/config/wireless
 
config wifi-device 'wl0'
	option type		'broadcom'
	option channel		'5'
	option disabled		'0'
 
config wifi-iface 'dmz'
	option device		'wl0'
	option network		'dmz'
	option mode		'ap'
	option ssid		'HeartOfGold'
	option encryption	'psk2'
	option key		'Beeblebrox'
 
# /etc/config/dhcp
 
config dhcp 'lan'
	option interface	'lan'
	option start 		'100'
	option limit		'50'
	option leasetime	'12h'
 
config dhcp 'dmz'
	option interface	'dmz'
	option start 		'100'
	option limit		'50'
	option leasetime	'12h'
```

## Router B

```
# /etc/config/network
 
config switch 'eth0'
	option enable		'1'
 
config switch_vlan 'eth0_0'
	option device		'eth0'
	option vlan		'0'
	option ports		'1 2 5'
 
config switch_vlan 'eth0_1'
	option device		'eth0'
	option vlan		'1'
	option ports		'0 5'
 
config switch_vlan 'eth0_2'
	option device		'eth0'
	option vlan		'2'
	option ports		'3 4 5*'
 
config interface 'wan'
	option device		'eth0.2'
	option proto		'dhcp'
	option ipaddr		'192.168.1.123'
 
config interface 'lan'
	option device		'eth0.0'
	option proto		'static'
	option ipaddr		'192.168.2.1'
	option netmask		'255.255.255.0'
 
config interface 'dmz'
	option device		'br-dmz'
	option proto		'static'
	option ipaddr		'192.168.3.1'
	option netmask		'255.255.255.0'
 
config device 'dmz_dev'
	option name		'br-dmz'
	option type		'bridge'
	list ports		'eth0.1'
	list ports		'eth0.2'
 
# /etc/config/wireless
 
config wifi-device 'wl0'
	option type		'broadcom'
	option channel		'5'
	option disabled		'0'
 
config wifi-iface 'wan'
	option device		'wl0'
	option network		'wan'
	option mode		'sta'
	option ssid		'HeartOfGold'
	option encryption	'psk2'
	option key		'Beeblebrox'
 
config wifi-iface 'dmz'
	option device		'wl0'
	option network		'dmz'
	option mode		'ap'
	option ssid		'FreeBeer'
	option encryption	'none'
 
# /etc/config/dhcp
 
config dhcp 'lan'
	option interface	'lan'
	option start 		'100'
	option limit		'50'
	option leasetime	'12h'
 
config dhcp 'dmz'
	option interface	'dmz'
	option start 		'100'
	option limit		'50'
	option leasetime	'12h'
```
