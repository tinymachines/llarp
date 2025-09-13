# Broadcom BCM33xx

This page covers the BCM33xx SoC specificities, but the [BCM63xx](/docs/techref/hardware/soc/soc.broadcom.bcm63xx "docs:techref:hardware:soc:soc.broadcom.bcm63xx") SoC are mostly the same chip, except that the DOCSIS/EuroDOCSIS core is replaced with a DSL one.

- The Broadcom BCM33xx currently only begins booting with the SB4xxx cable modems. This only worked on [the dropped bcm63xx target](https://github.com/openwrt/openwrt/pull/14559 "https://github.com/openwrt/openwrt/pull/14559").

## Linux support

- The OpenWrt support for the Broadcom BCM33xx SoC family currently only works with following models, using the target [BCM63xx](/docs/techref/hardware/soc/soc.broadcom.bcm63xx "docs:techref:hardware:soc:soc.broadcom.bcm63xx"):
  
  - **3368**

BCM33xx support was partially introduced in the BCM63xx target. However, the BCM63xx target has been superseded by the BMIPS target, and we lost BCM33xx support (for now).

There is a WIP support for BCM3380 on Netgear CG3100D:

[https://github.com/rikka0w0/openwrt-fast3864op/tree/bcm3380-20241014](https://github.com/rikka0w0/openwrt-fast3864op/tree/bcm3380-20241014 "https://github.com/rikka0w0/openwrt-fast3864op/tree/bcm3380-20241014")

More progress can be found here:

[https://gist.github.com/rikka0w0/4e4d5feb3a50a8b64224750140f859ef](https://gist.github.com/rikka0w0/4e4d5feb3a50a8b64224750140f859ef "https://gist.github.com/rikka0w0/4e4d5feb3a50a8b64224750140f859ef")

There is an attempt to run Linux on TC7200 (BCM3383): [https://github.com/jclehner/linux-technicolor-tc7200](https://github.com/jclehner/linux-technicolor-tc7200 "https://github.com/jclehner/linux-technicolor-tc7200")

## Broadcom DOCSIS

- We have no GPL'd drivers for Ethernet or DOCSIS so this makes the board pretty useless. DOCSIS would require images to be signed by CableLabs if to be used in a real environment, anyway.

## What is this Broadcom 33xx stuff?

[Broadcom33xx SoC](http://www.broadcom.com/products/Cable/Cable-Modem-Solutions "http://www.broadcom.com/products/Cable/Cable-Modem-Solutions") integrates DOCSIS/EuroDOCSIS features and routing.

## What are 33xx variants?

There are many 33xx variants. Only those with a TLB will be supported:

Chip CPU MHz USB Device VoIP WiFi DOCSIS TLB Product ID -march Surfboard [bcm3300](http://www.datasheetcatalog.org/datasheets2/13/131978_1.pdf "http://www.datasheetcatalog.org/datasheets2/13/131978_1.pdf") n/a - - - 1.0/1.1 Yes - mips32 3100 bcm3302 ? ? ? ? - ? ? ? ? [bcm3345](http://www.datasheetcatalog.org/datasheets2/15/155898_1.pdf "http://www.datasheetcatalog.org/datasheets2/15/155898_1.pdf") 140Mhz MIPS (1x) 1.1 - - 1.0/1.1 Yes? 0x28000 mips32 4200 [bcm3348](http://www.datasheetcatalog.org/datasheets/166/404171_DS.pdf "http://www.datasheetcatalog.org/datasheets/166/404171_DS.pdf") 200Mhz MIPS (1x) 1.1 - - 1.0/1.1/2.0 Yes ? mips32 5100 [bcm3349](http://www.broadcom.com/products/Cable/Cable-Modem-Solutions/BCM3349 "http://www.broadcom.com/products/Cable/Cable-Modem-Solutions/BCM3349") 200Mhz MIPS (1x) 1.1 - EBI/PCMCIA 1.0/1.1/2.0 Yes ? mips32? 5101 [bcm3350](http://www.datasheetcatalog.org/datasheets/134/404172_DS.pdf "http://www.datasheetcatalog.org/datasheets/134/404172_DS.pdf") 100Mhz MIPS (1x) 1.1 - - 1.0/1.1 No 0x28000 mips32 4100 [bcm3368](http://www.broadcom.com/products/Cable/Cable-Modem-Solutions/BCM3368 "http://www.broadcom.com/products/Cable/Cable-Modem-Solutions/BCM3368") 300Mhz MIPS (1x) 1.1 2 lines Expansion Bus 2.0 Yes ? mips32 - [bcm3380](http://datasheet.elcodis.com/pdf/48/45/484522/bcm3380dkfsbg.pdf "http://datasheet.elcodis.com/pdf/48/45/484522/bcm3380dkfsbg.pdf") 333Mhz MIPS (2x) 2.0 x2 2 lines miniPCIe 3.0 Yes ? mips32 - [bcm3382](https://www.broadcom.com/products/Cable/Cable-Modem-Solutions/BCM3382 "https://www.broadcom.com/products/Cable/Cable-Modem-Solutions/BCM3382") 400Mhz MIPS (2x) - 2 lines - 3.0 Yes ? mips32 6182 [bcm3383](http://www.broadcom.com/products/Cable/Cable-Modem-Solutions/BCM3383 "http://www.broadcom.com/products/Cable/Cable-Modem-Solutions/BCM3383") 600Mhz MIPS (2x) 2.0 2 lines miniPCIe 3.0 Yes ? mips32 - [bcm3384](http://www.broadcom.com/products/Cable/Cable-Modem-Solutions/BCM3384 "http://www.broadcom.com/products/Cable/Cable-Modem-Solutions/BCM3384") 600Mhz MIPS (2x) 2.0 ? miniPCIe 3.0 Yes ? mips32 - [bcm3390](https://www.broadcom.com/products/broadband/cable/modems/bcm3390 "https://www.broadcom.com/products/broadband/cable/modems/bcm3390") 1.5Ghz ARM (2x), 675Mhz MIPS (2x) 2.0/3.0 - miniPCIe 3.1 Yes ? armv7-a/mips32 8200

### bcm3300

This chip does not include a CPU itself.

Known platforms:

- 3Com HomeConnect Cable Modem
- Aastra PipeRider HM200
- Ambit 60098E/U
- Arris CM200\[U]
- Askey CME03x
- Cisco uBR924
- Com21 DOXport 1010
- E-Tech ICE 200
- E-Tech ITCM
- GVC USB Cable Modem
- Motorola SURFboard 3100A/B
- Samsung InfoRanger ITCM/SCM-110R
- Thomson RCA DCM 205/215/225
- Zyxel Prestige 941

### bcm3302

This chip seems to be a general-purpose MIPS CPU. It is usually included with other platforms like bcm47xx and such.

### bcm3345

Known platforms:

- [Motorola SURFboard 4200](https://oldwiki.archive.openwrt.org/oldwiki:openwrtdocs:hardware:motorola:sb4200 "https://oldwiki.archive.openwrt.org/oldwiki:openwrtdocs:hardware:motorola:sb4200") cable modem
- Hitron BRG-3520

[http://www.datasheetcatalog.org/datasheets2/15/155898\_1.pdf](http://www.datasheetcatalog.org/datasheets2/15/155898_1.pdf "http://www.datasheetcatalog.org/datasheets2/15/155898_1.pdf")

### bcm3348

Known platforms:

- [Motorola SURFboard 5100](https://oldwiki.archive.openwrt.org/oldwiki:openwrtdocs:hardware:motorola:sb5100 "https://oldwiki.archive.openwrt.org/oldwiki:openwrtdocs:hardware:motorola:sb5100")
- [Motorola SBG900E](https://oldwiki.archive.openwrt.org/oldwiki:openwrtdocs:hardware:motorola:sbg900e "https://oldwiki.archive.openwrt.org/oldwiki:openwrtdocs:hardware:motorola:sbg900e")
- Scientific-Atlanta WebStar DPX-2100
- [Thomson TCM390](https://oldwiki.archive.openwrt.org/oldwiki:openwrtdocs:hardware:thomson:tcm390 "https://oldwiki.archive.openwrt.org/oldwiki:openwrtdocs:hardware:thomson:tcm390")

### bcm3349

Known platforms:

- Motorola SURFboard 5101
- [Scientific-Atlanta WebStar DPC2100](https://oldwiki.archive.openwrt.org/oldwiki:openwrtdocs:hardware:scientific_atlanta:dpc2100 "https://oldwiki.archive.openwrt.org/oldwiki:openwrtdocs:hardware:scientific_atlanta:dpc2100")
- [Scientific-Atlanta WebStar EPX2203](https://oldwiki.archive.openwrt.org/toh/scientific.atlanta/epx2203 "https://oldwiki.archive.openwrt.org/toh/scientific.atlanta/epx2203")

Source code:

- [Commscope SourceForge SB5101/SB5102](https://sourceforge.net/arris/sb5101/home/Home/ "https://sourceforge.net/arris/sb5101/home/Home/")

### bcm3350

Known platforms:

- [Motorola SURFboard 4000/410x](https://oldwiki.archive.openwrt.org/oldwiki:openwrtdocs:hardware:motorola:sb4100 "https://oldwiki.archive.openwrt.org/oldwiki:openwrtdocs:hardware:motorola:sb4100")
- Ambit 60218P
- Ambit 60194E
- Askey CME063
- Com21 DOXport 1110
- Hitron BRG-3510
- Icable ICS-110
- Linksys BEFCMUH4/BEFCMU10
- Thomson RCA DCM 235/305
- [USRobotics USR6000](https://oldwiki.archive.openwrt.org/oldwiki:openwrtdocs:hardware:usrobotics:usr6000 "https://oldwiki.archive.openwrt.org/oldwiki:openwrtdocs:hardware:usrobotics:usr6000")

MIPS R3000 CPU **without a TLB** (random register always reads a 0)

Note: Ralf says this is just mostly R3000-\*compatible\*, so -march=mips32 is safer.

[http://www.datasheetcatalog.org/datasheets/134/404172\_DS.pdf](http://www.datasheetcatalog.org/datasheets/134/404172_DS.pdf "http://www.datasheetcatalog.org/datasheets/134/404172_DS.pdf")

read\_c0\_prid() ⇒ 0x28000

NS16550 serial UART

i82559 Ethernet

Used in the [SB4100](https://oldwiki.archive.openwrt.org/oldwiki:openwrtdocs:hardware:motorola:sb4100 "https://oldwiki.archive.openwrt.org/oldwiki:openwrtdocs:hardware:motorola:sb4100") cable modem

### bcm3368

Known platforms:

- [Netgear CVG834G](https://oldwiki.archive.openwrt.org/oldwiki:openwrtdocs:hardware:netgear:cvg834g "https://oldwiki.archive.openwrt.org/oldwiki:openwrtdocs:hardware:netgear:cvg834g")
- Scientific-Atlanta WebStar DPX/[EPC 2203](https://oldwiki.archive.openwrt.org/toh/scientific.atlanta/epc2203c "https://oldwiki.archive.openwrt.org/toh/scientific.atlanta/epc2203c")
- [Cisco EPC2425](http://www.cisco.com/web/consumer/support/modem_DPC2425.html "http://www.cisco.com/web/consumer/support/modem_DPC2425.html")
- Thomson AGC905

### bcm3380

Known platforms:

- [Cisco DPC3212/EPC3212](http://www.cisco.com/web/consumer/support/modem_DPC3212.html "http://www.cisco.com/web/consumer/support/modem_DPC3212.html")
- [Cisco DPC3825/EPC3825](/toh/cisco/epc3825 "toh:cisco:epc3825")
- [Cisco EPC3925](/toh/cisco/epc3925 "toh:cisco:epc3925")
- [Netgear CG3100Dv3, CG3100D](/inbox/toh/openwrt/netgear_cg3100d_v3 "inbox:toh:openwrt:netgear_cg3100d_v3")
- [Motorola SBG6580](http://www.motorola.com/us/consumers/SBG6580-SURFboard%C2%AE-eXtreme-Wireless-Cable-Modem/70902,en_US,pd.html?cgid=gateways-and-modems "http://www.motorola.com/us/consumers/SBG6580-SURFboard®-eXtreme-Wireless-Cable-Modem/70902,en_US,pd.html?cgid=gateways-and-modems")
- Thomson TWG870

### bcm3383

Firmware and additional sources available for [Technicolor TC7200](https://github.com/tch-opensrc/TC72XX_LxG1.0.10mp5_OpenSrc "https://github.com/tch-opensrc/TC72XX_LxG1.0.10mp5_OpenSrc")

Known platforms:

- [Netgear C6300BD-1TLAUS](/inbox/toh/netgear/c6300bd-1tlaus "inbox:toh:netgear:c6300bd-1tlaus"), [Firmware source code](https://www.downloads.netgear.com/files/GPL/C6300BD_1TLAUS_v1.01.03_src_20140319.zip "https://www.downloads.netgear.com/files/GPL/C6300BD_1TLAUS_v1.01.03_src_20140319.zip")
- [Netgear CG3000-2STAUS](/inbox/toh/openwrt/cg3000-2staus "inbox:toh:openwrt:cg3000-2staus"), [Firmware source code](https://www.downloads.netgear.com/files/GPL/CG3000-2STAUS_V2.03.02n_GPL.zip "https://www.downloads.netgear.com/files/GPL/CG3000-2STAUS_V2.03.02n_GPL.zip")
- [Netgear CG3000Dv2 (N450)](/toh/netgear/cg3000dv2 "toh:netgear:cg3000dv2"), [Firmware source code](https://www.downloads.netgear.com/files/GPL/N450-100NAS_V1.02.10_src_20170912.zip "https://www.downloads.netgear.com/files/GPL/N450-100NAS_V1.02.10_src_20170912.zip")

### bcm3384

As per the [readme](https://github.com/Broadcom/aeolus/blob/master/README.md "https://github.com/Broadcom/aeolus/blob/master/README.md") for Broadcom's open source bootloader for the bcm3384, the SoC has 2 big-endian MIPS32R1 processors:

- One 'Viper' (BMIPS4355) core responsible for the cable modem/DOCSIS subsystem, running the eCos RTOS.
- One 'Zephyr' (BMIPS5000) application processor responsible for running other services, in most cases it runs a form of Linux.

The Viper core runs first, performing tasks including basic peripheral initialisation and preperation of the Linux image for the Zephyr.

Firmware and additional sources available for [Technicolor TC7210 and TC7230](https://github.com/tch-opensrc/TC72XX_LxG1.0.10mp5_OpenSrc "https://github.com/tch-opensrc/TC72XX_LxG1.0.10mp5_OpenSrc")

### bcm3390

Known platforms:

- Motorola/Arris/Commscope SB8200/CM8200 (Linux kernel + eCos source: [Commscope SourceForge 8200](https://sourceforge.net/projects/c8200-cable-modem.arris/files/ "https://sourceforge.net/projects/c8200-cable-modem.arris/files/"))
- Netgear CM1000/CM1100 (Linux kernel + eCos source: [Netgear GPL open source code for programmers](https://kb.netgear.com/2649/NETGEAR-Open-Source-Code-for-Programmers-GPL "https://kb.netgear.com/2649/NETGEAR-Open-Source-Code-for-Programmers-GPL"))

[This repo](https://github.com/jclehner/bcm3390 "https://github.com/jclehner/bcm3390") appears to provide some information (header files, register layout, and some pinouts) of the BCM3390 SoC.

[There are some kernel code that related to BCM3390A0](https://github.com/atefganm/linux-3.14.79/tree/be685f2a8a8732a00523f7a686aebd2ea0b6930e "https://github.com/atefganm/linux-3.14.79/tree/be685f2a8a8732a00523f7a686aebd2ea0b6930e")

Also this one: [https://github.com/pombredanne/stblinux-3.14/tree/master/linux](https://github.com/pombredanne/stblinux-3.14/tree/master/linux "https://github.com/pombredanne/stblinux-3.14/tree/master/linux")

[Header files](https://github.com/RDS5/kernel_arris_vip56x2w/tree/7fa47fd87658cb8931f8ee6dcda4027d50f83072/include/linux/brcmstb/3390a0 "https://github.com/RDS5/kernel_arris_vip56x2w/tree/7fa47fd87658cb8931f8ee6dcda4027d50f83072/include/linux/brcmstb/3390a0")

## Finished tasks

The support for Broadcom 33xx is at this state :

- Linux 2.6.x booting before failing to find init on bcm3348 (SB4200)
- Linux 2.6.x booting to BusyBox shell on bcm3349 (WebSTAR DPC2100)

## TODO

- Talk with Broadcom related vendors to make them release some sources
- A u-boot port is required to get around secure boot (not secure app)/to replace the original bootloader and an ethernet driver needs to be written (binary blob Linux driver is a virtual link to eCos)

The Netgear CVG834G uses a bcm33xx chip and has GPL'd eCos. Netgear modified the Atlas driver in eCos to add the bcm3350.

- Technicolor opensourced some platforms: [Github account of Technicolor](https://github.com/tch-opensrc "https://github.com/tch-opensrc")
- Technicolor additional information for certain products [Technicolor internal business website](http://ebroot.technicolor.com/opensw/documents/ "http://ebroot.technicolor.com/opensw/documents/")
- Commscope opensourced many platforms: [Commscope SourceForge project list](https://sourceforge.net/arris/wiki/Projects/ "https://sourceforge.net/arris/wiki/Projects/")

## Firmware/Bootloader

Surfboard modems use a [VxWorks](/docs/techref/bootloader/vxworks "docs:techref:bootloader:vxworks") bootloader ([headers](/docs/techref/headers "docs:techref:headers")). For other modems, the official broadcom bootloaders are used (BOLT and cmboot); both bootloaders are proprietary. BOLT is used on bcm3384 and later, especially on bcm3390.

#### Determining if secure boot is enabled

If a device is using the official broadcom bootloader (cmboot), it is possible to determine whether secure boot is enabled by looking for a “Cust key size” message on the serial console.

#### cmboot: secure boot and/or secure app?

It should be noted that secure boot != secure app, where the former refers to bootrom validation of code stored in flash, and secure app refers to the validation of images passed to cmboot.

While secure boot might not let you replace cmboot with another bootloader, it is still possible to boot up a 2nd-stage bootloader if secure app is not enabled.

#### Aeolus

Cable modems like Netgear CG3100D use a special proprietary bootloader called [Aeolus](https://github.com/Broadcom/aeolus "https://github.com/Broadcom/aeolus"). Broadcom has decided to [open-source the Aeolus implementation for BCM3384](https://github.com/Broadcom/aeolus "https://github.com/Broadcom/aeolus"). Although CG3100D is based on BCM3380, the ProgramStore utility from BCM3384's Aeolus can still be used to prepend necessary headers and compress the OpenWrt firmware image.

#### U-Boot

There is [a U-Boot port for Netgear CG3100D](https://github.com/u-boot/u-boot/blob/7036abbd5c3934059b020d5fd5bcb8b3bf3c788c/arch/mips/dts/netgear%2Ccg3100d.dts "https://github.com/u-boot/u-boot/blob/7036abbd5c3934059b020d5fd5bcb8b3bf3c788c/arch/mips/dts/netgear%2Ccg3100d.dts") by [Noltari](https://github.com/Noltari "https://github.com/Noltari"), who's also a core OpenWrt contributor. It only boots in RAM and almost everything (including ethernet and flash) does not work. See [netgear\_cg3100d\_v3](/inbox/toh/openwrt/netgear_cg3100d_v3 "inbox:toh:openwrt:netgear_cg3100d_v3") for how to load it to your device's memory.

## Devices

The list of related devices: [bcm3368](/tag/bcm3368?do=showtag&tag=bcm3368 "tag:bcm3368"), [bcm3380](/tag/bcm3380?do=showtag&tag=bcm3380 "tag:bcm3380"), [bcm3383](/tag/bcm3383?do=showtag&tag=bcm3383 "tag:bcm3383"), [bcm3384](/tag/bcm3384?do=showtag&tag=bcm3384 "tag:bcm3384"), [bcm3390](/tag/bcm3390?do=showtag&tag=bcm3390 "tag:bcm3390"), [bcm33xx](/tag/bcm33xx?do=showtag&tag=bcm33xx "tag:bcm33xx")
