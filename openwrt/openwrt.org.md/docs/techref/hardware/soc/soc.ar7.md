# AR7 SoCs

Originally made by Texas Instruments (2003).  
In 2007, TI sold its DSL business to Infineon. The part number on the SoCs changed the prefix *TNETD* to *PSB*  
In 2009, Infineon spins off its wireline division to Lantiq. On November 6, 2009, Lantiq annouced that it became a standalone company

The Architecture is based on a standard **MIPS32** Instruction Set, sharing features with the R4600 microprocessor. It can operate in both little and big endian modes. Almost all brands ship their devices configured in little Endian but Zyxel using Big Endian.

## Linux support

- The OpenWrt support for the AR7 SoC family currently only works with following models:
  
  - **TNETD7100**, **TNETD7200**, **TNETD7300** `(Ohio/Sangam)`
  - **TNETV1050**, **TNETV1055**, **TNETV1056**, **TNETV1060** `(Titan)`
  - **AC495**, **AC496** `(Audiocodes)`
- Only **little endian** support. Support for Big endian configured SoCs possible but not integrated into OpenWrt
- Full Linux support with runtime detection of the SoC on which the kernel is running.
- xDSL and ATM are SUPPORTED
- GPL drivers for Ethernet/switch, Watchdog
- VLYNQ proprietary bus interface supported for the most common wifi cards, TNETW1350 not supported
- No support for the USB host/slave

## Common features

[![](/_media/media/doc/hardware/tnetd73xx-block-diagram.png?w=700&tok=4f63a6)](/_media/media/doc/hardware/tnetd73xx-block-diagram.png "media:doc:hardware:tnetd73xx-block-diagram.png")

- Integrated high performance MIPS 4KEc 32-Bit RISC processor
- ADSL PHY subsystem based on TI C62x DSP, with integrated transceiver, codec, line driver, and line receiver
- Hardware accelerated ATM SAR
- Integrated IEEE 802.3 PHY
- Two IEEE 802.3 MACs with integrated Media Independent Interface (MII) and Quality of Service (QoS)
- Integrated USB 1.1 compliant transceiver, slave. Only TNETV1050 is USB host capable.
- Two VLYNQ interfaces for compatible high-speed expansion devices
- Two 16c550 compatible UARTs
- EJTAG, GPIO and FSER interfaces
- 4Kb PROM (0xBFC00000) and 4Kb RAM (0x80000000) on the chip for boot purposes
- 324 BGA with 1.0-mm ball pitch

SoC codename TNETD7100 Ohio TNETD7200 Ohio TNETD73XX Sangam TNETV1050 Titan TNETC4401 Puma-S TNETV1020 Apex

**Abbreviations**

- AR7DB: AR7 Development Board
- AR7RD: AR7 Reference Design board
- AR7VDB: AR7 Verification and Debug Board
- AR7WRD: AR7 WLAN Reference Design board; uses 1130/1350 WLAN core.
- AR7Wi: AR7 WLAN board; uses 1230 WLAN core.
- AR7vWi: AR7 Voice-WLAN board; uses 1230 WLAN core.
- TNETV1050SDB: 1050 SoC based VoP Development Board (Titan board)
- TNETW113vag: 5306 SoC based WLAN (1130 core) board
- WA1130v : reference design WLAN board to showcase PUMA(S)

## Bootloader

[**adam2**](/docs/techref/bootloader/adam2 "docs:techref:bootloader:adam2"): The bootloader commonly used in AR7, with some limitations.  
[**PSPBoot**](/docs/techref/bootloader/pspboot "docs:techref:bootloader:pspboot"): an evolution of ADAM2, used in the most modern devices  
**Bootbase**: bootloader used by Zyxel in AR7, working in Big endian mode  
**EVA**: not very common in AR7, based on Adam2

## GPIOs

In OpenWrt the AR7 [GPIOs](/docs/techref/hardware/port.gpio "docs:techref:hardware:port.gpio") can be accessed by using the char device */dev/gpio*, but first you may need to make them available

```
mkdir /dev/gpio
for i in `seq 0 31`; do mknod /dev/gpio/gpio$i c 254 $i; done
```

Now you can control GPIOs using the *echo* command

- Enable:`echo e > /dev/gpio/gpioX`
- Disable:`echo d > /dev/gpio/gpioX`
- Output:`echo o > /dev/gpio/gpioX`
- Input:`echo i > /dev/gpio/gpioX`
- High:`echo 1 > /dev/gpio/gpioX`
- Low:`echo 0 > /dev/gpio/gpioX`

Example, use GPIO5 as an output and put it on high state:  
`echo e > /dev/gpio/gpio5 echo o > /dev/gpio/gpio5 echo 1 > /dev/gpio/gpio5`

With latest OpenWrt versions should be possible to control GPIOs by using the **/sys/class/gpio/** interface, but it doesn's seeem to be enabled in the kernel. Therefore building your own firmware with GPIO\_SYSFS enabled is required.

## Pinouts

### TNETD7200/7300 pinout

[![](/_media/media/datasheets/tnetd7300-pinout.png?w=600&tok=bbab84)](/_media/media/datasheets/tnetd7300-pinout.png "media:datasheets:tnetd7300-pinout.png")

### TNETV1050 pinout

[![](/_media/media/datasheets/tnetv1050_pinout.png?w=600&tok=78f9b9)](/_media/media/datasheets/tnetv1050_pinout.png "media:datasheets:tnetv1050_pinout.png")

### TNETV1060 pinout

[![](/_media/media/datasheets/tnetv1060_pinout.png?w=600&tok=e06bf7)](/_media/media/datasheets/tnetv1060_pinout.png "media:datasheets:tnetv1060_pinout.png")

## Devices

The list of related devices: [AR7](/tag/ar7?do=showtag&tag=AR7 "tag:ar7")
