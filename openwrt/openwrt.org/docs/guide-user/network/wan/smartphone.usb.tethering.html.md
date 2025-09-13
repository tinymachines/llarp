# Smartphone USB tethering

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

## Introduction

USB tethering is used to connect your OpenWrt Router to the Internet by using the your smartphone. It's more convenient and has better performance (lower latency) than turning your smartphone into an access point and using that. It also is less of a CPU load on your phone, charges your phone, and allows you the flexibility of doing things with your OpenWrt router that you cannot do with your phone like connecting multiple devices with ease, both wireless and wired, to each other and to the internet. In order to maximize performance, you should turn your tethered phone Wi-Fi and Bluetooth off.

- ![:!:](/lib/images/smileys/exclaim.svg) USB tethering is known to be problematic on [iOS 14 devices](https://forum.openwrt.org/t/has-the-ios14-tethering-issue-been-resolved/74949 "https://forum.openwrt.org/t/has-the-ios14-tethering-issue-been-resolved/74949"). works without patch on latest trunk 01/2022, 21.02.1 needs patch
- ![:!:](/lib/images/smileys/exclaim.svg) Connecting your whole network to the Internet using the Smartphone might consume your monthly traffic quota very fast.
- Follow [USB reverse tethering](/docs/guide-user/network/wan/smartphone.usb.reverse.tethering "docs:guide-user:network:wan:smartphone.usb.reverse.tethering") to share the internet from router to the smartphone over USB.

A new option has arrived with Android 11: '**Ethernet Tethering**'. The only devices that seem to consistently support it, across a wide variety of phones, are AXIS-Chipset based Ethernet-to-USB-C adapters. The upside to using an adapter instead of a direct USB tether that requires you first load additional USB support into the router, is simply uses an ethernet cable to connect to the WAN port on your router. The downside is, if the phone ever restarts, if the adapter is ever unplugged from the phone, or the USB-C PD power feed to the adapter is interrupted, it is necessary to manually go to the phone, to Network, Hotspot &amp; Tethering, and re-enable Ethernet Tethering. There is no automated, programmatic method to re-enable it, yet. USB Tethering, however, can be set to automatically re-enable, e.g. after a power loss. Note: *Merely rebooting the router with Ethernet Tethering enabled, does not disable ethernet tethering. Tethering will automatically work when the router starts back up. But if the power to the phone/adapter is interrupted, it will turn off on the phone, and need to be manually re-enabled.*

## Instructions

### 1. Installation of USB Support on Router

For the easiest installation, have a wired upstream internet connection to boot-strap this process.

You will need: the router, your tethering phone, necessary cables, a computer and an upstream Internet connection via Ethernet for initial setup. Instead of a wired upstream connection,[it is also possible to download necessary packages below, through your computer while tethered to your phone,](https://forum.openwrt.org/t/install-packages-while-offline/66148 "https://forum.openwrt.org/t/install-packages-while-offline/66148") the same way you can get the OpenWrt distribution for your router. If you need to manually download the packages on another device for bootstrapping, see also [get\_additional\_software\_packages](/downloads#get_additional_software_packages "downloads"). The Kernel modules will be in the URL of form `downloads.openwrt.org/releases/[your release]/targets/[your target]/generic/packages/` and other packages (iOS stuff in this case) in `downloads.openwrt.org/releases/[release]/packages/[instruction set]/packages/`.

Other alternative ways to bootstrap, include using the phone's WiFi hotspot and a micro-router configured as a wireless-to-ethernet device, or an Ethernet-to-USB-C adapter \[see above].

RNDIS is the most common protocol for Android-based devices for tethering via USB. The following commands will install [kmod-usb-net-rndis](/packages/pkgdata/kmod-usb-net-rndis "packages:pkgdata:kmod-usb-net-rndis") kernel module and its dependencies on the router:

```
opkg update
opkg install kmod-usb-net-rndis
```

See also [How To use LTE modem in RNDIS mode for WAN connection](/docs/guide-user/network/wan/wwan/ethernetoverusb_rndis "docs:guide-user:network:wan:wwan:ethernetoverusb_rndis")

Android devices come with great diversity, therefore some require different [protocols](https://en.wikipedia.org/wiki/Ethernet_over_USB "https://en.wikipedia.org/wiki/Ethernet_over_USB"). For instance, newer devices may use NCM, others may require EEM or even need a subset implementation.

**NOTE:** You may need to add a different protocol if you don't see that a new interface (usually - `usb0` or `ethX`) has been added on the router or the device keeps disconnecting:

```
opkg install kmod-usb-net-cdc-ncm

# Huawei may need its own implementation!
opkg install kmod-usb-net-huawei-cdc-ncm

# More protocols:
kmod-usb-net-cdc-eem
kmod-usb-net-cdc-ether
kmod-usb-net-cdc-subset
```

Extra steps depending on [USB type and drivers](/docs/guide-user/storage/usb-installing "docs:guide-user:storage:usb-installing") for your router:

```
opkg update
opkg install kmod-nls-base kmod-usb-core kmod-usb-net kmod-usb-net-cdc-ether kmod-usb2
```

Additional steps for iOS devices:

```
opkg update
opkg install kmod-usb-net-ipheth usbmuxd libimobiledevice usbutils
 
# Call usbmuxd
usbmuxd -v
 
# Add usbmuxd to autostart
sed -i -e "\$i usbmuxd" /etc/rc.local
```

### 2. Smartphone Settings

Connect the smartphone to the USB port of the router with the USB cable, and then enable `USB Tethering` from the Android settings. Turn on the phone's `Developer Options` *\[Find the `Build` information in the `About Phone` menu, and tap rapidly 7x]*. There is a `Default USB Configuration, USB Tethering` option in Developer Options. The phone will now immediately turn on USB Tethering mode when plugged into a configured router \[or laptop], without further commands. However, **it is necessary to remove the screen lock on the phone. A locked phone will not start automatically USB Tethering by itself.** *E.G. When the router starts, or restarts after a scheduled reboot, if the phone is locked, it needs to be manually unlocked if a screen lock is activated.*

For iPhones, you may have to disable and re-enable the *Personal Hotspot/Allow Others to Join* setting on the iPhone to force the OpenWrt DHCP client to get an IP address from the eth1 iPhone interface. Disabling and re-enabling the *Personal Hotspot/Allow Others to Join* setting on the iPhone is also required if you disconnect the iPhone from the OpenWrt USB port and re-connect it later, unless you cache Trust records (see watchdog section and/or LeJeko's Github repository in reference section).

iPhones starting from iOS 11 will terminate the USB data connections after one hour by default to improve security. This can easily be changed via:

`Settings > Touch ID/Face ID & Passcode > USB Accessories > ON` ([macworld](https://www.macworld.com/article/233368/that-s-right-you-can-t-turn-off-personal-hotspot-in-ios-13-and-ipados-13.html "https://www.macworld.com/article/233368/that-s-right-you-can-t-turn-off-personal-hotspot-in-ios-13-and-ipados-13.html"))

### 3.a Router: Web interface

Go back to the router and navigate to “Network” then “Interfaces”.

Here you can simply assign the existing WAN&amp;WAN6 Interfaces to `usb0`, or create a whole new interfaces (e.g. 'TetheringWAN', 'TetheringWAN6') that use `usb0`, if you want both to be active, and be able to swap between the WAN Ethernet port and USB tethering (such as in a dual-wan fail-over situation). To make the easiest changes: in the web interface, simply edit the existing default WAN &amp; WAN6 interfaces, and change the physical device to `usb0`, then “Save &amp; Apply”.

TetheringWAN: To create a whole new USB interface, and leave WAN&amp;WAN6 connected to the WAN Ethernet port, make a new Interface called **TetheringWAN**, and bind to it the new `usb0` network device (restart if you do not see it yet. And, for some cases, the new interface may be called `eth1`: check what the log is showing in your case). Set the protocol to DHCP client mode, and under the Firewall Settings tab, place it into the WAN zone. Then you can also make a 'TetheringWAN6', and assign it to DHCPv6 Client. See below for more information on further configuring IPv6 so your clients can use it.

Save changes.

See the following screenshots:  
First page of the Create Interface wizard.  
[![](/_media/docs/guide-user/advanced/image_create_new_interface.png?w=800&tok=1b4f10)](/_media/docs/guide-user/advanced/image_create_new_interface.png "docs:guide-user:advanced:image_create_new_interface.png")  
Firewall tab of the Create Interface Wizard. Very important to set it as WAN.  
[![](/_media/docs/guide-user/advanced/image_create_new_interface_set_firewall_region.png?w=800&tok=7b9c37)](/_media/docs/guide-user/advanced/image_create_new_interface_set_firewall_region.png "docs:guide-user:advanced:image_create_new_interface_set_firewall_region.png")  
And the end result in the Interfaces page:  
[![](/_media/docs/guide-user/advanced/image_create_new_interface_end_result.png?w=800&tok=b5a710)](/_media/docs/guide-user/advanced/image_create_new_interface_end_result.png "docs:guide-user:advanced:image_create_new_interface_end_result.png")

#### WAN Activity light

When you create a second interface or simply switch the existing WAN Interface to `usb0`, the WAN activity light will go out. To reactivate it's function (blinking on activity), go to System, LED Configuration, Name - Wan, Edit, and change Device: `wan` to `usb0`. Save &amp; Save-&amp;-Apply.

After committing the changes, the WAN&amp;WAN6 or new TetheringWAN/TetheringWAN6 should be active. Otherwise, restart them with the buttons you find in the **Interface** page of LuCI web interface.

### 3.b Router: Command Line Interface

```
# Enable tethering
uci set network.wan.ifname="usb0"
uci set network.wan6.ifname="usb0"
uci commit network
/etc/init.d/network restart
```

For iPhones, replace the interface name `usb*` with `eth*`.

**All your clients and router should have internet connectivity at this point.**

## Troubleshooting &amp; Optimizations

If all went well, you should be able to see something like the following in the log

- click on **Status** and then on **System Log** to see this log from the LuCi web interface
- or use `dmesg` command on the [console over SSH](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")

```
[  176.449246] usb 1-1: new high-speed USB device number 3 using orion-ehci
[  176.654650] rndis_host 1-1:1.0 usb0: register 'rndis_host' at usb-f1050000.ehci-1, RNDIS device, ee:da:c0:50:ff:44
```

Note the interface name (`usb0`) mentioned on the last line, this is the name to use during the setup process.

With iPhone attached and necessary driver loaded the log output will be different:

```
[  276.139195] usb 4-1: new high-speed USB device number 2 using ehci-platform
[  276.344366] usb 4-1: New USB device found, idVendor=05ac, idProduct=12a8, bcdDevice=14.06
[  276.352586] usb 4-1: New USB device strings: Mfr=1, Product=2, SerialNumber=3
[  276.359800] usb 4-1: Product: iPhone
[  276.363431] usb 4-1: Manufacturer: Apple Inc.
[  276.367818] usb 4-1: SerialNumber: XXXXXXXXXXXXXXXXXXXXXXXX
[  413.508513] ipheth 4-1:4.2: Apple iPhone USB Ethernet device attached
```

The interface device name will not appear in the logs unlike the previous example, until the interface is manually created in OpenWrt and underlying device is selected. In practice it will be the next available `ethX` like `eth1` in this example. The name can be discovered by running the following line of code on the console (replace `4-1:4.2` with numbers from your log):

```
root@OpenWrt:~# for a in /sys/class/net/*; do readlink $a; done | grep  4-1:4.2 | xargs -r basename
eth1
```

### Overcoming bottlenecks

Openwrt 22.03 and newer ([using nftables/fw4, instead of older iptables/fw3](/docs/guide-user/firewall/firewall_configuration "docs:guide-user:firewall:firewall_configuration")):

1.) Put this in /etc/config/firewall

```
config include
    option path '/etc/firewall.user'
    option fw4_compatible '1'
```

2.) Create the file '/etc/firewall.user'

3.) Put these lines in it:

```
nft add rule inet fw4 mangle_forward oifname usb0 ip ttl set 65
nft add rule inet fw4 mangle_forward oifname usb0 ip6 hoplimit set 65
#for USB tethering, OR:
nft add rule inet fw4 mangle_forward oifname wan ip ttl set 65
nft add rule inet fw4 mangle_forward oifname wan ip6 hoplimit set 65
#for regular WAN ethernet uplink
```

4.) Restart the firewall

```
/etc/init.d/firewall restart
```

There is no way to do the above commands through the web interface Luci, [https://forum.openwrt.org/t/custom-rules-on-firewall-tab/120056](/docs/guide-user/network/wan/yet_on_current_versions_of_openwrt "docs:guide-user:network:wan:yet_on_current_versions_of_openwrt"). These changes require [ssh or another CLI method](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration"), and a text editor (e.g. [nano](/packages/pkgdata/nano "packages:pkgdata:nano")). The Custom/User Firewall tab, is missing in current builds (23.x).

### Connectivity Issues Related to Cell Provider Networks

You may notice the following: Android client devices to the router, will say there is 'no internet', but laptops may function fine. Intermittent connectivity issues to certain sites, but no problems connecting to others. Certain apps will behave poorly. Certain websites will take an otherwise unexplainably long time to load. There will be unaccounted-for hesitation on your connection, compared with no issues using them at the tethering phone directly. To further verify, before making these changes, test by opening a Wireguard connection directly from your device to your VPN host.

On some providers, it may be necessary to reduce the MTU (e.g. Verizon):  
Set `Network > Interfaces > Devices > usb0 > Configure` (or 'wan' if you are using an ethernet-to-usb-c adapter) to an MTU of 1400, and an IPv6 MTU of 1400.

Another fix is `Network > Firewall > General Settings`: On the 'LAN → WAN' rule, turn on **Masquerading** and **MSS Clamping**.

### Restart tethering on connection failure

If your tethering connection fails every so often, and:

- You see in your client devices that there is no internet connectivity, and
- Your phone is still showing a good 4G/tower connection, and tethering enabled, and
- Simply unplugging your tethering phone and plugging it back into the router fixes the problem

Then it might be fixed with the following solution:

1.) Install packages:

```
opkg update
opkg install hub-ctrl
```

2.) Create the connectivity checking script:

```
nano /root/wan-watchdog.sh
```

3.) Copy and paste:

```
#!/bin/sh
 
# Fetch WAN gateway
. /lib/functions/network.sh
network_flush_cache
network_find_wan NET_IF
network_get_gateway NET_GW "${NET_IF}"
 
# Check WAN connectivity
TRIES="0"
while [ "${TRIES}" -lt 5 ]
do
    if ping -c 1 -w 3 "${NET_GW}" &> /dev/null
    then exit 0
    else let TRIES++
    fi
done
 
# Restart network
/etc/init.d/network stop
hub-ctrl -h 0 -P 1 -p 0
sleep 1
hub-ctrl -h 0 -P 1 -p 1
/etc/init.d/network start
```

4.) Run:

```
chmod +x /root/wan-watchdog.sh
```

5.) Set the script to run every minute as scheduled task: Go to System→Scheduled Tasks, add:

```
* * * * * /root/wan-watchdog.sh
```

Every 1 minute, the script will be run, ping WAN gateway, and if there are 5 consecutive failures, it will stop the network, power off the USB hub (which will terminate tethering on the phone), power it back on, then restart the network. This solution is much faster than restarting the whole router.

### iPhone automatic watchdog

Once you set up iPhone tethering as per above, you'll may notice several issues:

- usbmuxd needs to be started manually after every reboot
- On iPhone, you need to set up trust again after every router reboot
- If your cellular signal is weak, tethering will disconnect every now and then and you'll need to unplug and reconnect USB cable

Save following script to some location that survives reboot, e.g. `/etc/lockdown`, and execute it after every reboot. It should keep tethering up and running as long as iPhone is connected.

```
# Save watchdog script
mkdir -p /etc/lockdown
cat << "EOF" > /etc/lockdown/watchdog.sh
#!/bin/sh
# A small script to make life with iPhone tethering less cumbersome on OpenWrt
# Petr Vyskocil, Apr 2020
# Public domain
 
# After you successfully allow iPhone tethering, copy files with name like
# /var/lib/lockdown/12345678-9ABCDEF012345678.plist to /etc/lockdown/locks.
# That way, you won't have to set up trust again after router reboots.
if [ -e /etc/lockdown/locks ]
then
    mkdir -p /var/lib/lockdown
    cp -f /etc/lockdown/locks/* /var/lib/lockdown/
fi
 
# lockdown records restored, now we can launch usbmuxd. Don't launch it sooner!
usbmuxd
 
# We are up and running now. But unfortunately if your carrier signal is weak, iPhone will
# drop connection from time to time and you'd have to unplug and replug USB cable to start tethering
# again. Script below automates that activity.
 
# First wait a bit - we just brought the interface up by usbmuxd
sleep 20
 
# If we see iPhone ethernet interface, try to ping iPhone router's address (172.20.10.1).
# When the ping is unsuccessful, rebind iPhone ethernet USB driver and wait for things to settle down
while :
do
    for i in /sys/bus/usb/drivers/ipheth/*:*
    do
        test -e "${i}" || continue
        ping -w 3 172.20.10.1 &> /dev/null
        if [ "${?}" -ne 0 ]; then
            echo "${i##*/}" > "${i%/*}"/unbind
            echo "${i##*/}" > "${i%/*}"/bind
            sleep 20
        fi
    done
    sleep 1
done
EOF
chmod +x /etc/lockdown/watchdog.sh
 
# Add watchdog script to autostart
sed -i -e "\$i (/etc/lockdown/watchdog.sh) &" /etc/rc.local
```

### Work around tethering-activation issue on rooted phones

If your Android phone does not seem to detect that there is something attached to the USB port and refuses to switch to USB tethering, you might want to install **DriveDroid** and try to enable various methods of using USB guest for its own functionality. This does solve that issue on some phones. You will probably need **root** (administrator) access on your device though.

### Cell provider assigns IPv6

Cell phone companies are transitioning to IPv6, and they might assign your SIM an IPv6 subnet bigger than a /64, typically, a /56 or /48, but sometimes a /60. You may use an assignment larger than a /64 (/56 or /48) to provide native IPv6 addresses and connectivity to your LAN, but even /64 will provide some connectivity. A quick way to test, is to look at the wan6/TetheringWAN6 interface, and see what kind of IPv6 address was provided.

The following IPv6 settings have consistently worked for cell providers Verizon &amp; TMOBILE: Luci (Web): Your LAN DHCP settings \[Go to: Network, Interfaces, LAN, Edit, DHCP Server, IPv6 Settings] for IPv6 preferences should be set to 'Relay' for **RA-Service**, **DHCPv6-Service** and **NDP-Proxy**. Your WAN6/TetheringWAN6 settings, are 'Designated Master' (checked), and again 'Relay' for all three aspects.

The equivalent CLI settings, editing /etc/config/dhcp:

```
config dhcp 'lan'
        ...
	option dhcpv6 'relay'
	option ra 'relay'
	option ndp 'relay'
	option ra_useleasetime '1'
	option ra_dns '0' # You may need this to get DNS to work properly!
config dhcp 'wan6'
        ...
	option master '1'
	option ra 'relay'
	option dhcpv6 'relay'
	option ndp 'relay'
	option ra_useleasetime '1'
```

It may help to explicitly set your **Gateway Metric** on WAN (IPv4), to a different (lower) value than on WAN6 (IPv6) \[Network, Interfaces, WAN/WAN6/TetheringWAN/TetheringWAN6, Edit, Advanced Settings, Use Gateway Metric]. These are not set, by default, and setting them like this, can clear up some connectivity issues, where the internet connection 'dies' after awhile on Android devices, and needs to be restarted (either by toggling the Wifi on the device, or Airplane Mode).

If your provider does not assign a subnet larger than a /64, you could use [NAT6 and IPv6 masquerading](/docs/guide-user/network/ipv6/ipv6.nat6 "docs:guide-user:network:ipv6:ipv6.nat6") to enable IPv6 access for your LAN clients. One of the features of IPv6 is enough address space to move away from NAT and CGNAT. If you have an IPv6 interface on \*usb0* over the usual IPv4 DHCP client and thus have two WAN interfaces over \*usb0\*, and the provider assigns e.g. a /56, the IPv4 wan interface would be doing NAT and tunneling your traffic, which is overhead native IPv6 would avoid.

### Dual-WAN

Install the [mwan3](/docs/guide-user/network/wan/multiwan/mwan3 "docs:guide-user:network:wan:multiwan:mwan3") and `luci-app-mwan3` packages to manage traffic over both (or up to 250 WAN) interfaces with kernel policy routing, this is especially useful if you're using your cell phone as a secondary WAN interface.

### References

- Tethering instructions (abbreviated) used to correct this guide (2020/06/10): [https://android.stackexchange.com/a/26650](https://android.stackexchange.com/a/26650 "https://android.stackexchange.com/a/26650")
- The original forum thread: [https://forum.openwrt.org/viewtopic.php?pid=173399#p173399](https://forum.openwrt.org/viewtopic.php?pid=173399#p173399 "https://forum.openwrt.org/viewtopic.php?pid=173399#p173399")
- The old wiki archived page [https://oldwiki.archive.openwrt.org/doc/howto/usb.tethering](https://oldwiki.archive.openwrt.org/doc/howto/usb.tethering "https://oldwiki.archive.openwrt.org/doc/howto/usb.tethering")
- A script that might enhance the experience (especially for iPhone users) [https://github.com/LeJeko/OpenWRT-USB-Tethering](https://github.com/LeJeko/OpenWRT-USB-Tethering "https://github.com/LeJeko/OpenWRT-USB-Tethering")

### OpenWrt build issues

If you don't see something like the sample kernel log output in your device's log then your device might be lacking proper USB drivers (drivers to operate the USB controllers at all). Check [Installing USB drivers](/docs/guide-user/storage/usb-installing "docs:guide-user:storage:usb-installing") and report the issue in a bug report or in the mailing list, as devices should have base USB drivers integrated and working already.

For other issues it might be worth it to check [the article about using RNDIS dongles](/docs/guide-user/network/wan/wwan/ethernetoverusb_rndis "docs:guide-user:network:wan:wwan:ethernetoverusb_rndis") as Android tethering is using the same protocol.
