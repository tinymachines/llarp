# Country code for Wi-Fi operation

OpenWrt is free software, but not free as in “free of responsibilities”. When operating a Wi-Fi capable device with OpenWrt you are responsible to be in conformance with your country's regulation.

## Mandatory Wi-Fi country code

When enabling Wi-Fi, it is mandatory to set the correct country code where your router is located.

This field is not meant to be set to where you were born, and not the country where you would prefer to live happily forever and ever with Katy Perry. It's also not some optional “cloud usage statistics” input field.

Follow the steps below:

1. In LuCI go to Network → Wireless
2. Click “Edit” on the SSID you want to enable
3. Click “Advanced Settings” tab
4. Select your “Country Code” from the dropdown
5. Save and Apply

Note if you do not see an “Edit” button, then the WiFi radio is not setup, use “Add” and configure a radio. Alternatively, you can SSH in and set the country with `iw reg set`

## Wi-Fi outdoor operation

Some Wi-Fi frequencies are for indoor use only, no matter if OpenWrt or the vendor firmware runs on your device. OpenWrt can by itself enforce settings like the maximum transmit power, but it cannot not tell if you have setup your OpenWrt device outdoors. So know your allowed frequencies before providing Wi-Fi to the roses at the far end of your garden.

## How does OpenWrt know what Wi-Fi channel settings are OK for my country?

The following is for informational purposes for technically interested readers. There is nothing you have to do beyond setting your proper country code. OpenWrt automatically takes care of everything else for you.

OpenWrt relies on the OpenWrt-firmware-contained [CRDA database](https://wireless.docs.kernel.org/en/latest/en/developers/regulatory/crda.html "https://wireless.docs.kernel.org/en/latest/en/developers/regulatory/crda.html") and [db.txt](https://web.git.kernel.org/pub/scm/linux/kernel/git/wens/wireless-regdb.git/tree/db.txt "https://web.git.kernel.org/pub/scm/linux/kernel/git/wens/wireless-regdb.git/tree/db.txt"), containing the regulation details for each supported country.

If you are curious about specific details for your country, run `iw reg get` on the command line.

Example output for Belgium:

```
country BE: DFS-ETSI
        (2402 - 2482 @ 40), (N/A, 20), (N/A)
        (5170 - 5250 @ 80), (N/A, 20), (N/A), AUTO-BW
        (5250 - 5330 @ 80), (N/A, 20), (0 ms), DFS, AUTO-BW
        (5490 - 5710 @ 160), (N/A, 27), (0 ms), DFS
        (57000 - 66000 @ 2160), (N/A, 40), (N/A)
```

Note: these are the max values your hardware is allowed to use, according to your country's regulation.  
If your hardware could do more, it will be capped by these regulatory limits.

Explanation of some commonly used values in `iw` output:

- “(2402 - 2482)”: allowed Wi-Fi frequency range in MHz (the output will not show Wi-Fi channel numbers).
- “@ ..” maximum allowed channel width in MHz for the given frequency range.
- “(N/A, 20)”: antenna transmit power limit for this frequency range. If there is no unit label of “mW” given the limit is stated in “dBm”. These units are exponential: +3 = double the power, e.g. 17 dBm = 50 mW, 20 dBm = 100 mW.
- “AUTO-BW: “Auto-bandwidth”: the Wi-Fi stack may automatically decide the channel width.
- ”[DFS](/docs/techref/dfs "docs:techref:dfs")“: “dynamic frequency selection”: Wi-Fi operating in those bands are required to employ a radar detection and avoidance capability.
- “NO-OUTDOOR”: Frequency range must not be used outdoors.

See the [CRDA database](https://wireless.wiki.kernel.org/en/developers/Regulatory#crda "https://wireless.wiki.kernel.org/en/developers/Regulatory#crda") for further details.

## Wi-Fi channels and weather radar detection

The following is for informational purposes for technically interested readers. There is nothing you have to do beyond setting your proper country code. OpenWrt automatically takes care of everything else for you.

Regulatory requirements for [DFS](/docs/techref/dfs "docs:techref:dfs")-marked channels requires that OpenWrt passively scans these Wi-Fi frequencies for 60 seconds for any weather radar activity, before using them for Wi-Fi activities.

An effect you may notice from this scan delay is a temporary user-unexpected Wi-Fi downtime. Such a short downtime may be experienced, when OpenWrt's Wi-Fi software stack switches to a DFS channel or when OpenWrt is done booting, but does not yet offer Wi-Fi for connection.

This delay isn't due to a bad software implementation, it's only due to a regulatory requirement. Factory firmware either does not support DFS channels at all or must implement the same scan technique. Future hardware could support extra antennas for transparent DFS-scanning in the background to remove user-noticeable delays on such frequencies.

## Changes in frequency regulation

It could happen rarely, but if changes happen in your country's wireless regulation, these changes will be reflected in a new OpenWrt firmware update. So you as the Wi-Fi device operator are responsible to keep the device within the current limits of your regulatory laws. You can achieve this by keeping your OpenWrt firmware up to date and apply newer releases periodically from OpenWrt.  
In rare cases even new frequencies get added to the allowed Wi-Fi spectrum of your country.

## Hardware-encoded Wi-Fi country-restrictions

It may be that your device has been branded by the vendor to be sold in a specific country and therefore has hardcoded Wi-Fi limits for that particular country. The Wi-Fi radio chip of your device might enforce such limits in addition to the country limits OpenWrt brings. Such hardware limits will precede OpenWrt regulatory settings. If you take such a limited device to a different country, such hardware-encoded limitation will cause your hardware to still enforce the limits of the original country. There is nothing you can do about such hard-encoded limits, you cannot circumvent them, you have to live with these extra-applied Wi-Fi limits.
