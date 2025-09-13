# Use RNDIS USB Dongle for WAN connection

[RNDIS](https://en.wikipedia.org/wiki/RNDIS "https://en.wikipedia.org/wiki/RNDIS") (Remote Network Driver Interface Specification) is [Ethernet over USB](https://en.wikipedia.org/wiki/Ethernet_over_USB "https://en.wikipedia.org/wiki/Ethernet_over_USB") protocol used by some USB modems.

The same applies to external modems connected to USB ports (“dongles”) and internal models installed into M.2(NGFF) or mPCIe slots.

Note from [rndis\_host Linux driver source code](https://github.com/torvalds/linux/blob/master/drivers/net/usb/rndis_host.c "https://github.com/torvalds/linux/blob/master/drivers/net/usb/rndis_host.c"):

> USE OF RNDIS IS STRONGLY DISCOURAGED in favor of such non-proprietary alternatives as CDC Ethernet or the newer (and currently rare) “Ethernet Emulation Model” (EEM).

It is also used by many USB 3.0 to Gigabit Ethernet adapters like the TP-Link UE300 and all Chinese low-cost ones (such as 4G LTE USB Wifi Dongle) you can buy on ebay, etc. It is one of the ways these Gigabit Ethernet dongles use to be “plug and play” or “driverless”, by conforming to RNDIS standard so they don't need a special driver just for themselves. These dongles lack any kind of web interface or settings, they are just USB-to-Ethernet adapters, nothing more.

Worth to add, the same protocol is widely used for [smartphone tethering](/docs/guide-user/network/wan/smartphone.usb.tethering "docs:guide-user:network:wan:smartphone.usb.tethering"), so the same instructions are usually applicable for that use case as well.

For more information about other protocols commonly used:

- **QMI** and **MBIM**, see [How to use LTE modem in QMI mode for WAN connection](/docs/guide-user/network/wan/wwan/ltedongle "docs:guide-user:network:wan:wwan:ltedongle")
- **NCM**, see [How to use LTE modem in NCM mode for WAN connection](/docs/guide-user/network/wan/wwan/ethernetoverusb_ncm "docs:guide-user:network:wan:wwan:ethernetoverusb_ncm")
- **ECM**, see [Use cdc\_ether driver based dongles for WAN connection](/docs/guide-user/network/wan/wwan/ethernetoverusb_cdc "docs:guide-user:network:wan:wwan:ethernetoverusb_cdc")
- **PPP**, see [How to use 3g/UMTS USB Dongle for WAN connection](/docs/guide-user/network/wan/wwan/3gdongle "docs:guide-user:network:wan:wwan:3gdongle")

## Setting up RNDIS-based dongles

For RNDIS device to work `kmod-usb-net-rndis` package needs to be installed. Install it either in Luci → System → Software or via command line:

```
root@OpenWrt:~# opkg update
root@OpenWrt:~# opkg install kmod-usb-net-rndis
```

Additional modules will be automatically installed as *dependencies*.

You can also add the necessary packages when building a new image with [Firmware Selector](https://firmware-selector.openwrt.org/ "https://firmware-selector.openwrt.org/").

Install `usb-modeswitch` *only if* that is needed for switching the modem into a “working” state. More about: [USB mode switch](/docs/guide-user/network/wan/wwan/usb-modeswitching "docs:guide-user:network:wan:wwan:usb-modeswitching")

After installing the packages and connecting the USB stick, the following should appear in `dmesg` output:

```
[  847.390000] usb 1-1: new high-speed USB device number 3 using ehci-platform
[  847.590000] usb 1-1: no of_node; not parsing pinctrl DT
[  847.610000] rndis_host 1-1:1.0: no of_node; not parsing pinctrl DT
[  847.620000] rndis_host 1-1:1.0 usb0: register 'rndis_host' at usb-101c0000.ehci-1, RNDIS device, 72:4d:eb:bb:e2:60
```

Note the *device name* (`usb0`) mentioned on the last line, it will be used later. For another modem the name could be `eth2` or something like that.

If the USB modem or phone will be your only WAN connection, then the easiest way to set up the connection is to change the *device* used by the existing `wan` interface, either in Luci or in `/etc/config/network` as shown below:

```
config interface 'wan'
        option ifname 'usb0'
        option proto 'dhcp'
```

Otherwise a new interface should be created using *device name* discovered earlier; the interface should be assigned to the existing “wan” firewall zone.

(you need to reboot or restart the network subsystem with `/etc/init.d/network restart` afterwards)

![:!:](/lib/images/smileys/exclaim.svg) Since RNDIS-based sticks create their own NAT'ed IP subnet, it is important that OpenWrt's LAN IP subnet is different from the modem's subnet. For some modems the default IP address is `192.168.1.1`, which clashes with OpenWrt's default. Therefore if that address conflict cannot be resolved on the modem side, then OpenWrt's LAN IP subnet should be changed to something else, such as:

```
config interface 'lan'
        option ipaddr '192.168.10.1'
```

### Additional steps

For some modems adding the network interface will be sufficient, but others may need an APN provisioned. It is also sometimes necessary to send a special “dial” command to the AT command port, consult AT Commands Guide for the given modem for details. If this is the case it is worth trying to configure the [NCM](/docs/guide-user/network/wan/wwan/ethernetoverusb_ncm "docs:guide-user:network:wan:wwan:ethernetoverusb_ncm") interface instead.

If the modem exposes *serial* interfaces then the appropriate driver needs to be installed (`kmod-usb-serial` or `kmod-usb-serial-option` or `kmod-usb-serial-qualcomm` or `kmod-usb-acm`) as well as a simple *terminal* app like `picocom`. More about: sending [AT commands](/docs/guide-user/network/wan/wwan/at_commands "docs:guide-user:network:wan:wwan:at_commands") from the router.

If auto-connect is disabled or PIN-request is enabled on the modem or correct APN needs to be set, you may need to visit its admin web interface (typically at `http://192.168.1.1`) to enter the PIN and/or initiate the connection. Modem's own IP address can be seen in the System Log:

```
daemon.notice netifd: wwan (20573): udhcpc: broadcasting discover
daemon.notice netifd: wwan (20573): udhcpc: broadcasting select for 192.168.1.101, server 192.168.1.1
daemon.notice netifd: wwan (20573): udhcpc: lease of 192.168.1.101 obtained from 192.168.1.1, lease time 43200
daemon.notice netifd: Interface 'wwan' is now up
```

### RNDIS Troubleshooting

If you only see the USB messages, but not the rndis\_host messages, then *modeswitching* may be at fault.

Checking with `cat /sys/kernel/debug/usb/devices`, the device section should look like this:

```
T:  Bus=01 Lev=01 Prnt=01 Port=00 Cnt=01 Dev#=  3 Spd=480  MxCh= 0
D:  Ver= 2.01 Cls=00(>ifc ) Sub=00 Prot=00 MxPS=64 #Cfgs=  1
P:  Vendor=1bbb ProdID=0195 Rev= 2.28
S:  Manufacturer=Alcatel
S:  Product=MobileBroadBand
S:  SerialNumber=0123456789ABCDEF
C:* #Ifs= 3 Cfg#= 1 Atr=80 MxPwr=500mA
A:  FirstIf#= 0 IfCount= 2 Cls=e0(wlcon) Sub=01 Prot=03
I:* If#= 0 Alt= 0 #EPs= 1 Cls=e0(wlcon) Sub=01 Prot=03 Driver=rndis_host
E:  Ad=82(I) Atr=03(Int.) MxPS=   8 Ivl=32ms
I:* If#= 1 Alt= 0 #EPs= 2 Cls=0a(data ) Sub=00 Prot=00 Driver=rndis_host
E:  Ad=81(I) Atr=02(Bulk) MxPS= 512 Ivl=0ms
E:  Ad=01(O) Atr=02(Bulk) MxPS= 512 Ivl=0ms
I:* If#= 2 Alt= 0 #EPs= 2 Cls=08(stor.) Sub=06 Prot=50 Driver=(none)
E:  Ad=02(O) Atr=02(Bulk) MxPS= 512 Ivl=125us
E:  Ad=83(I) Atr=02(Bulk) MxPS= 512 Ivl=0ms
```

and not like this:

```
T:  Bus=01 Lev=01 Prnt=01 Port=00 Cnt=01 Dev#=  2 Spd=480  MxCh= 0
D:  Ver= 2.01 Cls=00(>ifc ) Sub=00 Prot=00 MxPS=64 #Cfgs=  1
P:  Vendor=1bbb ProdID=f000 Rev= 2.28
S:  Manufacturer=Alcatel
S:  Product=MobileBroadBand
S:  SerialNumber=0123456789ABCDEF
C:* #Ifs= 1 Cfg#= 1 Atr=80 MxPwr=500mA
I:* If#= 0 Alt= 0 #EPs= 2 Cls=08(stor.) Sub=06 Prot=50 Driver=(none)
E:  Ad=01(O) Atr=02(Bulk) MxPS= 512 Ivl=125us
E:  Ad=81(I) Atr=02(Bulk) MxPS= 512 Ivl=0ms
```

(note the difference with “ProdID=” and number of interfaces)

### RNDIS Security Note

![:!:](/lib/images/smileys/exclaim.svg) Leaving your RNDIS-based dongle admin web interface available to LAN users might not be something you would like to do, as there is usually no authentication mechanism there. To protect it, you can add the following rule to Network→Firewall→Custom Rules (obsolete, needs to be converted to `nftables` rules):

```
iptables -A forwarding_lan_rule -d 192.168.1.0/24 -m comment --comment "no access to USB dongle from LAN" -j DROP
```

Now, if you need to access your dongle web interface, log in to your OpenWrt box with:

```
ssh -L 8080:192.168.1.1:80 root@your-openwrt-ip
```

and point your browser to [http://localhost:8080](http://localhost:8080 "http://localhost:8080").
