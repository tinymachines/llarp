# ar71xx

ar71xx is deprecated and has been [marked as source only](https://git.openwrt.org/016d1eb1f9c14c50dbd0b5461fc22c1f4ef6e30a "https://git.openwrt.org/016d1eb1f9c14c50dbd0b5461fc22c1f4ef6e30a") in June 2019. The replacement target for the same hardware is DTS based [ath79](/docs/techref/targets/ath79 "docs:techref:targets:ath79"). See also [switch default target from ar71xx to ath79](https://git.openwrt.org/750a57b8364c2ef9e021b9428725585e47864163 "https://git.openwrt.org/750a57b8364c2ef9e021b9428725585e47864163"). In August 2020 the [ar71xx target has finally been dropped](https://git.openwrt.org/4e4ee4649553ab536225060a27fc320bf54e458c "https://git.openwrt.org/4e4ee4649553ab536225060a27fc320bf54e458c").

- [Latest git commits for this target](https://git.openwrt.org/?p=openwrt%2Fopenwrt.git&a=search&h=HEAD&st=commit&s=ar71xx%3A "https://git.openwrt.org/?p=openwrt/openwrt.git&a=search&h=HEAD&st=commit&s=ar71xx:")

## ar71xx snapshot images

Buildbots stopped building ar71xx snapshot images on 17.06.2019 as a consequence of the *source-only* status. The remaining, old and outdated ar71xx snapshot images have been subsequently removed later.

## ar71xx-ath79 transition

Release Target(s) 18.06.x (and earlier) ar71xx only 19.07.x ar71xx + ath79 21.02.x (and later) ath79 only

## How to use your ar71xx device with OpenWrt

**For ar71xx/ath79 devices with 4MB flash and/or 32MB RAM see also [4/32 warning](/supported_devices/432_warning "supported_devices:432_warning") and [OpenWrt on 4/32 devices](/supported_devices/openwrt_on_432_devices "supported_devices:openwrt_on_432_devices")**

**For ar71xx/ath79 devices with 8MB flash and/or 64MB RAM see also [8/64 warning](/supported_devices/864_warning "supported_devices:864_warning") and [OpenWrt on 8/64 devices](/supported_devices/openwrt_on_864_devices "supported_devices:openwrt_on_864_devices")**

- Use [ath79](/docs/techref/targets/ath79 "docs:techref:targets:ath79") instead, *if available*
- If ath79 is not available for your device, then [port it to ath79](https://forum.openwrt.org/t/porting-guide-ar71xx-to-ath79/13013 "https://forum.openwrt.org/t/porting-guide-ar71xx-to-ath79/13013")
- If you are not able to port it yourself, find someone who is able to do it.  
  Support the developer by providing the needed information for porting and by testing development builds.
- If all that does not work, nail your device on the wall of your living room (as souvenir), use it as paperweight, or just dump it into the appropriate recycling channels.

## Maintainers and contributors

[Realname](/docs/techref/targets/ar71xx?datasrt=realname "Sort by this column")[Nickname](/docs/techref/targets/ar71xx?datasrt=nickname "Sort by this column")[Status](/docs/techref/targets/ar71xx?datasrt=status "Sort by this column")Alexander Couzens[lynxis](/developers/lynxis "developers:lynxis")activeAlexander Couzens[lynxis](/developers/lynxis "developers:lynxis")activeGabor Juhos[juhosg](/developers/juhosg "developers:juhosg")activeGabor Juhos[juhosg](/developers/juhosg "developers:juhosg")activeJonas Gorski[jogo](/developers/jogo "developers:jogo")activeJonas Gorski[jogo](/developers/jogo "developers:jogo")activeMatthias Schiffer[neoraider](/developers/neoraider "developers:neoraider")activeMatthias Schiffer[neocturne](/developers/neocturne "developers:neocturne")activeMatthias Schiffer[neocturne](/developers/neocturne "developers:neocturne")activePiotr Dymacz[pepe2k](/developers/pepe2k "developers:pepe2k")activePiotr Dymacz[pepe2k](/developers/pepe2k "developers:pepe2k")active

## Devices with this target

**Note:** This table shows also devices with target ar71xx-ath7. See [ar71xx-ath79](/docs/techref/targets/ar71xx-ath79 "docs:techref:targets:ar71xx-ath79") and [ath79](/docs/techref/targets/ath79 "docs:techref:targets:ath79") for more information.

Show devices with this target

Hide devices with this target

[Filter: Target](#folded_451fe4546c5947369f285720abfa8565_1)

- [ar71xx(281)](/docs/techref/targets/ar71xx?dataflt%5B0%5D=target_%3Dar71xx "Show pages matching 'ar71xx'")
- [ar71xx-ath79(31)](/docs/techref/targets/ar71xx?dataflt%5B0%5D=target_%3Dar71xx-ath79 "Show pages matching 'ar71xx-ath79'")

[Filter: Subtarget](#folded_451fe4546c5947369f285720abfa8565_2)

- [(3)](/docs/techref/targets/ar71xx?dataflt%5B0%5D=subtarget_%3D "Show pages matching ''")
- [QCA9531(3)](/docs/techref/targets/ar71xx?dataflt%5B0%5D=subtarget_%3DQCA9531 "Show pages matching 'QCA9531'")
- [QCA9557(1)](/docs/techref/targets/ar71xx?dataflt%5B0%5D=subtarget_%3DQCA9557 "Show pages matching 'QCA9557'")
- [generic(186)](/docs/techref/targets/ar71xx?dataflt%5B0%5D=subtarget_%3Dgeneric "Show pages matching 'generic'")
- [mikrotik(30)](/docs/techref/targets/ar71xx?dataflt%5B0%5D=subtarget_%3Dmikrotik "Show pages matching 'mikrotik'")
- [nand(1)](/docs/techref/targets/ar71xx?dataflt%5B0%5D=subtarget_%3Dnand "Show pages matching 'nand'")
- [tiny(87)](/docs/techref/targets/ar71xx?dataflt%5B0%5D=subtarget_%3Dtiny "Show pages matching 'tiny'")
- [¿(1)](/docs/techref/targets/ar71xx?dataflt%5B0%5D=subtarget_%3D%C2%BF "Show pages matching '¿'")
