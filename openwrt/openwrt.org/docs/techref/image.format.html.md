# Image formats

You can help to improve this page by adding explanations for the different firmware types below.

If you are confused by the many different firmware types and extensions in the [OpenWrt firmware downloads](/toh/views/toh_fwdownload "toh:views:toh_fwdownload") table, this pages tries to explain a bit about this topic.

## Standard formats

### factory (.img/.bin)

Use when flashing from OEM ( non-openwrt ) [1)](#fn__1)

If only a sysupgrade image is available for your router, either the router is already running some kind of OpenWrt fork (which understands the sysupgrade format natively) or web flash via the OEM UI is not possible... Please consult the Table of Hardware for your device for installation instructions from OEM firmware.

### sysupgrade ( or trx )

Previously known as *trx image*, *sysupgrade* is designed to be flashed from OpenWrt/LEDE itself [2)](#fn__2). Commonly used when upgrading.

## Specific formats

### ext4

This firmware contains a regular ext4 Linux partition. Mostly used in x86 and x86\_x64 systems.

### squashfs

This firmware contains a type of partition that is compressed and mounts read-only. All modifications (file edit, new files, deleted files) are committed to an overlay. .bin/.chk/.trx

- See also [TRX vs. TRX2 vs. BIN](/docs/techref/headers "docs:techref:headers")

### initramfs

Can be loaded from an arbitrary location ( most often tftp ) and is self-contained in memory. This is like a Linux LiveCD. Often used to test firmware, as the first part of a multi-stage installation or as a recovery tool. [3)](#fn__3)

An initramfs and initrd are basically the same. It’s a filesystem in memory, which contains userland software. In an embedded environment it might contain the whole distro, on bigger systems it can contain tools&amp;scripts to assemble&amp;mount raid arrays and stuff like that before passing userland boot to them. Both can have a uHeader, to let uBoot know what it is.

The initramfs-kernel image is used for development or special situations as a one-time boot as a stepping stone toward installing the regular sysupgrade version. Since the initramfs version runs entirely from RAM, it does not store any settings in flash, so it is not suitable for operational use.

initramfs-uImage.bin: initramfs-kernel.bin:

### sdcard.img.gz

Used by few devices ( mvebu/RPi etc. ), most often a multi partition image which is uncompressed and written to external storage via PC.

### rootfs

Only the root filesystem.

### kernel

Linux core, generally without compression or appended headers.

### ubifs

??

### ubi

??

### tftp

Designed to be loaded from tftp server. Device in recovery mode?

### u-boot

This is an image format designed for U-Boot loader. Same as initramfs-or-uImage?

### ubinized.bin

### uImage

This is an image format designed for U-Boot loader, generally consisting of a kernel with a header for information. Often a zImage with a 64 byte uImage header, which contains the load address &amp; entry point of the zImage, so that uBoot knows what to do with it. Further is contains a description of the actual contents (linux kernel, version, …)

### zImage

zImage is a compressed plain kernel with a ‘pyggyback’. Some extra code which can decompress the kernel before booting it.

## Subformats

### bin, img, elf, dtb, chk, dlf

These are raw binary data of the firmware file

### xz, gz, tar, lzma

These are compressed images

## Developer files

### sdk

SDK Toolchain for compiling single userspace packages [4)](#fn__4)

### Imagebuilder

To build custom images without compiling [5)](#fn__5)

### vmlinux

Linux kernel for build [6)](#fn__6)

# Example Firmware image names

## Firmware types

Target Install Upgrade adm5120 squashfs.bin squashfs.bin apm821xx squashfs-factory.img  
initramfs-kernel.bin squashfs-sysupgrade.tar  
ext4-rootfs.img.gz ar7 squashfs.bin  
squashfs-code.bin squashfs.bin ar71xx factory.img  
factory.bin sysupgrade.bin at91 atheros squashfs-factory.bin squashfs-sysupgrade.tar brcm2708 ext4-sdcard.img.gz - brcm47xx squashfs.bin  
squashfs.chk  
squashfs.trx squashfs.bin  
squashfs.chk  
squashfs.trx bcm53xx squashfs.bin  
squashfs.chk  
squashfs.trx  
squashfs.chk  
squashfs.trx brcm63xx squashfs-cfe.bin  
squashfs-factory.chk squashfs-sysupgrade.bin cns3xxx - sysupgrade.bin imx6 ? ? ipq806x factory.img sysupgrade.tar ixp4xx squashfs.bin  
squashfs.img  
zImage squashfs-sysupgrade.bin kirkwood squashfs-factory.bin squashfs-sysupgrade.bin lantiq initramfs-kernel.bin  
squashfs-factory.bin squashfs-sysupgrade.bin layerscape squashfs-firmware.bin - mpc85xx squashfs-factory.bin squashfs-sysupgrade.bin mvebu sdcard.img.gz  
squashfs-factory.img  
squashfs-sysupgrade.bin mxs ? ? orion not supported not supported oxnas squashfs-ubinized.bin  
ubifs-ubinized.bin squashfs-sysupgrade.tar  
ubifs-sysupgrade.tar ramips initramfs-kernel.bin  
squashfs-factory.bin  
squashfs-factory.dlf  
initramfs-uImage.bin squashfs-sysupgrade.bin  
squashfs-sysupgrade.tar sunxi ext4-sdcard.img.gz  
squashfs-sdcard.img.gz x86 combined-ext4.img combined-ext4.img.gz

# Image Formats General

This article describes and links to the various factory firmware image formats found.

For OpenWrt Flash Layout see: [flash.layout](/docs/techref/flash.layout "docs:techref:flash.layout").

[Binwalk](https://github.com/ReFirmLabs/binwalk "https://github.com/ReFirmLabs/binwalk") can help to analyze unknown formats.

## Known Formats

by extension:

- BIN
- CHK
- DLF
- IMG
- TRX

## Other Formats

- see [brcm63xx.imagetag](/docs/techref/brcm63xx.imagetag "docs:techref:brcm63xx.imagetag")
- see [headers](/docs/techref/headers "docs:techref:headers")

[1)](#fnt__1) , [2)](#fnt__2)

[before.installation](/docs/guide-user/installation/before.installation "docs:guide-user:installation:before.installation")

[3)](#fnt__3)

[https://forum.lede-project.org/t/toward-a-good-flashing-lede-instructions-page/52/5](https://forum.lede-project.org/t/toward-a-good-flashing-lede-instructions-page/52/5 "https://forum.lede-project.org/t/toward-a-good-flashing-lede-instructions-page/52/5")

[4)](#fnt__4) , [5)](#fnt__5) , [6)](#fnt__6)

[https://we.riseup.net/lackof/openwrt-on-x86-64](https://we.riseup.net/lackof/openwrt-on-x86-64 "https://we.riseup.net/lackof/openwrt-on-x86-64")
