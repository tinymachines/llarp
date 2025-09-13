# OpenWrt Debricking Guide

When people say a router is *bricked*, this very generally means, that it does not function properly any longer and the reasons can be various. First of all, you should calm down, relax and read [flash.layout](/docs/techref/flash.layout "docs:techref:flash.layout"), [file systems in OpenWrt](/docs/techref/filesystems#implementation_in_openwrt "docs:techref:filesystems") and [bootloader CLI](/docs/techref/bootloader#additional_functions "docs:techref:bootloader"). Now depending on what exactly is broken, you have several possibilities:

1. if only something on the [**JFFS2**](/docs/techref/filesystems#jffs2 "docs:techref:filesystems") partition is broken, you are still able to → [**boot into OpenWrt failsafe mode**](/docs/guide-user/troubleshooting/failsafe_and_factory_reset "docs:guide-user:troubleshooting:failsafe_and_factory_reset")
2. if the [**SquashFS**](/docs/techref/filesystems#squashfs "docs:techref:filesystems") partition or the **Kernel** is broken, you cannot boot into failsafe mode any longer. But you still have a functioning bootloader and so you should follow the same procedures as when you first → [**installed OpenWrt via bootloader**](/docs/guide-user/installation/generic.flashing#method_2via_bootloader_and_an_ethernet_port "docs:guide-user:installation:generic.flashing").
3. if the **[bootloader](/docs/techref/bootloader "docs:techref:bootloader") is broken**, there are some options left:
   
   1. access your hardware through the → [**JTAG Port**](/docs/techref/hardware/port.jtag "docs:techref:hardware:port.jtag"), this *should* allow you to write to the flash. Restore the bootloader.
   2. desolder the flash chip, connect it to some device, that does give you write access to it and restore the bootloader. You did perform a [generic.backup](/docs/guide-user/installation/generic.backup "docs:guide-user:installation:generic.backup"), right?
   3. look if device supports [UART](/toh/astoria/arv752dpw22#uart_mode_unbrick "toh:astoria:arv752dpw22") serial boot.

If you need to solder, you can find some help here:

- → [**soldering**](/docs/techref/hardware/soldering "docs:techref:hardware:soldering"), [Serial Port](/docs/techref/hardware/port.serial "docs:techref:hardware:port.serial"), [JTAG Port](/docs/techref/hardware/port.jtag "docs:techref:hardware:port.jtag")

* * *

- [https://forum.openwrt.org/viewtopic.php?id=35462](https://forum.openwrt.org/viewtopic.php?id=35462 "https://forum.openwrt.org/viewtopic.php?id=35462")

![FIXME](/lib/images/smileys/fixme.svg) This page needs major cleanup. Use caution regarding this advice.

### As for the proper ways to recover a "bricked" router

#### boot\_wait

The single best thing you can do is have boot\_wait set, meaning that all you have to do is TFTP a new firmware. At one time the reflashing instructions included a an exploit for the Linksys firmware that set the boot\_wait variable; as time progressed and Linksys eventually fixed the bug (after several failed attempts) we found that people were flashing to other firmwares for the sole purpose of setting boot\_wait so they could reflash to OpenWrt. We figured this was somewhat pointless and altered the instructions to indicate that you could safely reflash to OpenWrt without setting boot\_wait.

#### JTAG

It's one of those amazingly useful things that allows you to recover from pretty much anything that doesn't involve a hardware failure. While the JTAG can technically be used to watch every instruction and register as the system boots, the recovery software only uses it for DMA access to the flash chip, making it somewhat a blind recovery mechanism.

The biggest mistake people seem to make with JTAG is the “wipe everything and reflash [bootloader](/docs/techref/bootloader "docs:techref:bootloader")” ([CFE](/docs/techref/bootloader/cfe "docs:techref:bootloader:cfe") for broadcom devices) approach; they either can't find the correct CFE version after wiping the device, or they reflash with a CFE which is incompatible with their device. You should always try to use the CFE version that came with the device rather than attempting to replace it with some random CFE you found on the internet.

Second mistake - embedded within CFE is a set of NVRAM defaults to be used if the NVRAM partition is missing. This means that in most cases you can just wipe everything but CFE and it'll happily boot, recreate NVRAM and start waiting for a firmware via TFTP. In some cases however, the defaults embedded defaults (in the CFE shipped with the device) don't match the actual hardware and CFE will fail to boot. This is why we have the warnings not to wipe NVRAM. To recover from this situation you need either the original NVRAM contents, or a version of CFE with the correct defaults.

![FIXME](/lib/images/smileys/fixme.svg): OK, you have told us what NOT TO DO, now please tell us what TO DO! Let us take the most usual case where someone has installed a bad image on their router. The usual recovery methods have failed, forceing the user to to go to JTAG. The user has used to good OpenWrt Documentation to set up the cables and hardware and software. The user is now sitting at an OPENOCD, URJTAG, or Hairydairymaid prompt. The user has never used a JTAG tool before. What should they do now? What backup commands should they issue, before trying their fix? Some say that by erasing some partitions it will cause the system to start working, well enough to use the other recovery methods. OK, but what exactly is the correct procedure? If this does not work, is there a way to install a good openwrt image directly using JTAG?

#### Serial

Serial consoles are great, there's just one problem - the routers run on 3.3v and a normal PC serial port puts out +/-12v, easily frying a router. This means that a level shifter such as a max233 is required (free samples can be obtained from Texas Instruments or Maxim), and adding the ICs and caps required is beyond the ability of most users -- luckily there's a shortcut. Most cellphones are either USB or 3.3v serial, so the data cable for a 3.3v cellphone can be used to make an easy and professional looking serial console connection (e.g the DKU-5 Cable for Nokia handsets). You only need to identify and connect 4 wires (vcc, rx, tx, gnd) -- and if your cable uses a pl2303 you can skip the vcc connection.

Serial console allows you to interact with the CFE command line, watch the kernel boot and console access to linux. This is probably the only way you'll every get any meaningful feedback about the device boot up.

##### Serial modes

Some [serial modes](/docs/techref/hardware/port.serial#serial_modes "docs:techref:hardware:port.serial") allow you to upload a binary directly to ram or to the flash memory from the serial connection, allowing you to repair a broken bootloader

#### Arduino

If you have an Arduino board you can upload a sketch that will send the debrick commands via serial. An example that works for the TP-WR703N is available here: [https://forum.openwrt.org/viewtopic.php?pid=191463](https://forum.openwrt.org/viewtopic.php?pid=191463 "https://forum.openwrt.org/viewtopic.php?pid=191463"). Note that the commands for your router could be different!

#### Raspberry Pi

If you don't have a USB serial ttl but have a Raspberry Pi, you can use it to connect to the router's serial pins. The Raspberry Pi's uart works at 3.3V which is the correct voltage for most routers. Connect the GND to GND, the RX to TX, and the TX to RX. Leave VCC (or 3.3V) unconnected (that is, in the end you will only be connecting 3 pins out of 4).

#### WIFI

If by chance the lan bridge is not working after flashing and the router is inaccessible, it might be worth a shot to use the serial instructions to add a serial port and configure Wifi. If ssh connection via Wifi is working a newer/bugfixed/stable image can be copied via scp and then installed via sysupgrade command.

## LEDs

Most people assume the LEDs on the front are deterministic, and that by telling you which LEDs are lit you can instantly tell if the hardware is working or where it crashed in bootup. This unfortunately isn't the slightest bit true.

1. Power LED. The biggest mistake people make here is “my power led is blinking, what does that mean?”. There's an assumption that if the LED is blinking there must be software turning the LED on and off, and that it must mean something. The blinking is actually done in hardware; software only as the ability to set the LED “on” or “blink” -- it defaults to blink on power up and isn't set to on until after the firmware boots. If the led is on then you know the firmware booted; blinking really doesn't tell you much.
2. Switch LEDs. The second common mistake is “the switch still works”. Of course the switch still works, it's a separate piece of hardware and the LEDs are wired directly to it. The only useful bit of information you can get is “all the switch LEDs are lit”. When the switch chip is reset, all of the ports will light up (even if no devices are connected) for about a second; this happens at power up and again as the firmware boots and reprograms the switch. If they stay lit, you're either a moron for not noticing the ports are actually in use, or someone has broken/shorted the switch chip. You can also notice reboot loops by watching for the switch reset.
3. Diag/DMZ LED. Controlled by OpenWrt (diag module) to indicate bootup.
4. Wifi. Controlled by the wifi driver; trivia - the wifi driver can also reset the power led in certain situations.

## Stupid things people do

Pin shorting

In the past we used to suggest that people shorted a few pins of the flash; when CFE booted and attempted to perform the CRC32 there would be a flash read error which would change the outcome of the CRC and the resulting failure would force CFE into recovery mode. It's a great trick, but over the years we've learned that people are idiots and will take that as an invitation to poke mangle and short just about every pin on the device based on some irrational belief that if they find the right pin everything will magically work again. You do not want someone paranoid at the thought of breaking the device scraping up every single electrical connection on the device -- it never ends well, and generally results in the flash chip or the router being damaged in the process.

\- frying a chip (worst case) - lifting/breaking electrical connections - permanently shorting (best case)

The best case is that they simply bent a pin and you can easily bend it back - providing you can find it.

Depending on which pins are shorted/broken, it may be possible to access CFE but not to access the rest of the flash. Meaning CFE boots fine but can't read or write the firmware. This can be confirmed by JTAG.

Wrong CFE version - Loading the wrong CFE version can also lead to devices which boot into CFE but are unable to write to the flash, or are unable to initialize the networking.

And yes, there are actually a few obscure versions that require the firmware to be named “code.bin” or a specific port to be used. Unfortunately nobody can remember exactly which devices, leading to all sorts of superstition.

This article is based on: [https://forum.openwrt.org/viewtopic.php?id=11304](https://forum.openwrt.org/viewtopic.php?id=11304 "https://forum.openwrt.org/viewtopic.php?id=11304")

* * *

- [https://forum.openwrt.org/viewtopic.php?pid=128790#p128790](https://forum.openwrt.org/viewtopic.php?pid=128790#p128790 "https://forum.openwrt.org/viewtopic.php?pid=128790#p128790")

## by Vavasik

In this case, someone manage to wipe out the [bootloader](/docs/techref/bootloader "docs:techref:bootloader") of his [D-Link DIR-825](/toh/d-link/dir-825 "toh:d-link:dir-825").

The full originals by vavasik can be found at:

- [http://translate.google.de/translate?hl=de&amp;ie=UTF-8&amp;sl=auto&amp;tl=en&amp;u=http://webcache.googleusercontent.com/search%3Fq%3Dcache:wZfxY3lVVfQJ:forum.ixbt.com/topic.cgi%253Fid%253D14:49819%2Bhttp://forum.ixbt.com/topic.cgi%253Fid%253D14:49819%26cd%3D1%26hl%3Den%26ct%3Dclnk%26source%3Dwww.google.com&amp;prev=\_t](http://translate.google.de/translate?hl=de&ie=UTF-8&sl=auto&tl=en&u=http%3A%2F%2Fwebcache.googleusercontent.com%2Fsearch%3Fq%3Dcache%3AwZfxY3lVVfQJ%3Aforum.ixbt.com%2Ftopic.cgi%253Fid%253D14%3A49819%2Bhttp%3A%2F%2Fforum.ixbt.com%2Ftopic.cgi%253Fid%253D14%3A49819%26cd%3D1%26hl%3Den%26ct%3Dclnk%26source%3Dwww.google.com&prev=_t "http://translate.google.de/translate?hl=de&ie=UTF-8&sl=auto&tl=en&u=http://webcache.googleusercontent.com/search%3Fq%3Dcache:wZfxY3lVVfQJ:forum.ixbt.com/topic.cgi%253Fid%253D14:49819%2Bhttp://forum.ixbt.com/topic.cgi%253Fid%253D14:49819%26cd%3D1%26hl%3Den%26ct%3Dclnk%26source%3Dwww.google.com&prev=_t")

<!--THE END-->

1. Open the Router’s case
2. Find an IC SPI Flash SPANSION S25FL064A (Package SO3 016 wide), it is located on the backside of the router PCB.
   
   1. There are some variations regarding the IC used by D-LINK. In my particular case, the IC is from a different player. It is a ST Microelectronics chip labeled 5P64V6P 7B469 VS, but the pin outs are exactly the same.
3. To record to flash chip it is necessary to build a simple cable that is connected in one side, to PARALEL PORT of your computer, and on other side you have to SOLDERING THE WIRES DIRECTLY INTO IC PINS.

```
DB25 # PIN---------------RESISTOR---------------FLASH IC # PIN

7 ----------------------------[150Ω] ----------------------------- 7
10 ---------------------------[150Ω]------------------------------ 8
8 ----------------------------[150Ω]----------------------------- 16
9 ----------------------------[150Ω]----------------------------- 15
18 ---------------------------------------------------------------- 10 GND (or "GND" on JTAG pads)

|----------- {recommended cable length = 120 mm} ------------|
```

It is also necessary to provide some external power supply (during the flashing process the router’s power adapter connector should be NOT INSERTED). So, in my case I decided to use a simple 3 x AAA 1.2 Volt NiMH battery holder that I assembled together with the cable itself.

Since the batteries are placed in a serial arrange, the final voltage of the set is 3.6 Volt.

```
FLASH IC # PIN--------------------BATTERY ARRAY--------------------FLASH IC # PIN

10 ----------------[ - 1.2 Volt +]----[ - 1.2 Volt +]----[ - 1.2 Volt +]--------------- 2
```

1. 4 It is not necessary but it could prove useful, to be capable to follow the boot process through serial console. In order to achieve that it is recommended to install some connections pins into the empty board holes related to JP1 connector. You can use the pins from old computer parts.

```
DIR 825 SERIAL PINOUTS (connector JP1) is:

PIN 1 -> 3.3V (Pin 1 is the one close to a small switch and a LED indicator)
PIN 2 -> RX
PIN 3 -> TX
PIN 4 -> GND
```

1. &lt;5&gt; Use a TTL to RS-232 cable to connect to serial console. A good, easy and cheap option is to buy a USB to Phone cable like the model CA-42. Here in Brazil this cable can be found for about US$ 3.00.

Since you have the cable all you have to do is to cut off the Phone connector side and to identify the GROUND; TX and RX wires. It is quite easy and the web is plenty of guides that teach how to do that.

Use a terminal emulator software (I like PuTTY) configured as follow:

Speed (baud) 115200 Data Bits 8 Stop Bits 1 Parity None Flow Control XON / XOFF

- 6 Now that the LPT ADAPTER is done and its wires are soldering to the chip, you have to connect the other side to LPT interface of your computer and also to connect the 3,6V external battery array. You must see the light of some LEDs on board.
- 7 So, if everything is done properly, download the software SPIPGMW at the following address: [http://rayer.ic.cz/programm/programm.htm#SPIPGM](http://rayer.ic.cz/programm/programm.htm#SPIPGM "http://rayer.ic.cz/programm/programm.htm#SPIPGM") Run it in a DOS session. It is good use the key “i” in order to check if the chip is correctly identified.

SPIPGMW.EXE /i

Program should show:

```
SPI connected to LPT port at I / O base address: 378h, SCK pulse width: t 0us FlashROM JEDEC ID, type: 010216h Spansion S25FL064A (8MB)
```

In my particular case, the software shows the ST Microelectronics chip id. If you see “unknown chip” there is a problem with LPT cable connection, check connections and try again!

- 8 - Download and save the appropriated image toDIR-825.
- 9 - Before flashing the image it is necessary to allow recording in chip with the key “u” SPIPGMW.EXE /u
- 10 – Prior to recording it is good to make a cleanup. Erase chip with the key “e” SPIPGMW.EXE /e
- 11 – Now it is time to program chip with key “p” SPIPGMW.EXE /p file\_name
- 12 - Dump chip content to a file with key file “d” SPIPGMW.EXE /d filename\_1
- 13 - Check the success of recording operation by comparing recorded file and recently dumped file fc / b filename\_1 filename\_2. Files must have exactly the same content.
- 14 - Disconnect LPT cable and external power supply, try to boot. Look at the serial console terminal program and follow the boot process. Luckily everything will work fine.

<!--THE END-->

- [http://img189.imageshack.us/img189/134/recoveringadir825flashc.jpg](http://img189.imageshack.us/img189/134/recoveringadir825flashc.jpg "http://img189.imageshack.us/img189/134/recoveringadir825flashc.jpg")
- [http://img251.imageshack.us/img251/134/recoveringadir825flashc.jpg](http://img251.imageshack.us/img251/134/recoveringadir825flashc.jpg "http://img251.imageshack.us/img251/134/recoveringadir825flashc.jpg")
- [http://img833.imageshack.us/img833/134/recoveringadir825flashc.jpg](http://img833.imageshack.us/img833/134/recoveringadir825flashc.jpg "http://img833.imageshack.us/img833/134/recoveringadir825flashc.jpg")
- [http://img708.imageshack.us/img708/134/recoveringadir825flashc.jpg](http://img708.imageshack.us/img708/134/recoveringadir825flashc.jpg "http://img708.imageshack.us/img708/134/recoveringadir825flashc.jpg")
- [http://img267.imageshack.us/img267/134/recoveringadir825flashc.jpg](http://img267.imageshack.us/img267/134/recoveringadir825flashc.jpg "http://img267.imageshack.us/img267/134/recoveringadir825flashc.jpg")
- [http://img267.imageshack.us/img267/8935/recoveringadir825flashco.jpg](http://img267.imageshack.us/img267/8935/recoveringadir825flashco.jpg "http://img267.imageshack.us/img267/8935/recoveringadir825flashco.jpg")
- [http://img209.imageshack.us/img209/134/recoveringadir825flashc.jpg](http://img209.imageshack.us/img209/134/recoveringadir825flashc.jpg "http://img209.imageshack.us/img209/134/recoveringadir825flashc.jpg")
- [http://img513.imageshack.us/img513/134/recoveringadir825flashc.jpg](http://img513.imageshack.us/img513/134/recoveringadir825flashc.jpg "http://img513.imageshack.us/img513/134/recoveringadir825flashc.jpg")
- [http://img171.imageshack.us/img171/134/recoveringadir825flashc.jpg](http://img171.imageshack.us/img171/134/recoveringadir825flashc.jpg "http://img171.imageshack.us/img171/134/recoveringadir825flashc.jpg")
- [http://img403.imageshack.us/img403/134/recoveringadir825flashc.jpg](http://img403.imageshack.us/img403/134/recoveringadir825flashc.jpg "http://img403.imageshack.us/img403/134/recoveringadir825flashc.jpg")
- [http://img593.imageshack.us/img593/134/recoveringadir825flashc.jpg](http://img593.imageshack.us/img593/134/recoveringadir825flashc.jpg "http://img593.imageshack.us/img593/134/recoveringadir825flashc.jpg")
- [http://img522.imageshack.us/img522/134/recoveringadir825flashc.jpg](http://img522.imageshack.us/img522/134/recoveringadir825flashc.jpg "http://img522.imageshack.us/img522/134/recoveringadir825flashc.jpg")

<!--THE END-->

- [http://rayer.ic.cz/elektro/spipgm.htm](http://rayer.ic.cz/elektro/spipgm.htm "http://rayer.ic.cz/elektro/spipgm.htm") RayeR's homepage/Programmer SPI FlashROM for parallel port
- [http://rayer.ic.cz/programm/programe.htm#SPIPGM](http://rayer.ic.cz/programm/programe.htm#SPIPGM "http://rayer.ic.cz/programm/programe.htm#SPIPGM") RayeR's homepage/Programming - SPIPGM.ZIP ver. 1.8 \[79 kB] :

SPI FlashROM supported ST Microelectronic: M25P10 (128kB) M25P20 (256kB) M25P40 (512kB) M25P80 (1MB) M25P16 (2MB) M25P32 (4MB) M25P64 (8MB) M25P128 (16MB)

- [Programming an ASUS P5B BIOS | Adventures in Home Computing](http://richard-burke.dyndns.org/wordpress/2009/02/programming-an-asus-p5b-bios "http://richard-burke.dyndns.org/wordpress/2009/02/programming-an-asus-p5b-bios")

## Write flash chip by USB

This is the probably easiest way to “burn” a flash chip: It is a cheap (cable ~20 EUR), universal (USB) and multiplatform (many OS) solution. Buy a FTDI cable C232HM-DDHSL-0 (in case of 3.3 Volts), connect the wires to the flash chip as shown below and write the data with [flashrom](http://flashrom.org/ "http://flashrom.org/").

```
C232HM-DDHSL-0       SPI-Flash SOP8
     1 red    ------ 8 Vcc
     2 orange ------ 6 SCLK
     3 yellow ------ 5 SI
     4 green  ------ 2 SO
     5 brown  ------ 1 /CS
     6 grey   ------ 3 /WP (with 4k7 Pullup)
     7 purple ------ 7 /HOLD (with 4k7 Pullup)
    10 black  ------ 4 Gnd
```

Write command:

```
# time ./flashrom -p ft2232_spi:type=232H -c MX25L6406E/MX25L6436E -w ../../dump.mtd 2>&1 |tee log
flashrom v0.9.7-r1711 on Darwin 8.11.0 (Power Macintosh)
flashrom is free software, get the source code at http://www.flashrom.org

Calibrating delay loop... OK.
Found Macronix flash chip "MX25L6406E/MX25L6436E" (8192 kB, SPI) on ft2232_spi.
Reading old flash chip contents... done.
Erasing and writing flash chip... Erase/write done.
Verifying flash... VERIFIED.

real    7m1.731s
user    0m12.288s
sys     0m22.984s
```

The example shows burning of a MX25L6406 for the [Alfa AP121](/toh/alfa.network/ap121 "toh:alfa.network:ap121"). (No, I didn't brick it. ![;-)](/lib/images/smileys/wink.svg) I just wanted to replace a 4MB Flash with 8 MB flash.)

Warning: If you use a FTDI cable for [serial console](/docs/techref/hardware/port.serial.cables#prebuilt_cables "docs:techref:hardware:port.serial.cables") then you probably must disable the FTDI serial port driver or exclude the product ID 0x6014 for the FT232H chip in the serial driver. Patch for MacOS:

```
--- tmp/FTDIUSBSerialDriver.kext/Contents/Info.plist    2012-08-08 14:01:40.000000000 +0200
+++ /System/Library/Extensions/FTDIUSBSerialDriver.kext/Contents/Info.plist     2013-11-17 10:48:54.000000000 +0100
@@ -2014,25 +2014,6 @@
                        <key>idVendor</key>
                        <integer>1027</integer>
                </dict>
-               <key>FT232H</key>
-               <dict>
-                       <key>CFBundleIdentifier</key>
-                       <string>com.FTDI.driver.FTDIUSBSerialDriver</string>
-                       <key>IOClass</key>
-                       <string>FTDIUSBSerialDriver</string>
-                       <key>IOProviderClass</key>
-                       <string>IOUSBInterface</string>
-                       <key>bConfigurationValue</key>
-                       <integer>1</integer>
-                       <key>bInterfaceNumber</key>
-                       <integer>0</integer>
-                       <key>bcdDevice</key>
-                       <integer>2304</integer>
-                       <key>idProduct</key>
-                       <integer>24596</integer>
-                       <key>idVendor</key>
-                       <integer>1027</integer>
-               </dict>
                <key>FT4232H_A</key>
                <dict>
                        <key>CFBundleIdentifier</key>
```

*(Note: To get flashrom work on an old MacOS 10.4 PPC system as shown above you'll have to make some mods to flashrom.)*
