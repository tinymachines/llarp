# Ethernet Network Switch

Many devices supported by OpenWrt contain an Ethernet network switch. Most switches are *configurable* and driver options are available. Typical features include ethernet frame tagging and [VLAN](/docs/guide-user/network/vlan/switch_configuration "docs:guide-user:network:vlan:switch_configuration") support. We require two software components:

1. A kind of a driver
2. A utility

## DSA Distributed Network Switch

The preferred contemporary driver architecture for ethernet switches in the Linux kernel is [DSA (distributed switch architecture)](https://www.kernel.org/doc/html/latest/networking/dsa/dsa.html "https://www.kernel.org/doc/html/latest/networking/dsa/dsa.html").

For a user the main difference to past OpenWrt switch drivers is that all the switch ports that on a consumer router have names such as **LAN1**, **LAN2**, ... or **WAN** also appear as independent network interfaces in userspace and those can be handled like any other network interfaces using the `ip` tool or `ethtool`.

The Linux kernel also has [userspace configuration examples](https://www.kernel.org/doc/html/latest/networking/dsa/configuration.html "https://www.kernel.org/doc/html/latest/networking/dsa/configuration.html") on how to use the DSA switches in Linux.

DSA support will be introduced along with kernel 5.4 support, but there is no full feature parity with swconfig yet as of writing (2020-05-12). Changing VLAN tags is not supported yet at the moment, e.g..

Tagging support is more complex than with swconfig; see the [kernel documentation](https://www.kernel.org/doc/html/latest/networking/dsa/configuration.html#configuration-with-tagging-support "https://www.kernel.org/doc/html/latest/networking/dsa/configuration.html#configuration-with-tagging-support") for configuration instructions. It looks like at this point there is no automation for this yet and it needs to be configured through /etc/rc.local.

### Support matrix

Only master targets actually having DSA enabled are listed.

Target Kernel Notes bcm53xx 5.10? Gemini 5.10 IMX6 5.10 IPQ40xx 5.15 Kirkwood 5.10 Lantiq 5.10 Mediatek/MT7623 5.10 Mvebu 5.10 Realtek 5.10 Ramips/MT7621 5.10 See [Github PR #2942](https://github.com/openwrt/openwrt/pull/2942 "https://github.com/openwrt/openwrt/pull/2942") (merged) for improvements

## Switchdev

**Note**: not to be confused with [Linux switchdev](https://www.kernel.org/doc/html/latest/networking/switchdev.html "https://www.kernel.org/doc/html/latest/networking/switchdev.html"), which DSA is based on.

The previous switch driver model invented by OpenWrt was switchdev and the corresponding configuration utility was `swconfig`. This is used in legacy patches and userspace, but is not recommended when implementing switch drivers for new devices. Please write new code using DSA and help out to convert old drivers to DSA if you can.

## Ethernet Network Switch models

### Realtek

- [RTL8366/RTL8369 datasheet](http://realtek.info/pdf/rtl8366_8369_datasheet_1-1.pdf "http://realtek.info/pdf/rtl8366_8369_datasheet_1-1.pdf"), notice that this is quite different from RTL8366RB or RTL8369S
- [RealTek RTL8366RB](https://web.archive.org/web/20100729202805/http://www.realtek.com.tw/products/productsView.aspx?Langid=1&PNid=18&PFid=15&Level=5&Conn=4&ProdID=197 "https://web.archive.org/web/20100729202805/http://www.realtek.com.tw/products/productsView.aspx?Langid=1&PNid=18&PFid=15&Level=5&Conn=4&ProdID=197"), a 5-port Gigabit switch e.g. in the [WR1043ND v1](/toh/tp-link/tl-wr1043nd "toh:tp-link:tl-wr1043nd") or [DIR-685](/toh/d-link/dir-685 "toh:d-link:dir-685")
  
  - [Upstream RTL8366RB DSA kernel driver](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/drivers/net/dsa/realtek/rtl8366rb.c "https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/drivers/net/dsa/realtek/rtl8366rb.c") this should become the default after incorporating kernel v4.19 or later
  - see [all tickets concerning the Realtek RTL8366RB](https://dev.openwrt.org/search?q=%208366RB&noquickjump=1&ticket=on "https://dev.openwrt.org/search?q=+8366RB&noquickjump=1&ticket=on")
    
    - e.g. [Ticket 7977:Enhance rtl8366rb driver](https://dev.openwrt.org/ticket/7977 "https://dev.openwrt.org/ticket/7977")
    - e.g. [Ticket 10202: Add support for port mirroring in rtl8366rb](https://dev.openwrt.org/ticket/10202 "https://dev.openwrt.org/ticket/10202")
  - see [all changesets concerning the Realtek RTL8366RB](https://dev.openwrt.org/search?q=%208366RB&noquickjump=1&changeset=on "https://dev.openwrt.org/search?q=+8366RB&noquickjump=1&changeset=on")
    
    - e.g. [r36847: add port mirroring/monitoring capability to the RTL8366RB switch](https://dev.openwrt.org/changeset/36847 "https://dev.openwrt.org/changeset/36847")
- [RealTek RTL8366S](http://www.realtek.com.tw/press/newsViewOne.aspx?NewsID=182 "http://www.realtek.com.tw/press/newsViewOne.aspx?NewsID=182"), e.g. in the [DIR-825](/toh/d-link/dir-825 "toh:d-link:dir-825")
- [Realtek RTL8306SD/SDM](http://www.realtek.com.tw/products/productsView.aspx?Langid=1&PFid=20&Level=5&Conn=4&ProdID=156 "http://www.realtek.com.tw/products/productsView.aspx?Langid=1&PFid=20&Level=5&Conn=4&ProdID=156") FastEthernet, 6 Ports, 5x 100BASE-TX-PHYs e.g. in the [ARV4518PW](/toh/arcadyan/arv4518pw "toh:arcadyan:arv4518pw")
- [RTL8309G](http://www.realtek.com.tw/products/productsView.aspx?Langid=1&PFid=21&Level=3&Conn=4&ProdID=209 "http://www.realtek.com.tw/products/productsView.aspx?Langid=1&PFid=21&Level=3&Conn=4&ProdID=209") FastEthernet, 9 Ports, 8x 100BASE-TX-PHYs e.g. in the [D-Link DIR-632](/toh/d-link/dir-632 "toh:d-link:dir-632")

### Qualcomm / Atheros

- AR8216 FastEthernet, 6 ports; found in [Arcadyan ARV752DPW22](/toh/astoria/arv752dpw22 "toh:astoria:arv752dpw22"), [Netgear WNR2000v1](/toh/netgear/wnr2000 "toh:netgear:wnr2000"), others
- AR8316 GigabitEthernet, e.g. in the [RouterStation Pro](/toh/ubiquiti/routerstation_pro "toh:ubiquiti:routerstation_pro"), [WBMR-HP-G300H](/toh/buffalo/wbmr-hp-g300h "toh:buffalo:wbmr-hp-g300h"), ...
- [AR8228 + AR8229](http://www.qca.qualcomm.com/technology/technology.php?nav1=48&product=99 "http://www.qca.qualcomm.com/technology/technology.php?nav1=48&product=99") FastEthernet: 7-Ports, 5x 100BASE-TX-PHYs
- [AR8236](http://www.qca.qualcomm.com/technology/technology.php?nav1=48&product=100 "http://www.qca.qualcomm.com/technology/technology.php?nav1=48&product=100") FastEthernet: 6-Ports, 5 x 100BASE-TX-PHYs
- [AR8327 + AR8327N](http://www.qca.qualcomm.com/technology/technology.php?nav1=48&product=102 "http://www.qca.qualcomm.com/technology/technology.php?nav1=48&product=102") GigabitEthernet: 7Ports, 5x 1000Base-T-PHYs e.g. in the [WR1043ND v2](/toh/tp-link/tl-wr1043nd "toh:tp-link:tl-wr1043nd") ([Atheros AR8327N-BL1A](http://wikidevi.com/files/Atheros/specsheets/AR8327_AR8327N.pdf "http://wikidevi.com/files/Atheros/specsheets/AR8327_AR8327N.pdf"))
- [AR8328 + AR8328N](http://www.qca.qualcomm.com/technology/technology.php?nav1=48&product=101 "http://www.qca.qualcomm.com/technology/technology.php?nav1=48&product=101") GigabitEthernet: 7Ports, 5x 1000Base-T-PHYs
- Atheros AR7240 built-in switch
- Atheros AR934X built-in switch

**`Note:`** Atheros Switch-Chips with the 'N' designation include the *Hardware NAT* function.

### Broadcom

- [r37650: brcm47xx: switch to kernel 3.10.4; This uses a new switch driver. The old ADMTEK Adm6996 switch is not supported any more.](https://dev.openwrt.org/changeset/37650 "https://dev.openwrt.org/changeset/37650")
- Broadcom [BCM5325](/_media/media/datasheets/bcm5325_pinout.png "media:datasheets:bcm5325_pinout.png (490.5 KB)")

### Vitesse

- Vitesse have produced 4-port PHYs VSC8584 and VSC8574
  
  - [Upstream PHY driver for VSC8584 and VSC8574](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/drivers/net/phy/mscc.c "https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/drivers/net/phy/mscc.c")
- Vitesse have produced switch chips for 5+1 and 8+1 switches VSC7385, VSC7388, VSC7395 and VSC7398.
  
  - [Upstream DSA kernel driver for VSC7385, VSC7388, VSC7395 and VSC7398](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/drivers/net/dsa/vitesse-vsc73xx-core.c "https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/drivers/net/dsa/vitesse-vsc73xx-core.c")
- The Vitesse switch chips family were acquired by Micosemi who were then acquired by Microchip.
- Micochip will provide complete datasheets if you sign an NDA on their website

[VSC7384 datasheet](/lib/exe/fetch.php?tok=94fbff&media=https%3A%2F%2Fopenwrt.org%2F_media%2Fmedia%2Fdocs%2Fvsc7384_ds_41.pdf "https://openwrt.org/_media/media/docs/vsc7384_ds_41.pdf")

### MediaTek / Ralink

- [TC2206](http://www.mediatek.com/_en/01_products/04_pro.php?sn=1032 "http://www.mediatek.com/_en/01_products/04_pro.php?sn=1032")

### Other

- IC+ IP17xx

### Features

- Some switches contain a functionality called ***“Hardware NAT”***; support for this features has not yet been included into OpenWrt. Since the [cpu](/docs/techref/hardware/cpu "docs:techref:hardware:cpu")s used in CPE Routers are relatively slow, expect 2 to 4 times performance gain if you were to use Hardware NAT, e.g. without hardware NAT some router could achieve 400Mbit/s at full CPU load, with hardware NAT it could achieve 900Mbit/s at full CPU load. OpenWrt developer is supposed to have said, that implementing HW-NAT support would be unacceptably hacky to accomplish.
