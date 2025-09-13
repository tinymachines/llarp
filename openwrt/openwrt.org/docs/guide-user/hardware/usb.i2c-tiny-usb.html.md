# How to use I²C over USB

## Introduction

Several routers and embedded devices with OpenWRT-support are equipped with one or more USB ports. In order not to risk your warranty by opening your device and soldering an I²C bus to the GPIOs, you can use an USB-I²C adapter to connect to your I²C-devices (e.g. temperature sensors, RTCs, AD-converters, GPIO-expanders, LCD-Drivers). One of those adapters is called [i2c-tiny-usb](http://www.harbaum.org/till/i2c_tiny_usb/index.shtml "http://www.harbaum.org/till/i2c_tiny_usb/index.shtml"), developed by Till Harbaum. Biggest advantage is the low price (though not as cheap as the GPIO mod) and the support in the Linux kernel (thus making it possible to connect it to your computer running a recent Linux distribution and test it). Though you need some basic soldering skills, and at the moment you need to build OpenWRT from source.

## Compiling the kernel module

![](/_media/meta/icons/tango/dialog-information.png) **`Note:`** This module is now in trunk, called kmod-i2c-tiny-usb. You can use a [snapshot](http://downloads.openwrt.org/snapshots/trunk/ "http://downloads.openwrt.org/snapshots/trunk/") and install this kernel module with opkg.

Follow the build instructions until you reach the topic [building images](/docs/guide-developer/toolchain/use-buildsystem#building_images "docs:guide-developer:toolchain:use-buildsystem"). At that point you have to edit you kernel configuration:

```
make kernel_menuconfig
```

Make sure the following items are selected:

- Device Drivers &gt; I2C support &gt; I2C device interface &lt;\*&gt; (to get access through /dev/i2c-X)
- Device Drivers &gt; I2C support &gt; I2C Hardware Bus support &gt; Tiny-USB adapter &lt;\*&gt;

Continue with the build instructions.

## Using the I²C bus - kernel module

Since the module is compiled into the kernel, the I2C-Tiny-USB adapter can be plugged in. The successful registration can be tested:

```
dmesg | tail

usb 1-3.3: new low speed USB device using ehci_hcd and address 5
usb 1-3.3: New USB device found, idVendor=0403, idProduct=c631
usb 1-3.3: New USB device strings: Mfr=1, Product=2, SerialNumber=0
usb 1-3.3: Product: i2c-tiny-usb
usb 1-3.3: Manufacturer: Till Harbaum
usb 1-3.3: configuration #1 chosen from 1 choice
i2c-tiny-usb 1-3.3:1.0: version 1.05 found at bus 001 address 005
i2c-adapter i2c-0: connected i2c-tiny-usb device
usbcore: registered new interface driver i2c-tiny-usb
```

The same results are achieved by loading the kernel module by insmod. The current trunk module within kmod-i2c-tiny-usb package works just fine (requiring also kmod-i2c-core package).

## Using the I²C bus - using the bus

First install the i2c-tools package. This will provide all necessary tools for you to work with the bus.

### Searching for the bus

As you already can see in the dmesg listing, the i2c-0 device was created. The device node is visible under /dev/i2c-0. First of all, check the device is also visible for i2c tools. Running

`i2cdetect -l`

should print something like

`i2c-0 i2c i2c-tiny-usb at bus 001 device 004 I2C adapter`

This is a good sign. We can show the implemented functions by running

`i2cdetect -F 0`

and it will print something like

`Functionalities implemented by /dev/i2c-0: I2C yes SMBus Quick Command yes SMBus Send Byte yes SMBus Receive Byte yes SMBus Write Byte yes SMBus Read Byte yes SMBus Write Word yes SMBus Read Word yes SMBus Process Call yes SMBus Block Write yes SMBus Block Read no SMBus Block Process Call no SMBus PEC no I2C Block Write yes I2C Block Read yes`

### Searching for the devices

Now, we can search for devices, connected to the bus:

`i2cdetect 0`

will scan the bus and show available devices, similar to this:

`WARNING! This program can confuse your I2C bus, cause data loss and worse! I will probe file /dev/i2c-0. I will probe address range 0x03-0x77. Continue? [Y/n] 0 1 2 3 4 5 6 7 8 9 a b c d e f 00: -- -- -- -- -- -- -- -- -- -- -- -- -- 10: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 20: 20 -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 30: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 40: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 50: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 60: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 70: -- -- -- -- -- -- -- --`

Should you be anoyed by the Y/n question, you can use the -y switch to avoid it ;)

As you can see, I have an i2c device accessible on address 0x20 on the bus number 0.

## Accessing the example device

My device is actually a [MCP23017](http://www.adafruit.com/products/732 "http://www.adafruit.com/products/732") - 16 port GPIO expander. First I have to set the directions of the inputs and outputs - as this device possess 2 ports (A and B), I have to set the direction for both of them - setting a bit to 0 will cause it to switch to output, setting the bit to 1 will cause to switch to input. The address to set the direction for port A is 0x00, for port B it's 0x01. Therefore to set the first 8 channels (port A) to output, I'd run

`i2cset -y 0 0x20 0x00 0`

That means use the device at the address 0x20 on the bus /dev/i2c-0, set its address 0x00 to zero value. The `-y` switch is there just to avoid the Y/n question. Also, to set the port B to input, I'd issue following command:

`i2cset -y 0 0x20 0x01 0xff`

This will set all the pins for port B to input. To set the actual value for port A, the address 0x12 is utilized. Similar, for port B, the address is 0x13. Therefore to set first bit to logical 1, I'd issue (assuming I already set the port's bit for output):

`i2cset -y 0 0x20 0x12 1`

Should you have some LED connected to the port, it will shine bright now. To turn it off, simply issue the following:

`i2cset -y 0 0x20 0x12 0`

Should some input be set on the port B, one can read its value by using following command:

`i2cget -y 0 0x20 0x13`

The result will be something like `0x00` (corresponding to the logical values presented to the actual pins).

Using this approach, you can enrich the OpenWRT device with multiple I/O channels.

I've already tested MCP23017, MCP23008, some i2c temperature sensors and EEPROM - all working just fine.

## Precaution

**This I²C bus operates at 5V. Make sure not to connect I²C devices incompatible with this voltage level!**
