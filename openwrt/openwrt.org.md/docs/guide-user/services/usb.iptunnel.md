# USB over IP tunnel

USB/IP Project aims to develop a general USB device sharing system over IP network. To share USB devices between computers with their full functionality, USB/IP encapsulates “USB I/O messages” into TCP/IP payloads and transmits them between computers.

![:!:](/lib/images/smileys/exclaim.svg) This is reported to be working, but we lack a HowTo yet!

## Server on OpenWrt

**Since Barrier Breaker release USBIP packets are missing - there's difference in installation procedure**

First install the usb kernel module and usbip server and client packages:

*Attitude Adjustment:*

```
opkg install kmod-usb-ohci usbip-server usbip-client
```

*Barrier Breaker + Chaos Calmer:*

```
opkg install kmod-usb-ohci
opkg install http://downloads.openwrt.org/attitude_adjustment/12.09/ar71xx/generic/packages/usbip_1.1.1-2_ar71xx.ipk
opkg install http://downloads.openwrt.org/attitude_adjustment/12.09/ar71xx/generic/packages/usbip-client_1.1.1-2_ar71xx.ipk
opkg install http://downloads.openwrt.org/attitude_adjustment/12.09/ar71xx/generic/packages/usbip-server_1.1.1-2_ar71xx.ipk
```

(The packages are installed from AA, but kernel modules would be installed from BB automatically to match kernel ver)

Now use `usbip list -l` to list the local usb devices available that can be exported. In the following example a hub, usb printer, and an optical mouse are shown:

```
root@OpenWrt:~# usbip list -l
Local USB devices
=================
 - busid 2-1 (05e3:0608)
         2-1:1.0 -> hub

 - busid 2-1.4 (04e8:344f)
         2-1.4:1.0 -> unknown
         2-1.4:1.1 -> unknown

 - busid 2-2 (093a:2510)
         2-2:1.0 -> unknown
```

The information that you are looking for is **2-2**, which is the BUSID for the target device (an optical mouse).  
Edit `/etc/rc.local` and before the `exit 0` add the following lines:

```
usbipd -D &
sleep 1
usbip bind -b 2-2
```

Use `netstat` to see if everything works:

```
root@OpenWrt:~# netstat -alpt
Active Internet connections (servers and established)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name    
tcp        0      0 0.0.0.0:3240            0.0.0.0:*               LISTEN      927/usbipd
```

## Client side (Arch-linux PC)

Install **usbip** in your PC

```
[root@tool dani]# pacman -S usbip
```

Load the module for the client

```
[root@tool dani]# modprobe vhci_hcd
```

List the available remote devices at OpenWrt (server side).

```
[root@tool dani]# usbip list -r 192.168.1.1
Exportable USB devices
======================
 - 192.168.1.1
        2-2: Pixart Imaging, Inc. : Optical Mouse (093a:2510)
           : /sys/devices/platform/bcm63xx_ohci.0/usb2/2-2
           : (Defined at Interface level) (00/00/00)
           :  0 - Human Interface Device / Boot Interface Subclass / Mouse (03/01/02)
```

Attach the remote device

```
[root@tool dani]# usbip attach -r 192.168.1.1 -b 2-2
```

If all went fine now you can move the mouse on your pc, but attached to the router with OpenWrt.

## Client side (Windows PC (incl. W7 x64)

Solution consists of 2 parts:

1\. Install Driver

2\. Start usbip tool

1\. Installing a driver could be a challenge - there is a signed drivers, included in 0.200 version of tool. Unfortunately the don't work anymore. at least for Win7 x64. Look through USBIP forum to find the latest compiled driver and tool. Unfortunately the Driver is not signed and in order to install it, you have to switch off Windows drivers signature check. a)Download the working Driver and usbip tool here: [http://sourceforge.net/p/usbip/discussion/418507/thread/86c5e473/](http://sourceforge.net/p/usbip/discussion/418507/thread/86c5e473/ "http://sourceforge.net/p/usbip/discussion/418507/thread/86c5e473/")

b)Disable Windows Drivers check:

```
    Open a command prompt as an admin and type:
    bcdedit -set loadoptions DISABLE_INTEGRITY_CHECKS
    bcdedit -set TESTSIGNING ON
    NOTE: Turning off driver signing is a security risk.
    If it doesn't work, for whatever reason, you can just remove loadoptions with bcedit and >switch testsigning off, though this is not recommended:
    bcdedit /deletevalue loadoptions
    bcdedit -set TESTSIGNING OFF
    For Windows 8.1, use the details on this page:
    [[http://www.howtogeek.com/167723/how-to-disable-driver-signature-verification-on-64-bit-windows-8.1-so-that-you-can-install-unsigned-drivers/]]
    And then restart Windows.
```

2\. Use the tool usbip.exe, downloaded with the working driver.

```
a) usbip -l <HOST IP address>                to show all USB devices binded on the HOST
b) usbip -a <HOST IP address> <BUSID>        to connect to particular Device.
```

![:-D](/lib/images/smileys/biggrin.svg) Tested on BB release. Working at least with USB Drives and Kvaser Leaf Lite CAN gateway.

## Notes

- [http://www.howtoforge.com/how-to-set-up-a-usb-over-ip-server-and-client-with-ubuntu-10.04](http://www.howtoforge.com/how-to-set-up-a-usb-over-ip-server-and-client-with-ubuntu-10.04 "http://www.howtoforge.com/how-to-set-up-a-usb-over-ip-server-and-client-with-ubuntu-10.04")
- [#5590](https://dev.openwrt.org/ticket/5590 "https://dev.openwrt.org/ticket/5590")
- [http://usbip.sourceforge.net/](http://usbip.sourceforge.net/ "http://usbip.sourceforge.net/")
- [#9953](https://dev.openwrt.org/ticket/9953 "https://dev.openwrt.org/ticket/9953") (usbip server on OpenWRT fails after client tries to attach device) also features a small how to.
