# Zero configuration networking in OpenWrt

Zero-configuration networking (zeroconf) is a methodology and a set of special technologies that automatically creates a usable computer network based on the Internet Protocol Suite (TCP/IP) when computers or network peripherals are interconnected. It does not require manual operator intervention or special configuration servers. [Zeroconf](https://en.wikipedia.org/wiki/Zeroconf "https://en.wikipedia.org/wiki/Zeroconf")

Zeroconf (aka bonjour) can be used for ad-hoc networks and internal service announcements (mDNS) without the need to configure DHCP and DNS servers. All zeroconf enabled devices such as printers, scanners, wireless speakers, chromecast devices etc. automatically answer to zeroconf enabled clients via IPv4 or IPv6 multicast messages without a central registry. Therefore, it is only required to install a zeroconf solution on your OpenWrt router if you have one of the following use-cases:

- Publish services though zeroconf that are not zeroconf enabled
- Automatically assign a link local IP address without the need for a DHCP server
- Configure conventional DNS servers using mDNS in a DHCP-like fashion

If you cannot discover an existing zeroconf service on your local network this is typically due to a multicast issue on layer 2. Sometimes the bridge between your LAN and your WLAN will block multicast packets. Also managed Ethernet switches can limit/block multicast packets by default. Unless you have specific use-cases like multicast video-streaming it is recommended to disable IGMP-snooping as this will ensure that multicast packets are treated like broadcast packages.

OpenWrt offers several different packages supporting the different zeroconf implementations:

- [umdns - OpenWrt's own package](/docs/guide-developer/mdns "docs:guide-developer:mdns"). Recommended.
- [avahi](https://wiki.archlinux.org/title/avahi "https://wiki.archlinux.org/title/avahi") - A fairly full, but quite large implementation. Packages: avahi-daemon-service-ssh, avahi-daemon-service-http, avahi-utils, avahi-autoipd, avahi-dnsconfd
- Bonjour - provided by Apple's mDNSResponder. Packages: mdnsresponder, mdnsd
- A small [announce](/packages/pkgdata/announce "packages:pkgdata:announce") automatically announces ssh, sftp, and http services
- Zeroconf/UPnP SSDP (Microsoft, incompatible with mDNS)
- Web Services on Devices Discovery, LLMNR. Install for Samba/Ksmbd servers for network shares to appear in Windows File Explorer / Network. Package: wsdd2

![:!:](/lib/images/smileys/exclaim.svg) Many programs can be compiled with zeroconf support. However due to size restrictions this support is most likely deactivated by default. Compile your own image.

![:!:](/lib/images/smileys/exclaim.svg) Currently there is little DNS-SD support on Windows, since it uses incompatible UPnP SSDP.

![:!:](/lib/images/smileys/exclaim.svg) The .local domain is reserved for (zeroconfig) multicast dns [rfc6762](http://tools.ietf.org/html/rfc6762 "http://tools.ietf.org/html/rfc6762"), [.local](https://en.wikipedia.org/wiki/.local "https://en.wikipedia.org/wiki/.local"). Watch out for conflicts with your Dnsmasq configuration

## umdns

In OpenWrt since OpenWRT 17 [r41345](https://dev.openwrt.org/changeset/41345 "https://dev.openwrt.org/changeset/41345")

If you want your device to be discoverable in your network, you must define a hostname for it under /etc/config/system

```
 option hostname 'your_openwrt_device'
```

Even if the service comes with the base install, it must be enabled and started:

```
# /etc/init.d/umdns enable
# /etc/init.d/umdns start
```

```
 umdns: add the new openwrt mdns daemon

this is still wip, you can use the following ubus calls.

ubus call umdns update # triggers a scan
ubus call umdns browse # look at the currenlty cached records
ubus call umdns hosts # look at the currenlty cached hosts
```

## avahi

avahi-daemon: mDNS daemon avahi-utils: lookup utility avahi-browse

In order to announce http and ssh services to the network, do:

```
opkg update
opkg install avahi-daemon-service-ssh avahi-daemon-service-http
```

## mdnsresponder

Install the **mdnsresponder** package:

```
# opkg update
# opkg install mdnsresponder
```

Edit the **/etc/mDNSResponder.conf** file, which contains a list of service descriptions:

```
"SSH Service"
_ssh._tcp. local
22
Local SSH Service

"Web Service"
_http._tcp. local
80
Local Web Service
```

Once all your services are configured, you can enable and start the mDNSResponder:

```
# /etc/init.d/mDNSResponder enable
# /etc/init.d/mDNSResponder start
```
