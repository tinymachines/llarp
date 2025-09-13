# USB Benchmarks

These benchmarks provide a rough estimate of how USB devices perform on various hardware and software configurations.

![](/_media/meta/icons/tango/48px-dialog-error-round.svg.png) I see two possible bottlenecks when bechmarking read/write operations on a storage device: the CPU and the device itself.  
\* If you expected notable differences between the [cpu](/docs/techref/hardware/cpu "docs:techref:hardware:cpu")s, you would conduct a series of benchmark with the same storage device but different CPUs. You would also make sure that the storage device used in this benchmark is NOT a bottle neck.  
\* If you expected notable differences between the storage devices, you would conduct a series of benchmarks with the same CPU, but different storage devices. Again, you would make sure, that the CPU is not the bottle neck!  
\* there is of course a third possible bottle neck: the USB controller (MAC+PHY) on the SoC and/or possibly the USB-to-SATA converter, in case you use a SATA hard disk. ![;-)](/lib/images/smileys/wink.svg)

I do not know, about notable differences in CPU, but there definitely are very slow flash storage devices purchasable out there with maximum read/write “speeds” of &lt; 2MB/s and less!!!

## Prerequisites

- Install benchmark utilities 'hdparm' and 'bonnie++'
  
  ```
  opkg update
  opkg install hdparm bonniexx
  ```
- Install USB drivers
  
  ```
   opkg install kmod-usb2 kmod-usb-storage   kmod-fs-ext4  block-mount
  ```

## USB Flash drives

- Run the followings commands:
  
  ```
  hdparm -Tt /dev/sda#
  ```
  
  ```
  mkdir -p /mnt/benchmark
  ```
  
  ```
  mount -O rw,noatime -t ext4 /dev/sda# /mnt/benchmark
  bonnie++ -n 0 -u 0 -s 64 -f -b -d /mnt/benchmark
  ```
- `hdparm` and `bonnie++` are **non-destructive** benchmarks
- bonnie should auto-detect RAM size but you may need to use '-r' parameter to override. Also you may adjust '-s' to be double of '-r'.

Router Flash Drive hdparm bonnie++ Timing (MB/s) Sequential Output (KB/s) Sequential Input (KB/s) Random Device USB Software Version Drive USB Filesystem Cached Reads Buffered Disk Reads Block Rewrite Block Seeks/s D-Link DIR-835 rev. A1 A1 Attitude Adjustment, r39789 [UDisk](http://www.aliexpress.com/store/product/Free-Shipping-Super-Low-Price-128MB-8GB-16GB-32GB-64GB-Swivel-USB-2-0-Flash-Drive/1036461_1486356715.html "http://www.aliexpress.com/store/product/Free-Shipping-Super-Low-Price-128MB-8GB-16GB-32GB-64GB-Swivel-USB-2-0-Flash-Drive/1036461_1486356715.html"), 64GiB (59.9GB) 2.0 ext4 88.51 13.63 4721 4216 128686 12.5 (not a typo) [TP-Link Archer C6U v1](/toh/tp-link/archer_c6u_v1_eu "toh:tp-link:archer_c6u_v1_eu") 2.0 21.02.3 r16554 Kingston DT 100G3 64G 3.2 ext4 128.70 22.06 2866 1533 20200 179.5 D-Link DIR-835 rev. A1 A1 Attitude Adjustment, r39789 [UDisk](http://www.aliexpress.com/store/product/Free-Shipping-Super-Low-Price-128MB-8GB-16GB-32GB-64GB-Swivel-USB-2-0-Flash-Drive/1036461_1486356715.html "http://www.aliexpress.com/store/product/Free-Shipping-Super-Low-Price-128MB-8GB-16GB-32GB-64GB-Swivel-USB-2-0-Flash-Drive/1036461_1486356715.html"), 64GiB (59.9GB) 2.0 vfat 87.48 13.35 ? ? ? ? [TP-Link TL-WR1043ND](/toh/tp-link/tl-wr1043nd "toh:tp-link:tl-wr1043nd") v1.8 2.0 Attitude Adjustment, r33883 SanDisk Cruzer Extreme, 32GB (PID: SDCZ80-032G-X46) 3.0 ext4 106.40 24.21 22,124 12,774 29,664 718.6 [TP-Link TL-WR1043ND](/toh/tp-link/tl-wr1043nd "toh:tp-link:tl-wr1043nd") v1.8 2.0 Attitude Adjustment, r33883 Unknown Manufacturer, 2GB 2.0 ext4 89.17 13.41 1,623 1,485 14,661 73.6 [TP-Link TL-MR3020](/toh/tp-link/tl-mr3020 "toh:tp-link:tl-mr3020") v1.6 2.0 Attitude Adjustment, r33883 SanDisk Cruzer Fit, 16GB (PID: SDCZ33-016G-B35) 2.0 ext4 70.27 18.65 5,091 3,254 19,499 33.7 [TP-Link TL-MR3020](/toh/tp-link/tl-mr3020 "toh:tp-link:tl-mr3020") v1.6 2.0 Attitude Adjustment, r33883 Kingston DTSE9H, 16GB 2.0 ext4 72.93 17.19 11,519 6,998 17,661 339.6 [TP-Link TL-MR3220](/toh/tp-link/tl-mr3220 "toh:tp-link:tl-mr3220") v1.0 2.0 Attitude Adjustment, r36088 Lexar Jumpdrive S73, 32GB 3.0 ext4 without journal 75.07 26.07 24,395 12,403 30,900 200.2 [TP-Link TL-WR842ND](/toh/tp-link/tl-wr842nd "toh:tp-link:tl-wr842nd") v1.0 2.0 Attitude Adjustment, r33312 SanDisk Cruzer Fit, 16GB (PID: SDCZ33-016G-B35) 2.0 ext4 73.40 18.88 5,053 3,227 20,335 34.2 [TP-Link TL-WR842ND](/toh/tp-link/tl-wr842nd "toh:tp-link:tl-wr842nd") v1.0 2.0 Attitude Adjustment, r33312 Kingston DTSE9H, 16GB 2.0 ext4 71.51 16.44 12,548 6,758 17,849 330.9 [TP-Link TL-WR842ND](/toh/tp-link/tl-wr842nd "toh:tp-link:tl-wr842nd") v1.0 2.0 Attitude Adjustment, r34185 (12.09-rc1) Seagate Free Agent Desktop, 250GB 2.0 ext4 data=ordered barrier=1 72.15 23.12 15,895 or [31,864](https://forum.openwrt.org/viewtopic.php?id=28574 "https://forum.openwrt.org/viewtopic.php?id=28574") 9,900 or [12,645](https://forum.openwrt.org/viewtopic.php?id=28574 "https://forum.openwrt.org/viewtopic.php?id=28574") 26,373 or [33,142](https://forum.openwrt.org/viewtopic.php?id=28574 "https://forum.openwrt.org/viewtopic.php?id=28574") 94.0 or [117.7](https://forum.openwrt.org/viewtopic.php?id=28574 "https://forum.openwrt.org/viewtopic.php?id=28574") [Linksys WRT160NL-DE](/toh/linksys/wrt160nl "toh:linksys:wrt160nl") v1.0 2.0 Attitude Adjustment, r33312 SanDisk Cruzer Fit, 16GB (PID: SDCZ33-016G-B35) 2.0 ext4 106.4 17.8 5,019 3,286 19,500 37.4 [Linksys WRT160NL-DE](/toh/linksys/wrt160nl "toh:linksys:wrt160nl") v1.0 2.0 Attitude Adjustment, r33883 Kingston DTSE9H, 16GB 2.0 ext4 99.75 15.64 12,405 6,727 21,925 324.6 [Buffalo WZR-HP-G300H-EU](/toh/buffalo/wzr-hp-g300h "toh:buffalo:wzr-hp-g300h") v1.0 2.0 Attitude Adjustment, r33312 SanDisk Cruzer Fit, 16GB (PID: SDCZ33-016G-B35) 2.0 ext4 158.53 19.92 5,240 3,866 +++++ 36.1 [Buffalo WZR-HP-G300H-EU](/toh/buffalo/wzr-hp-g300h "toh:buffalo:wzr-hp-g300h") v1.0 2.0 Attitude Adjustment, r33312 Kingston DTSE9H, 16GB 2.0 ext4 133.21 16.61 16,485 17,118 65,676 969.1 [Buffalo WZR-600DHP](/toh/buffalo/wzr-600dhp "toh:buffalo:wzr-600dhp") 2.0 Barrier Breaker, r42625 Kinsgtom Elite Pro 133x 8GB Compact Flash Card 2.0 ext4 153.55 15.41 12177 11935 +++++ 86.8 [ARV4518PW](/toh/arcadyan/arv4518pw "toh:arcadyan:arv4518pw") 2.0 Barrier Breaker, r35905 Maxell, 4GB 2.0 ext4 57.97 12.86 3,776 2,918 16,518 17.1 [AW1000](/toh/arcadyan/astoria/aw1000 "toh:arcadyan:astoria:aw1000") 3.0 24.10.0, r28427 Asus FA100, 512GB + ORICO M.2 NVME SSD adapter 3.0 extfs 912.92 354.67 349m 185m 342m 4787 [VR-3025un](/toh/comtrend/vr-3025un "toh:comtrend:vr-3025un") 2.0 Barrier Breaker, r37514 Maxell, 4GB 2.0 ext4 87.66 12.82 2,743 2,654 19,213 16.9 [VR-3025un SMP](/toh/comtrend/vr-3025un "toh:comtrend:vr-3025un") 2.0 Barrier Breaker, r37842 Maxell, 4GB 2.0 ext4 116.20 13.24 3,815 2,939 18,480 18.4 [Wyse Winterm S10](http://www.parkytowers.me.uk/thin/wyse/s10/index.shtml "http://www.parkytowers.me.uk/thin/wyse/s10/index.shtml") 2.0 Attitude Adjustment, r34668 Maxell, 4GB 2.0 ext4 134.98 13.72 3,861 3,167 18,472 17.6 [TP-Link TL-WDR4300](/toh/tp-link/tl-wdr4300_v1 "toh:tp-link:tl-wdr4300_v1") v.1.1 2.0 Attitude Adjustment, r34185 (12.09-rc1) Unknown Manufacturer,[1)](#fn__1) 2GB 2.0 ext4 82.57 9.85 272 599 +++++ 36.2 [TP-Link TL-WDR4300](/toh/tp-link/tl-wdr4300_v1 "toh:tp-link:tl-wdr4300_v1") v.1.1 2.0 Attitude Adjustment, r34185 (12.09-rc1) SanDisk Corp. Cruzer Glide, 8GB (PID: SDCZ60-008G) 2.0 ext4 89.17 20.43 10,901 11,741 +++++ 1,458 TP-Link VR200v 2.0 21.02.1 r16325 SanDisk 4GB 2.0 vfat 99.13 23.45 5,065 4,088 22,600 467.5

*Sequential Output = Write performance*  
*Sequential Input = Read performance*  
*Random Seeks = IOPS*

## USB Hard drives

- Run the followings commands:
  
  ```
  hdparm -Tt /dev/sda#
  ```
  
  ```
  mkdir -p /mnt/benchmark
  ```
  
  ```
  mount -O rw,noatime -t ext4 /dev/sda# /mnt/benchmark
  bonnie++ -n 0 -u 0 -s 64 -f -b -d /mnt/benchmark
  ```
- `hdparm` and `bonnie++` are **non-destructive** benchmarks
- bonnie should auto-detect RAM size but you may need to use `-r` parameter to override. Also you may adjust `-s` to be double of `-r`.

Router Hard Drive hdparm bonnie++ Timing (MB/s) Sequential Output (KB/s) Sequential Input (KB/s) Random Device USB Software Version Drive USB Filesystem Cached Reads Buffered Disk Reads Block Rewrite Block Seeks/s [Buffalo WZR-HP-AG300H](/toh/buffalo/wzr-hp-ag300h "toh:buffalo:wzr-hp-ag300h") 2.0 Attitude Adjustment, r31761 Seagate 2TB 2.0 ext4 134.75 27.87 30,757 31.057 +++++ 186.0 [TL-WR842ND](/toh/tp-link/tl-wr842nd "toh:tp-link:tl-wr842nd") 2.0 Attitude Adjustment, r36088 WD 750MB 3.0 xfs 69.51 17.98 4,100 3,911 24,651 103.8 TP-Link VR200v 2.0 21.02.1 r16325 Seagate 1TB 3.0 ext4 116.96 24.26 19,300 11,300 21,700 88.2

[1)](#fnt__1)

Presents as “`Kingston Technology Company Inc. DataTraveler 2.0 1GB/4GB Flash Drive / Patriot Xporter 4GB Flash Drive`” in `lsusb`

*Sequential Output = Write performance*  
*Sequential Input = Read performance*  
*Random Seeks = IOPS*

[1)](#fnt__1)

Presents as “`Kingston Technology Company Inc. DataTraveler 2.0 1GB/4GB Flash Drive / Patriot Xporter 4GB Flash Drive`” in `lsusb`
