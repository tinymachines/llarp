# MediaTek / Ralink

## General

- On May, 5th 2011, MediaTek bought Ralink.
- Most WNICs are supported by the `rt2x00` driver family. See [wireless.overview](/docs/guide-user/network/wifi/wireless.overview "docs:guide-user:network:wifi:wireless.overview")
- Websites with more background information
  
  - [Ralink](https://en.wikipedia.org/wiki/Ralink "https://en.wikipedia.org/wiki/Ralink")
  - [http://www.mediatek.com](http://www.mediatek.com "http://www.mediatek.com")
  - [http://wikidevi.com/wiki/Ralink](http://wikidevi.com/wiki/Ralink "http://wikidevi.com/wiki/Ralink")
  - [http://wikidevi.com/wiki/MediaTek](http://wikidevi.com/wiki/MediaTek "http://wikidevi.com/wiki/MediaTek")

## Ralink ramips

- A quite good source for product specs on MediaTek/Ralink SoCs is here: [https://deviwiki.com/wiki/Ralink](https://deviwiki.com/wiki/Ralink "https://deviwiki.com/wiki/Ralink").
- OpenWrt specific:
  
  - All old MediaTek/Ralink SoCs are merged under the target **`ramips`** .
  - Building a target requires a target-specific firmware. The kernel is patched with the command line that has the board name in it. This mechanism is similar to what is done for [ar71xx](/docs/techref/hardware/soc/soc.qualcomm.ar71xx "docs:techref:hardware:soc:soc.qualcomm.ar71xx") platforms.
  - Source code: [https://github.com/openwrt/openwrt/tree/master/target/linux/ramips](https://github.com/openwrt/openwrt/tree/master/target/linux/ramips "https://github.com/openwrt/openwrt/tree/master/target/linux/ramips")

Target Subtarget SoC MIPS **Cores** **Threads** **Max clock** RAM Ant Devices `ramips` RT288x RT2880 4KEc 1 1 300 MHz SDR 2T3R [see ToH](/toh/views/toh_dev_arch-target-cpu?dataflt%5BCPU%2A~%5D=RT2880 "toh:views:toh_dev_arch-target-cpu") RT3x5x/RT5350 RT3050 24KEc 1 1 384 MHz SDR 2T2R [see ToH](/toh/views/toh_dev_arch-target-cpu?dataflt%5BCPU%2A~%5D=RT3050 "toh:views:toh_dev_arch-target-cpu") RT3052 24KEc 1 1 384 MHz SDR 2T2R [see ToH](/toh/views/toh_dev_arch-target-cpu?dataflt%5BCPU%2A~%5D=RT3052 "toh:views:toh_dev_arch-target-cpu") RT3350 24KEc 1 1 384 MHz SDR 1T1R [see ToH](/toh/views/toh_dev_arch-target-cpu?dataflt%5BCPU%2A~%5D=RT3350 "toh:views:toh_dev_arch-target-cpu") RT3352 24KEc 1 1 400 MHz SDR/DDR2 2T2R [see ToH](/toh/views/toh_dev_arch-target-cpu?dataflt%5BCPU%2A~%5D=RT3352 "toh:views:toh_dev_arch-target-cpu") RT5350 24KEc 1 1 500 MHz SDR 1T1R [see ToH](/toh/views/toh_dev_arch-target-cpu?dataflt%5BCPU%2A~%5D=RT5350 "toh:views:toh_dev_arch-target-cpu") RT3662/RT3883 RT3662 74Kc 1 1 500 MHz SDR/DDR2 2T3R [see ToH](/toh/views/toh_dev_arch-target-cpu?dataflt%5BCPU%2A~%5D=RT3662 "toh:views:toh_dev_arch-target-cpu") RT3883 74Kc 1 1 500 MHz SDR/DDR2 3T3R [see ToH](/toh/views/toh_dev_arch-target-cpu?dataflt%5BCPU%2A~%5D=RT3883 "toh:views:toh_dev_arch-target-cpu") RT6856 RT6856 34KEc 1 ? 700 MHz DDR2 n/a [see ToH](/toh/views/toh_dev_arch-target-cpu?dataflt%5BCPU%2A~%5D=RT6856 "toh:views:toh_dev_arch-target-cpu") MT7620 MT7620a 24KEc 1 1 600 Mhz DDR2 2T2R [see ToH](/toh/views/toh_dev_arch-target-cpu?dataflt%5BCPU%2A~%5D=MT7620a "toh:views:toh_dev_arch-target-cpu") MT7620n 24KEc 1 1 600 Mhz SDR/DDR1/2 2T2R [see ToH](/toh/views/toh_dev_arch-target-cpu?dataflt%5BCPU%2A~%5D=MT7620n "toh:views:toh_dev_arch-target-cpu") MT7621 MT7621AT 1004Kc 2 4 880 MHz DDR2/3 n/a [see ToH](/toh/views/toh_dev_arch-target-cpu?dataflt%5BCPU%2A~%5D=MT7621A "toh:views:toh_dev_arch-target-cpu") MT7621DAT 1004Kc 2 4 880 MHz integrated 128MB DDR3 n/a [see ToH](/toh/views/toh_dev_arch-target-cpu?dataflt%5BCPU%2A~%5D=MT7621DA "toh:views:toh_dev_arch-target-cpu") MT7621NT 1004Kc 1 2 880 MHz DDR2 n/a [see ToH](/toh/views/toh_dev_arch-target-cpu?dataflt%5BCPU%2A~%5D=MT7621N "toh:views:toh_dev_arch-target-cpu") MT7621ST 1004Kc 1 2 880 MHz DDR2/3 n/a [see ToH](/toh/views/toh_dev_arch-target-cpu?dataflt%5BCPU%2A~%5D=MT7621S "toh:views:toh_dev_arch-target-cpu") [MT7628](https://www.mediatek.com/products/homeNetworking/mt7628k-n-a "https://www.mediatek.com/products/homeNetworking/mt7628k-n-a") MT7628 24kec 1 1 580 MHz DDR1/2 2T2R [see ToH](/toh/views/toh_dev_arch-target-cpu?dataflt%5BCPU%2A~%5D=MT7628 "toh:views:toh_dev_arch-target-cpu") MT7688 MT7688 24kec 1 1 580 MHz DDR1/2 1T1R [see ToH](/toh/views/toh_dev_arch-target-cpu?dataflt%5BCPU%2A~%5D=MT7688 "toh:views:toh_dev_arch-target-cpu")

- RT6856
  
  - Not supported
- MT7620 vs. RT5350
  
  - Chips are similar on the software layer
  - RT5350 is cheaper [http://cdn.sparkfun.com/datasheets/Wireless/WiFi/RT5350.pdf](http://cdn.sparkfun.com/datasheets/Wireless/WiFi/RT5350.pdf "http://cdn.sparkfun.com/datasheets/Wireless/WiFi/RT5350.pdf")
  - MT7620 is the successor, it's “faster and better”
  - Both use the `rt2800soc` driver.
  - No hardware support for 802.11w thus limiting WPA3 speed to ~14 Mbps. Use WPA2 for full throughput.
- MT7621
  
  - 2 cores, 4 threads:
    
    - MT7621AT
    - MT7621DAT: 128MB integrated RAM
  - 1 core, 2 threads:
    
    - MT7621NT, MT7621ST
  - SoC does not include a Wifi subsystem
  - [https://www.mediatek.com/products/homeNetworking/mt7621](https://www.mediatek.com/products/homeNetworking/mt7621 "https://www.mediatek.com/products/homeNetworking/mt7621")
  - [https://deviwiki.com/wiki/MediaTek\_MT7621](https://deviwiki.com/wiki/MediaTek_MT7621 "https://deviwiki.com/wiki/MediaTek_MT7621")
- MT7628
  
  - MT7628A: Full function with external DRAM
  - MT7628K: Embedded 8MB DRAM and L-shape
  - MT7628N: Same as MT7628A, but without PCle and IoT modes
  - MT7628DAN: 64MB integrated RAM
  - Chip uses a driver from the [mt76](/docs/techref/driver.wlan/mt76 "docs:techref:driver.wlan:mt76") family. 802.11w is hardware accelerated.

## MediaTek

New MediaTek SoCs are released under the much more performant Filogic line:

- Use quad core and hybrid core ARM architecture
- Includes support for DSA and hardware acceleration for flow offloading (HFO) and wireless offloading (WED)
- Depending on SoC includes Wi-Fi 6 and/or 7 under the [mt76](/docs/techref/driver.wlan/mt76 "docs:techref:driver.wlan:mt76") driver family
- 802.11w and WPA3 included in hardware
- Used in many devices such as OpenWrt One
- See Filogic link under Devices below for supported targets

## RGMII configuration

On MT7620A and likely other Ralink based SOCs, the RGMII delay is set with the Port I control register in the GSW (gigabit switch) subsystem. For boards with Uboot and an available console the register can be read with the command:

```
  md 0x10117014 1
```

The following bits tell you the OEM bootloader / chip defaults:

BIT(2)RX no delay BIT(3)TX delay BITS(16, 20)PHY\_BASE BITS(24, 28)PHY\_DISABLE

For a complete explanation, look for the register 0x7014 in the MT7620 Programming Guide. For example:

10117014: 1f08000c

c -→ 1100 -→ TX delay only

8 -→ PHY\_BASE address

1f -→ internal PHYs disabled

* * *

Remember to read bits from right to left. For example `1f08000c` in binary becomes `00011111000010000000000000001100`

```
0001 1111 0000 1000 0000 0000 0000 1100
   |    |    |    |    |    |    |    |   
  28   24   20   16   12    8    4    0
```

## MediaTek xDSL

### Products

#### ADSL

- [http://www.mediatek.com/\_en/01\_products/04\_pro.php?sn=1031](http://www.mediatek.com/_en/01_products/04_pro.php?sn=1031 "http://www.mediatek.com/_en/01_products/04_pro.php?sn=1031")
- [TC3085/TC3086](http://www.mediatek.com/_en/01_products/04_pro.php?sn=1031 "http://www.mediatek.com/_en/01_products/04_pro.php?sn=1031") includes AFE (Analog Front-End) for ADSL2+
- [TC3162L2M](http://www.mediatek.com/_en/01_products/04_pro.php?sn=1019 "http://www.mediatek.com/_en/01_products/04_pro.php?sn=1019") incorporates a 32-bit network processor and a DMT (Discrete Multi-Tone)-engine for ADSL2+
- [TC3162LEM](http://www.mediatek.com/_en/01_products/04_pro.php?sn=1019 "http://www.mediatek.com/_en/01_products/04_pro.php?sn=1019") incorporates a 32-bit network processor and a DMT (Discrete Multi-Tone)-engine for ADSL2+

#### VDSL

- [RT63260](http://www.mediatek.com/en/products/connectivity/xdsl/adsl-wifi/rt63260/ "http://www.mediatek.com/en/products/connectivity/xdsl/adsl-wifi/rt63260/") is a integrated single-chip solution combining AFE (Analog Front End) and an ADSL2/2+ wired ADSL modem application together on one chip. It includes a 32-bit network processor and a Discrete Multi-Tone (DMT) engine for ADSL.
- [RT63365](http://www.mediatek.com/en/products/connectivity/xdsl/adsl-wifi/rt63365/ "http://www.mediatek.com/en/products/connectivity/xdsl/adsl-wifi/rt63365/")
  
  - Combine with RT63087 AFE (Analog Front-End) for VDSL2
- [RT63368](http://www.mediatek.com/en/products/connectivity/xdsl/adsl-wifi/rt63368/ "http://www.mediatek.com/en/products/connectivity/xdsl/adsl-wifi/rt63368/") incorporates a MIPS 34Kc CPU and a DMT (Discrete Multi-Tone)-engine for VDSL2
  
  - Combine with RT63087 AFE (Analog Front-End) for VDSL2
- [RT65168](http://www.mediatek.com/en/products/connectivity/xdsl/adsl-wifi/RT65168/ "http://www.mediatek.com/en/products/connectivity/xdsl/adsl-wifi/RT65168/") incorporates a MIPS 34Kc CPU and a DMT (Discrete Multi-Tone)-engine for VDSL2
  
  - Combine with RT63095 AFE (Analog Front-End) for VDSL2

## Devices

The list of related devices:  
[MediaTek](/tag/mediatek?do=showtag&tag=MediaTek "tag:mediatek"), [MT7620a](/tag/mt7620a?do=showtag&tag=MT7620a "tag:mt7620a"), [MT7620N](/tag/mt7620n?do=showtag&tag=MT7620N "tag:mt7620n"), [MT7621](/tag/mt7621?do=showtag&tag=MT7621 "tag:mt7621"), [MT7628](/tag/mt7628?do=showtag&tag=MT7628 "tag:mt7628"), [MT7688](/tag/mt7688?do=showtag&tag=MT7688 "tag:mt7688"), [Ralink](/tag/ralink?do=showtag&tag=Ralink "tag:ralink"), [ramips](/tag/ramips?do=showtag&tag=ramips "tag:ramips"), [rt2880](/tag/rt2880?do=showtag&tag=rt2880 "tag:rt2880"), [rt3050](/tag/rt3050?do=showtag&tag=rt3050 "tag:rt3050"), [rt3052](/tag/rt3052?do=showtag&tag=rt3052 "tag:rt3052"), [rt3350](/tag/rt3350?do=showtag&tag=rt3350 "tag:rt3350"), [rt3352](/tag/rt3352?do=showtag&tag=rt3352 "tag:rt3352"), [rt3662](/tag/rt3662?do=showtag&tag=rt3662 "tag:rt3662"), [rt3883](/tag/rt3883?do=showtag&tag=rt3883 "tag:rt3883"), [rt5350](/tag/rt5350?do=showtag&tag=rt5350 "tag:rt5350"), [filogic](/tag/filogic?do=showtag&tag=filogic "tag:filogic")
