# Shadowsocks

NOTE: shadowsocks-libev is included in OpenWrt up to version 23.05 and dropped thereafter (see [this pull request](https://github.com/openwrt/packages/pull/24540 "https://github.com/openwrt/packages/pull/24540")).

[shadowsocks](https://shadowsocks.org/ "https://shadowsocks.org/") is a fast tunnel proxy that helps you bypass firewalls.

Here's a summary on how to install and setup shadowsocks on a fresh OpenWrt 19.06 installation, (taken from [this forum post](https://forum.openwrt.org/t/guide-shadowsocks-setup-on-openwrt-for-beginners/77026 "https://forum.openwrt.org/t/guide-shadowsocks-setup-on-openwrt-for-beginners/77026"))

## Installation

You need to install the following packages:

```
opkg install shadowsocks-libev-ss-local shadowsocks-libev-ss-redir shadowsocks-libev-ss-rules shadowsocks-libev-ss-tunnel
```

And if you need the Luci web interface also:

```
opkg install luci-app-shadowsocks-libev
```

## Server Configuration

In the Luci Web UI, head to **Services → Shadowsocks-libev → Remote Servers** if going from CLI the config file is **/etc/config/shadowsocks-libev**

Edit the existing sss0 server (or add a new one). Set at least IP, port, method and password, and don't forget to untick the Disable checkbox.

## Services and Rules Configuration

The simplest recipe is to forward all traffic through the tunnel. Follow the steps outlined [in the readme file under Recipes &gt; forward all](https://github.com/openwrt/packages/blob/openwrt-23.05/net/shadowsocks-libev/README.md#forward-all "https://github.com/openwrt/packages/blob/openwrt-23.05/net/shadowsocks-libev/README.md#forward-all")

## DNS Configuration

This must be done via command line according to the instructions in [in the readme file under Recipes &gt; forward all](https://github.com/openwrt/packages/blob/openwrt-23.05/net/shadowsocks-libev/README.md#forward-all "https://github.com/openwrt/packages/blob/openwrt-23.05/net/shadowsocks-libev/README.md#forward-all")
