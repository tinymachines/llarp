# EVA

EVA is a proprietary bootloader by AVM, based on [ADAM2](/docs/techref/bootloader/adam2 "docs:techref:bootloader:adam2").

## Examples

### Unknown AVM device(running FritzOS v6.03)

```
ROM VER: 1.1.3
CFG 01

(AVM) EVA Revision: 1.1322 Version: 2322
(C) Copyright 2005 AVM Date: Dec 16 2011 Time: 14:45:22 (1) 2 0x0-0x341D
```

### Fritzbox 7490 (running FritzOS v6.83)

```
ROM VER: 1.1.4
CFG 05
<E7>$^@^ADC! <A4><A5><84><84>DC[/]

(AVM) EVA Revision: 1.1964 Version: 2964
(C) Copyright 2005 AVM Date: Nov 27 2013 Time: 14:33:10 (0) 3 0x0-0x740D
```

##### Commands available

```
     Commands   Description
     --------   -----------
         help   help
           dm   dump mem 32 Bit <addr> <range>
           cm   change mem 32 Bit <addr> <value>
           dh   dump mem 16 Bit <addr> <range>
           ch   change mem 16 Bit <addr> <value>
           db   dump mem 8 Bit <addr> <range>
           cb   change mem 8 Bit <addr> <value>
           sn   scan nand
        erase   Erase Flash <mtd>
     printenv   print Env. Variables
      restart   reboot Device
       setenv   set Env. variable <var> <value>
     unsetenv   unset Env. variable <var>
           go   load & start kernel from mtd1
       setmac   set mac addresses <addr> (like 12:23:40)
    mdio-read   read 16-Bit mdio value
   mdio-write   write 16-Bit mdio value
```

##### printenv

```
Eva_AVM >printenv

HWRevision            185
HWSubRevision         6
ProductID             Fritz_Box_HW185
SerialNumber          0000000000000000
annex                 A
autoload              yes
bootloaderVersion     1.1964
bootserport           tty0
country               061
cpufrequency          500000000
firstfreeaddress      0x81116240
firmware_info         113.06.83
firmware_version      avme
flashsize             nor_size=0MB sflash_size=1024KB nand_size=512MB
language              en
linux_fs_start        1
maca                  38:10:D5:xx:xx:xC
macb                  38:10:D5:xx:xx:xD
macwlan               38:10:D5:xx:xx:xE
macwlan2              38:10:D5:xx:xx:xF
macdsl                38:10:D5:xx:xx:x0
memsize               0x10000000
modetty0              38400,n,8,1,hw
modetty1              38400,n,8,1,hw
mtd0                  0x400000,0x3400000
mtd1                  0x0,0x400000
mtd2                  0x0,0x40000
mtd3                  0x40000,0xA0000
mtd4                  0xA0000,0x100000
mtd5                  0x0,0x200000
my_ipaddress          192.168.178.1
prompt                Eva_AVM
req_fullrate_freq     250000000
sysfrequency          250000000
tr069_passphrase      xxxxxxxxxxxxxxxx
tr069_serial          00040E-3810D5B042DC
urlader-version       2964
usb_board_mac         38:10:D5:xx:xx:xx
usb_device_id         0x0000
usb_device_name       USB DSL Device
usb_manufacturer_name  AVM
usb_revision_id       0x0000
usb_rndis_mac         38:10:D5:xx:xx:xx
wlan_key              xxxxxxxxxxxxxxxxxxxxxxxx
```
