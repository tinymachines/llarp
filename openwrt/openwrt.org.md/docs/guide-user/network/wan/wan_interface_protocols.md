# WAN interface protocols

## Protocol "ppp" (PPP over Modem)

![:!:](/lib/images/smileys/exclaim.svg) The package `ppp` must be installed to use PPP.

Name Type Required Default Description `device` file path yes *(none)* Modem device node `username` string no(?) *(none)* Username for PAP/CHAP authentication `password` string no(?) *(none)* Password for PAP/CHAP authentication `connect` file path no *(none)* Path to custom PPP connect script `disconnect` file path no *(none)* Path to custom PPP disconnect script `keepalive` number no *(none)* Number of unanswered echo requests before considering the peer dead. The interval between echo requests is 5 seconds. `demand` number no *(none)* Number of seconds to wait before closing the connection due to inactivity `defaultroute` boolean no `1` Replace existing default route on PPP connect `peerdns` boolean no `1` Use peer-assigned DNS server(s) `dns` list of ip addresses no *(none)* Override peer-assigned DNS server(s) `ipv6` \[0,1,auto] no `auto` Enable IPv6 on the PPP link  
0: IPv6 disabled  
1: IPv6 enabled  
auto: IPv6 enabled. DHCPv6 client enabled. `pppd_options` string no *(none)* Additional command line arguments to pass to the pppd daemon

PPP-based protocols negotiate IPv4 and IPv6 support when the link is established. These protocols require `option ipv6` to be specified in the parent `config interface wan` section if IPv6 support is required. Further configuration can be given in the alias `config interface wan6` section – see [ipv6](/docs/guide-user/network/ipv6/start "docs:guide-user:network:ipv6:start").

## Protocol "pppoe" (PPP over Ethernet)

![:!:](/lib/images/smileys/exclaim.svg) The packages `ppp`, `kmod-pppoe` and `ppp-mod-pppoe` must be installed to use PPPoE.

```
opkg update
opkg install ppp kmod-pppoe ppp-mod-pppoe
```

Name Type Required Default `username` string no *(none)* Username for PAP/CHAP authentication `password` string no *(none)* Password for PAP/CHAP authentication `ac` string no *(none)* Specifies the Access Concentrator to connect to. If unset, `pppd` uses the first discovered one `service` string no *(none)* Specifies the Service Name to connect to, If unset, `pppd` uses the first discovered one `host_uniq` string no *(none)* Specifies the PPPoE Host-Uniq tag (hexstring) to connect with. If unset, it uses the `pppd` process ID `connect` file path no *(none)* Path to custom PPP connect script `disconnect` file path no *(none)* Path to custom PPP disconnect script `keepalive` 2 numbers no `5 1` The numbers must be separated by a space. First number is “we assume the connection is down after this number of pings failed” (**ppp**'s **lcp-echo-failure** option). Second number is for “seconds between each ping” (**ppp**'s **lcp-echo-interval** option). `keepalive_adaptive` boolean no `1` Suppress LCP echo requests if traffic was received [more info](https://github.com/openwrt/openwrt/commit/bc356cef8245214321c6b944bb8ebe2e72542387 "https://github.com/openwrt/openwrt/commit/bc356cef8245214321c6b944bb8ebe2e72542387") `demand` number no *(none)* Number of seconds to wait before closing the connection due to inactivity `defaultroute` boolean no `1` Replace existing default route on PPP connect `peerdns` boolean no `1` Use peer-assigned DNS server(s) `dns` list of ip addresses no *(none)* Override peer-assigned DNS server(s) `ipv6` \[0,1,auto] no `auto` Enable IPv6 on the PPP link. See Protocol “ppp” above `padi_attempts` number no *(none)* Number of discovery attempts [more info](https://github.com/ppp-project/ppp/commit/8e77984ac5d7acbe68b2b2f590abd17564c9730d "https://github.com/ppp-project/ppp/commit/8e77984ac5d7acbe68b2b2f590abd17564c9730d") `padi_timeout` number no *(none)* Initial timeout for discovery packets in seconds [more info](https://github.com/ppp-project/ppp/commit/8e77984ac5d7acbe68b2b2f590abd17564c9730d "https://github.com/ppp-project/ppp/commit/8e77984ac5d7acbe68b2b2f590abd17564c9730d") `pppd_options` string no *(none)* Additional command line arguments to pass to the pppd daemon e.g `debug noipv6`

## Protocol "pppoa" (PPP over ATM AAL5)

![:!:](/lib/images/smileys/exclaim.svg) The package `ppp-mod-pppoa` must be installed to use PPPoA.

Name Type Required Default Description `vci` number no `35` PPPoA VCI `vpi` number no `8` PPPoA VPI `atmdev` number no `0` Specifies the ATM adapter number starting with 0. Most systems only have one ATM device and do not need this option `encaps` string no `llc` PPPoA encapsulation mode: 'llc' (LLC) or 'vc' (VC) `username` string no(?) *(none)* Username for PAP/CHAP authentication `password` string no(?) *(none)* Password for PAP/CHAP authentication `connect` file path no *(none)* Path to custom PPP connect script `disconnect` file path no *(none)* Path to custom PPP disconnect script `keepalive` number no *(none)* Number of connection failures before reconnect `demand` number no *(none)* Number of seconds to wait before closing the connection due to inactivity `defaultroute` boolean no `1` Replace existing default route on PPP connect `peerdns` boolean no `1` Use peer-assigned DNS server(s) `dns` list of ip addresses no *(none)* Override peer-assigned DNS server(s) `ipv6` \[0,1,auto] no `auto` Enable IPv6 on the PPP link. See Protocol “ppp” above. `pppd_options` string no *(none)* Additional command line arguments to pass to the pppd daemon

## Protocol "3g" (PPP over EV-DO, CDMA, UMTS or GPRS)

![:!:](/lib/images/smileys/exclaim.svg) The package `comgt` must be installed to use 3G.

Name Type Required Default Description `device` file path yes *(none)* Modem device node `service` string yes `umts` 3G service type: `cdma`/`evdo`, `umts`/`umts_only`/`gprs_only` (....\_only options limited to Novatel &amp; Option cards and dongles) `apn` string yes *(none)* Used APN `pincode` number no *(none)* PIN code to unlock SIM card `dialnumber` string no \*99\*\*\*1# Modem dial string e.g. \*99# `maxwait` number no `0` Number of seconds to wait for modem to become ready `username` string no(?) *(none)* Username for PAP/CHAP authentication `password` string no(?) *(none)* Password for PAP/CHAP authentication `keepalive` number no *(none)* Number of connection failures before reconnect `demand` number no *(none)* Number of seconds to wait before closing the connection due to inactivity `defaultroute` boolean no `1` Replace existing default route on PPP connect `peerdns` boolean no `1` Use peer-assigned DNS server(s) `dns` list of ip addresses no *(none)* Override peer-assigned DNS server(s) `ipv6` \[0,1,auto] no `auto` Enable IPv6 on the PPP link. See Protocol “ppp” above. `delay` number no 0 Seconds to wait before trying to interact with the modem (some ZTE modems require up to 30 s.)

## Protocol "qmi" (USB modems using QMI protocol)

![:!:](/lib/images/smileys/exclaim.svg) The package `uqmi` must be installed to use QMI.

Name Type Required Default Description `device` file path yes *(none)* QMI device node, typically /dev/cdc-wdm0 `apn` string yes *(none)* Used APN `pincode` number no *(none)* PIN code to unlock SIM card `username` string no *(none)* Username for PAP/CHAP authentication `password` string no *(none)* Password for PAP/CHAP authentication `auth` string no *(none)* Authentication type: pap, chap, both, none `modes` string no *(modem default)* Allowed network modes, comma separated list of: all, lte, umts, gsm, cdma, td-scdma `delay` number no 0 Seconds to wait before trying to interact with the modem (some ZTE modems require up to 30 s.)

## Protocol "ncm" (USB modems using NCM protocol)

![:!:](/lib/images/smileys/exclaim.svg) The package `comgt-ncm` + modem specific driver must be installed to use NCM.

Name Type Required Default Description `device` file path yes *(none)* NCM device node, typically /dev/cdc-wdm0 or /dev/ttyUSB# `apn` string yes *(none)* Used APN `pincode` number no *(none)* PIN code to unlock SIM card `username` string no *(none)* Username for PAP/CHAP authentication `password` string no *(none)* Password for PAP/CHAP authentication `auth` string no *(none)* Authentication type: pap, chap, both, none `mode` string no *(modem default)* Used network mode, not every device support every mode: preferlte, preferumts, lte, umts, gsm, auto `pdptype` string no `IPV4V6` Used IP-stack mode, `IP` (for IPv4), `IPV6` (for IPv6) or `IPV4V6` (for dual-stack) (Designated Driver #46844 and later) `delay` number no 0 Seconds to wait before trying to interact with the modem (some modems require up to 30 s.)

## Protocol "wwan" (USB modems autodetecting above protocols)

![:!:](/lib/images/smileys/exclaim.svg) The package `wwan` must be installed to use this feature. The “wwan” protocol detects the right protocol (3G/QMI/NCM/MBIM) for the USB Modem model and passes the configuration to the protocol.

Name Type Required Default Description `apn` string yes *(none)* Used APN `auth` string no *(none)* Authentication type: pap, chap, both, none `username` string no *(none)* Username for PAP/CHAP authentication `password` string no *(none)* Password for PAP/CHAP authentication `pincode` number no *(none)* PIN code to unlock SIM card `modes` string no *(modem default)* Allowed network modes, comma separated list of: all, lte, umts, gsm, cdma, td-scdma `delay` number no 0 Seconds to wait before trying to interact with the modem (some ZTE modems require up to 30 s.)

## Examples

Below are a few examples for special, non-standard interface configurations.

### PPPoE internet connection

```
config interface 'wan'
        option proto     'pppoe'
        option device    'eth0'
        option username  'user'
        option password  'pass'
        option keepalive '4 5'
```

### PPPoA ADSL internet connection

```
config adsl-device 'adsl'
        option fwannex 'a'
        option annex 'a'
 
config interface 'wan'
        option proto 'pppoa'
        option username 'jbloggs@plusdsl.net'
        option password 'XXXXXXXXX'
        option vpi '0'
        option vci '38'
        option encaps 'vc'
```
