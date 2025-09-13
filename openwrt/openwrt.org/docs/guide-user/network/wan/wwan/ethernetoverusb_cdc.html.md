# Use cdc\_ether driver based dongles for WAN connection

This recipe explains how to setup and configure OpenWrt for using a USB 3G/4G/5G modem operating in ECM mode supported by `cdc_ether` driver.

The same applies to *external* modems connected to USB ports and *internal* models installed into M.2(NGFF) or mPCIe slots.

## Required Packages

Before using your USB modem, install packages either in LuCI → System → Software or via command line:

```
root@OpenWrt:~# opkg update
root@OpenWrt:~# opkg install kmod-usb-net-cdc-ether
```

You can also add the necessary packages when building a new image with [Firmware Selector](https://firmware-selector.openwrt.org/ "https://firmware-selector.openwrt.org/").

Some \[older] modems may additionally need `usb-modeswitch` package. It is used to *switch* the modem into a “working” *mode*. More about: [USB mode switch](/docs/guide-user/network/wan/wwan/usb-modeswitching "docs:guide-user:network:wan:wwan:usb-modeswitching")

If the installation was successful, plugging the USB dongle in or restarting the internal modem will show similar messages in the log:

```
root@OpenWrt:~# dmesg
[  208.424433] usb 1-1: new high-speed USB device number 3 using ehci-platform
[  209.251501] usb 1-1: USB disconnect, device number 3
[  209.652469] usb 1-1: new high-speed USB device number 4 using ehci-platform
[  210.060700] cdc_ether 1-1:1.0 usb0: register 'cdc_ether' at usb-1b000000.usb-1, CDC Ethernet Device, d2:60:c8:b6:65:46
```

Note the interface name (`usb0`) mentioned on the last line, it will be used later. For another modem the name could be `eth2` or something like that.

It is worth to check the output of `cat /sys/kernel/debug/usb/devices` to make sure the necessary drivers are loaded for USB interfaces:

```
root@OpenWrt:~# cat /sys/kernel/debug/usb/devices

[...]

T:  Bus=01 Lev=01 Prnt=01 Port=00 Cnt=01 Dev#=  3 Spd=480  MxCh= 0
D:  Ver= 2.00 Cls=02(comm.) Sub=00 Prot=00 MxPS=64 #Cfgs=  1
P:  Vendor=12d1 ProdID=14dc Rev= 1.02
S:  Manufacturer=HUAWEI
S:  Product=HUAWEI Mobile
C:* #Ifs= 3 Cfg#= 1 Atr=80 MxPwr=500mA
I:* If#= 0 Alt= 0 #EPs= 1 Cls=02(comm.) Sub=06 Prot=00 Driver=cdc_ether
E:  Ad=83(I) Atr=03(Int.) MxPS=  16 Ivl=32ms
I:* If#= 1 Alt= 0 #EPs= 2 Cls=0a(data ) Sub=00 Prot=00 Driver=cdc_ether
E:  Ad=82(I) Atr=02(Bulk) MxPS= 512 Ivl=0ms
E:  Ad=02(O) Atr=02(Bulk) MxPS= 512 Ivl=0ms
I:* If#= 2 Alt= 0 #EPs= 2 Cls=08(stor.) Sub=06 Prot=50 Driver=(none)
E:  Ad=84(I) Atr=02(Bulk) MxPS= 512 Ivl=0ms
E:  Ad=03(O) Atr=02(Bulk) MxPS= 512 Ivl=125us

[...]
```

## Modem Preparation

Some modems require manual switching into ECM mode by using AT commands. This could be done on any computer prior to installation or on the router directly using a terminal application like `picocom`. More about: sending [AT commands](/docs/guide-user/network/wan/wwan/at_commands "docs:guide-user:network:wan:wwan:at_commands") from the router.

A few extra packages need to be installed in order to “talk” with the modem from the router:

```
opkg install kmod-usb-serial-option picocom
```

This is an example for popular Quectel modems (don't expect these proprietary commands to work on devices from other manufacturers):

```
AT+QCFG="usbnet"	# check the current mode
AT+QCFG="usbnet",1	# set ECM mode
```

Reset the modem to apply changes - power toggle it or send `AT+CFUN=1,1` command.

It is worth checking the APN(s) configured on the modem. If the modem offers its own web interface, use it for this task. Alternatively, if the modem has serial (ttyUSB) interface(s) exposed, use a *terminal* program to query the modem with `AT+CGDCONT?` and observe the output. Example:

```
AT+CGDCONT?
+CGDCONT: 1,"IPV4V6","internet",...
+CGDCONT: 2,"IPV4V6","ims",...
+CGDCONT: 3,"IPV4V6","sos",...
```

Typically, but not always, context #1 is used for Internet connection. If it is not configured with the correct information (IP type and APN), it is recommended to set the desired parameters. Example:

```
AT+CGDCONT=1,"IP","internet"
```

Replace `IP` with `IPV4V6` or `IPV6` if necessary and use your APN instead of `internet`.

While in the *terminal*, check the modem firmware version with `ATI` and see if there is an upgrade available.

![:!:](/lib/images/smileys/exclaim.svg) Since ECM modem typically behaves like a router with DHCP and NAT, it is important that OpenWrt's LAN IP subnet is different from the modem's IP subnet. For some modems the default IP address is `192.168.1.1`, which clashes with OpenWrt's default. Therefore if that address conflict cannot be resolved on the modem side, then OpenWrt LAN IP subnet should be changed to something else.

## Network Configuration

### Using LuCI

Navigate to Network → Interfaces → Add new interface... → Protocol: DHCP Client, Interface: “usb0” (or another name found earlier)

Assign the firewall zone (wan) on 'Firewall Settings' tab.

Open Advanced Settings and make sure that both “Use default gateway” and “Use DNS servers advertised by peer” checkboxes are ticked.

### Editing configuration files

Alternatively you can edit the configuration files with any text editor like `vi` or `nano`:

- add a new interface in `/etc/config/network`:

```
config interface 'wwan'
    option proto 'dhcp'
    option ifname 'usb0'
```

Other [DHCP options](/docs/guide-user/network/ipv4/configuration#protocol_dhcp "docs:guide-user:network:ipv4:configuration") can be used here as well.

- add the same interface name to the “wan” firewall zone in `/etc/config/firewall`:

```
config zone
    option name 'wan'
    [...]
    list network 'wwan'
```

IPv6 interface can be added in a standard way if needed:

```
config interface 'wwan6'
    option proto 'dhcpv6'
    option ifname '@wwan'
    option reqprefix '64'
    option extendprefix '1'
```

Other [DHCPv6 options](/docs/guide-user/network/ipv6/configuration#protocol_dhcpv6 "docs:guide-user:network:ipv6:configuration") can be used here as well.

IPv6 interface needs to be in the “wan” firewall zone in `/etc/config/firewall` as well:

```
config zone
    option name 'wan'
    [...]
    list network 'wwan'
    list network 'wwan6'
```

### Additional steps

For some modems adding an interface will be sufficient, but others may need an APN provisioned, it is also sometimes necessary to send a special “autodial” command to the AT command port. It is recommended to install additional packages `picocom kmod-usb-serial-option` and consult AT Commands Guide for the given modem.

If the modem needs a “dial” command sent on each connection attempt, then it is worth trying to configure the [NCM](/docs/guide-user/network/wan/wwan/ethernetoverusb_ncm "docs:guide-user:network:wan:wwan:ethernetoverusb_ncm") interface instead.

## Modem Settings

Compared to PPP or QMI protocols there are no settings provided from OpenWrt for the modem. All the configuration changes are made on the modem itself, typically by using *AT commands*.

Alternatively, some manufacturers (Huawei, ZTE, etc) provide a web interface where you can enter your APN, check connection status, enter PIN code, enable data roaming, change bands, send/receive SMS, etc. As an example, with Huawei modem in HiLink mode the interface is accessible via `http://hi.link` or `http://192.168.8.1` (that is a default IP address). Modem's own IP address can be seen in the System Log:

```
daemon.notice netifd: wwan (20573): udhcpc: broadcasting discover
daemon.notice netifd: wwan (20573): udhcpc: broadcasting select for 192.168.8.198, server 192.168.8.1
daemon.notice netifd: wwan (20573): udhcpc: lease of 192.168.8.198 obtained from 192.168.8.1, lease time 43200
daemon.notice netifd: Interface 'wwan' is now up
```

If access to the modem interface is blocked, it may be that your firewall does not allow it. In this case you can define a rule like the following:

```
config rule
	option name 'Allow-HiLink'
	option src 'lan'
	option proto 'tcp'
	option target 'ACCEPT'
	option family 'ipv4'
	option dest 'wan'
	list dest_ip '192.168.8.1'
```
