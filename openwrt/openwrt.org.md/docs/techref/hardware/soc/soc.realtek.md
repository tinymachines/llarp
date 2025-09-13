# Realtek

- For Realtek 802.11 “wireless” chipsets and Realtek SoCs see [Realtek](https://wikidevi.wi-cat.ru/Realtek "https://wikidevi.wi-cat.ru/Realtek").
- For Linux drivers for Realtek 802.11 chipsets, see [Comparison of open-source wireless drivers](https://en.wikipedia.org/wiki/Comparison%20of%20open-source%20wireless%20drivers "https://en.wikipedia.org/wiki/Comparison of open-source wireless drivers") and also [http://wireless.kernel.org/en/users/Drivers](http://wireless.kernel.org/en/users/Drivers "http://wireless.kernel.org/en/users/Drivers")

## Lexra

- About the Lexra CPUs, see [Lexra](https://en.wikipedia.org/wiki/Lexra "https://en.wikipedia.org/wiki/Lexra") / [Lexra](http://www.linux-mips.org/wiki/Lexra "http://www.linux-mips.org/wiki/Lexra") and [livebox.2](/toh/sagemcom/livebox.2 "toh:sagemcom:livebox.2")

### Devices with Lexra SoC

- [https://oldwiki.archive.openwrt.org/toh/alfa.network/ac1200r](https://oldwiki.archive.openwrt.org/toh/alfa.network/ac1200r "https://oldwiki.archive.openwrt.org/toh/alfa.network/ac1200r")
- [https://oldwiki.archive.openwrt.org/toh/cc\_c/wa-6202](https://oldwiki.archive.openwrt.org/toh/cc_c/wa-6202 "https://oldwiki.archive.openwrt.org/toh/cc_c/wa-6202")
- [https://oldwiki.archive.openwrt.org/toh/d-link/dir-120](https://oldwiki.archive.openwrt.org/toh/d-link/dir-120 "https://oldwiki.archive.openwrt.org/toh/d-link/dir-120")
- [https://oldwiki.archive.openwrt.org/toh/sagem/livebox](https://oldwiki.archive.openwrt.org/toh/sagem/livebox "https://oldwiki.archive.openwrt.org/toh/sagem/livebox")
- [https://oldwiki.archive.openwrt.org/toh/sagem/livebox.2](https://oldwiki.archive.openwrt.org/toh/sagem/livebox.2 "https://oldwiki.archive.openwrt.org/toh/sagem/livebox.2")
- [https://oldwiki.archive.openwrt.org/inbox/toh/totolink\_n300rt](https://oldwiki.archive.openwrt.org/inbox/toh/totolink_n300rt "https://oldwiki.archive.openwrt.org/inbox/toh/totolink_n300rt")
- [https://oldwiki.archive.openwrt.org/ru/toh/totolink/toton610rt](https://oldwiki.archive.openwrt.org/ru/toh/totolink/toton610rt "https://oldwiki.archive.openwrt.org/ru/toh/totolink/toton610rt")
- [https://oldwiki.archive.openwrt.org/inbox/trendnet/trendnet\_tew-820ap\_1.0r](https://oldwiki.archive.openwrt.org/inbox/trendnet/trendnet_tew-820ap_1.0r "https://oldwiki.archive.openwrt.org/inbox/trendnet/trendnet_tew-820ap_1.0r")
- [https://oldwiki.archive.openwrt.org/toh/zte/h298n](https://oldwiki.archive.openwrt.org/toh/zte/h298n "https://oldwiki.archive.openwrt.org/toh/zte/h298n")

### Support status

SoCs of the Lexra Architecture are not supported by OpenWrt since years. It is unlikely that this status changes anytime soon.

### Adding support for Lexra

If you want OpenWrt support for a device with a Lexra SoC, you have to add it yourself. See below how to do that.

#### OpenWrt documentation

- [https://openwrt.org/docs/guide-developer/start](https://openwrt.org/docs/guide-developer/start "https://openwrt.org/docs/guide-developer/start")
- [https://openwrt.org/docs/guide-developer/build-system/use-buildsystem](https://openwrt.org/docs/guide-developer/build-system/use-buildsystem "https://openwrt.org/docs/guide-developer/build-system/use-buildsystem")
- [https://openwrt.org/docs/guide-developer/add.new.platform](https://openwrt.org/docs/guide-developer/add.new.platform "https://openwrt.org/docs/guide-developer/add.new.platform")
- [https://openwrt.org/docs/guide-developer/add.new.device](https://openwrt.org/docs/guide-developer/add.new.device "https://openwrt.org/docs/guide-developer/add.new.device")
- [https://openwrt.org/docs/guide-developer/adding\_new\_device](https://openwrt.org/docs/guide-developer/adding_new_device "https://openwrt.org/docs/guide-developer/adding_new_device")

#### External sources

- [https://github.com/AlexeySofree/openwrt-rtl819x](https://github.com/AlexeySofree/openwrt-rtl819x "https://github.com/AlexeySofree/openwrt-rtl819x")
- [https://github.com/hackpascal/lede-rtl8196c](https://github.com/hackpascal/lede-rtl8196c "https://github.com/hackpascal/lede-rtl8196c")
- [RTL819x SDK](https://sourceforge.net/projects/rtl819x/files/ "https://sourceforge.net/projects/rtl819x/files/")
- [https://sourceforge.net/projects/rtl8197xd-v2-5-pkg/files/](https://sourceforge.net/projects/rtl8197xd-v2-5-pkg/files/ "https://sourceforge.net/projects/rtl8197xd-v2-5-pkg/files/")
- [https://wikileaks.org/wiki/Lexra\_CPU\_core\_documentation](https://wikileaks.org/wiki/Lexra_CPU_core_documentation "https://wikileaks.org/wiki/Lexra_CPU_core_documentation")
- [http://wlstorage.net/file/lexra-cpu-core-documentation.zip](http://wlstorage.net/file/lexra-cpu-core-documentation.zip "http://wlstorage.net/file/lexra-cpu-core-documentation.zip")

#### Forum discussions

[Search the OpenWrt forum for Lexra support status](https://forum.openwrt.org/search?q=lexra "https://forum.openwrt.org/search?q=lexra")

- [RTL8196C port status](https://forum.archive.openwrt.org/viewtopic.php?id=31551 "https://forum.archive.openwrt.org/viewtopic.php?id=31551")
- [Realtek SoC support in OpenWrt](https://forum.archive.openwrt.org/viewtopic.php?id=46606 "https://forum.archive.openwrt.org/viewtopic.php?id=46606")
- [Any plans for Realtek SOC support?](https://forum.openwrt.org/t/any-plans-for-realtek-soc-support/15727 "https://forum.openwrt.org/t/any-plans-for-realtek-soc-support/15727")
- [Need to compile WRT for rtl819x](https://forum.openwrt.org/t/need-to-compile-wrt-for-rtl819x/28338 "https://forum.openwrt.org/t/need-to-compile-wrt-for-rtl819x/28338")
- [Status (Feb 2019) and info collection regarding OpenWrt support for Lexra](https://forum.openwrt.org/t/zte-zxhn-h118na-hw-ver-2-3-possible-openwrt-flash/31245/2?u=tmomas "https://forum.openwrt.org/t/zte-zxhn-h118na-hw-ver-2-3-possible-openwrt-flash/31245/2?u=tmomas")
- [Working Realtek SoC RTL8196E 97D 97F in last master](https://forum.openwrt.org/t/working-realtek-soc-rtl8196e-97d-97f-in-last-master/70975?u=tmomas "https://forum.openwrt.org/t/working-realtek-soc-rtl8196e-97d-97f-in-last-master/70975?u=tmomas")

#### Quotes

From [https://forum.openwrt.org/t/programing-for-new-device/17062/14?u=tmomas](https://forum.openwrt.org/t/programing-for-new-device/17062/14?u=tmomas "https://forum.openwrt.org/t/programing-for-new-device/17062/14?u=tmomas"):

> Lexra is not supported directly by gcc like MIPS, ARM, x86 etc. are. This means that even compiling the first line of C code requires a lot of modification to the system.
> 
> Also Realtek does not have good open wifi drivers.

* * *

From [https://forum.openwrt.org/t/building-openwrt-for-rtl8196c/1379/4?u=tmomas](https://forum.openwrt.org/t/building-openwrt-for-rtl8196c/1379/4?u=tmomas "https://forum.openwrt.org/t/building-openwrt-for-rtl8196c/1379/4?u=tmomas"):

> The first big problem is that the Lexra CPU core found in these chips isn't one of the platforms directly selectable in gcc. So these third-party projects use a hacked up old version of gcc. And everything kind of falls apart from there. Also open-source drivers for Realtek wifi chips are limited.

* * *

From [https://openwrt.org/toh/sagem/livebox.2](https://openwrt.org/toh/sagem/livebox.2 "https://openwrt.org/toh/sagem/livebox.2"):

> It is possible to compile software for Lexra processors using the gnu gcc tools for the MIPS-I R3000 processor. This can be done either by writing an exception trap handler for reserved instructions that detects unaligned load and store instructions and emulates their functionality with shifts and aligned loads and stores or else modifying the compiler so that it does not generate lwl, lwr, swl, and swr instructions. With either of those changes, any C code can run on Lexra processors. Advanced hobbyists might even choose to accelerate their critical inner loops by coding them in assembly code using digital signal processing (DSP) instructions that Lexra implemented as extensions to the MIPS-I instruction set.

* * *

From [Realtek SoC support in OpenWrt](https://forum.archive.openwrt.org/viewtopic.php?id=46606&p=13#p371989 "https://forum.archive.openwrt.org/viewtopic.php?id=46606&p=13#p371989"):

> In terms of lexra (Realtek's reduced mips ISA) support, there is none - nor anyone actively pushing for it (as in providing patches/ pull requests against current master); chances for this to change are non-zero, but extremely low (once you'd have hypothetical lexra arch/ SOC support, there would still be the problem of the wlan drivers and current hostapd/ nl80211, to drive them reliably in AP mode).
> 
> \[Disclaimer: I can't speak for the LEDE/ OpenWrt developers]  
> Personally I don't think lexra will 'ever' be supported in LEDE/ OpenWrt (too different from normal mips, no upstream/ toolchain support at all, very low-end devices, the wlan situation (drivers, AP mode reliability, nl80211 support) is difficult). But effectively all it would need, is someone pushing for it - to provide a (long-term-) manageable pull request with lexra support against OpenWrt/ master, kernel 4.14, musl, hostapd/ nl80211 for the wlan drivers and not too many arch specific changes (so it can be reasonably updated with the rest of OpenWrt and not stay behind).

* * *

From [https://forum.openwrt.org/t/can-rtl8196c-be-incorporated-into-the-lede/1381](https://forum.openwrt.org/t/can-rtl8196c-be-incorporated-into-the-lede/1381 "https://forum.openwrt.org/t/can-rtl8196c-be-incorporated-into-the-lede/1381"):

> Afaik there's no upstream support whatsoever towards OpenWrt/LEDE, which is why Realtek devices aren't supported.

> Realtek inherited a reduced mips ISA via Lexra, given that this differs from the normal mips ISA, it is quite a bit harder to support - especially lacking active (or any-) upstream development.

* * *

From [https://forum.openwrt.org/t/can-rtl8196c-be-incorporated-into-the-lede/1381/4?u=tmomas](https://forum.openwrt.org/t/can-rtl8196c-be-incorporated-into-the-lede/1381/4?u=tmomas "https://forum.openwrt.org/t/can-rtl8196c-be-incorporated-into-the-lede/1381/4?u=tmomas"):

> I've ported RTL8196C support to LEDE, without wireless support.  
> All source codes (SPI driver/ethernet driver) were written myself.  
> [https://github.com/hackpascal/lede-rtl8196c](https://github.com/hackpascal/lede-rtl8196c "https://github.com/hackpascal/lede-rtl8196c") 240 (with branch realtek)
> 
> But I probably have no time to develop it later.

* * *

From [https://forum.openwrt.org/t/unsupported-belkin/17252/3?u=tmomas](https://forum.openwrt.org/t/unsupported-belkin/17252/3?u=tmomas "https://forum.openwrt.org/t/unsupported-belkin/17252/3?u=tmomas"):

> The whole target SOC isn't supported at all (search this forum for 'lexra', if you want more details), neither in OpenWrt, nor upstream linux, binutils, gcc, musl, … Adding support for this arch is of course 'possible', but a lot of work - and once there you'd have to deal with getting the wlan drivers to work in AP mode and using contemporary hotapd version, neither will be easy.

#### Boot Logs (Realtek RTL8197F-VG - Strong AC1200)

```
Booting...
init_ram
bond:0x0000000b
MCM 128MB

 dram_init_clk_frequency ,ddr_freq=1066 (Mbps), 533 (MHZ) 

DRAM init disable

DRAM init enable

DRAM init is done , jump to DRAM
enable DRAM ODT 

SDR init done dev_map=0xb8142000

Detect page_size = 2KB (3)

Detect bank_size = 8 banks(0x00000002)

Detect dram size = 128MB (0x08000000)

DDR init OK
init ddr ok

DRAM Type: DDR2
	DRAM frequency: 533MHz
	DRAM Size: 128MB
JEDEC id EF4018, EXT id 0x0000
found w25q128
flash vendor: Winbond
w25q128, size=16MB, erasesize=4KB, max_speed_hz=29000000Hz
auto_mode=0 addr_width=3 erase_opcode=0x00000020
Write PLL1=80c00042
=>CPU Wake-up interrupt happen! GISR=89000080 
 
---Realtek RTL8197F-VG boot code at 2021.06.08-19:04+0800 v3.4.14 (999MHz)
bootbank is 1, bankmark 80000001, forced:0
no sys signature at 00010000!
no sys signature at 00020000!
no rootfs signature at 00260000!
no rootfs signature at 00270000!
no rootfs signature at 002B0000!
Jump to image start=0x80a00000...
return_addr = b0030000 ,boot bank=1, bank_mark=0x80000001...
decompressing kernel:
Uncompressing Linux... done, booting the kernel.
done decompressing kernel.
start address: 0x804f5400
Linux version 3.10.90 (wanglei@Routerteam) (gcc version 4.8.5 20150209 (prerelease) (Realtek MSDK-4.8.5p1 Build 2536) ) #173 Tue Aug 24 19:43:32 CST 2021
bootconsole [early0] enabled
CPU revision is: 00019385 (MIPS 24Kc)
Determined physical RAM map:
 memory: 08000000 @ 00000000 (usable)
Zone ranges:
  Normal   [mem 0x00000000-0x07ffffff]
Movable zone start for each node
Early memory node ranges
  node   0: [mem 0x00000000-0x07ffffff]
Primary instruction cache 64kB, VIPT, 4-way, linesize 32 bytes.
Primary data cache 32kB, 4-way, PIPT, no aliases, linesize 32 bytes
Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 8176
Kernel command line: console=ttyS0,38400 root=/dev/mtdblock1
PID hash table entries: 512 (order: -3, 2048 bytes)
Dentry cache hash table entries: 16384 (order: 2, 65536 bytes)
Inode-cache hash table entries: 8192 (order: 1, 32768 bytes)
Writing ErrCtl register=0004190c
Readback ErrCtl register=0004190c
Memory: 107456k/131072k available (5112k kernel code, 23616k reserved, 2094k data, 208k init, 0k highmem)
SLUB: HWalign=32, Order=0-3, MinObjects=0, CPUs=1, Nodes=1
NR_IRQS:192
Realtek GPIO IRQ init
Calibrating delay loop... 666.41 BogoMIPS (lpj=3332096)
pid_max: default: 32768 minimum: 301
Mount-cache hash table entries: 2048
NET: Registered protocol family 16
<<<<<Register PCI Controller>>>>>
Do MDIO_RESET
40MHz
Find PCIE Port, Device:Vender ID=f81210ec
Realtek GPIO controller driver init 3
INFO: registering sheipa spi device
bio: create slab <bio-0> at 0
INFO: sheipa spi driver register
INFO: sheipa spi probe
Switching to clocksource MIPS
NET: Registered protocol family 2
TCP established hash table entries: 2048 (order: 0, 16384 bytes)
TCP bind hash table entries: 2048 (order: -1, 8192 bytes)
TCP: Hash tables configured (established 2048 bind 2048)
TCP: reno registered
UDP hash table entries: 1024 (order: 0, 16384 bytes)
UDP-Lite hash table entries: 1024 (order: 0, 16384 bytes)
NET: Registered protocol family 1
squashfs: version 4.0 (2009/01/31) Phillip Lougher
msgmni has been set to 209
Block layer SCSI generic (bsg) driver version 0.4 loaded (major 254)
io scheduler noop registered (default)
Serial: 8250/16550 driver, 1 ports, IRQ sharing disabled
serial8250: ttyS0 at MMIO 0x18147000 (irq = 17) is a 16550A
console [ttyS0] enabled, bootconsole disabled
console [ttyS0] enabled, bootconsole disabled
Realtek GPIO Driver for Flash Reload Default
loop: module loaded
m25p80 spi0.0: change speed to 15000000Hz, div 7
JEDEC id EF4018
m25p80 spi0.0: found w25q128, expected m25p80
flash vendor: Winbond
m25p80 spi0.0: w25q128 (16384 Kbytes) (29000000 Hz)
6 rtkxxpart partitions found on MTD device m25p80
Creating 6 MTD partitions on "m25p80":
0x000000000000-0x000000300000 : "boot+cfg+linux"
0x000000300000-0x000000800000 : "rootfs"
0x000000800000-0x000000b00000 : "boot+cfg+linux2"
0x000000b00000-0x000000ff8000 : "rootfs2"
0x000000ff8000-0x000000ffc000 : "cwmp transfer"
0x000000ffc000-0x000001000000 : "cwmp notification"
PPP generic driver version 2.4.2
NET: Registered protocol family 24
MPPE/MPPC encryption/compression module registered
Realtek WLAN driver - version 3.8.0(2017-12-26)(SVN:45048)
DFS function - version 3.0.0
Adaptivity function - version 9.7.07
Do MDIO_RESET
40MHz
Find PCIE Port, Device:Vender ID=f81210ec
rtl8192cd_init_one(15553): vendor_deivce_id(f81210ec) sub(f81210ec)

 found 8812F !!! 
IS_RTL8812F_SERIES value8 = 14 
Hardware type = RTL8812FE
MACHAL_version_init
11692M
HALMAC_MAJOR_VER = 1
HALMAC_PROTOTYPE_VER = 6
HALMAC_MINOR_VER = 6
HALMAC_PATCH_VER = 6
[TRACE]halmac_init_adapter <===
halmac_init_adapter Succss 
[MACFM_software_init 297]wifi hal support Mac function = 0x11ff


#######################################################
SKB_BUF_SIZE=4432 MAX_SKB_NUM=1024
#######################################################

[MACFM_software_init 297]wifi hal support Mac function = 0x11ff
[MACFM_software_init 297]wifi hal support Mac function = 0x11ff
[MACFM_software_init 297]wifi hal support Mac function = 0x11ff
[MACFM_software_init 297]wifi hal support Mac function = 0x11ff
[MACFM_software_init 297]wifi hal support Mac function = 0x11ff
MACHAL_version_init
[MACFM_software_init 297]wifi hal support Mac function = 0x8108


#######################################################
SKB_BUF_SIZE=3032 MAX_SKB_NUM=400
#######################################################

[MACFM_software_init 297]wifi hal support Mac function = 0x8108
[MACFM_software_init 297]wifi hal support Mac function = 0x8108
[MACFM_software_init 297]wifi hal support Mac function = 0x8108
[MACFM_software_init 297]wifi hal support Mac function = 0x8108
[MACFM_software_init 297]wifi hal support Mac function = 0x8108
u32 classifier
nf_conntrack version 0.5.0 (1679 buckets, 6716 max)
nf_conntrack_l2tp version 3.1 loaded
nf_conntrack_rtsp v0.6.21 loading
nf_conntrack_ipsec loaded
nf_nat_ipsec loaded
nf_nat_rtsp v0.6.21 loading
ip_tables: (C) 2000-2006 Netfilter Core Team
TCP: cubic registered
NET: Registered protocol family 10
ip6_tables: (C) 2000-2006 Netfilter Core Team
sit: IPv6 over IPv4 tunneling driver
NET: Registered protocol family 17
Ebtables v2.0 registered
l2tp_core: L2TP core driver, V2.0
8021q: 802.1Q VLAN Support v1.8
Realtek FastPath:v1.03

Probing RTL819X NIC-kenel stack size order[0]...
  SoC: 8197FS-VG,0
Switch API version: v1.3.11, chip id: 0x6367-0020
[rtl865x_adjustQueueLen:8656] memory: bb80457c,  value: fc00ff
[rtl865x_adjustQueueLen:8656] memory: bb804580,  value: fc00ff
[rtl865x_adjustQueueLen:8656] memory: bb804584,  value: fc00ff
[rtl865x_adjustQueueLen:8656] memory: bb8045c4,  value: fc00ff
[rtl865x_adjustQueueLen:8656] memory: bb8045c8,  value: fc00ff
[rtl865x_adjustQueueLen:8656] memory: bb8045cc,  value: fc00ff
eth0 added. vid=9 Member port 0x10f...
eth1 added. vid=8 Member port 0x10...
[peth0] added, mapping to [eth1]...
m25p80 spi0.0: change speed to 29000000Hz, div 4
VFS: Mounted root (squashfs filesystem) readonly on device 31:1.
Freeing unused kernel memory: 208K (8070c000 - 80740000)
init started: BusyBox v1.13.4 (2021-08-24 19:32:50 CST)
cp: cannot stat '/etc/shadow.sample': No such file or directory
cp: cannot stat '/etc/avahi-daemon.conf': No such file or directory
type:3, enable:1, percent1
******************
sysconf init_randmac 
***************
******************
sysconf init_reg_domain 
***************
******************
sysconf easy_mesh_router_init 
***************
******************
sysconf easy_mesh_multiap_config 
***************
******************
sysconf init gw all 
***************
value is null [private_beacon_ie] !
6389:apmib_set:960
Init Start...
******************
sysconf wlanapp kill wlan0 
***************
!!! adjust 5G 2ndoffset for 8812 !!!
******************
sysconf wlanapp kill wlan1 
***************
open /proc/br_wlanblock: Permission denied
Init bridge interface...
device eth0 entered promiscuous mode
device wlan0 entered promiscuous mode
chip_version=0x2001,WlanSupportAbility = 0x3
[ACS] 5G should not use acs_type=1, change to acs_type=2
[stactrl_init, 217][wlan0] groupID: 0
[stactrl_init, 235][wlan0] Enable block_5G feature
[stactrl_init, 242][wlan0] Enable hiddenAP feature
[stactrl_init, 272][wlan0] WARNING: not find available priv
clock 40MHz
[TRACE]pre_init_system_cfg_8812f ===>
[TRACE]set_hw_value_88xx ===>
[TRACE]set_hw_value_88xx <===
[TRACE]pre_init_system_cfg_8812f <===
[TRACE]mac_pwr_switch_pcie_8812f ===>
[TRACE]pwr = 1
[TRACE]8812F pwr seq ver = V01
[TRACE]mac_pwr_switch_pcie_8812f <===
InitPON OK!!!
REG_HCI_MIX_CFG = 2b 
[TRACE]init_system_cfg_8812f ===>
[TRACE]init_system_cfg_8812f <===
InitMAC Page0 
[TRACE]download_firmware_88xx ===>
[TRACE]halmac h2c ver = f, fw h2c ver = e!!
[TRACE]=== FW info ===
[TRACE]ver : 3
[TRACE]sub-ver : 3
[TRACE]sub-idx : 0
[TRACE]build : 2019/8/13 9:35
[TRACE]Dlfw OK, enable CPU
[TRACE]0x80=0xC078, cnt=5000
[TRACE]download_firmware_88xx <===
>>SetBeaconDownload88XX
Init Download FW OK 
[TRACE]cfg_la_mode_88xx ===>
[TRACE]cfg_la_mode_88xx <===
[TRACE]init_mac_cfg_88xx ===>
[TRACE]init_trx_cfg_8812f ===>
[TRACE]rqpn_parser_88xx done
[TRACE]pg_num_parser_88xx done
[TRACE]Set FIFO page
[TRACE]h2c fs : 1024
[TRACE]init_trx_cfg_8812f <===
[TRACE]init_protocol_cfg_8812f ===>
[TRACE]init_protocol_cfg_8812f <===
[TRACE]init_edca_cfg_8812f ===>
[TRACE]init_edca_cfg_8812f <===
[TRACE]init_wmac_cfg_8812f ===>
[TRACE]init_low_pwr_8812f ===>
[TRACE]init_low_pwr_8812f <===
[TRACE]init_wmac_cfg_8812f <===
[TRACE]init_mac_cfg_88xx <===
halmac_init_mac_cfg OK
halmac_cfg_rx_aggregation OK
[TRACE]cfg_mac_addr_88xx ===>
[TRACE]cfg_mac_addr_88xx <===
halmac_init_mac_cfg OK
[TRACE]cfg_drv_info_8812f ===>
[TRACE]drv info = 1
[TRACE]set_hw_value_8812f ===>
[TRACE]set_hw_value_88xx ===>
[TRACE]cfg_rx_ignore_8812f ===>
[TRACE]cfg_rx_ignore_8812f <===
[TRACE]set_hw_value_8812f <===
[TRACE]cfg_drv_info_8812f <===
[GetHwReg88XX][size PHY_REG_PG_8812Fmp_Type0]
[GetHwReg88XX][PHY_REG_PG_8812Fmp_Type0]
start_addr=(0x20000), end_addr=(0x40000), buffer_size=(0x20000), smp_number_max=(16384)
[set_8812F_trx_regs] +++ 
device wlan1 entered promiscuous mode
chip_version=0x100f,WlanSupportAbility = 0x2
PrepareRXBD88XX_V1 134 
test 0x87ad2c00,0x30,0x7ad2e80,0x0, 
test 0x87ad2c80,0x30,0x7ad2ec0,0x0, 
test 0x87ad2d00,0x30,0x7ad2f00,0x0, 
test 0x87ad2d80,0x30,0x7ad2f40,0x0, 
test 0x87ad2e00,0x30,0x7ad2f80,0x0, 
[stactrl_init, 217][wlan1] groupID: 0
[stactrl_init, 235][wlan1] Enable block_5G feature
[stactrl_init, 242][wlan1] Enable hiddenAP feature
[stactrl_init, 276][wlan1] find other band : wlan0
[stactrl_init, 296][wlan1] prefer band : wlan0, non-prefer band: wlan1
[97F] RFE type 0 PHY paratemters: DEFAULT
clock 40MHz
AP-mode enabled...
RT_OP_MODE_AP...
load efuse ok
rom_progress: 0x200046f
[GetHwReg88XX][rtl8197Gfw]
[GetHwReg88XX][rtl8197Gfw size]
InitMACTRX OK
InitMACProtocolHandler OK
InitMACSchedulerHandler OK
InitMACWMACHandler OK
InitMACSysyemCfgHandler OK
InitMACFunctionHandler OK
[GetHwReg88XX][PHY_REG_PG_8197Gmp_Type0] size = 0x872 *((pu4Byte)(val))=0 
[GetHwReg88XX][PHY_REG_PG_8197Gmp_Type0 start ] 8067fd70 
start_addr=(0x0), end_addr=(0x10000), buffer_size=(0x10000), smp_number_max=(8192)
device wlan0-va0 entered promiscuous mode
[stactrl_init, 217][wlan0-va0] groupID: 0
[stactrl_init, 230][wlan0-va0] WARNING: not ap mode or not enabled
device wlan1-va0 entered promiscuous mode
[stactrl_init, 217][wlan1-va0] groupID: 0
[stactrl_init, 230][wlan1-va0] WARNING: not ap mode or not enabled
device wlan0-vxd entered promiscuous mode
[ACS] 5G should not use acs_type=1, change to acs_type=2
[stactrl_init, 217][wlan0-vxd] groupID: 0
[stactrl_init, 230][wlan0-vxd] WARNING: not ap mode or not enabled
br0: port 6(wlan0-vxd) entered listening state
br0: port 6(wlan0-vxd) entered listening state
br0: port 5(wlan1-va0) entered listening state
br0: port 5(wlan1-va0) entered listening state
br0: port 4(wlan0-va0) entered listening state
br0: port 4(wlan0-va0) entered listening state
br0: port 3(wlan1) entered listening state
br0: port 3(wlan1) entered listening state
br0: port 2(wlan0) entered listening state
br0: port 2(wlan0) entered listening state
br0: port 1(eth0) entered listening state
br0: port 1(eth0) entered listening state
IPv6: ADDRCONF(NETDEV_UP): br0: link is not ready
wait for bridge initialization...
br0: port 6(wlan0-vxd) entered learning state
br0: port 5(wlan1-va0) entered learning state
br0: port 4(wlan0-va0) entered learning state
br0: port 3(wlan1) entered learning state
br0: port 2(wlan0) entered learning state
br0: port 1(eth0) entered learning state
br0: topology change detected, propagating
br0: port 6(wlan0-vxd) entered forwarding state
br0: topology change detected, propagating
br0: port 5(wlan1-va0) entered forwarding state
IPv6: ADDRCONF(NETDEV_CHANGE): br0: link becomes ready
br0: topology change detected, propagating
br0: port 4(wlan0-va0) entered forwarding state
br0: topology change detected, propagating
br0: port 3(wlan1) entered forwarding state
br0: topology change detected, propagating
br0: port 2(wlan0) entered forwarding state
br0: topology change detected, propagating
br0: port 1(eth0) entered forwarding state
route: SIOCDELRT: No such process
route: SIOCADDRT: Invalid argument
******************
sysconf init ap wlan_app 
***************
+++set_wanipv6+++2495
Start setting IPv6[IPv6]
6389:apmib_set:372
open /proc/sys/net/ipv4/rt_cache_rebuild_count: No such file or directory
/bin/sh: can't create /sys/class/gpio/gpio57/value: nonexistent directory
/bin/sh: can't create /sys/class/gpio/gpio35/value: nonexistent directory
/bin/sh: can't create /sys/class/gpio/gpio34/value: nonexistent directory
/bin/sh: can't create /sys/class/gpio/gpio36/value: nonexistent directory
/bin/sh: can't create /sys/class/gpio/gpio33/value: nonexistent directory

ivy set_firewall.c-start_tr069-6493,agent_flag[2]cwmp_flag[162],call system(/bin/cwmpClient &)
******************
sysconf easy_mesh_multiap_config 
***************
[lyu][INFO][main.c:main:236] Enter main CWMP_BUILT_TIME:2021.08.24-11:35+0000 
TR-069 cwmpClient startup.
6389:apmib_set:726
8078:apmib_update:5012,66759,66759
enable 0 interval
===write:0x40===
6389:apmib_set:833
6389:apmib_set:841
Using TR-181 root data model
Libcwmp 
Multi AP agent daemon is running with 0
Multi AP checker daemon is running with 0
[CONFIG] Max resend time for the message that doesn't acknowledged in time is 4
[CONFIG] Multi-AP alme port: 8888
[CONFIG] Rssi weightage is 9
[CONFIG] Path weightage is 1
[CONFIG] Cu weightage is 0
[CONFIG] Roam score difference is 20
[CONFIG] Min evaluation interval is 1
[CONFIG] Min roam interval is 18
[CONFIG] Max number of device allowed is 16
[CONFIG] Throughput threshold is 2500
[CONFIG] Enable pbc gpio monitoring
[[stactrl_deinit, 393][wlan0-vxd] 
CONFIG] Max bss br0: port 6(wlan0-vxd) entered disabled state
number per radio is 5
[CONFIG] Device name set by user is MESH_AP_54C1
[CONFIG] 5GH radio name is: wlan0
[CONFIG] 5GL radio name is: wlan0
[CONFIG] 24G radio name is: wlan1
[CONFIG] VAP Pvalue is null [private_beacon_ie] !
refix: va
[CONFIG] Configured band is 0
[CONFIG] HW redion domain is 3
[CONFIG] agent 5g channel is 36
[CONFIG] agent channel bandwidth is 2
[CONFIG] repeater_ssid : RWFzeU1lc2hCSC1iMmhvWEVxdjU=
[CONFIG] bss_data number : 6
[CONFIG] ssid 0: XXXXXXX
[CONFIG] ssid 1: EasyMeshBH-b2hoXEqv5
[CONFIG] ssid 2: STRONG_ATRIA_2MRD_GUEST1_5G
[CONFIG] ssid 3: STRONG_ATRIA_MK65_GUEST2_5G
[CONFIG] ssid 4: STRONG_ATRIA_MK65_GUEST3_5G
[CONFIG] ssid 5: EasyMeshBH-b2hoXEqv5
[stactrl_init, 217][wlan0-vxd] groupID: 0
[CONFIG] Network[stactrl_init, 230][wlan0-vxd] WARNING: not ap mode or not enabled
 key 0: XXXXX: port 6(wlan0-vxd) entered listening state
@f2JP*BYTrUM
[Cbr0: port 6(wlan0-vxd) entered listening state
ONFIG] Network key 1: XXXXXX
[CONFIG] Network key 2: 00000000
[CONFIG] Network key 3: 00000000
[CONFIG] Network key 4: 00000000
[CONFIG] Network key 5: XXXXXX
[CONFIG] network_type 0: 32
[CONFIG] network_type 1: 64
[CONFIG] network_type 2: 32
[CONFIG] network_type 3: 32
[CONFIG] network_type 4: 32
[CONFIG] network_type 5: 128
[CONFIG] status 0: 1
[CONFIG] status 1: 1
[CONFIG] status 2: 0
[CONFIG] status 3: 0
[CONFIG] status 4: 0
[CONFIG] status 5: 1
[CONFIG] encrypt_type 0: 4
[CONFIG] encrypt_type 1: 4
[CONFIG] encrypt_type 2: 4
[CONFIG] encrypt_type 3: 4
[CONFIG] encrypt_type 4: 4
[CONFIG] encrypt_type 5: 4
[CONFIG] agent 2.4g channel is 11
[CONFIG] agent channel bandwidth is 0
[CONFIG] repeater_ssid : RWFzeU1lc2hCSC1BSE0wVWpGTkw=
[CONFIG] bss_data number : 6
[CONFIG] ssid 0: XXXXXX
[CONFIG] ssid 1: EasyMeshBH-AHM0UjFNL
[CONFIG] ssid 2: STRONG_ATRIA_2MRD_GUEST1_2G
[CONFIG] ssid 3: STRONG_ATRIA_MK65_GUEST2_2G
[CONFIG] ssid 4: STRONG_ATRIA_MK65_GUEST3_2G
[CONFIG] ssid 5: EasyMeshBH-AHM0UjFNL
[CONFIG] Network key 0: XXXXXXX
[CONFIG] Network key 1: nR4d+as3cwqFTf^Ecs_2o[hwFiy:zC
[CONFIG] Network key 2: 00000000
[CONFIG] Network key 3: 00000000
[CONFIG] Network key 4: 00000000
[CONFIG] Network key 5: nR4d+as3cwqFTf^Ecs_2o[hwFiy:zC
[CONFIG] network_type 0: 32
[CONFIG] network_type 1: 64
[CONFIG] network_type 2: 32
[CONFIG] network_type 3: 32
[CONFIG] network_type 4: 32
[CONFIG] network_type 5: 128
[CONFIG] status 0: 1
[CONFIG] status 1: 1
[CONFIG] status 2: 0
[CONFIG] status 3: 0
[CONFIG] status 4: 0
[CONFIG] status 5: 0
[CONFIG] encrypt_type 0: 4
[CONFIG] encrypt_type 1: 4
[CONFIG] encrypt_type 2: 4
[CONFIG] encrypt_type 3: 4
[CONFIG] encrypt_type 4: 4
[CONFIG] encrypt_type 5: 4
Radio Number: 2
/etc/init.d/rcS: line 130: can't create /proc/irq/33/smp_affinity: nonexistent directory
6389:apmib_set:960
Init Start...
Init Wlan application...
[warn] event_add: event has no event_base set.
[warn] event_add: event has no event_base set.
[warn] event_add: event has no event_base set.
6389:apmib_set:3535


=====ivy func:[main:125] BOA_BUILT_TIME:2020.08.26-09:52+0000====

boa: soft version 2.0.37
boa: stype:3, enable:0, percent0
erver built Aug 24 2021 at 19:33:47.
boa: starting server pid=1489, port 80
Startup Ok
rlx-linux login: 8078:apmib_update:5012,66759,66759
br0: port 6(wlan0-vxd) entered learning state
===write:0x40===
ps for map_agent found, pid is 1426 
br0: topology change detected, propagating
br0: port 6(wlan0-vxd) entered forwarding state

WiFi Simple Config v2.20-wps2.0 (2021.08.24-11:34+0000).

br0: received packet on wlan0-vxd with own address as source address
[_write_vendor_data_869]check vendor OUI: 001a9a


[_write_vendor_data_869]check vendor OUI: 001a9a


[CONFIG] Max resend time for the message that doesn't acknowledged in time is 4
[CONFIG] Multi-AP alme port: 8888
[CONFIG] Rssi weightage is 9
[CONFIG] Path weightage is 1
[CONFIG] Cu weightage is 0
[CONFIG] Roam score difference is 20
[CONFIG] Min evaluation interval is 1
[CONFIG] Min roam interval is 18
[CONFIG] Max number of device allowed is 16
[CONFIG] Throughput threshold is 2500
[CONFIG] Enable pbc gpio monitoring
[CONFIG] Max bss number per radio is 5
[CONFIG] Device name set by user is MESH_AP_54C1
[CONFIG] 5GH radio name is: wlan0
[CONFIG] 5GL radio name is: wlan0
[CONFIG] 24G radio name is: wlan1
[CONFIG] VAP Prefix: va
[CONFIG] Configured band is 7
[CONFIG] HW redion domain is 3
[CONFIG] agent 5gl channel is 36
[CONFIG] config_data number : 6
[CONFIG] ssid 0: XXXXX
[CONFIG] ssid 1: EasyMeshBH-b2hoXEqv5
[CONFIG] ssid 2: STRONG_ATRIA_2MRD_GUEST1_5G
[CONFIG] ssid 3: STRONG_ATRIA_MK65_GUEST2_5G
[CONFIG] ssid 4: STRONG_ATRIA_MK65_GUEST3_5G
[CONFIG] ssid 5: EasyMeshBH-b2hoXEqv5
[CONFIG] Network key 0: XXXXX
[CONFIG] Network key 1: OTaxIx_YPg?Cfw4(9oBgln?Le]u(0Q
[CONFIG] Network key 2: 00000000
[CONFIG] Network key 3: 00000000
[CONFIG] Network key 4: 00000000
[CONFIG] Network key 5: OTaxIx_YPg?Cfw4(9oBgln?Le]u(0Q
[CONFIG] is_enabled 0: 1
[CONFIG] is_enabled 1: 1
[CONFIG] is_enabled 2: 0
[CONFIG] is_enabled 3: 0
[CONFIG] is_enabled 4: 0
[CONFIG] is_enabled 5: 1
[CONFIG] need_configure 0: 0
[CONFIG] need_configure 1: 0
[CONFIG] need_configure 2: 0
[CONFIG] need_configure 3: 0
[CONFIG] need_configure 4: 0
[CONFIG] need_configure 5: 0
[CONFIG] bss_type 0: 32
[CONFIG] bss_type 1: 64
[CONFIG] bss_type 2: 32
[CONFIG] bss_type 3: 32
[CONFIG] bss_type 4: 32
[CONFIG] bss_type 5: 128
[CONFIG] encrypt_type 0: 4
[CONFIG] encrypt_type 1: 4
[CONFIG] encrypt_type 2: 4
[CONFIG] encrypt_type 3: 4
[CONFIG] encrypt_type 4: 4
[CONFIG] encrypt_type 5: 4
[CONFIG] vendor setmib data number is: 1
[CONFIG] vendor payload data len is: 31
[CONFIG] vendor payload data 0: [GUEST_ACCESS]192.168.7.254 80
[CONFIG] vendor config data oui 0: 001a9a
[CONFIG] agent 2.4g channel is 11
[CONFIG] config_data number : 6
[CONFIG] ssid 0: XXXX
[CONFIG] ssid 1: EasyMeshBH-AHM0UjFNL
[CONFIG] ssid 2: STRONG_ATRIA_2MRD_GUEST1_2G
[CONFIG] ssid 3: STRONG_ATRIA_MK65_GUEST2_2G
[CONFIG] ssid 4: STRONG_ATRIA_MK65_GUEST3_2G
[CONFIG] ssid 5: EasyMeshBH-AHM0UjFNL
[CONFIG] Network key 0: XXXXX
[CONFIG] Network key 1: nR4d+as3cwqFTf^Ecs_2o[hwFiy:zC
[CONFIG] Network key 2: 00000000
[CONFIG] Network key 3: 00000000
[CONFIG] Network key 4: 00000000
[CONFIG] Network key 5: nR4d+as3cwqFTf^Ecs_2o[hwFiy:zC
[CONFIG] is_enabled 0: 1
[CONFIG] is_enabled 1: 1
[CONFIG] is_enabled 2: 0
[CONFIG] is_enabled 3: 0
[CONFIG] is_enabled 4: 0
[CONFIG] is_enabled 5: 0
[CONFIG] need_configure 0: 0
[CONFIG] need_configure 1: 0
[CONFIG] need_configure 2: 0
[CONFIG] need_configure 3: 0
[CONFIG] need_configure 4: 0
[CONFIG] need_configure 5: 0
[CONFIG] bss_type 0: 32
[CONFIG] bss_type 1: 64
[CONFIG] bss_type 2: 32
[CONFIG] bss_type 3: 32
[CONFIG] bss_type 4: 32
[CONFIG] bss_type 5: 128
[CONFIG] encrypt_type 0: 4
[CONFIG] encrypt_type 1: 4
[CONFIG] encrypt_type 2: 4
[CONFIG] encrypt_type 3: 4
[CONFIG] encrypt_type 4: 4
[CONFIG] encrypt_type 5: 4
[CONFIG] vendor setmib data number is: 1
[CONFIG] vendor payload data len is: 31
[CONFIG] vendor payload data 0: [GUEST_ACCESS]192.168.7.254 80
[CONFIG] vendor config data oui 0: 001a9a
6389:apmib_set:2387

WiFi Simple Config v2.20-wps2.0 (2021.08.24-11:34+0000).

br0: received packet on wlan0-vxd with own address as source address
Register to wlan0
Register to wlan1
Register to wlan0-vxd
iwcontrol RegisterPID to (wlan0)
iwcontrol RegisterPID to (wlan1)
route: SIOCDELRT: No such process
IEEE 802.11f (IAPP) using interface br0 (v1.8)
/bin/sh: can't create /proc/br0/up_event: nonexistent directory
******************
sysconf conn dhcp br0 192.168.7.103 255.255.255.0 192.168.7.254 90.207.238.97 90.207.238.99 
***************
update_dns_resolv_file.49 enter update_dns_resolv_file 
can not open:/var/run/igmp_pid
ntp client success
br0: received packet on wlan0-vxd with own address as source address
watchdog: ERROR: watchdog_write_pidfile: /var/run/watchdog.pid contains pid 1402 which is still running; aborting
--------agent:108,snd get_sync-----
3431:{ "method": "sync_infomation", "sessionid": 3261, "type0": 0, "allmac0": "", "type1": 0, "allmac1": "", "name24g": "STRONG_ATRIA_2MRD_GUEST1_2G", "password24g": "00000000", "name5g": "STRONG_ATRIA_2MRD_GUEST1_5G", "password5g": "00000000", "disable_wifi_24": 1, "disable_wifi_5": 1, "on_duration_24": 0, "on_duration_5": 0, "on_duration_24_cur": 0, "on_duration_5_cur": 0, "schlist_enable": 0, "wsc_ssid24g": "XXXX", "wsc_password24g": "XXXX", "wsc_encrypt24g": 32, "wsc_auth24g": 8, "wsc_ssid5g": "XXXX", "wsc_password5g": "XXXXX", "wsc_encrypt5g": 32, "wsc_auth5g": 8, "5g_prefer": 1, "enable": 1, "timezone": "-1 1", "daylight": 1, "ntpServerIp0": "0.pool.ntp.org", "ntpServerIp1": "0.us.pool.ntp.org", "ntpsync": 86400, "year": 0, "mon": 0, "day": 0, "hour": 0, "min": 0, "sec": 0, "ledSwitch": 1, "usesrname": "admin", "userPwd": "PP!EZTkg43EvvWR", "controllerName": "MESH_AP_4C95", "controllerIp": "192.168.7.254", "controllerMac": "34:85:11:49:4c:95", "GwIp": "90.208.12.1", "controllerMode": "gw", "controllerSN": "120830112100475", "enable_0": 0, "coexist_enable_0": 0, "channel_bonding_0": 2, "channel_0": 0, "ssid_0": "XXXX", "hiddenSSID_0": 0, "encrypt_t_0": 4, "WPA_AUTH_0": 2, "WPA2_CIPHER_SUITE_0": 2, "PSK_FORMAT_0": 0, "WPA_PSK_0": "XXXX", "RS_IP_0": "", "RS_PORT_0": 1812, "RS_PASSWORD_0": "", "IEEE80211W_0": 0, "SHA256_ENABLE_0": 0, "enable_1": 0, "coexist_enable_1": 0, "channel_bonding_1": 0, "channel_1": 0, "ssid_1": "XXXX", "hiddenSSID_1": 0, "encrypt_t_1": 4, "WPA_AUTH_1": 2, "WPA2_CIPHER_SUITE_1": 2, "PSK_FORMAT_1": 0, "WPA_PSK_1": "XXXXX", "RS_IP_1": "", "RS_PORT_1": 1812, "RS_PASSWORD_1": "", "IEEE80211W_1": 0, "SHA256_ENABLE_1": 0, "Tr69Enable": 1, "CwmpFlag": 162, "Tr69Inform": 1, "InformCyc": 3600, "CwmpFlag2": 0, "ACSURL": "SkyBB-DHCP", "AcsUser": "tr069", "AcsPwd": "tr069", "ConPath": "\/tr069", "ConName": "itms", "ConPwd": "itms", "ConPort": 9090, "StunEnable": 1, "StunURL": "stunap.internet.com", "StunName": "stun", "StunPwd": "stun", "StunPort": 3478, "CertPwd": "", "DFS": 0 }
########################
941-0
########################
########################
1099-0
########################
212-0
222-0-0
243-
########################
1844-0
########################
########2510-0-1########
sky_controller_info:myMac:34:85:11:49:54:C1,conMac:34:85:11:49:4c:95
1338-36-0-0
1338-11-0-0
########################
1706-0
########################
sky_cwmp_info:Tr69:1,162
======compare cwmp info=========
########################
2748-0
########################
########################
3477-0
########################
br0: received packet on wlan0-vxd with own address as source address
Multi-ap select ch 1
Op class: 81, bandwidth: 0, sideband: 0
Op class: 115, bandwidth: 0, sideband: 0
[CONFIG] Max resend time for the message that doesn't acknowledged in time is 4
[CONFIG] Multi-AP alme port: 8888
[CONFIG] Rssi weightage is 9
[CONFIG] Path weightage is 1
[CONFIG] Cu weightage is 0
[CONFIG] Roam score difference is 20
[CONFIG] Min evaluation interval is 1
[CONFIG] Min roam interval is 18
[CONFIG] Max number of device allowed is 16
[CONFIG] Throughput threshold is 2500
[CONFIG] Enable pbc gpio monitoring
[CONFIG] Max bss number per radio is 5
[CONFIG] Device name set by user is MESH_AP_54C1
[CONFIG] 5GH radio name is: wlan0
[CONFIG] 5GL radio name is: wlan0
[CONFIG] 24G radio name is: wlan1
[CONFIG] VAP Prefix: va
Op class: 116, bandwidth: 1, sideband: 1
Op class: 128, bandwidth: 2, sideband: 0
[CONFIG] Max resend time for the message that doesn't acknowledged in time is 4
[CONFIG] Multi-AP alme port: 8888
[CONFIG] Rssi weightage is 9
[CONFIG] Path weightage is 1
[CONFIG] Cu weightage is 0
[CONFIG] Roam score difference is 20
[CONFIG] Min evaluation interval is 1
[CONFIG] Min roam interval is 18
[CONFIG] Max number of device allowed is 16
[CONFIG] Throughput threshold is 2500
[CONFIG] Enable pbc gpio monitoring
[CONFIG] Max bss number per radio is 5
[CONFIG] Device name set by user is MESH_AP_54C1
[CONFIG] 5GH radio name is: wlan0
[CONFIG] 5GL radio name is: wlan0
[CONFIG] 24G radio name is: wlan1
[CONFIG] VAP Prefix: va
6389:apmib_set:2
6389:apmib_set:2
6389:apmib_set:284
6389:apmib_set:284
get_controller_ip 478:ip:192.168.7.254
6389:apmib_set:285
--------agent:670,recv wired_rsp-----
get_controller_ip 478:ip:192.168.7.254
--------agent:670,recv wired_rsp-----
br0: received packet on wlan0-vxd with own address as source address
[889543.653] ERROR   : [Waiting Message] Discard the message (7ec0) after sent 4 times
rlx-linux login: root
Password: 
```
