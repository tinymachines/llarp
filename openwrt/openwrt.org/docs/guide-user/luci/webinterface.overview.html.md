# Web interface overview

This is for a web interface used to administer OpenWrt. For running a webserver see [webserver](/docs/guide-user/services/webserver/start "docs:guide-user:services:webserver:start"). You can read about web interfaces on [http://lwn.net/Articles/420066/](http://lwn.net/Articles/420066/ "http://lwn.net/Articles/420066/").

## LuCI

Mainly [Lua (programming language)](https://en.wikipedia.org/wiki/Lua%20%28programming%20language%29 "https://en.wikipedia.org/wiki/Lua (programming language)")

- Project Homepage: [https://github.com/openwrt/luci/wiki/](https://github.com/openwrt/luci/wiki/ "https://github.com/openwrt/luci/wiki/")
- Translation Portal: [https://github.com/openwrt/luci/wiki/i18n](https://github.com/openwrt/luci/wiki/i18n "https://github.com/openwrt/luci/wiki/i18n")
- [luci.essentials](/docs/guide-user/luci/luci.essentials "docs:guide-user:luci:luci.essentials")
- [LuCI – Technical Reference](/docs/techref/luci "docs:techref:luci")
- [http.uhttpd](/docs/guide-user/services/webserver/http.uhttpd "docs:guide-user:services:webserver:http.uhttpd") is default web server

## LuCI2

- [LuCI2 - Technical Reference](/docs/techref/luci2 "docs:techref:luci2")
- [http.uhttpd](/docs/guide-user/services/webserver/http.uhttpd "docs:guide-user:services:webserver:http.uhttpd") is default web server
- [luci2 sources (cgit)](http://git.openwrt.org/?p=project%2Fluci2%2Fui.git "http://git.openwrt.org/?p=project/luci2/ui.git")

## JUCI

[JUCI](https://github.com/mkschreder/juci "https://github.com/mkschreder/juci") is modern web interface developed for OpenWrt-based embedded devices. It is built using HTML5 and angular.js and uses websockets for communicating with a compact and fast Lua backend running on the embedded device. You can build both the frontend application and the backend server independently of each other and use them separately. It's developed by [IOPSYS](https://iopsys.eu/ "https://iopsys.eu/") and used on their devices.

## Turris Foris and reForis

[Foris](https://doc.turris.cz/doc/en/howto/foris "https://doc.turris.cz/doc/en/howto/foris") is a Web UI used in [Turris Omnia](/toh/turris/turris_omnia "toh:turris:turris_omnia") routers. [reForis](https://gitlab.nic.cz/turris/reforis/reforis "https://gitlab.nic.cz/turris/reforis/reforis") is a newer redesigned version. But they are open source so you may freely use them on other devices. They are written in Python so your device must have enough disk space.

## Oui

[Oui](https://zhaojh329.github.io/oui/ "https://zhaojh329.github.io/oui/") is a Web UI built using Vue3 that relies on a [custom lua runtime](https://github.com/zhaojh329/lua-eco "https://github.com/zhaojh329/lua-eco"). It's designed to be modular in a similar way to LuCI (i.e. allowing separate ipk modules rather than a single monolithic frontend).

## Gargoyle

Uses [JavaScript](https://en.wikipedia.org/wiki/JavaScript "https://en.wikipedia.org/wiki/JavaScript") ? to do as much of the computation on the client side as possible, server-side scripting that is necessary is done using [haserl](https://haserl.sourceforge.net/ "https://haserl.sourceforge.net/") .

- Project Homepage: [https://www.gargoyle-router.com/](https://www.gargoyle-router.com/ "https://www.gargoyle-router.com/")
- Implementation Overview: [developer\_documentation](https://www.gargoyle-router.com/wiki/doku.php?id=developer_documentation "https://www.gargoyle-router.com/wiki/doku.php?id=developer_documentation")

## CyberWRT

[CyberWRT](http://cyber-place.ru/showthread.php?t=720 "http://cyber-place.ru/showthread.php?t=720") is a dashboard for IoT hub based on OpenWrt. It's popular in DIY community to create smart home solutions. It's not intended to administer router but still has some limited capabilities for this.

## Webmin

[Webmin](https://www.webmin.com/ "https://www.webmin.com/") is a web-based interface written in Perl for system administration for Unix and Linux (but it wasn't ported to OpenWrt yet). Using any modern web browser, you can setup user accounts, Apache, DNS, file sharing and much more. Webmin removes the need to manually edit Unix configuration files like /etc/passwd, and lets you manage a system from the console or remotely. The same author also created [UserMin](https://www.webmin.com/usermin.html "https://www.webmin.com/usermin.html") for a regular users with webmail, password changing, mail filters, fetchmail and much more.

## X-Wrt

X-Wrt was the first web interface project for OpenWrt. It shouldn't to be confused with a more recent Chinese fork of OpenWrt also named X-Wrt.

- Archived Homepage: [https://web.archive.org/web/20131031031526/http://x-wrt.org/](https://web.archive.org/web/20131031031526/http://x-wrt.org/ "https://web.archive.org/web/20131031031526/http://x-wrt.org/")

## X-Wrt Chinese

Chinese fork of OpenWrt, has a configuration wizard

- [Homepage](https://x-wrt.com/ "https://x-wrt.com/")
- [https://github.com/x-wrt/x-wrt](https://github.com/x-wrt/x-wrt "https://github.com/x-wrt/x-wrt")
