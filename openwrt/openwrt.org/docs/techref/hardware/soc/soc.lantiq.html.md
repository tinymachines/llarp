# Lantiq SoCs

The design has changed hands a few times, from Texas Instruments to Infineon to [Lantiq](https://en.wikipedia.org/wiki/Lantiq "https://en.wikipedia.org/wiki/Lantiq"), then to [Intel](https://en.wikipedia.org/wiki/Intel "https://en.wikipedia.org/wiki/Intel") and perhaps now to [MaxLinear](https://en.wikipedia.org/wiki/MaxLinear "https://en.wikipedia.org/wiki/MaxLinear").

Terminology:

- The [AR7](/docs/techref/hardware/soc/soc.ar7 "docs:techref:hardware:soc:soc.ar7") is included here for historical context but `ar7` is a distinct platform in OpenWrt.
- Lantiq applied the XWAY trademark to various parts (see [product brochures](https://web.archive.org/web/20160408093506/http://downloads.codico.com/misc/Lantiq/20140216_Lantiq_Product_Overview_for_Distribution.pdf "https://web.archive.org/web/20160408093506/http://downloads.codico.com/misc/Lantiq/20140216_Lantiq_Product_Overview_for_Distribution.pdf")/[listings](https://archive.is/o2CBw "https://archive.is/o2CBw")) but in BB, CC and trunk (as of 2016-05):
  
  - OpenWrt's `xway` only includes the DANUBE- and AR9-based models, not AMAZON
  - OpenWrt's `xrx200` includes the VR9-based models
- but see [OpenWrt Support](#openwrt_support "docs:techref:hardware:soc:soc.lantiq ↵") for details

## Lantiq xDSL

DSL-Version SoC-Family SoC [cpu](/docs/techref/hardware/cpu "docs:techref:hardware:cpu") Devices ADSL2+ [AR7](/docs/techref/hardware/soc/soc.ar7 "docs:techref:hardware:soc:soc.ar7") AR7 4Kc + [C62x](http://www.wehavemorefun.de/fritzbox/index.php/C62x "http://www.wehavemorefun.de/fritzbox/index.php/C62x") [D-Link DSL-502T (gen. 2)](https://oldwiki.archive.openwrt.org/toh/d-link/dsl-502t-genii "https://oldwiki.archive.openwrt.org/toh/d-link/dsl-502t-genii")  
[D-Link DSL-504T](/toh/d-link/dsl-504t "toh:d-link:dsl-504t")  
[D-Link DSL-524T](/toh/d-link/dsl-524t "toh:d-link:dsl-524t")  
[D-Link DSL-584T](/toh/d-link/dsl-584t "toh:d-link:dsl-584t")  
[D-Link DSL-G624T](/toh/d-link/dsl-624t "toh:d-link:dsl-624t")  
[Linksys AG241](/toh/linksys/ag241 "toh:linksys:ag241")  
[Linksys RTP300 and WRTP54G](/toh/linksys/rtp300_and_wrtp54g "toh:linksys:rtp300_and_wrtp54g")  
[Linksys AG310](https://oldwiki.archive.openwrt.org/oldwiki/openwrtdocs/hardware/linksys/ag310 "https://oldwiki.archive.openwrt.org/oldwiki/openwrtdocs/hardware/linksys/ag310")  
[Linksys WAG54GP](/toh/linksys/wag54g "toh:linksys:wag54g")  
[FRITZ!Box Fon WLAN 7112](/toh/avm/fritz.box.wlan.7112 "toh:avm:fritz.box.wlan.7112")  
[ZyXEL P-2602HWN-D7A](https://oldwiki.archive.openwrt.org/toh/zyxel/zyxel_p2602hwn "https://oldwiki.archive.openwrt.org/toh/zyxel/zyxel_p2602hwn") AMAZON “AR8”\[1] AMAZON-ME (PSB 50505) 4KEc [Speedport W 700V](/toh/t-com/spw700v "toh:t-com:spw700v")  
[D-Link "HorstBox" DVA-G3342SD](/toh/d-link/dva-g3342sd "toh:d-link:dva-g3342sd") AMAZON-SE-lite (PSB 50600) AMAZON-SE (PSB 50601) [ADB 1000g](https://oldwiki.archive.openwrt.org/toh/adb/1000g "https://oldwiki.archive.openwrt.org/toh/adb/1000g")  
[Netgear DGN1000](https://oldwiki.archive.openwrt.org/toh/netgear/dgn1000b "https://oldwiki.archive.openwrt.org/toh/netgear/dgn1000b")  
[Samsung SMT-G3000](/toh/samsung/smt-g3xx0 "toh:samsung:smt-g3xx0")  
[Thomson TG585v8](https://wikidevi.com/wiki/Thomson_TG585v8 "https://wikidevi.com/wiki/Thomson_TG585v8")  
[ZTE ZXV10 H108L](https://oldwiki.archive.openwrt.org/toh/zte/zxv10h108l "https://oldwiki.archive.openwrt.org/toh/zte/zxv10h108l") AMAZON-S (PSB 50610) [vigor2830\_series](/toh/draytek/vigor2830_series "toh:draytek:vigor2830_series") DANUBE DANUBE (PSB 50702) 2x 24KEc [Airties WAV-281](/toh/airties/wav281 "toh:airties:wav281")  
[Arcadyan ARV4518PW (SMC-7908-ISP)](/toh/arcadyan/arv4518pw "toh:arcadyan:arv4518pw")  
[Arcadyan ARV7506PW11 (Alice IAD 4421 / o2 Box 4421)](/toh/arcadyan/arv7506pw11 "toh:arcadyan:arv7506pw11")  
[Arcadyan ARV7510PW](/toh/arcadyan/arv7510pw "toh:arcadyan:arv7510pw")  
[Astoria Networks ARV7518PW](/toh/astoria/arv7518pw "toh:astoria:arv7518pw")  
[Arcadyan ARV7519PW](/toh/arcadyan/arv7519pw "toh:arcadyan:arv7519pw")  
[Arcadyan ARV752DPW (Vodafone EasyBox 802)](/toh/arcadyan/arv752dpw "toh:arcadyan:arv752dpw")  
[Astoria Networks ARV752DPW22 (Arcor/Vodafone DSL-EasyBox 803A)](/toh/astoria/arv752dpw22 "toh:astoria:arv752dpw22")  
[Belkin F5D8635-4v1](/toh/belkin/f5d8635-4v1_danube "toh:belkin:f5d8635-4v1_danube")  
[MediaPack MP-252](/toh/audiocodes/mp-252 "toh:audiocodes:mp-252")  
[SIEMENS / SAGEM Gigaset SX762 / SX763](/toh/gigaset/sx76x "toh:gigaset:sx76x")  
[Speedport W 502V](/toh/t-com/spw502v "toh:t-com:spw502v")  
[Speedport W 503V Typ C](/toh/t-com/spw503vtypc "toh:t-com:spw503vtypc")  
[Speedport W 504V](/toh/t-com/speedport_w_504v "toh:t-com:speedport_w_504v")  
[Speedport W 722V Typ B](/toh/t-com/spw722vtypb "toh:t-com:spw722vtypb") DANUBE-S (PSB 50712) 2x 24KEc [Siemens Gigaset 604 IL](/toh/siemens/gigaset604il "toh:siemens:gigaset604il")  
[BT HomeHub 2.0 Type B](/toh/bt/homehub_v2b "toh:bt:homehub_v2b") ARX100 **“AR9”** ARX168 34Kc [Buffalo WBMR-HP-G300H](/toh/buffalo/wbmr-hp-g300h "toh:buffalo:wbmr-hp-g300h")  
[Netgear DGN3500](/toh/netgear/dgn3500b "toh:netgear:dgn3500b")  
[Aztech GR7000](/toh/aztech/gr7000 "toh:aztech:gr7000")  
[ZyXEL P-661HNU-F3](/toh/zyxel/p-661hnu-f3 "toh:zyxel:p-661hnu-f3")  
[BT HomeHub 3.0a](/toh/bt/homehub_v3a "toh:bt:homehub_v3a")  
[FRITZ!Box Fon WLAN 7320](/toh/avm/avm_fritz_box_7320 "toh:avm:avm_fritz_box_7320")  
[FRITZ!Box Fon WLAN 7330](/toh/avm/fritz.box.wlan.7330 "toh:avm:fritz.box.wlan.7330")  
[VTECH NetiaSpot](/toh/vtech/netiaspot "toh:vtech:netiaspot") ARX182 [ZTE ZXV10-H201L](/toh/zte/zxv10h201l "toh:zte:zxv10h201l") [ZyXEL P-2601HN-Fx](/toh/zyxel/p-2601hn-fx "toh:zyxel:p-2601hn-fx") ARX188 [FRITZ!Box 7312](/toh/avm/fritz.box.wlan.7312 "toh:avm:fritz.box.wlan.7312") VDSL2 VINAX VINAX-VE/-A 2× 24KEc VINAX-E/-A VINAX-D/-A ALLNET ALL126Ax2 ? VRX200 **“VR9”** VRX220 34Kc [Netgear DM200](/toh/netgear/dm200 "toh:netgear:dm200")  
[AVM FRITZ!Box 7412](/toh/avm/avm_fritz_box_7412 "toh:avm:avm_fritz_box_7412") VRX288 / VRX208 [AVM FRITZ!Box WLAN 3370](/toh/avm/fritz.box.wlan.3370 "toh:avm:fritz.box.wlan.3370")  
[FRITZ!Box WLAN 3390](/toh/avm/fritzbox_3390 "toh:avm:fritzbox_3390")  
[FRITZ!Box Fon WLAN 7360](/toh/avm/fritz.box.wlan.7360 "toh:avm:fritz.box.wlan.7360")  
[FRITZ!Box Fon WLAN 7490](/toh/avm/fritz.box.7490 "toh:avm:fritz.box.7490")  
[FRITZ!Box 6840 LTE](/toh/avm/fritz.box.wlan.6840.lte "toh:avm:fritz.box.wlan.6840.lte")  
[Astoria Networks ARV7519RW22 (Livebox 2.1)](/toh/arcadyan/arv7519rw22 "toh:arcadyan:arv7519rw22")  
[Astoria Networks VGV7519KW (KPN Experia Box v8)](/toh/arcadyan/vgv7519 "toh:arcadyan:vgv7519")  
[Arcadyan VGV7510KW22 (o2 Box 6431)](/toh/arcadyan/vgv7510kw22 "toh:arcadyan:vgv7510kw22")  
[Draytek Vigor 2760(Vn)/(Delight)](/toh/draytek/vigor2760 "toh:draytek:vigor2760")  
[TP-Link Archer VR200v](/toh/tp-link/vr200v "toh:tp-link:vr200v")  
[ZyXEL P-2812HNU-F1](/toh/zyxel/p-2812hnu-f1 "toh:zyxel:p-2812hnu-f1")  
[ZyXEL P-2812HNU-F3](/toh/zyxel/p-2812hnu-f3 "toh:zyxel:p-2812hnu-f3") VRX268 / VRX208 [TP-Link TD-W8970](/toh/tp-link/td-w8970_v1 "toh:tp-link:td-w8970_v1")  
[TP-Link TD-W8980](/toh/tp-link/td-w8980_v1 "toh:tp-link:td-w8980_v1")  
[TP-Link TD-W9980](/toh/tp-link/td-w9980 "toh:tp-link:td-w9980")  
[Netgear VEVG2500](/toh/netgear/vevg2500 "toh:netgear:vevg2500")  
[BT Home Hub 5 Type A](/toh/bt/homehub_v5a "toh:bt:homehub_v5a")  
[BT OpenReach VG3503J](/toh/bt/vg3503j "toh:bt:vg3503j") VRX208 -- AFE and Line driver ADSL2+ ARX300 ARX388 34Kc ADSL2+/Ethernet SoC with integrated high-performance WLAN, GbitE LAN/WAN, 2-4 Ch FxS and CATiq support ARX382 ADSL2+/Ethernet SoC with integrated cost-effective WLAN, FastE LAN/WAN, 2-4 Ch FxS and CATiq support ARX368 ADSL2+/Ethernet SoC with integrated high performance WLAN and GbitE LAN/WAN  
[TP-Link Archer D2 AC750](/toh/tp-link/archer_d2_ac750 "toh:tp-link:archer_d2_ac750") ARX362 ADSL2+/Ethernet SoC with integrated cost-effective WLAN and FastE LAN/WAN none GRX300 GRX388 Gigabit Ethernet Router/Gateway SoC with integrated 3×3 Wi-Fi GRX387 Gigabit Ethernet Router/Gateway SoC with integrated 2×2 Wi-Fi none GRX350 PXB4395 interAptiv Gigabit Ethernet Router/Gateway Soc with USB, PCIe 2 PXB3395EL1600 GRX550 PXB4583EL VDSL2 ? VRX318 -- ADSL2/2+/VDSL Transceiver and Line Driver for GRX388/GRX387 VDSL2 ? VRX518 -- ADSL/VDSL2(35b) Transceiver and Line Driver for GRX350 / GRX550  
[AVM FRITZ!Box 7520 / 7530](/toh/avm/avm_fritz_box_7530 "toh:avm:avm_fritz_box_7530")

\[1] Infineon called Amazon “AR8” in at least one [product brochure](http://www.infineon.com/dgdl/IFX_CPE_Brochure_final.pdf?folderId=db3a304312dc768d0112e132874e0280&fileId=db3a30431add1d95011ae886288656ae "http://www.infineon.com/dgdl/IFX_CPE_Brochure_final.pdf?folderId=db3a304312dc768d0112e132874e0280&fileId=db3a30431add1d95011ae886288656ae"). It probably applied to Danube too.

## Lantiq telephony

Intel/MaxLinear product name Lantiq product name Lantiq marking Datasheets SLC110 SLIC110 PEF41068 SLC120 SLIC120 PEF42068 SLC121 SLIC121 PEF42168 SLC210 SLIC210 PEF41078 [617968\_slc210\_pef41078vv11\_ds\_rev2.0.pdf](/_media/media/datasheets/617968_slc210_pef41078vv11_ds_rev2.0.pdf "media:datasheets:617968_slc210_pef41078vv11_ds_rev2.0.pdf (1012.9 KB)") SLC220 SLIC220 PEF42078 [617948\_slc220\_pef42078vtv11\_ds\_rev2.0.pdf](/_media/media/datasheets/617948_slc220_pef42078vtv11_ds_rev2.0.pdf "media:datasheets:617948_slc220_pef42078vtv11_ds_rev2.0.pdf (1 MB)")

Manuals: [617580\_dxs\_api\_device\_driver\_pr\_rev3.0.pdf](/_media/media/manuals/617580_dxs_api_device_driver_pr_rev3.0.pdf "media:manuals:617580_dxs_api_device_driver_pr_rev3.0.pdf (1.9 MB)") [617585\_dxs\_um\_sd\_rev2.2.pdf](/_media/media/manuals/617585_dxs_um_sd_rev2.2.pdf "media:manuals:617585_dxs_um_sd_rev2.2.pdf (1.4 MB)") [617837\_gateway\_socs\_voice\_sp\_4.44rc5\_rn\_rev2.0.pdf](/_media/media/manuals/617837_gateway_socs_voice_sp_4.44rc5_rn_rev2.0.pdf "media:manuals:617837_gateway_socs_voice_sp_4.44rc5_rn_rev2.0.pdf (891.5 KB)")

## OpenWrt Support

Judging mostly by age and wiki pages:

- DANUBE devices: look pretty well supported, with builds for many devices having been in the system for years.
- xRX2xx devices: seem to work fine (speaking from experience of the BTHH5A, and the healthy wiki pages of the [ZyXEL P2812HNU-Fx](/toh/zyxel/p2812hnu-fx "toh:zyxel:p2812hnu-fx")).
- AR9 devices: the [Buffalo WBMR-HP-G300H](/toh/buffalo/wbmr-hp-g300h "toh:buffalo:wbmr-hp-g300h") and [Netgear DGN3500B](/toh/netgear/dgn3500b "toh:netgear:dgn3500b") wiki pages look healthy.
- AMAZON-SE devices: platform support has been around since 2011 and remains, but timing was unkind; support consolidated shortly after the Attitude Adjustment freeze, but as few devices/user reports existed, build support got dropped again before Barrier Breaker. There has been [some success](https://forum.openwrt.org/viewtopic.php?id=39319 "https://forum.openwrt.org/viewtopic.php?id=39319") building trunk (2016-05) for the [DGN1000](https://oldwiki.archive.openwrt.org/toh/netgear/dgn1000b "https://oldwiki.archive.openwrt.org/toh/netgear/dgn1000b").
- AMAZON-ME: no data; anecdotally: “we tried booting OpenWrt on \[one]: we never got a single response from it (even after hacking around in some linux early-boot code...)”
- VINAX, other AMAZON variants: no data

### Lantiq DSL IP block support in Linux

ADSL and VDSL are generally supported (probably through a combination of GPL dumps for [some units](/toh/netgear/vevg2500 "toh:netgear:vevg2500") and contributions directly from Lantiq; there may still be some blobs?). Some people report that AR9-/VR9-based routers achieve better synchronization than Danube-based boards.

### Lantiq supported DSL Annex

![:!:](/lib/images/smileys/exclaim.svg) Annex A,B,J,L,M should be supported. see package/network/config/ltq-vdsl-app/files/dsl\_control

### SMP/Multithreading

**Danube/Danube-S:** They have two MIPS 24kec CPUs, but the second core has few differences that make SMP support impossible. The second core is used for VoIP.

**AR9/VR9:** Their cores have multithreading support, but it does not work properly with these SoCs without some hacks seen in the source dumps of some boards. For now multithreading is not supported without specific patches for the AR9 and VR9.

### WAVE300

A Lantiq WiFi chip. See [https://forum.openwrt.org/t/support-for-wave-300-wi-fi-chip/24690/161](https://forum.openwrt.org/t/support-for-wave-300-wi-fi-chip/24690/161 "https://forum.openwrt.org/t/support-for-wave-300-wi-fi-chip/24690/161")

## Boot

Lantiq SoCs have small mask ROMs capable of booting from [various sources](https://elixir.bootlin.com/linux/latest/source/arch/mips/include/asm/mach-lantiq/xway/lantiq_soc.h#L59 "https://elixir.bootlin.com/linux/latest/source/arch/mips/include/asm/mach-lantiq/xway/lantiq_soc.h#L59"), selected by a combination the `boot_selN` pins. This mask ROM is what emits “`ROM VER x.yy ... CFG 0x`” over serial on these devices. Finding those pins on a given device [can be tricky](https://forum.openwrt.org/viewtopic.php?pid=252818#p252818 "https://forum.openwrt.org/viewtopic.php?pid=252818#p252818"), but on several Lantiq-based devices it's the primary mechanism for installation or recovery. Consult the pages for a specific device for details on `boot_selN` access discovered so far (if any); since pins have only been found for BGA-packaged chips so far, access probably involves soldering to small surface mount resistor pads. Be careful, if you short the pins too long it is possible to create a loop. In this case the SoC tries always to boot e.g. from CFG 04 (UART). In this case your SoC is bricked!

The bootloader is typically [U-Boot](/docs/techref/bootloader/uboot "docs:techref:bootloader:uboot"), sometimes [brnboot](/docs/techref/bootloader/brnboot "docs:techref:bootloader:brnboot").

### UART mode

When the `boot_selN` pins select UART mode (or on some SoCs such as the 50601, when the SPI flash can't be read or appears invalid), the mask ROM routine waits for data in hex. The format, which seems to have originated on the [Motorola MMC2107](http://www.camelforth.com/e107_files/downloads/newmicros/product_manual/NMIN-2107.pdf "http://www.camelforth.com/e107_files/downloads/newmicros/product_manual/NMIN-2107.pdf"), is:

- lines start with addresses (8 hex digits, encoding a 32-bit address)
- addresses are followed by data (128 hex digits, encoding 64 bytes)
- aligned addresses simply denote 64-byte writes at the corresponding locations
- selected unaligned addresses cause data to be interpreted differently:
  
  - `33333333`: data is address/value pairs for writing individual words
    
    - this is typically used first, to configure some RAM access (SRAM? SDRAM? cache-as-RAM?) so there's somewhere to store the image
    - unused pairs seem to use all zeros for address/value
  - `11111111`: data is a 32-bit checksum, followed by 120 0s of padding
  - `99999999`: data is a 32-bit start address, again padded

U-Boot is often the payload, as in [this example](https://raw.githubusercontent.com/seanchann/sx76x-openwrt-danube/master/u-boot.asc "https://raw.githubusercontent.com/seanchann/sx76x-openwrt-danube/master/u-boot.asc").

The Motorola toolchain included a Perl script called `sikadown.pl` which converted traditional S-record files into this format. OpenWrt's `boot` package contains (within [Lantiq patches](https://dev.openwrt.org/browser/trunk/package/boot/uboot-lantiq/patches/0017-tools-add-some-helper-tools-for-Lantiq-SoCs.patch?rev=40482 "https://dev.openwrt.org/browser/trunk/package/boot/uboot-lantiq/patches/0017-tools-add-some-helper-tools-for-Lantiq-SoCs.patch?rev=40482")) a newer version, `gct.pl`, that is very similar to the one from the DGN1000 Netgear GPL release and does the same with the addition of RAM initialisation.

### Booting from flash

This is taken from [a patent application](https://www.google.com/patents/US8260968 "https://www.google.com/patents/US8260968") and the specific example of the the PSB 50601 (Amazon SE), but other variants are likely very similar. What seems to vary between implementations is:

- Ease of influencing the boot via `boot_selN` pins:
  
  - Some might load and run code from any valid-looking flash if any `boot_selN` pin is set, and **the structure of the flash can mean the set pins are ignored**. The PSB 50601 behaves this way.
    
    - On these, if the `boot_selN` pins can't be located then another approach may be to inhibit flash reads, e.g. pull `/CE` high on a serial flash chip.
  - Others might honour the `boot_selN` pins before consulting the flash (the VRX268 seems to do this).
- Fallback mechanism; some may default to UART if other methods fail, some may not.

On an example PSB 50601-based unit the start of SPI, dictated by the mask ROM, is:

```
AA 55 FF FF  03 02 01 00  0C 00 05 04
```

This is interpreted as:

- the signature/magic `0xAA55` (signifies valid flash)
- a PHY0 address (`0xFF`); unclear what is expected to interpret this, or how
- a PHY1 address (`0xFF`); unclear what is expected to interpret this, or how
- a MAC (here `00:01:02:03:04:05`), oddly laid out to straddle...
- the size (`0x0C`) in bytes of this header and reserved area (in this case there's no extra reserved space beyond this header)
- a validity flag for the MAC address (`0x00` means valid)

If there were any reserved space, it would appear next.

A list of entries then follows. Similar to UART mode, addresses can indicate word writes, block writes or transfer of control:

- a plain address with clear low bits (`0b00`) is followed by a single word to be written there
- an address ORed with `0b01` is followed by a length (in 32-bit words) and a block of data to write; should be possible to initialise multiple non-contiguous regions just by concatenating multiple entries of this type
- a uint32 with `0b11` low bits terminates the list:
  
  - `0xFFFFFFFF`: treat the following uint32 as the entry address, jumping to it
  - `0x00000003`: attempt to boot from whatever `boot_selN` indicates (the next word isn't consulted)

### MII (network) boot

The documentation outlines this, and transfers would be quicker than serial. Documentation/tooling welcomed.

## JTAG

On PSB 50601 the JTAG pins are:

- 49: TDO
- 50: TMS
- 51: nTRST
- 52: TDI
- 53: TCK

SPI pins are:

- 44: CLK
- 45: MOSI
- (46 unknown)
- 47: MISO
- 48: Slave select (probably the first of several)

## GPIO pinmux

EXIN = External Interrupt

Lantiq XWAY Danube (gpiochip label = gpio-xway) GPIO pin f0 f1 f2 f3 GPIO0 GPIO EXIN 0 SDIO TDM GPIO1 GPIO EXIN 1 CBUS MII GPIO2 GPIO CGU EXIN 2 MII GPIO3 GPIO CGU SDIO PCI REQ3 GPIO4 GPIO STP DFE ASC GPIO5 GPIO STP MII DFE GPIO6 GPIO STP GPT ASC GPIO7 GPIO CGU CBUS MII GPIO8 GPIO CGU NMI MII GPIO9 GPIO ASC SPI CS5 MII GPIO10 GPIO ASC SPI CS4 MII GPIO11 GPIO ASC CBUS SPI CS6 GPIO12 GPIO ASC CBUS MCD GPIO13 GPIO EBU SPI CS3 MII GPIO14 GPIO CGU CBUS MII GPIO15 GPIO SPI CS1 SDIO JTAG GPIO16 GPIO SPI DI SDIO JTAG GPIO17 GPIO SPI DO SDIO JTAG GPIO18 GPIO SPI CLK SDIO JTAG GPIO19 GPIO PCI GNT3 SDIO MII GPIO20 GPIO JTAG SDIO MII GPIO21 GPIO PCI EBU GPT GPIO22 GPIO SPI CS2 MCD MII GPIO23 GPIO EBU PCI GNT2 STP GPIO24 GPIO EBU TDM PCI GPIO25 GPIO TDM SDIO ASC GPIO26 GPIO EBU TDM SDIO GPIO27 GPIO TDM SDIO ASC GPIO28 GPIO GPT MII SDIO GPIO29 GPIO PCI REQ1 CBUS MII GPIO30 GPIO PCI GNT1 CBUS MII GPIO31 GPIO EBU PCI REQ2 MII

Lantiq XWAY xrx200 (gpiochip label = gpio-xway) GPIO pin f0 f1 f2 f3 GPIO0 GPIO EXIN SDIO TDM GPIO1 GPIO EXIN CBUS SIN GPIO2 GPIO CGU EXIN GPHY GPIO3 GPIO CGU SDIO PCI GPIO4 GPIO STP DFE USIF GPIO5 GPIO STP GPHY DFE GPIO6 GPIO STP GPT USIF GPIO7 GPIO CGU CBUS GPHY GPIO8 GPIO CGU NMI NONE GPIO9 GPIO USIF SPI EXIN GPIO10 GPIO USIF SPI EXIN GPIO11 GPIO USIF CBUS SPI GPIO12 GPIO USIF CBUS MCD GPIO13 GPIO EBU SPI NONE GPIO14 GPIO CGU CBUS USIF GPIO15 GPIO SPI SDIO MCD GPIO16 GPIO SPI SDIO NONE GPIO17 GPIO SPI SDIO NONE GPIO18 GPIO SPI SDIO NONE GPIO19 GPIO PCI SDIO CGU GPIO20 GPIO NONE SDIO EBU GPIO21 GPIO PCI EBU GPT GPIO22 GPIO SPI CGU EBU GPIO23 GPIO EBU PCI STP GPIO24 GPIO EBU TDM PCI GPIO25 GPIO TDM SDIO USIF GPIO26 GPIO EBU TDM SDIO GPIO27 GPIO TDM SDIO USIF GPIO28 GPIO GPT PCI SDIO GPIO29 GPIO PCI CBUS EXIN GPIO30 GPIO PCI CBUS NONE GPIO31 GPIO EBU PCI NONE GPIO32 GPIO MII NONE EBU GPIO33 GPIO MII NONE EBU GPIO34 GPIO SIN SSI NONE GPIO35 GPIO SIN SSI NONE GPIO36 GPIO SIN SSI EXIN GPIO37 GPIO USIF NONE PCI GPIO38 GPIO PCI USIF NONE GPIO39 GPIO USIF EXIN NONE GPIO40 GPIO MII TDM NONE GPIO41 GPIO MII TDM NONE GPIO42 GPIO MDIO NONE NONE GPIO43 GPIO MDIO NONE NONE GPIO44 GPIO MII SIN GPHY GPIO45 GPIO MII GPHY SIN GPIO46 GPIO MII NONE EXIN GPIO47 GPIO MII GPHY SIN GPIO48 GPIO EBU NONE NONE GPIO49 GPIO EBU NONE NONE

## Devices

The list of related devices: [adsl](/tag/adsl?do=showtag&tag=adsl "tag:adsl"), [adsl2+](/tag/adsl2?do=showtag&tag=adsl2%2B "tag:adsl2"), [adsl2](/tag/adsl2?do=showtag&tag=adsl2 "tag:adsl2"), [amazon](/tag/amazon?do=showtag&tag=amazon "tag:amazon"), [ar7](/tag/ar7?do=showtag&tag=ar7 "tag:ar7"), [ar9](/tag/ar9?do=showtag&tag=ar9 "tag:ar9"), [danube](/tag/danube?do=showtag&tag=danube "tag:danube"), [lantiq](/tag/lantiq?do=showtag&tag=lantiq "tag:lantiq"), [vdsl](/tag/vdsl?do=showtag&tag=vdsl "tag:vdsl"), [vdsl2](/tag/vdsl2?do=showtag&tag=vdsl2 "tag:vdsl2"), [vinax](/tag/vinax?do=showtag&tag=vinax "tag:vinax"), [vr9](/tag/vr9?do=showtag&tag=vr9 "tag:vr9")
