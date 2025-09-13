# JTAG Cables

JTAG stands for [Joint Test Action Group](https://en.wikipedia.org/wiki/Joint%20Test%20Action%20Group "https://en.wikipedia.org/wiki/Joint Test Action Group"), which is an [IEEE](https://en.wikipedia.org/wiki/Institute%20of%20Electrical%20and%20Electronics%20Engineers "https://en.wikipedia.org/wiki/Institute of Electrical and Electronics Engineers") work group defining an electrical interface for [integrated circuit](/docs/techref/hardware/ic "docs:techref:hardware:ic") ***testing*** and ***programming***.

- → [port.jtag](/docs/techref/hardware/port.jtag "docs:techref:hardware:port.jtag") (this article)
  
  - → [port.jtag.cables](/docs/techref/hardware/port.jtag.cables "docs:techref:hardware:port.jtag.cables") (homemade cables)
  - → [port.jtag.cable.buffered](/docs/techref/hardware/port.jtag.cable.buffered "docs:techref:hardware:port.jtag.cable.buffered")
  - → [port.jtag.cable.unbuffered](/docs/techref/hardware/port.jtag.cable.unbuffered "docs:techref:hardware:port.jtag.cable.unbuffered")
- → [port.jtag.utilization](/docs/techref/hardware/port.jtag.utilization "docs:techref:hardware:port.jtag.utilization")
  
  - → [generic.debrick](/docs/guide-user/troubleshooting/generic.debrick "docs:guide-user:troubleshooting:generic.debrick") there is content utilizing the JTAG (link to it or from it, don't leave double content!)
  - → [jtag](/toh/davolink/dv-201amr#jtag "toh:davolink:dv-201amr") again milk it for generic content

## JTAG Cables

There are several different types of cables that are popular for hooking up to JTAG headers inside consumer electronic equipment. Most of these rely on a regular PC's [Parallel port](https://en.wikipedia.org/wiki/Parallel%20port "https://en.wikipedia.org/wiki/Parallel port") to drive the JTAG signal lines. There are vendors of commercial JTAG cables that sell them at extravagant prices. For the home user or hobbyist, however, a better choice is usually to construct a cable at home from commonly available parts.

![FIXME](/lib/images/smileys/fixme.svg): In the BIOS of your PC, you may need to set Parallel Port into ECP, EPP or both mode. Read on: [IEEE 1284 modes](https://en.wikipedia.org/wiki/IEEE_1284#IEEE_1284_modes "https://en.wikipedia.org/wiki/IEEE_1284#IEEE_1284_modes").

For SOHO routers and other network devices there are two popular cables: the buffered Wiggler-type cable and the unbuffered-type cable. The single largest segment of homemade JTAG cable users is probably satellite television receiver owners. A search on ebay for JTAG will turn up many people selling JTAG cables for use with satellite TV receivers. The JTAG interface is pretty much standardized but the difference in pinouts for different equipment can vary widely. The cables for sale on ebay could probably be easily made to work with SOHO routers, and vice versa, but this page will not cover them. I've never bought or used one so I don't know exactly how they are constructed.

There are other types of JTAG cables as well. Macraigor sells the Raven cable which is even more expensive than the Wiggler. Lately there are also cables that use a USB interface on the PC side instead of the 25-pin parallel port connector. I have not had any experience with these. There are still other JTAG solutions out there that are faster and more sophisticated than the interfaces built by hobbyists, but these are generally not cost-effective for someone who just wants to re-flash a single flash chip. A complete JTAG test rig is used in industry for much more than programming flash chips. Some of these industrial-strength setups can cost thousands and thousands of dollars.

- [Cheapest ready-made parallel JTAG adapter to buy in the USA…](http://microcontrollershop.com/product_info.php?products_id=589 "http://microcontrollershop.com/product_info.php?products_id=589")
- [Cheapest ready-made USB JTAG adapter to buy in the USA…](http://microcontrollershop.com/product_info.php?products_id=3124 "http://microcontrollershop.com/product_info.php?products_id=3124") ![FIXME](/lib/images/smileys/fixme.svg): Broken link, Please fix
- [Hookups to defeat pinout mismatches…](http://shop1.frys.com/product/1599820 "http://shop1.frys.com/product/1599820")

Driving a JTAG interface through the parallel port on a PC is a slow proposition. *Really* slow. This is due more to the nature of the parallel port connection than an inherent limit of the JTAG specification. In fact, the JTAG spec allows for up to 25 million bits-per-second transfers. With a parallel port cable, however, you will be lucky to achieve more than about 400,000 bits-per-second. With these speeds it is not unusual to spend 25 minutes writing a mere 256 KB of data over a JTAG cable. Programming an entire 2 MB or 4 MB flash chip can literally take hours. It's worth it, however, if you have an otherwise worthless device on your hands and JTAG is the only way to revive it. The Macraigor Raven and USB JTAG adapters are much faster, but there are no known schematic to implement it.

There are many variants of the LPT-to-JTAG cables. All of them are different in the LPT pins -to- JTAG pins mapping and may be in the buffered and unbuffered variant.
