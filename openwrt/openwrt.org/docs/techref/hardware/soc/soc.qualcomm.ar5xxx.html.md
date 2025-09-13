# Qualcomm Atheros AR5xxx (atheros)

[Qualcomm Atheros](https://en.wikipedia.org/wiki/Qualcomm%20Atheros "https://en.wikipedia.org/wiki/Qualcomm Atheros")

- [Atheros chipsets based wireless 802.11a/b/g devices](http://atheros.rapla.net/ "http://atheros.rapla.net/")
- [https://wikidevi.wi-cat.ru/Atheros](https://wikidevi.wi-cat.ru/Atheros "https://wikidevi.wi-cat.ru/Atheros")
- [https://wikidevi.wi-cat.ru/Qualcomm\_Atheros](https://wikidevi.wi-cat.ru/Qualcomm_Atheros "https://wikidevi.wi-cat.ru/Qualcomm_Atheros")

## Atheros

Boards based on the old Atheros AR231x/AR5312 CPUs. The AR531x/231x is a platform by Atheros, which is used for dual-band and single-band 108Mb/s routers and APs. It is also referred as a *WiSoC - Wireless System-on-a-Chip*, and the radio inside often refereed as *RoC - Radio-on-a-Chip* as it is contained on a distinct chip.

1\. AR5001 generation (802.11a only)

- [AR5001AP](http://www.iet.unipi.it/f.giannetti/documenti/wlan/Data/refer/tecno/chip/APBulletin.pdf "http://www.iet.unipi.it/f.giannetti/documenti/wlan/Data/refer/tecno/chip/APBulletin.pdf") (AR5311 CPU + AR5111 5GHz RoC)

2\. [AR5002](http://mgvs.org/public/midge/datasheet/AR5002+spec+sheet.pdf "http://mgvs.org/public/midge/datasheet/AR5002+spec+sheet.pdf") generation (first dual-band designs)

- AR5002AP-A (AR2312 CPU + AR5122 5GHz RoC)
- [AR5002AP-G](http://www.atheros.com/pt/AR5002AP-GBulletin.htm "http://www.atheros.com/pt/AR5002AP-GBulletin.htm") (AR2312 CPU + AR2112 2.4GHz RoC)
- [AR5002AP-X](http://www.atheros.com/pt/AR5002AP-XBulletin.htm "http://www.atheros.com/pt/AR5002AP-XBulletin.htm") (AR2312 CPU + AR5112 2.4/5GHz RoC)
- [AR5002AP-2X](http://www.atheros.com/pt/AR5002AP-2XBulletin.htm "http://www.atheros.com/pt/AR5002AP-2XBulletin.htm") (AR5312 CPU + AR5112 2.4/5GHz RoC + AR2112 2.4GHz RoC)

3-4. AR5003 and AR5004 generation (Super-AG technology) *The AR5003 got merged into the AR5004. The new WiSoCs are/were in production, but they were not announced.*

- AR2313
- AR5213
- AR2314

5\. AR5005 generation (MIMO technology, onboard AES engine, serial flash)

- [AR5005VA](http://www.atheros.com/pt/AR5005VA.htm "http://www.atheros.com/pt/AR5005VA.htm") (AR5513 CPU + AR5112 RoC)
- [AR5005VL](http://www.atheros.com/pt/AR5005VL.htm "http://www.atheros.com/pt/AR5005VL.htm") (AR5513 CPU + AR5112 RoC)

6\. AR5006 generation (single-chip solutions)

- [AR5006AP-G](http://www.atheros.com/pt/AR5006AP-G.htm "http://www.atheros.com/pt/AR5006AP-G.htm") (AR2315) - 54Mbps only
- [AR5006AP-GS](http://www.atheros.com/pt/AR5006AP-GS.htm "http://www.atheros.com/pt/AR5006AP-GS.htm") (AR2316)
- AR5315

7\. AR5007 generation (radical decrease of Bill of materials)

- [AR5007AP-G](http://www.atheros.com/pt/AR5007AP-G.htm "http://www.atheros.com/pt/AR5007AP-G.htm") (AR2317)

## Devices

- Bufallo WER-AM54G54 (AR5002AP-2X)
- D-Link [DI-524](http://www.dlink.com/products/?sec=0&pid=316 "http://www.dlink.com/products/?sec=0&pid=316"), at least HW rev C1 (AR2313), but it only has 8MB RAM and 1MB ROM.
- D-Link [DWL-2210AP](http://support.dlink.com/products/view.asp?productid=DWL-2210AP "http://support.dlink.com/products/view.asp?productid=DWL-2210AP") (AR2313)
- D-Link [DWL-2100AP](http://www.dlink.com/products/?pid=292 "http://www.dlink.com/products/?pid=292") (AR5002AP-G : core AR2312@180/240MHz, radio AR2112)
- D-Link [DWL-7100AP](http://www.dlink.com/products/?pid=304 "http://www.dlink.com/products/?pid=304") (AR5002AP-2X)
- D-Link DWL-774 (AR5002AP-2X) (discontinued)
- LevelOne WBR-3405TX : AR2313A and Marvell 88E6060 switch
- Micronet SP918GL [Product Link](http://www.micronet.info/up_images/english/6/462/SP918GL_Manual.pdf "http://www.micronet.info/up_images/english/6/462/SP918GL_Manual.pdf") (AR2313A) seems to be identical with D-Link DWL-2210AP
- Meraki [Mini](http://www.meraki.net/mini.html "http://www.meraki.net/mini.html") (AR2315) - source available for [Meraki's own Linux port](http://www.meraki.net/linux "http://www.meraki.net/linux")
- MicraDigital/Belkin F5D7230 (ver.1020ec) (AR2315A)
- Netgear [WGR614](http://www.seattlewireless.net/index.cgi/NetgearWGR614 "http://www.seattlewireless.net/index.cgi/NetgearWGR614")v3.
- Netgear [WGT624](https://oldwiki.archive.openwrt.org/oldwiki/openwrtdocs/hardware/netgear/wgt624 "https://oldwiki.archive.openwrt.org/oldwiki/openwrtdocs/hardware/netgear/wgt624") [Product link](http://www.netgear.com/products/details/WGT624.php "http://www.netgear.com/products/details/WGT624.php") (AR5002AP-G) (v2 AR5001AP)
- Netgear [WG102](http://www.seattlewireless.net/index.cgi/NetgearWG102 "http://www.seattlewireless.net/index.cgi/NetgearWG102") (AR2313)
- Senao NL-5354 AP1 Aries2 (AR5002AP-2X)
- Senao NL-3054 AP3 Aries2 (AR2313)
- Siemens [SE551](https://oldwiki.archive.openwrt.org/oldwiki/openwrtdocs/hardware/siemens/se551 "https://oldwiki.archive.openwrt.org/oldwiki/openwrtdocs/hardware/siemens/se551") (AR2316)
- Wistron [CA8-4](https://oldwiki.archive.openwrt.org/toh/wistron/ca8-4 "https://oldwiki.archive.openwrt.org/toh/wistron/ca8-4") aka Ovislink [WLA-5000AP](http://www.ovislink.com.tw/WLA5000AP.htm "http://www.ovislink.com.tw/WLA5000AP.htm"), LinkPro WLT-108AAP, Diswire CAP2/5 (AR5002AP-X)
- Wistron CR8-2 aka LinkPro WLT-108AAR (AR5002AP-2X)
- Smc WEBT-G aka Philips SNR6500 aka Siemens Wlan Repeater 108 (AR2316)
- X-Micro XWL-11GRAG : AR5002AP-G (AR2312A+AR2112) and Marvell 88E6060
