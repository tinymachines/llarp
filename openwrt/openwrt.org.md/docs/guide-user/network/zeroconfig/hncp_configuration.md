# The Homenet Control Protocol (HNCP)

- The Homenet (hnet) protocol and this documentation were last under development in late 2016. It is unknown whether the `hncp` package works with modern (19.07 and later) versions of OpenWrt.
- The Homenet website seems to have gone off the air in 2020. A 2018 version of the site is at [The Wayback Machine](https://web.archive.org/web/20180831161552/http://homewrt.org/start "https://web.archive.org/web/20180831161552/http://homewrt.org/start")
- This [Forum article](https://forum.openwrt.org/t/homenet-hnet-documentation/209 "https://forum.openwrt.org/t/homenet-hnet-documentation/209") also describes the state.

The Homenet Control Protocol (HNCP) automatically manages IPv4 and IPv6 address assignment, routing, DNS, SD (ZeroConf/mDNS) and border firewalling between multiple routers in a “home network”. It is specified as a set of RFCs to implement a minimalist state synchronization protocol for Homenet routers.  
Read the materials on the [Homenet web site](http://www.homewrt.org "http://www.homewrt.org")

**hnet-full** package installs hnetd to implement HNCP protocol, there is also **luci-app-hnet**, a luci webgui package to control it.  
**Note:** We strongly recommend you install `ipset` before installing `hnet-full`

## Protocol "hnet"

Name Type Required Default Description `mode` string no auto Interface mode. One of external, guest, adhoc or hybrid. `ip6assign` integer no 64 IPv6-prefix size to assign to this interface if internal. `ip4assign` integer no 24 IPv4-prefix size to assign to this interface if internal. `dnsname` string no &lt;device-name&gt; DNS-Label to assign to interface.

### Tutorials

- **Juliusz Chroboczek's tutorial:** [https://www.irif.univ-paris-diderot.fr/~jch/software/homenet/howto.html](https://www.irif.univ-paris-diderot.fr/~jch/software/homenet/howto.html "https://www.irif.univ-paris-diderot.fr/~jch/software/homenet/howto.html")
- **Tore Anderson's tutorial:** [https://blog.toreanderson.no/2015/10/11/making-a-homenet-router-out-of-openwrt.html](https://blog.toreanderson.no/2015/10/11/making-a-homenet-router-out-of-openwrt.html "https://blog.toreanderson.no/2015/10/11/making-a-homenet-router-out-of-openwrt.html")

### Technical Reference

- [RFC 7368 - IPv6 Home Networking Architecture Principles](https://tools.ietf.org/html/rfc7368/ "https://tools.ietf.org/html/rfc7368/")
- [RFC 7788 - Homenet Control Protocol](https://tools.ietf.org/html/rfc7788 "https://tools.ietf.org/html/rfc7788")

### Other Links

- [Overview of Homenet, and why it's the future of home networking](https://blog.toreanderson.no/2015/10/02/homenet-the-future-of-home-networking.html "https://blog.toreanderson.no/2015/10/02/homenet-the-future-of-home-networking.html")
- [Mailing Lists](http://www.homewrt.org/about/mailinglist "http://www.homewrt.org/about/mailinglist")
- [Slides from IETF 89 (March 2014)](https://www.ietf.org/proceedings/89/slides/slides-89-homenet-3.pdf "https://www.ietf.org/proceedings/89/slides/slides-89-homenet-3.pdf")
- [Links to source code on Homenet wiki](http://www.homewrt.org/building/downloads "http://www.homewrt.org/building/downloads")
- [Building hnetd from source](http://www.homewrt.org/building/start "http://www.homewrt.org/building/start")
