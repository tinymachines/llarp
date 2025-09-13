# X Play

If you receive more services then just “Internet” from your ISP, you have either:

- [Dual play](https://en.wikipedia.org/wiki/Dual%20play "https://en.wikipedia.org/wiki/Dual play") Internet + [VoIP](https://en.wikipedia.org/wiki/Voice%20over%20IP "https://en.wikipedia.org/wiki/Voice over IP")
- or [Triple play (telecommunications)](https://en.wikipedia.org/wiki/Triple%20play%20%28telecommunications%29 "https://en.wikipedia.org/wiki/Triple play (telecommunications)") Internet + VoIP + [IPTV](https://en.wikipedia.org/wiki/IPTV "https://en.wikipedia.org/wiki/IPTV")
- or [Quadruple play](https://en.wikipedia.org/wiki/Quadruple%20play "https://en.wikipedia.org/wiki/Quadruple play") Internet + VoIP + IPTV + “wireless”/mobile

Please read this rather old article: [http://www.heise.de/ct/artikel/Erwuenschtes-Fremdgehen-291758.html](http://www.heise.de/ct/artikel/Erwuenschtes-Fremdgehen-291758.html "http://www.heise.de/ct/artikel/Erwuenschtes-Fremdgehen-291758.html") in German language. This [Forum Post](https://forum.openwrt.org/viewtopic.php?pid=130880#p130880 "https://forum.openwrt.org/viewtopic.php?pid=130880#p130880") might also help you with problems.

And this means that all data travels through your Router. Usually you get a Router with integrated DSL/DOCSIS or LTE functionality from your provider, such a device combines NAT-Router, Modem, Splitter and Telefon-Box in one device. And only a few of such devices are supported by OpenWrt, namely the ones which incorporate hardware, for which FOSS drivers are available. The devices for which only closed source drivers are available, will work with OpenWrt, but WITHOUT that functionality.

However you could connect a fully supported router behind the one provided by your ISP, and here is list of articles, which concern themselves with your possibilities:

- [internet.connection](/docs/guide-user/network/wan/internet.connection "docs:guide-user:network:wan:internet.connection") with x-play, sometimes you have to arrange for special adjustments in order for everything to work
- [udp\_multicast](/docs/guide-user/network/wan/udp_multicast "docs:guide-user:network:wan:udp_multicast") IPTV service is usually done via IPv4 UDP multicasting

## External

- [IPTV scheme](http://rpc.one.pl/images/stories/images/wr1043nd/vlan_wr1043nd_iptv_schemat.jpg "http://rpc.one.pl/images/stories/images/wr1043nd/vlan_wr1043nd_iptv_schemat.jpg")
- [Info](http://translate.google.com/translate?hl=en-US&sl=auto&tl=en&u=http%3A%2F%2Frpc.one.pl%2Findex.php%2Flista-artykulow%2F34-openwrt%2F81-konfiguracja-switch-vlan-na-podstawie-swconfig-w-routerze-wr1043nd-pod-openwrt "http://translate.google.com/translate?hl=en-US&sl=auto&tl=en&u=http://rpc.one.pl/index.php/lista-artykulow/34-openwrt/81-konfiguracja-switch-vlan-na-podstawie-swconfig-w-routerze-wr1043nd-pod-openwrt")
