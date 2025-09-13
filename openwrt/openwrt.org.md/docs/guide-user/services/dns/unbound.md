# Unbound

[Unbound](https://www.unbound.net/ "https://www.unbound.net/") is a validating, recursive, and caching DNS resolver. The C implementation of Unbound is developed and maintained by [NLnet Labs](https://www.nlnetlabs.nl/ "https://www.nlnetlabs.nl/").

OpenWrt base install uses Dnsmasq for DNS forwarding (and DHCP serving). This works well for many cases. Dependence on the upstream resolver can be cause for concern. It is often provided by the ISP, and some users have switched to public DNS providers. Either way can result in problems due to performance, hijacking, trustworthiness, or several other reasons. Running a recursive resolver is a solution.

Releases [LEDE 17.01](/releases/17.01/start "releases:17.01:start") and [OpenWrt 18.06](/releases/18.06/start "releases:18.06:start") have included UCI/LuCI for the Unbound [package](https://github.com/openwrt/packages "https://github.com/openwrt/packages") and complete documentation in its README. The UCI/LuCI features should be familiar to those that have tweaked dnsmasq in the past. “How To” are available for integration with either dnsmasq or odhcpd. “How To” are available to configure Unbound as forwarding client of DoT.

DNS over TLS is fully supported with Unbound configuration helpers in UCI and LuCI. **You should be able to find it all in the README.** You can manage zone recursion, zone forward, and zone transfer preferences. These are present in a form similar to how the firewall pin point rules work. You may forward specific domains to specific DNS servers with or without TLS. This may be useful where you need location specific resolution for ISP colocated services such as is often done by Google ([www.youtube.com](http://www.youtube.com "http://www.youtube.com") by 8.8.8.8), but wish to have a private DNS like CloudFlare (1.1.1.1) mask location while resolving general look-ups.

Documentation:

- [README for Unbound 1.6.8 @ LEDE 17.01](https://github.com/openwrt/packages/tree/lede-17.01/net/unbound/files/README.md "https://github.com/openwrt/packages/tree/lede-17.01/net/unbound/files/README.md")
- [README for Unbound 1.10.1 @ OpenWrt 18.06](https://github.com/openwrt/packages/tree/openwrt-18.06/net/unbound/files/README.md "https://github.com/openwrt/packages/tree/openwrt-18.06/net/unbound/files/README.md")
- [README for Unbound 1.10.1 @ OpenWrt 19.07](https://github.com/openwrt/packages/tree/openwrt-19.07/net/unbound/files/README.md "https://github.com/openwrt/packages/tree/openwrt-19.07/net/unbound/files/README.md")
- [README for Unbound @ OpenWrt Snapshot](https://github.com/openwrt/packages/tree/master/net/unbound/files/README.md "https://github.com/openwrt/packages/tree/master/net/unbound/files/README.md")

Note there are significant options enhancements from 18.06 to 19.07 including UCI/LuCI for TLS.
