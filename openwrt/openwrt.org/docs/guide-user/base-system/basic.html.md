# Basic configuration

OpenWrt has the following ways to configure your device

1. There is [UCI](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") to store and manipulate all its configuration. This is a OpenWrt system to configure base services and many additional packages from a central standardized point.
2. There is LuCI - a web interface for UCI, by default usually listening at `http://192.168.1.1/` or `http://openwrt.lan/`. Not all devices with less than 8MB of Flash ROM have LuCI available, as LuCI requires about 1MB of flash space. LuCI is based on Lua and its a OpenWrt own standard as well. You can also enable HTTPS for LuCI access. Not all options may be available in LuCI.
3. There are several classic Linux config files also used in on OpenWrt devices. These files use the same format and config options as in other Linux distributions.
4. Optional installable packages sometimes integrate into the UCI config model and may also provide a LuCI config extension, but many extension packages also bring their own config files.

When using the command line or the web interface to modify values, all changes are staged and not saved to the file directly, so **remember to save the changes after you have set them.**
