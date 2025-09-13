## Upgrading to OpenWrt 21.02.0

*This page is a Work In Process. If you can contribute your knowledge, we would be pleased to have your help.*

OpenWrt 21.02.0 has [many important features](/releases/21.02/notes-21.02.0#highlights_in_openwrt_21020 "releases:21.02:notes-21.02.0") that make it worthwhile (or even important!) to upgrade to this new version. Before you upgrade, you should be aware of a number of criteria:

- OpenWrt 21.02.0 requires **8 MB Flash/64 MB RAM.** To see if your device can support 21.02.0, enter your device's brand/model in the table below and check the **Flash** and **RAM** columns.
- Direct sysupgrade from 18.06 (or earlier) to 21.02 is **not** supported. To upgrade, you should backup your configuration, install 21.02.0, and then manually re-create your configuration.
- *As always, make a backup of your configuration before proceeding.*
- If your router currently runs 19.07, in many cases, you can upgrade to 21.02.0 using either the LuCI web GUI (keeping configuration) or sysupgrade from the command line.
- However, there is no “keep-configuration” migration path from 19.07 to 21.02 for targets that [switched from swconfig to DSA.](/releases/21.02/notes-21.02.0#initial_dsa_support "releases:21.02:notes-21.02.0") The affected targets are: **ath79 (only TP-Link TL-WR941ND), bcm4908, gemini, kirkwood, mediatek (most boards), mvebu, octeon, ramips (mt7621 subtarget only)**, and **realtek**. Check the **Target** column in the table below. If your device is listed, check its **Device Page** (link in the table below) or [ask on the Forum.](https://forum.openwrt.org "https://forum.openwrt.org")
- Don't worry - If you try to upgrade with the wrong target, sysupgrade will refuse to proceed with an error message like this:  
  `Image version mismatch. image 1.1 device 1.0 Please wipe config during upgrade (force required) or reinstall. Config cannot be migrated from swconfig to DSA Image check failed`
- The default root file system partition size changed for targets/devices relying on booting from mass storage (HDD, USB flash, SD card, etc.), so MBR will change and any additional partition will be deleted when sysupgrading.
- If your device cannot be upgraded automatically, but it *will* support OpenWrt 21.02.0, you should backup your configuration, install manually, then re-create your configuration. As always if you have questions, [feel free to ask on the Forum.](https://forum.openwrt.org "https://forum.openwrt.org")

That's it! Good luck with OpenWrt 21.02.0!

### How can I get my device's specifications?

Enter your device's Brand or Model below to see its characteristics.
