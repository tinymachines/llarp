# Image Builder frontends

This page lists software based on [Image Builder](/docs/guide-user/additional-software/imagebuilder "docs:guide-user:additional-software:imagebuilder") whose goal is to automate or make it easier to generate OpenWrt images.

For one-shot OpenWrt image generation or light customization, it is probably still best to directly use the Image Builder.

### OpenWrt Firmware Selector

Modern Javascript interface that allows to locate and download an OpenWrt image. Note this implementation is not an image builder frontend and is simply and official image locator tool.

- [https://firmware-selector.openwrt.org/](https://firmware-selector.openwrt.org/ "https://firmware-selector.openwrt.org/")

Based on original Attended Sysupgrade interface from [https://sudhanshu16.github.io/openwrt-firmware-selector/](https://sudhanshu16.github.io/openwrt-firmware-selector/ "https://sudhanshu16.github.io/openwrt-firmware-selector/")

### Chef Online Imagebuilder / Attended Sysupgrade(asu)

Javascript app that connects to a Attendedsysupgrade server via an API, this is a work in progress. It's frontend resembles the Firmware Selector although provides customization options such as package selection.

Web-based asu frontends:

- [https://asu.aparcar.org/](https://asu.aparcar.org/ "https://asu.aparcar.org/")
- [https://chef.libremesh.org/](https://chef.libremesh.org/ "https://chef.libremesh.org/")

On router packages cli:auc and luci:luci-app-attendedsysupgade offer alternative frontends to communicate with asu server infrastructure in addition to the web based frontends above.

This project intends to simplify the sysupgrade process of devices running OpenWrt or distributions based on the former like LibreMesh. The provided tools here offer an easy way to reflash the router with a new version or package upgrades, without the need of opkg installed.

Additionally it offers an API (covered below) to request custom images with any selection of packages pre-installed, allowing to create firmware images without the need of setting up a build environment, even from mobile devices.

Flask-based code: [https://github.com/aparcar/asu](https://github.com/aparcar/asu "https://github.com/aparcar/asu")

## Gluon

Gluon is a modular framework for creating OpenWrt-based firmware images for wireless mesh nodes. Several Freifunk communities in Germany use Gluon as the foundation of their Freifunk firmware.

Documentation: [https://gluon.readthedocs.io/en/latest/](https://gluon.readthedocs.io/en/latest/ "https://gluon.readthedocs.io/en/latest/")

## Freifunk Berlin firmware

This tool creates customized OpenWrt images for the needs of Freifunk Berlin. It builds images directly from the OpenWrt source code to create an Imagebuilder and SDK. The final images are build with the created Imagebuilder or a prebuild Imagbuilder can be used directly.

Code: [https://github.com/freifunk-berlin/firmware](https://github.com/freifunk-berlin/firmware "https://github.com/freifunk-berlin/firmware")

Documentation: [https://github.com/freifunk-berlin/firmware#development](https://github.com/freifunk-berlin/firmware#development "https://github.com/freifunk-berlin/firmware#development")

## Temba (TEMplate BAsed firmware)

Buildsystem to generate custom Openwrt-Firmware files for different nodes in a community network.

It uses erb templates on config files per device, evaluated from inherited yaml files. There are two interfaces: command-line (rake) and web (simple Ruby on Rails app).

Code: [https://gitlab.com/guifi-exo/temba](https://gitlab.com/guifi-exo/temba "https://gitlab.com/guifi-exo/temba")

Slide of the presentation at Battlemesh v12: [https://www.battlemesh.org/BattleMeshV12?action=AttachFile&amp;do=get&amp;target=custom\_pseudofirmware\_with\_OpenWrt\_imagebuilder.pdf](https://www.battlemesh.org/BattleMeshV12?action=AttachFile&do=get&target=custom_pseudofirmware_with_OpenWrt_imagebuilder.pdf "https://www.battlemesh.org/BattleMeshV12?action=AttachFile&do=get&target=custom_pseudofirmware_with_OpenWrt_imagebuilder.pdf")

## imagebuilder.sh

Part of Temba, a helper script to build the environment to run the image builder.

Code: [https://gitlab.com/guifi-exo/temba/blob/master/imagebuilder.sh](https://gitlab.com/guifi-exo/temba/blob/master/imagebuilder.sh "https://gitlab.com/guifi-exo/temba/blob/master/imagebuilder.sh")

## openwrt-tools

Project by tetaneutral.net, a community ISP in France.

Python program that uses YAML templates to generate images for various devices. No web interface.

Code: [https://redmine.tetaneutral.net/projects/git-tetaneutral-net/repository/openwrt-tools](https://redmine.tetaneutral.net/projects/git-tetaneutral-net/repository/openwrt-tools "https://redmine.tetaneutral.net/projects/git-tetaneutral-net/repository/openwrt-tools")

## openwrt-auto-extroot

[openwrt-auto-extroot](https://github.com/attila-lendvai/openwrt-auto-extroot "https://github.com/attila-lendvai/openwrt-auto-extroot") can be used to build a custom firmware image that will automatically format and set up extroot on **any** plugged-in, but not yet setup storage device. The primary audience of this project is developers, who can use it to build customized firmware images for their applications, but advanced users should also be able to build a firmware by just running its build script as-is.

## lime-sdk cooker

The “LibreMesh software development kit” uses the OpenWRT SDK and ImageBuilder to generate (cook) LibreMesh packages and firmware. If you want to create your own LibreMesh flavor because you need some specific configuration or you just want to have control over your binaries, the cooker is your friend!

Command-line interface, but can also be used with [Chef](https://github.com/libremesh/chef/ "https://github.com/libremesh/chef/").

Code: [https://github.com/libremesh/lime-sdk](https://github.com/libremesh/lime-sdk "https://github.com/libremesh/lime-sdk")

## openwrt-linksys8450-ubi-installer

A script which uses the IB to generate easy-to-use installer images for the Linksys E8450 and Belkin RT3200.

Code: [https://github.com/dangowrt/linksys-e8450-openwrt-installer](https://github.com/dangowrt/linksys-e8450-openwrt-installer "https://github.com/dangowrt/linksys-e8450-openwrt-installer")

## openwrt-metabuilder

Simple wrapper around ImageBuilder, that automatically downloads the right ImageBuilder archive.

Code: [https://github.com/aparcar/openwrt-metabuilder](https://github.com/aparcar/openwrt-metabuilder "https://github.com/aparcar/openwrt-metabuilder")

## openwrt\_autobuild

A simple, standalone python3 wrapper around ImageBuilder that consumes a declarative INI-style configuration file and builds images for multiple targets and devices in parallel.

Code: [https://johannes.truschnigg.info/code/openwrt\_autobuild/](https://johannes.truschnigg.info/code/openwrt_autobuild/ "https://johannes.truschnigg.info/code/openwrt_autobuild/")

## Mesh testbed generator

Older initiative, was the basis of Temba: [https://github.com/yanosz/mesh\_testbed\_generator/](https://github.com/yanosz/mesh_testbed_generator/ "https://github.com/yanosz/mesh_testbed_generator/")

## Meshkit

Project by Freifunk: meshkit is a webinterface for the OpenWrt image generator. It allows you to build customized OpenWrt firmware images to use on your router/access point. It also offers templates for each Freifunk community.

![FIXME](/lib/images/smileys/fixme.svg) Demo: [http://imagebuilder.augsburg.freifunk.net/meshkit](http://imagebuilder.augsburg.freifunk.net/meshkit "http://imagebuilder.augsburg.freifunk.net/meshkit")

Relevant links:

- [https://wiki.freifunk.net/Freifunk\_Firmware/Meshkit](https://wiki.freifunk.net/Freifunk_Firmware/Meshkit "https://wiki.freifunk.net/Freifunk_Firmware/Meshkit")
- [https://github.com/freifunk/meshkit](https://github.com/freifunk/meshkit "https://github.com/freifunk/meshkit")
- [https://github.com/freifunk/meshkit-community\_files](https://github.com/freifunk/meshkit-community_files "https://github.com/freifunk/meshkit-community_files")
- [http://doc.meshkit.freifunk.net/daily/html/](http://doc.meshkit.freifunk.net/daily/html/ "http://doc.meshkit.freifunk.net/daily/html/")
- [https://wiki.freifunk.net/Freifunk-Firmware/Community-Profile](https://wiki.freifunk.net/Freifunk-Firmware/Community-Profile "https://wiki.freifunk.net/Freifunk-Firmware/Community-Profile")
