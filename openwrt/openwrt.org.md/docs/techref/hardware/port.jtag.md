# JTAG

JTAG stands for [Joint Test Action Group](https://en.wikipedia.org/wiki/Joint%20Test%20Action%20Group "https://en.wikipedia.org/wiki/Joint Test Action Group"), which is an [IEEE](https://en.wikipedia.org/wiki/Institute%20of%20Electrical%20and%20Electronics%20Engineers "https://en.wikipedia.org/wiki/Institute of Electrical and Electronics Engineers") work group defining an electrical interface for [integrated circuit](/docs/techref/hardware/ic "docs:techref:hardware:ic") ***testing*** and ***programming***.

- → [port.jtag](/docs/techref/hardware/port.jtag "docs:techref:hardware:port.jtag") (this article)
  
  - → [port.jtag.cables](/docs/techref/hardware/port.jtag.cables "docs:techref:hardware:port.jtag.cables") (homemade cables)
    
    - → [port.jtag.cable.buffered](/docs/techref/hardware/port.jtag.cable.buffered "docs:techref:hardware:port.jtag.cable.buffered")
    - → [port.jtag.cable.unbuffered](/docs/techref/hardware/port.jtag.cable.unbuffered "docs:techref:hardware:port.jtag.cable.unbuffered")
  - → [port.jtag.utilization](/docs/techref/hardware/port.jtag.utilization "docs:techref:hardware:port.jtag.utilization")
    
    - → [generic.debrick](/docs/guide-user/troubleshooting/generic.debrick "docs:guide-user:troubleshooting:generic.debrick") there is content on utilizing JTAG (link to it or from it, don't leave double content!)
    - → [jtag](/toh/davolink/dv-201amr#jtag "toh:davolink:dv-201amr") there is content on utilizing JTAG (link to it or from it, don't leave double content! unless specific)

<!--THE END-->

- [Debrick Routers with AR724x processors Using JTAG](https://forum.openwrt.org/viewtopic.php?id=34993 "https://forum.openwrt.org/viewtopic.php?id=34993")

## JTAG automate

There is always a JTAG automate (JTAG logic) integrated into your [soc](/docs/techref/hardware/soc "docs:techref:hardware:soc") or [cpu](/docs/techref/hardware/cpu "docs:techref:hardware:cpu") and usually this is connected to a JTAG header on the PCB. You can test and program the IC by issuing `JTAG commands` to it through the JTAG.

To do that, you need to connect the [parallel port](https://en.wikipedia.org/wiki/parallel%20port "https://en.wikipedia.org/wiki/parallel port") of your PC with the JTAG header on the PCB via a bought or a homemade “JTAG cable”. You then run a special JTAG software on your PC, which allows you to comfortably control the JTAG automate and make it perform commands like reads and writes at arbitrary locations.

As already stated the primary intention of the JTAG automate is to test the IC itself. But of course it can additionally be utilized to recover a device if you erased the bootloader resident on the flash. Because, through the JTAG automate in the SoC, you can also write to the Flash Chip.

A JTAG port can be used without any software running on the IC itself, but the IC still has to be powered by a separate power supply. This means, you can solder a lonely SoC to a PCB, no Flash-Chip, no RAM; then connect to it via JTAG and interact with the SoC. Of course, on the PC itself, you should have some sort of software, to make this interaction with the hardware on the lowest level possible a bit more comfortable.

Of course, if there is a flash chip soldered onto the PCB, you could access this chip by programming the SoC via JTAG. It's one of those amazingly useful things that allows you to recover from pretty much anything that doesn't involve a hardware failure.

The JTAG automate is not a standardized system. Different SoCs/CPUs/ISAs have different JTAG automate behavior and reset sequence, most likely you will find ARM and MIPS CPUs, both having their standard to allow controlling the CPU behavior using JTAG.

Finding JTAG connector on a PCB can be a little easier than finding the UART since most vendors leave those headers unpopulated after production. JTAG connectors are usually 12, 14, or 20-pins headers with one side of the connector having some signals at 3.3V and the other side being connected to GND.

## Identifying JTAG connector

### Headers

There are two major JTAG header arrangements used in SOHO routers based on MIPS CPUs. One uses 12 pins and the other uses 14 pins. While not radically different, you should be familiar with both. Other JTAG pinouts can be found at [http://www.jtagtest.com/pinouts/](http://www.jtagtest.com/pinouts/ "http://www.jtagtest.com/pinouts/").

#### 8 Pin Header - 1 row

[![](/_media/media/doc/hardware/jst-sh-8-labelled.jpg?h=200&tok=cc398b)](/_detail/media/doc/hardware/jst-sh-8-labelled.jpg?id=docs%3Atechref%3Ahardware%3Aport.jtag "media:doc:hardware:jst-sh-8-labelled.jpg") [![](/_media/media/doc/hardware/jst-sh-8.jpg?h=200&tok=2cd4d3)](/_detail/media/doc/hardware/jst-sh-8.jpg?id=docs%3Atechref%3Ahardware%3Aport.jtag "media:doc:hardware:jst-sh-8.jpg") Common in Thomson routers, but not elsewhere. Specifically these are JST-SH-8, 1.0mm pitch. If you want a tidy connection rather than soldering wires directly to the board, Sparkfun stocks [single cable/socket pairs](https://www.sparkfun.com/products/10853 "https://www.sparkfun.com/products/10853") (for their Arduino Mega Pro Mini), and [bags of 10 cable assemblies and sockets](http://www.ebay.co.uk/itm/181431004441 "http://www.ebay.co.uk/itm/181431004441") are cheap on eBay. They still need to be hand-soldered as they don't take too kindly to hot air tools.

? 1 nTRST 2 TCK 3 TMS 4 GND 5 TDO 6 TDI 7 GND 8

#### 10 Pin Header

Found in many Huawei routers:

TCK GND 1 2 TDO VREF 3 4 TMS nSRST 5 6 - nTRST 7 8 TDI GND 9 10

It matches with the ALTERA ByteBlasterMV 10-pin cable, but without the nSRST, nTRST pins.

#### 12 Pin Header

Found in Linksys routers such as the WRT54G and WRT54GS, the 12-pin header has the following arrangement of JTAG signals and pins:

nTRST GND 1 2 TDI GND 3 4 TDO GND 5 6 TMS GND 7 8 TCK GND 9 10 nSRST GND 11 12

Seems, this header is a truncated version of the full EJTAG header.

#### 14 Pin Header

This header is fully MIPS EJTAG 2.6 compatible and described in the EJTAG 2.6 standard. Found in Edimax routers (and other brands that are Edimax clones), the 14-pin header has the following arrangement of JTAG signals and pins:

nTRST GND 1 2 TDI GND 3 4 TDO GND 5 6 TMS GND 7 8 TCK GND 9 10 nSRST n/a 11 12 n/a Vcc 13 14

A buffered cable such as the Wiggler requires an external Vcc voltage supply. The 14-pin header conveniently supplies this voltage on pin 14. The typical unbuffered cable, however, does not require an external voltage in order to function. Formally, the pin 14 is called VREF and used to indicate a JTAG signal levels: 5V, 3.3V or 2.5V. On the most devices this pin is tied to the device's Vcc and may be used to power a buffer IC chip (and to generate an appropriate levels as result). Note that the 12-pin JTAG header arrangement does not provide Vcc.

#### 16 Pin Header

Usually found in IBM 4XX powerpc platform, this layout is also known as JTAG RISCWATCH

TDO - 1 2 TDI nTRST 3 4 HALTED VREF 5 6 TCK - 7 8 TMS - 9 10 HALT GND 11 12 nSRST KEY 13 14 - GND 15 16

#### 20 Pin Header

Found in Comtrend routers:

nTRST GND 1 2 TDI GND 3 4 TDO GND 5 6 TMS GND 7 8 TCK GND 9 10 nSRST GND 11 12 Vcc ? 13 14 Vcc GND 15 16 Vcc GND 17 18 Vcc GND 19 20

Not fully verified, Vcc at the bottom left are by add smd 0ohm. ![FIXME](/lib/images/smileys/fixme.svg)

### JTAG pinout scan

We can detect the pinout using a microcontroller like Arduino with specific software for this purpose. There are several implementations, probably JTAGenum is the best one.

#### JTAGenum

[JTAGenum](https://github.com/cyphunk/JTAGenum "https://github.com/cyphunk/JTAGenum") is opensource and runs over an Arduino board. It can find the JTAG pinout among a large amount of pins. The drawback is the **5V** signal voltage level on most Arduino boards, whereas most routers use a **3.3V** signal voltage levels. Therefore a level shift converter is required to wire the original Arduino with the test points at the router. Otherwise, there are some Arduino-compatible boards (like WeMos D1 for instance) built upon the famous ESP8266 which runs itself and the whole board at **3.3V**, so you are ready to go on scanning JTAG headers of common consumer networking equipment.

## JTAG software

### Hairydairymaid

The most famous software for JTAG is probably the Linksys De-Brick Utility by Hairydairymaid (aka Lightbulb). As of 12 September 2006 the most recent version is v4.8. Virtually everyone who uses this software opts for an unbuffered cable, and the software itself, by default, expects this type of cable to be used.

There is source code available on GitHub at [https://github.com/etmatrix/debrick\_buspirate](https://github.com/etmatrix/debrick_buspirate "https://github.com/etmatrix/debrick_buspirate"). The Github repo is likely the most stable source (the cshore site will not be hosting it any longer, as it was only added back for lack of another source).

The utility CAN operate on most any MIPS based cpu supporting EJTAG by using PrAcc routines (non-dma mode) - use the /nodma switch. It is not limited to WRT54G/GS units.

If you don't have a PC with parallel port but instead own a [Raspberry Pi](https://en.wikipedia.org/wiki/Raspberry_Pi "https://en.wikipedia.org/wiki/Raspberry_Pi"), you can use a [Raspberry Pi version](https://github.com/oxplot/tjtag-pi "https://github.com/oxplot/tjtag-pi") of this software instead which uses [the onboard GPIO pins](http://elinux.org/RPi_Low-level_peripherals#General_Purpose_Input.2FOutput_.28GPIO.29 "http://elinux.org/RPi_Low-level_peripherals#General_Purpose_Input.2FOutput_.28GPIO.29") to drive the JTAG lines.

Downloads:

- [zjtag-1.8.zip](/_media/media/doc/hardware/zjtag-1.8.zip "media:doc:hardware:zjtag-1.8.zip (400.7 KB)")

**Hairydairymaid variants:**

- [tjtag-pi](https://github.com/oxplot/tjtag-pi "https://github.com/oxplot/tjtag-pi")
- [tjtag-arduino](https://github.com/zoobab/tjtag-arduino "https://github.com/zoobab/tjtag-arduino")
- [tjtag-arduigler-HID](https://github.com/stahir/tjtag3-0-1_arduiglerHID "https://github.com/stahir/tjtag3-0-1_arduiglerHID")
- [zjtag](http://zjtag.osdn.jp/ "http://zjtag.osdn.jp/")
- [freetzlinux-wrtjp](http://sourceforge.net/p/freetzlinux/code/HEAD/tree/trunk/wrtjp/ "http://sourceforge.net/p/freetzlinux/code/HEAD/tree/trunk/wrtjp/")
- brjtag
- tjtag (AKA Tornado MOD)

### UrJTAG

Another popular JTAG utility is [Openwince JTAG](http://openwince.sourceforge.net/jtag/ "http://openwince.sourceforge.net/jtag/"). But is no longer developed. In late 2007, development of the openwince JTAG tools has been resumed in a new project named [UrJTAG](http://urjtag.sourceforge.net "http://urjtag.sourceforge.net"), with improvements like support for USB cables.

```
jtag> print
No. Manufacturer Part Stepping Instruction Register
---------------------------------------------------------------------------------------------
0 Lexra LX5280 1 BYPASS BR
Active bus:
*0: EJTAG compatible bus driver via PrAcc (JTAG part No. 0)
start: 0x00000000, length: 0x20000000, data width: 8 bit
start: 0x20000000, length: 0x20000000, data width: 16 bit
start: 0x40000000, length: 0x20000000, data width: 32 bit
```

### OpenOCD

OpenOCD is more complex than Hairydairymaid or UrJTAG since it is mainly used for debugging. But it can be also used for debricking.

- [http://openocd.sourceforge.net/](http://openocd.sourceforge.net/ "http://openocd.sourceforge.net/")
- [Debricking AR71xx](/docs/guide-user/hardware/debrick.ath79.using.jtag "docs:guide-user:hardware:debrick.ath79.using.jtag")

## Links

**Cleanup Required!**  
This page or section needs cleanup. You can edit this page to fix wiki markup, redundant content or outdated information.

- [EJTAG](http://www.linux-mips.org/wiki/JTAG "http://www.linux-mips.org/wiki/JTAG") at the Linux-MIPS Wiki
- [Openwince JTAG](http://openwince.sourceforge.net/jtag/ "http://openwince.sourceforge.net/jtag/"), “Supported hardware” section for other types of the JTAG cables.
- [K9SPUD JTAG](http://www.k9spud.com/jtag/ "http://www.k9spud.com/jtag/") another Wiggler schematic
- [USB JTAG](http://ixo-jtag.sourceforge.net/ "http://ixo-jtag.sourceforge.net/") a budget USB JTAG adapter
- [FREE JTAG Resources](http://www.asset-intertech.com/products/free_resources.htm "http://www.asset-intertech.com/products/free_resources.htm")
- [JTAG Pinouts](http://www.jtagtest.com/pinouts/ "http://www.jtagtest.com/pinouts/")

## Devices

The list of related devices: [jtag](/tag/jtag?do=showtag&tag=jtag "tag:jtag")
