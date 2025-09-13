# image/Makefile Details

**Work in Progress!**  
This page is a continuous work in progress. You can edit this page to contribute information.

- I think its(this page) needed to clarify the intent, preferred style and function of the image/Makefile.
- I believe one of the following should be placed here:
  
  - Adding a new platform (new buildroot howto section?)
  - OpenWrt Buildroot - new platform (new page/how-to on adding platform support to the buildroot system)

## image/Makefile from scratch or modify

Inside your platform directory you will need to create a file to tell the buildroot system how to process the results of a compiled kernel. Most of the work is done automatically by image.mk but different platforms and individual devices will need specific work for images to be useful.

## Basic Function

See example.

### Image/Prepare

Can be used to append data to image but often used simply to move to another directory such as $(KDIR)

Example:

```
cat $(LINUX_DIR)/arch/arm/boot/zImage >> $(KDIR)/$(call zimage_name,$(1))
```

### Image/Build/Initramfs

This section allows automated modification of the elf file before loading onto the device. The file can be found with this line

```
$(BIN_DIR)/$(IMG_PREFIX)-vmlinux.elf
```

### Image/Build/jffs2-64k

### Image/Build/jffs2-128k

### Image/Build/squashfs

### Image/Build

Appears to be used to call the other build defines (squashfs, jffs2-64k, jffs2-128k, etc) after they were processed and their resulting files were placed into $(TARGET\_DIR)

to call a define for each use:

```
$(call Image/Build/$(1),$(1))
```

## Example

Example of: **trunk/target/linux*/platform*/image/Makefile**

```
# 
# Copyright (C) 2010 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/image.mk
 
define Image/Prepare
 
endef
 
define Image/Build/Initramfs
	$(BIN_DIR)/$(IMG_PREFIX)-vmlinux.elf
endef
 
define Image/BuildKernel
 
endef
 
define Image/Build/jffs2-64k
	dd if=$(KDIR)/root.$(1) of=$(BIN_DIR)/openwrt-$(BOARD)-$(1).img bs=65536 conv=sync
endef
 
define Image/Build/jffs2-128k
	dd if=$(KDIR)/root.$(1) of=$(BIN_DIR)/openwrt-$(BOARD)-$(1).img bs=131072 conv=sync
endef
 
define Image/Build/squashfs
	$(call prepare_generic_squashfs,$(KDIR)/root.squashfs)
endef
 
define Image/Build
	$(call Image/Build/$(1),$(1))
endef
```

## See also

have a look at your copy of **trunk/include/image.mk**

# Platform/Device configuration files

## config-4.x

Kernel options required by the platform + kernel version.

```
CONFIG_QCOM_PM=y
CONFIG_QCOM_QFPROM=y
CONFIG_QCOM_RPMCC=y
```

## files-4.x

Kernel specific device source. Primarily the location of device DTS files. You will need to add a new device dts here and reference in image/Makefile under DEVICE\_DTS.

## patches-4.x

Kernel source additions. No changes for basic device additions.

## Makefile

Platform wide device definition and common package set. Generally does not require modification when adding additional platform devices.

```
include $(TOPDIR)/rules.mk
 
ARCH:=arm
BOARD:=ipq806x
BOARDNAME:=Qualcomm Atheros IPQ806X
FEATURES:=squashfs nand fpu ramdisk
CPU_TYPE:=cortex-a15
CPU_SUBTYPE:=neon-vfpv4
MAINTAINER:=John Crispin <john@phrozen.org>
 
KERNEL_PATCHVER:=4.14
 
KERNELNAME:=zImage Image dtbs
 
include $(INCLUDE_DIR)/target.mk
DEFAULT_PACKAGES += \
	kmod-leds-gpio kmod-gpio-button-hotplug swconfig \
	kmod-ata-core kmod-ata-ahci kmod-ata-ahci-platform \
	kmod-usb-core kmod-usb-ohci kmod-usb2 kmod-usb-ledtrig-usbport \
	kmod-usb3 kmod-usb-dwc3-of-simple kmod-usb-phy-qcom-dwc3 \
	kmod-ath10k-ct wpad-basic \
	uboot-envtools
 
$(eval $(call BuildTarget))
```

## image/Makefile

Device specific image creation parameters and image generation functions.

```
define Device/zyxel_nbg6817
	DEVICE_DTS := qcom-ipq8065-nbg6817
	KERNEL_SIZE := 4096k
	BLOCKSIZE := 64k
	BOARD_NAME := nbg6817
	RAS_BOARD := NBG6817
	RAS_ROOTFS_SIZE := 20934k
	RAS_VERSION := "V1.99(OWRT.9999)C0"
	SUPPORTED_DEVICES += nbg6817
	DEVICE_VENDOR := ZyXEL
	DEVICE_MODEL := NBG6817
	DEVICE_PACKAGES := ath10k-firmware-qca9984-ct e2fsprogs kmod-fs-ext4 losetup
	$(call Device/ZyXELImage)
endef
TARGET_DEVICES += zyxel_nbg6817
```

## base-files

Initialization scripts. Instantiation of LED, wifi and upgrade/install routines. etc. Many changes needed to add new device.

## profiles/00-default.mk

Board core firmware.
