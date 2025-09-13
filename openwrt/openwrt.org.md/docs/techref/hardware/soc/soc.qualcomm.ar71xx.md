# Qualcomm Atheros AR7xxx, AR9xxx and QCA9xxx boards

- Manfacturer: [Atheros](https://en.wikipedia.org/wiki/Atheros "https://en.wikipedia.org/wiki/Atheros") now subsidiary of [Qualcomm](https://en.wikipedia.org/wiki/Qualcomm "https://en.wikipedia.org/wiki/Qualcomm")

![FIXME](/lib/images/smileys/fixme.svg): now that we have a separate page for [AR5xxx](/docs/techref/hardware/soc/soc.qualcomm.ar5xxx "docs:techref:hardware:soc:soc.qualcomm.ar5xxx"), shouldn't we make separate pages for AR7xxx, AR9xxx and QCA9xxx as well? Otherwise is there a logical reason to have them in one article? Just because it's all in the ar7xx source tree? If so, please explain here, with a short intro to the platform(s).

## ar7xxx

Boards based on current Atheros AR71xx/AR7240 CPUs/SoCs. Note that in OpenWrt builds the ar71xx targets require target-specific firmware (that is, most devices need customised firmware). The kernel is patched with the command line that has the board name in it. This is like [ramips](/docs/techref/hardware/soc/soc.ralink "docs:techref:hardware:soc:soc.ralink") boards, which need to have a dts file embedded, so they're board-specific too.

### AR7161

#### Description

- AR7161 integrates ![FIXME](/lib/images/smileys/fixme.svg) lorema, please fix, you probably know this ![;-)](/lib/images/smileys/wink.svg)

#### AR7161-based Devices

- [see ToH](/toh/views/toh_dev_arch-target-cpu?dataflt%5BCPU%2A~%5D=AR7240 "toh:views:toh_dev_arch-target-cpu") or [AR7161](/tag/ar7161?do=showtag&tag=AR7161 "tag:ar7161")

### AR7240

#### Description

- ![FIXME](/lib/images/smileys/fixme.svg)
- MACs
- Fast Ethernet switch core
- 5 Fast Ethernet PHYs

#### AR7240-based Devices

- [see ToH](/toh/views/toh_dev_arch-target-cpu?dataflt%5BCPU%2A~%5D=AR7240 "toh:views:toh_dev_arch-target-cpu") or [AR7240](/tag/ar7240?do=showtag&tag=AR7240 "tag:ar7240")

## ar9xxx

Boards based on current Atheros AR913x/AR933x CPUs/SoCs. As of January 2009, active work is under way to get OpenWrt running well on AR9100 routers. AR9132 400Mhz MIPS CPU seems to be on all models, [Das U-Boot](/docs/techref/bootloader/uboot "docs:techref:bootloader:uboot") is the most frequent [bootloader](/docs/techref/bootloader "docs:techref:bootloader"), all seem to have 32MB of RAM and at least 4MB of FLASH. The CPU is typically paired with the AR9102 (2×2 MIMO), or AR9103 (3×3 MIMO) radio chip. Check the Kamikaze forums for latest information.please don't direct to old forums

### AR9130

#### Description

- Dual Fast Ethernet MAC
- AP81 is the reference design for AR9130, single band 2.4 GHz
  
  - ![FIXME](/lib/images/smileys/fixme.svg): merge these into ToH
    
    - Atlantiland A02-RB-W300N
    - Cameo Communications WLN2206, FCC id same as Trendnet TEW-632BRP according to SmallNetBuilder website
    - Mercury MWR300T+, ar9103 3×3 MIMO, details: [http://bbs.whbear.com/thread-62276-1-1.html](http://bbs.whbear.com/thread-62276-1-1.html "http://bbs.whbear.com/thread-62276-1-1.html"), probably a clone of the [TP-Link TL-WR941ND](/toh/tp-link/tl-wr941nd "toh:tp-link:tl-wr941nd") because it uses the same firmware.
    - Unex RNEA-81: AP83 AR9130+AR9104
    - Zyxel
      
      - X550N, X550NH, 401764. They run ZyOS (not Linux) but the bootloader seems flexible. Info: [http://en.network01.net/modules/newbb/viewtopic.php?topic\_id=15&amp;forum=2](http://en.network01.net/modules/newbb/viewtopic.php?topic_id=15&forum=2 "http://en.network01.net/modules/newbb/viewtopic.php?topic_id=15&forum=2")
- AP83 is the reference design for AR9130, dual band 2.4 GHz and 5 GHz
  
  - ![FIXME](/lib/images/smileys/fixme.svg): merge these into ToH and link
    
    - Unex RNRA-83, [http://www.unex.com.tw/spec/rnra-83](http://www.unex.com.tw/spec/rnra-83 "http://www.unex.com.tw/spec/rnra-83")
    - ARADA SoC Econo Series 2
    - Linksys WAP-4410N, if you read the release notes for the firmware on this router you will clearly see AP83 reference.

[atheros-ap83](/tag/atheros-ap83?do=showtag&tag=atheros-ap83 "tag:atheros-ap83")

#### AR9130 based devices

- [see ToH](/toh/views/toh_dev_arch-target-cpu?dataflt%5BCPU%2A~%5D=AR9130 "toh:views:toh_dev_arch-target-cpu") or [AR9130](/tag/ar9130?do=showtag&tag=AR9130 "tag:ar9130")

### AR9131

#### Description

- AP121 is the reference design for AR9331

[ap121](/tag/ap121?do=showtag&tag=ap121 "tag:ap121")

#### AR9131 based devices

- [see ToH](/toh/views/toh_dev_arch-target-cpu?dataflt%5BCPU%2A~%5D=AR9131 "toh:views:toh_dev_arch-target-cpu") or [AR9131](/tag/ar9131?do=showtag&tag=AR9131 "tag:ar9131")

### AR9132

#### Description

- Dual Gigabit Ethernet MAC

#### AR9132 based devices

- [see ToH](/toh/views/toh_dev_arch-target-cpu?dataflt%5BCPU%2A~%5D=AR9132 "toh:views:toh_dev_arch-target-cpu") or [AR9132](/tag/ar9132?do=showtag&tag=AR9132 "tag:ar9132")

### AR9331

#### Description

- Architecture: [MIPS](https://en.wikipedia.org/wiki/MIPS%20architecture "https://en.wikipedia.org/wiki/MIPS architecture") 24Kc V7.4
- Datasheet: [https://www.openhacks.com/uploadsproductos/ar9331\_datasheet.pdf](https://www.openhacks.com/uploadsproductos/ar9331_datasheet.pdf "https://www.openhacks.com/uploadsproductos/ar9331_datasheet.pdf")
- [https://wikidevi.com/wiki/Atheros\_AR9331](https://wikidevi.com/wiki/Atheros_AR9331 "https://wikidevi.com/wiki/Atheros_AR9331")
- Features:
  
  - 2 Gbit MACs
  - 5 port Fast Ethernet switch
  - 802.11n 1×1 MAC/BB/ radio with internal PA and LNA.
  - 802.11n operations up to 72 Mbps for 20 MHz and 150 Mbps for 40 MHz channel respectively, and IEEE 802.11b/g data rates.
- Pinout (from [ar9331\_pinout](/toh/tp-link/tl-wr703n/ar9331_pinout "toh:tp-link:tl-wr703n:ar9331_pinout")): [![](/_media/media/datasheets/ar9331.pinout.bg.png?w=200&tok=594c23)](/_detail/media/datasheets/ar9331.pinout.bg.png?id=docs%3Atechref%3Ahardware%3Asoc%3Asoc.qualcomm.ar71xx "media:datasheets:ar9331.pinout.bg.png"), [![](/_media/media/datasheets/ar9331.png?w=200&tok=1059a8)](/_detail/media/datasheets/ar9331.png?id=docs%3Atechref%3Ahardware%3Asoc%3Asoc.qualcomm.ar71xx "media:datasheets:ar9331.png")
- Requires a WiFi firmware called “ART” (Atheros Radio Test). It holds device specific wireless calibration data, thus using a generic or the wrong firmware causes FCC incompliance and poor wireless performance. Usually the firmware is stored in an ART partition located at the last 64KiB of the flash. If the ART partition is missing or corrupt, `ath9k` (wireless driver) won't come up anymore.
- there is also a special [U-Boot version based on 1.1.4](/docs/techref/bootloader/uboot#das_u-boot_modifications "docs:techref:bootloader:uboot") for this SoC (and others)

#### AR9331 based devices

- [see ToH](/toh/views/toh_dev_arch-target-cpu?dataflt%5BCPU%2A~%5D=AR9331 "toh:views:toh_dev_arch-target-cpu") or [AR9331](/tag/ar9331?do=showtag&tag=AR9331 "tag:ar9331")

## QCA9xxx

### QCA9531

- [see ToH](/toh/views/toh_dev_arch-target-cpu?dataflt%5BCPU%2A~%5D=QCA9531 "toh:views:toh_dev_arch-target-cpu") or [QCA9531](/tag/qca9531?do=showtag&tag=QCA9531 "tag:qca9531")

### QCA9533

- [see ToH](/toh/views/toh_dev_arch-target-cpu?dataflt%5BCPU%2A~%5D=QCA9533 "toh:views:toh_dev_arch-target-cpu") or [QCA9533](/tag/qca9533?do=showtag&tag=QCA9533 "tag:qca9533")

### QCA9557

#### Description

- ![FIXME](/lib/images/smileys/fixme.svg)

#### QCA9557 based devices

- [QCA9557](/tag/qca9557?do=showtag&tag=QCA9557 "tag:qca9557")

### QCA9558

#### Description

- ![FIXME](/lib/images/smileys/fixme.svg)

#### QCA9558 based devices

- [see ToH](/toh/views/toh_dev_arch-target-cpu?dataflt%5BCPU%2A~%5D=QCA9558 "toh:views:toh_dev_arch-target-cpu") or [QCA9558](/tag/qca9558?do=showtag&tag=QCA9558 "tag:qca9558")

## Devices

The list of related devices: [AP121](/tag/ap121?do=showtag&tag=AP121 "tag:ap121"), [AR7161](/tag/ar7161?do=showtag&tag=AR7161 "tag:ar7161"), [AR7240](/tag/ar7240?do=showtag&tag=AR7240 "tag:ar7240"), [AR7241](/tag/ar7241?do=showtag&tag=AR7241 "tag:ar7241"), [AR7242](/tag/ar7242?do=showtag&tag=AR7242 "tag:ar7242"), [AR9130](/tag/ar9130?do=showtag&tag=AR9130 "tag:ar9130"), [AR9132](/tag/ar9132?do=showtag&tag=AR9132 "tag:ar9132"), [AR9331](/tag/ar9331?do=showtag&tag=AR9331 "tag:ar9331"), [AR9341](/tag/ar9341?do=showtag&tag=AR9341 "tag:ar9341"), [AR9342](/tag/ar9342?do=showtag&tag=AR9342 "tag:ar9342"), [AR9344](/tag/ar9344?do=showtag&tag=AR9344 "tag:ar9344"), [QCA9531](/tag/qca9531?do=showtag&tag=QCA9531 "tag:qca9531"), [QCA9533](/tag/qca9533?do=showtag&tag=QCA9533 "tag:qca9533"), [QCA9557](/tag/qca9557?do=showtag&tag=QCA9557 "tag:qca9557"), [QCA9558](/tag/qca9558?do=showtag&tag=QCA9558 "tag:qca9558"), [QCA9561](/tag/qca9561?do=showtag&tag=QCA9561 "tag:qca9561"), [QCA9563](/tag/qca9563?do=showtag&tag=QCA9563 "tag:qca9563"), [TP9343](/tag/tp9343?do=showtag&tag=TP9343 "tag:tp9343")
