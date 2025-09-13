# Dnsmasq DHCP server

[Dnsmasq](https://en.wikipedia.org/wiki/Dnsmasq "https://en.wikipedia.org/wiki/Dnsmasq") is a lightweight, easy to configure DNS-forwarder and DHCP-server. It is designed to provide DNS and, optionally, DHCP, to a small network. It can serve the names of local machines which are not in the global DNS. The DHCP-server integrates with the DNS server and allows machines with DHCP-allocated addresses to appear in the DNS with names configured either in each host or in a central configuration file. Dnsmasq supports static and dynamic DHCP leases and BOOTP for network booting of disk-less machines. It is already installed and preconfigured on OpenWrt.

## Configuration

The configuration is done with help of the uci-configuration file: `/etc/config/dhcp`, but you can use this together with the file `/etc/dnsmasq.conf`.

Depending on the setting in the uci-file, you may also use the files `/etc/ethers` and `/etc/hosts` additionally.

### /etc/config/dhcp

→ [/etc/config/dhcp](/docs/guide-user/base-system/dhcp "docs:guide-user:base-system:dhcp") is a UCI configuration file and as such documented exclusively in [uci](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci"). Almost all settings can be configured with it!

### /etc/dnsmasq.conf

It is possible to mix the traditional `/etc/dnsmasq.conf` configuration file with the options found in `/etc/config/dhcp`.

The `dnsmasq.conf` file does not exist by default but will be processed by dnsmasq on startup if it is present. Note that options in `/etc/config/dhcp` take precendence over `dnsmasq.conf` since they are translated to command line arguments.

Example: By default, Dnsmasq comes configured to put your hosts into the `.lan` domain. This is specified in the configuration file as:

```
# allow /etc/hosts and dhcp lookups via *.lan
local=/lan/
domain=lan
```

You can change this to whatever you'd like your home domain to be. Also, if you want your hosts to be available via your home domain without having to specify the domain in your `/etc/hosts` file, add the `expand-hosts` directive to your `/etc/dnsmasq.conf` file.

As an example, without `expand-hosts`, you can only reach *router, ubuntu-desktop and ubuntu-laptop*. With *expand-hosts* on, you can reach *router, router.lan, ubuntu-desktop, ubuntu-desktop.lan, etc*. This probably matches what you're looking for anyway.

Without this setting, you'll have to add *.lan* entries to your `/etc/hosts`.

### /etc/ethers

In `/etc/ethers` static lease entries can be assigned. See → [static\_leases](/docs/guide-user/base-system/dhcp#static_leases "docs:guide-user:base-system:dhcp").

### /etc/hosts

In `/etc/hosts` DNS entries are configured. Dnsmasq will utilize these entries to answer DNS queries on your network.

Format:

```
[IP_address] host_name host_name_short ...
```

Example:

```
192.168.1.1 router OpenWrt localhost
192.168.1.2 debian-server
192.168.1.3 ubuntu-laptop
```

## Troubleshooting

### DHCP response missing due to network overload

Sometimes when an interface is on the edge of the capacity (especially WiFi over longer distances) a DHCP request could be not replied in time. Therefore the DHCP client will not be able to receive proper network settings. A possible workaround is using static IPs or very long DHCP leases (more than 12h). This is particularly important when one has several WiFi repeaters that use DHCP and are distant from each other or not easily accessible.

### Log spammed with DHCPINFORM/DHCPACK

Windows 7 among others ask for proxy settings using DHCP. The issue is that they do not stop asking until they have received an answer. This results in that the log contains a lot information about these requests, an example can be found below (thanks to [the excito wiki](http://wiki.excito.com/w/index.php?title=Stop_DHCP_INFORM_flooding "http://wiki.excito.com/w/index.php?title=Stop_DHCP_INFORM_flooding") for the info).

Solution:

```
uci add_list dhcp.lan.dhcp_option='252,"\n"'
uci commit dhcp
service dnsmasq restart
```

### Static lease issues

Windows 7 has introduced a new [Microsoft-enhanced](http://answers.microsoft.com/en-us/windows/forum/windows_7-networking/windows-7-refuses-dhcp-addresses-if-they-were/1b72b289-0f58-492f-afb8-e76c80a81f00 "http://answers.microsoft.com/en-us/windows/forum/windows_7-networking/windows-7-refuses-dhcp-addresses-if-they-were/1b72b289-0f58-492f-afb8-e76c80a81f00") feature. It won't assign IP address obtained from a DHCP server to an interface, if the IP was used before for another interface, even if that other interface is **NOT** active currently (i.e. cable disconnected). This behaviour is unique and was not reported for older Windows versions, Mac OS nor Linux.

If you try configure MAC address hot swap on your router, Windows 7 clients will end up in an infinite [DORA](http://tools.ietf.org/html/rfc1531#section-3.1 "http://tools.ietf.org/html/rfc1531#section-3.1") loop.

Solution:

1. Create a [bridge](https://www.google.com/search?q=windows%207%20create%20bridge "https://www.google.com/search?q=windows%207%20create%20bridge") from the wireless and ethernet interfaces on your client
   
   - Add the MAC address of the bridge to `/etc/config/dhcp`
   - Since the bridge will probably take and alter your ethernet MAC address, you will lose SLAAC on wifi interface, making your laptop IPv6-disabled when only wireless is up.
2. Another solution is IPv6 friendly, you don't need to create a bridge, nor add MAC address to dnsmasq config file, but it involves user interaction:
   
   - When you plug the ethernet cable in, disable wireless interface in control panel (power off wireless won't do it).
   - When you unplug ethernet cable, enable wireless and disable ethernet.

```
uci add dhcp host
uci set	dhcp.@host[-1].name="example-host"
uci set	dhcp.@host[-1].ip="192.168.1.230"
uci set	dhcp.@host[-1].mac="00:a0:24:5a:33:69 00:11:22:33:44:55 02:a0:24:5a:33:69 02:11:22:33:44:55"
uci commit dhcp
service dnsmasq restart
```

### Adguard DNS and dnsmasq issues

If you use Adguard DNS as forwarder (to have a cheap and efficient network adblocker), you need to disable Rebind protection, to avoid lag or site unreachable due to Rebin protection.

If not, you can see lot of this log in system.log, and have lag or host unreachable issue.

```
daemon.warn dnsmasq[xxx]: possible DNS-rebind attack detected: any.adserver.dns
```

## Notes

- Project Homepage: [http://thekelleys.org.uk/dnsmasq/doc.html](http://thekelleys.org.uk/dnsmasq/doc.html "http://thekelleys.org.uk/dnsmasq/doc.html")
- Tutorial [http://www.enterprisenetworkingplanet.com/netos/article.php/3377351](http://www.enterprisenetworkingplanet.com/netos/article.php/3377351 "http://www.enterprisenetworkingplanet.com/netos/article.php/3377351")
- Tutorial [http://martybugs.net/wireless/openwrt/dnsmasq.cgi](http://martybugs.net/wireless/openwrt/dnsmasq.cgi "http://martybugs.net/wireless/openwrt/dnsmasq.cgi")
