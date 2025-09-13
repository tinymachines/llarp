# Use 3G/UMTS USB Dongle for WAN connection

This tutorial explains how to setup and configure OpenWrt for using a USB 3G/UMTS modem or a smartphone for WAN connection using legacy (and slow) **PPP** protocol.  
Most modern 4G(LTE) and 5G(NR) USB modems provide newer **QMI**, **MBIM**, **NCM**, **ECM**, **RNDIS** protocols for connection instead of obsolete **PPP** protocol, they are faster and better, overall recommended. For more information:

- **QMI** and **MBIM**, see [How to Use LTE modem in QMI mode for WAN connection](/docs/guide-user/network/wan/wwan/ltedongle "docs:guide-user:network:wan:wwan:ltedongle")
- **NCM**, see [How To use LTE modem in NCM mode for WAN connection](/docs/guide-user/network/wan/wwan/ethernetoverusb_ncm "docs:guide-user:network:wan:wwan:ethernetoverusb_ncm")
- **ECM**, see [Use cdc\_ether driver based dongles for WAN connection](/docs/guide-user/network/wan/wwan/ethernetoverusb_cdc "docs:guide-user:network:wan:wwan:ethernetoverusb_cdc")
- **RNDIS**, see [How To use LTE modem in RNDIS mode for WAN connection](/docs/guide-user/network/wan/wwan/ethernetoverusb_rndis "docs:guide-user:network:wan:wwan:ethernetoverusb_rndis")

You may want to checkout the [mwan3](/docs/guide-user/network/wan/multiwan/mwan3 "docs:guide-user:network:wan:multiwan:mwan3") (Multi WAN load balancing/failover) package to use this simultaneously with other connections to the Internet.

![:!:](/lib/images/smileys/exclaim.svg) Cellular mobile telephony can be intercepted very easily. Remember this is a wireless connection.

![:!:](/lib/images/smileys/exclaim.svg) Most mobile ISPs do not provide *public* IP addresses, so configuring *port forwarding* makes no sense.

![:!:](/lib/images/smileys/exclaim.svg) If you've got a Huawei E367 (which will work), or a Huawei E585 (which does not currently work), you may want to read the following tutorial (which includes info on why you may not be able to get the on-board micro-SD card to function): [http://www.draisberghof.de/usb\_modeswitch/bb/viewtopic.php?t=836](http://www.draisberghof.de/usb_modeswitch/bb/viewtopic.php?t=836 "http://www.draisberghof.de/usb_modeswitch/bb/viewtopic.php?t=836")

![:!:](/lib/images/smileys/exclaim.svg) If you have the Leadtek FlashOFDM card (Flarion) from T-Mobile in Slovakia and the Asus WL-500g Premium, you may use the image on [http://www.accalio.com/index.php?id=301](http://www.accalio.com/index.php?id=301 "http://www.accalio.com/index.php?id=301"). If you wish to get more information, or another distribution with the driver, please contact Accalio [http://www.accalio.com](http://www.accalio.com "http://www.accalio.com")

![:!:](/lib/images/smileys/exclaim.svg) Serial device modes: If a dongle in already configured for serial mode, it is not necessary to install `usb-modeswitch` onto your router device. Modem sticks are commonly equipped with a flash storage containing drivers and software and/or provide a slot for a microSD card. These features (like the 'NO-CD' feature) can be configured in various ways. These configurations may be stored permanently. In that case a modeswitch will behave in an unpredictable way. A modem stick, that was previously configured as a modem, will show up as serial devices (like `/dev/ttyUSBx`). A default setting in combination with modeswitch may additionally show the SD-card reader. See the Troubleshooting section in this document for further information.

## Preparations

### Required Packages

First install required packages:

- *comgt*
- Appropriate host controller interface for your USB hardware (precompiled images will most likely already contain the correct one)
  
  - *kmod-usb2* (aka EHCI)
  - *kmod-usb-ohci*
  - *kmod-usb-uhci* (for example VIA chips)
- Support for serial communication; needed to send control commands to the dongle and receive its responses:
  
  - *kmod-usb-serial*, and
  - *kmod-usb-serial-option*, and
  - *kmod-usb-serial-wwan*, or
  - *kmod-usb-acm* i.s.o. the last two, depending on dongle/phone hardware.
- *usb-modeswitch*, if your modem initially presents itself as a storage device and it needs to be switched into a *modem* mode
- *luci-proto-3g* for web-based configuration

### Dependencies

If you are doing an offline installation, you might need some of these packages handy

- *kmod-usb-core*, usually already in the default install
- *chat*, dependency of *comgt*
- *ppp*, dependency of *chat*, usually already in the default install
- *kmod-usb-serial*, dependency of *kmod-usb-serial-option*
- *libusb* [or the "compatible" library](http://www.draisberghof.de/usb_modeswitch/#download "http://www.draisberghof.de/usb_modeswitch/#download") from *libusb-1.0*, dependency of *usb-modeswitch*

## Installation

First install needed packages:

```
opkg update
opkg install comgt kmod-usb-serial kmod-usb-serial-option kmod-usb-serial-wwan usb-modeswitch
```

Now plug your USB Dongle to the USB port and restart the router.

Check dmesg for:

```
USB Serial support registered for generic
usbserial_generic 1-1:1.0: generic converter detected
USB Serial support registered for generic
usbserial_generic 1-1:1.0: generic converter detected
usb 1-1: generic converter now attached to ttyUSB0
usbserial_generic 1-1:1.1: generic converter detected
usb 1-1: generic converter now attached to ttyUSB1
...
usbcore: registered new interface driver usbserial_generic
usbserial: USB Serial Driver core
USB Serial support registered for GSM modem (1-port)
usbcore: registered new interface driver option
option: v0.7.2:USB Driver for GSM modems
```

If above lines do not appear in dmesg, but instead you see something like:

```
scsi1 : SCSI emulation for USB Mass Storage devices
usb-storage: device found at 4
usb-storage: waiting for device to settle before scanning
scsi 1:0:0:0: CD-ROM            Novatel  Mass Storage     2.31 PQ: 0 ANSI: 0
scsi 1:0:0:0: Attached scsi generic sg1 type 5
usb-storage: device scan complete
```

then, depending on your modem, you have to switch device mode (described below).

If you can't see `usbserial_generic` go to [usbserial\_generic missing in dmesg](/docs/guide-user/network/wan/wwan/3gdongle#usbserial_generic_missing_in_dmesg "docs:guide-user:network:wan:wwan:3gdongle")

### Switching USB mode

Install [usb-modeswitch](/packages/pkgdata/usb-modeswitch "packages:pkgdata:usb-modeswitch") package if that is needed for switching the modem into a “working” state. More about: [USB mode switch](/docs/guide-user/network/wan/wwan/usb-modeswitching "docs:guide-user:network:wan:wwan:usb-modeswitching").

## Manual Configuration

The shown configuration replaces the WAN line, so no further changes are needed to the firewall/other configuration. Note that if you also want to use the WAN port, you have to define it as WAN2 in the configuration. If you define the 3g connection as WAN2, you have to do more changes to other parts, like firewall and so on.

### Network configuration

Edit your `/etc/config/network` file: (see [network 3G section](/docs/guide-user/network/wan/wan_interface_protocols#protocol_3g_ppp_over_ev-do_cdma_umts_or_gprs "docs:guide-user:network:wan:wan_interface_protocols") for more details)

```
config interface wan
#        option ifname  ppp0 # on some carriers enable this line
        option pincode 1234
        option device  /dev/ttyUSB0
        option apn     your.apn
        option service umts
        option proto   3g
```

Replace 'pincode' with the correct pincode of your SIM card. Note that a disabled pincode on the SIM card is problematic, please enable it. If you are connecting to a phone where the pincode has already been entered, there is no need for this.

Replace 'device' with the correct USB port of your modem. On a phone this might for example be `/dev/ttyACM0`.

Replace 'apn' with the correct APN of your 3G/umts provider.

Note in case your APN also requires an username/password, you can configure this too, just add to the network configuration file:

```
    option username yourusername
    option password yourpassword
```

Replace 'username' and 'password' with the correct username/password you received from your 3g provider. You can also look for this information (apn, username and password) in the [mobile-broadband-provider-info database](http://git.gnome.org/browse/mobile-broadband-provider-info/tree/serviceproviders.xml "http://git.gnome.org/browse/mobile-broadband-provider-info/tree/serviceproviders.xml") from the Gnome project.

For some providers, apparently it is necessary to add `noipdefault` to `pppd_options`. If `logread` shows that the connection was established and CHAP authentication was successful, but the connection was immediately dropped after, then try:

```
    option 'pppd_options' 'noipdefault'
```

If your provider supports PAP authentication only then you need to disable all other protocols via these added options:

```
    option 'pppd_options' 'noipdefault refuse-chap refuse-mschap refuse-mschap-v2 refuse-eap' 
```

Now you have configured the network interface.

### Chat configuration

Now we need to check if the default chatscript does work with your 3g provider or not.

You can find it here '/etc/chatscripts/3g.chat', it looks like this:

```
ABORT   BUSY
ABORT   'NO CARRIER'
ABORT   ERROR
REPORT  CONNECT
TIMEOUT 12
""      "AT&F"
OK      "ATE1"
OK      'AT+CGDCONT=1,"IP","$USE_APN"'
ABORT   'NO CARRIER'
TIMEOUT 15
OK      "ATD*99***1#"
CONNECT ' '
```

If your modem needs a special AT command, your can add it to this file. You may have to edit the dial number of the ATD command to fit in with your provider's settings (for example “\*99#” instead of “\*99\*\*\*11#”).

## Establishing connection

Just type on console 'ifup wan'

Now check dmesg logread for successful connect:

```
pppd 2.4.4 started by root, uid 0
abort on (BUSY)
abort on (ERROR)
report (CONNECT)
timeout set to 12 seconds
send (AT&F^M)
expect (OK)
AT&F^M^M
OK
 -- got it
send (ATE1^M)
expect (OK)
^M
ATE1^M^M
OK
 -- got it
send (AT+CGDCONT=1,"IP","your.apn"^M)
abort on (NO CARRIER)
timeout set to 15 seconds
expect (OK)
^M
AT+CGDCONT=1,"IP","your.apn"^M^M
OK
 -- got it
send (ATD*99***1#^M)
expect (CONNECT)
^M
ATD*99***1#^M^M
CONNECT
 -- got it
send ( ^M)
Serial connection established.
Using interface 3g-wan
Connect: 3g-wan <--> /dev/ttyUSB0
Could not determine remote IP address: defaulting to x.x.x.x
local  IP address x.x.x.x
remote IP address  x.x.x.x
primary   DNS address  x.x.x.x
secondary DNS address  x.x.x.x
adding wan (3g-wan) to firewall zone wan
```

That's it, now you should be connected.

If you want an permanent connect from startup, add 'ifup wan' command to '/etc/rc.local' file.

## Debugging signal strength issues

For troubleshooting or locating the best position for the USB Dongle, you can use

```
gcom info -d /dev/ttyUSBx
```

from the console. This tool will report signal strength, but also network registration and SIM status. If it returns a port-in-use error because your connection is already up, try

```
gcom -d /dev/ttyUSBx
```

where `x` represents a port number not used by the wan connection itself.

`gcom` returns the signal quality in RSSI ([Received signal strength indication](https://en.wikipedia.org/wiki/Received%20signal%20strength%20indication "https://en.wikipedia.org/wiki/Received signal strength indication")) and in BER ([Bit error rate](https://en.wikipedia.org/wiki/Bit%20error%20rate "https://en.wikipedia.org/wiki/Bit error rate"), reported in percent). A higher RSSI value represents a stronger signal - scale is from 0 to 99, where 1 is the lowest detectable signal and 31 a very good signal. Don't expect your signal to go all the way up to 99, though. If BER returns 99 it means not known or not detectable.

If your 3G modem is e.g. a ZTE K3565-Z featuring a LED SSI indicator to show it's status (Not Connected, GPRS, UMTS) you may be mislead to believe, that a strong signal strength of e.g. 17 may be better, while you only get GPRS, but a value of 4 allows for UMTS access. This is owed to the circumstance, that the device may switch over to another cell. The only method to prevent a handover between a GPRS and an UMTS station during the process of optimizing, is to initiate the device to use 'UMTS only' in the first place.

You can also add the AT command

```
""      "AT+CSQ"
```

to your [chat script](/docs/guide-user/network/wan/wwan/3gdongle#chatconfiguration "docs:guide-user:network:wan:wwan:3gdongle") to check signal quality.

Command return is “+CSQ: &lt;rssi&gt;,&lt;ber&gt;” and looks like this in `logread`:

```
send (AT+CSQ^M)
expect (OK)
^M
AT+CSQ^M^M
+CSQ: 11,99^M
^M
OK
-- got it
```

If you have problems establishing a connection and multiple modem devices (`/dev/ttyUSB0`, `/dev/ttyUSB1`, ...) are present, try **all** of them. Some may not work at all while others seem to work at first, but will give a `NO CARRIER` during the connection process.

## AICCU interaction

`/etc/hotplug.d/iface/30-aiccu` starts aiccu when the WAN connection is established. It seems however that, in the case of 3G connections, the start scripts are started just a bit too early and the start of aiccu fails. I have butchered the script a bit:

```
#!/bin/sh

[ "$ACTION" = "ifup" -a "$INTERFACE" = "wan" ] && /etc/init.d/aiccu enabled && sleep 15; /etc/init.d/aiccu restart
```

Note that sixxs really frowns upon quick re-re-restarts of aiccu, it may get your account blocked for unjust use of resources. Be careful with these scripts.

## Installing multiple 3G dongles

You can use multiple USB 3G dongles easily by using an active USB hub.

Prepare for the next steps: We assume you have at least one 3G dongle configured. You will need an active internet connection in order to install modules for 3g support.

1\. Connect an active USB hub to the OpenWrt router. You need to assure, that the power supply will deliver sufficient power for all of your 3G dongles. A proper estimation is, that you will need 500+ mA per one 3G dongle. Remember that modem can slightly exceed its declared power consumption in HDSPA+ modes. Be generous and pick USB hub with some power source overhead.

2\. Connect all 3G dongles and start.

3\. Browse through `logread` output (or System Log in Luci) to check if modems are properly recognized and `/dev/ttyUSBx` ports are assigned.

4\. Usually a 3G modem has a few *serial* ports - one for control/configuration, another for PPP data service, etc. Exeplum gratum: A Huawei E1750 has three ports. The first one is a communication port and last is a service port. If you only have one modem, it will be recognized as `/dev/ttyUSB0 /dev/ttyUSB1 /dev/ttyUSB2`. You need to configure interface using `/dev/ttyUSB0` (the first one). A Huawei E372 has five ports, but similar to other Huawei devices, the communication port (or “PC UI” as they call it) is the first one.

5\. You need to configure the interfaces, an example of “/etc/config/network” could look like this:

```
config 'interface' 'wan'
	option 'proto' '3g'
	option 'service' 'umts'
	option 'device' '/dev/ttyUSB0'
	option 'apn' 'internet'
	option 'pincode' ''
	option 'username' ''
	option 'password' ''
```

Usually you need to provide an APN name in “option 'apn' 'Name-Of-APN-HERE'”. If your SIM card is locked with a PIN, or if your provider requires to use a username and/or password, add it accordingly.

6\. Check `logread` output for other \[pre-]existing `/dev/ttyUSBx` ports. In my case I have second modem starting with /ttyUSB3 (previous one use /ttyUSB0 to /ttyUSB2) so second interface looks like this:

```
config 'interface' 'wan2'
	option 'proto' '3g'
	option 'service' 'umts'
	option 'maxwait' '0'
	option 'device' '/dev/ttyUSB3'
	option 'apn' 'internet'
	option 'pincode' ''
	option 'username' ''
	option 'password' ''
```

7\. Remember to add a new interface to the “wan” zone in the firewall's config file “/etc/config/firewall” (it may differ in your case):

```
config 'zone'
	option 'name' 'wan'
	option 'input' 'REJECT'
	option 'output' 'ACCEPT'
	option 'forward' 'REJECT'
	option 'masq' '1'
	option 'mtu_fix' '1'
	option 'network' 'wan wan2'
```

Look at last line - there is wan2 added.

8\. Now you have both interfaces configured and they should work.

9\. You can use both interfaces as a failover.

## Additional DNS configuration

Follow: [DNS and DHCP configuration examples](/docs/guide-user/base-system/dhcp_configuration "docs:guide-user:base-system:dhcp_configuration")

## Easy Configuration Using Luci Web Interface

[Luci](/docs/guide-user/luci/luci.essentials "docs:guide-user:luci:luci.essentials") has supported 3G configuration. Be sure to have **luci** and **luci-proto-3g** installed.

To create a new 3g connection, go to Luci web interface. Navigate to Network ⇒ interfaces. Click on **Add new interface** button. Give a simple name to the interface, for example **3g** and choose **UMTS/GPRS/EVDO** as its protocol.

Here is basic configuration to get the connection working.

```
# General Setup
Protocol : UMTS/GPRS/EVDO
Modem device : /dev/ttyUSB0
Service type : UMTS only (You may prefer UMTS/GPRS if you wish)
APN : internet (Not needed for CDMA/EVDO)
PIN : 1234 (Leave it blank if you don't use pin)
PAP/CHAP username : <ask your 3G provider>
PAP/CHAP password : <ask your 3G provider> 

# Advanced Settings (leave them as default)

# Firewall Settings
Create / Assign firewall zone : wan
```

## Obtaining IPv6 address

If you want to enable IPv6 on 3G connection, make sure that your dongle supports PDPv6[1)](#fn__1) and your 3G provider is providing IPv6 service.

To enable IPv6 negotiation on the PPP link, issue the following command.

```
uci set network.3g.ipv6=1
uci commit network.3g
```

Be sure to replace *3g* with the correct name of 3G interface.

In addition, be sure to edit file `/etc/chatscripts/3g.chat` for PDPv6 configuration as currently there is no [UCI](/docs/techref/uci "docs:techref:uci") entry for PDPv6.

```
ABORT   BUSY
ABORT   'NO CARRIER'
ABORT   ERROR
REPORT  CONNECT
TIMEOUT 10
""      "AT&F"
OK      "ATE1"
OK      'AT+CGDCONT=1,"IPV6","$USE_APN"'
SAY     "Calling UMTS/GPRS"
TIMEOUT 30
OK      "ATD$DIALNUMBER"
CONNECT ' '
```

You may use the following chatscript for PDPv4v6 configuration. Make sure that your dongle supports PDv4v6[2)](#fn__2) before attempting to modify the chatscript.

```
ABORT   BUSY
ABORT   'NO CARRIER'
ABORT   ERROR
REPORT  CONNECT
TIMEOUT 10
""      "AT&F"
OK      "ATE1"
OK      'AT+CGDCONT=1,"IPV4V6","$USE_APN"'
SAY     "Calling UMTS/GPRS"
TIMEOUT 30
OK      "ATD$DIALNUMBER"
CONNECT ' '
```

If you are using Luci, be sure to check *Enable IPv6 negotiation on the PPP link* and optionally *Use builtin IPv6-management* on the *Advanced settings* section of the 3G interface configuration page. Also, be sure to modify /etc/chatscripts/3g.chat file for PDPv6 as explained above.

Of course you can use other methods to obtain IPv6 instead of relying on PPP negotiation. See [IPv6](/docs/guide-user/network/ipv6/start "docs:guide-user:network:ipv6:start") for more explanation.

## Compile things yourself

If you want to build an own firmware containing support for a UMTS Modem, maybe this BuildHowTo will help you: [Wireless router with a 3G dongle and multiwan for failover on Wired, Wireless client (routed) and 3G](/docs/guide-developer/build-image-with-3g-dongle-support "docs:guide-developer:build-image-with-3g-dongle-support")

## Troubleshooting

### Howto activate serial mode through web browser on CDC-Ethernet devices

WARNING - this will deactivate WEB-GUI access on these devices!!! You need to know howto submit AT commands to a modem in order to restore the GUI.

#### Huawei

Browse to [http://192.168.1.1/html/switchProjectMode.html](http://192.168.1.1/html/switchProjectMode.html "http://192.168.1.1/html/switchProjectMode.html") with JavaScript enabled browser.

#### ZTE

Browse to [http://192.168.0.1/goform/goform\_process?goformId=MODE\_SWITCH&amp;switchCmd=FACTORY](http://192.168.0.1/goform/goform_process?goformId=MODE_SWITCH&switchCmd=FACTORY "http://192.168.0.1/goform/goform_process?goformId=MODE_SWITCH&switchCmd=FACTORY") with JavaScript enabled browser.

### Howto restore CDC mode on CDC-Ethernet capable devices

#### Huawei

`AT^U2DIAG=255` or `AT+U2DIAG=276`, see [http://www.3g-modem-wiki.com/page/Huawei+AT-commands](http://www.3g-modem-wiki.com/page/Huawei+AT-commands "http://www.3g-modem-wiki.com/page/Huawei+AT-commands")

#### ZTE

`AT+ZCDRUN=9`

`AT+ZCDRUN=F`

Sources: [3)](#fn__3)[4)](#fn__4)

### Workarounds for specific devices

#### Huawei E220/Chaos Calmer

If you encounter problems with an undetected Huawei E220, you can try the following - this resets the E220 to its factory defaults, so it can again be handled by the new JSON-based modeswitch. This will re-enable the CD-ROM Mode.

1\. Make the modem work once, by manually telling the kernel to use generic (option) drivers.

```
echo '12d1 1003 ff' > /sys/bus/usb-serial/drivers/generic/new_id
```

2\. Shutdown WWAN (necessary only if WWAN was previously configured)

```
ifdown WWAN
```

3\. Modes of the E220 Modem + PC UI

```
echo  "AT^U2DIAG=0" >/dev/ttyUSB0
```

Modem + CD

```
echo  "AT^U2DIAG=1" >/dev/ttyUSB0
```

4\. Reboot

```
reboot
```

### usbserial\_generic missing in dmesg

If you can't see usbserial\_generic in dmesg, try loading the usbserial module (&lt;vid&gt; and &lt;pid&gt; are Vendor and Product ID of your device):

```
rmmod usbserial #optional
insmod /lib/modules/`uname -r`/usbserial.ko vendor=0x<vid> product=0x<pid>
```

Alternatively, you can also use option GSM driver on your dongle. Option driver is more reliable, as it can distinguish between serial port and storage port.

```
insmod option #skip this if option driver is loaded already
echo '<vid> <pid> ff' > /sys/bus/usb-serial/drivers/option1/new_id
```

To automate the process of attaching option serial driver on boot, just edit `/etc/rc.local` and place

```
echo '<vid> <pid> ff' > /sys/bus/usb-serial/drivers/option1/new_id
```

before the exit code

```
exit 0
```

Adding the above to hotplug instead of rc.local: You can easily integrate this into hotplug in the following way - in this example we will use a fictional “3G Dongie HSPA+” Dongle:

Create and edit the file /etc/hotplug.d/usb/22-dongie\_hspaplus:

```
#!/bin/sh                                                                       
...
                                                                                
DONGIEHSPAPLUS_PRODID="0815/9000/0"                                                
if [ "${PRODUCT}" = "${DONGIEHSPAPLUS_PRODID}" ]; then                             
        if [ "${ACTION}" = "add" ]; then                           
...             
                echo '0815 9000 ff' > /sys/bus/usb-serial/drivers/option1/new_id
...
```

If your modem's switched product id is 0815:9000, the above will work. So for your modem you will have to replace all appearances of the variable DONGIEHSPAPLUS\_PRODID and all appearance of “0815” and “9000” in the above example with your matching product's name, vendor and product id.

Check dmesg again for:

```
usbcore: registered new interface driver usbserial
USB Serial support registered for generic
usbserial_generic 1-1.3:1.0: generic converter detected
usb 1-1.3: generic converter now attached to ttyUSB0
usbserial_generic 1-1.3:1.1: generic converter detected
usb 1-1.3: generic converter now attached to ttyUSB1
usbcore: registered new interface driver usbserial_generic
usbserial: USB Serial Driver core
```

Also check kernel USB debug for loaded drivers

```
root@OpenWrt:~# cat /sys/kernel/debug/usb/devices

T:  Bus=01 Lev=01 Prnt=01 Port=00 Cnt=01 Dev#=  3 Spd=480  MxCh= 0
D:  Ver= 2.00 Cls=00(>ifc ) Sub=00 Prot=00 MxPS=64 #Cfgs=  1
P:  Vendor=1c9e ProdID=9800 Rev= 0.00
S:  Manufacturer=USB Modem
S:  Product=USB Modem
S:  SerialNumber=1234567890ABCDEF
C:* #Ifs= 4 Cfg#= 1 Atr=e0 MxPwr=500mA
I:* If#= 0 Alt= 0 #EPs= 2 Cls=ff(vend.) Sub=ff Prot=ff Driver=option
E:  Ad=81(I) Atr=02(Bulk) MxPS= 512 Ivl=0ms
E:  Ad=01(O) Atr=02(Bulk) MxPS= 512 Ivl=4ms
I:* If#= 1 Alt= 0 #EPs= 3 Cls=ff(vend.) Sub=ff Prot=ff Driver=option
E:  Ad=82(I) Atr=03(Int.) MxPS=  64 Ivl=2ms
E:  Ad=83(I) Atr=02(Bulk) MxPS= 512 Ivl=0ms
E:  Ad=02(O) Atr=02(Bulk) MxPS= 512 Ivl=4ms
I:* If#= 2 Alt= 0 #EPs= 2 Cls=ff(vend.) Sub=ff Prot=ff Driver=option
E:  Ad=84(I) Atr=02(Bulk) MxPS= 512 Ivl=0ms
E:  Ad=03(O) Atr=02(Bulk) MxPS= 512 Ivl=4ms
I:* If#= 3 Alt= 0 #EPs= 2 Cls=08(stor.) Sub=06 Prot=50 Driver=usb-storage
E:  Ad=04(O) Atr=02(Bulk) MxPS= 512 Ivl=0ms
E:  Ad=85(I) Atr=02(Bulk) MxPS= 512 Ivl=0ms
```

[1)](#fnt__1)

To check if your dongle support PDPv6, open up serial terminal (Putty, screen, minicom, microcom, or picocom), and type **AT+CGDCONT=?**. If the response shows a line containing “IPV6”, for example **+CGDCONT: (1-11),“IPV6”,,,(0-2),(0-3)**, your dongle supports PDPv6. Otherwise, your dongle is stuck with IPv4.

[2)](#fnt__2)

See previous note.

[3)](#fnt__3)

[http://www.techytalk.info/disable-virtu](http://www.techytalk.info/disable-virtu "http://www.techytalk.info/disable-virtu") … m-devices/

[4)](#fnt__4)

[https://www.semanticlab.net/index.php/UMTS\_with\_OpenWRT](https://www.semanticlab.net/index.php/UMTS_with_OpenWRT "https://www.semanticlab.net/index.php/UMTS_with_OpenWRT")
