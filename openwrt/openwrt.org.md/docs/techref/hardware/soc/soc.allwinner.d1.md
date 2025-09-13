# Allwinner D1 (sun20i)

RISC-V is a free, open, extensible instruction set architecture (ISA), the specification is now maintained by the nonprofit RISC-V Foundation.

Allwinner D1 (sun20i, also known as D1-H) is the first SoC of Allwinner which is based on a RISC-V core. D1 features single RV64GCV core XuanTie C906 from T-Head Semiconductor (subsidiary of Alibaba) and an additional 600 MHz Tensilica HiFi4 DSP.

Peripherals and devices mostly match the sunxi H3 board's ones, as the same IP blocks are being used. Supporting them is generally adding new compatibles into the drivers and a few quirks.

### Status

- Port status: [https://github.com/openwrt/openwrt/pull/12845](https://github.com/openwrt/openwrt/pull/12845 "https://github.com/openwrt/openwrt/pull/12845")
- Official doc site: [https://d1.docs.aw-ol.com/](https://d1.docs.aw-ol.com/ "https://d1.docs.aw-ol.com/")

### Hardware Highlights

Model RAM [Storage](/docs/techref/flash.layout "docs:techref:flash.layout") Network USB [Serial](/docs/techref/hardware/port.serial "docs:techref:hardware:port.serial") [JTAG](/docs/techref/hardware/port.jtag "docs:techref:hardware:port.jtag") [UEXT](https://en.wikipedia.org/wiki/UEXT "https://en.wikipedia.org/wiki/UEXT") Other linux-sunxi page [Nezha D1](/toh/allwinner/nezha "toh:allwinner:nezha") 512MiB/1GiB/2GiB DDR3 μSD, 256Mb NAND Gigabit Ethernet 1x USB2 yes n/a n/a HDMI, audio, CSI [Page](https://linux-sunxi.org/Allwinner_Nezha "https://linux-sunxi.org/Allwinner_Nezha") [DongshanPi Nezha STU](/toh/dongshanpi/nezha_stu "toh:dongshanpi:nezha_stu") 512MiB μSD Gigabit Ethernet - yes n/a n/a HDMI, 2×20 GPIO [Page](https://linux-sunxi.org/DongshanPi_Nezha_STU "https://linux-sunxi.org/DongshanPi_Nezha_STU") [MangoPi MQ-Pro](/toh/mangopi/mq_pro "toh:mangopi:mq_pro") 512MiB/1GiB μSD, optional SPI flash RTL8723 - yes n/a n/a HDMI, I2S, additional dock [Page](https://linux-sunxi.org/MangoPi_MQ-Pro "https://linux-sunxi.org/MangoPi_MQ-Pro") [Sipeed LicheePi RV](/toh/sipeed/licheepi_rv "toh:sipeed:licheepi_rv") 512MiB μSD RTL8723 - yes n/a n/a HDMI, additional dock [Page](https://linux-sunxi.org/Sipeed_Lichee_RV "https://linux-sunxi.org/Sipeed_Lichee_RV")

## Installing OpenWrt

Standard SD-card installation via dd-ing the generated image to an SD-card of at least 256Mb.

## Upgrading OpenWrt

→[generic.sysupgrade](/docs/guide-user/installation/generic.sysupgrade "docs:guide-user:installation:generic.sysupgrade")

sysupgrade works out of the box, using (at least) the ext4-sdcard.img.gz files.

### Pre-built release and snapshot images

[OpenWrt firmware downloads for d1](#folded_8951d28375b7dae2f5b373537ee6db84_1)

## Boot process

(Credits goes to the [https://linux-sunxi.org/Allwinner\_Nezha](https://linux-sunxi.org/Allwinner_Nezha "https://linux-sunxi.org/Allwinner_Nezha") page)

### U-Boot

Boot firmware on the D1 consists of three parts, which largely correspond to the components used by 64-bit ARM SoCs:

U-Boot SPL (Secondary Program Loader) which is responsible for initializing DRAM and loading further firmware from storage. OpenSBI, which runs in machine mode and provides a standard “SBI” interface to less privileged modes. This is similar to how TF-A runs in EL3 and provides PSCI on 64-bit ARM. U-Boot proper, which initializes additional hardware and loads Linux from storage or the network.

### OpenSBI

Mainline OpenSBI fully supports the C906 CPU and the Allwinner D1 SoC out of the box since version 1.1. You should use upstream OpenSBI, not any fork.

### Mainline U-Boot

Mainline U-Boot support is mostly complete, but is not merged yet. Booting Linux from the network, USB, and an SD card works. Some refactoring of the various sunxi device drivers is still needed before any RISC-V sunxi platforms can be upstreamed. Full U-Boot SPL support is available, so using the BSP boot0 or a TOC1 image is no longer necessary.
