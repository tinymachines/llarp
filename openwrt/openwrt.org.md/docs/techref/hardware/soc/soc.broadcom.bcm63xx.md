# Broadcom BCM63xx

Official support for BCM63xx target was dropped completely since 24.10.0

This page provides an overview of the Broadcom BCM63xx series [soc](/docs/techref/hardware/soc "docs:techref:hardware:soc") , which share many similarities with the [BCM33xx](/docs/techref/hardware/soc/soc.broadcom.bcm33xx "docs:techref:hardware:soc:soc.broadcom.bcm33xx") SoCs (with the exception of the BCM3302, which is a standalone CPU). The difference between the two being that the DSL core in the BCM63xx is replaced with a DOCSIS/EuroDOCSIS core in the BCM33xx series.

The [Broadcom BCM63xx SoC](https://www.broadcom.com/products/broadband/xdsl/ "https://www.broadcom.com/products/broadband/xdsl/") integrates ADSL/ADSL2+ capabilities, routing functions, and support for external Wireless NICs.

This SoC family is widely adopted in xDSL platforms globally and is considered one of the most successful xDSL platforms. Its success is attributed to the ease of transitioning older platforms (e.g., BCM6345) to newer ones with minimal software changes.

Architecture information:

***Older BCM63xx SoCs** are based on the **MIPS32 Big Endian instruction set***, with architectural similarities to the R4000 microprocessor.

***Newer BCM63xx SoCs** have transitioned to the **ARMv7a Little Endian instruction set***, exemplified by chips like the BCM63138.

## Linux support

- The OpenWrt support for the Broadcom BCM63xx SoC family currently only works with following models:
  
  - [**6318**](/toh/views/toh_dev_arch-target-cpu?dataflt%5BCPU%2A~%5D=bcm6318 "toh:views:toh_dev_arch-target-cpu")
  - [**6328**](/toh/views/toh_dev_arch-target-cpu?dataflt%5BCPU%2A~%5D=bcm6328 "toh:views:toh_dev_arch-target-cpu")
  - **6338**
  - **6345**
  - [**6348**](/toh/views/toh_dev_arch-target-cpu?dataflt%5BCPU%2A~%5D=bcm6348 "toh:views:toh_dev_arch-target-cpu")
  - [**6358**](/toh/views/toh_dev_arch-target-cpu?dataflt%5BCPU%2A~%5D=bcm6358 "toh:views:toh_dev_arch-target-cpu") / [**6359**](/toh/views/toh_dev_arch-target-cpu?dataflt%5BCPU%2A~%5D=bcm6359 "toh:views:toh_dev_arch-target-cpu")
  - [**6361**](/toh/views/toh_dev_arch-target-cpu?dataflt%5BCPU%2A~%5D=bcm6361 "toh:views:toh_dev_arch-target-cpu") / [**6362**](/toh/views/toh_dev_arch-target-cpu?dataflt%5BCPU%2A~%5D=bcm6362 "toh:views:toh_dev_arch-target-cpu")
  - [**6368**](/toh/views/toh_dev_arch-target-cpu?dataflt%5BCPU%2A~%5D=bcm6368 "toh:views:toh_dev_arch-target-cpu") / [**6369**](/toh/views/toh_dev_arch-target-cpu?dataflt%5BCPU%2A~%5D=bcm6369 "toh:views:toh_dev_arch-target-cpu")
  - [**63167**](/toh/views/toh_dev_arch-target-cpu?dataflt%5BCPU%2A~%5D=bcm63167 "toh:views:toh_dev_arch-target-cpu") / [**63168**](/toh/views/toh_dev_arch-target-cpu?dataflt%5BCPU%2A~%5D=bcm63168 "toh:views:toh_dev_arch-target-cpu") / [**63169**](/toh/views/toh_dev_arch-target-cpu?dataflt%5BCPU%2A~%5D=bcm63169 "toh:views:toh_dev_arch-target-cpu") / [**63268**](/toh/views/toh_dev_arch-target-cpu?dataflt%5BCPU%2A~%5D=bcm63268 "toh:views:toh_dev_arch-target-cpu") / [**63269**](/toh/views/toh_dev_arch-target-cpu?dataflt%5BCPU%2A~%5D=bcm63269 "toh:views:toh_dev_arch-target-cpu")
- There are working drivers for USB Host (OHCI and EHCI) and Ethernet under the GPL. USB Device drivers are also supported but only for BCM6368 and newer SoCs.
- → [brcm63xx.imagetag](/docs/techref/brcm63xx.imagetag "docs:techref:brcm63xx.imagetag")

### Finished tasks

The support for Broadcom 63xx is at this state :

- **Runtime detection of the SoC**: Full Linux support on which the kernel is running.
- **Ethernet / switch**: GPL driver.
- **USB OHCI, EHCI**: GPL driver.
- **Watchdog**: GPL driver.
- **SPI**: GPL driver, with minor bugs.
- **Dual core**: supported in BMC6368/6362/63268 and no support in BCM6358.
- **NAND** flash chips are supported since [r13271](https://git.openwrt.org/86583384ff "https://git.openwrt.org/86583384ff") (kernel 5.4).
- **SPU** (Secure Processing Unit): The [Cipher Engine](#cipher_engine "docs:techref:hardware:soc:soc.broadcom.bcm63xx ↵") has drivers since [Linux kernel 4.11](https://github.com/torvalds/linux/commit/9d12ba86 "https://github.com/torvalds/linux/commit/9d12ba86"), but still not integrated into OpenWrt/LEDE
- [Wifi core](https://bcm63xx.sipsolutions.net/UBUS.html "https://bcm63xx.sipsolutions.net/UBUS.html"): not supported, initial work: [WIP: bcm63xx: internal wireless support](https://github.com/Noltari/openwrt/commit/795786f53edd9c6116fbd884d4052442831db93e "https://github.com/Noltari/openwrt/commit/795786f53edd9c6116fbd884d4052442831db93e")
- **FAP** (Broadcom Forwarding Assist Processor) not supported. This looks like some kind of hardware NAT.
- **No available drivers** (neither binary, nor GPL) for DSL, ATM, VoIP, on-board SLIC/SLAC,

### Broadcom xDSL

- xDSL and ATM are **NOT SUPPORTED**. Not by some binary nor are there GPL drivers available!
  
  - Netgear has released some sources for DSL-driver: [DG834GBv4 GPL and closed code](https://sourceforge.net/projects/officialnetgearfirmware/files/DG834_G_GBv3_4_01_06.zip/download "https://sourceforge.net/projects/officialnetgearfirmware/files/DG834_G_GBv3_4_01_06.zip/download")
  - [https://forum.openwrt.org/viewtopic.php?id=24271](https://forum.openwrt.org/viewtopic.php?id=24271 "https://forum.openwrt.org/viewtopic.php?id=24271")
  - [https://web.archive.org/web/20160622160227/http://comments.gmane.org/gmane.comp.embedded.openwrt.devel/17440](https://web.archive.org/web/20160622160227/http://comments.gmane.org/gmane.comp.embedded.openwrt.devel/17440 "https://web.archive.org/web/20160622160227/http://comments.gmane.org/gmane.comp.embedded.openwrt.devel/17440")
  - [http://www.neufbox4.org/forum/viewtopic.php?pid=15930#p15930](http://www.neufbox4.org/forum/viewtopic.php?pid=15930#p15930 "http://www.neufbox4.org/forum/viewtopic.php?pid=15930#p15930")
  - [https://github.com/cubieb/hg556a\_source/tree/master/bcmdrivers/broadcom/char/adsl/bcm96358](https://github.com/cubieb/hg556a_source/tree/master/bcmdrivers/broadcom/char/adsl/bcm96358 "https://github.com/cubieb/hg556a_source/tree/master/bcmdrivers/broadcom/char/adsl/bcm96358") here seems to be a quite complete stack for bcm6348/58 kernel 2.6
- → [BCM63xx ADSL Support on Linux kernel 2.6.8.1](https://wiki.openwrt.org/inbox/adsl_support "https://wiki.openwrt.org/inbox/adsl_support") effort to make it work again on Linux kernel 2.6.8.1 from 2004-08-14

### Dual Core

Certain Broadcom SoCs, including the BCM6358, BCM6361, BCM6362, and BCM6368, feature dual cores. However, the BCM6358 is limited to using only one core. While the kernel includes [SMP](https://en.wikipedia.org/wiki/Symmetric%20multiprocessing "https://en.wikipedia.org/wiki/Symmetric multiprocessing") support (see [smp-bmips.c](http://lxr.free-electrons.com/source/arch/mips/kernel/smp-bmips.c "http://lxr.free-electrons.com/source/arch/mips/kernel/smp-bmips.c")), fully utilizing both cores is complex. The second CPU must be explicitly initialized, and the current interrupt (IRQ) code only enables interrupts on the first CPU. Consequently, only userspace processes can access the second core, while all interrupt handlers remain tied to the first core.

→ [SMP/CMT Broadcom 63xx](/docs/techref/hardware/soc/soc.broadcom.bcm63xx/smp "docs:techref:hardware:soc:soc.broadcom.bcm63xx:smp")

### How to help

- Download: [DG834GBv4 GPL and closed code](ftp://downloads.netgear.com/files/GPL/DG834GBv4_V5.01.01_src.zip "ftp://downloads.netgear.com/files/GPL/DG834GBv4_V5.01.01_src.zip") and help writing specification for the DSL core, the place to host specifications is [BCM63xx at Sipsolutions.net](http://bcm63xx.sipsolutions.net "http://bcm63xx.sipsolutions.net").
- Improve the bcm63xx SPI driver.
- Dual core SMP/CMT still needs further work, specially for BCM6358 with a shared TLB. If you know how to get rid of the problem of having a shared TLB between 2 cores, with working code, please contact with developers  
  see → [TLB exception handlers](/docs/techref/hardware/soc/soc.broadcom.bcm63xx/smp#tlbexceptionhandlers "docs:techref:hardware:soc:soc.broadcom.bcm63xx:smp")
- BCM63168 with Kernel 3.4 source can be found here: [100AAJX8\_4.16L.02A GPL and closed code](https://drive.google.com/folderview?id=0B-U-Krbg5qbTfkEwYkFpUkhVNFhlU3hPeWlZSUlmNlppTkpsODlSbm5FOElyV1p3MENCZlk&usp=sharing "https://drive.google.com/folderview?id=0B-U-Krbg5qbTfkEwYkFpUkhVNFhlU3hPeWlZSUlmNlppTkpsODlSbm5FOElyV1p3MENCZlk&usp=sharing").
- BCM63168D0 with Kernel 2.6.30 source can be found here: [100AAPP7D0\_4.12L.06B\_consumer\_release GPL and open source code](https://osdn.net/projects/zyxel-vmg3312/downloads/68893/100AAPP7D0_4.12L.06B_consumer_release.tar.gz/ "https://osdn.net/projects/zyxel-vmg3312/downloads/68893/100AAPP7D0_4.12L.06B_consumer_release.tar.gz/").

## Existent 63xx variants

SoC CPU MHz Dual Core RAM NAND USB Device USB Host PCMCIA / PCCARD PCI PCIe Wireless NIC Switch ADSL2 ADSL2+ VDSL VDSL2 Fiber OpenWrt [bcm6318](/tag/bcm6318?do=showtag&tag=bcm6318 "tag:bcm6318") 333 ☐ DDR ☐ 2.0 2.0 ☐ ☐ ✔ ☐ ✔ ✔ ✔ ☐ ☐ ☐ [bcm6328](/tag/bcm6328?do=showtag&tag=bcm6328 "tag:bcm6328") 320 ☐ DDR2 ✔ 2.0 2.0 ☐ ☐ ✔ ☐ ✔ ✔ ✔ ☐ ☐ ☐ 12.09 bcm6329 320 ✔ DDR2 ✔ 2.0 2.0 ☐ ☐ ✔ ☐ ✔ ☐ ☐ ☐ ☐ ☐ bcm6335 140 ☐ SDR ☐ ☐ ☐ ☐ ☐ ☐ ☐ ☐ ✔ ☐ ☐ ☐ ☐ bcm6338 240 ☐ SDR ☐ 1.1 ☐ ☐ ☐ ☐ ☐ ☐ ✔ ✔ ☐ ☐ ☐ [10.03](http://downloads.openwrt.org/backfire/10.03.1/brcm63xx/ "http://downloads.openwrt.org/backfire/10.03.1/brcm63xx/") bcm6345 140 ☐ SDR ☐ 1.1 ☐ ✔ ☐ ☐ ☐ ☐ ✔ ☐ ☐ ☐ ☐ [10.03](http://downloads.openwrt.org/backfire/10.03.1/brcm63xx/ "http://downloads.openwrt.org/backfire/10.03.1/brcm63xx/") [bcm6348](/tag/bcm6348?do=showtag&tag=bcm6348 "tag:bcm6348") [256](#overclocking "docs:techref:hardware:soc:soc.broadcom.bcm63xx ↵") ☐ SDR ☐ 1.1 1.1 ✔ ✔ ☐ ☐ ☐ ✔ ✔ ☐ ☐ ☐ [10.03](http://downloads.openwrt.org/backfire/10.03.1/brcm63xx/ "http://downloads.openwrt.org/backfire/10.03.1/brcm63xx/") [bcm6358](/tag/bcm6358?do=showtag&tag=bcm6358 "tag:bcm6358") 300 ✔ DDR ☐ 1.1 2.0 ✔ ✔ ☐ ☐ ☐ ✔ ✔ ☐ ☐ ☐ [10.03](http://downloads.openwrt.org/backfire/10.03.1/brcm63xx/ "http://downloads.openwrt.org/backfire/10.03.1/brcm63xx/") [bcm6359](/tag/bcm6359?do=showtag&tag=bcm6359 "tag:bcm6359") 300 ✔ DDR ☐ 2.0 2.0 ✔ ✔ ☐ ☐ ☐ ☐ ☐ ☐ ☐ ☐ [10.03](http://downloads.openwrt.org/backfire/10.03.1/brcm63xx/ "http://downloads.openwrt.org/backfire/10.03.1/brcm63xx/") [bcm6361](/tag/bcm6361?do=showtag&tag=bcm6361 "tag:bcm6361")  
[bcm6362](/tag/bcm6362?do=showtag&tag=bcm6362 "tag:bcm6362") 400 ✔ DDR2 ✔ 2.0 2.0 ☐ ☐ ✔ ✔ ✔ ✔ ✔ ☐ ☐ ☐ [r32923](https://dev.openwrt.org/changeset/32923/trunk "https://dev.openwrt.org/changeset/32923/trunk") [bcm6367](/tag/bcm6367?do=showtag&tag=bcm6367 "tag:bcm6367") 400 ✔ DDR ✔ 2.0 2.0 ✔ ✔ ☐ ☐ ✔ ✔ ✔ ✔ ☐ ☐ 12.09 [bcm6368](/tag/bcm6368?do=showtag&tag=bcm6368 "tag:bcm6368") 400 ✔ DDR ✔ 2.0 2.0 ✔ ✔ ☐ ☐ ✔ ✔ ✔ ✔ ✔ ☐ 12.09 [bcm6369](/tag/bcm6369?do=showtag&tag=bcm6369 "tag:bcm6369") 400 ✔ DDR ✔ 2.0 2.0 ✔ ✔ ☐ ☐ ✔ ☐ ☐ ☐ ☐ ☐ [bcm63167](/tag/bcm63167?do=showtag&tag=bcm63167 "tag:bcm63167")  
[bcm63168](/tag/bcm63168?do=showtag&tag=bcm63168 "tag:bcm63168")  
[bcm63268](/tag/bcm63268?do=showtag&tag=bcm63268 "tag:bcm63268") 400 ✔ DDR2/3 ✔ 2.0 2.0 ☐ ☐ ✔ ✔ ✔ ✔ ✔ ✔ ✔ ☐ [bcm63169](/tag/bcm63169?do=showtag&tag=bcm63169 "tag:bcm63169")  
[bcm63269](/tag/bcm63269?do=showtag&tag=bcm63269 "tag:bcm63269") 400 ✔ DDR2 ✔ 2.0 2.0 ☐ ☐ ✔ ✔ ✔ ☐ ☐ ☐ ☐ ☐ [bcm6816](/tag/bcm6816?do=showtag&tag=bcm6816 "tag:bcm6816") 400 ✔ DDR2 ✔ 2.0 2.0 ✔ ✔ ✔ ☐ ✔ ☐ ☐ ☐ ☐ ✔ [bcm6818](/tag/bcm6818?do=showtag&tag=bcm6818 "tag:bcm6818") 400 ✔ DDR2 ✔ 2.0 2.0 ✔ ✔ ✔ ☐ ✔ ☐ ☐ ☐ ☐ ✔ [bcm63138](/tag/bcm63138?do=showtag&tag=bcm63138 "tag:bcm63138") 1000 ✔ DDR3 ✔ 3.0 3.0 ☐ ☐ ✔ ☐ ? ✔ ✔ ✔ ✔ ☐ [bcm63139](/tag/bcm63139?do=showtag&tag=bcm63139 "tag:bcm63139") 1000 ✔ DDR3 ✔ 3.0 3.0 ☐ ☐ ? ☐ ✔ ? ? ? ? ☐

- The third digit, when set to 3 (like in BCM6335, BCM6338) denotes a single-chip and cost-reduction oriented design.
- There are also some other variants like bcm6341, which is a DSP used in VoIP products in conjunction with a BCM6348 SoC.
- The bcm63138 supports G.fast, G.inp and SRA.

## CPU caches

icache dcache SoC CPU version Core Size (kB) Associativity Linesize (bytes) Cache policy Size (kB) Associativity Aliases Linesize (bytes) Cache policy BCM6348 **BMIPS3300 V0.7** 0 16 2-way 16 VIPT 8 2-way ☐ 16 VIPT BCM6318 **BMIPS3300 v3.3** 0 64 4-way 16 VIPT 32 2-way ✔ 16 VIPT BCM6358 **BMIPS4350 V1.0** 0 32 2-way 16 VIPT 16 2-way ✔ 16 VIPT 1 16 2-way 16 VIPT BCM6368 **BMIPS4350 V3.1** 0 64 4-way 16 VIPT 32 2-way ✔ 16 VIPT 1 64 4-way 16 VIPT BCM6361 **BMIPS4350 V7.0** 0 32 4-way 16 VIPT 32 2-way ✔ 16 VIPT 1 32 4-way 16 VIPT BCM6328 **BMIPS4350 v7.5** 0 32 4-way 16 VIPT 32 2-way ✔ 16 VIPT BCM63168 **BMIPS4350 V8.0** 0 64 4-way 16 VIPT 32 2-way ✔ 16 VIPT 1 64 4-way 16 VIPT

**VIPT** = Virtually indexed, physically tagged

See → [http://www.linux-mips.org/wiki/Caches](http://www.linux-mips.org/wiki/Caches "http://www.linux-mips.org/wiki/Caches")

## Internal BUS

- **SSB**: 6348, 6358, 6368
- **BCMA**: 6318, 6328, 6362, 63168, 63268

## TRNG

[Hardware random number generator](https://en.wikipedia.org/wiki/Hardware_random_number_generator "https://en.wikipedia.org/wiki/Hardware_random_number_generator")

Only available in **BCM6362, BCM6368, BCM6816**. GPL supported. [bcm63xx-rng.c](http://lxr.free-electrons.com/source/drivers/char/hw_random/bcm63xx-rng.c "http://lxr.free-electrons.com/source/drivers/char/hw_random/bcm63xx-rng.c") [dev-rng.c](http://lxr.free-electrons.com/source/arch/mips/bcm63xx/dev-rng.c "http://lxr.free-electrons.com/source/arch/mips/bcm63xx/dev-rng.c")

To take advantage of this hardware feature, **rng-tools** should be installed.

## Cipher Engine

BCM63xx SoCs have [cryptographic hardware accelerators](/docs/techref/hardware/cryptographic.hardware.accelerators "docs:techref:hardware:cryptographic.hardware.accelerators"). The Cipher engine accelerates the IPSec protocol by using dedicated hardware blocks. BCM63XX SoCs (all family? ![FIXME](/lib/images/smileys/fixme.svg)) are implemented with the Encapsulating Security Payload (ESP) and Authentication Header (AH) IPSec protocols:

- **AES and DES/3DES** hardware encryption and decryption.
  
  - AES in both Cipher Block Chaining (CBC) mode and Counter (CTR) mode. Can be performed in 128-, 192-, and 256-bit modes.
  - DES, 3DES in Cipher Block Chaining (CBC) mode
- **HMAC-SHA1 and HMAC-MD5** authentication in hardware.

This what Broadcom calls **SPU** (Secure Processing Unit). The driver is available with GPL

[http://code.google.com/p/gfiber-gflt100/source/browse/bcmdrivers/opensource/char/spudd/impl2/](http://code.google.com/p/gfiber-gflt100/source/browse/bcmdrivers/opensource/char/spudd/impl2/ "http://code.google.com/p/gfiber-gflt100/source/browse/bcmdrivers/opensource/char/spudd/impl2/")

The SPU drivers has been added since Linux kernel v4.11 → [https://github.com/torvalds/linux/commit/9d12ba8](https://github.com/torvalds/linux/commit/9d12ba8 "https://github.com/torvalds/linux/commit/9d12ba8")

But there isn't still support for SPU under OpenWrt/LEDE.

## SPI

[Serial Peripheral Interface](https://en.wikipedia.org/wiki/Serial_Peripheral_Interface_Bus "https://en.wikipedia.org/wiki/Serial_Peripheral_Interface_Bus")

Two types of SPI controllers are present in BCM63xx:

- **SPI** : **Not** available in 6318, 6328, 6345
- **HSSPI**: High speed SPI, **only** available in 6318, 6328, 6362, 63268 SoCs

By default only one or two (more in newer SoCs) Slave Selects are available. Additional Slave Selects are at GPIO lines, but they need to be enabled.

(SPI) Slave Select 0 Slave Select 1 Slave Select 2 Slave Select 3 Slave Select 4 Slave Select 5 **BCM6338** ✔ ✔ ✔ ☐ ☐ ☐ **BCM6348** ✔ GPIO29 GPIO30 GPIO31 ☐ ☐ **BCM6358** ✔ ✔ GPIO32 GPIO33 ☐ ☐ **BCM6368**  
**BCM6816**  
**BCM6818** ✔ ✔ GPIO28 GPIO29 GPIO30 GPIO31 **BCM6362** ✔ ✔ GPIO9 GPIO10 ☐ ☐

(HSSPI) Slave Select 0 Slave Select 1 Slave Select 2 Slave Select 3 Slave Select 4 Slave Select 5 Slave Select 6 Slave Select 7 **BCM6328** ✔ ✔ ✔ ✔ ☐ ☐ ☐ ☐ **BCM6828** ✔ ✔ GPIO16 GPIO17 GPIO9 ☐ ☐ ☐ **BCM63268** ✔ ✔ ✔ ✔ GPIO16 GPIO17 GPIO8 GPIO9

Snippet code example for enabling these extra slave-selects at GPIOs:

```
/* BCM6348 */
	u32 val;
	/* Enable Extra SPI CS */
	/* GPIO 29 is SS1, GPIO 30 is SS2, GPIO 31 is SS2 */
	val = bcm_gpio_readl(GPIO_MODE_REG);
	val |= GPIO_MODE_6348_G1_SPI_MASTER;
	bcm_gpio_writel(val, GPIO_MODE_REG);
 
/* BCM6358 */
	u32 val;
	/* Enable Overlay for SPI SS Pins */
	val = bcm_gpio_readl(GPIO_MODE_REG);
	val |= GPIO_MODE_6358_EXTRA_SPI_SS;
	bcm_gpio_writel(val, GPIO_MODE_REG);
	/* Enable SPI Slave Select as Output Pins */
        /* GPIO 32 is SS2, GPIO 33 is SS3 */
	val = bcm_gpio_readl(GPIO_CTL_HI_REG);
	val |= 0x0003;
	bcm_gpio_writel(val, GPIO_CTL_HI_REG);
 
/* BCM6368 */
	u32 val;
	/* Enable Extra SPI CS */
	val = bcm_gpio_readl(GPIO_MODE_REG);
	val |= (GPIO_MODE_6368_SPI_SSN2 | GPIO_MODE_6368_SPI_SSN3 | GPIO_MODE_6368_SPI_SSN4 | GPIO_MODE_6368_SPI_SSN5);
	bcm_gpio_writel(val, GPIO_MODE_REG);
	/* Enable SPI Slave Select as Output Pins */            
        /* GPIO 28 is SS2, GPIO 29 is SS3, GPIO 30 is SS4, GPIO 31 is SS5*/   
	val = bcm_gpio_readl(GPIO_CTL_LO_REG);
	val |= (GPIO_MODE_6368_SPI_SSN2 | GPIO_MODE_6368_SPI_SSN3 | GPIO_MODE_6368_SPI_SSN4 | GPIO_MODE_6368_SPI_SSN5);
	bcm_gpio_writel(val, GPIO_CTL_LO_REG);
 
/* BCM6328 */
#define SEL_SPI2                 8
#define PINMUX_SEL_SPI2_MASK     (3 << SEL_SPI2)
#define PINMUX_SEL_SPI2          (2 << SEL_SPI2)
	u32 val;
	/* configure pinmux to SPI extra Slave Select */
	val = bcm_gpio_readl(GPIO_PINMUX_OTHR_REG);
	val &= ~PINMUX_SEL_SPI2_MASK;
	bcm_gpio_writel(val, GPIO_PINMUX_OTHR_REG);
 
	val = bcm_gpio_readl(GPIO_PINMUX_OTHR_REG);
	val |= PINMUX_SEL_SPI2;
	bcm_gpio_writel(val, GPIO_PINMUX_OTHR_REG);
 
/* BCM63268 */
#define GPIO_MODE_63268_HSSPI_SSN4		(1 << 16)
#define GPIO_MODE_63268_HSSPI_SSN5		(1 << 17)
#define GPIO_MODE_63268_HSSPI_SSN6		(1 << 8)
#define GPIO_MODE_63268_HSSPI_SSN7		(1 << 9)
	u32 val;
	/* GPIO 16 is SS4, GPIO 17 is SS5, GPIO 8 is SS6, GPIO 9 is SS7*/   
	val = bcm_gpio_readl(GPIO_MODE_REG);
	val |= (GPIO_MODE_63268_HSSPI_SSN4 | GPIO_MODE_63268_HSSPI_SSN5 | GPIO_MODE_63268_HSSPI_SSN6 | GPIO_MODE_63268_HSSPI_SSN7);
	bcm_gpio_writel(val, GPIO_MODE_REG);
```

### Locating slave selects on the board

We can locate slave selects on the board by toggling the state of them.

1. Build a firmware with `devmem` enabled in busybox and kernel
2. Use this script to *blink* a slave select
   
   ```
   #!/bin/sh
    
   # Toggle the SPI_SS_POLARITY, "blink" the SPI chip select
   # Example: "blink" the chip select 2
   # ./sstoggle.sh 2
    
   #6318
   #SPIBASE=0x10003000
    
   #6328 6362 63268
   SPIBASE=0x10001000
    
   DEFAULT=`devmem $SPIBASE`
   OFF=`printf "0x%x" "$(( $DEFAULT | (1 << $1) ))"`
   ON=`printf "0x%x" "$(( $DEFAULT & ~(1 << $1) ))"`
    
   while true; do
   	devmem $SPIBASE 32 $OFF
   	echo "[OFF]: $SPIBASE 32 $OFF"
   	sleep 1
    
   	devmem $SPIBASE 32 $ON
   	echo "[ON ]: $SPIBASE 32 $ON"
   	sleep 1
   done
   ```
3. Use a voltimeter or a led (with a 270 ohm series resistor) to see if the candidate for the SPI slave select on the board blinks

The script is only valid for HSSPI.

## GPIOs

[General Purpose Input/Output](/docs/techref/hardware/port.gpio "docs:techref:hardware:port.gpio")

On bcm63xx boards the GPIOs are used for diferent purposes:

- **software leds**: the GPIOs are controled by the linux kernel, and can be user configured by using led triggers drivers.
- **hardware leds**: the GPIOs are multiplexed to act as pure leds controled by hardware. The GPIO functionality is lost, avoiding to control them with OpenWrt. They can monitor LAN activity, serial activity, and so on. They can be software controled again by writing some particular registers of the SoC.
- **buttons**: configured as inputs, software controled using the polling method. Can be configured by the user to trigger events.
- **other hardware**: some GPIOs are wired to hardware specific interfaces, such as PCI, PCMCIA, ethernet, UART, SPI, and so on. They are multiplexed and enabled by OpenWrt during initialization of the board devices.

See [BCM6348 GPIO pinmux](/docs/techref/hardware/soc/soc.broadcom.bcm63xx/pinmux "docs:techref:hardware:soc:soc.broadcom.bcm63xx:pinmux")

The amount of GPIOs of each SoC model is different:

BCM6333 BCM6338 BCM6345 BCM6348 BCM6358 BCM6368 BCM6318 BCM6328 BCM6362 BCM63268 **GPIO count** 5 8 16 37 38 38 50 32 48 52

When having more than 32 GPIOs they are splitted between 2 gpiochips. The labels in the Linux kernel are:

- `bcm63xx-gpio.0`
- `bcm63xx-gpio.1`

### External IRQs

A few GPIOs are shared with external IRQs on most SoCs except BCM6338

External interrupts IRQ\_EXT\_0 IRQ\_EXT\_1 IRQ\_EXT\_2 IRQ\_EXT\_3 IRQ\_EXT\_4 IRQ\_EXT\_5 **BCM6318** GPIO32 GPIO33 ? ? ☐ ☐ **BCM6328** GPIO23 GPIO24 GPIO15 GPIO12 ☐ ☐ **BCM6338** ✔ ✔ ☐ ☐ ☐ ☐ **BCM6345** ? ? ? ? ☐ ☐ **BCM6348** GPIO32 GPIO33 GPIO34 GPIO35 GPIO36 ☐ **BCM6358** GPIO34 GPIO35 GPIO36 GPIO37 GPIO32 GPIO33 **BCM6368** **BCM6362** GPIO24 GPIO25 GPIO26 GPIO27 ☐ ☐ **BCM63268** GPIO32 GPIO33 GPIO34 GPIO35 ☐ ☐

\*) Guessed

Caveats:

- IRQ\_EXT\_4 and IRQ\_EXT\_5 aren't defined in the kernel driver
- IRQ\_EXT\_4 and IRQ\_EXT\_5 aren't implemented in BCM6358 SoC (OpenWrt ≤ Barrier Breaker). Proposed patch for Barrier Breaker → [http://pastebin.com/xaqJznWw](http://pastebin.com/xaqJznWw "http://pastebin.com/xaqJznWw")
- IRQ\_EXT\_4 in BCM6348 cannot be managed because it seems there isn't enough *CP0 CAUSE* registers to do the job.
- In Chaos Calmer version the external IRQs are broken → [https://dev.openwrt.org/ticket/21613](https://dev.openwrt.org/ticket/21613 "https://dev.openwrt.org/ticket/21613")

Since LEDE Reboot there is full support for external IRQs with “gpio to irq” translation. → [https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=dd7079e79a](https://git.openwrt.org/?p=openwrt%2Fopenwrt.git%3Ba%3Dcommit%3Bh%3Ddd7079e79a "https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=dd7079e79a")

Snippet kernel code example: a button press triggers an IRQ, printing something on the console. Tested on BCM6348, Openwrt 12.09 and GPIO33 connected to an external button.

```
#include <linux/kernel.h>
#include <linux/err.h>
#include <linux/module.h>
#include <linux/spinlock.h>
#include <linux/interrupt.h>
 
#include <bcm63xx_cpu.h>
#include <bcm63xx_io.h>
#include <bcm63xx_regs.h>
#include <bcm63xx_irq.h>
 
static irqreturn_t gpio_interrupt(int irq, void *dev_id)
{
	printk("my IRQ triggered!!!!\n");
	return IRQ_HANDLED;
}
 
int bcm63xx_button_init(void)
{
	int ret, irq;
 
	printk("TEST IRQ (GPIO-button)\n");
	irq = IRQ_EXT_1;
	ret = request_irq(irq, gpio_interrupt, 0, "bcm63xx_extIRQ", NULL);
	if (ret) {
		printk(KERN_ERR "bcm63xx-extIRQ: failed to register irq %d\n",irq);
		return ret;
	}
	printk("Mapped IRQ %d\n", irq );
 
	return 0;
}
 
arch_initcall(bcm63xx_button_init);
```

## Bootloader

[bootloader](/docs/techref/bootloader "docs:techref:bootloader"): Some devices use [redboot](/docs/techref/bootloader/redboot "docs:techref:bootloader:redboot") such as Inventel Liveboxes. Most of the others use [cfe](/docs/techref/bootloader/cfe "docs:techref:bootloader:cfe") with a built-in LZMA decompressor. CFE is not using standard LZMA compression arguments, and most noticeably, changes the dictionary size, so beware. Thomson routers have their own bootloader.

There is released source code for RedBoot (Inventel Livebox), and probably can be modified to work with other routers. Also there is some source code for [uboot](/docs/techref/bootloader/uboot "docs:techref:bootloader:uboot").

- TBSBOOT (crippled U-Boot) source code with the toolchain included for vx160 SoCs but with some code for bcm6338, bcm6348 and bcm6358: [UBOOT-sourcecode-vx160.tar.gz](https://drive.google.com/uc?export=download&id=0B-EMoBe-_OdBSjF3bFFtZEp2WGs "https://drive.google.com/uc?export=download&id=0B-EMoBe-_OdBSjF3bFFtZEp2WGs")
- RedBoot source code for Inventel Liveboxes (bcm6348) : [REDBOOT-sourcecode-blue5g.tar.gz](https://drive.google.com/uc?export=download&id=0B-EMoBe-_OdBa1BNajBvaGhEZU0 "https://drive.google.com/uc?export=download&id=0B-EMoBe-_OdBa1BNajBvaGhEZU0")

On several CPE (Customer-premises equipment) hardware devices and especially on smart phones, the OEM bootloaders are feature poor (no netboot, no booting from a USB stick, etc.), obfuscated (require some magic values to be correct) or completely messed up and make it cumbersome, difficult or impossible to install free software on the device. It is thus paramount to always have at least some products available, that have OEM bootloaders that keep installing free software easy (cf. [generic.flashing](/docs/guide-user/installation/generic.flashing "docs:guide-user:installation:generic.flashing")). And it could be interesting to port such bootloaders to devices, which happen to come with a restricted bootloader. Compare the available [bootloader](/docs/techref/bootloader "docs:techref:bootloader") out there, their license, available code and feature sets. Please also remember that *available source code* it NOT enough, it has to be under some license, that allow for modification and redistribution.

### U-Boot

bcm63xx boards have U-boot support thanks to the developer Álvaro Fernández (Noltari). Currently only available for the RAM bootloader version. The ROM version requires low level initialisations to be integrated into U-Boot (TODO).

[https://github.com/Noltari/u-boot/commits/master?author=noltari](https://github.com/Noltari/u-boot/commits/master?author=noltari "https://github.com/Noltari/u-boot/commits/master?author=noltari")

There is an official broadcom u-boot port for 63137/63138, 63158, and 63178; it is able to replace cfe, but there is no GPL release of this yet.

## Dump the flash

There exists an utility to backup the entire flash:  
[cfetool](https://github.com/Noltari/cfetool "https://github.com/Noltari/cfetool")  
You must connect your PC with the bcm63xx router via serial TTL port while CFE is running. Then execute *cfetool* with a command like this, maybe different with different boot address / flash sizes.

```
./cfetool.py --read=dump.bin --addr=0xB8000000 --size=0x1000000 --block=0x10000
--addr=0xB8000000 -> Flash Memory Address (see CFE bootlog --> Boot Address)
--size=0x1000000 -> 16Mb Flash
--block=0x10000 -> Memory dumped each iteration (default is 10Kb 0x2800)
```

cfetool expects the serial port used is /dev/ttyUSB0 in your PC, but you can change it with “--serial=/dev/ttyUSB1”.

**Note**: not all CFEs have internally the dm/sm command, as a result of this cfetool may not work with some devices. Alternatively you can dump the flash via traditional methods like JTAG or with an OpenWrt ramdisk firmware version.

## Overclocking

### BCM6348

On the **BCM6348** the MPI interface is wired to both the flash chip and the miniPCI interface. The CPU clock configuration is strapped from 5 pins on this interface. These 5 pins use pulldown resistors (4.7 or 10 kohm) to configure the CPU clock:

Flash pin DQ0 DQ8 DQ1 DQ9 DQ10 CPU clock (MHz) mPCI pin AD27 AD28 AD29 AD30 AD31 Pulldown  
resistor ☐ ✔ ✔ ✔ ✔ **200** ☐ ✔ ☐ ✔ ✔ **240** ✔ ☐ ☐ ✔ ✔ **256** ☐ ☐ ☐ ✔ ✔ **264** ☐ ✔ ✔ ☐ ✔ **300**

Example of CPU clock modification → [Comtrend CT5361 overclocking](/toh/comtrend/ct5361#overclocking "toh:comtrend:ct5361")

**Note**: only tested on BCM6348KPBG

### BCM6368, BCM6369

The same pins used in BCM6348 are also used in the BCM6368 SoC. 4.7 kohm pull down resistors are also used to configure the CPU frequency.

Flash pin DQ0 DQ8 DQ1 DQ9 DQ10 CPU clock (MHz) mPCI pin AD27 AD28 AD29 AD30 AD31 Pulldown  
resistor ☐ ☐ ✔ ☐ ✔ **266** ☐ ☐ ☐ ☐ ✔ **320** ☐ ☐ ☐ ✔ ☐ **384** ☐ ☐ ☐ ☐ ☐ **400** ☐ ☐ ✔ ☐ ☐ **426** ☐ ☐ ✔ ✔ ✔ **533**

## Pinouts

### BCM6338 pinout

[![](/_media/media/datasheets/bcm6338_kfbg.png?h=300&tok=be4917)](/_media/media/datasheets/bcm6338_kfbg.png "media:datasheets:bcm6338_kfbg.png")

### BCM6348 pinout

[![](/_media/media/datasheets/bcm6348_kpbg_pinout.png?h=300&tok=fbbd68)](/_media/media/datasheets/bcm6348_kpbg_pinout.png "media:datasheets:bcm6348_kpbg_pinout.png") [![](/_media/media/datasheets/bcm6348_skfbg_pinout.png?h=300&tok=fc35cc)](/_media/media/datasheets/bcm6348_skfbg_pinout.png "media:datasheets:bcm6348_skfbg_pinout.png")

### BCM6358 pinout

[![](/_media/media/datasheets/bcm6358_r-pinout.png?h=320&tok=f77f66)](/_media/media/datasheets/bcm6358_r-pinout.png "media:datasheets:bcm6358_r-pinout.png")

### BCM6328 pinout

[![](/_media/media/datasheets/bcm6328_3kfbg_pinout.png?h=300&tok=ba8f0c)](/_media/media/datasheets/bcm6328_3kfbg_pinout.png "media:datasheets:bcm6328_3kfbg_pinout.png") [![](/_media/media/datasheets/bcm6328_1tkfbg_pinout.png?h=300&tok=438c0f)](/_media/media/datasheets/bcm6328_1tkfbg_pinout.png "media:datasheets:bcm6328_1tkfbg_pinout.png")

### BCM6368 pinout

[![](/_media/media/datasheets/bcm6368_kpbg_pinout.png?h=300&tok=2b2070)](/_media/media/datasheets/bcm6368_kpbg_pinout.png "media:datasheets:bcm6368_kpbg_pinout.png")

### BCM6361 partial pinout

[![](/_media/media/datasheets/bcm6361ekfebg.png?h=300&tok=284adc)](/_media/media/datasheets/bcm6361ekfebg.png "media:datasheets:bcm6361ekfebg.png")

### BCM6838 pinout

[![](/_media/media/datasheets/bcm6838_pinout.png?h=300&tok=440d5b)](/_media/media/datasheets/bcm6838_pinout.png "media:datasheets:bcm6838_pinout.png")

### BCM63168 pinout

[![](/_media/media/datasheets/bcm63168_kfebg_pinout.png?h=300&tok=497465)](/_media/media/datasheets/bcm63168_kfebg_pinout.png "media:datasheets:bcm63168_kfebg_pinout.png")

## Known 63xx platforms

### Some 6328 platforms\*:

[CPU](/docs/techref/hardware/soc/soc.broadcom.bcm63xx?datasrt=cpu "Sort by this column")↓ [Brand](/docs/techref/hardware/soc/soc.broadcom.bcm63xx?datasrt=%5Ebrand "Sort by this column")[Page](/docs/techref/hardware/soc/soc.broadcom.bcm63xx?datasrt=%25title%25 "Sort by this column")Broadcom BCM6328ADB[Techdata: ADB P.DG A4001N1](/toh/hwdata/adb/adb_pdga4001n1 "toh:hwdata:adb:adb_pdga4001n1")Broadcom BCM6328ADB[Techdata: ADB P.DG A4001N A-000-1A1-AE](/toh/hwdata/adb/adb_p.dg_a4001n_a-000-1a1-ae "toh:hwdata:adb:adb_p.dg_a4001n_a-000-1a1-ae")Broadcom BCM6328ADB[Techdata: ADB P.DG A4101N A-000-1A1-AE](/toh/hwdata/adb/adb_p.dg_a4101n_a-000-1a1-ae "toh:hwdata:adb:adb_p.dg_a4101n_a-000-1a1-ae")Broadcom BCM6328ADB[Techdata: ADB P.DG A4001N A-000-1A1-AX](/toh/hwdata/adb/adb_p.dg_a4001n_a-000-1a1-ax "toh:hwdata:adb:adb_p.dg_a4001n_a-000-1a1-ax")Broadcom BCM6328ADB[adb\_pdga4001n1](/toh/hwdata/adb/adb_pdga4001n1 "toh:hwdata:adb:adb_pdga4001n1"), [Techdata: ADB P.DG A4001N1](/start "start")Broadcom BCM6328Actiontec[Techdata: Actiontec GT784WNV 5A](/toh/hwdata/actiontec/actiontec_gt784wnv "toh:hwdata:actiontec:actiontec_gt784wnv")Broadcom BCM6328Arcadyan / Astoria[Techdata: Arcadyan / Astoria AR7516 (Orange / EE Bright Box)](/toh/hwdata/arcadyanastoria/arcadyanastoria_ar7516 "toh:hwdata:arcadyanastoria:arcadyanastoria_ar7516")Broadcom BCM63281Billion[Techdata: Billion BiPAC 7700N](/toh/hwdata/billion/billion_bipac_7700n "toh:hwdata:billion:billion_bipac_7700n")Broadcom BCM6328Comtrend[Techdata: Comtrend AR-5381u](/toh/hwdata/comtrend/comtrend_ar-5381u "toh:hwdata:comtrend:comtrend_ar-5381u")Broadcom BCM6328Comtrend[Techdata: Comtrend AR-5387un](/toh/hwdata/comtrend/comtrend_ar-5387un "toh:hwdata:comtrend:comtrend_ar-5387un")Broadcom BCM6328Comtrend[comtrend\_ar-5381u](/toh/hwdata/comtrend/comtrend_ar-5381u "toh:hwdata:comtrend:comtrend_ar-5381u"), [Techdata: Comtrend AR-5381u](/start "start")Broadcom BCM6328Comtrend[comtrend\_ar-5387un](/toh/hwdata/comtrend/comtrend_ar-5387un "toh:hwdata:comtrend:comtrend_ar-5387un"), [Techdata: Comtrend AR-5387un](/start "start")Broadcom BCM63281D-Link[Techdata: D-Link DSL-2640S A1](/toh/hwdata/d-link/d-link_dsl-2640s_a1 "toh:hwdata:d-link:d-link_dsl-2640s_a1")Broadcom BCM6328D-Link[Techdata: D-Link DSL-2740B/1B F1 (EU)](/toh/hwdata/d-link/d-link_dsl-2740b1b_f1 "toh:hwdata:d-link:d-link_dsl-2740b1b_f1")Broadcom BCM6328D-Link[Techdata: D-Link DSL-2750B T1](/toh/hwdata/d-link/d-link_dsl-2750b_t1 "toh:hwdata:d-link:d-link_dsl-2750b_t1")Broadcom BCM63281D-Link[Techdata: D-Link DSL-2750u C1](/toh/hwdata/d-link/d-link_dsl-2750u_c1 "toh:hwdata:d-link:d-link_dsl-2750u_c1")Broadcom BCM63281D-Link[Techdata: D-Link DSL-2750B B1 (EU)](/toh/hwdata/d-link/d-link_dsl-2750b_b1_eu "toh:hwdata:d-link:d-link_dsl-2750b_b1_eu")Broadcom BCM6328D-Link[d-link\_dsl-2750b\_t1](/toh/hwdata/d-link/d-link_dsl-2750b_t1 "toh:hwdata:d-link:d-link_dsl-2750b_t1"), [Techdata: D-Link DSL-2750B T1](/start "start")Broadcom BCM6328Innacomm[Techdata: Innacomm W3400V6](/toh/hwdata/innacomm/innacomm_w3400v6 "toh:hwdata:innacomm:innacomm_w3400v6")Broadcom BCM6328Inteno[Techdata: Inteno XG6846](/toh/hwdata/inteno/inteno_xg6846 "toh:hwdata:inteno:inteno_xg6846")Broadcom BCM63281Netgear[Techdata: Netgear DGN2200 v3](/toh/hwdata/netgear/netgear_dgn2200_v3 "toh:hwdata:netgear:netgear_dgn2200_v3")Broadcom BCM63281Netgear[Techdata: Netgear DGN2200 v4](/toh/hwdata/netgear/netgear_dgn2200_v4 "toh:hwdata:netgear:netgear_dgn2200_v4")Broadcom BCM6328NuCom[Techdata: NuCom R5010UNv2](/toh/hwdata/nucom/nucom_r5010un "toh:hwdata:nucom:nucom_r5010un")Broadcom BCM6328Sagem[Techdata: Sagem F@ST2704 V2](/toh/hwdata/sagem/sagem_fast2704_v2 "toh:hwdata:sagem:sagem_fast2704_v2")Broadcom BCM6328Sercomm[Techdata: Sercomm AD1018](/toh/hwdata/sercomm/sercomm_ad1018 "toh:hwdata:sercomm:sercomm_ad1018")Broadcom BCM6328Sercomm[Techdata: Sercomm AD1018 NOR](/toh/hwdata/sercomm/sercomm_ad1018_nor "toh:hwdata:sercomm:sercomm_ad1018_nor")Broadcom BCM6328Sercomm[Techdata: Sercomm AD1018 v2](/toh/hwdata/sercomm/sercomm_ad1018_v2 "toh:hwdata:sercomm:sercomm_ad1018_v2")Broadcom BCM6328Sercomm[Techdata: Sercomm AD1018 v1](/toh/hwdata/sercomm/sercomm_ad1018_v1 "toh:hwdata:sercomm:sercomm_ad1018_v1")Broadcom BCM6328Sercomm[sercomm\_ad1018\_nor](/toh/hwdata/sercomm/sercomm_ad1018_nor "toh:hwdata:sercomm:sercomm_ad1018_nor"), [Techdata: Sercomm AD1018 NOR](/start "start")Broadcom BCM6328Sercomm[sercomm\_ad1018\_v1](/toh/hwdata/sercomm/sercomm_ad1018_v1 "toh:hwdata:sercomm:sercomm_ad1018_v1"), [Techdata: Sercomm AD1018 v1](/start "start")Broadcom BCM6328TP-Link[Techdata: TP-Link TD-W8960N v4](/toh/hwdata/tp-link/tp-link_td-w8960n_v4 "toh:hwdata:tp-link:tp-link_td-w8960n_v4")Broadcom BCM63281Technicolor[Techdata: Technicolor TG582n DANT-1](/toh/hwdata/technicolor/technicolor_tg582n "toh:hwdata:technicolor:technicolor_tg582n")Broadcom BCM63281Technicolor[Techdata: Technicolor TG582n DANT-T](/toh/hwdata/technicolor/technicolor_tg582n_dant-t "toh:hwdata:technicolor:technicolor_tg582n_dant-t")Broadcom BCM63281Technicolor[Techdata: Technicolor TG582n DANT-V](/toh/hwdata/technicolor/technicolor_tg582n_dant-v "toh:hwdata:technicolor:technicolor_tg582n_dant-v")Broadcom BCM63281ZTE[Techdata: ZTE ZXHN H108N v1](/toh/hwdata/zte/zte_zxhn_h108n_v1 "toh:hwdata:zte:zte_zxhn_h108n_v1")

### Known 6338 platforms\*:

[ASUS AM602](http://ru.asus.com/products.aspx?l1=13&l2=96&l3=0&l4=0&model=1105&modelmenu=1 "http://ru.asus.com/products.aspx?l1=13&l2=96&l3=0&l4=0&model=1105&modelmenu=1") Huawei EchoLife HG510 [Netgear DM111P](http://www.netgear.co.uk/adsl_ethernet_modem_dm111p.php "http://www.netgear.co.uk/adsl_ethernet_modem_dm111p.php") [Dynalink RTA1320](http://www.dynalink.co.nz/modemsadsl_cur.htm?prod=RTA1320 "http://www.dynalink.co.nz/modemsadsl_cur.htm?prod=RTA1320") [(Nateks Unispot21)](http://www.nateks-networks.ru/content/view/44/45/ "http://www.nateks-networks.ru/content/view/44/45/") Siemens CL 110 [Zhone 6211](http://zhone.com/products/6211/ "http://zhone.com/products/6211/") [Zhone 6212-l2/-l3](http://zhone.com/products/6212/ "http://zhone.com/products/6212/") [tp-link tp-8840](http://www.tp-link.com/products/product_des.asp?id=44 "http://www.tp-link.com/products/product_des.asp?id=44") Thomson SpeedTouch ST516 v6 Thomson SpeedTouch ST530 v6 (same as above with USB port) Swisscom Internet-Box Light RTV1900VW

[CPU](/docs/techref/hardware/soc/soc.broadcom.bcm63xx?datasrt=cpu "Sort by this column")↓ [Brand](/docs/techref/hardware/soc/soc.broadcom.bcm63xx?datasrt=%5Ebrand "Sort by this column")[Page](/docs/techref/hardware/soc/soc.broadcom.bcm63xx?datasrt=%25title%25 "Sort by this column")Broadcom BCM6338Comtrend[Techdata: Comtrend CT-5367](/toh/hwdata/comtrend/comtrend_ct-5367 "toh:hwdata:comtrend:comtrend_ct-5367")Broadcom BCM6338D-Link[Techdata: D-Link DSL-2542B/3B D2 (EU)](/toh/hwdata/d-link/d-link_dsl-2542b3b "toh:hwdata:d-link:d-link_dsl-2542b3b")Broadcom BCM6338D-Link[Techdata: D-Link DSL-2640U/BRU/C C1](/toh/hwdata/d-link/d-link_dsl-2640ubruc_c1 "toh:hwdata:d-link:d-link_dsl-2640ubruc_c1")Broadcom BCM6338Inteno[Techdata: Inteno XG6749 v1.0](/toh/hwdata/inteno/inteno_xg6749 "toh:hwdata:inteno:inteno_xg6749")Broadcom BCM6338Siemens[Techdata: Siemens S1621-Z220-A](/toh/hwdata/siemens/siemens_s1621-z220-a "toh:hwdata:siemens:siemens_s1621-z220-a")Broadcom BCM6338Thomson[Techdata: Thomson TG585 v7](/toh/hwdata/thomson/thomson_tg585_v7 "toh:hwdata:thomson:thomson_tg585_v7")

### Known 6345 platforms\*:

[BT Voyager 2100](http://www.voyager.bt.com/wireless_devices/voyager_2100/product_info.htm "http://www.voyager.bt.com/wireless_devices/voyager_2100/product_info.htm") [Dynalink RTA230](http://www.dynalink.com.au/modemsadsl_cur.htm?prod=RTA230 "http://www.dynalink.com.au/modemsadsl_cur.htm?prod=RTA230") Dynalink RTA770W ZTE ZXDSL 831A [Siemens SE515](http://gigaset.siemens.com/shc/0,1935,hq_en_0_42931_rArNrNrNrN,00.html "http://gigaset.siemens.com/shc/0,1935,hq_en_0_42931_rArNrNrNrN,00.html") [Paradyne 6211-A1](http://www.zhone.com/products/6211/ "http://www.zhone.com/products/6211/") [US Robotics USR9105](http://www.usr.com/images/products/product-emea.asp?prod=9105 "http://www.usr.com/images/products/product-emea.asp?prod=9105") [US Robotics USR9106](http://www.usr.com/images/products/product-emea.asp?prod=9106 "http://www.usr.com/images/products/product-emea.asp?prod=9106") [Belkin F5D7632 v2](http://www.belkin.com/uk/support/product/?lid=enu&pid=F5D7632uk4A "http://www.belkin.com/uk/support/product/?lid=enu&pid=F5D7632uk4A")

[CPU](/docs/techref/hardware/soc/soc.broadcom.bcm63xx?datasrt=cpu "Sort by this column")↓ [Brand](/docs/techref/hardware/soc/soc.broadcom.bcm63xx?datasrt=%5Ebrand "Sort by this column")[Page](/docs/techref/hardware/soc/soc.broadcom.bcm63xx?datasrt=%25title%25 "Sort by this column")Broadcom BCM6345Siemens[Techdata: Siemens SE515](/toh/hwdata/siemens/siemens_se515 "toh:hwdata:siemens:siemens_se515")Broadcom BCM6345Telsey[Techdata: Telsey CPVA500](/toh/hwdata/telsey/telsey_cpva500 "toh:hwdata:telsey:telsey_cpva500")

### Some 6348 platforms\*:

[3Com 3CRWDR200A-75](https://h10145.www1.hp.com/downloads/SoftwareReleases.aspx?ProductNumber=JE457A "https://h10145.www1.hp.com/downloads/SoftwareReleases.aspx?ProductNumber=JE457A") [ASUS AM604](http://www.asus.com/Networks/ADSL_Modem_Routers/AM604 "http://www.asus.com/Networks/ADSL_Modem_Routers/AM604") [ASUS AM604g](http://www.asus.com/Networks/ADSL_Modem_Routers/AM604g/ "http://www.asus.com/Networks/ADSL_Modem_Routers/AM604g/") [ASUS](http://www.asus.com/Networks/ADSL_Modem_Routers/WL600g/ "http://www.asus.com/Networks/ADSL_Modem_Routers/WL600g/") [WL-600G](/toh/asus/wl600g "toh:asus:wl600g") [ASUS](http://www.asus.com/Networks/ADSL_Modem_Routers/AM200g/ "http://www.asus.com/Networks/ADSL_Modem_Routers/AM200g/") AM200G Belkin f5d7633-4 BT Voyager 2091 [Comtrend CT-638/1](https://oldwiki.archive.openwrt.org/toh/netcomm/nb9w "https://oldwiki.archive.openwrt.org/toh/netcomm/nb9w") [Dynalink RTA1046VW](http://www.dynalink.co.nz/cms/index.php?page=rta1046vw "http://www.dynalink.co.nz/cms/index.php?page=rta1046vw") Freebox v4 Freebox v5 Huawei EchoLife HG520 Huawei EchoLife HG550 [Linksys WAG325N](http://homesupport.cisco.com/en-eu/support/gateways/WAG325N "http://homesupport.cisco.com/en-eu/support/gateways/WAG325N") [Linksys WAG300N](http://homesupport.cisco.com/en-eu/support/gateways/WAG300N "http://homesupport.cisco.com/en-eu/support/gateways/WAG300N") [Netcomm NB8W](http://support.netcommwireless.com/product/xdsl/nb8w "http://support.netcommwireless.com/product/xdsl/nb8w") (Re-branded Comtrend CT-536) [Netcomm NB9](http://support.netcommwireless.com/product/voip/nb9 "http://support.netcommwireless.com/product/voip/nb9") (Re-branded Comtrend CT-638) [Netgear DG834PN](http://support.netgear.com/product/DG834PN "http://support.netgear.com/product/DG834PN") [Thomson Speedtouch TG605/TG605S](/toh/thomson/tg605 "toh:thomson:tg605") [Thomson Speedtouch ST716(g)](/toh/thomson/st716 "toh:thomson:st716") [Thomson Speedtouch ST780(i)WL](/toh/thomson/st780 "toh:thomson:st780") [US Robotics](http://www.usr-emea.com/support/s-prod-template.asp?loc=unkg&prod=9107 "http://www.usr-emea.com/support/s-prod-template.asp?loc=unkg&prod=9107") [USR9107](https://oldwiki.archive.openwrt.org/toh/us.robotics/usr9107 "https://oldwiki.archive.openwrt.org/toh/us.robotics/usr9107") [US Robotics](http://www.usr-emea.com/support/s-prod-template.asp?loc=unkg&prod=9108 "http://www.usr-emea.com/support/s-prod-template.asp?loc=unkg&prod=9108") [USR9108](/toh/us.robotics/usr9108 "toh:us.robotics:usr9108") [Zhone 6218](http://zhone.com/products/6218/ "http://zhone.com/products/6218/") [Zhone 6238](http://zhone.com/products/6238/ "http://zhone.com/products/6238/") ZTE ZXDSL 831CII

[CPU](/docs/techref/hardware/soc/soc.broadcom.bcm63xx?datasrt=cpu "Sort by this column")↓ [Brand](/docs/techref/hardware/soc/soc.broadcom.bcm63xx?datasrt=%5Ebrand "Sort by this column")[Page](/docs/techref/hardware/soc/soc.broadcom.bcm63xx?datasrt=%25title%25 "Sort by this column")Broadcom BCM6348ASUS[Techdata: ASUS WL-600g](/toh/hwdata/asus/asus_wl-600g "toh:hwdata:asus:asus_wl-600g")Broadcom BCM6348ASUS[asus\_wl-600g](/toh/hwdata/asus/asus_wl-600g "toh:hwdata:asus:asus_wl-600g"), [Techdata: ASUS WL-600g](/start "start")Broadcom BCM6348Asmax[Techdata: Asmax AR 1004g 1](/toh/hwdata/asmax/asmax_ar1004g_1 "toh:hwdata:asmax:asmax_ar1004g_1")Broadcom BCM6348Asus[Techdata: Asus DSL-N13 1](/toh/hwdata/asus/asus_dsl-n13_1 "toh:hwdata:asus:asus_dsl-n13_1")Broadcom BCM6348BT[Techdata: BT Home Hub 1 1.0, 1.5](/toh/hwdata/bt/bt_homehub1 "toh:hwdata:bt:bt_homehub1")Broadcom BCM6348Comtrend[Techdata: Comtrend CT-536+](/toh/hwdata/comtrend/comtrend_ct-536 "toh:hwdata:comtrend:comtrend_ct-536")Broadcom BCM6348Comtrend[Techdata: Comtrend CT-5361](/toh/hwdata/comtrend/comtrend_ct-5361 "toh:hwdata:comtrend:comtrend_ct-5361")Broadcom BCM6348Comtrend[Techdata: Comtrend CT-5365](/toh/hwdata/comtrend/comtrend_ct-5365 "toh:hwdata:comtrend:comtrend_ct-5365")Broadcom BCM6348Comtrend[Techdata: Comtrend CT-5621](/toh/hwdata/comtrend/comtrend_ct-5621 "toh:hwdata:comtrend:comtrend_ct-5621")Broadcom BCM6348Comtrend[Techdata: Comtrend HG-536+](/toh/hwdata/comtrend/comtrend_hg-536 "toh:hwdata:comtrend:comtrend_hg-536")Broadcom BCM6348Comtrend[comtrend\_ct-536](/toh/hwdata/comtrend/comtrend_ct-536 "toh:hwdata:comtrend:comtrend_ct-536"), [Techdata: Comtrend CT-536+](/start "start")Broadcom BCM6348Comtrend[comtrend\_ct-5361](/toh/hwdata/comtrend/comtrend_ct-5361 "toh:hwdata:comtrend:comtrend_ct-5361"), [Techdata: Comtrend CT-5361](/start "start")Broadcom BCM6348Comtrend[comtrend\_ct-5365](/toh/hwdata/comtrend/comtrend_ct-5365 "toh:hwdata:comtrend:comtrend_ct-5365"), [Techdata: Comtrend CT-5365](/start "start")Broadcom BCM6348Comtrend[comtrend\_ct-5621](/toh/hwdata/comtrend/comtrend_ct-5621 "toh:hwdata:comtrend:comtrend_ct-5621"), [Techdata: Comtrend CT-5621](/start "start")Broadcom BCM6348Comtrend[comtrend\_hg-536](/toh/hwdata/comtrend/comtrend_hg-536 "toh:hwdata:comtrend:comtrend_hg-536"), [Techdata: Comtrend HG-536+](/start "start")Broadcom BCM6348D-Link[Techdata: D-Link DSL-2640U(B) B2 (RU)](/toh/hwdata/d-link/d-link_dsl-2640u "toh:hwdata:d-link:d-link_dsl-2640u")Broadcom BCM6348Davolink[Techdata: Davolink DV-201AMR](/toh/hwdata/davolink/davolink_dv-201amr "toh:hwdata:davolink:davolink_dv-201amr")Broadcom BCM6348Davolink[Techdata: Davolink DV-2020](/toh/hwdata/davolink/davolink_dv-2020 "toh:hwdata:davolink:davolink_dv-2020")Broadcom BCM6348Gigaset[Techdata: Gigaset SL2-141-i](/toh/hwdata/gigaset/gigaset_sl2-141-i "toh:hwdata:gigaset:gigaset_sl2-141-i")Broadcom BCM6348Hitachi[Techdata: Hitachi AH4051](/toh/hwdata/hitachi/hitachi_ah4051 "toh:hwdata:hitachi:hitachi_ah4051")Broadcom BCM6348Inventel[Techdata: Inventel AOLBox D5213](/toh/hwdata/inventel/inventel_aolbox_d5213 "toh:hwdata:inventel:inventel_aolbox_d5213")Broadcom BCM6348Inventel[Techdata: Inventel Livebox 1 DV3210](/toh/hwdata/inventel/inventel_livebox1_dv3210 "toh:hwdata:inventel:inventel_livebox1_dv3210")Broadcom BCM6348Inventel[Techdata: Inventel Livebox 1 DV4210](/toh/hwdata/inventel/inventel_livebox1_dv4210 "toh:hwdata:inventel:inventel_livebox1_dv4210")Broadcom BCM6348Inventel[Techdata: Inventel Livebox Pro V1 DV4410](/toh/hwdata/inventel/inventel_liveboxprov1_dv4410 "toh:hwdata:inventel:inventel_liveboxprov1_dv4410")Broadcom BCM6348Linksys[Techdata: Linksys WAG54G v1.1](/toh/hwdata/linksys/linksys_wag54g_v11 "toh:hwdata:linksys:linksys_wag54g_v11")Broadcom BCM6348Linksys[Techdata: Linksys WAG54GS v1.0, v1.1](/toh/hwdata/linksys/linksys_wag54gs "toh:hwdata:linksys:linksys_wag54gs")Broadcom BCM6348Linksys[Techdata: Linksys WAG54GX2](/toh/hwdata/linksys/linksys_wag54gx2 "toh:hwdata:linksys:linksys_wag54gx2")Broadcom BCM6348NETGEAR[Techdata: NETGEAR DG834G v4](/toh/hwdata/netgear/netgear_dg834g_v4 "toh:hwdata:netgear:netgear_dg834g_v4")Broadcom BCM6348NETGEAR[Techdata: NETGEAR DG834GT](/toh/hwdata/netgear/netgear_dg834gt "toh:hwdata:netgear:netgear_dg834gt")Broadcom BCM6348NetComm[Techdata: NetComm NB6PLUS4W Rev1](/toh/hwdata/netcomm/netcomm_nb6plus4w "toh:hwdata:netcomm:netcomm_nb6plus4w")Broadcom BCM6348NetComm[Techdata: NetComm NB9W](/toh/hwdata/netcomm/netcomm_nb9w "toh:hwdata:netcomm:netcomm_nb9w")Broadcom BCM6348Pirelli[Techdata: Pirelli Alice Gate2 Plus Wi-Fi AGA](/toh/hwdata/pirelli/pirelli_alicegate2plus "toh:hwdata:pirelli:pirelli_alicegate2plus")Broadcom BCM6348Pirelli[Techdata: Pirelli Alice Gate W2+ Vela](/toh/hwdata/pirelli/pirelli_alicegatew2plus "toh:hwdata:pirelli:pirelli_alicegatew2plus")Broadcom BCM6348Pirelli[Techdata: Pirelli DRG A125G](/toh/hwdata/pirelli/pirelli_drga125g "toh:hwdata:pirelli:pirelli_drga125g")Broadcom BCM6348Sagem[Techdata: Sagem F@ST2404](/toh/hwdata/sagem/sagem_fast2404 "toh:hwdata:sagem:sagem_fast2404")Broadcom BCM6348Sagem[Techdata: Sagem F@ST2604](/toh/hwdata/sagem/sagem_fast2604 "toh:hwdata:sagem:sagem_fast2604")Broadcom BCM6348T-Com / Telekom[Techdata: T-Com / Telekom Speedport W 500V](/toh/hwdata/t-comtelekom/t-comtelekom_speedportw500v "toh:hwdata:t-comtelekom:t-comtelekom_speedportw500v")Broadcom BCM6348T-Com / Telekom[t-comtelekom\_speedportw500v](/toh/hwdata/t-comtelekom/t-comtelekom_speedportw500v "toh:hwdata:t-comtelekom:t-comtelekom_speedportw500v"), [Techdata: T-Com / Telekom Speedport W 500V](/start "start")Broadcom BCM6348Tecom[Techdata: Tecom GW6000](/toh/hwdata/tecom/tecom_gw6000 "toh:hwdata:tecom:tecom_gw6000")Broadcom BCM6348Tecom[Techdata: Tecom GW6200](/toh/hwdata/tecom/tecom_gw6200 "toh:hwdata:tecom:tecom_gw6200")Broadcom BCM6348Telsey[Techdata: Telsey Alice W-Gate](/toh/hwdata/telsey/telsey_alicew-gate "toh:hwdata:telsey:telsey_alicew-gate")Broadcom BCM6348Telsey[Techdata: Telsey CPVA502+](/toh/hwdata/telsey/telsey_cpva502 "toh:hwdata:telsey:telsey_cpva502")Broadcom BCM6348Telsey[Techdata: Telsey CPVA502+W](/toh/hwdata/telsey/telsey_cpva502w "toh:hwdata:telsey:telsey_cpva502w")Broadcom BCM6348Tenda[Techdata: Tenda W548D](/toh/hwdata/tenda/tenda_w548d "toh:hwdata:tenda:tenda_w548d")Broadcom BCM6348Thomson[Techdata: Thomson ST7G](/toh/hwdata/thomson/thomson_st7g "toh:hwdata:thomson:thomson_st7g")Broadcom BCM6348Thomson[Techdata: Thomson ST585 6](/toh/hwdata/thomson/thomson_st585_6 "toh:hwdata:thomson:thomson_st585_6")Broadcom BCM6348Thomson[Techdata: Thomson ST706WL](/toh/hwdata/thomson/thomson_st706wl "toh:hwdata:thomson:thomson_st706wl")Broadcom BCM6348US Robotics[Techdata: US Robotics USR9108 A](/toh/hwdata/usrobotics/usrobotics_usr9108_a "toh:hwdata:usrobotics:usrobotics_usr9108_a")Broadcom BCM6348ZTE[Techdata: ZTE ZXDSL 531B(II)](/toh/hwdata/zte/zte_zxdsl531b "toh:hwdata:zte:zte_zxdsl531b")

### Some 6358 platforms\*:

Buffalo WBMR-G300N [D-Link DSL-2640B](http://www.dlink.com/products/?pid=567 "http://www.dlink.com/products/?pid=567") [D-Link DSL-2740B hw C2, C3](http://www.dlink.co.uk/cs/Satellite?c=Product_C&childpagename=DLinkEurope-GB%2FDLProductCarousel&cid=1197319446523&p=1197318962342&packedargs=ParentPageID%3D1197318962321%26TopLevelPageProduct%3DConsumer%26locale%3D1195806691854%26packedargs%3DProductParentID%253D1195808621247&pagename=DLinkEurope-GB%2FDLWrapper "http://www.dlink.co.uk/cs/Satellite?c=Product_C&childpagename=DLinkEurope-GB%2FDLProductCarousel&cid=1197319446523&p=1197318962342&packedargs=ParentPageID%3D1197318962321%26TopLevelPageProduct%3DConsumer%26locale%3D1195806691854%26packedargs%3DProductParentID%253D1195808621247&pagename=DLinkEurope-GB%2FDLWrapper") [Netcomm NB9WMAXX](https://oldwiki.archive.openwrt.org/oldwiki/openwrtdocs/hardware/netcomm/nb9wmaxx "https://oldwiki.archive.openwrt.org/oldwiki/openwrtdocs/hardware/netcomm/nb9wmaxx") [Netgear DG834N](https://oldwiki.archive.openwrt.org/oldwiki/openwrtdocs/hardware/netgear/dg834n "https://oldwiki.archive.openwrt.org/oldwiki/openwrtdocs/hardware/netgear/dg834n") [ALICE GATE VoIP 2 Plus Wi-Fi Business](/toh/pirelli/agpf "toh:pirelli:agpf") [US Robotics USR9113](http://www.usr-emea.com/products/p-broadband-product.asp?prod=bb-9113&loc=unkg "http://www.usr-emea.com/products/p-broadband-product.asp?prod=bb-9113&loc=unkg") [Zhone 6228](http://zhone.com/products/6228/ "http://zhone.com/products/6228/") [Thomson TG784](/toh/thomson/tg784 "toh:thomson:tg784")

[CPU](/docs/techref/hardware/soc/soc.broadcom.bcm63xx?datasrt=cpu "Sort by this column")↓ [Brand](/docs/techref/hardware/soc/soc.broadcom.bcm63xx?datasrt=%5Ebrand "Sort by this column")[Page](/docs/techref/hardware/soc/soc.broadcom.bcm63xx?datasrt=%25title%25 "Sort by this column")Broadcom BCM6358Alcatel-Sbell[Techdata: Alcatel-Sbell RG100A-AA Rev 0](/toh/hwdata/alcatel-sbell/alcatel-sbell_rg100a-aa "toh:hwdata:alcatel-sbell:alcatel-sbell_rg100a-aa")Broadcom BCM6358BT[Techdata: BT Home Hub 2 Type A](/toh/hwdata/bt/bt_homehub_2a "toh:hwdata:bt:bt_homehub_2a")Broadcom BCM6358Comtrend[Techdata: Comtrend CT-6373](/toh/hwdata/comtrend/comtrend_ct-6373 "toh:hwdata:comtrend:comtrend_ct-6373")Broadcom BCM6358Comtrend[comtrend\_ct-6373](/toh/hwdata/comtrend/comtrend_ct-6373 "toh:hwdata:comtrend:comtrend_ct-6373"), [Techdata: Comtrend CT-6373](/start "start")Broadcom BCM6358D-Link[Techdata: D-Link DSL-2650U/BRU/D](/toh/hwdata/d-link/d-link_dsl-2650ubrud "toh:hwdata:d-link:d-link_dsl-2650ubrud")Broadcom BCM6358D-Link[Techdata: D-Link DSL-2740B/1B C2](/toh/hwdata/d-link/d-link_dsl-2740b1b_c2 "toh:hwdata:d-link:d-link_dsl-2740b1b_c2")Broadcom BCM6358D-Link[Techdata: D-Link DSL-2740B/1B C3](/toh/hwdata/d-link/d-link_dsl-2740b1b_c3 "toh:hwdata:d-link:d-link_dsl-2740b1b_c3")Broadcom BCM6358D-Link[Techdata: D-Link DSL-2740U C2](/toh/hwdata/d-link/d-link_dsl-2740u_c2 "toh:hwdata:d-link:d-link_dsl-2740u_c2")Broadcom BCM6358D-Link[Techdata: D-Link DVA-G3810BN/TL A1](/toh/hwdata/d-link/d-link_dva-g3810bntl_a1 "toh:hwdata:d-link:d-link_dva-g3810bntl_a1")Broadcom BCM6358D-Link[d-link\_dsl-2740b1b\_c3](/toh/hwdata/d-link/d-link_dsl-2740b1b_c3 "toh:hwdata:d-link:d-link_dsl-2740b1b_c3"), [Techdata: D-Link DSL-2740B/1B C3](/start "start")Broadcom BCM6358D-Link[d-link\_dsl-2650ubrud](/toh/hwdata/d-link/d-link_dsl-2650ubrud "toh:hwdata:d-link:d-link_dsl-2650ubrud"), [toh:hwdata:d-link:d-link\_dsl-2650ubrud](/start "start")Broadcom BCM6358Huawei[Techdata: Huawei HG553](/toh/hwdata/huawei/huawei_hg553 "toh:hwdata:huawei:huawei_hg553")Broadcom BCM6358Huawei[Techdata: Huawei HG556a C](/toh/hwdata/huawei/huawei_hg556a_c "toh:hwdata:huawei:huawei_hg556a_c")Broadcom BCM6358Huawei[Techdata: Huawei HG556a B](/toh/hwdata/huawei/huawei_hg556a_b "toh:hwdata:huawei:huawei_hg556a_b")Broadcom BCM6358Huawei[Techdata: Huawei HG556a A](/toh/hwdata/huawei/huawei_hg556a_a "toh:hwdata:huawei:huawei_hg556a_a")Broadcom BCM6358Linksys[Techdata: Linksys WAG160N v1](/toh/hwdata/linksys/linksys_wag160n_v1 "toh:hwdata:linksys:linksys_wag160n_v1")Broadcom BCM6358Linksys[Techdata: Linksys WAG160N v2](/toh/hwdata/linksys/linksys_wag160n_v2 "toh:hwdata:linksys:linksys_wag160n_v2")Broadcom BCM6358UNETGEAR[Techdata: NETGEAR DGN2200 v1](/toh/hwdata/netgear/netgear_dgn2200_v1 "toh:hwdata:netgear:netgear_dgn2200_v1")Broadcom BCM6358NETGEAR[Techdata: NETGEAR MBRN3000](/toh/hwdata/netgear/netgear_mbrn3000_0 "toh:hwdata:netgear:netgear_mbrn3000_0")Broadcom BCM6358Pirelli[Techdata: Pirelli AliceGate AGPF](/toh/hwdata/pirelli/pirelli_alicegateagpf "toh:hwdata:pirelli:pirelli_alicegateagpf")Broadcom BCM6358Pirelli[Techdata: Pirelli FastWeb DRG A226M](/toh/hwdata/pirelli/pirelli_fastweb_drga226m "toh:hwdata:pirelli:pirelli_fastweb_drga226m")Broadcom BCM6358Pirelli[Techdata: Pirelli DRG A226M](/toh/hwdata/pirelli/pirelli_drg_a226m "toh:hwdata:pirelli:pirelli_drg_a226m")Broadcom BCM6358Pirelli[Techdata: Pirelli DRG A226G](/toh/hwdata/pirelli/pirelli_drg_a226g "toh:hwdata:pirelli:pirelli_drg_a226g")Broadcom BCM6358SFR (Société Française de Radiotéléphonie)[Techdata: SFR (Société Française de Radiotéléphonie) Neufbox4 (NB4)](/toh/hwdata/sfr/sfr_neufbox4 "toh:hwdata:sfr:sfr_neufbox4")Broadcom BCM6358T-Com / Telekom[Techdata: T-Com / Telekom Speedport W 303V Typ B](/toh/hwdata/t-comtelekom/t-comtelekom_speedportw303vtypb "toh:hwdata:t-comtelekom:t-comtelekom_speedportw303vtypb")Broadcom BCM6358T-Com / Telekom[t-comtelekom\_speedportw303vtypb](/toh/hwdata/t-comtelekom/t-comtelekom_speedportw303vtypb "toh:hwdata:t-comtelekom:t-comtelekom_speedportw303vtypb"), [Techdata: T-Com / Telekom Speedport W 303V Typ B](/start "start")Broadcom BCM6358STP-Link[Techdata: TP-Link TD-W8960N v1](/toh/hwdata/tp-link/tp-link_td-w8960n "toh:hwdata:tp-link:tp-link_td-w8960n")Broadcom BCM6358Telsey[Techdata: Telsey CPA-ZNTE60T](/toh/hwdata/telsey/telsey_cpa-znte60t "toh:hwdata:telsey:telsey_cpa-znte60t")

### Known 6361 platforms\*:

[CPU](/docs/techref/hardware/soc/soc.broadcom.bcm63xx?datasrt=cpu "Sort by this column")↓ [Brand](/docs/techref/hardware/soc/soc.broadcom.bcm63xx?datasrt=%5Ebrand "Sort by this column")[Page](/docs/techref/hardware/soc/soc.broadcom.bcm63xx?datasrt=%25title%25 "Sort by this column")Broadcom BCM6361Aztech[aztech\_dsl7002grv\_s](/toh/hwdata/aztech/aztech_dsl7002grv_s "toh:hwdata:aztech:aztech_dsl7002grv_s"), [Techdata: Aztech DSL7002GRV(S)](/start "start")Broadcom BCM6361BT[Techdata: BT Home Hub 3 Type B](/toh/hwdata/bt/bt_homehub3_2 "toh:hwdata:bt:bt_homehub3_2")Broadcom BCM6361SFR (Société Française de Radiotéléphonie)[Techdata: SFR (Société Française de Radiotéléphonie) Neufbox6 (NB6)](/toh/hwdata/sfr/sfr_neufbox6 "toh:hwdata:sfr:sfr_neufbox6")Broadcom BCM6361Sercomm[Techdata: Sercomm SHG1500 VS2](/toh/hwdata/sercomm/sercomm_shg1500_vs2 "toh:hwdata:sercomm:sercomm_shg1500_vs2")

### Known 6362 platforms\*:

[Motorola NVG510](http://www.att.com/equipment/accessory-details/?q_sku=sku5480277 "http://www.att.com/equipment/accessory-details/?q_sku=sku5480277") Commonly used with AT&amp;T copper Uverse, which supports VOIP but not TV. (Motorola GPL [source](http://sourceforge.net/motorola/nvg510/home/Home/ "http://sourceforge.net/motorola/nvg510/home/Home/")). Also on [WikiDevi](http://www.wikidevi.com/wiki/Motorola_NVG510 "http://www.wikidevi.com/wiki/Motorola_NVG510")

[CPU](/docs/techref/hardware/soc/soc.broadcom.bcm63xx?datasrt=cpu "Sort by this column")↓ [Brand](/docs/techref/hardware/soc/soc.broadcom.bcm63xx?datasrt=%5Ebrand "Sort by this column")[Page](/docs/techref/hardware/soc/soc.broadcom.bcm63xx?datasrt=%25title%25 "Sort by this column")Broadcom BCM6362Huawei[Techdata: Huawei HG253s v2](/toh/hwdata/huawei/huawei_hg253s_v2 "toh:hwdata:huawei:huawei_hg253s_v2")Broadcom BCM6362NETGEAR[Techdata: NETGEAR DGND3700 v2](/toh/hwdata/netgear/netgear_dgnd3700_v2 "toh:hwdata:netgear:netgear_dgnd3700_v2")Broadcom BCM6362Sagem[Techdata: Sagem F@ST2504n v.6](/toh/hwdata/sagem/sagem_fast2504n_v.6 "toh:hwdata:sagem:sagem_fast2504n_v.6")Broadcom BCM6362TP-Link[Techdata: TP-Link TD-W8970 v3.0](/toh/hwdata/tp-link/tp-link_td-w8970_v3.0 "toh:hwdata:tp-link:tp-link_td-w8970_v3.0")Broadcom BCM6362ZTE[Techdata: ZTE ZXA10 F660 2.0](/toh/hwdata/zte/zte_zxa10f660_20 "toh:hwdata:zte:zte_zxa10f660_20")

### Known 6368 platforms\*:

[Freebox Server](http://free.fr/adsl "http://free.fr/adsl") [ZyXEL P-870HN-51b](http://www.zyxel.com/fi/fi/products_services/p_870hn_51b.shtml "http://www.zyxel.com/fi/fi/products_services/p_870hn_51b.shtml") (commonly shipped to VDSL2 customers by Sonera in Finland) [ZyXEL P-870HN-53b](http://www.zyxel.com/products_services/p_870hn_5xb_series.shtml?t=p "http://www.zyxel.com/products_services/p_870hn_5xb_series.shtml?t=p") (commonly shipped to ADSL/VDSL customers by T-Mobile in Czech Republic) [NETGEAR VVG2000](http://www.netgear.com/service-provider/products/routers-and-gateways/dsl-gateways/vvg2000.aspx "http://www.netgear.com/service-provider/products/routers-and-gateways/dsl-gateways/vvg2000.aspx") (sold to VDSL2 customers by Bezeq in Israel) [D-Link DSL-6740U](http://www.dlink.ru/mn/products/5/1349.html "http://www.dlink.ru/mn/products/5/1349.html") (sold to VDSL2 customers by Bezeq in Israel) [Cisco 867-VAE](http://www.cisco.com/en/US/products/ps11999/index.html "http://www.cisco.com/en/US/products/ps11999/index.html") [Inteno DG201](http://intenogroup.com/store/tabid/88/categoryid/3/productid/2/default.aspx "http://intenogroup.com/store/tabid/88/categoryid/3/productid/2/default.aspx") [Actiontec Q2000](http://www.actiontec.com/216.html "http://www.actiontec.com/216.html") (commonly shipped to VDSL2 customers of Centurylink/Qwest)

[CPU](/docs/techref/hardware/soc/soc.broadcom.bcm63xx?datasrt=cpu "Sort by this column")↓ [Brand](/docs/techref/hardware/soc/soc.broadcom.bcm63xx?datasrt=%5Ebrand "Sort by this column")[Page](/docs/techref/hardware/soc/soc.broadcom.bcm63xx?datasrt=%25title%25 "Sort by this column")Broadcom BCM6368ADB[Techdata: ADB P.DG AV4202N](/toh/hwdata/adb/adb_pdgav4202n "toh:hwdata:adb:adb_pdgav4202n")Broadcom BCM6368Actiontec[Techdata: Actiontec R1000H](/toh/hwdata/actiontec/actiontec_r1000h "toh:hwdata:actiontec:actiontec_r1000h")Broadcom BCM6368Comtrend[Techdata: Comtrend VR-3025u](/toh/hwdata/comtrend/comtrend_vr-3025u "toh:hwdata:comtrend:comtrend_vr-3025u")Broadcom BCM6368Comtrend[Techdata: Comtrend VR-3025un](/toh/hwdata/comtrend/comtrend_vr-3025un "toh:hwdata:comtrend:comtrend_vr-3025un")Broadcom BCM6368Comtrend[Techdata: Comtrend VR-3026e v1](/toh/hwdata/comtrend/comtrend_vr-3026e_v1 "toh:hwdata:comtrend:comtrend_vr-3026e_v1")Broadcom BCM6368Comtrend[comtrend\_vr-3025un](/toh/hwdata/comtrend/comtrend_vr-3025un "toh:hwdata:comtrend:comtrend_vr-3025un"), [Techdata: Comtrend VR-3025un](/start "start")Broadcom BCM6368Huawei[Techdata: Huawei HG622](/toh/hwdata/huawei/huawei_hg622 "toh:hwdata:huawei:huawei_hg622")Broadcom BCM6368Huawei[Techdata: Huawei HG655b](/toh/hwdata/huawei/huawei_hg655b "toh:hwdata:huawei:huawei_hg655b")Broadcom BCM6368Huawei[Techdata: Huawei HG655d](/toh/hwdata/huawei/huawei_hg655d "toh:hwdata:huawei:huawei_hg655d")Broadcom BCM6368Huawei[Techdata: Huawei HG622u](/toh/hwdata/huawei/huawei_hg622u "toh:hwdata:huawei:huawei_hg622u")Broadcom BCM6368NETGEAR[Techdata: NETGEAR DGND3700 v1](/toh/hwdata/netgear/netgear_dgnd3700_v1 "toh:hwdata:netgear:netgear_dgnd3700_v1")Broadcom BCM6368NETGEAR[Techdata: NETGEAR DGND3800B](/toh/hwdata/netgear/netgear_dgnd3800b "toh:hwdata:netgear:netgear_dgnd3800b")Broadcom BCM6368Observa[Techdata: Observa VH4032N](/toh/hwdata/observa/observa_vh4032n "toh:hwdata:observa:observa_vh4032n")Broadcom BCM6368Pirelli[Techdata: Pirelli PRG AV4202N](/toh/hwdata/pirelli/pirelli_prgav4202n "toh:hwdata:pirelli:pirelli_prgav4202n")Broadcom BCM6368Thomson[Techdata: Thomson TG789VN](/toh/hwdata/thomson/thomson_tg789vn "toh:hwdata:thomson:thomson_tg789vn")Broadcom BCM6368ZTE[Techdata: ZTE ZXDSL 931WII v1](/toh/hwdata/zte/zte_zxdsl_20931wiiv_1 "toh:hwdata:zte:zte_zxdsl_20931wiiv_1")Broadcom BCM6368ZyXEL[Techdata: ZyXEL P-870HW-51a v2](/toh/hwdata/zyxel/zyxel_p-870hw-51a_v2 "toh:hwdata:zyxel:zyxel_p-870hw-51a_v2")Broadcom BCM6368UZyXEL[Techdata: ZyXEL P-870HN-51b](/toh/hwdata/zyxel/zyxel_p-870hn-51b "toh:hwdata:zyxel:zyxel_p-870hn-51b")Broadcom BCM6368ZyXEL[Techdata: ZyXEL P-870HN-53b](/toh/hwdata/zyxel/zyxel_p-870hn-53b "toh:hwdata:zyxel:zyxel_p-870hn-53b")Broadcom BCM6368ZyXEL[Techdata: ZyXEL P-870HNU-51c](/toh/hwdata/zyxel/zyxel_p-870hnu-51c "toh:hwdata:zyxel:zyxel_p-870hnu-51c")

### Known 63137 platforms\*:

[BT Smart Hub](http://www.ispreview.co.uk/index.php/2016/06/uk-isp-bt-launches-new-smart-hub-wireless-broadband-router.html "http://www.ispreview.co.uk/index.php/2016/06/uk-isp-bt-launches-new-smart-hub-wireless-broadband-router.html") (Distributed by BT since Summer 2016)

[CPU](/docs/techref/hardware/soc/soc.broadcom.bcm63xx?datasrt=cpu "Sort by this column")↓ [Brand](/docs/techref/hardware/soc/soc.broadcom.bcm63xx?datasrt=%5Ebrand "Sort by this column")[Page](/docs/techref/hardware/soc/soc.broadcom.bcm63xx?datasrt=%25title%25 "Sort by this column") Nothing found

### Known 63138 platforms\*:

[Plusnet Hub Two](https://www.ispreview.co.uk/index.php/2021/10/broadband-isp-plusnet-uk-launch-familiar-new-hub-two-router.html "https://www.ispreview.co.uk/index.php/2021/10/broadband-isp-plusnet-uk-launch-familiar-new-hub-two-router.html") (Distributed by Plusnet since October 2021)

[CPU](/docs/techref/hardware/soc/soc.broadcom.bcm63xx?datasrt=cpu "Sort by this column")↓ [Brand](/docs/techref/hardware/soc/soc.broadcom.bcm63xx?datasrt=%5Ebrand "Sort by this column")[Page](/docs/techref/hardware/soc/soc.broadcom.bcm63xx?datasrt=%25title%25 "Sort by this column") Nothing found

### Known 63167 platforms\*:

[Zyxel VMG8924-B10D](/toh/zyxel/vmg8924 "toh:zyxel:vmg8924") (commonly shipped to Tiscali customers in Italy)

[CPU](/docs/techref/hardware/soc/soc.broadcom.bcm63xx?datasrt=cpu "Sort by this column")↓ [Brand](/docs/techref/hardware/soc/soc.broadcom.bcm63xx?datasrt=%5Ebrand "Sort by this column")[Page](/docs/techref/hardware/soc/soc.broadcom.bcm63xx?datasrt=%25title%25 "Sort by this column") Nothing found

### Known 63168 platforms\*:

[Airties Air 5650](http://www.airties.com/products/dslgw/Air5650 "http://www.airties.com/products/dslgw/Air5650") (commonly shipped to TTnet Hipernet customers in Turkey) [D-Link DSL6850U](/toh/d-link/dsl-6850u "toh:d-link:dsl-6850u") SmartRG SR630N - 5-port VDSL modem, already runs some custom linux distribution [SmartRG SR505N](https://wikidevi.com/wiki/SmartRG_SR505N "https://wikidevi.com/wiki/SmartRG_SR505N"), also a VDSL modem, [maybe working with Tomato?](https://www.dslreports.com/forum/r28868424-SmartRG-SR505N-w-Tomato-WRT-w-SL-MLPPP "https://www.dslreports.com/forum/r28868424-SmartRG-SR505N-w-Tomato-WRT-w-SL-MLPPP") [ADB VV3212](http://www.slovanet.net/sk/zariadenia/internet/internetove-zariadenia/adb-vv3212.html "http://www.slovanet.net/sk/zariadenia/internet/internetove-zariadenia/adb-vv3212.html") (Distributed by Slovak Telekom) [Actiontec T1200H](http://opensource.actiontec.com/t1200x.html "http://opensource.actiontec.com/t1200x.html") [Actiontec T2200H](http://opensource.actiontec.com/t2200x.html "http://opensource.actiontec.com/t2200x.html") [Actiontec F2250](http://opensource.actiontec.com/f2250.html "http://opensource.actiontec.com/f2250.html") [Kasda KW5212, also a VDSL modem.](http://www.kasda.cn/product_info.asp?id=199 "http://www.kasda.cn/product_info.asp?id=199")

[CPU](/docs/techref/hardware/soc/soc.broadcom.bcm63xx?datasrt=cpu "Sort by this column")↓ [Brand](/docs/techref/hardware/soc/soc.broadcom.bcm63xx?datasrt=%5Ebrand "Sort by this column")[Page](/docs/techref/hardware/soc/soc.broadcom.bcm63xx?datasrt=%25title%25 "Sort by this column")Broadcom BCM63168Actiontec[Techdata: Actiontec T1200H](/toh/hwdata/actiontec/actiontec_t1200h "toh:hwdata:actiontec:actiontec_t1200h")Broadcom BCM63168Comtrend[Techdata: Comtrend VR-3032u](/toh/hwdata/comtrend/comtrend_vr-3032u "toh:hwdata:comtrend:comtrend_vr-3032u")Broadcom BCM63168Comtrend[comtrend\_vr-3032u](/toh/hwdata/comtrend/comtrend_vr-3032u "toh:hwdata:comtrend:comtrend_vr-3032u"), [Techdata: Comtrend VR-3032u](/start "start")Broadcom BCM63168D0Sagem[Techdata: Sagem F@ST3864OP](/toh/hwdata/sagem/sagem_f_st3864op "toh:hwdata:sagem:sagem_f_st3864op")Broadcom BCM63168Sercomm[Techdata: Sercomm SHG2500](/toh/hwdata/sercomm/sercomm_shg2500 "toh:hwdata:sercomm:sercomm_shg2500")Broadcom BCM63168Sercomm[sercomm\_shg2500](/toh/hwdata/sercomm/sercomm_shg2500 "toh:hwdata:sercomm:sercomm_shg2500"), [Techdata: Sercomm SHG2500](/start "start")Broadcom BCM63168Sky[Techdata: Sky SR102](/toh/hwdata/sky/sky_sr102 "toh:hwdata:sky:sky_sr102")Broadcom BCM63168SmartRG[Techdata: SmartRG SR505n](/toh/hwdata/smartrg/smartrg_sr505n "toh:hwdata:smartrg:smartrg_sr505n")Broadcom BCM63168ZTE[Techdata: ZTE ZXHN F660 2.3](/toh/hwdata/zte/zte_zxhnf660_23 "toh:hwdata:zte:zte_zxhnf660_23")Broadcom BCM63168ZyXEL[Techdata: ZyXEL P8702N](/toh/hwdata/zyxel/zyxel_p8702n "toh:hwdata:zyxel:zyxel_p8702n")

### Known 63268 platforms\*:

[Inteno DG301](/toh/inteno/dg301b "toh:inteno:dg301b") (commonly shipped to Sonera customers in Finland) [Technicolor TG799Svn v2](http://www.technicolor.com/en/solutions-services/connected-home/modems-gateways/xdsl-modems-gateways/smart-vdsl-gateway "http://www.technicolor.com/en/solutions-services/connected-home/modems-gateways/xdsl-modems-gateways/smart-vdsl-gateway") (commonly shipped to Telia customers in Sweden) [Zyxel C1000Z](https://wikidevi.com/wiki/ZyXEL_C1000Z "https://wikidevi.com/wiki/ZyXEL_C1000Z")

[CPU](/docs/techref/hardware/soc/soc.broadcom.bcm63xx?datasrt=cpu "Sort by this column")↓ [Brand](/docs/techref/hardware/soc/soc.broadcom.bcm63xx?datasrt=%5Ebrand "Sort by this column")[Page](/docs/techref/hardware/soc/soc.broadcom.bcm63xx?datasrt=%25title%25 "Sort by this column")Broadcom BCM63268Inteno[Techdata: Inteno DG301B](/toh/hwdata/inteno/inteno_dg301b "toh:hwdata:inteno:inteno_dg301b")Broadcom BCM63268T-Com / Telekom[t-comtelekom\_speedportw724vtypci](/toh/hwdata/t-comtelekom/t-comtelekom_speedportw724vtypci "toh:hwdata:t-comtelekom:t-comtelekom_speedportw724vtypci"), [Techdata: T-Com / Telekom Speedport W 724V Typ Ci](/start "start")

## Devices

The list of related devices: [bcm63xx](/tag/bcm63xx?do=showtag&tag=bcm63xx "tag:bcm63xx"), [bcm6318](/tag/bcm6318?do=showtag&tag=bcm6318 "tag:bcm6318"), [bcm6328](/tag/bcm6328?do=showtag&tag=bcm6328 "tag:bcm6328"), [bcm6348](/tag/bcm6348?do=showtag&tag=bcm6348 "tag:bcm6348"), [bcm6358](/tag/bcm6358?do=showtag&tag=bcm6358 "tag:bcm6358"), [bcm6361](/tag/bcm6361?do=showtag&tag=bcm6361 "tag:bcm6361"), [bcm6362](/tag/bcm6362?do=showtag&tag=bcm6362 "tag:bcm6362"), [bcm6368](/tag/bcm6368?do=showtag&tag=bcm6368 "tag:bcm6368"), [bcm6816](/tag/bcm6816?do=showtag&tag=bcm6816 "tag:bcm6816"), [bcm6818](/tag/bcm6818?do=showtag&tag=bcm6818 "tag:bcm6818") [bcm63167](/tag/bcm63167?do=showtag&tag=bcm63167 "tag:bcm63167"), [bcm63168](/tag/bcm63168?do=showtag&tag=bcm63168 "tag:bcm63168"), [bcm63169](/tag/bcm63169?do=showtag&tag=bcm63169 "tag:bcm63169"), [bcm63268](/tag/bcm63268?do=showtag&tag=bcm63268 "tag:bcm63268"),
