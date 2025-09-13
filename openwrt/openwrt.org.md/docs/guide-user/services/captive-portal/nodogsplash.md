# NoDogSplash Captive Portal

## Overview

NoDogSplash (NDS) is a high performance, small footprint Captive Portal, offering by default a simple splash page restricted Internet connection. From version 5.0.0 the Forwarding Authentication Service API **(FAS) has been moved to the openNDS package**. This allows NoDogSplash to be optimised for use on devices with very limited resources (eg 8/64 or less). NoDogSplash v5.0.0 and greater will only support templated html splash pages.

Note1: There has been little or no work in the project since spring 2020. It is not known if the project is still active.

Note2: Version 5 has incompatibility issues with nftables so cannot be regarded as stable on OpenWrt 22.03.00 onwards.

For details of the OpenNDS package, see: [https://openwrt.org/docs/guide-user/services/captive-portal/opennds](https://openwrt.org/docs/guide-user/services/captive-portal/opennds "https://openwrt.org/docs/guide-user/services/captive-portal/opennds")

## Documentation

Full documentation can be found at:

[https://nodogsplashdocs.readthedocs.io](https://nodogsplashdocs.readthedocs.io "https://nodogsplashdocs.readthedocs.io")

## Official Repository

The official repository can be found here:

[https://github.com/nodogsplash/nodogsplash](https://github.com/nodogsplash/nodogsplash "https://github.com/nodogsplash/nodogsplash")

## How NoDogSplash (NDS) works

NoDogSplash is a Captive Portal Engine. Any Captive Portal, including NDS, will have two main components:

- Something that does the capturing, and
- Something to provide a Portal for client users to log in.

A wireless router will typically be running OpenWrt or some other Linux distribution.

A router, by definition, will have two or more interfaces, at least one to connect to the wide area network (WAN) or Internet feed, and at least one connecting to the local area network (LAN).

Each LAN interface must also act as the Default IP Gateway for its LAN, ideally with the interface serving IP addresses to client devices using DHCP.

Multiple LAN interfaces can be combined into a single bridge interface. For example, ethernet, 2.4Ghz and 5Ghz networks are typically combined into a single bridge interface. Logical interface names will be assigned such as eth0, wlan0, wlan1 etc. with the combined bridge interface named as br-lan.

NDS will manage one or more of them of them. This will typically be br-lan, the bridge to both the wireless and wired LAN, but could be, for example, wlan0 if you wanted NDS to work just on the wireless interface.

#### Summary of Operation

By default, NDS blocks everything, but intercepts port 80 requests.

An initial port 80 request will be generated on a client device, usually automatically by the client device's built in Captive Portal Detection (CPD), or possibly by the user manually browsing to an http web page.

This request will of course **be routed by the client device to the Default Gateway** of the local network. The Default Gateway will, as we have seen, be the router interface that NDS is managing.

#### The Thing That Does the Capturing

As soon as this initial port 80 request is received on the default gateway interface, NDS will “Capture” it, make a note of the client device identity, allocate a unique token for the client device, then redirect the client browser to the Portal component of NDS.

#### The Thing That Provides the Portal

The client browser is redirected to the Portal component. This is a web service that is configured to know how to communicate with the core engine of NDS. This is commonly known as the Splash Page.

NDS has its own web server built in and this can be used to serve the Portal “Splash” pages to the client browser, or a separate web server can be used.

### NoDogSplash supports Templated html splash pages

The default installation contains a fully functional splash page with a “click to continue” button. This is served from the included splash.html and splash.css files and can be easily customised by editing these files.

### FAS, or Forward Authentication Service

From version 5.0.0, the OpenNDS package is required for FAS support.

See: [https://openwrt.org/docs/guide-user/services/captive-portal/opennds](https://openwrt.org/docs/guide-user/services/captive-portal/opennds "https://openwrt.org/docs/guide-user/services/captive-portal/opennds")

### A Note on Captive Portal Detection (CPD)

All modern mobile devices, most desktop operating systems and most browsers now have a CPD process that automatically issues a port 80 request on connection to a network. NDS detects this and serves a special “splash” web page to the connecting client device.

The port 80 html request made by the client CPD can be one of many vendor specific URLs.

Typical CPD URLs used are, for example:

- [http://captive.apple.com/hotspot-detect.html](http://captive.apple.com/hotspot-detect.html "http://captive.apple.com/hotspot-detect.html")
- [http://connectivitycheck.gstatic.com/generate\_204](http://connectivitycheck.gstatic.com/generate_204 "http://connectivitycheck.gstatic.com/generate_204")
- [http://connectivitycheck.platform.hicloud.com/generate\_204](http://connectivitycheck.platform.hicloud.com/generate_204 "http://connectivitycheck.platform.hicloud.com/generate_204")
- [http://www.samsung.com/](http://www.samsung.com/ "http://www.samsung.com/")
- [http://detectportal.firefox.com/success.txt](http://detectportal.firefox.com/success.txt "http://detectportal.firefox.com/success.txt")
- Plus many more

It is important to remember that CPD is designed primarily for mobile devices to automatically detect the presence of a portal and to trigger the login page, without having to resort to breaking SSL/TLS security by requiring the portal to redirect port 443 for example.

Just about all current CPD implementations work very well but some compromises are necessary depending on the application.

### A Note on Captive Portal Identification (CPI)

Until recently, the vast majority of devices attaching to a typical Captive Portal used CPD.

More and more devices are beginning to use the new Captive Portal Identification method (CPI) (RFC8910/RFC8908). NoDogSplash does not support CPI.
