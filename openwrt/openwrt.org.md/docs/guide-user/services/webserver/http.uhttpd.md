# uHTTPd webserver

uHTTPd is OpenWrt's default web server and is used to provide the [LuCI](/docs/techref/luci "docs:techref:luci") web interface.

Its source code is available in the following git repository:

- [https://git.openwrt.org/project/uhttpd.git](https://git.openwrt.org/project/uhttpd.git "https://git.openwrt.org/project/uhttpd.git")
- [https://github.com/openwrt/uhttpd](https://github.com/openwrt/uhttpd "https://github.com/openwrt/uhttpd") (mirror)

## Features

Built as a general purpose HTTP daemon suitable for embedded devices, uHTTPd features include:

- A lightweight, single-threaded and event-driven architecture with minimal memory footprint
- HTTP and HTTPS (TLS) support
- CGI script execution
- Scripting via Lua and [UCode](https://ucode.mein.io/ "https://ucode.mein.io/")
- Basic authentication
- File serving with directory listing capabilities
- URL rewriting and aliasing

## Installation

uHTTPd is the standard HTTP server for OpenWrt, and is usually included by default in the system image for the main OpenWrt releases. The package name is `uhttpd`. In case the package is not installed, it can be installed manually:

```
opkg update
opkg install uhttpd
```

However, it is usually installed automatically as a dependency for the [LuCI](/docs/techref/luci "docs:techref:luci") [web interface](/docs/guide-user/luci/webinterface.overview "docs:guide-user:luci:webinterface.overview").

## Configuration

The configuration of uHTTPd is performed via OpenWrt's standard [uci](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") system. The configuration file is `/etc/config/uhttpd`. See the [uHTTPd UCI configuration page](/docs/guide-user/services/webserver/uhttpd "docs:guide-user:services:webserver:uhttpd") for further details.

### Using the default installation for publishing files

One can use the default installation to publish files under `/www`. Here's a quick example:

```
mkdir /www/test
echo "Hello world" >> /www/test/message.txt
```

The file should now be available at e.g. `https://192.168.1.1/test/`.
