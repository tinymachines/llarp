# LIRC GPIO receiver / blaster

[LIRC](http://www.lirc.org/ "http://www.lirc.org/") is a package that allows you to decode and send infra-red signals of many (but not all) commonly used remote controls.

The kernel module used in this howto needs **GPIO IRQs**, otherwise it won't work. Not all devices have IRQs implemented at the GPIO lines in the kernel.

You'll need at least 2 free GPIOs in your router. Also you need to locate VCC (3.3V) and GND, but this is a piece of cake. You can omit the blaster if only interested on receiving.

## Prepare your hardware

### Receiver

The receiver is quite simple, it's directly connected to the GPIO, Vcc and GND

[![](/_media/media/doc/howtos/lirc-gpio-generic.png?w=300&tok=31942c)](/_media/media/doc/howtos/lirc-gpio-generic.png "media:doc:howtos:lirc-gpio-generic.png")

The receiver used in the test was a TSOP4838. Any other should also work if can be fed with 3.3V.

[![](/_media/media/datasheets/tsop4838.jpg?w=200&tok=edfc70)](/_media/media/datasheets/tsop4838.jpg "media:datasheets:tsop4838.jpg")

### Blaster

For the IR emitter we need a few more components because a GPIO cannot supply more than 4mA.

![](/_media/media/doc/howtos/lirc-gpioblaster_reduced.png?w=300&tok=cd879d)

See [lirc-gpioblaster](/docs/guide-user/hardware/lirc-gpioblaster "docs:guide-user:hardware:lirc-gpioblaster") for more details. Although this circuit can be omited, if we are only interested on receiving. Later, we can configure the lirc-gpio-generic module with an unused dummy GPIO.

## Prepare your software

You will need to make a custom build. The module lirc-gpio-generic isn't available in the official repositories, and LIRC is not maintained an probably broken.

These are the kernel module lirc-gpio-generic, and LIRC package (Tested in Barrier Breaker):

- [https://github.com/danitool/openwrt-pkgs/tree/bb/lirc-gpio-generic](https://github.com/danitool/openwrt-pkgs/tree/bb/lirc-gpio-generic "https://github.com/danitool/openwrt-pkgs/tree/bb/lirc-gpio-generic")
- [https://github.com/danitool/openwrt-pkgs/tree/bb/lirc](https://github.com/danitool/openwrt-pkgs/tree/bb/lirc "https://github.com/danitool/openwrt-pkgs/tree/bb/lirc")

Put the directories under the ***package***/ subdirectory at the build root.

As usually build your custom firmware but select `lirc`

```
Location: 
    -> Utilities
```

```
┌─────────────────────────────────── Utilities ───────────────────────────────────┐
│ ┌─────────────────────────────────────────────────────────────────────────────┐ │  
│ │     Boot Loaders  --->                                                      │ │  
│ │     Editors  --->                                                           │ │  
│ │     Filesystem  --->                                                        │ │  
│ │     Terminal  --->                                                          │ │  
│ │     disc  --->                                                              │ │  
│ │ < > alsa-utils............ ALSA (Advanced Linux Sound Architecture) utilitie│ │  
│ │ < > alsa-utils-seq.................................. ALSA sequencer utilitie│ │  
│ │ < > alsa-utils-tests.......... ALSA utilities test data (adds ~1.3M to image│ │  
│ │ < > bzip2.................................... bzip2 is a compression utility│ │  
│ │ < > cal................................................... display a calenda│ │  
│ │ < > comgt............................... Option/Vodafone 3G/GPRS control too│ │  
│ │ < > dmesg............................ print or control the kernel ring buffe│ │  
│ │ < > dropbearconvert.......................... Utility for converting SSH key│ │  
│ │ < > fconfig..................................... RedBoot configuration edito│ │  
│ │ < > flock.................................... manage locks from shell script│ │  
│ │ < > gdb......................................................... GNU Debugge│ │  
│ │ < > gdbserver................................. Remote server for GNU Debugge│ │  
│ │ < > getopt.................................. parse command options (enhanced│ │  
│ │ < > gpioctl................................... Tool for controlling gpio pin│ │  
│ │ < > hwclock.................................. query or set the hardware cloc│ │  
│ │ < > iconv................................... Character set conversion utilit│ │  
│ │ < > iwcap.................................... Simple radiotap capture utilit│ │  
│ │ < > iwinfo.......................... Generalized Wireless Information utilit│ │  
│ │ --- jshn................................................. JSON SHell Notatio│ │  
│ │ < > kexec-tools.......................................... Kernel boots kerne│ │  
│ │ < > ldconfig............................... Shared library path configuratio│ │  
│ │ < > ldd.................................................... LDD trace utilit│ │  
│ │ <*> lirc................................ LIRC - Linux Infrared Remote Contro│ │  
│ │ < > logger......... a shell command interface to the syslog system log modul│ │  
│ │ < > look......................... display lines beginning with a given strin│ │  
│ └─v(+)────────────────────────────────────────────────────────────────────────┘ │  
├─────────────────────────────────────────────────────────────────────────────────┤  
│                        <Select>    < Exit >    < Help >                         │  
└─────────────────────────────────────────────────────────────────────────────────┘
```

Under `lirc` select `lirctools`

```
┌────────── lirc........................ LIRC - Linux Infrared Remote Control ──────────┐
│ ┌───────────────────────────────────────────────────────────────────────────────────┐ │  
│ │  --- lirc................................ LIRC - Linux Infrared Remote Control    │ │  
│ │  < >   lirc-audioalsa......................................... plugin audio_alsa  │ │  
│ │  < >   lirc-devinput............................................ plugin devinput  │ │  
│ │  < >   lirc-ftdi.................................................... plugin ftdi  │ │  
│ │  <*>   lirctools..................................................... LIRC tools  │ │  
│ └───────────────────────────────────────────────────────────────────────────────────┘ │  
├───────────────────────────────────────────────────────────────────────────────────────┤  
│            <Select>    < Exit >    < Help >    < Save >    < Load >                   │  
└───────────────────────────────────────────────────────────────────────────────────────┘  
```

Look for `kmod-lirc_gpio_generic` and select it:

```
Location: 
    -> Kernel modules
      -> Other modules
```

```
  ┌─────────────────────────────────── Other modules ───────────────────────────────────┐
  │ ┌─────────────────────────────────────────────────────────────────────────────────┐ │  
  │ │ < > kmod-bcma................................................... BCMA support   │ │  
  │ │ < > kmod-bluetooth......................................... Bluetooth support   │ │  
  │ │ <*> kmod-button-hotplug................................ Button Hotplug driver   │ │  
  │ │ < > kmod-eeprom-93cx6................................... EEPROM 93CX6 support   │ │  
  │ │ < > kmod-eeprom-at24..................................... EEPROM AT24 support   │ │  
  │ │ < > kmod-eeprom-at25..................................... EEPROM AT25 support   │ │  
  │ │ < > kmod-gpio-button-hotplug............... Simple GPIO Button Hotplug driver   │ │  
  │ │ < > kmod-gpio-dev........................... Generic GPIO char device support   │ │  
  │ │ < > kmod-gpio-nxp-74hc164.................. NXP 74HC164 GPIO expander support   │ │  
  │ │ < > kmod-hid..................................................... HID Devices   │ │  
  │ │ --- kmod-input-core........................................ Input device core   │ │  
  │ │ < > kmod-input-evdev...................................... Input event device   │ │  
  │ │ < > kmod-input-gpio-buttons................. Polled GPIO buttons input device   │ │  
  │ │ < > kmod-input-gpio-encoder............................... GPIO rotay encoder   │ │  
  │ │ < > kmod-input-gpio-keys.................................... GPIO key support   │ │  
  │ │ <*> kmod-input-gpio-keys-polled...................... Polled GPIO key support   │ │  
  │ │ < > kmod-input-joydev................................ Joystick device support   │ │  
  │ │ --- kmod-input-polldev........................... Polled Input device support   │ │  
  │ │ <*> kmod-lirc_gpio_generic.......... Driver for LIRC GPIO receiver/transmitter  │ │  
  │ │ < > kmod-mmc............................................. MMC/SD Card Support   │ │  
  │ │ < > kmod-mmc-over-gpio......................... MMC/SD card over GPIO support  -│ │  
  │ │ < > kmod-mtdtests........................................ MTD subsystem tests   │ │  
  │ │ < > kmod-nand............................................. NAND flash support   │ │  
  │ └─v(+)────────────────────────────────────────────────────────────────────────────┘ │  
  ├─────────────────────────────────────────────────────────────────────────────────────┤  
  │                          <Select>    < Exit >    < Help >                           │  
  └─────────────────────────────────────────────────────────────────────────────────────┘  
```

Build openwrt, and flash your custom firmware. Now you have LIRC prepared to work.

[![](/_media/meta/icons/tango/dialog-information.png)](/_detail/meta/icons/tango/dialog-information.png?id=docs%3Aguide-user%3Ahardware%3Alirc "meta:icons:tango:dialog-information.png") Note the file **/etc/lirc/lircd.conf** is specific for your remote. You might need to use [irrecord](http://www.lirc.org/html/irrecord.html "http://www.lirc.org/html/irrecord.html") in a machine with a LIRC receiver to get one for your own remote if you don't find any in the [lirc database](https://sourceforge.net/p/lirc-remotes/code/ci/master/tree/remotes/ "https://sourceforge.net/p/lirc-remotes/code/ci/master/tree/remotes/").

## Make it work

Flash your custom firmware with *lirc\_gpio\_generic* and the *LIRC* daemon included. If the module is loaded correctly when booting OpenWrt you should see this kernel message:  
`[ 36.240000] lirc_gpio_generic: auto-detected active low receiver on GPIO pin 10 [ 36.250000] lirc_gpio_generic lirc_gpio_generic.0: lirc_dev: driver lirc_gpio_generic registered at minor = 0 [ 36.260000] lirc_gpio_generic: driver registered!`

After loading lirc\_gpio\_generic, /dev/lirc0 is created. If the LIRC utility package is installed an init script should autostart the LIRC daemon conected to /dev/lirc0.

As default the GPIO 9 for the receiver and GPIO10 for the transmitter are used, to use another for example the GPIO 17 18 you need to parse the options  
`gpio_in_pin=17 gpio_out_pin=18`

You can put these options in the **/etc/modules.d/99-lirc\_gpio\_generic** file

```
lirc_gpio_generic gpio_in_pin=17 gpio_out_pin=18
```

Test the receiver, execute

`irw`

Press some buttons on your remote. If all is working OK, irw will return the commands pressed on the remote:  
`root@OpenWrt:/# irw 00000000000005e9 00 + rct3004 00000000000005ea 00 - rct3004 00000000000005ea 01 - rct3004 00000000000005dd 00 power rct3004 00000000000005d0 00 3 rct3004 00000000000005d0 01 3 rct3004 00000000000005c9 00 5 rct3004 00000000000005c9 01 5 rct3004 00000000000005c1 00 4 rct3004 00000000000005c1 01 4 rct3004`

Now we're ready to use irexec for executing custom scripts or commands every time a particular button is pressed on the remote.

### irexec

Configure [lircrc](http://www.lirc.org/html/configure.html#lircrc_format "http://www.lirc.org/html/configure.html#lircrc_format") as described in the LIRC website. Create the file `/etc/lirc/lircrc`. Run the [irexec](http://www.lirc.org/html/irexec.html "http://www.lirc.org/html/irexec.html") daemon with a command like this:

```
irexec --daemon /etc/lirc/lircrc
```

Now everytime you press a button in your remote, irexec will execute the associated commands in the lircrc file.

## Notes

Succesfully tested in Barrier Breaker

- **Platform AR7240**: GPIO9, GPIO10 are used for the serial port (multiplexed pins). For using these pins as regular GPIOs for our LIRC transceiver, execute the command  
  `devmem 0x18040028 32 0x48000`  
  The GPIO used for the receiver shouldn't have any pull down resistor, otherwise it won't work. The lirc-gpio-generic module package should copy a patch to the kernel patches directory for having GPIO IRQs available, check if the patch is applied.
- **brcm63xx**: only a few GPIOs have IRQs, check [external\_irqs](/docs/techref/hardware/soc/soc.broadcom.bcm63xx#external_irqs "docs:techref:hardware:soc:soc.broadcom.bcm63xx"). Only those GPIOs can be used for the receiver. A patch is copied into the kernel patches directory for having gpio\_to\_irq function available in the lirc\_gpio\_generic module, check if the patch is applied when compiling the firmware.

## Tested routers

Target Platform Router Tested brcm63xx BCM6348 Livebox 1 OK BCM6358 HG556a ar71xx AR7240 TL-WR741ND OK lantiq Danube ARV7518PW KO ramips ? KO?
