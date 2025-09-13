# SoC (System on a Chip)

There is a perpetual effort to make the Linux kernel work on any available hardware. This work takes place within projects like OpenWrt and also within companies that design, manufacture, or sell hardware and products based on Linux. Much of this work eventually gets mainlined, meaning the code becomes part of the mainline Linux kernel.

Today, we take wireless functionality for granted, but in the beginning, it was a real challenge. The IEEE 802.11 family of standards inspired what could be achieved, but the available Linux kernel drivers were poorly written, lacked features, or didn't exist. This is still true for some wireless hardware on the market today. No matter how fantastic or powerful a new device may be, its Linux drivers could offer limited functionality.

Since its founding, OpenWrt has focused on customer premise equipment (CPE) hardware such as routers and NAS devices, dedicating much effort to supporting IEEE 802.11. Given that the initial hardware, the Linksys WRT54G, sold over 400,000 units in its first months, it's safe to say that the work done by the OpenWrt project has had an impact.

## Companies

Most SoC manufacturers license a (soft or hard) [IP core](/docs/techref/hardware/cpu#ip_core "docs:techref:hardware:cpu") for a certain [CPU](/docs/techref/hardware/cpu "docs:techref:hardware:cpu") design from a licensor like MIPS or ARM, then combine this with other (self-developed or licensed) (soft or hard) [IP cores](/docs/techref/hardware/cpu#ip_core "docs:techref:hardware:cpu") for DSP-, wireless-, VoIP-, Sound-, Switch-, etc-functionality and commission the manufacturing of chips at some semiconductor foundry. These chips, SoCs, are acquired by different manufacturers of Routers. The latter design [PCB](https://en.wikipedia.org/wiki/Printed%20circuit%20board "https://en.wikipedia.org/wiki/Printed circuit board")s for whatever purpose and solder the purchased chips (SoC, RAM, Flash) onto them.

Company CPU IP for [Mixed-signal integrated circuit](https://en.wikipedia.org/wiki/Mixed-signal%20integrated%20circuit "https://en.wikipedia.org/wiki/Mixed-signal integrated circuit") Intruction set license for own IP wired optical wireless [MIPS](https://en.wikipedia.org/wiki/MIPS%20architecture "https://en.wikipedia.org/wiki/MIPS architecture") [ARM](https://en.wikipedia.org/wiki/ARM%20architecture "https://en.wikipedia.org/wiki/ARM architecture") [Power Architecture](https://en.wikipedia.org/wiki/Power%20Architecture "https://en.wikipedia.org/wiki/Power Architecture") other Ethernet DSL DOCSIS GPON 802.11 [WiMAX](https://en.wikipedia.org/wiki/WiMAX "https://en.wikipedia.org/wiki/WiMAX") [LTE](https://en.wikipedia.org/wiki/LTE%20%28telecommunication%29 "https://en.wikipedia.org/wiki/LTE (telecommunication)") [Broadcom](https://en.wikipedia.org/wiki/Broadcom "https://en.wikipedia.org/wiki/Broadcom") MIPS32, MIPS64 ARMv6, ARMv7, ARMv8 ✔ ✔ ✔ ✔ [Marvell](https://en.wikipedia.org/wiki/Marvell "https://en.wikipedia.org/wiki/Marvell") (Intel) ARMv5 (XScale, Sheeva), ARMv6, ARMv7, ARMv8 ✔ ✔ [Qualcomm](https://en.wikipedia.org/wiki/Qualcomm "https://en.wikipedia.org/wiki/Qualcomm") (Atheros, ZyDAS) MIPS32 ARMv5, ARMv6, ARMv7, ARMv8 Ubicom32, Ubicom64 ✔ ✔ [MediaTek](https://en.wikipedia.org/wiki/MediaTek "https://en.wikipedia.org/wiki/MediaTek") MIPS32 ARMv5, ARMv6, ARMv7, ARMv8 ✔ ✔ ✔ [Lantiq](https://en.wikipedia.org/wiki/Lantiq "https://en.wikipedia.org/wiki/Lantiq") (Infineon, Texas Instruments) MIPS32 ✔ ✔ ✔ [Samsung](https://en.wikipedia.org/wiki/Samsung "https://en.wikipedia.org/wiki/Samsung") ARMv4, ARMv5, ARMv6, ARMv7 [Texas Instuments](https://en.wikipedia.org/wiki/Texas%20Instuments "https://en.wikipedia.org/wiki/Texas Instuments") ARMv5, ARMv6, ARMv7 TMS320 ✔ [Ikanos](https://en.wikipedia.org/wiki/Ikanos "https://en.wikipedia.org/wiki/Ikanos") (Conexant, Analog Devices) MIPS32, Lexra ARMv5, ARMv6 ✔ [Realtek](https://en.wikipedia.org/wiki/Realtek "https://en.wikipedia.org/wiki/Realtek") Lexra, MIPS32 ✔ ✔ ✔ [Intel](https://en.wikipedia.org/wiki/Intel "https://en.wikipedia.org/wiki/Intel") (Digital Equipment Corporation) (Texas Instruments) ARMv4 (StrongARM), ARMv5 (XScale), ARMv6 x86, x86-64, IA-64 ✔ ✔ ✔ [AMD](https://en.wikipedia.org/wiki/Advanced%20Micro%20Devices "https://en.wikipedia.org/wiki/Advanced Micro Devices") MIPS32, MIPS64 x86, x86-64 [Apple](https://en.wikipedia.org/wiki/Apple "https://en.wikipedia.org/wiki/Apple") ARMv7, ARMv8, ARMv9 [Hisilicon](https://en.wikipedia.org/wiki/Hisilicon "https://en.wikipedia.org/wiki/Hisilicon") ARMv? [Cavium Networks](https://en.wikipedia.org/wiki/Cavium%20Networks "https://en.wikipedia.org/wiki/Cavium Networks") MIPS32, MIPS64 ARMv4 [Vitesse Semiconductor](https://en.wikipedia.org/wiki/Vitesse%20Semiconductor "https://en.wikipedia.org/wiki/Vitesse Semiconductor") [Applied Micro Circuits Corporation](https://en.wikipedia.org/wiki/Applied%20Micro%20Circuits%20Corporation "https://en.wikipedia.org/wiki/Applied Micro Circuits Corporation") ARMv8 ✔ [Maxim Integrated](https://en.wikipedia.org/wiki/Maxim%20Integrated "https://en.wikipedia.org/wiki/Maxim Integrated") [Freescale Semiconductor](https://en.wikipedia.org/wiki/Freescale%20Semiconductor "https://en.wikipedia.org/wiki/Freescale Semiconductor") ARMv5, ARMv6, ARMv7 ✔ [Motorola 68000](https://en.wikipedia.org/wiki/Motorola%2068000 "https://en.wikipedia.org/wiki/Motorola 68000") [Allwinner Technology](https://en.wikipedia.org/wiki/Allwinner%20Technology "https://en.wikipedia.org/wiki/Allwinner Technology") ARMv5, ARMv7, ARMv8 [Renesas Electronics](https://en.wikipedia.org/wiki/Renesas%20Electronics "https://en.wikipedia.org/wiki/Renesas Electronics") MIPS64 ARMv7 [SuperH](https://en.wikipedia.org/wiki/SuperH "https://en.wikipedia.org/wiki/SuperH") ,[M32R](https://en.wikipedia.org/wiki/M32R "https://en.wikipedia.org/wiki/M32R") [Sony](https://en.wikipedia.org/wiki/Sony "https://en.wikipedia.org/wiki/Sony") MIPS? ✔ [Toshiba](https://en.wikipedia.org/wiki/Toshiba "https://en.wikipedia.org/wiki/Toshiba") MIPS? [SiFive](https://en.wikipedia.org/wiki/SiFive "https://en.wikipedia.org/wiki/SiFive") RISC-V

### Examples of devices with an exotic SoC

- Cavium CNS1202: [Cisco RVS4000 v2](/toh/cisco/rvs4000_v2 "toh:cisco:rvs4000_v2")
- Mindspeed Comcerto-SoC: [ZyXEL NBG5715](/toh/zyxel/nbg5715 "toh:zyxel:nbg5715")
- Qualcomm Ubicom32: [D-Link DIR-657 HD Media Router 1000](/toh/d-link/dir-657 "toh:d-link:dir-657")
- Conexant/Ikanos CX94610-11Z: [Xavi 7968](https://oldwiki.archive.openwrt.org/toh/xavi/xavi_7968 "https://oldwiki.archive.openwrt.org/toh/xavi/xavi_7968")
- Freescale MPC85xx PowerQUICC III P1014@800MHz [TP-Link TL-WDR4900 v1, v1.3](/toh/tp-link/tl-wdr4900 "toh:tp-link:tl-wdr4900")

## Linux support

Now that we have an overview of the companies that own/license semiconductor IP, let's have a look of the available support of their products in the mainline Linux kernel and in the OpenWrt Linux kernel. We are less concerned about the Android Linux kernel or other heavily modified Linux kernels.

For mainlined Linux kernel-drivers for the

- IEEE 802.3 (Ethernet) cf.
  
  - E.g. [BCM63xx codebase with GPL'd Ethernet and USB support](https://forum.openwrt.org/viewtopic.php?id=17370 "https://forum.openwrt.org/viewtopic.php?id=17370") proves, that sometimes FOSS drivers for Ethernet NICs are not available.
- IEEE 802.11 cf. [Comparison of open-source wireless drivers](https://en.wikipedia.org/wiki/Comparison%20of%20open-source%20wireless%20drivers "https://en.wikipedia.org/wiki/Comparison of open-source wireless drivers") and [http://wireless.kernel.org/en/users/Drivers](http://wireless.kernel.org/en/users/Drivers "http://wireless.kernel.org/en/users/Drivers")
- DSL is a Layer1 protocol; as Layer2 protocol usually [ATM](https://en.wikipedia.org/wiki/Asynchronous%20Transfer%20Mode "https://en.wikipedia.org/wiki/Asynchronous Transfer Mode") is employed. Cf. [PPPoEoA vs. PPPoE to PPPoA](https://en.wikipedia.org/wiki/PPPoE#How_PPPoE_fits_in_the_DSL_Internet_access_architecture "https://en.wikipedia.org/wiki/PPPoE#How_PPPoE_fits_in_the_DSL_Internet_access_architecture"). Long story short, we require support for ATM in the Linux kernel:
  
  - [/net/atm/Kconfig](https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/tree/net/atm/Kconfig "https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/tree/net/atm/Kconfig")
  - [Documentation/atm.txt](https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/tree/Documentation/networking/atm.txt "https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/tree/Documentation/networking/atm.txt")
- For the Lantiq xDSL support cf. [soc.lantiq](/docs/techref/hardware/soc/soc.lantiq "docs:techref:hardware:soc:soc.lantiq").
- FOSS support for the Broadcom DSL-IP does not exist.
- FOSS support for the Ikanos/Conexant DSL-IP does not exist.

## Platforms

Each different OpenWrt [**platform**](/docs/platforms/start "docs:platforms:start") represents a set of hardware that share certain common features, such as being part of the same family of [SoC](https://en.wikipedia.org/wiki/System-on-a-chip "https://en.wikipedia.org/wiki/System-on-a-chip")s. Depending on the semiconductor company that designs the SoC, a SoC-family can consist entirely of IP blocks that are all well-supported, maybe already mainlined. But it can also contain IP blocks, for that only raggedly written, feature-poor code exists, that would never be mainlined. Or IP blocks that are completely unsupported by the Linux kernel.

### Qualcomm Atheros

#### ar5xxx

Qualcomm Atheros AR5xxx boards (Atheros brand)

- → [soc.qualcomm.ar5xxx](/docs/techref/hardware/soc/soc.qualcomm.ar5xxx "docs:techref:hardware:soc:soc.qualcomm.ar5xxx")

#### ar71xx

Qualcomm Atheros AR7xxx, AR9xxx and QCA9xxx boards

- → [soc.qualcomm.ar71xx](/docs/techref/hardware/soc/soc.qualcomm.ar71xx "docs:techref:hardware:soc:soc.qualcomm.ar71xx")

#### ipq40xx

- → [soc.qualcomm.ipq40xx](/docs/techref/hardware/soc/soc.qualcomm.ipq40xx "docs:techref:hardware:soc:soc.qualcomm.ipq40xx")

#### ipq806x / ipq807x

- → [soc.qualcomm.ipq806x](/docs/techref/hardware/soc/soc.qualcomm.ipq806x "docs:techref:hardware:soc:soc.qualcomm.ipq806x")
- → [soc.qualcomm.ipq807x](/docs/techref/hardware/soc/soc.qualcomm.ipq807x "docs:techref:hardware:soc:soc.qualcomm.ipq807x")

#### msm

- not supported / removed from Linux in [March 2015](http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/arch/arm/mach-msm?id=c0c89fafa289ea241ba3fb22d6f583f8089a719e "http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/arch/arm/mach-msm?id=c0c89fafa289ea241ba3fb22d6f583f8089a719e")

### Lantiq / Infineon

#### adm5120

Infineon/ADMtek ADM5120

- → [soc.adm5120](/docs/techref/hardware/soc/soc.adm5120 "docs:techref:hardware:soc:soc.adm5120")

#### adm8668

Infineon WildPass ADM8668

- → [soc.adm8668](/docs/techref/hardware/soc/soc.adm8668 "docs:techref:hardware:soc:soc.adm8668")

#### AR7

TNETV1050, TNETD7200, TNETD73XX SoCs with ADSL2+ support.

- → [soc.ar7](/docs/techref/hardware/soc/soc.ar7 "docs:techref:hardware:soc:soc.ar7")

#### Lantiq

XWAY, XRX200 SoCs with ADSL2+ and VDLS2 support in OpenWrt.

- → [soc.lantiq](/docs/techref/hardware/soc/soc.lantiq "docs:techref:hardware:soc:soc.lantiq")

### MediaTek

- Ralink was merged under the target `ramips`, see [MediaTek-Ralink ramips](/docs/techref/hardware/soc/soc.ralink "docs:techref:hardware:soc:soc.ralink")
- Filogic is their newer line of SoCs including the popular 820, 830, 860, and 880. The [OpenWrt One](/toh/openwrt/one "toh:openwrt:one") uses Filogic 820.
- [soc.mediatek](/docs/techref/hardware/soc/soc.mediatek "docs:techref:hardware:soc:soc.mediatek")

### Broadcom

#### bcm270x

- SoCs are used in the Raspberry Pi line of SBCs
- OpenWrt support is available for BCM2708, 2709, 2710, 27110, 2712

#### brcm47xx

Broadcom 47xx boards

- → [soc.broadcom.bcm47xx](/docs/techref/hardware/soc/soc.broadcom.bcm47xx "docs:techref:hardware:soc:soc.broadcom.bcm47xx")

#### bcm63xx

Broadcom 6338, 6345, 6348, 6358, 6361, 6368, 63168 among other SoCs. Working with no driver for the on-board DSL/VoIP

- → [soc.broadcom.bcm63xx](/docs/techref/hardware/soc/soc.broadcom.bcm63xx "docs:techref:hardware:soc:soc.broadcom.bcm63xx")

#### bcm33xx

Minimal support for some of these SoCs.

- → [soc.broadcom.bcm33xx](/docs/techref/hardware/soc/soc.broadcom.bcm33xx "docs:techref:hardware:soc:soc.broadcom.bcm33xx")

#### bcm53xx

ARM-based bcm53xx and ARM-based bcm47xx SoCs:

- → [soc.broadcom.bcm53xx](/docs/techref/hardware/soc/soc.broadcom.bcm53xx "docs:techref:hardware:soc:soc.broadcom.bcm53xx")

### Hisilicon

#### hi35xx

- → [soc.hisilicon.hi35xx](/docs/techref/hardware/soc/soc.hisilicon.hi35xx "docs:techref:hardware:soc:soc.hisilicon.hi35xx")

### Ikanos

#### Conexant/Ikanos Solos-W

Boards based on the CX94610 SoCs.

- → [https://oldwiki.archive.openwrt.org/toh/xavi/xavi\_7968](https://oldwiki.archive.openwrt.org/toh/xavi/xavi_7968 "https://oldwiki.archive.openwrt.org/toh/xavi/xavi_7968")
- → [wag54g2](/toh/linksys/wag54g2 "toh:linksys:wag54g2")

### Marvell

#### orion

Marvell MV88F**5**18x/MV88F528x

- →[soc.marvell](/docs/techref/hardware/soc/soc.marvell "docs:techref:hardware:soc:soc.marvell")

#### kirkwood

Marvell MV88F**6**1xx/MV88F62xx

- →[soc.marvell](/docs/techref/hardware/soc/soc.marvell "docs:techref:hardware:soc:soc.marvell")

#### mvebu

Marvell Armada XP/370

- →[soc.marvell](/docs/techref/hardware/soc/soc.marvell "docs:techref:hardware:soc:soc.marvell")

### Moschip

#### mcs814x

Only 2 known devices (supported). [Devolo dLAN USB Extender](https://oldwiki.archive.openwrt.org/toh/devolo/dlan-usb-extender "https://oldwiki.archive.openwrt.org/toh/devolo/dlan-usb-extender")

### Realtek

- → [Realtek](/docs/techref/hardware/soc/soc.realtek "docs:techref:hardware:soc:soc.realtek")

### Rockchip

- → [Rockchip](/docs/techref/hardware/soc/soc.rockchip "docs:techref:hardware:soc:soc.rockchip")
- RK3399
- RK3568B2
- RK3588S

### Freescale

#### mpc52xx

Freescale MPC52xx

- →[soc.freescale.mpc](/docs/techref/hardware/soc/soc.freescale.mpc "docs:techref:hardware:soc:soc.freescale.mpc")

#### mpc83xx

Freescale MPC83xx

- →[soc.freescale.mpc](/docs/techref/hardware/soc/soc.freescale.mpc "docs:techref:hardware:soc:soc.freescale.mpc")

#### mpc85xx

Freescale MPC8xx

- →[soc.freescale.mpc](/docs/techref/hardware/soc/soc.freescale.mpc "docs:techref:hardware:soc:soc.freescale.mpc")

#### imx21

- broken: [https://dev.openwrt.org/changeset/35487](https://dev.openwrt.org/changeset/35487 "https://dev.openwrt.org/changeset/35487")

#### imx23

Freescale i.MX23 series

- →[soc.freescale.imx](/docs/techref/hardware/soc/soc.freescale.imx "docs:techref:hardware:soc:soc.freescale.imx")

#### imx6

Freescale i.MX6 series

- →[soc.freescale.imx](/docs/techref/hardware/soc/soc.freescale.imx "docs:techref:hardware:soc:soc.freescale.imx")

### Oxford / PLXTECH / Avago

#### oxnas

Oxford Semi OX82x / PLXTECH NAS782x

- →[soc.oxnas](/docs/techref/hardware/soc/soc.oxnas "docs:techref:hardware:soc:soc.oxnas")

### SiFive

- → [SiFive](/docs/techref/hardware/soc/soc.sifive "docs:techref:hardware:soc:soc.sifive")

### Allwinner

#### sunxi

A10/A10s/A13/A20/A23/A31/A33/A64/A80/H3/H5/H8

- →[soc.allwinner.sunxi](/docs/techref/hardware/soc/soc.allwinner.sunxi "docs:techref:hardware:soc:soc.allwinner.sunxi")

#### d1

D1 RISC-V

- →[soc.allwinner.d1](/docs/techref/hardware/soc/soc.allwinner.d1 "docs:techref:hardware:soc:soc.allwinner.d1")

## Unsupported SoCs

- Realtek RTL8196C is unsupported, see [Lexra](/docs/techref/hardware/soc/soc.realtek#lexra "docs:techref:hardware:soc:soc.realtek")
- Ubicom is not supported
- QCA msm arch was removed from Linux mainline and is unsupported.
