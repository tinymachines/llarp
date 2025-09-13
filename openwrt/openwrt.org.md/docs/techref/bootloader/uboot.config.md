# Das U-Boot Environment

Das U-Boot uses a small amount of space on the flash storage usually on the same partition it is stored on to store some important configuration parameters. This can hardly be compared to NVRAM/TFFS-approach of other bootloaders. It is called the *u-boot environment*. It stores some values like the IP address of the TFTP server (on your PC) to which the the TFTP client (part of U-Boot) will try to connect, etc.

You can read and write these values when you are connected to the *U-Boot console* via [Serial Port](/docs/techref/hardware/port.serial "docs:techref:hardware:port.serial") and also from the CLI once you booted OpenWrt.

One of the huge advantages of [Das U-Boot](/docs/techref/bootloader/uboot "docs:techref:bootloader:uboot") is its ability for run time configuration. This flexibility is based on being able to easily change environment variables. The environment is usually at the end of the uboot [partition](/docs/techref/flash.layout "docs:techref:flash.layout"). The *environment variables* are set up in a board specific file, e.g. `package/uboot-ar71xx/files/include/configs/nbg460n.h` for the [Zyxel NBG 460N/550N/550NH](/toh/zyxel/nbg460n "toh:zyxel:nbg460n").

The location on the flash partition is predefined:

```
#define CONFIG_ENV_OFFSET                 0x0000
#define CONFIG_ENV_SIZE                   0x2000
```

and copied to RAM when U-Boot starts.

![](/_media/meta/icons/tango/dialog-information.png) The U-Boot Environment is protected by a [CRC32](https://en.wikipedia.org/wiki/Cyclic%20redundancy%20check "https://en.wikipedia.org/wiki/Cyclic redundancy check") checksum.  
See [Warning - bad CRC, using default environment](https://web.archive.org/web/20211024121026/http://www.denx.de/wiki/view/DULG/WarningBadCRCUsingDefaultEnvironment "https://web.archive.org/web/20211024121026/http://www.denx.de/wiki/view/DULG/WarningBadCRCUsingDefaultEnvironment")

[Content of linked page 'Warning - bad CRC, using default environment'](#folded_5e79f269c60d0ea14f29ea1037efe181_1)

**Question:**

I have ported U-Boot to a custom board. It seems to boot OK, but it prints:  
`Warning - bad CRC, using default environment`  
Why?

**Answer:**

Most probably everything is OK. The message is printed because the flash sector or ERPROM containing the environment variables has never been initialized yet. The message will go away as soon as you save the envrionment variables using the `saveenv` command.

## Common variables

→ [http://www.denx.de/wiki/view/DULG/UBootEnvVariables](http://www.denx.de/wiki/view/DULG/UBootEnvVariables "http://www.denx.de/wiki/view/DULG/UBootEnvVariables")  
This lists the most important environment variables, all of which have a special meaning to U-Boot.

`Variable` Description `autoload` if set to `no` (or any string beginning with 'n'), the `rarpb`, `bootp` or `dhcp` commands will perform only a configuration lookup from the BOOTP / DHCP server, but not try to load any image using [TFTP](https://en.wikipedia.org/wiki/Trivial%20File%20Transfer%20Protocol "https://en.wikipedia.org/wiki/Trivial File Transfer Protocol"). `autostart` if set to `yes`, an image loaded using the `rarpb`, `bootp`, `dhcp`, `tftp`, `disk`, or `docb` commands will be automatically started (by internally calling the `bootm` command). `baudrate` a decimal number that selects the console baudrate (in bps). `bootargs` The contents of this variable are passed to the Linux kernel as boot arguments (aka “command line”). `bootcmd` This variable defines a command string that is automatically executed when the initial countdown is not interrupted. This command is only executed when the variable bootdelay is also defined! `bootdelay` After reset, U-Boot will wait this number of seconds before it executes the contents of the bootcmd variable. During this time a countdown is printed, which can be interrupted by pressing any key.  
Set this variable to 0 boot without delay. Be careful: depending on the contents of your `bootcmd` variable, this can prevent you from entering interactive commands again forever!  
Set this variable to -1 to disable autoboot. `bootfile` name of the default image to load with TFTP `ethaddr` Ethernet MAC address for first/only ethernet interface (`eth0` in Linux).  
This variable can be set only once (usually during manufacturing of the board). U-Boot refuses to delete or overwrite this variable once it has been set. `ipaddr` IP address; needed for `tftp` command `loadaddr` Default load address for commands like `tftp` or `loads` `serverip` TFTP server IP address; needed for `tftp` command. `silent` If the configuration option `CONFIG_SILENT_CONSOLE` has been enabled for your board, setting this variable to any value will suppress all console messages. Please see [silent\_booting](/silent_booting "silent_booting") for details. `verify` If set to `n` or `no` disables the checksum calculation over the complete image in the `bootm` command to trade speed for safety in the boot process. Note that the header checksum is still verified.

## Accessing U-Boot environment variables in Serial Console

- [Serial Console](/docs/techref/hardware/port.serial "docs:techref:hardware:port.serial")
- → [http://www.denx.de/wiki/view/DULG/UBoot](http://www.denx.de/wiki/view/DULG/UBoot "http://www.denx.de/wiki/view/DULG/UBoot")
  
  - → [5.9. U-Boot Command Line Interface](http://www.denx.de/wiki/view/DULG/UBootCommandLineInterface "http://www.denx.de/wiki/view/DULG/UBootCommandLineInterface")

### Examining env var in U-Boot

```
printenv ipaddr hostname netmask
ipaddr=192.168.0.2
hostname=openwrt
netmask=255.255.255.0
print bootdelay
bootdelay=1
print serverip
serverip=192.168.0.5
```

### Setting env var in U-Boot

```
set bootcmd 'tftp 0x1000000 uImage548; bootm'
set ipaddr 176.16.15.14
print ipaddr
ipaddr=176.16.15.14
dhcp
start Auto negotiation... (take ~2sec)
Auto negotiation complete, 1000BaseT, full duplex
BOOTP broadcast 1
DHCP client bound to address 176.16.15.14
print serverip
serverip=176.16.15.1
set serverip 176.16.15.254
```

### Removing an env var in U-Boot

```
set foo 'tftp 0x1000000 uImage123; bootm'
print foo
tftp 0x1000000 uImage123; bootm
set foo
print foo
## Error: "foo" not defined
```

### Saving changes to the environment back to flash in U-Boot

![:!:](/lib/images/smileys/exclaim.svg) [All changes you make to the U-Boot environment are made in RAM only](http://www.denx.de/wiki/view/DULG/UBootCmdGroupEnvironment "http://www.denx.de/wiki/view/DULG/UBootCmdGroupEnvironment")! If you want to additionally make your changes permanent you have to use the `saveenv` command to write a copy of the environment settings from RAM to persistent storage.

```
set foo 'tftp 0x1000000 uImage123; bootm'
print foo
saveenv
reset
[...]
print foo
tftp 0x1000000 uImage123; bootm
set foo
saveenv
reset
[...]
print foo
## Error: "foo" not defined
```

## Accessing U-Boot environment variables in Net Console

- ![FIXME](/lib/images/smileys/fixme.svg) → [https://forum.openwrt.org/viewtopic.php?pid=142707#p142707](https://forum.openwrt.org/viewtopic.php?pid=142707#p142707 "https://forum.openwrt.org/viewtopic.php?pid=142707#p142707")

## Accessing U-Boot environment variables in OpenWrt

The relevant tools to manipulate the U-Boot environment are contained in the `opkg`-package `uboot-envtools`.

Package Version Depends Size Description uboot-envtools 20081215-2 zlib 7843 This package includes tools to read (`fw_printenv`) and modify (`fw_setenv`) U-Boot bootloader environment.

However there are several steps to be able to use the above commands effectively. First of all you must tell the `fw_*` tools where the U-Boot environment is located.

Also, the bootloader partition will likely be mounted read-only and one must change this somehow. An example on how to change this, is here: [TL-WR1043ND - Making bootloader partition writable](/toh/tp-link/tl-wr1043nd#making_bootloader_partition_writable "toh:tp-link:tl-wr1043nd")

You need to install and configure `uboot-envtools`:

```
opkg install uboot-envtools
vi /etc/fw_env.config
```

```
# Configuration file for fw_(printenv/saveenv) utility.
# Up to two entries are valid, in this case the redundant
# environment sector is assumed present.
# Notice, that the "Number of sectors" is ignored on NOR and SPI-dataflash.
# Futhermore, if the Flash sector size is ommitted, this value is assumed to
# be the same as the Environment size, which is valid for NOR and SPI-dataflash
 
# NOR example
# MTD device name	Device offset	Env. size	Flash sector size	Number of sectors
/dev/mtd1		0x0000		0x2000		0x10000
/dev/mtd2 		0x0000		0x4000		0x4000
 
# MTD SPI-dataflash example
# MTD device name	Device offset	Env. size	Flash sector size	Number of sectors
#/dev/mtd5		0x4200		0x4200
#/dev/mtd6		0x4200		0x4200
 
# NAND example
#/dev/mtd0		0x4000		0x4000		0x20000			2
```

To determine these values please read the documentation file in the U-boot Source Code: [/tools/env/README](http://git.denx.de/?p=u-boot.git%3Ba%3Dblob_plain%3Bf%3Dtools%2Fenv%2FREADME%3Bhb%3DHEAD "http://git.denx.de/?p=u-boot.git;a=blob_plain;f=tools/env/README;hb=HEAD") A tentative example of making such a configuration is in [Example of configuring uboot-envtools](#example_of_configuring_uboot-envtools "docs:techref:bootloader:uboot.config ↵")

### Examining env var from OpenWrt

Example:

```
root@openwrt:~# fw_printenv
baudrate=115200
loads_echo=0
ipaddr=169.254.123.123
serverip=169.254.254.254
rootpath=/mnt/ARM_FS/
netmask=255.255.0.0
run_diag=yes
console=console=ttyS0,115200
CASset=min
MALLOC_len=1
ethprime=egiga0
bootargs_root=root=/dev/mtdblock2 ro
ethmtu=1500
usb0Mode=host
nandEcc=1bit
ethact=egiga0
ethaddr=00:10:75:xx:xx:xx
cesvcid=6UQX37NNJL85RGNQ5RKCBM5DDN
ceserialno=2GEP09HS
ceboardver=REDSTONE:1.0
bootcmd=nand read.e 0x800000 0x100000 0x300000; setenv bootargs $(console) $(bootargs_root); bootm 0x800000
arcNumber=2097
stdin=serial
stdout=serial
stderr=serial
mainlineLinux=yes
enaMonExt=no
enaCpuStream=no
enaWrAllo=no
pexMode=RC
disL2Cache=no
setL2CacheWT=yes
disL2Prefetch=yes
enaICPref=yes
enaDCPref=yes
sata_dma_mode=yes
netbsd_en=no
vxworks_en=no
bootdelay=3
disaMvPnp=no
Environment size: 778/131068 bytes
```

In above example the boot partition is 2x64KiB ins size, but the booloader console only reports 131068 Bytes which is 4 Bytes short. How can this be? This could be CRC32 value. Furthermore we see, the environment occupies 778Bytes! Now we guess, the environment is located at the end of the partition and the CRC32 is again behind it. So it's offset should be, hmm, hmm, 131.068-778=130.290 and minus 1 because we count the zeros = 130.289 in hex 0x0001FCF1. Let's do a [backup](/docs/guide-user/installation/generic.backup "docs:guide-user:installation:generic.backup") and look at the content of the whole partition with help of a [hex editor](https://en.wikipedia.org/wiki/hex%20editor "https://en.wikipedia.org/wiki/hex editor"). The assumption was obviously wrong. At the end, there is only FF data at the end.

- `/uboot.source.code/tools/env/README`
- [Isues with ECC](http://plugcomputer.org/plugforum/index.php?PHPSESSID=6d6a1c88e56f31bea4a9d2415f1b820a&topic=1290.msg8970#msg8970 "http://plugcomputer.org/plugforum/index.php?PHPSESSID=6d6a1c88e56f31bea4a9d2415f1b820a&topic=1290.msg8970#msg8970")

### Setting env var from OpenWrt

Revert u-boot silent boot and add a bootdelay

```
fw_setenv silent
Unlocking flash...
Done
Erasing old environment...
Done
Writing environment to /dev/mtd0...
Done
Locking ...
Done
 
fw_setenv bootdelay 1
Unlocking flash...
Done
Erasing old environment...
Done
Writing environment to /dev/mtd0...
Done
Locking ...
Done
```

### Example of configuring uboot-envtools

Inside a working system consult the file `/proc/mtd` that should contain the mapping of the flash of the router. We can thus determine the partition where the U-Boot environment is stored.

```
# cat /proc/mtd
```

```
dev:    size   erasesize  name
mtd0: 00030000 00010000 "uboot"
mtd1: 00010000 00010000 "uboot_env"
mtd2: 007b0000 00010000 "firmware"
mtd3: 0018906c 00010000 "kernel"
mtd4: 00626f94 00010000 "rootfs"
mtd5: 000d0000 00010000 "rootfs_data"
mtd6: 00010000 00010000 "board_config"
```

Here it is `/dev/mtd1`. Some devices seem not to have the `uboot_env` section and the environment appears with an offset in the section containing `uboot` (`/dev/mtd0`) here. In the latter case expect that the environment address (offset) is a multiple of Flash sector size.

We have determined that the `MTD device name` is `/dev/mtd1`. The offset in our case is `0x0000`.

Useful offset information can also be found by running dmesg on your device. This is taken from a modified arv752dpw22:

```
[    0.505477] 0x000000000000-0x000000030000 : "uboot"
[    0.512242] 0x000000030000-0x000000040000 : "uboot_env"
[    0.518030] 0x000000040000-0x0000007f0000 : "firmware"
[    0.563673] 0x000000040000-0x0000001c906c : "kernel"
[    0.570525] 0x0000001c906c-0x0000007f0000 : "rootfs"
[    0.586168] 0x000000720000-0x0000007f0000 : "rootfs_data"
[    0.639581] 0x0000007f0000-0x000000800000 : "board_config"
```

#### Determine CONFIG\_ENV\_OFFSET, CONFIG\_ENV\_SIZE, and CONFIG\_ENV\_SECT\_SIZE

Next we need to determine the `Env. size` and `Flash sector size` (the `Number of sectors` is ignored in the case of NOR flash). The variables of interest are C macros in the OpenWrt source tree relative to your device

```
#define CONFIG_ENV_OFFSET              (192 * 1024)
#define CONFIG_ENV_SECT_SIZE           (64 * 1024)
#define CONFIG_ENV_SIZE                (8 * 1024)
```

You can search for it by issuing a `grep` search in the base directory of the OpenWrt tree.

```
# grep -R CONFIG_ENV_SIZE
```

There will be a lot of results and you can just page through the listed files to find one that is relevant for your device.

In the case of [arv752dpw22](/toh/astoria/arv752dpw22 "toh:astoria:arv752dpw22") the data was found in `package/boot/uboot-lantiq/patches/0038-MIPS-add-board-support-for-Arcadyan-ARV752DPW22.patch`

```
/* Environment */
+#if defined(CONFIG_SYS_BOOT_NOR)
+#define CONFIG_ENV_IS_IN_FLASH
+#define CONFIG_ENV_OVERWRITE
+#define CONFIG_ENV_OFFSET              (192 * 1024)
+#define CONFIG_ENV_SECT_SIZE           (64 * 1024)
+#else
+#define CONFIG_ENV_IS_NOWHERE
+#endif
+
+#define CONFIG_ENV_SIZE                        (8 * 1024)
+#define CONFIG_LOADADDR                        CONFIG_SYS_LOAD_ADDR
+
```

Do not forget to convert the values to hex if they are in dec.

However, maybe due to the historic version of uboot, the variable names may be different (in the case of WR1043ND one has `CFG_FLASH_SIZE`) and the file is: `include/configs/ap83.h` (in Source Code, obtain from manufacturer, not OpenWrt). Here are the values:

```
/*-----------------------------------------------------------------------
 * FLASH and environment organization
 */
#define CFG_MAX_FLASH_BANKS     1	    /* max number of memory banks */
//#define CFG_MAX_FLASH_SECT      128    /* max number of sectors on one chip */
#define CFG_MAX_FLASH_SECT      256    /* max number of sectors on one chip */
#define CFG_FLASH_SECTOR_SIZE   (64*1024)
#define CFG_FLASH_SIZE          0x00800000 /* Total flash size */

#define CFG_FLASH_WORD_SIZE     unsigned short 
#define CFG_FLASH_ADDR0         (0x5555)   /* 1st address for flash config cycles  */
#define CFG_FLASH_ADDR1         (0x2AAA)   /* 2nd address for flash config cycles  */

#define CFG_HOWL_1_2 1
```

You can check that the configuration is correct if `fw_printenv` gives you the correct output:

```
root@OpenWrt:/# fw_printenv 
addconsole=setenv bootargs $bootargs console=$consoledev,$baudrate
addeth=setenv bootargs $bootargs ethaddr=$ethaddr
addip=setenv bootargs $bootargs ip=$ipaddr:$serverip::::$netdev:off
addmachtype=setenv bootargs $bootargs machtype=ARV752DPW22
baudrate=115200
bootcmd=run download_kernel_command; bootm ${kernel_addr}
bootdelay=2
consoledev=ttyLTQ1
download_kernel=true
download_kernel_command=test -n $download_kernel && ping $serverip && run load-kernel && ping $serverip && run write-kernel && ping $serverip
ethact=ltq-eth
ethaddr=7C:4F:B5:BF:77:B7
fileaddr=81000000
filesize=680004
ipaddr=192.168.1.1
kernel_addr=0xB0040000
load-kernel=tftpboot openwrt-lantiq-xway-ARV752DPW22-squashfs.image && crc32 $fileaddr $filesize
load-uboot-nor=tftpboot u-boot.bin
load-uboot-norspl=tftpboot u-boot.ltq.norspl
load-uboot-norspl-lzma=tftpboot u-boot.ltq.lzma.norspl
load-uboot-norspl-lzo=tftpboot u-boot.ltq.lzo.norspl
loadaddr=0x81000000
netdev=eth0
serverip=192.168.1.2
stderr=serial
stdin=serial
stdout=serial
update-uboot-nor=run load-uboot-nor write-uboot-nor
write-kernel=erase $kernel_addr +$filesize && cp.b $fileaddr $kernel_addr $filesize && crc32 $kernel_addr $filesize
write-uboot-nor=protect off 0xB0000000 +$filesize && erase 0xB0000000 +$filesize && cp.b $fileaddr 0xB0000000 $filesize
root@OpenWrt:/# fw_printenv 
addconsole=setenv bootargs $bootargs console=$consoledev,$baudrate
addeth=setenv bootargs $bootargs ethaddr=$ethaddr
addip=setenv bootargs $bootargs ip=$ipaddr:$serverip::::$netdev:off
addmachtype=setenv bootargs $bootargs machtype=ARV752DPW22
baudrate=115200
bootcmd=run download_kernel_command; bootm ${kernel_addr}
bootdelay=2
consoledev=ttyLTQ1
download_kernel=true
download_kernel_command=test -n $download_kernel && ping $serverip && run load-kernel && ping $serverip && run write-kernel && ping $serverip
ethact=ltq-eth
ethaddr=7C:4F:B5:BF:77:B7
fileaddr=81000000
filesize=680004
ipaddr=192.168.1.1
kernel_addr=0xB0040000
load-kernel=tftpboot openwrt-lantiq-xway-ARV752DPW22-squashfs.image && crc32 $fileaddr $filesize
load-uboot-nor=tftpboot u-boot.bin
load-uboot-norspl=tftpboot u-boot.ltq.norspl
load-uboot-norspl-lzma=tftpboot u-boot.ltq.lzma.norspl
load-uboot-norspl-lzo=tftpboot u-boot.ltq.lzo.norspl
loadaddr=0x81000000
netdev=eth0
serverip=192.168.1.2
stderr=serial
stdin=serial
stdout=serial
update-uboot-nor=run load-uboot-nor write-uboot-nor
write-kernel=erase $kernel_addr +$filesize && cp.b $fileaddr $kernel_addr $filesize && crc32 $kernel_addr $filesize
write-uboot-nor=protect off 0xB0000000 +$filesize && erase 0xB0000000 +$filesize && cp.b $fileaddr 0xB0000000 $filesize
```

In case the configuration is incorrect you get

```
root@OpenWrt:/# fw_printenv 
Warning: Bad CRC, using default environment
bootcmd=bootp; setenv bootargs root=/dev/nfs nfsroot=${serverip}:${rootpath} ip=${ipaddr}:${serverip}:${gatewayip}:${netmask}:${hostname}::off; bootm
bootdelay=5
baudrate=115200
```

DO NOT EVEN TRY to use `fw_setenv` if your configuration is incorrect. Who knows what you could mess up by writing to the wrong place!

#### Making ''/dev/mtd#'' read-write

As mentioned previously usually the `/dev/mtd#` are readonly under OpenWRT. If this is the case the you would get the following error when trying to write to flash

```
# fw_setenv Status 0
Can't open /dev/mtd1: Permission denied
Error: can't write fw_env to flash
```

You must find a way to tell the linux system that it should access that part of flash in read-write mode. There are lots of questions on how to do this but not many answers around because the u-boot people, who are the ones that get asked about it, say it is a Linux problem relating to the specifics of the kernel/system you have installed. Here are some examples about making the partition read-write.

[TL-WR1043ND - Making bootloader partition writable](/toh/tp-link/tl-wr1043nd#making_bootloader_partition_writable "toh:tp-link:tl-wr1043nd")

The information about being `ro` or `rw` can also be in the `dts` files. For [arv752dpw22](/toh/astoria/arv752dpw22 "toh:astoria:arv752dpw22") this file is in `./target/linux/lantiq/dts/ARV752DPW22.dts` and the relevant section is

```
nor-boot@0 {
                                compatible = "lantiq,nor";
                                bank-width = <2>;
                                reg = <0 0x0 0x800000>;
                                #address-cells = <1>;
                                #size-cells = <1>;

                                partition@0 {
                                        label = "uboot";
                                        reg = <0x00000 0x30000>;
                                        read-only;
                                };

                                partition@10000 {
                                        label = "uboot_env";
                                        reg = <0x30000 0x10000>;
                                        read-only;
                                };

                                partition@20000 {
                                        label = "firmware";
                                        reg = <0x40000 0x7b0000>;
                                };
```

Removing the `read-only` directive to have

```
                                partition@10000 {
                                        label = "uboot_env";
                                        reg = <0x30000 0x10000>;
                                };
```

and recompiling everything fixes the problem. However be careful, for whatever reason I am not sure that make detects changes to `dts` files so be sure that if you are recompiling make actually notices the change and does everything. Maybe a

```
make clean
```

at the beginning can help.
