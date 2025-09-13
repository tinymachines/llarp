# The Bootloader

The [Bootloader](https://en.wikipedia.org/wiki/Bootloader "https://en.wikipedia.org/wiki/Bootloader") is a piece of software that is executed every time the hardware device is powered up. It is executable machine code and thus [ARCH](/docs/techref/hardware/cpu#the_isa_instruction_set_architecture "docs:techref:hardware:cpu")-specific. It's quite heavily device-specific because its main task is to initialize all the low-level hardware details. The bootloader can be contained on a separate [EEPROM](https://en.wikipedia.org/wiki/EEPROM "https://en.wikipedia.org/wiki/EEPROM") (very seldom) or directly on flash storage (most common).

Being a piece of software, the bootloader is considered part of the firmware, but **the bootloader is not part of OpenWrt!**  
Only on seldom occasions a change of the *bootloader settings* or the *bootloader code* is necessary to allow for booting/installing OpenWrt  
There are a number of bootloaders under diverse [software license](https://en.wikipedia.org/wiki/software%20license "https://en.wikipedia.org/wiki/software license")s

## Main Function

The bootloader's main function is to initialize the hardware, pass an abstraction of the initialized hardware, a hardware description, to and execute the Kernel. (A very nice technical example can be seen [here](https://web.archive.org/web/20111219072809/http://www.wehavemorefun.de/fritzbox/index.php/ADAM2 "https://web.archive.org/web/20111219072809/http://www.wehavemorefun.de/fritzbox/index.php/ADAM2") or see a suggestion until finding a better example: [here](https://www.moritz.systems/blog/before-the-bsd-kernel-starts-part-one-on-amd64/ "https://www.moritz.systems/blog/before-the-bsd-kernel-starts-part-one-on-amd64/") and [here](https://0xax.gitbooks.io/linux-insides/content/Booting/linux-bootstrap-1.html "https://0xax.gitbooks.io/linux-insides/content/Booting/linux-bootstrap-1.html")) After that the bootloader is done and not needed in memory any longer. Most bootloaders offer [additional functions](#additional_functions "docs:techref:bootloader ↵").

### Why this is necessary?

It's not. A bootloader is not required to boot Linux. The use of one (or several) bootloaders in a row to chainload (or [bootstrap](https://en.wikipedia.org/wiki/Bootstrapping%20%28computing%29 "https://en.wikipedia.org/wiki/Bootstrapping (computing)")) a Kernel is not a categorical necessity, it is merely a very crafty method to start an operating system. The main advantage for OpenWrt is, that the existence of a bootloader offers users and developers additional possibilities to [debrick](/docs/guide-user/troubleshooting/generic.debrick "docs:guide-user:troubleshooting:generic.debrick") a device.

## Features

### Limitations

Some bootloader or implementation of universal bootloaders come with certain limitation implemented by the OEM, such as:

- a willfully designed kernel/firmware size limitation
- make the bootloader expect a certain exotic firmware format
- inability of the bootloader to execute the [ELF](https://en.wikipedia.org/wiki/Executable%20and%20Linkable%20Format "https://en.wikipedia.org/wiki/Executable and Linkable Format") binary format
- the need of some obscure “magic value” to be present and correct
- you name it

The reasons are variable, from simple ineptitude of the creators to the willful sabotage of the users' attempts to run [free software](https://en.wikipedia.org/wiki/free%20software "https://en.wikipedia.org/wiki/free software") on their own property.

### Additional Functions

The bootloader can be more or less sophisticated, and offer none to many additional functions. In many situations additional functions would give the user a huge advantage, so most bootloaders offer them, such as:

- Flash new firmware, see [generic.flashing](/docs/guide-user/installation/generic.flashing "docs:guide-user:installation:generic.flashing")
- The bootloader can possibly validate data on the flash-storage, and e.g. should the firmware fail to pass a CRC, the bootloader would presume the firmware is corrupt and wait for a new firmware to be uploaded over the network. Of course, this also means, that every time you change something on the flash, you have to update this CRC-value...
- this could also be triggered by setting a boot\_wait variable or by a command executed in the serial console
- a [CLI](https://en.wikipedia.org/wiki/Command-line%20interface "https://en.wikipedia.org/wiki/Command-line interface") (aka *serial console*), which usually can be accessed over the [serial port](/docs/techref/hardware/port.serial "docs:techref:hardware:port.serial") **only**. There are several ways to access the *serial console* port on your target system, such as using a terminal server, but the most common way is to attach it to a serial port on your host. Additionally, you will need a terminal emulation program on your host system, such as `cu` or `kermit`.
  
  - once the bootloader has fulfilled its main function - chainload the Kernel - it does not run any longer, so to play with it, you have to login to it before it loads the Kernel and you may also have to prevent it from loading the Kernel, i.e. to stop the boot process.
- boot from USB
  
  - Like the Kernel requires the module `kmod-fs-ext4` to read/write to a EXT3 filesystem, so a bootloader requires such a module to do the same. [GRUB2](https://en.wikipedia.org/wiki/GRUB2 "https://en.wikipedia.org/wiki/GRUB2") has this functionality implemented, so with it, you can very comfortably configure your boot options and also update and maintain your OS. The lightweight bootloaders we use with OpenWrt, usually do not have this functionality. But see [flash.layout](/docs/techref/flash.layout "docs:techref:flash.layout") for further reference. One exception is the U-Boot implementation of the [dockstar](/toh/seagate/dockstar "toh:seagate:dockstar"). It can not only initialize the USB (like all the rest of the hardware) but additionally utilize the USB and also understand the EXT2 filesystem. Thus, the dockstar can be booted directly from an ext2-formated harddisc/usb-stick connected to any of it's USB-ports.
- [net booting](/inbox/howto/netboot "inbox:howto:netboot") functionality via [BOOTP](https://en.wikipedia.org/wiki/Bootstrap%20Protocol "https://en.wikipedia.org/wiki/Bootstrap Protocol") or [PXE](https://en.wikipedia.org/wiki/Preboot%20Execution%20Environment "https://en.wikipedia.org/wiki/Preboot Execution Environment") or DHCP or NFS or [TFTP](https://en.wikipedia.org/wiki/Trivial%20File%20Transfer%20Protocol "https://en.wikipedia.org/wiki/Trivial File Transfer Protocol")

## Boot Procedure

→ [**boot process**](/docs/techref/process.boot "docs:techref:process.boot") should give a more detailed description of whole boot procedure. The bootloader is the beginning.

## Individual Bootloaders

[Comparison of boot loaders](https://en.wikipedia.org/wiki/Comparison%20of%20boot%20loaders "https://en.wikipedia.org/wiki/Comparison of boot loaders")

*Please use `templates` to create and maintain these articles. ATM they are quite unmaintained and without a structure and almost useless*

### PC

An embedded bootloader fulfills the same functionality as the [BIOS](https://en.wikipedia.org/wiki/BIOS "https://en.wikipedia.org/wiki/BIOS") plus [GNU GRUB](https://en.wikipedia.org/wiki/GNU%20GRUB "https://en.wikipedia.org/wiki/GNU GRUB") together on a PC.

- [BIOS](https://en.wikipedia.org/wiki/BIOS "https://en.wikipedia.org/wiki/BIOS") proprietary the BIOS of your PC *is* nothing else but a bootloader!
- [UEFI](https://en.wikipedia.org/wiki/Extensible%20Firmware%20Interface "https://en.wikipedia.org/wiki/Extensible Firmware Interface") proprietary successor want-to-be of the BIOS
- [coreboot](https://en.wikipedia.org/wiki/coreboot "https://en.wikipedia.org/wiki/coreboot") GPLv2 successor of the BIOS, alternative to UEFI based on the Linux kernel;  
  support for x86, x86-64 and ARM. There is no MIPS support.  
  Coreboot does only “a little bit of hardware initialization”
- [GNU GRUB](https://en.wikipedia.org/wiki/GNU%20GRUB "https://en.wikipedia.org/wiki/GNU GRUB") GPLv2

### Embedded Devices

- [**Das U-Boot**](/docs/techref/bootloader/uboot "docs:techref:bootloader:uboot") GPLv2 arguably the richest, most flexible, and most actively developed FOSS bootloader available
- [pepe2k-u-boot\_mod](/docs/techref/bootloader/pepe2k "docs:techref:bootloader:pepe2k") GPLv2 U-Boot 1.1.4 modification for routers [https://github.com/pepe2k/u-boot\_mod](https://github.com/pepe2k/u-boot_mod "https://github.com/pepe2k/u-boot_mod")
- [RedBoot](/docs/techref/bootloader/redboot "docs:techref:bootloader:redboot") mod GPL
- [CFE](/docs/techref/bootloader/cfe "docs:techref:bootloader:cfe") BSD like by Broadcom; the orange color means, the OEM is not obliged to deliver the source code
- [Adam2](/docs/techref/bootloader/adam2 "docs:techref:bootloader:adam2") proprietary for AR7/UR8
  
  - [pspboot](/docs/techref/bootloader/pspboot "docs:techref:bootloader:pspboot") proprietary the only slightly compatible successor of Adam2.
- [brnboot](/docs/techref/bootloader/brnboot "docs:techref:bootloader:brnboot") unknown sometimes called AMAZON Loader.
- [bootbase](/docs/techref/bootloader/bootbase "docs:techref:bootloader:bootbase") unknown used by the ZyXEL Prestige 660HW-xx and Prestige 660M-xx devices (and probably other ZyXEL products). [http://www.ixo.de/info/zyxel\_uclinux/](http://www.ixo.de/info/zyxel_uclinux/ "http://www.ixo.de/info/zyxel_uclinux/")
- [jboot](/docs/techref/bootloader/jboot "docs:techref:bootloader:jboot") unknown
- [myloader](/docs/techref/bootloader/myloader "docs:techref:bootloader:myloader") unknown
- [pp\_boot](/docs/techref/bootloader/pp_boot "docs:techref:bootloader:pp_boot") unknown
- [yamon](/docs/techref/bootloader/yamon "docs:techref:bootloader:yamon") unknown by [Imagination Technology](https://en.wikipedia.org/wiki/Imagination%20Technology "https://en.wikipedia.org/wiki/Imagination Technology"); the Linux kernel can only be booted when it is in SREC format.
- [Breed](/docs/techref/bootloader/breed "docs:techref:bootloader:breed") - Breed booatloader

<!--THE END-->

- VxWorks' own bootloader - most Atheros devices (There is a description of the basic workings on the [Netgear WGT624](/oldwiki/openwrtdocs/hardware/netgear/wgt624 "oldwiki:openwrtdocs:hardware:netgear:wgt624") page.)
- NetBoot - the standard loader in DWL7100AP allows to boot firmware image via network from TFTP server direct to RAM
- ThreadX - D-Link uses OS called ThreadX on lowend 1MiB Flash storage &amp; 8MiB RAM models. They have custom boot loader that doesn't output anything sensible to serial port but does have recovery mode so you can upload firmware using browser.

## Bootloader Pages

- [ADAM2](/docs/techref/bootloader/adam2 "docs:techref:bootloader:adam2")
- [ARMBoot](/docs/techref/bootloader/armboot "docs:techref:bootloader:armboot")
- [Breed](/docs/techref/bootloader/breed "docs:techref:bootloader:breed")
- [brnboot](/docs/techref/bootloader/brnboot "docs:techref:bootloader:brnboot")
- [CFE](/docs/techref/bootloader/cfe "docs:techref:bootloader:cfe")
- [Changing CFE defaults](/docs/techref/bootloader/cfe/changing.defaults "docs:techref:bootloader:cfe:changing.defaults")
- [EVA](/docs/techref/bootloader/eva "docs:techref:bootloader:eva")
- [kboot](/docs/techref/bootloader/kboot "docs:techref:bootloader:kboot")
- [kwboot](/docs/techref/bootloader/kwboot "docs:techref:bootloader:kwboot")
- [MyLoader](/docs/techref/bootloader/myloader "docs:techref:bootloader:myloader")
- [pepe2k-u-boot\_mod](/docs/techref/bootloader/pepe2k "docs:techref:bootloader:pepe2k")
- [PP Boot](/docs/techref/bootloader/pp_boot "docs:techref:bootloader:pp_boot")
- [PSPBoot](/docs/techref/bootloader/pspboot "docs:techref:bootloader:pspboot")
- [RealTek](/docs/techref/bootloader/realtek "docs:techref:bootloader:realtek")
- [RedBoot](/docs/techref/bootloader/redboot "docs:techref:bootloader:redboot")
- [RouterBOOT](/docs/techref/bootloader/routerboot "docs:techref:bootloader:routerboot")
- [Das U-Boot](/docs/techref/bootloader/uboot "docs:techref:bootloader:uboot")
- [Das U-Boot Environment](/docs/techref/bootloader/uboot.config "docs:techref:bootloader:uboot.config")
- [YAMON](/docs/techref/bootloader/yamon "docs:techref:bootloader:yamon")
