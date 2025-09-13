# Debrick ath79 using JTAG

Since with [this commit](http://openocd.zylin.com/gitweb?p=openocd.git%3Ba%3Dcommitdiff%3Bh%3D6b9d19d3675a82ccc501fd7cba036c5b04d04590 "http://openocd.zylin.com/gitweb?p=openocd.git;a=commitdiff;h=6b9d19d3675a82ccc501fd7cba036c5b04d04590") and [this fix](http://openocd.zylin.com/gitweb?p=openocd.git%3Ba%3Dcommitdiff%3Bh%3D1025be363e2bf42f1613083223a2322cc3a9bd4c "http://openocd.zylin.com/gitweb?p=openocd.git;a=commitdiff;h=1025be363e2bf42f1613083223a2322cc3a9bd4c") now OpenOCD program support SPI driver for ATH79 SoCs.

*This means, that you do NOT need to patch the OpenOCD program for support the ath79-spi driver. However, you may need to change the /openocd/src/flash/nor/spi.c source file for support your NOR-flash chip with specific JEDEC ID.*

Supported SoCs: **AR71xx**, **AR91xx**, **AR724x**, **AR93xx**, **QCA95xx**.

Unlike the [method](/ru/toh/tp-link/tl-mr3420/debrick.using.jtag "ru:toh:tp-link:tl-mr3420:debrick.using.jtag") with initializing a processor and memory - this method is more functional because You do not need to look for special registers for a specific SoC. The OpenOCD program will be use the SPI-chip directly. Therefore, this method is good for the recovery of data on flash with any processor of the ath79 family where there is → [JTAG port](/docs/techref/hardware/port.jtag "docs:techref:hardware:port.jtag").

Pinout [EJTAG v3.1](http://www.linux-mips.org/wiki/JTAG "http://www.linux-mips.org/wiki/JTAG") port on ath79 looks like this:

EJTAG on DIR-615 Ex EJTAG on TL-WR1043ND [![ASCII](/_media/media/dlink/dir-615/e4-photos/d-link.dir-615e4-jtag.jpg?w=400&tok=445e53 "ASCII")](/_detail/media/dlink/dir-615/e4-photos/d-link.dir-615e4-jtag.jpg?id=docs%3Aguide-user%3Ahardware%3Adebrick.ath79.using.jtag "media:dlink:dir-615:e4-photos:d-link.dir-615e4-jtag.jpg") [![tl-wr1043nd_serial.jpg](/_media/media/tplink/tl-wr1043/tl-wr1043nd_serial.jpg?w=400&tok=aca19b "tl-wr1043nd_serial.jpg")](/_detail/media/tplink/tl-wr1043/tl-wr1043nd_serial.jpg?id=docs%3Aguide-user%3Ahardware%3Adebrick.ath79.using.jtag "media:tplink:tl-wr1043:tl-wr1043nd_serial.jpg")

Using **nSRST** (**RST**) pin - in the case of damage the bootloader this pin is optional. Even more, on the Atheros SoC, it not only resets SoC also it resets the TAP controller.  
In the case your bootloader **is not damaged** the JTAG on router may **not work** at all, because during the boot process, in the bootloader, JTAG can be disabled and configured for GPIOs or other stuff.  
Limit only in that, does support your NOR-flash chip by OpenOCD program or not. If not - you can manual add support of your NOR-flash chip in program at the stage of compiling the program.

## How to Build

For build the program I use Linux (Ubuntu) and [this guide](http://shukra.cedt.iisc.ernet.in/edwiki/EmSys:Compiling_OpenOCD_v0.8.0_Linux "http://shukra.cedt.iisc.ernet.in/edwiki/EmSys:Compiling_OpenOCD_v0.8.0_Linux") or [this guide](http://airsupplylab.com/index.php/learn/12-embedded/12-how-to-install-openocd-v0-8-0 "http://airsupplylab.com/index.php/learn/12-embedded/12-how-to-install-openocd-v0-8-0"):

```
sudo apt-get update
sudo apt-get install libtool automake libusb-1.0 git
git clone git://openocd.git.sourceforge.net/gitroot/openocd/openocd
cd ~/openocd
git pull
./bootstrap
```

***Note:** I use a short version of the packages installation for Ubuntu to support OpenOCD because I only need the parallel port.*

The next step configures support of program OpenOCD specific interfaces, for more help, see “./configure -help” option.  
Most likely you will need to use other options for your JTAG-interface. For example, I'll use ([Wiggler parallel port JTAG adapter](http://ciclamab.altervista.org/hard_corpo_jtag.htm "http://ciclamab.altervista.org/hard_corpo_jtag.htm")) and here my options:

```
./configure --enable-maintainer-mode --disable-werror --disable-shared --enable-parport --enable-parport_ppdev
```

***Note:** Besides in my case, I compile with `“--disable-werror”` option because I have Warning messages, otherwise it will be have error at the stage of compiling the program.*

Before we `make` and `install` the program, what you should do next is located in the file /openocd/src/flash/nor/spi.c of source - you must find name of your NOR-flash chip in this list. If your chip not listed, then go to [this point](/docs/guide-user/hardware/debrick.ath79.using.jtag#unknown_flash_device "docs:guide-user:hardware:debrick.ath79.using.jtag"), okay, now make it:

```
make
sudo make install
```

### Supported NOR-flash chips by default (02.06.17)

```
	...
	/* name, erase_cmd, chip_erase_cmd, device_id, pagesize, sectorsize, size_in_bytes */
	FLASH_ID("st m25p05",      0xd8, 0xc7, 0x00102020, 0x80,  0x8000,  0x10000),
	FLASH_ID("st m25p10",      0xd8, 0xc7, 0x00112020, 0x80,  0x8000,  0x20000),
	FLASH_ID("st m25p20",      0xd8, 0xc7, 0x00122020, 0x100, 0x10000, 0x40000),
	FLASH_ID("st m25p40",      0xd8, 0xc7, 0x00132020, 0x100, 0x10000, 0x80000),
	FLASH_ID("st m25p80",      0xd8, 0xc7, 0x00142020, 0x100, 0x10000, 0x100000),
	FLASH_ID("st m25p16",      0xd8, 0xc7, 0x00152020, 0x100, 0x10000, 0x200000),
	FLASH_ID("st m25p32",      0xd8, 0xc7, 0x00162020, 0x100, 0x10000, 0x400000),
	FLASH_ID("st m25p64",      0xd8, 0xc7, 0x00172020, 0x100, 0x10000, 0x800000),
	FLASH_ID("st m25p128",     0xd8, 0xc7, 0x00182020, 0x100, 0x40000, 0x1000000),
	FLASH_ID("st m45pe10",     0xd8, 0xd8, 0x00114020, 0x100, 0x10000, 0x20000),
	FLASH_ID("st m45pe20",     0xd8, 0xd8, 0x00124020, 0x100, 0x10000, 0x40000),
	FLASH_ID("st m45pe40",     0xd8, 0xd8, 0x00134020, 0x100, 0x10000, 0x80000),
	FLASH_ID("st m45pe80",     0xd8, 0xd8, 0x00144020, 0x100, 0x10000, 0x100000),
	FLASH_ID("sp s25fl004",    0xd8, 0xc7, 0x00120201, 0x100, 0x10000, 0x80000),
	FLASH_ID("sp s25fl008",    0xd8, 0xc7, 0x00130201, 0x100, 0x10000, 0x100000),
	FLASH_ID("sp s25fl016",    0xd8, 0xc7, 0x00140201, 0x100, 0x10000, 0x200000),
	FLASH_ID("sp s25fl116k",   0xd8, 0xc7, 0x00154001, 0x100, 0x10000, 0x200000),
	FLASH_ID("sp s25fl032",    0xd8, 0xc7, 0x00150201, 0x100, 0x10000, 0x400000),
	FLASH_ID("sp s25fl132k",   0xd8, 0xc7, 0x00164001, 0x100, 0x10000, 0x400000),
	FLASH_ID("sp s25fl064",    0xd8, 0xc7, 0x00160201, 0x100, 0x10000, 0x800000),
	FLASH_ID("sp s25fl164k",   0xd8, 0xc7, 0x00174001, 0x100, 0x10000, 0x800000),
	FLASH_ID("sp s25fl128",    0xd8, 0xc7, 0x00182001, 0x100, 0x10000, 0x1000000),
	FLASH_ID("sp s25fl256",    0xd8, 0xc7, 0x00190201, 0x100, 0x10000, 0x2000000),
	FLASH_ID("atmel 25f512",   0x52, 0xc7, 0x0065001f, 0x80,  0x8000,  0x10000),
	FLASH_ID("atmel 25f1024",  0x52, 0x62, 0x0060001f, 0x100, 0x8000,  0x20000),
	FLASH_ID("atmel 25f2048",  0x52, 0x62, 0x0063001f, 0x100, 0x10000, 0x40000),
	FLASH_ID("atmel 25f4096",  0x52, 0x62, 0x0064001f, 0x100, 0x10000, 0x80000),
	FLASH_ID("atmel 25fs040",  0xd7, 0xc7, 0x0004661f, 0x100, 0x10000, 0x80000),
	FLASH_ID("mac 25l512",     0xd8, 0xc7, 0x001020c2, 0x010, 0x10000, 0x10000),
	FLASH_ID("mac 25l1005",    0xd8, 0xc7, 0x001120c2, 0x010, 0x10000, 0x20000),
	FLASH_ID("mac 25l2005",    0xd8, 0xc7, 0x001220c2, 0x010, 0x10000, 0x40000),
	FLASH_ID("mac 25l4005",    0xd8, 0xc7, 0x001320c2, 0x010, 0x10000, 0x80000),
	FLASH_ID("mac 25l8005",    0xd8, 0xc7, 0x001420c2, 0x010, 0x10000, 0x100000),
	FLASH_ID("mac 25l1605",    0xd8, 0xc7, 0x001520c2, 0x100, 0x10000, 0x200000),
	FLASH_ID("mac 25l3205",    0xd8, 0xc7, 0x001620c2, 0x100, 0x10000, 0x400000),
	FLASH_ID("mac 25l6405",    0xd8, 0xc7, 0x001720c2, 0x100, 0x10000, 0x800000),
	FLASH_ID("micron n25q064", 0xd8, 0xc7, 0x0017ba20, 0x100, 0x10000, 0x800000),
	FLASH_ID("micron n25q128", 0xd8, 0xc7, 0x0018ba20, 0x100, 0x10000, 0x1000000),
	FLASH_ID("win w25q80bv",   0xd8, 0xc7, 0x001440ef, 0x100, 0x10000, 0x100000),
	FLASH_ID("win w25q32fv",   0xd8, 0xc7, 0x001640ef, 0x100, 0x10000, 0x400000),
	FLASH_ID("win w25q32dw",   0xd8, 0xc7, 0x001660ef, 0x100, 0x10000, 0x400000),
	FLASH_ID("win w25q64cv",   0xd8, 0xc7, 0x001740ef, 0x100, 0x10000, 0x800000),
	FLASH_ID("win w25q128fv",  0xd8, 0xc7, 0x001840ef, 0x100, 0x10000, 0x1000000),
	FLASH_ID("gd gd25q20",     0x20, 0xc7, 0x00c84012, 0x100, 0x1000,  0x80000),
	FLASH_ID("gd gd25q16c",    0xd8, 0xc7, 0x001540c8, 0x100, 0x10000, 0x200000),
	FLASH_ID("gd gd25q32c",    0xd8, 0xc7, 0x001640c8, 0x100, 0x10000, 0x400000),
	FLASH_ID("gd gd25q128c",   0xd8, 0xc7, 0x001840c8, 0x100, 0x10000, 0x1000000),
	FLASH_ID(NULL,             0,    0,	   0,          0,     0,       0)
```

*Also you can manual add your not listed NOR-flash chip in `/openocd/src/flash/nor/spi.c` file of OpenOCD sources.*  
***Note:** That JEDEC ID here in the reversed byte (big-endian) ordering format (for example: `0x001840ef` = `0xef401800`).*

## Using OpenOCD

This part includes a list of programs that will be needed in the process of debugging and recovery through the JTAG interface. Also, this section contains a list of used OpenOCD commands and configuration file for ATH79 SoC's.

- **telnet** console - for linux or **PuTTY** console - for Windows.

<!--THE END-->

- [**ath79.cfg**](#ath79cfg "docs:guide-user:hardware:debrick.ath79.using.jtag ↵") - config. file for the OpenOCD program and your target device (config. file must be copied to OpenOCD your installation folder as the `/usr/local/share/openocd/scripts/target/ath79.cfg`).

<!--THE END-->

- **backup.bin** - conditional bootloader or other fragment of SPI-flash memory data you want to restore.

### Used commands in OpenOCD

```
reset
```

*The example presented in this section, the command is only used as - identify the ID and state of the processor, not more.*

```
halt
```

*Put the processor in debug state (receiving commands from operator).*

```
reset init
```

*After running this command, the script will be executed for this event (enclosed in braces), which is in the config. file (send commands to the processor).*

```
dump_image <filename> <starting address in memory or flash-chip> <size>
```

*This command saves a dump of the memory/flash-chip to the file. Command can be executed before initialize the CPU and memory. To read the flash memory, use the address `0x9f000000`*

```
flash write_image unlock <filename> <starting address in flash-chip>
```

*This command starts writing flash-chip from file at starting address.*

### ath79.cfg

```
# Atheros ATH79 MIPS SoC.
# tested on AP83 and AP99 reference board
#
# source: https://forum.openwrt.org/viewtopic.php?pid=297299#p297299

if { [info exists CHIPNAME] } {
   set _CHIPNAME $CHIPNAME
} else {
   set _CHIPNAME ath79
}

if { [info exists ENDIAN] } {
   set _ENDIAN $ENDIAN
} else {
   set _ENDIAN big
}

if { [info exists CPUTAPID] } {
   set _CPUTAPID $CPUTAPID
} else {
   set _CPUTAPID 0x00000001
}

jtag_ntrst_assert_width 200
jtag_ntrst_delay 1

reset_config trst_only

jtag newtap $_CHIPNAME cpu -irlen 5 -ircapture 0x1 -irmask 0x1f -expected-id $_CPUTAPID

set _TARGETNAME $_CHIPNAME.cpu
target create $_TARGETNAME mips_m4k -endian $_ENDIAN -chain-position $_TARGETNAME

$_TARGETNAME configure -event reset-init {
	# disable flash remap
	mww 0xbf000004 0x43
}

# serial SPI capable flash
# flash bank <driver> <base> <size> <chip_width> <bus_width>
set _FLASHNAME $_CHIPNAME.flash
flash bank $_FLASHNAME ath79 0xbf000000 0x01000000 0 0 $_TARGETNAME
```

### Recovery example

Recovery the bootloader u-boot and art section, on the AR7241 SoC in the Ubuntu operating system. If you need, in the same way, additionally, it is possible to flash the firmware image or fully flash-chip - fullflash.

- After we make and install the OpenOCD program, [ath79.cfg](#ath79cfg "docs:guide-user:hardware:debrick.ath79.using.jtag ↵") config. file must be copied to your OpenOCD installation folder as the `/usr/local/share/openocd/scripts/target/ath79.cfg`

<!--THE END-->

- Connect JTAG to the PC and router (router must be **turned OFF**).

<!--THE END-->

- After that **turn ON** your bricked router.

<!--THE END-->

- Run OpenOCD with next parameters:
  
  ```
  sudo openocd -f interface/parport.cfg -f target/ath79.cfg -c "adapter_khz 6000"
  ```
  
  *If you use a different JTAG adapter, **parport.cfg** name of interface should be changed to the appropriate name of the configuration file for your JTAG adapter. Of course, you have to pre-build OpenOCD program with support this interface.*

#### Working with the program OpenOCD

- Once we have turned ON the router, our target is to detect ID 0x00000001 (standard Atheros CPU identifier):
  
  ```
  ubuntu@ubuntu:~$ sudo openocd -f interface/parport.cfg -f target/ath79.cfg -c "adapter_khz 6000"
  Open On-Chip Debugger 0.10.0-dev-00247-g73b676c-dirty (2016-03-12-07:52)
  Licensed under GNU GPL v2
  For bug reports, read
  	http://openocd.org/doc/doxygen/bugs.html
  Warn : Adapter driver 'parport' did not declare which transports it allows; assuming legacy JTAG-only
  Info : only one transport option; autoselect 'jtag'
  parport port = 0x0
  jtag_ntrst_assert_width: 200
  jtag_ntrst_delay: 1
  trst_only separate trst_push_pull
  adapter speed: 6000 kHz
  Info : clock speed 500 kHz
  Info : JTAG tap: ath79.cpu tap/device found: 0x00000001 (mfg: 0x000 (<invalid>), part: 0x0000, ver: 0x0)
  Info : accepting 'telnet' connection on tcp/4444
  ```
  
  *If you could not identify the ID at once, try to go to the next step and enter “reset” in the telnet console. If the program still does not identify the CPU ID, check the JTAG connection cable for possible errors, as the cause of a problem may lie in the length of the cable used.*

<!--THE END-->

- If everything is successful, run in new shell telnet console or PuTTY at address 127.0.0.1 and port 4444, after connecting to the console should display input prompt:
  
  ```
  ubuntu@ubuntu:~$ telnet localhost 4444
  Trying 127.0.0.1...
  Connected to localhost.
  Escape character is '^]'.
  Open On-Chip Debugger
  > 
  ```
  
  - Next, enter the commands:
    
    ```
    > reset
    JTAG tap: ath79.cpu tap/device found: 0x00000001 (mfg: 0x000 (<invalid>), part: 0x0000, ver: 0x0)
    > 
    ```
    
    *This command does not affect the state of the processor, because we do not use **RST** pin. However, the command once again detects the ID and state of the processor.*
    
    ```
    > halt      
    ath79.cpu: target state: halted
    target halted in MIPS32 mode due to debug-request, pc: 0xbfc03860
    > 
    ```
    
    *This command puts the processor from the state “running” to the state “halted” - in this state, the processor receives commands from operator.*
    
    ```
    > reset init
    JTAG tap: ath79.cpu tap/device found: 0x00000001 (mfg: 0x000 (<invalid>), part: 0x0000, ver: 0x0)
    ath79.cpu: target state: halted
    target halted in MIPS32 mode due to debug-request, pc: 0xbfc03860
    > 
    ```
    
    *Initializing the main script in the [ath79.cfg](#ath79cfg "docs:guide-user:hardware:debrick.ath79.using.jtag ↵") configuration file. In this case, the script commands sent a group of commands (enclosed in braces) for the event `reset init`.*
    
    ```
    > flash probe 0
    read_flash_id: 16311c
    Found flash device 'eon en25f32' (ID 0x0016311c)
    flash 'ath79' found at 0xbf000000
    > 
    ```
    
    *Probing the flash. Detects flash memory identifier, if the flash-chip is not supported by the driver, there will be written.*
    
    ```
    > flash info 0
    #0 : ath79 at 0xbf000000, size 0x00400000, buswidth 0, chipwidth 0
    	#  0: 0x00000000 (0x10000 64kB) protected
    	#  1: 0x00010000 (0x10000 64kB) protected
    	#  2: 0x00020000 (0x10000 64kB) protected
    	#  3: 0x00030000 (0x10000 64kB) protected
    	#  4: 0x00040000 (0x10000 64kB) protected
    	#  5: 0x00050000 (0x10000 64kB) protected
    	#  6: 0x00060000 (0x10000 64kB) protected
    	#  7: 0x00070000 (0x10000 64kB) protected
    	#  8: 0x00080000 (0x10000 64kB) protected
    	#  9: 0x00090000 (0x10000 64kB) protected
    	# 10: 0x000a0000 (0x10000 64kB) protected
    	# 11: 0x000b0000 (0x10000 64kB) protected
    	# 12: 0x000c0000 (0x10000 64kB) protected
    	# 13: 0x000d0000 (0x10000 64kB) protected
    	# 14: 0x000e0000 (0x10000 64kB) protected
    	# 15: 0x000f0000 (0x10000 64kB) protected
    	# 16: 0x00100000 (0x10000 64kB) protected
    	# 17: 0x00110000 (0x10000 64kB) protected
    	# 18: 0x00120000 (0x10000 64kB) protected
    	# 19: 0x00130000 (0x10000 64kB) protected
    	# 20: 0x00140000 (0x10000 64kB) protected
    	# 21: 0x00150000 (0x10000 64kB) protected
    	# 22: 0x00160000 (0x10000 64kB) protected
    	# 23: 0x00170000 (0x10000 64kB) protected
    	# 24: 0x00180000 (0x10000 64kB) protected
    	# 25: 0x00190000 (0x10000 64kB) protected
    	# 26: 0x001a0000 (0x10000 64kB) protected
    	# 27: 0x001b0000 (0x10000 64kB) protected
    	# 28: 0x001c0000 (0x10000 64kB) protected
    	# 29: 0x001d0000 (0x10000 64kB) protected
    	# 30: 0x001e0000 (0x10000 64kB) protected
    	# 31: 0x001f0000 (0x10000 64kB) protected
    	# 32: 0x00200000 (0x10000 64kB) protected
    	# 33: 0x00210000 (0x10000 64kB) protected
    	# 34: 0x00220000 (0x10000 64kB) protected
    	# 35: 0x00230000 (0x10000 64kB) protected
    	# 36: 0x00240000 (0x10000 64kB) protected
    	# 37: 0x00250000 (0x10000 64kB) protected
    	# 38: 0x00260000 (0x10000 64kB) protected
    	# 39: 0x00270000 (0x10000 64kB) protected
    	# 40: 0x00280000 (0x10000 64kB) protected
    	# 41: 0x00290000 (0x10000 64kB) protected
    	# 42: 0x002a0000 (0x10000 64kB) protected
    	# 43: 0x002b0000 (0x10000 64kB) protected
    	# 44: 0x002c0000 (0x10000 64kB) protected
    	# 45: 0x002d0000 (0x10000 64kB) protected
    	# 46: 0x002e0000 (0x10000 64kB) protected
    	# 47: 0x002f0000 (0x10000 64kB) protected
    	# 48: 0x00300000 (0x10000 64kB) protected
    	# 49: 0x00310000 (0x10000 64kB) protected
    	# 50: 0x00320000 (0x10000 64kB) protected
    	# 51: 0x00330000 (0x10000 64kB) protected
    	# 52: 0x00340000 (0x10000 64kB) protected
    	# 53: 0x00350000 (0x10000 64kB) protected
    	# 54: 0x00360000 (0x10000 64kB) protected
    	# 55: 0x00370000 (0x10000 64kB) protected
    	# 56: 0x00380000 (0x10000 64kB) protected
    	# 57: 0x00390000 (0x10000 64kB) protected
    	# 58: 0x003a0000 (0x10000 64kB) protected
    	# 59: 0x003b0000 (0x10000 64kB) protected
    	# 60: 0x003c0000 (0x10000 64kB) protected
    	# 61: 0x003d0000 (0x10000 64kB) protected
    	# 62: 0x003e0000 (0x10000 64kB) protected
    	# 63: 0x003f0000 (0x10000 64kB) protected
    
    SMI flash information:
      Device 'eon en25f32' (ID 0x0016311c)
    
    > 
    ```
    
    *Where first two sectors (#0,#1) is **uboot** and last sector (#63) is **art** partition (for 4MByte flash and TP-LINK platform).*
    
    ```
    > dump_image uboot.bin 0x9f000000 0x20000  
    dumped 131072 bytes in 88.281433s (1.450 KiB/s)
    > dump_image art.bin 0x9f3f0000 0x10000    
    dumped 65536 bytes in 47.600506s (1.345 KiB/s)
    > 
    ```
    
    *Buckup **uboot** and **art** partition.*
    
    ```
    > flash write_image unlock uboot.bin 0xbf000000
    auto unlock enabled
    writing 256 bytes to flash page @0x00000000
    writing 256 bytes to flash page @0x00000100
    writing 256 bytes to flash page @0x00000200
    writing 256 bytes to flash page @0x00000300
    writing 256 bytes to flash page @0x00000400
    writing 256 bytes to flash page @0x00000500
    ...
    writing 256 bytes to flash page @0x0001ef00
    writing 256 bytes to flash page @0x0001f000
    writing 256 bytes to flash page @0x0001fb00
    writing 256 bytes to flash page @0x0001fc00
    writing 256 bytes to flash page @0x0001fd00
    writing 256 bytes to flash page @0x0001fe00
    wrote 131072 bytes from file uboot.bin in 1968.353027s (0.065 KiB/s)
    ```
    
    *Writing flash at base (bank) flash address.*  
    **Note:** This is not very high Write speed because I use the [old JTAG adapter](/docs/techref/hardware/port.jtag.cable.buffered "docs:techref:hardware:port.jtag.cable.buffered") (500KHz).

## Problems

### Unknown flash device

```
> flash probe 0
read_flash_id: 16311c
Unknown flash device (ID 0x0016311c)
in procedure 'flash'
> 
```

Solution: You can add manual support for your flash-chip by editing `/openocd/src/flash/nor/spi.c` file of OpenOCD sources.

Read datasheet for your SPI NOR flash-chip(search by name of flash on package), in datasheet you can find necessary registers for the driver. Or copy it from [other driver](http://fossies.org/linux/qemu/hw/block/m25p80.c "http://fossies.org/linux/qemu/hw/block/m25p80.c").  
**Note:** That JEDEC ID here in the reversed byte (big-endian) ordering format (for example: `0x0016311c` = `0x1c311600`).

### Error: JTAG scan chain interrogation failed: all ones

```
ubuntu@ubuntu:~/openocd$ sudo openocd -f interface/parport.cfg -f target/ath79.cfg -c "adapter_khz 6000"
Open On-Chip Debugger 0.10.0-dev-00247-g73b676c-dirty (2016-03-12-07:52)
Licensed under GNU GPL v2
For bug reports, read
	http://openocd.org/doc/doxygen/bugs.html
Warn : Adapter driver 'parport' did not declare which transports it allows; assuming legacy JTAG-only
Info : only one transport option; autoselect 'jtag'
parport port = 0x0
jtag_ntrst_assert_width: 200
jtag_ntrst_delay: 1
trst_only separate trst_push_pull
adapter speed: 6000 kHz
Info : clock speed 500 kHz
Error: JTAG scan chain interrogation failed: all ones
Error: Check JTAG interface, timings, target power, etc.
Error: Trying to use configured scan chain anyway...
Error: ath79.cpu: IR capture error; saw 0x1f not 0x01
Warn : Bypassing JTAG setup events due to errors
```

Solution: Check the JTAG connection cable for possible errors, Check TDO signal

When TDO is connected to the JTAG adapter the signal must return to 3.3V in rest. Optionally add a 10kΩ pullup resistor to 3V3 (between pins TDO and VCC 3V3).

## Forum discussion and source

[https://forum.openwrt.org/viewtopic.php?id=34993](https://forum.openwrt.org/viewtopic.php?id=34993 "https://forum.openwrt.org/viewtopic.php?id=34993")
