# Horst

Horst is a small, lightweight IEEE802.11 wireless LAN analyzer with a text interface. See [README](https://github.com/br101/horst/blob/master/README "https://github.com/br101/horst/blob/master/README") and [Homepage of Horst](http://br1.einfach.org/tech/horst/ "http://br1.einfach.org/tech/horst/").

## Installation

With `opkg`:

```
opkg update
opkg install horst
```

## Usage

1. As a newcomer, please consult [wireless.overview](/docs/guide-user/network/wifi/wireless.overview "docs:guide-user:network:wifi:wireless.overview"). It is written for you!
2. If your wireless drivers support it, use either `/etc/config/wireless` or [wireless.utilities](/docs/guide-user/network/wifi/wireless-tool/wireless.utilities "docs:guide-user:network:wifi:wireless-tool:wireless.utilities") to put your WNIC into *monitor mode* then start horst on the default interface (wlan0):
   
   ```
   iwconfig wlan0 mode monitor channel X
   horst
   ```
3. Or with newer mac80211 drivers you can use the “modern” way, using ‘iw’ to add a monitor interface while you can continue to use the existing interface:
   
   ```
   iw dev wlan0 interface add mon0 type monitor
   horst -i mon0
   ```
4. To use the client/server mode you can start a server (-q without a user interface) with
   
   ```
   horst -i wlan0 -C -q
   ```
5. and connect a client with
   
   ```
   horst -c IP
   ```
   
   Only one client is allowed at a time!
