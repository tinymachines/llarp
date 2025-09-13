# xDSL (Digital subscriber line)

**`Note`** : This page is for **hardware and driver**; for help configuring your Internet connection, please see [Configuration of the Internet connection](/docs/guide-user/network/wan/internet.connection "docs:guide-user:network:wan:internet.connection") See the other [internet.access.technologies](/docs/techref/hardware/internet.access.technologies "docs:techref:hardware:internet.access.technologies").

## Overview

There are at least three companies with [xDSL](https://en.wikipedia.org/wiki/Digital%20subscriber%20line "https://en.wikipedia.org/wiki/Digital subscriber line")-Solutions:

Wikipedia Documentation in OpenWrt Wiki Linux support for xDSL Notes ADSL2+ VDSL proprietary OpenWrt proprietary OpenWrt [Lantiq](https://en.wikipedia.org/wiki/Lantiq "https://en.wikipedia.org/wiki/Lantiq") [lantiq\_xdsl](/docs/techref/hardware/soc/soc.lantiq#lantiq_xdsl "docs:techref:hardware:soc:soc.lantiq") ✓ ✔ ✓ wip the modem firmware is not opensource, it is shipped by OpenWrt and loaded by the opensource driver [Broadcom](https://en.wikipedia.org/wiki/Broadcom "https://en.wikipedia.org/wiki/Broadcom") [broadcom\_xdsl](/docs/techref/hardware/soc/soc.broadcom.bcm63xx#broadcom_xdsl "docs:techref:hardware:soc:soc.broadcom.bcm63xx") ✓ ✘ ✓ ✘ [about the proprietary driver](/inbox/adsl_support "inbox:adsl_support") [MediaTek](https://en.wikipedia.org/wiki/MediaTek "https://en.wikipedia.org/wiki/MediaTek") [mediatek\_xdsl](/docs/techref/hardware/soc/soc.mediatek#mediatek_xdsl "docs:techref:hardware:soc:soc.mediatek") ✓ ✘ ✓ ✘ [Ikanos](https://en.wikipedia.org/wiki/Ikanos "https://en.wikipedia.org/wiki/Ikanos") [ikanos\_xdsl](/docs/techref/hardware/soc/soc.ikanos#ikanos_xdsl "docs:techref:hardware:soc:soc.ikanos") ✓ ✘ ✓ ✘ a couple of FRITZ!Boxes are based on the [Fusiv Vx180 + IFE-6](http://www.wehavemorefun.de/fritzbox/Fusiv "http://www.wehavemorefun.de/fritzbox/Fusiv");  
the firmware is Linux-based, ergo there are proprietary drivers

[2009-Aug-24: Conexant sells its Broadband Access Product Line](http://www.ikanos.com/press-releases/ikanos-communications-completes-acquisition-of-broadband-access-product-line-from-conexant-systems-inc/ "http://www.ikanos.com/press-releases/ikanos-communications-completes-acquisition-of-broadband-access-product-line-from-conexant-systems-inc/")

## Commonalities

### Layer 1 (Physical layer)

[Digital subscriber line](https://en.wikipedia.org/wiki/Digital%20subscriber%20line "https://en.wikipedia.org/wiki/Digital subscriber line") is a family of Layer 1 communication protocols. The more prevalent members of the family are: [ADSL](https://en.wikipedia.org/wiki/Asymmetric%20digital%20subscriber%20line "https://en.wikipedia.org/wiki/Asymmetric digital subscriber line"), [ADSL2+](https://en.wikipedia.org/wiki/G.992.5 "https://en.wikipedia.org/wiki/G.992.5") and [VDSL2](https://en.wikipedia.org/wiki/Very-high-bit-rate%20digital%20subscriber%20line%202 "https://en.wikipedia.org/wiki/Very-high-bit-rate digital subscriber line 2"); there are different Annexes: [G.992.1#Annex\_A](https://de.wikipedia.org/wiki/G.992.1#Annex_A "https://de.wikipedia.org/wiki/G.992.1#Annex_A") and there are different Profiles: [VDSL2 Profiles](https://en.wikipedia.org/wiki/Very-high-bit-rate_digital_subscriber_line_2#Profiles "https://en.wikipedia.org/wiki/Very-high-bit-rate_digital_subscriber_line_2#Profiles").

#### DMT

To be able to do the [DMT (Discrete multitone modulation)](https://en.wikipedia.org/wiki/Discrete%20multitone%20modulation "https://en.wikipedia.org/wiki/Discrete multitone modulation") fast enough, some DSL-implementations use 2 CPUs, e.g. two MIPS 24Kc Cores, one being solely used for the DMT, other employ one MIPS 34Kc Core (contains support for multi-threading and also some DSP-extensions), and others have some [ASIC](https://en.wikipedia.org/wiki/Application-specific%20integrated%20circuit "https://en.wikipedia.org/wiki/Application-specific integrated circuit") for this purpose! Explanation: [DSPs are fast](https://www.olimex.com/Products/DSP/ "https://www.olimex.com/Products/DSP/")

#### AFE

Then some AFE (Analog Front-End) is required, this amplifies the signal and also performs the digital-to-analog and analog-to-diginal signal conversions. The AFE is a [Mixed-signal integrated circuit](https://en.wikipedia.org/wiki/Mixed-signal%20integrated%20circuit "https://en.wikipedia.org/wiki/Mixed-signal integrated circuit"), so (probably for manufacturing purposes) most solutions keep the AFE on a distinct Chip, e.g. the Lantiq VRX208 or VRX318 or the MediaTek TC3086 Ikanos IFE-6, etc. Though, the MediaTek [RT63260](http://www.mediatek.com/_en/01_products/04_pro.php?sn=1071 "http://www.mediatek.com/_en/01_products/04_pro.php?sn=1071") or the [Lantiq VINAX](http://www.wehavemorefun.de/fritzbox/VINAX-CPE "http://www.wehavemorefun.de/fritzbox/VINAX-CPE") are reported to be a single chip solutions.

#### Linux

- Layer1: In case some [DSP](https://en.wikipedia.org/wiki/Digital%20signal%20processing "https://en.wikipedia.org/wiki/Digital signal processing")-is used for the DMT-part, software needs to be written, supporting this [Instruction set](https://en.wikipedia.org/wiki/Instruction%20set "https://en.wikipedia.org/wiki/Instruction set") (e.g. the [Texas Instruments TMS320](https://en.wikipedia.org/wiki/Texas%20Instruments%20TMS320 "https://en.wikipedia.org/wiki/Texas Instruments TMS320")). No big deal, given the programmer has the necessary documentation, the knowledge and ability and the time for the work. ![;-)](/lib/images/smileys/wink.svg)

### Layer 2 (Data link layer)

AFAIR DSL is Layer 1 only and does not define a Layer 2. As Layer 2 communication protocols either [ATM](https://en.wikipedia.org/wiki/Asynchronous%20Transfer%20Mode "https://en.wikipedia.org/wiki/Asynchronous Transfer Mode") or [Ethernet](https://en.wikipedia.org/wiki/Ethernet#Layer_2_.E2.80.93_Datagrams "https://en.wikipedia.org/wiki/Ethernet#Layer_2_.E2.80.93_Datagrams") (the Layer2 parts) is employed. Some VDSL2-ISPs are reported to employ this already.

#### Linux

- Layer2: there is some support for ATM in Linux. But it is not very good ;-(
  
  - [http://linux-atm.sourceforge.net/](http://linux-atm.sourceforge.net/ "http://linux-atm.sourceforge.net/")
  - The Layer2-part of the Ethernet protocol family on the other hand is very well supported in the Linux kernel! So for the few cases, where the ISP abandoned ATM in favor of Ethernet, it should be much simpler to obtain fully working fully stable deep shit Linux support! ![;-)](/lib/images/smileys/wink.svg)
- [sourceforge.net: ATM drivers for PCI ADSL/ADSL2+ modems (solos)](http://sourceforge.net/projects/openadsl/files/linux-solos-driver/ "http://sourceforge.net/projects/openadsl/files/linux-solos-driver/")

### Authentication, Authorization, and Accounting

For Authentication, Authorization, and Accounting (login) often [PPP](https://en.wikipedia.org/wiki/Point-to-point%20protocol "https://en.wikipedia.org/wiki/Point-to-point protocol") is used. The most common solution is [PPPoE](https://en.wikipedia.org/wiki/Point-to-point%20protocol%20over%20Ethernet "https://en.wikipedia.org/wiki/Point-to-point protocol over Ethernet") ([PPPoA](https://en.wikipedia.org/wiki/Point-to-Point%20Protocol%20over%20ATM "https://en.wikipedia.org/wiki/Point-to-Point Protocol over ATM") is less common, and there are other solutions). To make things be (or look) a bit more complicated, PPPoE is supported by the Router operating system and by all Desktop operating systems, but not by the Modem and the DSLAM. So the Modem either translates the PPPoE packets into PPPoA packets (“PPPoE to PPPoA”) or encapsulates PPPoE packets insides of PPPoA packets (“PPPoEoA”). The Wikipedia visualizes this: ["PPPoEoA" or "PPPoE to PPPoA"](https://en.wikipedia.org/wiki/Point-to-point_protocol_over_Ethernet#How_PPPoE_fits_in_the_DSL_Internet_access_architecture "https://en.wikipedia.org/wiki/Point-to-point_protocol_over_Ethernet#How_PPPoE_fits_in_the_DSL_Internet_access_architecture").

### Operating System: OpenWrt (Linux kernel)

The operating system needs to support both parts: Layer 1 and Layer 2.

### TR-069 / CWMP (CPE WAN Management Protocol)

The protocol [TR-069 (Technical Report) / CWMP (CPE WAN Management Protocol)](/docs/guide-user/network/wan/tr-069 "docs:guide-user:network:wan:tr-069") was released in May 2004 (and a couple of amendments to it have been released since then); its original purpose is, to enable the ISP to cost-efficiently manage the configuration of the operating system running on the [Customer-premises equipment](https://en.wikipedia.org/wiki/Customer-premises%20equipment "https://en.wikipedia.org/wiki/Customer-premises equipment"), that is required to maintain connection. Well actually, it could do more... Hmm...

There is support for [tr-069](/docs/guide-user/network/wan/tr-069 "docs:guide-user:network:wan:tr-069") in OpenWrt (and GNU/Linux in general).
