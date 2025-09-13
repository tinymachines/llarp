# USB Bluetooth support

**Cleanup Required!**  
This page or section needs cleanup. You can edit this page to fix wiki markup, redundant content or outdated information.

![:!:](/lib/images/smileys/exclaim.svg) There are differences between bluez5,bluez4 and current (2015) bluez5. (daemon names, config files ...)

##### Other Bluetooth guides

- [Bluetooth LE 6LoWPAN](/docs/guide-user/hardware/bluetooth/bluetooth.6lowpan "docs:guide-user:hardware:bluetooth:bluetooth.6lowpan")
- [Bluetooth Audio](/docs/guide-user/hardware/bluetooth/bluetooth.audio "docs:guide-user:hardware:bluetooth:bluetooth.audio")
- [Smartphone Bluetooth Tethering](/docs/guide-user/hardware/bluetooth/bluetooth.tether "docs:guide-user:hardware:bluetooth:bluetooth.tether")
- [Bluetooth Speakers](/docs/guide-user/hardware/bluetooth/bluetooth.speakers "docs:guide-user:hardware:bluetooth:bluetooth.speakers")

Some images offered on the OpenWrt download page, come with the basic [USB](https://en.wikipedia.org/wiki/Universal%20Serial%20Bus "https://en.wikipedia.org/wiki/Universal Serial Bus") support already included, if yours does not, this page will explain how to install USB support. The [OPKG](/docs/guide-user/additional-software/opkg "docs:guide-user:additional-software:opkg") packages needed to obtain a very basic USB support under OpenWrt are the following (please read about the different [host controller interfaces](https://en.wikipedia.org/wiki/Host%20controller%20interface "https://en.wikipedia.org/wiki/Host controller interface") on Wikipedia):

Name Size (KB) Required Desciption kmod-usb-core 67012 yes Kernel support for USB. kmod-usb-uhci 14897 specific Kernel support for USB **U**HCI controllers. Alternative to ohci. kmod-usb-ohci 10949 specific Kernel support for USB **O**HCI controllers. Alternative to uhci. kmod-usb2 21879 specific Kernel support for USB2 (**E**HCI) controllers. kmod-ledtrig-usbdev 3502 no Kernel module to drive LEDs based on USB device presence/activity. usbutils 191664 no USB devices listing utilities: `lsusb`, `...` kmod-bluetooth 126843 yes Kernel support for Bluetooth devices. bluez-daemon 487K yes Bluetooth daemon. bluez-libs 31943 yes Bluetooth library. bluez-utils 208236 yes Bluetooth utilities. dbus 296173 yes Simple interprocess messaging system (daemon), dependency of bluez-utils

By installing the correct kernel packages, your GNU/Linux system is able to address the bus. Now, depending on what you want to connect over the bus, you still need to install the drivers for that specific device. Please see [usb.overview](/docs/guide-user/hardware/usb.overview "docs:guide-user:hardware:usb.overview")

## Installation

## Manually installing all needed packages

If you wish to manually install all needed packages needed for bluetooth support just issue this command:

**Space needed: ~1.3 MB**

```
opkg update
opkg install kmod-bluetooth bluez-libs bluez-utils kmod-usb-core kmod-usb-uhci kmod-usb2 usbutils
```

In OpenWRT &gt;=18.06:

```
opkg update
opkg install kmod-bluetooth bluez-libs bluez-utils kmod-usb-core kmod-usb-uhci kmod-usb2 usbutils bluez-daemon
```

## Enabling automatic Bluetooth device support

**bluez-tools** automatically installs **dbus** as dependency package but it is not enabled by default in order to have benefits of **dbus** you need to enable both **dbus** and **bluez-utils** or **bluetoothd** services to start on boot:

```
/etc/init.d/dbus enable
/etc/init.d/dbus start
```

```
/etc/init.d/bluez-utils enable
/etc/init.d/bluez-utils start
```

In 18.06 the **bluez-daemon** installs the **bluetoothd** init script instead of **bluez-utils**:

```
/etc/init.d/bluetoothd enable
/etc/init.d/bluetoothd start
```

## Manually testing Bluetooth devices

There are few basic commands to test if you bluetooth device is properly detected and working ok.

**hciconfig**

Print name and basic information about all the Bluetooth devices installed in the system:

```
# hciconfig 
hci0:	Type: USB
	BD Address: 00:1A:82:00:12:11 ACL MTU: 339:6 SCO MTU: 180:1
	DOWN 
	RX bytes:454 acl:0 sco:0 events:16 errors:0
	TX bytes:70 acl:0 sco:0 commands:16 errors:0
```

hciconfig is part of the bluez-utils package.

To activate a device, use:

```
# hciconfig hci0 up
```

**hcitool**

To scan for remote devices:

```
# hcitool scan
```

## Manually insert a pin

hcid.conf man page is missing this info:

```
/var/lib/bluetooth/nn:nn:nn:nn:nn:nn/pincodes

    Default location for pins for pairing devices. The file is line separated, with the following columns separated by whitespace:

    nn:nn:nn:nn:nn:nn Remote device address.

    n 1-8 digit pin code. User may have to consult hardware documentation in cases of hard coded pins. Try 0000
```

## Troubleshooting and issues

If bluetooth device doesn't inicialize correctly and doesn't show up while running **hcitool dev** command try reinitializing bluetooth stack:

```
hciconfig hci0 reset
hciconfig hci0 up
/etc/init.d/bluez-utils restart
```
