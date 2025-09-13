# Allwinner Sun4i/5i/6i/7i/9i (sunxi)

Various vendors are offering development boards / [single-board computer](https://en.wikipedia.org/wiki/single-board%20computer "https://en.wikipedia.org/wiki/single-board computer") based on the [Allwinner](https://en.wikipedia.org/wiki/Allwinner%20Technology "https://en.wikipedia.org/wiki/Allwinner Technology") SoCs. These are running various flavors of the A1x, A20, A31, and soon H3 SoCs, with different buildouts. The mach is called “sunxi”.

For some specs rather see [Allwinner\_Technology#A-Series](https://en.wikipedia.org/wiki/Allwinner_Technology#A-Series "https://en.wikipedia.org/wiki/Allwinner_Technology#A-Series").

## Supported Versions

Model Version Launch Date OpenWrt Version Supported Model Specific Notes A10 - CC/trunk Single Cortex-A8 A10s - CC/trunk Single Cortex-A8 A13 - CC/trunk Single Cortex-A8 A20 - CC/trunk Dual Cortex-A7 A23 - na Dual Cortex-A7 A31 - trunk Quad Cortex-A7 A33 - na Quad Cortex-A7 A64 - trunk Quad-core Cortex-A53 A80 - na 8-core big.LITTLE (4x A15 + 4x A7) H3 - trunk Quad-core Cortex-A7 H5 - trunk Quad-core Cortex-A53 H8 - na 8-core Cortex-A7

See also [Table of Hardware](/toh/views/toh_standard_all?datasrt=cpu&dataflt%5BCPU%2A~%5D=Allwinner "toh:views:toh_standard_all") for supported devices and their basic technical data.

## Hardware Highlights

Model SoC RAM [Storage](/docs/techref/flash.layout "docs:techref:flash.layout") Network USB [Serial](/docs/techref/hardware/port.serial "docs:techref:hardware:port.serial") [JTAG](/docs/techref/hardware/port.jtag "docs:techref:hardware:port.jtag") [UEXT](https://en.wikipedia.org/wiki/UEXT "https://en.wikipedia.org/wiki/UEXT") Other linux-sunxi page [BananaPi](/toh/lemaker/banana_pi "toh:lemaker:banana_pi") A20 1024MiB μSD Gigabit Ethernet 2x USB2 yes n/a n/a HDMI, SATA, audio, IR, RCA video out, CSI [Page](http://linux-sunxi.org/LeMaker_Banana_Pi "http://linux-sunxi.org/LeMaker_Banana_Pi") [BananaPi M2 Plus](/toh/sinovoip/banana_pi_m2_plus "toh:sinovoip:banana_pi_m2_plus") H3 1024MiB μSD, 8GB eMMC Gigabit Ethernet, Ampak AP6212 2x USB2, 1x USB OTG yes n/a n/a HDMI, IR, GPIO, CSI [Page](http://linux-sunxi.org/Sinovoip_Banana_Pi_M2%2B "http://linux-sunxi.org/Sinovoip_Banana_Pi_M2%2B") [BananaPro](/toh/lemaker/banana_pro "toh:lemaker:banana_pro") A20 1024MiB μSD Gigabit Ethernet, AP6181 BT+WLAN 2x USB2 yes n/a n/a HDMI, SATA, audio, IR, RCA video out, CSI [Page](http://linux-sunxi.org/LeMaker_Banana_Pro "http://linux-sunxi.org/LeMaker_Banana_Pro") [Cubieboard](/toh/cubietech/cubieboard "toh:cubietech:cubieboard") A10 1024MiB μSD, 4GB NAND Fast Ethernet 2x USB2 yes n/a yes HDMI, SATA, audio [Page](http://linux-sunxi.org/Cubieboard "http://linux-sunxi.org/Cubieboard") [Cubieboard2](/toh/cubietech/cubieboard2 "toh:cubietech:cubieboard2") A20 1024MiB μSD, 4GB NAND Fast Ethernet 2x USB2 yes n/a yes HDMI, SATA, audio [Page](http://linux-sunxi.org/Cubieboard2 "http://linux-sunxi.org/Cubieboard2") [hummingbird](/toh/merrii/hummingbird "toh:merrii:hummingbird") A31 1024/2048MiB μSD, 8/16GB NAND BCM WiFi, Gigabit Ethernet 2x USB2 yes n/a n/a HDMI, audio, IR [Page](http://linux-sunxi.org/Merrii_Hummingbird_A31 "http://linux-sunxi.org/Merrii_Hummingbird_A31") [Cubietruck](/toh/cubietech/cubietruck "toh:cubietech:cubietruck") A20 2048MiB μSD, 8GB NAND BCM WiFi, Gigabit Ethernet 2x USB2 yes n/a n/a HDMI, VGA, SATA, audio, IR, TOSlink [Page](http://linux-sunxi.org/Cubietruck "http://linux-sunxi.org/Cubietruck") [Lamobo R1](/toh/lamobo/bananapi_r1 "toh:lamobo:bananapi_r1") A20 1024MiB μSD RTL8192CU 802.11bgn 2T2R WiFi  
BCM53125 Gigabit Ethernet switch with 5 ports 1x USB2 Host, 1x USB2 OTG yes n/a n/a HDMI, SATA, audio, IR, CSI [Page](http://linux-sunxi.org/Lamobo_R1 "http://linux-sunxi.org/Lamobo_R1") [Olimex A10-OLinuXino-LIME](/toh/olimex/a10-olinuxino-lime "toh:olimex:a10-olinuxino-lime") A10 512MiB μSD Fast Ethernet 2x USB2 yes n/a yes HDMI, SATA [Page](http://linux-sunxi.org/A10-OLinuXino-LIME "http://linux-sunxi.org/A10-OLinuXino-LIME") [Olimex A13-OLinuXino-WIFI](/toh/olimex/a13-olinuxino "toh:olimex:a13-olinuxino") A13 512MiB μSD RTL WiFi 3x USB2 yes n/a yes VGA [Page](http://linux-sunxi.org/A13-OLinuXino "http://linux-sunxi.org/A13-OLinuXino") [Olimex A13-SOM](/toh/olimex/a13-som "toh:olimex:a13-som") A13 256/512MiB μSD, 4GB NAND RTL WiFi n/a yes n/a n/a n/a [Olimex A20-OLinuXino-MICRO](/toh/olimex/a20-olinuxino-micro "toh:olimex:a20-olinuxino-micro") A20 1024MiB SD, μSD, 4GB NAND Fast Ethernet 2x USB2 yes n/a yes HDMI, SATA, audio [Page](http://linux-sunxi.org/A20-olinuxino-micro "http://linux-sunxi.org/A20-olinuxino-micro") [Orange Pi Plus](/toh/xunlong/orange_pi_plus "toh:xunlong:orange_pi_plus") H3 1024MiB μSD Gigabit Ethernet 4x USB2 yes n/a n/a n/a [Page](http://linux-sunxi.org/Xunlong_Orange_Pi_Plus "http://linux-sunxi.org/Xunlong_Orange_Pi_Plus") [Orange Pi PC](/toh/xunlong/orange_pi_pc "toh:xunlong:orange_pi_pc") H3 512/1024MiB μSD Fast Ethernet 3x USB2 yes n/a n/a n/a [Page](http://linux-sunxi.org/Xunlong_Orange_Pi_PC "http://linux-sunxi.org/Xunlong_Orange_Pi_PC") [Orange Pi Zero](/toh/xunlong/orange_pi_zero "toh:xunlong:orange_pi_zero") H2+ 256/512MiB μSD Fast Ethernet, [XR819 Wi-Fi](http://linux-sunxi.org/Wifi#Allwinner "http://linux-sunxi.org/Wifi#Allwinner") 1x USB2 yes n/a n/a u.FL [Page](http://linux-sunxi.org/Xunlong_Orange_Pi_Zero "http://linux-sunxi.org/Xunlong_Orange_Pi_Zero") [Orange Pi Zero Plus](/toh/xunlong/orangepizeroplus "toh:xunlong:orangepizeroplus") H5 512MiB μSD Gigabit Ethernet, [RTL8189FTV](http://linux-sunxi.org/Wifi#RTL8189FTV "http://linux-sunxi.org/Wifi#RTL8189FTV") (WiFi [Unsupported](http://lists.openwrt.org/pipermail/openwrt-devel/2018-March/011517.html "http://lists.openwrt.org/pipermail/openwrt-devel/2018-March/011517.html")) 1x USB2 yes n/a n/a u.FL [Page](http://linux-sunxi.org/Xunlong_Orange_Pi_Zero_Plus "http://linux-sunxi.org/Xunlong_Orange_Pi_Zero_Plus") [pcDuino/pcDuinoV2](/toh/linksprite/pcduino "toh:linksprite:pcduino") A10 1024MiB μSD, 2GB NAND Fast Ethernet 2x USB2 yes n/a n/a HDMI / Arduino headers [Page](http://linux-sunxi.org/LinkSprite_pcDuino_V2 "http://linux-sunxi.org/LinkSprite_pcDuino_V2") [pcDuino3](/toh/linksprite/pcduino3 "toh:linksprite:pcduino3") A20 1024MiB μSD, 4GB NAND Fast Ethernet, RTL8188EU WiFi 1x USB2 yes n/a n/a HDMI / Arduino headers, SATA, IR [Page](http://linux-sunxi.org/LinkSprite_pcDuino_V3 "http://linux-sunxi.org/LinkSprite_pcDuino_V3") [pcDuino8 / Arches](/toh/pcduino/pcduino8 "toh:pcduino:pcduino8") A80 2048MiB μSD, 8GB NAND BCM WiFi (AMPAK 6330), Gigabit Ethernet 2x USB2 yes n/a n/a HDMI / IR [Page](http://linux-sunxi.org/Pcduino8_A80_Board "http://linux-sunxi.org/Pcduino8_A80_Board") [Pine64 / PINE A64](/toh/pine64/pine_a64plus "toh:pine64:pine_a64plus") A64 512MiB μSD Fast Ethernet 2x USB2 yes n/a n/a HDMI / Audio / GPIO [Page](http://linux-sunxi.org/Pine64 "http://linux-sunxi.org/Pine64") [Pine64 / PINE A64+](/toh/pine64/pine_a64plus "toh:pine64:pine_a64plus") A64 1024/2048MiB μSD Gigabit Ethernet 2x USB2 yes n/a n/a HDMI / Audio / GPIO [Page](http://linux-sunxi.org/Pine64 "http://linux-sunxi.org/Pine64")

[UEXT](https://en.wikipedia.org/wiki/UEXT "https://en.wikipedia.org/wiki/UEXT") is an open standard port to provide serial, I²C and SPI expansion ports.

## Status

Patches have been back-ported from the [http://linux-sunxi.org/](http://linux-sunxi.org/ "http://linux-sunxi.org/") community, including device trees, clocks, timers, PIO, ethernet, USB, and, MMC. These patches are being mainlined as they come online by the community.

- SPL: done
- u-boot: done
- kernel: done
- rootfs: done

You have the option to boot the board from initramfs, SD card (recommended), USB storage, or NFS.

### Working

- SD/MMC
- USB EHCI/OHCI
- EMAC (A10 10/100 Mbps)
- GMAC (A20 and above, 10/100/1000 Mbps)
- SATA
- Clocks
- Timers
- SMP with HYP patches for A20
- Various devices, GPIO, IR

### Being worked on

- NAND (have some snippets already)
- Audio
- SPI (need integration)

## Installing OpenWrt

This section details what is required to install and upgrade OpenWrt. The generic procedure is described here: [generic.flashing](/docs/guide-user/installation/generic.flashing "docs:guide-user:installation:generic.flashing"); these devices don't have a flash chip soldered to the PCB but an SD-Card slot.

### Pre-built release and snapshot images

[OpenWrt firmware downloads for sunxi](#folded_66998246643ca355b3bde066069c2239_1)

### Trunk - Pre-built SD card images

**Outdated Information!**  
This article contains information that is outdated or no longer valid. You can edit this page to update it.

You can build an SD card image directly from buildroot for your device.

- Check out trunk - [https://dev.openwrt.org/wiki/GetSource](https://dev.openwrt.org/wiki/GetSource "https://dev.openwrt.org/wiki/GetSource")
- Run `make menuconfig`
- Select device profile - f.e. BananaPi
- Start the build
- The built SD card images will be in bin/sunxi
- `dd if=bin/sunxi/openwrt-sunxi-Bananapi-sdcard-vfat-ext4.img of=/dev/sdc`

### Chaos Calmer - Assembling the SD card image yourself

OpenWrt CC trunk images are located in [snapshots/trunk/sunxi/](http://downloads.openwrt.org/snapshots/trunk/sunxi/ "http://downloads.openwrt.org/snapshots/trunk/sunxi/") folder.

For example if you have Cubieboard3/Cubietruck then download these files from the server:

- [openwrt-sunxi-Cubietruck-u-boot-with-spl.bin](http://downloads.openwrt.org/snapshots/trunk/sunxi/generic/uboot-sunxi-Cubietruck/openwrt-sunxi-Cubietruck-u-boot-with-spl.bin "http://downloads.openwrt.org/snapshots/trunk/sunxi/generic/uboot-sunxi-Cubietruck/openwrt-sunxi-Cubietruck-u-boot-with-spl.bin")
- [openwrt-sunxi-Cubietruck-uEnv.txt](http://downloads.openwrt.org/snapshots/trunk/sunxi/generic/uboot-sunxi-Cubietruck/openwrt-sunxi-Cubietruck-uEnv.txt "http://downloads.openwrt.org/snapshots/trunk/sunxi/generic/uboot-sunxi-Cubietruck/openwrt-sunxi-Cubietruck-uEnv.txt")
- [sun7i-a20-cubietruck.dtb](http://downloads.openwrt.org/snapshots/trunk/sunxi/generic/sun7i-a20-cubietruck.dtb "http://downloads.openwrt.org/snapshots/trunk/sunxi/generic/sun7i-a20-cubietruck.dtb")
- [openwrt-sunxi-uImage](http://downloads.openwrt.org/snapshots/trunk/sunxi/generic/openwrt-sunxi-uImage "http://downloads.openwrt.org/snapshots/trunk/sunxi/generic/openwrt-sunxi-uImage")
- [openwrt-sunxi-root.ext4](http://downloads.openwrt.org/snapshots/trunk/sunxi/generic/openwrt-sunxi-root.ext4 "http://downloads.openwrt.org/snapshots/trunk/sunxi/generic/openwrt-sunxi-root.ext4")

### SD layout

SD layout with 512 byte blocks:

NAME start block size MBR 0 1 block u-boot-with-spl.bin 16 (8 KB) ~250 KB FAT 2048 (1 MB) 15 MB EXT4 32768 (16 MB) rest

### SD preparation

We assume **/dev/mmcblk0** is the SD card and **Cubietruck** is the board.

- Partition the SD card. Two partitions are created. The first is the boot partition, **/dev/mmcblk0p1**. The second is the root partition, **/dev/mmcblk0p2**.
  
  ```
  # fdisk /dev/mmcblk0
  
  Command (m for help): n
  Partition type:
     p   primary (0 primary, 0 extended, 4 free)
     e   extended
  Select (default p): p
  Partition number (1-4, default 1): 1
  First sector (2048-15523839, default 2048): 2048
  Last sector, +sectors or +size{K,M,G} (2048-15523839, default 15523839): +15M 
  
  Command (m for help): n
  Partition type:
     p   primary (1 primary, 0 extended, 3 free)
     e   extended
  Select (default p): p    
  Partition number (1-4, default 2): 2
  First sector (32768-15523839, default 32768): 32768
  Last sector, +sectors or +size{K,M,G} (32768-15523839, default 15523839): +240M
  
  Command (m for help): p
  
  Disk /dev/mmcblk0: 7948 MB, 7948206080 bytes
  4 heads, 16 sectors/track, 242560 cylinders, total 15523840 sectors
  Units = sectors of 1 * 512 = 512 bytes
  Sector size (logical/physical): 512 bytes / 512 bytes
  I/O size (minimum/optimal): 512 bytes / 512 bytes
  Disk identifier: 0x17002d14
  
          Device Boot      Start         End      Blocks   Id  System
  /dev/mmcblk0p1            2048       32767       15360   83  Linux
  /dev/mmcblk0p2           32768      524287      245760   83  Linux
  
  Command (m for help): w
  The partition table has been altered!
  
  Calling ioctl() to re-read partition table.
  ```

<!--THE END-->

- Re-read the new partition table layout (e.g. by removing and re-inserting the SD card).
- Copy the SPL + U-boot image to the card
  
  ```
  # dd if=bin/sunxi/uboot-sunxi-Cubietruck/openwrt-sunxi-Cubietruck-u-boot-with-spl.bin of=/dev/mmcblk0 bs=1024 seek=8
  ```
- Create a boot (FAT32) partition.
  
  ```
  # mkfs.vfat /dev/mmcblk0p1
  ```
- Mount the boot partition.
  
  ```
  # mount -t vfat /dev/mmcblk0p1 /mnt
  ```
- Copy the U-Boot environment file uEnv.txt to the boot partition.
  
  ```
  # cp bin/sunxi/uboot-sunxi-Cubietruck/openwrt-sunxi-Cubietruck-uEnv.txt /mnt/uEnv.txt
  ```

<!--THE END-->

- Copy the boot.scr containing needed uboot commands for loading, setting kernel parameters and booting to the boot partition.
  
  ```
  # cp bin/sunxi/sun7i-a20-cubietruck.scr /mnt/boot.scr
  ```

<!--THE END-->

- Copy the device tree data to the boot partition.
  
  ```
  # cp bin/sunxi/sun7i-a20-cubietruck.dtb /mnt/dtb
  ```

<!--THE END-->

- Copy the kernel image to the boot partition.
  
  ```
  # cp bin/sunxi/openwrt-sunxi-uImage /mnt/uImage
  ```

<!--THE END-->

- Resize the root filesystem image to match the partition size.
  
  ```
  # resize2fs bin/sunxi/openwrt-sunxi-root.ext4 240M
  ```

<!--THE END-->

- Create the root filesystem.
  
  ```
  # dd if=bin/sunxi/openwrt-sunxi-root.ext4 of=/dev/mmcblk0p2 bs=128k
  ```

<!--THE END-->

- Wrap up (flush buffers and unmount boot partition).
  
  ```
  # sync
  # umount /mnt
  ```

## Upgrading OpenWrt

→[generic.sysupgrade](/docs/guide-user/installation/generic.sysupgrade "docs:guide-user:installation:generic.sysupgrade")

sysupgrade works out of the box, using (at least) the ext4-sdcard.img.gz files.

## Links

For further information about the SoCs, go to [http://linux-sunxi.org/Main\_Page](http://linux-sunxi.org/Main_Page "http://linux-sunxi.org/Main_Page")

## How can you help

- We're looking for any A31 / A80 / H3 hardware at the moment
- Hardware donations - [https://dev.openwrt.org/wiki/WantedHardware](https://dev.openwrt.org/wiki/WantedHardware "https://dev.openwrt.org/wiki/WantedHardware")
- Test GPIOs and peripherals on A13/A20 and provide feedback

## Devices

List of related devices: [sunxi](/tag/sunxi?do=showtag&tag=sunxi "tag:sunxi")
