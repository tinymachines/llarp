# 1-wire Bus

To provide [1-Wire Bus Connections](https://en.wikipedia.org/wiki/1-Wire "https://en.wikipedia.org/wiki/1-Wire") between various 1-Wire- and Hostdevices different connection methods can be used. They can be connected to a Host using a bus converter. USB, RS-232 serial port interfaces are popular solutions for connecting 1-Wire Devices to the Hostdevice. But 1-Wire devices can also be interfaced directly to Controllers from various vendors using a GPIO Pin.

This guide will only cover 1-Wire Bus Connections (as of Sep 13, 2019) up to the stable release v19.07.8. For newer Kernels (since v21.02.0) the Package “kmod-w1-gpio-custom” is no longer available. Therefore the Installation is a bit more extensive. The Device which got tested was a **OrangePI PC+** (a different method is recommended for the Raspberry Pi!).

## Installation up to v19.07.8

In order to use a GPIO for the 1-Wire bus, i.e. for using [DS18B20 Sensors](https://datasheets.maximintegrated.com/en/ds/DS18B20.pdf "https://datasheets.maximintegrated.com/en/ds/DS18B20.pdf") it is necessary to install several additional packages:

```
opkg update
opkg install kmod-w1 kmod-w1-master-gpio kmod-w1-gpio-custom kmod-w1-slave-therm
```

## Configuration up to v19.07.8

Configure the GPIO pin connected to the data line of the sensor. The Section “Software” in [this howto](/docs/techref/hardware/port.gpio "docs:techref:hardware:port.gpio") describes how to determine the GPIO.

Create/Edit /etc/modules.d/55-w1-gpio-custom, replace 19 with the GPIO which you determined in the last step. You can include several bus definitions up to a maximum of four, i.e.:

```
echo "w1-gpio-custom bus0=0,19,0 bus1=1,20,0" > /etc/modules.d/55-w1-gpio-custom
```

The last Zero of the sequence means “not open-drain” and should be set to “0”.

After modifying the file /etc/modules.d restart, so that the kernel can load the modules.

When the 1-Wire bus is successfully set up, you should see in /sys/devices a directory called “w1\_bus\_master1”. A second bus will appear as “w1\_bus\_master2” and so on. Within this directory you will find a number of files including “w1\_master\_slaves\_count” which shows the number of detected devices connected to the 1-Wire bus, and “w1\_master\_slaves” which contains a list of the device identifiers.

In case, it is a Sunxi Device and you like to connect e.g. Pin 29 (=PA7) [Sunxi](https://linux-sunxi.org/GPIO "https://linux-sunxi.org/GPIO") says:

```
(position of letter in alphabet - 1) * 32 + pin number
```

so the GPIO for PA7 would be ( 1 - 1) * 32 + 7 = 0 + 7 = 7 (since 'a' is the first letter).

(Or you take a look with

```
cat /sys/kernel/debug/pinctrl/1c20800.pinctrl/pins
```

for the mappings...)

This results in the following configuration

```
echo "w1-gpio-custom bus0=0,7,0" > /etc/modules.d/55-w1-gpio-custom
```

## Installation as of v21.02.0

There are several possible Ways to install. The Way described here assumes, that an Image has been installed on a [SD card](/docs/guide-user/installation/installation_methods/sd_card "docs:guide-user:installation:installation_methods:sd_card").

**This Description again refers to an Orange Pi PC+, Pin “PA3” is to be used as W1 port conected with DS18B20 Sensors.**

First install the necessary several additional packages:

```
opkg update
opkg install kmod-w1 kmod-w1-master-gpio kmod-w1-slave-therm
```

As of v21.02.0 the Configuration of the Driver is done via the [Device Tree](/docs/guide-developer/defining-firmware-partitions "docs:guide-developer:defining-firmware-partitions"). On your Computer you need a Device-Tree-Compiler installed. Several Linux Distributions have it available in the Repositys.

The Device Tree can be changed as follows:

- Connect the SD Card to your Computer and look at lsblk or dmesg to identify it. In most Cases, it would be something like /dev/sdX.
- Mount and open the “20M” Boot Partition.
- there are 3 Files in the Partition: boot.scr, dtb, uImage
- Copy the File “dtb” to your Computer
- decompile

```
dtc dtb  -O dts -I dtb -o OPi.dts
```

- You get a File named “OPi.dts”. Edit the File.
- Inside the Section “pinctrl@1c20800” (the selected Pin “PA3” is within this range) you have to insert

```
  w1-pins {
        pins = "PA3";
        function = "gpio_out";
        phandle = <0x2f>;
    	};
```

and at the end of the file (**but before the last bracket!**) add:

```
w1-gpio {
	compatible = "w1-gpio";
	label = "w1-gpio";
	pinctrl-names = "default";
	pinctrl-0 = <0x2f>;
	gpios = <0xa 0x0 0x3 0x6>;
	status = "okay";
	};  
```

Notice:

1. phandle: you have to use a hex number following the highest number of phandle used in the file.
2. gpios: the “0xa” ist the phandle of the used pinctrl, the “0x0” is the used Bank (0 = A...), the “0x3” is the hex number of the used Pin inside the bank, the “0x6” ist the Configuration of the Pin.

<!--THE END-->

- compile

```
dtc OPi.dts  -O dtb -I dts -o dtb
```

- copy the new “dtb” to the SD Card (overwrite the old “dtb”)
- Check the output of “dmesg” for (error) messages

```
...
kern.info kernel: [    7.610839] Driver for 1-wire Dallas network protocol.
...
kern.info kernel: [    7.688174] w1_master_driver w1_bus_master1: Attaching one wire slave 28.0416a43244ff crc be
...
```

## electrical Configuration

To connect 1Wire Devices to a Host it is necessary to connect a Pullup Resistor of 4.7 kOhm between the Bus Line and the 3.3V VCC Line. On the Internet, other values ​​are given also, here it works well with 4.7kOhm and six DS18B20 Sensors.

[![](/_media/media/doc/howtos/w1-ds18b20.png)](/_media/media/doc/howtos/w1-ds18b20.png "media:doc:howtos:w1-ds18b20.png")

It is also possible to operate the 1-Wire Bus with just the Gnd and Bus Lines, with the Sensors deriving power “parasitically” from the Bus Line. For further information, read the datasheet of the device. For longer cables, the use of an insulator such as ADUM1201 is recommended.
