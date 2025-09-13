# wpa\_supplicant

wpa\_supplicant is a [WPA Supplicant](https://en.wikipedia.org/wiki/wpa%20supplicant "https://en.wikipedia.org/wiki/wpa supplicant") for Linux, BSD, Mac OS X, and Windows with support for WPA and WPA2 (IEEE 802.11i / RSN). It is suitable for both desktop/laptop computers and embedded systems. Supplicant is the IEEE 802.1X/WPA component that is used in the client stations. It implements key negotiation with a WPA Authenticator and it controls the roaming and IEEE 802.11 authentication/association of the wlan driver.

wpa\_supplicant is designed to be a “daemon” program that runs in the background and acts as the backend component controlling the wireless connection. wpa\_supplicant supports separate frontend programs and a text-based frontend (wpa\_cli) and a GUI (wpa\_gui) are included with wpa\_supplicant.

wpa\_supplicant uses a flexible build configuration that can be used to select which features are included. This allows minimal code size (from ca. 50 kB binary for WPA/WPA2-Personal and 130 kB binary for WPA/WPA2-Enterprise without debugging code to 450 kB with most features and full debugging support; these example sizes are from a build for x86 target).

## Supported WPA/IEEE 802.11i features

- WPA-PSK (“WPA-Personal”)
- WPA with EAP (e.g., with RADIUS authentication server) (“WPA-Enterprise”)
- key management for CCMP, TKIP, WEP104, WEP40
- WPA and full IEEE 802.11i/RSN/WPA2
- RSN: PMKSA caching, pre-authentication
- IEEE 802.11r
- IEEE 802.11w
- [Wi-Fi Protected Setup (WPS)](/docs/guide-user/network/wifi/basic#wps_options "docs:guide-user:network:wifi:basic")

## Example

wpa\_supplicant [config example](http://w1.fi/cgit/hostap/plain/wpa_supplicant/wpa_supplicant.conf "http://w1.fi/cgit/hostap/plain/wpa_supplicant/wpa_supplicant.conf")

## Link

[http://w1.fi/](http://w1.fi/ "http://w1.fi/") home of wpa\_supplicant and hostapd
