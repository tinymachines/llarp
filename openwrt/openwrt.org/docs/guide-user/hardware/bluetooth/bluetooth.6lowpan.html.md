# IPv6 over Bluetooth Smart (Low Energy)

Cross-compilation tested on Ubuntu 14.10 with kernel 3.18. Tested routers:

- ASUS RT-N16
- x86\_64 (Virtual Box)

## Prerequisites

- Bluetooth 4.0 USB dongle
- trunk (CC 3.18)

## Needed Modules

Kernel modules→Other Modules:

- kmod-6lowpan
- kmod-bluetooth
- kmod-bluetooth\_6lowpan

Kernel modules→USB support:

- kmod-usb-core
- kmod-usb-ohci
- kmod-usb2

Libraries:

- bluez-libs

Utilities:

- bluez-utils

## Example of usage

Below procedure shows how to establish a connection with Bluetooth Smart device (with IPv6 stack software) and do a ping. Note that router has to have Bluetooth Smart chip or dongle connected to USB.

Load 6LoWPAN module:

```
modprobe 6lowpan
modprobe bluetooth_6lowpan
```

Set PSM channel as 0x23 (35):

```
echo 35 > /sys/kernel/debug/bluetooth/6lowpan_psm
```

Look for available HCI devices:

```
hciconfig
```

Reset HCI device - e.g. hci0 device:

```
hciconfig hci0 reset
```

Read 00:AA:BB:XX:YY:ZZ address of bluetooth device:

```
hcitool lescan
```

Connect to the device:

```
echo "connect 00:AA:BB:XX:YY:ZZ 1" > /sys/kernel/debug/bluetooth/6lowpan_control
```

Check if connection has been established:

```
ifconfig
```

Try to ping device using its link-local address, e.g. on bt0 interface:

```
ping6 -I bt0 fe80::2AA:BBFF:FEXX:YYZZ
```
