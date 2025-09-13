# I2C

This gives an overview for running [I²C](https://en.wikipedia.org/wiki/I%C2%B2C "https://en.wikipedia.org/wiki/I²C") on your router. There are a few other OpenWrt I2C projects out there and they really helped me getting this up and running. In contrast to the other projects this one

- uses 2 [GPIOs](/docs/techref/hardware/port.gpio "docs:techref:hardware:port.gpio") of the router
- does not need any external circuit

## Hardware

I2C is bi-directional and needs pull-up resistors on both lines (10k is recommended). Most devices operate at 3.3V but some need 5V.

### I2C over GPIO

![:!:](/lib/images/smileys/exclaim.svg) **This no longer works on current versions of OpenWRT (removed in 21.02) due to changes in the Linux kernel.** For more current methods, see [Linux kernel device tree bindings for i2c-gpio.](https://www.kernel.org/doc/Documentation/devicetree/bindings/i2c/i2c-gpio.txt "https://www.kernel.org/doc/Documentation/devicetree/bindings/i2c/i2c-gpio.txt") TODO: detailed tutorial.

You need 2 GPIO ports to add a 3.3V I2C interface to your router. Check if your router has some spare GPIOs available. The [TP-Link MR3020](/toh/tp-link/tl-mr3020 "toh:tp-link:tl-mr3020") has 2 unused GPIO ports at R15 and R17. Otherwise you can use GPIOs used for LEDs. To avoid any influence from the old components disconnect the LEDs from those GPIOs (by removing the resistors.

Add a 10k pull-up resistor between GPIO ports and 3.3V. On the MR3020 GPIO 7 would be SDA and the GPIO 29 would be SCL.

Install and load the kernel module:

```
# opkg update
# opkg install kmod-i2c-gpio-custom kmod-i2c-core
# insmod i2c-dev
# insmod i2c-gpio-custom bus0=0,7,29
# dmesg | grep gpio
Mar 23 09:01:23 openwrt kern.info kernel: [   52.910000] Custom GPIO-based I2C driver version 0.1.1
Mar 23 09:01:23 openwrt kern.info kernel: [   52.910000] i2c-gpio i2c-gpio.0: using pins 7 (SDA) and 29 (SCL)
```

When loading the kernel module replace the values 7 and 29 with the GPIO-Pins you have chosen. If the GPIO-Ports are used as LED you may have to unload the kernel module for the LEDs:

```
# rmmod leds-gpio
```

### I2C with 3.3V and 5V devices

If some of your devices need 5V I2C bus you can use a [simple level shifter](http://www.hobbytronics.co.uk/mosfet-voltage-level-converter "http://www.hobbytronics.co.uk/mosfet-voltage-level-converter") with 2 n-channel MOSFETs like the 2N7000. Connect the source-pins of the MOSFET to the 3.3V line, the gate pin to 3.3V and the drain pin to the 5V line. You also need the 10k-pull ups on the 5V-line.

## Old Wiki

In the oldwiki there are following contents, please [migrate](/docs/techref/hardware/meta/migrating "docs:techref:hardware:meta:migrating") them:

- [https://oldwiki.archive.openwrt.org/oldwiki/port.i2c](https://oldwiki.archive.openwrt.org/oldwiki/port.i2c "https://oldwiki.archive.openwrt.org/oldwiki/port.i2c")
- [https://oldwiki.archive.openwrt.org/oldwiki/port.i2c.rtc](https://oldwiki.archive.openwrt.org/oldwiki/port.i2c.rtc "https://oldwiki.archive.openwrt.org/oldwiki/port.i2c.rtc")
- [https://oldwiki.archive.openwrt.org/oldwiki/port.i2c.source\_code](https://oldwiki.archive.openwrt.org/oldwiki/port.i2c.source_code "https://oldwiki.archive.openwrt.org/oldwiki/port.i2c.source_code")

## Devices

The list of related devices: [i2c](/tag/i2c?do=showtag&tag=i2c "tag:i2c")
