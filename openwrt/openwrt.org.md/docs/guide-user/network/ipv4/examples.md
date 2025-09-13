# IPv4 examples

Below are a few examples for special, non-standard interface configurations.

### Bridge without IP

```
config interface 'example'
	option proto   'none'
	option device  'br-lan'
	option auto    '1'
 
config device 'example_dev'
	option name 'br-lan'
	option type 'bridge'
	list ports 'eth0'
	list ports 'eth1'
```

### DHCP without default gateway

```
config interface 'example'
	option proto   'dhcp'
	option device  'eth0'
	option defaultroute' '0'
```

### DHCP and IPv6

```
config interface 'example'
	option proto     'dhcp'
	option device    'eth0'
 
config alias
	option interface 'example'
	option proto     'static'
	option ip6addr   '2001:0DB8:100:F00:BA3::1'
```

### Static IP configuration with multiple DNS servers

```
config interface 'example'
	option proto     'static'
	option device    'eth0'
	option ipaddr    '192.168.1.200'
	option netmask   '255.255.255.0'
	list   dns       '192.168.1.1'
	list   dns       '192.168.10.1'
```

![:!:](/lib/images/smileys/exclaim.svg) The last DNS listed will be the first one to be chosen for the name resolution.

![:!:](/lib/images/smileys/exclaim.svg) Restart the service to apply the new DNS configuration: `service dnsmasq restart`

### Static IP configuration and default gateway with non-zero metric

```
config interface 'example'
	option proto     'static'
	option device    'eth0'
	option ipaddr    '192.168.1.200'
	option netmask   '255.255.255.0'
	option dns       '192.168.1.1'
 
config route
	option interface 'example'
	option target    '0.0.0.0'
	option netmask   '0.0.0.0'
	option gateway   '192.168.1.1'
	option metric    '100'
```

### Multiple IP addresses

Assigning multiple IP addresses to the interface `foo`.

```
config interface 'foo'
	option device 'eth1'
	list ipaddr '10.8.0.1/24'
	list ipaddr '10.9.0.1/24'
	list ip6addr 'fdca:abcd::1/64'
	list ip6addr 'fdca:cdef::1/64'
```

See also: [Aliases](/docs/guide-user/network/network_interface_alias "docs:guide-user:network:network_interface_alias")

### Custom MAC address

Configure a custom MAC address for device `eth0`.

```
config device
	option name 'eth0'
	option macaddr '00:11:22:33:44:55'
```
