# AOE ((s)ATA over Ethernet) with vblade

The vblade target allows other computers on your network to mount your attached drives over the AOE ([ATA over Ethernet](https://en.wikipedia.org/wiki/ATA%20over%20Ethernet "https://en.wikipedia.org/wiki/ATA over Ethernet")) protocol.

## Example

```
config 'vblade'
	option 'shelf'	'1'
	option 'slot'	'1'
	option 'netif'	'eth0'
	option 'device' '/dev/sda'
 
config 'vblade'
	option 'shelf'	'1'
	option 'slot'	'2'
	option 'netif'	'eth0'
	option 'device' '/dev/sdb
```

Name Type Required Default Option Description `shelf` integer Yes shelf number `solt` integer Yes slot number `netif` string no? interface on which to allow initiators `device` string Yes Block device to export
