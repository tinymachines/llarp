# Travelmate, a connection manager for travel routers

## Description

If you’re taking your laptop, tablet, or phone on an upcoming vacation or business trip, you’ll want to connect with friends or complete work on the go. But many hotels don’t have a secure wireless network setup or limit you to using a single device at a time.

Travelmate lets you use a small “travel router” to connect all of your devices at once while having total control over your own personal wireless network.

Travelmate runs on OpenWrt, and provides an “uplink” to the hotel’s wireless access point/hotspot. Travelmate then becomes the Access Point (AP) for you and your companions, providing secure access to the internet. See the [Installation and Usage](/docs/guide-user/network/wifi/wifiextenders/travelmate#installation_and_usage "docs:guide-user:network:wifi:wifiextenders:travelmate") section below.

Travelmate manages all the network settings, firewall settings, connections to a hotel network, etc. and automatically (re)connnects to configured APs/hotspots as they become available.

*Note: This document was created from the original README at the Github repo: [https://github.com/openwrt/packages/blob/master/net/travelmate/files/README.md](https://github.com/openwrt/packages/blob/master/net/travelmate/files/README.md "https://github.com/openwrt/packages/blob/master/net/travelmate/files/README.md")*

## Main Benefits and Features

- Easy setup from LuCI web interface with **Interface Wizard** and **Wireless Station manager**
- Display a QR code to transfer the wireless credentials to your mobile devices
- Fast uplink connections
- Supports routers with multiple radios in any order
- Supports all kinds of uplinks, including hidden and enterprise uplinks. (WEP-based uplinks are no longer supported)
- Continuously checks the existing uplink quality, e.g. for conditional uplink (dis)connections
- Automatically add open uplinks to your wireless config, e.g. hotel captive portals
- Captive portal detection with a ‘heartbeat’ function to keep the uplink connection up and running
- Captive portal hook for auto-login configured via uci/LuCI. Use an external script for captive portal auto-logins (see example below)
- VPN hook supports ‘wireguard’ or ‘openvpn’ client setups to handle VPN (re)connections automatically
- Email hook via ‘msmtp’ sends notification e-mails after every successful uplink connect
- Proactively scan and switch to a higher priority uplink, replacing an existing connection
- Connection tracking logs start and end date of an uplink connection
- Automatically disable the uplink after n minutes, e.g. for timed connections
- Automatically (re)enable the uplink after n minutes, e.g. after failed login attempts
- (Optional) Generate a random unicast MAC address for each uplink connection
- NTP time sync before sending emails
- procd init and ntp-hotplug support
- Runtime information available via LuCI &amp; via ‘status’ init command
- Log status and debug information to syslog
- STA interfaces operate in an “always off” mode, to make sure that the AP is always accessible

## Prerequisites

- Modern [OpenWrt](https://openwrt.org "https://openwrt.org") (tested back to 20.0x)
- An OpenWrt router that supports the firmware version
- The `luci-app-travelmate` ensures these packages are present:
  
  - ‘dnsmasq’ as dns backend
  - ‘iwinfo’ for wlan scanning
  - ‘curl’ for connection checking and all kinds of captive portal magic, e.g. cp detection and auto-logins
  - a ‘wpad’ variant to support various WPA encrypted networks (WEP-based uplinks are no longer supported!)
- optional: ‘qrencode’ for AP QR code support
- optional: ‘wireguard’ or ‘openvpn’ for vpn client connections
- optional: ‘msmtp’ to send out Travelmate related status messages via email

## Installation and Usage

- Install OpenWrt on your router, and set it up to allow wireless connections. Be sure to set a strong password on the wireless channel(s) so that only you and your companions can use it.
- Decide which radio you’ll use for the Travelmate uplink (radio0, radio1, etc):
  
  - 2.4GHz allows a longer (more distant) link; 5GHz provides a faster link
  - Travelmate works on all radios. But for better performance, configure the AP on a separate radio from the one you’re planning to use as the uplink.
- Use LuCI web interface to install both **travelmate** and **luci-app-travelmate**
- Open the Travelmate LuCI application - **Services → Travelmate**
- You must use the Travelmate **Interface Wizard** one time to configure the uplink, firewall and other network settings. The default values work well. Just accept them unless you have a reason to modify them.
- Use the **Wireless Stations** tab to add an uplink station
  
  - **Scan** the radio you chose for the uplink
  - Click **Add Uplink…** for the desired SSID. If there are multiples, choose the one with the largest *Strength*
  - You’ll need to enter the credentials (password, etc)
  - You should be “on the air” - test by browsing the internet
- You may add additional uplinks (for different locations) by repeating the previous step
- Happy traveling …

*Note:* If you’re updating from a former Travelmate 1.x release: Use the ‘–force-reinstall –force-maintainer’ options in opkg; Remove any existing Travelmate related uplink stations in your wireless config manually

## Travelmate config options

The pre-configured Travelmate setup works quite well. Normally, no manual config overrides are needed. All listed options apply to the ‘global’ section:

Option Default Description/Valid Values trm\_enabled 0, disabled set to 1 to enable the travelmate service (this will be done by the Interface Wizard as well!) trm\_debug 0, disabled set to 1 to get the full debug output (logread -e “trm-”) trm\_iface -, not set uplink- and procd trigger network interface, configured by the ‘Interface Wizard’ trm\_radio -, not set restrict travelmate to a single radio or change the overall scanning order (‘radio1 radio0’) trm\_captive 1, enabled check the internet availability and handle captive portal redirections trm\_netcheck 0, disabled treat missing internet availability as an error trm\_proactive 1, enabled proactively scan and switch to a higher prioritized uplink, despite of an already existing connection trm\_autoadd 0, disabled automatically add open uplinks like hotel captive portals to your wireless config trm\_randomize 0, disabled generate a random unicast MAC address for each uplink connection trm\_triggerdelay 2 additional trigger delay in seconds before travelmate processing begins trm\_maxretry 3 retry limit to connect to an uplink trm\_minquality 35 minimum signal quality threshold as percent for conditional uplink (dis-) connections trm\_maxwait 30 how long should travelmate wait for a successful wlan uplink connection trm\_timeout 60 overall retry timeout in seconds trm\_maxautoadd 5 limit the max. number of automatically added open uplinks. To disable this limitation set it to ‘0’ trm\_maxscan 10 limit nearby scan results to process only the strongest uplinks trm\_captiveurl [http://detectportal.firefox.com](http://detectportal.firefox.com "http://detectportal.firefox.com") pre-configured provider URLs that will be used for connectivity - and captive portal checks trm\_useragent Mozilla/5.0 … pre-configured user agents that will be used for connectivity- and captive portal checks trm\_nice 0, normal priority change the priority of the travelmate background processing trm\_mail 0, disabled sends notification e-mails after every succesful uplink connect trm\_mailreceiver -, not set e-mail receiver address for travelmate notifications trm\_mailsender no-reply@travelmate e-mail sender address for travelmate notifications trm\_mailtopic travelmate connection to ‘&lt;sta&gt;’ topic for travelmate notification E-Mails trm\_mailprofile trm\_notify profile used by ‘msmtp’ for travelmate notification E-Mails

In addition, the travelmate config supports a `uplink` section for every uplink, with the following options:

Option Default Description/Valid Values enabled 1, enabled enable or disable the uplink, automatically set if the retry limit or the conn. expiry was reached device -, not set match the ‘device’ in the wireless config section ssid -, not set match the ‘ssid’ in the wireless config section bssid -, not set match the ‘bssid’ in the wireless config section con\_start -, not set connection start (will be automatically set after a successful ntp sync) con\_end -, not set connection end (will be automatically set after a successful ntp sync) con\_start\_expiry 0, disabled automatically disable the uplink after n minutes, e.g. for timed connections con\_end\_expiry 0, disabled automatically (re-)enable the uplink after n minutes, e.g. after failed login attempts script -, not set reference to an external auto login script for captive portals script\_args -, not set optional runtime args for the auto login script macaddr -, not set use a specified MAC address for the uplink vpn 0, disabled automatically handle VPN (re-) connections vpnservice -, not set reference the already configured ‘wireguard’ or ‘openvpn’ client instance as vpn provider vpniface -, not set the logical vpn interface, e.g. ‘wg0’ or ‘tun0’

## VPN client setup

Please follow one of the following guides to get a working vpn client setup on your travel router:

- [Wireguard client setup guide](https://openwrt.org/docs/guide-user/services/vpn/wireguard/client "https://openwrt.org/docs/guide-user/services/vpn/wireguard/client")
- [OpenVPN client setup guide](https://openwrt.org/docs/guide-user/services/vpn/openvpn/client "https://openwrt.org/docs/guide-user/services/vpn/openvpn/client")

Once your vpn client connection is running, you can reference to that setup in Travelmate to handle VPN (re-) connections automatically.

## E-Mail setup

To use E-Mail notifications you have to setup the package `msmtp`.

Modify the file `/etc/msmtprc`, e.g. for gmail:

```
[...]
defaults
auth            on
tls             on
tls_certcheck   off
timeout         5
syslog          LOG_MAIL
[...]
account         trm_notify
host            smtp.gmail.com
port            587
from            xxx@gmail.com
user            yyy
password        zzz
```

Finally enable E-Mail support in Travelmate and add a valid E-Mail receiver address.

See [SMTP clients](/docs/guide-user/services/email/smtp.client "docs:guide-user:services:email:smtp.client") for more details.

## Captive Portal auto-logins

For automated captive portal logins you can reference an external shell script per uplink. All login scripts should be executable and located in `/etc/travelmate` with the extension ‘.login’. The package ships multiple ready to run auto-login scripts:

- `wifionice.login` for ICE hotspots (DE)
- `db-bahn.login` for german DB railway hotspots via portal login API (still WIP, only tested at Hannover central station)
- `chs-hotel.login` for german chs hotels
- `h-hotels.login` for Telekom hotspots in h+hotels (DE)
- `julianahoeve.login` for Julianahoeve beach resort (NL)
- `telekom.login` for telekom hotspots (DE)
- `vodafone.login` for vodafone hotspots (DE)
- `generic-user-pass.login` a template to demonstrate the optional parameter handling in login scripts

A typical and successful captive portal login looks like this:

```
[...]
Thu Sep 10 13:30:16 2020 user.info trm-2.0.0[26222]: captive portal domain 'www.wifionice.de' added to to dhcp rebind whitelist
Thu Sep 10 13:30:19 2020 user.info trm-2.0.0[26222]: captive portal login '/etc/travelmate/wifionice.login ' for 'www.wifionice.de' has been executed with rc '0'
Thu Sep 10 13:30:19 2020 user.info trm-2.0.0[26222]: connected to uplink 'radio1/WIFIonICE/-' with mac 'B2:9D:F5:96:86:A4' (1/3)
[...]
```

Hopefully more scripts for different captive portals will be provided by the community!

## Runtime information

**Receive Travelmate runtime information:**

```
root@2go_ar750s:~# /etc/init.d/travelmate status
::: travelmate runtime information
  + travelmate_status  : connected (net ok/100)
  + travelmate_version : 2.0.0
  + station_id         : radio1/WIFIonICE/-
  + station_mac        : B2:9D:F5:96:86:A4
  + station_interface  : trm_wwan
  + wpa_flags          : sae: ✔, owe: ✔, eap: ✔, suiteb192: ✔
  + run_flags          : captive: ✔, proactive: ✔, netcheck: ✘, autoadd: ✘, randomize: ✔
  + ext_hooks          : ntp: ✔, vpn: ✘, mail: ✘
  + last_run           : 2020.09.10-15:21:19
  + system             : GL.iNet GL-AR750S (NOR/NAND), OpenWrt SNAPSHOT r14430-2dda301d40
```

To debug travelmate runtime problems, please always enable the ‘trm\_debug’ flag, restart Travelmate and check the system log afterwards (*logread -e “trm-”*)

## Support

Please join the Travelmate discussion in this [forum thread](https://forum.openwrt.org/t/travelmate-support-thread/5155 "https://forum.openwrt.org/t/travelmate-support-thread/5155") or contact me by [mail.](mailto:mailto:dev@brenken.org "mailto:dev@brenken.org") The Travelmate code is in this [Github repo.](https://github.com/openwrt/packages/blob/openwrt-22.03/net/travelmate/files/README.md "https://github.com/openwrt/packages/blob/openwrt-22.03/net/travelmate/files/README.md")

## Removal

- stop the Travelmate daemon with */etc/init.d/travelmate stop*
- optional: remove the Travelmate package (*opkg remove luci-app-travelmate*, *opkg remove travelmate*)

## Donations

You like this project - is there a way to donate? Generally speaking “No” - I have a well-paying full-time job and my OpenWrt projects are just a hobby of mine in my spare time.

If you still insist to donate some bucks …

- I would be happy if you put your money in kind into other, social projects in your area, e.g. a children’s hospice
- Let’s meet and invite me for a coffee if you are in my area, the “Markgräfler Land” in southern Germany or in Switzerland (Basel)
- Send your money to my [PayPal account](https://www.paypal.me/DirkBrenken "https://www.paypal.me/DirkBrenken") and I will collect your donations over the year to support various social projects in my area

No matter what you decide - thank you very much for your support!

Have fun!  
Dirk
