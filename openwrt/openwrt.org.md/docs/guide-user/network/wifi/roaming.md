# Wifi Roaming

It is common in larger installations (e.g. large domestic networks or commercial installations) for a WiFi network to be configured with multiple different access points all advertising the same SSID (wifi network name) with the same authentication method and credentials.

The intention is that a WiFi client will choose “the best” access point (or rather “BSSID”) to connect to. If network conditions change, or a client is physically moved to a different location, then “the best” BSSID may change.

Even if there is a only a single access point present, then a client may prefer to disconnect from the access point on one radio frequency band and reconnect on another band (e.g. switch from using 5 GHz to 2.4 GHz). i.e. A single physical access point might have two or three different BSSIDs, one on each frequency band which it supports, and “roaming” between then looks a lot like the transition which occurs between access points.

The WiFi standards refer to configuration where the same SSID is available from multiple access points as an Extended Service Set (ESS).

Over time, a number of optional features have been added to the WiFi standards to try to increase roaming performance within an ESS. These include:

- **802.11r** (“Fast Transition”) reduces the time taken for a client to establish a secure connection when roaming to a different BSSID.
- **802.11k** (“Radio Resource Measurement”) allows a single BSSID provide wifi clients with a list of other BSSIDs and frequencies which are included in the ESS. This reduces the time that each client needs to spend looking for an alternative “better” SSID because it no longer needs to scan all frequencies.
- **802.11v** (“Wireless Network Management”) this standard includes “Network assisted Roaming” whereby the BSSID can recommend alternative BSSIDs that the client could roam to.

## 802.11r Fast Transition

When joining (“associating with”) a wireless network with security enabled, a “4 way handshake” occurs between a wireless client and the BSS (usually a typical radio on an access point). In the case of “Enterprise” EAP / 802.1X type authentication (whereby each user has their own authentication credentials), this can be especially time consuming because the authentication step may involve a distant authentication server.

Without 802.11r, a roam (a transition to a different BSS) repeats the same authentication process. During this time, network traffic is interrupted. 802.11r aims to speed up the roam with a shorter packet exchange (e.g. 4 packets total vs 8) during the transition to the new BSS (n.b. the new BSS could also be on the same physical access point if the client switches between the 2.4GHz and 5GHz radios).

802.11r is particularly beneficial when “Enterprise” EAP / 802.1X type authentication is used because an additional (potentially high latency) round-trip to the authentication server is not required. See the linked WLPC presentation video in the “Additional Resources” section for some real world examples and timings.

### Configuring

The full set of 802.11r related options which OpenWrt supports can be found [here in the documentation](/docs/guide-user/network/wifi/basic#fast_bss_transition_options_80211r "docs:guide-user:network:wifi:basic").

To configure using the Luci web interface, go to `Network→Wireless`, and on each `SSID` click `Edit`, scroll-down to the `Interface Configuration` tabs, select `WLAN Roaming`, check the `802.11r Fast Transition` box, and put in a 4-digit `Mobility Domain` that matches the same SSID on your other 802.11r-enabled routers/AP's.

- If you do not see the `WLAN Roaming` tab, you need to update your OpenWrt or load a version of `wpad` that has the 802.11r features. All current versions of OpenWrt come with 802.11r support in the basic `wpad` drivers.

### Wifi clients with no or limited support for 802.11r

Clients without 802.11r support should connect to networks with 802.11r enabled, however **some buggy clients are known to refuse to associate** with networks which have 802.11r enabled, or have other problematic behaviour. A workaround for this is to create a separate “legacy” SSID which has 802.11r disabled, for those devices alone to connect to. In some cases upgrading the client firmware, drivers, or OS may fix issues.

- MacOS on Intel CPUs do not support 802.11r. Some older Intel Macs will refuse to connect to networks with 802.11r enabled. For minimum versions for iOS devices [Apple includes a table on this page](https://support.apple.com/en-gb/guide/deployment/dep98f116c0f/web "https://support.apple.com/en-gb/guide/deployment/dep98f116c0f/web")
- Windows 10 and Windows 11 (up to and including version 2024H2) only supports 802.11r on networks which use 802.1X authentication (i.e. **801.11r with PSK is not supported** - i.e. on networks with single a single passphrase as set by \`option key\` in OpenWrt Windows does not are not supported).
- Some Intel Windows wifi6 client cards with driver versions 23.60.* would fail to re-associate to OpenWrt 23.x access points when 802.11r with PSK was enabled. Upgrading to Intel driver version 23.90.* fixed the problem.

### Verifying client 802.11r support

To check if 802.11r is working properly, set log\_level to 1 (cf. [Common Options](/docs/guide-user/network/wifi/basic#common_options1 "docs:guide-user:network:wifi:basic")) and look for message “*FT authentication already completed - do not start 4-way handshake*” in your system log after roaming.

It's also possible to verify that clients are using 802.11r by inspecting the “Association Request” frames that they send. Verify the “Auth Key Management type” includes “FT” (Fast Transition).

In the packet capture screenshot below, Wireshark is used with the filter `wlan.fc.type_subtype == 0`. The client can be seen to request the use of 802.11r - the “Auth Key Management type” is set to “FT using SAE” (i.e. 802.11r fast transition, with WPA3 SAE pre-shared key).

[![](/_media/media/802.11r_assoc_wireshark.png?w=400&tok=ebb43b)](/_detail/media/802.11r_assoc_wireshark.png?id=docs%3Aguide-user%3Anetwork%3Awifi%3Aroaming "media:802.11r_assoc_wireshark.png")

When 802.11r is in use, this can be found in each Association Request frame, under `IEEE 802.11 Wireless Management` → `Tagged parameters` → `RSN Information` → `Auth Key Management (AKM) List`.

## 802.11k and 802.11v

The “hostap” management software forms a key part of OpenWrt in that it manages advertising WiFi networks and authenticating WiFi clients. hostapd includes support for 802.11k and 802.11v, but relies on external software to make roaming recommendations and provide it with lists of alternative BSSIDs etc. OpenWrt packages software which can perform these functions and are intended to manage both 802.11k and 802.11v. Only one should be active at a time:

- [dawn](/docs/guide-user/network/wifi/dawn "docs:guide-user:network:wifi:dawn")
- [usteer](/docs/guide-user/network/wifi/usteer "docs:guide-user:network:wifi:usteer")

Alternative packages which only implement 802.11k include:

- [rmm-nr-distributor](https://github.com/simonyiszk/openwrt-rrm-nr-distributor "https://github.com/simonyiszk/openwrt-rrm-nr-distributor")

Double check that your wpad supports 802.11k (wpad-basic-mbedtls does not, e.g., in 24.10)

## Additional Resources

- [A talk given at Wireless Lan Professionals Conference 2019 entitled "Effects of 802.11k/r/v"](https://youtu.be/4Ua2lI6HBhE?&t=24 "https://youtu.be/4Ua2lI6HBhE?&t=24")
- [OneMarkFifty explaining how to set-up fast roaming OpenWrt Wi-Fi Access points](https://www.youtube.com/watch?v=kMgs2XFClaM "https://www.youtube.com/watch?v=kMgs2XFClaM") (Youtube)
- [OpenWrt Forum: Documentation on 802.11r](https://forum.openwrt.org/t/documentation-on-802-11r/176972 "https://forum.openwrt.org/t/documentation-on-802-11r/176972")
- [OpenWrt Forum: 802.11r Fast Transition, another discussion](https://forum.openwrt.org/t/802-11r-fast-transition-how-to-understand-that-ft-works/110920 "https://forum.openwrt.org/t/802-11r-fast-transition-how-to-understand-that-ft-works/110920")
