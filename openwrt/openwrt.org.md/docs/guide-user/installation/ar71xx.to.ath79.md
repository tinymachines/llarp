# Upgrade from (old) ar71xx to ath79

Starting with [OpenWrt 19.07](/releases/19.07/start "releases:19.07:start"), there is a new device-tree-based target called [ath79](/docs/techref/targets/ath79 "docs:techref:targets:ath79") that deprecates the [ar71xx](/docs/techref/targets/ar71xx "docs:techref:targets:ar71xx") target. For 19.07, both targets are still built, but future releases of OpenWrt will drop support for the [ar71xx](/docs/techref/targets/ar71xx "docs:techref:targets:ar71xx") target.

Upgrading from [ar71xx](/docs/techref/targets/ar71xx "docs:techref:targets:ar71xx") to [ath79](/docs/techref/targets/ath79 "docs:techref:targets:ath79") is not always straightforward and depends on devices. This page lists instructions and pitfalls to upgrade a device as safely as possible.

## Step 1: check support for your device

Approximately 50% of ar71xx devices have been ported to ath79 in 19.07. Check if your model is in the [ath79 device status](/docs/techref/targets/ath79 "docs:techref:targets:ath79") page. You can also have a look at the [ar71xx-ath79 device status](/docs/techref/targets/ar71xx-ath79 "docs:techref:targets:ar71xx-ath79") page.

Lastly, you can directly check the [download page for ath79](https://downloads.openwrt.org/releases/19.07.0/targets/ath79/ "https://downloads.openwrt.org/releases/19.07.0/targets/ath79/") (but be aware: images for some devices are **not** built for releases, because of issues with limited flash size)

**If your device is not yet supported in ath79:** somebody will need to add support for this device, and it could be **you**! See [ath79](/docs/techref/targets/ath79 "docs:techref:targets:ath79"), [add.new.device](/docs/guide-developer/add.new.device "docs:guide-developer:add.new.device"), [adding\_new\_device](/docs/guide-developer/adding_new_device "docs:guide-developer:adding_new_device") and [submitting-patches](/submitting-patches "submitting-patches") for guidance.

## Step 2: backup your configuration

You absolutely need to **backup your configuration** before making any change, unless you are fine starting with a default OpenWrt configuration from scratch.

See [backup and restore](/docs/guide-user/troubleshooting/backup_restore "docs:guide-user:troubleshooting:backup_restore") documentation.

## Step 3: download sysupgrade image

Download the ath79 sysupgrade image of 19.07 for your device, and copy it to `/tmp/` on your router if necessary.

Make **really sure** that you download the right image for your device!

## Step 4: upgrade your system with sysupgrade

Flash the sysupgrade image **without keeping settings**. You can either use the [LuCI web interface](/docs/guide-quick-start/sysupgrade.luci "docs:guide-quick-start:sysupgrade.luci") or the [command-line interface](/docs/guide-user/installation/sysupgrade.cli "docs:guide-user:installation:sysupgrade.cli"):

- for LuCI: **uncheck “Keep settings and retain the current configuration”**
- for command-line sysupgrade: **use `sysupgrade -n <your-device-19.07-image-sysupgrade.bin>`**

At that point, there is little risk for your device: if the image is accepted, the upgrade will likely work as expected. Once the upgrade succeeded the device should be available on openwrt's default ip-address.

If the image check fails, **don't force upgrade** and continue reading below.

### If your device is not supported by the image

You may encounter the error “Device not supported by this image” or “Image check failed”. In that case:

1. first, check again that you selected the right image
2. if so, please [report the issue](/bugs "bugs") so that it can be fixed for the next 19.07.X minor release. In your bug report, make sure to give details about your device, which exact ar71xx image you were using, and which exact ath79 image you tried to flash.
3. go to section [Flashing from bootloader / TFTP / serial](#flashing_from_bootloadertftpserial "docs:guide-user:installation:ar71xx.to.ath79 ↵") or [Forcing sysupgrade (dangerous!)](#forcing_sysupgrade_dangerous "docs:guide-user:installation:ar71xx.to.ath79 ↵") below

## Step 5: check that the upgrade ran successfully

Because settings were not saved in the upgrade the device is now on openwrt's default ip address. Check basic functionality after rebooting: connect to device with HTTP or SSH, connect the WAN port to the Internet, enable Wi-Fi, etc.

**If your device stays unresponsive several minutes after upgrading:** [report the issue](/bugs "bugs") and go to section “Flashing from bootloader / TFTP / serial”.

## Step 6: import your configuration

First, check that [generic failsafe](/docs/guide-user/troubleshooting/failsafe_and_factory_reset "docs:guide-user:troubleshooting:failsafe_and_factory_reset") works so that you can always fix configs if anything goes wrong.

Then you can import your configuration:

1. If your configuration is simple enough, redo it manually and you're done upgrading, else follow the next steps;
2. Manually compare configs you backed up to the ones generated by an ath79 image on first boot. Pay specific attention to **device path** in `wireless`, **interface names** in `network` and **LEDs** in `system`;
3. If deemed reasonable, prepare new configs taking the comparison results into account and try restoring using them;
4. In case you have any specific issues, [report bugs](/bugs "bugs").

Congratulations, your upgrade was successful!

## Alternative methods

### Flashing from bootloader / TFTP / serial

You can use support from the bootloader to flash the new image. Find your device page from [Table of Hardware](/toh/start "toh:start") and proceed with whatever device-specific flashing methods are available.

### Forcing sysupgrade (dangerous!)

Forcing the upgrade will allow you to upgrade with an image that is not matching your device: **do this at your own risk!**

If you decide to do it anyway, make **really really sure** again that you downloaded the right image for your device!

- for LuCI: **check “Force upgrade”**
- for command-line sysupgrade: **use `sysupgrade -F -n <your-device-19.07-image-sysupgrade.bin>`**

**If the device is unresponsive several minutes after upgrade:** you were warned! Your last resort is “Flashing from bootloader / TFTP / serial”.

## Incompatible changes

Potential incompatible changes between ar71xx and ath79:

- Wi-Fi device paths in `/etc/config/wireless`
- network interface names and switch configuration in `/etc/config/network`
- LEDs in `/etc/config/system`

## Devices with known config changes (without migration available)

Devices listed here will have config changes that are not treated by any migration scripts, so using sysupgrade without “-n” option will definitely lead to a configuration not matching the rest any more. So, be sure to stick to the guide above for these devices in particular.

### eth1/eth0 swap

- AVM FritzBox4020
- TP-Link Archer C25 v1, C58 v1, C59 v1/v2, C60 v1/v2
- TP-Link TL-WR841N/ND v8 (not for v7 and v9 to v12)
- ...

### switch configuration change

- TP-Link TL-WR741N/ND v4
