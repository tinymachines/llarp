# Saving firmware space and RAM

## Excluding packages

Flash space is scarce on devices with only 4MB flash. You can save some space while compiling your own image (e.g. with the [imagebuilder](/docs/guide-user/additional-software/imagebuilder "docs:guide-user:additional-software:imagebuilder")) by removing packages that are not needed for your usecase. In order to completely remove IPv6 support and related packages you also need to ask the imagebuilder to do so by also passing this option to the make command: `CONFIG_IPV6=n`.

Action Packages Menu path remove pppoe `-ppp -ppp-mod-pppoe` Network remove IPv6 `-ip6tables -odhcp6c -kmod-ipv6 -kmod-ip6tables -odhcpd-ipv6only` Global build settings / Enable IPv6 support in packages remove dhcp server `-odhcpd` Network remove iptables `-iptables` Network / Firewall remove opkg `-opkg` Base system add LuCI minimal `uhttpd uhttpd-mod-ubus` Network / Web Servers/Proxies `libiwinfo-lua` Languages / Lua `luci-base luci-app-firewall luci-mod-admin-full luci-theme-bootstrap` LuCI add zram `zram-swap` Base system

![:!:](/lib/images/smileys/exclaim.svg) Do not use zram-swap for 4MB flash devices as it *increases* the amount of firmware space used. It is listed here as it is helpful on machines with very little RAM memory.

![:?:](/lib/images/smileys/question.svg) The minus `-PACKAGE_NAME` prefix removes a package, no prefix adds one.

### Build image for devices with only 4MB flash

**Example image builder command line**

**Note:** In the command line shown below, you need to adjust `PROFILE=tl-wr941nd-v6` to your device. Use `make info` to list possibilities.

LuCI Action Imagebuilder commandline with LuCI - remove pppoe and IPv6  
\+ include only needed luci components, not full luci package. `make image PROFILE=tl-wr941nd-v6 \ PACKAGES=“uhttpd uhttpd-mod-ubus libiwinfo-lua luci-base \ luci-app-firewall luci-mod-admin-full luci-theme-bootstrap \ -ppp -ppp-mod-pppoe -ip6tables -odhcp6c \ -kmod-ipv6 -kmod-ip6tables -odhcpd-ipv6only”` without LuCI - remove pppoe and IPv6 `make image PROFILE=tl-wr941nd-v6 \ PACKAGES=“-ppp -ppp-mod-pppoe -ip6tables -odhcp6c \ -kmod-ipv6 -kmod-ip6tables -odhcpd-ipv6only”`

Resources:

- [https://forum.openwrt.org/t/can-i-strip-the-ipv6-out-with-the-imagebuilder/3465/5](https://forum.openwrt.org/t/can-i-strip-the-ipv6-out-with-the-imagebuilder/3465/5 "https://forum.openwrt.org/t/can-i-strip-the-ipv6-out-with-the-imagebuilder/3465/5")
- [https://forum.openwrt.org/t/build-lede-without-ipv6/2043](https://forum.openwrt.org/t/build-lede-without-ipv6/2043 "https://forum.openwrt.org/t/build-lede-without-ipv6/2043")
- [https://forum.openwrt.org/t/make-image-problem/898](https://forum.openwrt.org/t/make-image-problem/898 "https://forum.openwrt.org/t/make-image-problem/898")
- [https://forum.openwrt.org/t/tp-link-tl-mr-3420-v3-build/855/8](https://forum.openwrt.org/t/tp-link-tl-mr-3420-v3-build/855/8 "https://forum.openwrt.org/t/tp-link-tl-mr-3420-v3-build/855/8")
- [https://forum.openwrt.org/t/possible-ppp-removal-from-base-image/42024/3](https://forum.openwrt.org/t/possible-ppp-removal-from-base-image/42024/3 "https://forum.openwrt.org/t/possible-ppp-removal-from-base-image/42024/3")
- Talk [Fight for the bytes! Fun with Four Megabytes Flash](https://youtu.be/M3yUjHKvde8?t=846 "https://youtu.be/M3yUjHKvde8?t=846")

### Build image for devices with only 16/32MB RAM

If the device has 16MB or less of RAM, then it should only be used as Internal AP (e.g. to extend Wi-Fi coverage).

**Example image builder command line**

**Note:** In the command line shown below, you need to adjust `PROFILE=tl-wr941nd-v6` to your device. Use `make info` to list possibilities.

RAM Action Imagebuilder commandline 16MB - remove pppoe and IPv6  
\- remove all related elements to iptables  
\- remove dhcp servers  
\+ add LUCI  
\+ add zram-swap  
\- remove opkg - not needed after making these adjustments `make image PROFILE=tl-wr941nd-v6 \ PACKAGES=“uhttpd uhttpd-mod-ubus libiwinfo-lua \ luci-base luci-app-firewall luci-mod-admin-full \ luci-theme-bootstrap zram-swap \ -ppp -ppp-mod-pppoe -iptables -ip6tables -odhcp6c -kmod-ipv6 \ -kmod-ip6tables -odhcpd-ipv6only -odhcpd -opkg”` 32MB - remove pppoe and IPv6  
\+ add LUCI  
\+ add zram-swap  
\- remove opkg - not needed after making these adjustments `make image PROFILE=tl-wr941nd-v6 \ PACKAGES=“uhttpd uhttpd-mod-ubus libiwinfo-lua luci-base \ luci-app-firewall luci-mod-admin-full luci-theme-bootstrap zram-swap \ -ppp -ppp-mod-pppoe -ip6tables -odhcp6c -kmod-ipv6 \ -kmod-ip6tables -odhcpd-ipv6only -opkg”`

Resources:

- [https://forum.openwrt.org/t/zram-configuration/3560](https://forum.openwrt.org/t/zram-configuration/3560 "https://forum.openwrt.org/t/zram-configuration/3560")
- [https://forum.openwrt.org/t/best-practices-for-32-mb-ram/5050](https://forum.openwrt.org/t/best-practices-for-32-mb-ram/5050 "https://forum.openwrt.org/t/best-practices-for-32-mb-ram/5050")
- [https://forum.openwrt.org/t/luci-slow-down-to-death-wr1043n-v1/1992](https://forum.openwrt.org/t/luci-slow-down-to-death-wr1043n-v1/1992 "https://forum.openwrt.org/t/luci-slow-down-to-death-wr1043n-v1/1992")

## Making all kernel modules built-in

This option compiles the kernel modules inside the kernel, you can either pick what modules you think can be integrated and make them built-in by pressing “y” on them when in the menuconfig, or do a quick-and-dirty change of the kernel config with (adjust the path in this example to point to your target's actual kernel config)

```
sed -i -e "s/=m/=y/g" build_dir/target-mipsel_24kc_musl/linux-ramips_mt7620/linux-4.14.63/.config
```

This will work only if your device's kernel partition is big enough to accomodate the slightly larger kernel, or if the device is using dynamic partitions.

This was reported by Daniel Santos in an [email to the OpenWrt developer mailing list](https://lists.infradead.org/pipermail/openwrt-devel/2018-October/014459.html "https://lists.infradead.org/pipermail/openwrt-devel/2018-October/014459.html"), 30 Oct 2018.

His comments:

*I did a quick experiment of this and **instead of saving 4k, my \*image* is a full 256k smaller**. I haven't analysed the specifics, but also this means less RAM consumed because squashfs uses the page cache for uncompressed files. Further, modules inherently have greater overhead, even after \_\_init sections have been discarded. The only downside is that built-ins cannot be unloaded and will always occupy a portion of RAM. But having them built into the kernel is far more efficient.*

(The “surprising” change in image size may be due to the block size of the squashfs image. See, for example `include/image-commands.mk` and `include/image.mk` in November, 2018 sources)

In a follow up mail by Phillip Prindeville pointed out the main drawback of this method.

*Some hardware (it’s rare but not unheard of) can only be reset by unloading and reloading the module that controls it. Otherwise, you have to reboot the box. If you build all of your drivers in, then rebooting is all you have.*

## Modifying build configuration variables

You can also save space by changing configuration variables using `make menuconfig`. In addition to the ones mentioned here you can save a tiny bit of space by disabling commands in busybox.

### Saving space

Config variable  
(`n` = disable, `y` = enable) Menu path Comments `CONFIG_KERNEL_PRINTK=n` Global build settings / Kernel build options / Enable support for printk `CONFIG_KERNEL_CRASHLOG=n` Global build settings / Kernel build options / Crash logging `CONFIG_KERNEL_SWAP=n` Global build settings / Kernel build options / Support for paging of anonymous memory (swap) `CONFIG_KERNEL_KALLSYMS=n` Global build settings / Kernel build options / Compile the kernel with symbol table information `CONFIG_KERNEL_DEBUG_INFO=n` Global build settings / Kernel build options / Compile the kernel with debug information `CONFIG_KERNEL_ELF_CORE=n` Global build settings / Kernel build options / Enable process core dump support `CONFIG_IPV6=n` Global build settings / Enable IPv6 support in packages `CONFIG_KERNEL_MAGIC_SYSRQ=n` Global build settings / Kernel build options / Compile the kernel with SysRq support `CONFIG_KERNEL_PRINTK_TIME=n` Global build settings / Kernel build options / Enable printk timestamps `CONFIG_PACKAGE_MAC80211_DEBUGFS=n` Kernel modules / Wireless Drivers / kmod-mac80211 / Export mac80211 internals in DebugFS Estimated savings: 21 KB `CONFIG_PACKAGE_MAC80211_MESH=n` Kernel modules / Wireless Drivers / kmod-mac80211 / Enable 802.11s mesh support Estimated savings: 29 KB `CONFIG_STRIP_KERNEL_EXPORTS=y` Global build settings / Strip unnecessary exports from the kernel image `CONFIG_USE_MKLIBS=y` Global build settings / Strip unnecessary functions from libraries `CONFIG_SERIAL_8250=n` Device Drivers / Character devices / Serial drivers / 8250/16550 and compatible serial support This will also save RAM by preventing /sbin/askfirst from running. However, this will break sysupgrade. This menu is available only via `make kernel_menuconfig` `CONFIG_EARLY_PRINTK=n` Kernel hacking / Early printk This menu is available only via `make kernel_menuconfig` `KERNEL_SQUASHFS_FRAGMENT_CACHE_SIZE` ![:!:](/lib/images/smileys/exclaim.svg) Global build settings / Kernel build options / Number of squashfs fragments cached Reduce the number of cached blocks. This menu is available only via `make kernel_menuconfig` `TARGET_SQUASHFS_BLOCK_SIZE` ![:!:](/lib/images/smileys/exclaim.svg) Target Images / squashfs / Block size Increase block size from the default 256 KB to improve compression

![:!:](/lib/images/smileys/exclaim.svg) Block size must be a power of 2, between 4096 bytes and 1 Megabyte. By default, 3 blocks will be cached so this will also make the router use more RAM (if 3 blocks are cached, and a block size of 1024 KB is used, this will use 2,304 KB more RAM (3 * 1024 KB - 3 * 256 KB)). It may also make the router use more CPU to decompress the larger blocks.

![:!:](/lib/images/smileys/exclaim.svg) To **build a kernel that only works with a specific device**, run `make kernel_menuconfig CONFIG_TARGET=subtarget` to edit `target/linux/<platform>/*/config-default` and go to `Machine selection / <Platform> machine selection` and disable all devices except for the specific device. [This can save some disk space and RAM](https://forum.openwrt.org/t/building-a-smaller-kernel-for-a-specific-device/30370/8 "https://forum.openwrt.org/t/building-a-smaller-kernel-for-a-specific-device/30370/8").

### Saving RAM

Config variable  
(`n` = disable, `y` = enable) Menu path `CONFIG_PACKAGE_zram-swap=y` Base system / zram-swap `CONFIG_PROCD_ZRAM_TMPFS=y` Base system / procd Configuration / Mount */tmp* using zram `CONFIG_KERNEL_SWAP=y` Global build settings / Kernel build options / Support for paging of anonymous memory (swap)

## Replace LuCI icons with a blank pixel

The icons in LuCI are not strictly necessary and replacing them with a blank image will save about 15 KB. This bash script will take an OpenWrt git path as parameter and replace the images with a blank using the [files](/docs/guide-developer/toolchain/use-buildsystem#custom_files "docs:guide-developer:toolchain:use-buildsystem") path:

Click to display ⇲

Click to hide ⇱

```
#!/bin/sh
if [ -z "$1" ]; then echo Need git path as parameter; exit 1; fi
cd "$1" || exit 1
gitpath=`pwd`
echo Installing to $gitpath
mkdir -p files/www/luci-static/resources/icons/
mkdir -p files/www/luci-static/resources/cbi/
wget -O files/www/luci-static/resources/cbi/blank.gif 'https://raw.githubusercontent.com/mathiasbynens/small/master/gif-transparent.gif'
wget -O files/www/luci-static/resources/cbi/blank.png 'https://raw.githubusercontent.com/mathiasbynens/small/master/png-transparent.png'
cd feeds/luci/modules/luci-base/htdocs/luci-static/resources/cbi
for a in *.gif; do ln -s blank.gif "$gitpath"/files/www/luci-static/resources/cbi/$a; done
cd ../icons
for a in *.gif; do ln -s ../cbi/blank.gif "$gitpath"/files/www/luci-static/resources/icons/$a; done
for a in *.png; do ln -s ../cbi/blank.png "$gitpath"/files/www/luci-static/resources/icons/$a; done
```

# External links

- [https://wiki.yoctoproject.org/wiki/Minimal\_Image](https://wiki.yoctoproject.org/wiki/Minimal_Image "https://wiki.yoctoproject.org/wiki/Minimal_Image")
- [https://wiki.yoctoproject.org/wiki/Linux\_kernel/Image\_Size](https://wiki.yoctoproject.org/wiki/Linux_kernel/Image_Size "https://wiki.yoctoproject.org/wiki/Linux_kernel/Image_Size")
- [https://elinux.org/System\_Size](https://elinux.org/System_Size "https://elinux.org/System_Size")
- [https://elinux.org/Runtime\_Memory\_Measurement](https://elinux.org/Runtime_Memory_Measurement "https://elinux.org/Runtime_Memory_Measurement")
- [https://tiny.wiki.kernel.org/](https://tiny.wiki.kernel.org/ "https://tiny.wiki.kernel.org/")
- [https://github.com/yurt-page/docs](https://github.com/yurt-page/docs "https://github.com/yurt-page/docs")
