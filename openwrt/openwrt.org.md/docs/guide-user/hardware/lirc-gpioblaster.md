# LIRC GPIO blaster

[LIRC](http://www.lirc.org/ "http://www.lirc.org/") is a package that allows you to decode and send infra-red signals of many (but not all) commonly used remote controls.

An infrared blaster is a device that emulates an infrared remote control. In this case the task is made using LIRC which will control a GPIO. The output of this GPIO is connected to a circuit with an IR diode. This is only for the transmitter, nothing about receiving IR signals is covered in this page.

![](/lib/exe/fetch.php?tok=d9be56&media=http%3A%2F%2Fupload.wikimedia.org%2Fwikipedia%2Fcommons%2Fb%2Fb6%2FWireless-Router.png) **=** ![](/lib/exe/fetch.php?w=150&tok=7c25d4&media=http%3A%2F%2Fupload.wikimedia.org%2Fwikipedia%2Fcommons%2Fthumb%2Fd%2Fd0%2FXbox_360_remote.png%2F271px-Xbox_360_remote.png)

You'll need at least 1 free GPIO in your router. Also you need to locate VCC (3.3V) and GND, but this is a piece of cake.

## Prepare your hardware

These are two schematics for connecting the IR LED to our GPIO output. Both should work fine.

1. Simple circuit. It should work on any device  
   ![](/_media/media/doc/howtos/lirc-gpioblaster_reduced.png?w=400&tok=ee4232)  
   With this schematic we must ensure the GPIO is **never on continously**, and VCC is powerful enough to feed the IR LED. The IR LED can forward high current but only with short pulses, otherwise if forced to forward high current continuously (100mA or more), it may burn out itself. Of course we can increment the value of R2 to a higher value but then the range of the IR LED will be very limited.  
   `   ` We can also add a pulldown resitor (≥10 kohm) at the GPIO line to avoid “floating current” until the LIRC GPIO blaster module is loaded (and configured as output). This will avoid to turn on accidentally the IR LED.
2. Safe circuit. R3 and C1 added. Recommended for devices with power supply weakness:  
   ![](/_media/media/doc/howtos/lirc-gpioblaster.png?w=500&tok=2751bb)  
   The components are not restricted to the values shown in the schematic, they can be different but the choice of values for C1, R2 and R3 is very important. **R2** determines how much current will be drawn through the IR LED, which determines the range of the remote control. **R3** determines how fast capacitor C1 is charged. The value must be small enough to charge capacitor C1 in a reasonable amount of time, but large enough to not overstress VCC. Depending on the values of R2 and R3, the capacitor must be large enough to retain most of its charge through a complete data packet. **R4** determines how much current is drawn from the GPIO, a value of 750 or higher is considered safe. Power supply VCC can be a higher voltage.

You can substitute the NPN S9013 (500mA) by a:

- 2N3904 : 200mA, less range
- 2N2222 : 800mA, more range

### Casing

As an example here you can see how a pendrive casing is used to store the simple circuit.

[![](/_media/media/doc/howtos/lirc-gpioblaster-case.jpg?h=200&tok=28bd04)](/_media/media/doc/howtos/lirc-gpioblaster-case.jpg "media:doc:howtos:lirc-gpioblaster-case.jpg") [![](/_media/media/doc/howtos/lirc-gpioblaster-plugged.jpg?h=200&tok=898af8)](/_media/media/doc/howtos/lirc-gpioblaster-plugged.jpg "media:doc:howtos:lirc-gpioblaster-plugged.jpg")

## Prepare your software

You will need to make a custom build. The module lirc\_gpioblaster isn't available in the official repositories, and LIRC is not maintained an probably broken. The lirc\_gpioblaster module is based on the one avaliable for the raspberry pi, without the receiver part, and properly packaged to build an external independent module for OpenWrt.

This is the kernel module lirc\_gpioblaster, and LIRC package only with the transmitter:

- [lirc-gpioblaster.zip](https://drive.google.com/uc?export=download&id=0B-EMoBe-_OdBcnhJaXBHY1FZS3c "https://drive.google.com/uc?export=download&id=0B-EMoBe-_OdBcnhJaXBHY1FZS3c") (Tested in Attitude Adjustment 12.07)
- [lirc-gpioblaster-CC.zip](https://drive.google.com/uc?export=download&id=0B-EMoBe-_OdBdF8xT0lBZUxvWVk "https://drive.google.com/uc?export=download&id=0B-EMoBe-_OdBdF8xT0lBZUxvWVk") (Tested in Chaos Calmer)

Extract lirc-gpioblaster.zip, and move the directories under the ***package***/ subdirectory at the build root.

As usually build your custom firmware but select lirc with the transmitter enabled

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

and kmod-lirc\_gpioblaster

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
  │ │ <*> kmod-lirc_gpioblaster................... Driver for LIRC GPIO transmitter   │ │  
  │ │ < > kmod-mmc............................................. MMC/SD Card Support   │ │  
  │ │ < > kmod-mmc-over-gpio......................... MMC/SD card over GPIO support  -│ │  
  │ │ < > kmod-mtdtests........................................ MTD subsystem tests   │ │  
  │ │ < > kmod-nand............................................. NAND flash support   │ │  
  │ └─v(+)────────────────────────────────────────────────────────────────────────────┘ │  
  ├─────────────────────────────────────────────────────────────────────────────────────┤  
  │                          <Select>    < Exit >    < Help >                           │  
  └─────────────────────────────────────────────────────────────────────────────────────┘  
```

Build openwrt, and flash your custom firmware. Now you have lirc prepared to work.

[![](/_media/meta/icons/tango/dialog-information.png)](/_detail/meta/icons/tango/dialog-information.png?id=docs%3Aguide-user%3Ahardware%3Alirc-gpioblaster "meta:icons:tango:dialog-information.png") Note the file **/etc/lirc/lircd.conf** is specific for your remote. You might need to use [irrecord](http://www.lirc.org/html/irrecord.html "http://www.lirc.org/html/irrecord.html") in a machine with a lirc receiver to get one for your own remote if you don't find any in the [lirc database](https://sourceforge.net/p/lirc-remotes/code/ci/master/tree/remotes/ "https://sourceforge.net/p/lirc-remotes/code/ci/master/tree/remotes/").

## Make it work

As default there is an init script which autostarts lircd conected to /dev/lirc0

/dev/lirc0 is created when the module lirc\_gpioblaster is loaded. As default the GPIO 0 is used, to use another for example the GPIO 17 you need to parse the option  
`gpio_out_pin=17`

Also you may need to invert the signal depending if the GPIO is active low or high:  
`invert=1`

**Warning**: if you use incorrectly the invert option, you can fry the IR led (depending on the schematic you use). Most GPIO outputs are active high, invert shouldn't be used unless some components were inverting the signal.

Example, insert the module with the above options:  
`insmod lirc_gpioblaster gpio_out_pin=17 invert=1`

You don't need to use this command every time you want to load the module. The module is autoloaded when the system boots up, just add the options to **/etc/modules.d/99-lirc\_gpioblaster** file

```
lirc_gpioblaster gpio_out_pin=17 invert=0
```

And restart OpenWrt.

Now is time to probe you IR transmitter: execute this command:

```
irsend SEND_ONCE rct3004 KEY_POWER
```

And if all is working OK, then IR signals are sent. Check it with your mobile phone camera, since these cameras usually are able to detect the IR light.

## Notes

Successfully tested in AA, platform bcm63xx.
