# PP Boot

This is propietary bootloader with no open sources.

All trails point to Conexant as owner.

There are known evolutions of this PP boot, v1.5, v5.09... but little documentation in general.

## PP Boot v1.5

PP Boot v1.5 seems to be unique to the Conexant Solos CX946xx board as used in the Linksys [WAG54G2](/toh/linksys/wag54g2 "toh:linksys:wag54g2"), [Xavi 7968](https://oldwiki.archive.openwrt.org/toh/xavi/xavi_7968 "https://oldwiki.archive.openwrt.org/toh/xavi/xavi_7968"), DG834, Billion 7402XL and some others.

However, the behaviour and look of pp-boot seems to change depending on the vendor. For instance, Xavi pp-boot seems to have ethernet uploading cancelled, which prevents firmware replacement.

On the contrary, routers WAG54G2, DG834 and Billion 7402XL have a recovery tool, allowing replacement of working firmware via pp-boot.

Preliminary investigation shows that the default config of PP Boot simply tries to boot the kernel at rom offset 0x20000.

### Commands

Boot can be interrupted and a console entered by pressing space on the serial console (usually 38400 bauds) early in the boot sequence.

Pressing help or ? will pop the following text:

```
Commands to the console are:
 configeeprom             display EEPROM configuration information
 configflash              display FLASH configuration information
        mac <address>               set MAC address
        networkboot {yes | auto}    boot auto-select Ethernet, USB or PCI
        networkboot ethernet        boot from Ethernet only
        networkboot usb             boot from USB only
        networkboot pci             boot from PCI only
        networkboot no              boot from FLASH
        networkboot ask             always prompt user for boot source
        copyimages {yes | no}       copy network booted image files
        flashfs {auto | emergency}  use automatic FLASHFS selection or
                                    force boot from emergency FLASHFS
        flashnetboot {yes | no}     flash boots auto network boots
        autolanrecover {yes | no}   attempt LAN recovery if flash corrupt
        initialise                  initialise configuration information
        listenv                     list environment variables
        setenv <key> <value>        set environment variable
        unsetenv <key>              unset environment variable
        pda read                    read PDA information
 configpci                          display EEPROM PCI configuration
 configpci set <idx> <addr> <data>  set PCI pair
 dw <address> [<length>]  dump words (hex/ascii)
 enter <address>          enter an image
 erw <wrdaddress>         read a single word from EEPROM
 eww <wrdaddress> <value> write a single word to EEPROM
 fdw <address> [<length>] dump flash words (hex/ascii)
 flash config             print flash configuration
 help                     print this text
 netboot [recover]        perform immediate network boot [in recovery mode]
 quit                     leave the console
 reset                    reset system
 rw <address>             read a single word
 why                      reason for console entry
 ww <address> <value>     write a single word
 xmodem [fast]            download mkflash image using X-Modem
```

### Structure

Taken from [Edimax](http://www.edimax.com/images/Image/OpenSourceCode/Wireless/Router/AR-7284WnA/AR-7284WnA&B_SDK_6222.tar.zip "http://www.edimax.com/images/Image/OpenSourceCode/Wireless/Router/AR-7284WnA/AR-7284WnA&B_SDK_6222.tar.zip") sources, the following code checks the integrity of a working pp-boot 1.5 binary (and enlightens us with its structure):

```
//       This reads the flash boot program from flash. This program needs
//       to comprehend the format that mkflash has built the flash in.
//       This is
//
//       Word 0: NP boot length in words (b)
//       Word 1: First word of NP boot
//       :
//       Word b:Last word of NP boot
//       Word b + 1: NP boot checksum
//       Word b + 2: Number of unused words (u)
//       :
//       Word b + u + 3: PP boot length (p)
//       Word b + u + 4: First word of PP boot
//       :
//       Word b + u + p + 3:Last word of PP boot
//       Word b + u + p + 4: Number of unused words (v)
//       :
//       Word b + u + p + v + 4: Configuration Information 
```

#### DISCLAIMER!

The following data is a proposal that hasn't be tested yet. Analysing the code of [Edimax](http://www.edimax.com/images/Image/OpenSourceCode/Wireless/Router/AR-7284WnA/AR-7284WnA&B_SDK_6222.tar.zip "http://www.edimax.com/images/Image/OpenSourceCode/Wireless/Router/AR-7284WnA/AR-7284WnA&B_SDK_6222.tar.zip") sources, this is the booting sequence of a Conexant 94610:

1. Reading of flash 0x38000000 word 0: Amount of words (b) that will be copied to cache 0x50000000
2. Automatic copy from flash (0x3800000 + 1) → (0x38000000 + b) to cache
3. Executing cache at 0x50000000

The NPboot is a piece of code compiled at cache address 0x50000000 that makes the first set-up, including SDRAM access. Because it must fit the cache, its size is very small, below 4kb.

After it, the same code has to jump back to the flash at (0x38000000 + b +1) and then continue booting sequence. This latter would be the place for u-boot as an example.
