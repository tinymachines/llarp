# FAQ after Installation of OpenWrt

![](/_media/meta/icons/tango/dialog-information.png) There is no preset password in OpenWrt!  
**You need to set a password at your [first login](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") per telnet or the WebUI.**

## General

### How do I ...?

→[docs](/docs/start "docs:start")

### How do I login?

→ follow [walkthrough\_login](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login")

### What version of OpenWrt do I have installed?

As you can see here [development](/about/development "about:development"), there are always two branches which are being actively worked on. OpenWrt trunk, which is bleeding edge, codename 'Designated Driver', and the [current stable](/downloads "downloads") release. Do

```
cat /etc/banner
```

to see the exact revision. Use that information for bug reports and questions in the forum. Also use it, to look up information yourself: [https://dev.openwrt.org/browser](https://dev.openwrt.org/browser "https://dev.openwrt.org/browser")

### I forgot my password!

→ [generic.debrick](/docs/guide-user/troubleshooting/generic.debrick "docs:guide-user:troubleshooting:generic.debrick")

### I have no WebUI

Install one, e.g. [LuCI](/docs/guide-user/luci/luci.essentials "docs:guide-user:luci:luci.essentials").

### How do I use the CLI (command-line interpreter)?

→ [user.beginner.cli](/docs/guide-user/base-system/user.beginner.cli "docs:guide-user:base-system:user.beginner.cli")

### How do I access the syslog messages?

Unless you installed some other log daemons, OpenWrt uses by default busybox-klogd and busybox-syslogd for logging. Both use the same circular buffer, which can be accessed with the command

```
logread
```

### How do I recover / boot in failsafe mode?

→[failsafe\_and\_factory\_reset](/docs/guide-user/troubleshooting/failsafe_and_factory_reset "docs:guide-user:troubleshooting:failsafe_and_factory_reset")

### I don't like LuCI

There are three [WebUI](/docs/guide-user/luci/webinterface.overview "docs:guide-user:luci:webinterface.overview")s available. All are FOSS, thus you can adapt each of them to your specific needs and likings.

* * *

## Installing packages

### How do I install ...

→ with `opkg`

### How do I uninstall ...

→ with `opkg`

### No space left on device

see also [OPKG troubleshooting: Out of space](/docs/guide-user/additional-software/opkg#out_of_space "docs:guide-user:additional-software:opkg")

#### How do I free up some space?

By removing packages you installed *after* flashing OpenWrt onto your Router. You cannot remove packages on the [SquashFS partition](/docs/techref/flash.layout "docs:techref:flash.layout"), which is included in the image you flashed.

#### Still not enough free space

This happens easily with recent firmware on 4MB Flash devices.  
You can press-fit an OpenWrt image into this small flash by building your own image, with only the packages you need, tailored for your usecase.

You can build your own image

- via [Image Generator](/docs/guide-user/additional-software/imagebuilder "docs:guide-user:additional-software:imagebuilder")
- via [custom build](/docs/guide-developer/toolchain/start "docs:guide-developer:toolchain:start")

#### I need many MB (GB) free space

- If you need even more space for package installation, you probably want [Extroot](/docs/guide-user/additional-software/extroot_configuration "docs:guide-user:additional-software:extroot_configuration").
- If you just want simple USB storage for e.g. pictures, video, music, see [usb-installing](/docs/guide-user/storage/usb-installing "docs:guide-user:storage:usb-installing") and [usb-drives](/docs/guide-user/storage/usb-drives "docs:guide-user:storage:usb-drives").

### Howto install opkg packages on a USB stick?

- →[opkg installation destinations](/docs/guide-user/additional-software/opkg#non-standard_installation_destinations "docs:guide-user:additional-software:opkg")
- →[/etc/config/fstab](/docs/guide-user/storage/fstab "docs:guide-user:storage:fstab") or →[usb-drives](/docs/guide-user/storage/usb-drives "docs:guide-user:storage:usb-drives")

### Where should I send bug reports?

Please send reproducible bugs to our [ticket system](http://dev.openwrt.org/report "http://dev.openwrt.org/report").

### Is package ... available?

**You can check yourself:**

1. [Package table](/packages/table/start "packages:table:start")
2. The OpenWrt repositories are brows-able by web browser.  
   Examples **for ar71xx** (replace ar71xx with the target fitting to your device):
   
   - 17.01.4 packages → [http://downloads.openwrt.org/releases/17.01.4/targets/ar71xx/generic/packages/](http://downloads.openwrt.org/releases/17.01.4/targets/ar71xx/generic/packages/ "http://downloads.openwrt.org/releases/17.01.4/targets/ar71xx/generic/packages/")
   - snapshot packages → [http://downloads.openwrt.org/snapshots/targets/ar71xx/generic/packages/](http://downloads.openwrt.org/snapshots/targets/ar71xx/generic/packages/ "http://downloads.openwrt.org/snapshots/targets/ar71xx/generic/packages/")

### Why isn't package ... available?

Possible reasons:

- it makes no sense to have this software in the repositories, because it is too bloated/not suited for embedded environments
- nobody has thought on packaging this software for OpenWrt yet

Possible solutions:

- create the package yourself: [Creating a package](/docs/guide-developer/packages "docs:guide-developer:packages")
- do nothing and wait until package becomes available

### Cannot satisfy dependencies

You will get the message *“Cannot satisfy the following dependencies for...”* if you are trying to install packages intended for a trunk build of OpenWrt on a different (older) version, i.e. the package in the trunk repository is for a newer kernel version than the kernel version on your flash.

- As general advice, especially for inexperienced users: Go for the latest [*stable release*](/about/history "about:history") version, not a trunk version, and the package repositories will match.
- Try to install via opkg with option `--force-depends` (=Install/remove despite failed dependencies). Mind that this is likely to fail for kernel related packages (kmods).
- [Make local copy of trunk packages](/docs/guide-user/advanced/snippets#make_local_copy_of_packages "docs:guide-user:advanced:snippets") (not recommended, needs much space!)

### opkg\_configure: &lt;packagename&gt;.postinst returned 127

**Root cause:** ??? *See [OpenWrt forum](https://forum.openwrt.org/ "https://forum.openwrt.org/") and add the root cause here --- tmomas 2015/12/23 21:10*

**Solution:** ??? *See [OpenWrt forum](https://forum.openwrt.org/ "https://forum.openwrt.org/") and add the solution here --- tmomas 2015/12/23 21:10*

* * *

## Network

### Howto connect behind another router?

This scenario: [https://forum.openwrt.org/viewtopic.php?pid=204297#p204297](https://forum.openwrt.org/viewtopic.php?pid=204297#p204297 "https://forum.openwrt.org/viewtopic.php?pid=204297#p204297") has three solutions:

- [https://forum.openwrt.org/viewtopic.php?pid=204332#p204332](https://forum.openwrt.org/viewtopic.php?pid=204332#p204332 "https://forum.openwrt.org/viewtopic.php?pid=204332#p204332")
- maybe see [dumbap](/docs/guide-user/network/wifi/dumbap "docs:guide-user:network:wifi:dumbap")

### Howto avoid double NATing?

see above: Howto connect behind another router?

### iptables does not work as intended

That be because the firewall-package comes with a configuration already. Certain user chains are created, and packets put into them. When you then later try to catch packets in the `INPUT` chain, there won't be any, because they are being put into user chains (maybe something like `wan_input`, `lan_input`) before that.

Anytime you can type

```
iptables -L 
```

to see how things are currently setup, but best thing is, to always know your own setup.

### How to view dhcp leases from shell ?

```
cat /tmp/dhcp.leases
```

### I trashed my /etc/config/firewall file, how to reset?

```
 cp -f /rom/etc/config/firewall /etc/config/firewall
/etc/init.d/firewall restart
```

### How can I filter traffic based on FQDN?

- netfilter
- HTTP proxy server
- ipset-dns

### No ping to external servers

### Internet not reachable

Something is wrong with your network configuration. Check Netmask, Gateway, DNS settings. → [https://wiki.openwrt.org/doc/howto/internet.connection](https://wiki.openwrt.org/doc/howto/internet.connection "https://wiki.openwrt.org/doc/howto/internet.connection")

* * *

## Other questions

### How do I have it do something every YYY seconds/minutes?

Like on any Linux system, you can use `crond`. Please consult `/etc/crontabs/root`

### How do I create a cronjob to reboot?

- `Busybox-crond` does not support the *@reboot* directive. The next best place to put @reboot jobs is `/etc/rc.local`
- [https://forum.openwrt.org/viewtopic.php?id=45274](https://forum.openwrt.org/viewtopic.php?id=45274 "https://forum.openwrt.org/viewtopic.php?id=45274")

### How do I turn USB power off?

See [Turning USB power on and off](/docs/guide-user/hardware/usb.overview#turning_usb_power_on_and_off "docs:guide-user:hardware:usb.overview").
