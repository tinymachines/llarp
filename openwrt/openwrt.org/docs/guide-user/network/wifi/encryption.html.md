# Configure Wi-Fi encryption

OpenWrt supports all major [Wi-Fi\_Alliance](https://en.wikipedia.org/wiki/Wi-Fi_Alliance "https://en.wikipedia.org/wiki/Wi-Fi_Alliance") protocols including [Wi-Fi\_Protected\_Access](https://en.wikipedia.org/wiki/Wi-Fi_Protected_Access "https://en.wikipedia.org/wiki/Wi-Fi_Protected_Access") (WPA), the primary method of securing access to Wi-Fi.

## Encryption types

Support for the latest WPA standards is dependent on your devices hardware and related Wi-Fi drivers.

- WPA3: The current recommended version. Supports many new cryptographic techniques and has strong mitigations built-in for KRACK and other attacks.
- WPA2: Use if you have devices (STAs) that do not support WPA3. Enable this with KRACK mitigation, and specify PSK2+AES mode if possible.
- WPA1: Deprecated, insecure, and should not be used.
- WEP: Deprecated, insecure, and should not be used.

Others include mixed and enterprise versions of WPA2 and WPA3, OWE, and OWE transition. For a full list of supported encryption types, see: [encryption\_modes](/docs/guide-user/network/wifi/basic#encryption_modes "docs:guide-user:network:wifi:basic").

The configured encryption protocol is defined per network in the `wifi-iface` sections of the wireless configuration.

This can be configured in [LuCI](/doc/howto/luci "doc:howto:luci") under Network → Wireless → click edit on each radio.

### Broadcom proprietary Wi-Fi

For Broadcom wireless chips use a proprietary driver that is generally not well supported in upstream Linux kernel. However it does work well enough for some targets and most use the newer mac80211 system.

### Atheros and generic mac80211 Wi-Fi

For Atheros and mac80211 supported wireless chips, the *wpad*, *hostapd* or *wpa\_supplicant* package is required.

The table below outlines the features supported by the packages and since which OpenWrt version they're available.

Package AP support Client support WPA Enterprise OpenWrt Version wpad yes yes yes 10.03+ wpad-mini **(recommended)** yes yes no 10.03+ hostapd yes no yes 7.06+ hostapd-mini yes no no 8.09+ wpa-supplicant no yes yes 7.06+ wpa-supplicant-mini no yes no 8.09+

If not installed yet, choose the appropriate package for the desired configuration.

```
opkg update
opkg install wpad-mini
```

for x86 and ath10k

```
opkg update
opkg wpad-openssl
```

### Configure WPA (PSK)

Configure WPA (PSK) encryption using UCI.

```
uci set wireless.@wifi-iface[0].encryption=psk
uci set wireless.@wifi-iface[0].key="your_password"
uci commit wireless
wifi
```

![:!:](/lib/images/smileys/exclaim.svg) The length must be between 8 and 63 characters. If the key length is 64 characters, it is treated as hex encoded.

### Configure WPA2 (PSK)

Configure WPA2 (PSK) encryption using UCI.

```
uci set wireless.@wifi-iface[0].encryption=psk2
uci set wireless.@wifi-iface[0].key="your_password"
uci commit wireless
wifi
```

![:!:](/lib/images/smileys/exclaim.svg) The length must be between 8 and 63 characters. If the key length is 64 characters, it is treated as hex encoded.

### Configure WPA2 Enterprise (EAP-TLS with external RADIUS server)

![:!:](/lib/images/smileys/exclaim.svg) The default `-mini` packages for Atheros hardware will not work with Enterprise mode. (See the [table above](#atherosandgenericmac80211wifi "docs:guide-user:network:wifi:encryption ↵").)

The example below defines WPA2 Enterprise encryption in AP mode with authentication against an external RADIUS server at 192.168.1.200, port 1812.

```
uci set wireless.@wifi-iface[0].encryption=wpa2
uci set wireless.@wifi-iface[0].key="shared_secret"
uci set wireless.@wifi-iface[0].server=192.168.1.200
uci set wireless.@wifi-iface[0].port=1812
uci commit wireless
wifi
```

### Configure WPA2 Enterprise Client, PEAP-GTC using One Time Password (OTP)

![:!:](/lib/images/smileys/exclaim.svg) The default `-mini` packages for Atheros hardware will not work with Enterprise mode. (See the [table above](#atherosandgenericmac80211wifi "docs:guide-user:network:wifi:encryption ↵").)

- Enter the following:

```
uci set wireless.@wifi-iface[0].encryption=wpa2
uci set wireless.@wifi-iface[0].mode="sta"
uci set wireless.@wifi-iface[0].ssid="SET_AS_NEEDED"
uci set wireless.@wifi-iface[0].encryption=wpa2+ccmp
uci set wireless.@wifi-iface[0].eap_type=peap
uci set wireless.@wifi-iface[0].auth=gtc
uci set wireless.@wifi-iface[0].identity="SET_AS_NEEDED"
uci commit wireless
wifi
```

- Modify the generated wpa\_supplicant.conf file in the /var/run folder to remove the *password=“”* line using your favorite editor.
- Enter the following:

```
wpa_cli -p /var/run/wpa_supplicant-wlan0
>status
```

- note the id of your interface (usually 0 in single interface systems)
- Enter the following at the wpa\_cli prompt

```
>reconfigure
>reassociate
```

- When prompted for you OTP PIN enter the following at the wpa\_cli prompt (if necessary replace the *0* with your desired interface id):

```
>otp 0 YOUR_PASSWORD_HERE
```

## WEP encryption (NOT recommended)

Do not use. This deprecated technology can be cracked in seconds with modern hardware. However some notes on how this works is below.

The format for the WEP key for the key1 option is HEX.

If you wish to use raw hex keys then you can skip to the UCI commands paragraph below. Raw hex keys have 10 hex digits (`0`..`9`, `a`..`f`) for 64-bit WEP keys and 26 hex digits for 128-bit WEP keys.

If you do not wish to use raw hex keys then follow the instructions below.

- The length of a 64bit WEP key must be exact 5 characters
- The length of a 128bit WEP key must be exact 13 characters
- Allowed characters are letters (upper and lower case) and numbers

Generate a 64bit WEP key:

```
# echo -n 'awerf' | hexdump -e '5/1 "%02x" "\n"'
6177657266
```

Generate a 128bit WEP key:

```
# echo -n 'xdhdkkewioddd' | hexdump -e '13/1 "%02x" "\n"'
786468646b6b6577696f646464
```

Now use UCI to configure WEP encryption with the hex key you just generated.

```
uci set wireless.@wifi-iface[0].encryption=wep
uci set wireless.@wifi-iface[0].key1="786468646b6b6577696f646464"
uci set wireless.@wifi-iface[0].key=1
uci commit wireless
wifi
```

You can configure up to four WEP keys.
