# RSN preauthentication

First go read:

- [hostapd RSN preauthentication documentation](https://wireless.wiki.kernel.org/en/users/documentation/hostapd#ieee_80211irsnwpa2_pre-authentication "https://wireless.wiki.kernel.org/en/users/documentation/hostapd#ieee_80211irsnwpa2_pre-authentication")
- [wpa\_supplicant RSN preauthentication documentation](https://wireless.wiki.kernel.org/en/users/documentation/wpa_supplicant#rsn_preauthentication "https://wireless.wiki.kernel.org/en/users/documentation/wpa_supplicant#rsn_preauthentication")

Basics:

- More than one AP
- All APs on the same SSID
- All APs on the same network
- Radius server installed available and on the same network

### Configuring OpenWrt for RSN preauthentication

For the wireless configuration here is an example on /etc/config/wireless :

```
config wifi-device  radio0
        option type     mac80211
        option channel  6
        option macaddr  00:03:7f:47:20:a5
        option hwmode   11g
        option htmode   HT20
        list ht_capab   LDPC
        list ht_capab   SHORT-GI-20
        list ht_capab   SHORT-GI-40
        list ht_capab   TX-STBC
        list ht_capab   RX-STBC1
        list ht_capab   DSSS_CCK-40

config wifi-iface
        option device           radio0
        option network          lan
        option mode             ap
        option ssid             mcgrof-ap136-01
        option encryption       wpa2+ccmp
        option server           192.168.4.149
        option port             1812
        option key              testing123
        option rsn_preauth      1
        option wpa_group_rekey  2000
```
