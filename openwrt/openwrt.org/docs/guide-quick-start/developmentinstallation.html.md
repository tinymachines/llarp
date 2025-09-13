# Installing OpenWrt development snapshots

**For experienced users only!** The steps below install OpenWrt development snapshot firmware on your device.

The development branch can contain experimental code that is under active development and should not be used for production environments. [Snapshot](/releases/snapshot "releases:snapshot") images may support additional hardware; however, it is experimental, considered unstable, and sometimes won't compile.

**Prebuilt [snapshot](/releases/snapshot "releases:snapshot") images do not come with any web interface or GUI**. You will need to be comfortable using a command line and remote shell to install one yourself → [How to install LuCI](/docs/guide-user/luci/luci.essentials "docs:guide-user:luci:luci.essentials")

## What is a development snapshot firmware?

Development snapshots aka “snapshots” are versions of OpenWrt that are “in development”. They are rebuilt frequently, often daily.

See also [Development builds / snapshots](/releases/snapshot "releases:snapshot")

## I am a standard consumer, do I want a development snapshot firmware?

**No!**  
Although they are the latest version, there is no guarantee that any particular snapshot build will be bug-free, or even work at all. Snapshots are not always stable enough to be used on your home router, where you or members of your family rely on the network. As a standard consumer stick to the stable release versions of OpenWrt.

See also [Development builds / snapshots](/releases/snapshot "releases:snapshot")

## Snapshots do not include the LuCI web interface by default

On snapshots, LuCI has to be installed if desired.

To install LuCI, follow the [LuCI installation](/docs/guide-user/luci/luci.essentials "docs:guide-user:luci:luci.essentials") guide but using APK.

## Installing a OpenWrt Snapshot

To install (or “flash”) an OpenWrt snapshot firmware image, just follow the standard flashing instructions: [Factory install](/docs/guide-quick-start/factory_installation "docs:guide-quick-start:factory_installation") and [Sysupgrade](/docs/guide-quick-start/sysupgrade.luci "docs:guide-quick-start:sysupgrade.luci"). You can also find and create custom builds with [Firmware Selector](https://firmware-selector.openwrt.org/ "https://firmware-selector.openwrt.org/").

## Optional next steps

Once the snapshot is installed on your device:

- Consult the [User Guide](/docs/guide-user/start "docs:guide-user:start").
- Consult with your device page for configuration tips.
- Install packages with [APK](/docs/guide-user/additional-software/opkg-to-apk-cheatsheet "docs:guide-user:additional-software:opkg-to-apk-cheatsheet") using `apk --update-cache add`. Popular packages include: luci, luci-ssl, luci-app-sqm, luci-app-attendedsysupgrade, luci-app-irqbalance, luci-app-adblock, luci-app-ksmbd, luci-app-hd-idle, owut, netperf, htop, nano, etc. There are LuCI themes available as well.
- If you have an unbranded router that came with OpenWrt / LEDE, you can find out its architecture via SSH and opening `/proc/cpuinfo`. A combination of the `system type` and `machine` is what you are looking for.
- If you will be flashing OpenWrt firmware snapshots frequently, you can create a script that makes configuration changes in a reliable and repeatable fashion. See, for example, the [config-openwrt.sh](https://github.com/richb-hanover/OpenWrtScripts/blob/master/config-openwrt.sh "https://github.com/richb-hanover/OpenWrtScripts/blob/master/config-openwrt.sh") script that updates most settings.
