# Installing and troubleshooting USB Drivers

1. A [**Quick Start for installing a USB drive**](/docs/guide-user/storage/usb-drives-quickstart "docs:guide-user:storage:usb-drives-quickstart") is available. This solves the very common case of installing a single USB drive onto your OpenWrt device.
2. If the [Quick Start](/docs/guide-user/storage/usb-drives-quickstart "docs:guide-user:storage:usb-drives-quickstart") doesn't address your question, you can install USB drivers manually. Background information about the different USB host controller interfaces (OHCI, UHCI, EHCI, xHCI) is given in a [Wikipedia article](https://en.wikipedia.org/wiki/Host%20controller%20interface "https://en.wikipedia.org/wiki/Host controller interface"). Please refer to your device documentation to find out which USB driver version your device needs.
3. There is a more complete [USB Drives](/docs/guide-user/storage/usb-drives "docs:guide-user:storage:usb-drives") page

## To install USB Drivers Manually

1. Start with refreshing the list of available packages
   
   ```
   opkg update
   ```
2. Obtain a list of already installed USB packages:
   
   ```
   opkg list-installed *usb*
   ```
   
   Result:
   
   ```
   kmod-usb-core - 4.9.58-1
   kmod-usb-storage - 4.9.58-1
   kmod-usb3 - 4.9.58-1
   ...
   ```
3. Install the USB core package (all USB versions), if the previous list-output does not list it:
   
   ```
   opkg install kmod-usb-core
   insmod usbcore
   ```
4. Install the USB storage package (all USB versions), if the previous list-output does not list it:
   
   ```
   opkg install kmod-usb-storage
   ```
5. To install USB 1.1 drivers, first try the UHCI driver:
   
   ```
   opkg install kmod-usb-uhci
   insmod uhci_hcd
   ```
   
   If this fails with an error “No such device”, try installing the alternative OHCI driver for USB 1.1:
   
   ```
   opkg install kmod-usb-ohci
   insmod ohci
   ```
   
   Someone would have to verify this *insmod uhci* command as inconsistent with the installed package - ohci package vs. uhci insmod command

(to remove non-working drivers, use `opkg remove`. Note: If both UCHI and OHCI drivers fail, we do not have USB 1.1.)

1. To install USB 2.0 drivers:
   
   ```
   opkg install kmod-usb2
   insmod ehci-hcd
   ```
2. To install USB 3.0 drivers:
   
   ```
   opkg install kmod-usb3
   insmod xhci-hcd
   ```
3. To install support for UASP aka [USB Attached SCSI](https://en.wikipedia.org/wiki/USB_Attached_SCSI "https://en.wikipedia.org/wiki/USB_Attached_SCSI") (supported by many USB drives and drive enclosures, especially if USB 3.0. It enhances performance if it's supported by both the drive and the host controller in your device):
   
   ```
   opkg install kmod-usb-storage-uas
   ```

**NOTES:**

- Some devices (e.g. Asus WL-500g router, brcm47xx) additionally need the kmod-usb2 module (even though they only have an USB 1.1 controller)
- Some devices (e.g. NLSU2, LinkSys WRT54G3GV2) additionally need the following packages:
  
  ```
  opkg install kmod-usb-ohci-pci
  opkg install kmod-usb2-pci
  ```

## Troubleshooting USB Drivers

### Diagnostics using dmesg

Most firmware images already have USB or SATA support integrated in the default profile/image, so it should not be necessary to install additional packages.  
To check, if USB support in included and if connected USB devices get detected:  
1\. Execute `dmesg` in the terminal, note its output. These are “driver messages”, events related to hardware being connected/started or disconnected/shut-down.  
2\. Now connect your external storage device, wait a few seconds and then execute `dmesg` on the terminal again.  
3\. If USB drivers are active and your device has successfully been recognized, you will notice that additional log output has been added at the end.

Here is an example of the dmesg text about an USB device being connected and properly recognized.

```
[   96.603945] usb 1-1: new high-speed USB device number 2 using ehci-pci
[   96.812362] usb-storage 1-1:1.0: USB Mass Storage device detected
[   96.842945] scsi host4: usb-storage 1-1:1.0
[   98.242956] scsi 4:0:0:0: Direct-Access     JetFlash Transcend 8GB    1100 PQ: 0 ANSI: 4
[   98.415163] sd 4:0:0:0: [sdb] 15826944 512-byte logical blocks: (8.10 GB/7.55 GiB)
[   98.443523] sd 4:0:0:0: [sdb] Write Protect is off
[   98.732241] sd 4:0:0:0: [sdb] Mode Sense: 43 00 00 00
[   98.738043] sd 4:0:0:0: [sdb] No Caching mode page found
[   98.752681] sd 4:0:0:0: [sdb] Assuming drive cache: write through
[   98.893168]  sdb: sdb1 sdb2
[   98.951053] sd 4:0:0:0: [sdb] Attached SCSI disk
```

If your log output does not show USB-related output like this, please check that you have the right drivers and report this as a bug in the [bugtracker](https://bugs.openwrt.org/ "https://bugs.openwrt.org/")

### Diagnostics using lsusb

Further diagnostics information about connected USB drives can be obtained, when installing the optional 'usbutils' package:

```
opkg update && opkg install usbutils
```

This package installs the `lsusb` command that will output information of the router-built in USB-hub and connected USB-devices. The following example was run on a router with a single USB port. lsusb has recognized USB 2.0 and 3.0 support on this port and a connected device consisting of an USB-to-SATA-disk-bridge from ASMedia. Since this device is listed with the same bus-ID as the 3.0 hub, the USB-harddisk obviously is connected via the USB 3.0 protocol:

```
Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
Bus 002 Device 002: ID 174c:1153 ASMedia Technology Inc. ASM2115 SATA 6Gb/s bridge
Bus 002 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
```

The command `lsusb -t` reveals, if your personal combination of device, OpenWrt firmware and external USB drive supports the newer and slightly faster USB 3.0 UASP Extension (USB Attached SCSI Protocol) or the older USB 3.0 block driver:

```
...
/:  Bus 02.Port 1: Dev 1, Class=root_hub, Driver=xhci_hcd/6p, 5000M
    |__ Port 2: Dev 3, If 0, Class=Mass Storage, Driver=uas, 5000M
    |__ Port 4: Dev 5, If 0, Class=Mass Storage, Driver=usb-storage, 5000M
...
```

In this example, device 3 (“Driver=uas”) is UASP-capable, while device 5 (“Driver=usb-storage”) is not.

On USB storage device problems, pay attention to the “Driver” output of `lsusb -t`. If it returned something like

```
|__ Port 4: Dev 5, If 0, Class=Mass Storage, Driver=, 5000M
```

instead of

```
|__ Port 4: Dev 5, If 0, Class=Mass Storage, Driver=usb-storage, 5000M
```

then OpenWrt has recognized the attached USB storage device, but does not have an USB-Storage driver installed yet. In this case you will need to install USB storage drivers first:

```
opkg install kmod-usb-storage
```

### Diagnostics using cat

If you are truly out of options, you can use `cat`. Thanks to linux's “everything is a file” feature, you can look over USB debug information:

```
cat /sys/kernel/debug/usb/devices

T:  Bus=01 Lev=00 Prnt=00 Port=00 Cnt=00 Dev#=  1 Spd=480  MxCh= 2
B:  Alloc=  0/800 us ( 0%), #Int=  0, #Iso=  0
D:  Ver= 2.00 Cls=09(hub  ) Sub=00 Prot=01 MxPS=64 #Cfgs=  1
P:  Vendor=1d6b ProdID=0002 Rev= 4.14
S:  Manufacturer=Linux 4.14.171 xhci-hcd
S:  Product=xHCI Host Controller
S:  SerialNumber=1e1c0000.xhci
C:* #Ifs= 1 Cfg#= 1 Atr=e0 MxPwr=  0mA
I:* If#= 0 Alt= 0 #EPs= 1 Cls=09(hub  ) Sub=00 Prot=00 Driver=hub
E:  Ad=81(I) Atr=03(Int.) MxPS=   4 Ivl=256ms

T:  Bus=01 Lev=01 Prnt=01 Port=01 Cnt=01 Dev#=  4 Spd=480  MxCh= 0
D:  Ver= 2.10 Cls=00(>ifc ) Sub=00 Prot=00 MxPS=64 #Cfgs=  1
P:  Vendor=0781 ProdID=5583 Rev= 1.00
S:  Manufacturer=SanDisk
S:  Product=Ultra Fit
S:  SerialNumber=4C530001091024119291
C:* #Ifs= 1 Cfg#= 1 Atr=80 MxPwr=224mA
I:* If#= 0 Alt= 0 #EPs= 2 Cls=08(stor.) Sub=06 Prot=50 Driver=(none)
E:  Ad=81(I) Atr=02(Bulk) MxPS= 512 Ivl=0ms
E:  Ad=02(O) Atr=02(Bulk) MxPS= 512 Ivl=0ms
```

You can piece enough information together from this output for diagnostics.
