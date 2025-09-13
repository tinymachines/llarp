# Broadcom BCM53xx

This page covers the BCM47xx and BCM53xx Wireless Router/AP SoC running **ARM** CPUs.

## Limitations

Currently the following features are not supported:

- Using USB 1.1 and USB 2.0 devices at the same time may cause a crash. See [#19601](https://dev.openwrt.org/ticket/19601 "https://dev.openwrt.org/ticket/19601")
- 802.11ac wireless devices (BCM4352/BCM4360 not usable at all), except for FullMAC BCM43602 (supported by brcmfmac)
- 802.11n features on older wireless devices (BCM4331, BCM43217, BCM43227, etc.)

## See also

- See also [common Broadcom BCM47xx and BCM53xx page](/docs/techref/hardware/soc/soc.broadcom.bcm47xx "docs:techref:hardware:soc:soc.broadcom.bcm47xx") which has much more info.

## Devices

The list of related devices: [ARM](/tag/arm?do=showtag&tag=ARM "tag:arm"), [bcm47xx](/tag/bcm47xx?do=showtag&tag=bcm47xx "tag:bcm47xx"), [bcm53xx](/tag/bcm53xx?do=showtag&tag=bcm53xx "tag:bcm53xx")
