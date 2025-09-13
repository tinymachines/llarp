# Enabling a Wi-Fi access point on OpenWrt

Devices with Ethernet ports have Wi-Fi turned off by default for security reasons. This page contains basic settings to enable Wi-Fi.

## Setup with the web GUI

1. Connect to LuCI at [http://192.168.1.1](http://192.168.1.1 "http://192.168.1.1"), and login with your “root” password.
2. Go to **Network → Wireless**. This page lists a separate Wi-Fi network for each physical radio (e.g. one for 2.4 GHz and one for 5 GHz).
3. For each Wi-Fi network, click `Edit` to configure (if not there click `Add` to create a network):
   
   - In **General Setup**, select the `Country Code` where your OpenWrt device is used. This is to ensure your Wi-Fi meets local regulations. Note this was formerly in the **Advanced Settings** tab.
   - In **General Setup**, enter an `ESSID`, the name for your Wi-Fi network.
   - In **Wireless Security**, select an `Encryption` method, “WPA2-PSK” or “WPA3-SAE” is recommended.
   - In **Wireless Security**, enter a `Key`, the password devices use to connect to your Wi-Fi network.
   - As desired, configure any other settings such as a channel and width, KRACK countermeasures, or 802.11r.
   - Click `Save` when you're done with these settings.
4. Click `Save & Apply`.
5. Finally, click `Enable` on each network you would like to activate.

## About the Country Code

To comply with your local regulatory laws, the country code for the radios on your device must be set. The default 00 (Rest of the World) country code limits operation to the limited set of channels and transmission power that is allowed anywhere in the world. You will typically have more available channels and higher power levels when you set the country code to your own. Be aware that setting the wrong country code could get you in trouble with local authorities because selecting a channel or transmitting at higher power than is allowed could interfere with other equipment, like radar. You can also interfere with your neighbor's devices.

On Linux based devices, like OpenWrt, the database of regulatory domains comes from the [wireless-regdb](https://git.kernel.org/pub/scm/linux/kernel/git/wens/wireless-regdb.git/tree/db.txt "https://git.kernel.org/pub/scm/linux/kernel/git/wens/wireless-regdb.git/tree/db.txt"). In there is the list of countries sorted alphabetically by their [ISO 3166-1 alpha-2](https://en.wikipedia.org/wiki/ISO%203166-1%20alpha-2 "https://en.wikipedia.org/wiki/ISO 3166-1 alpha-2") with allowed frequencies, channel bandwith, and transmission strength (dBm) or power (mW). If you plan to set your country code using the web GUI, do that from the dropdown, but if you intend to do it via command line, take note of your [ISO 3166-1 alpha-2](https://en.wikipedia.org/wiki/ISO%203166-1%20alpha-2 "https://en.wikipedia.org/wiki/ISO 3166-1 alpha-2") code on the link.

## Troubleshooting

- If you configured 5 GHz Wi-Fi and have just enabled it, but it does not start up immediately, consider the following: If your device supports Wi-Fi channels &gt;100, your OpenWrt device first must scan for weather radar on these channels before you can actually use such channels for Wi-Fi because of [DFS](/docs/techref/dfs "docs:techref:dfs"). This will take 1-10 minutes once after first reboot depending on your Wi-Fi situation and on the number of device-supported channels &gt;100. You may also experience 1 minute delay on each automatic channel change, as the same scan delay is required for regulation compliance.
- Network / Wireless / Edit / Interface Configuration / General Setup / Network should be left to the “lan” default or to another interface where there is an active DHCP server. DO NOT select “wan” or “wan6” as that's the interface for the Internet.
- If you are connecting your wireless device to an existing router and simply want to configure it as an access point (aka Dumb AP) use the [bridgedap](/docs/guide-user/network/wifi/wifiextenders/bridgedap "docs:guide-user:network:wifi:wifiextenders:bridgedap") guide.

## Using the command line

This section is not a complete howto on creating a fine tuned Wi-Fi network. It just shows important steps to set the basics for enabling Wi-Fi on the command line and meet the legal regulations of your country:

- Connect with SSH to your OpenWrt device: `$ ssh root@192.168.1.1`
- Execute `uci show wireless` to see all the wireless configurations and how many Wi-Fi chips (called “radio” in the config) there are on the device. Identify the radio number (0, 1, 2, etc) that are you aiming to configure, e.g., `radio0`, `radio1`, `radio2`.
- Execute `uci set wireless.radioN.country='XX'` to set the country code XX for each (N = 0, 1, 2) radio devices your router may have. Refer to the first section of this page.
- Execute `uci set wireless.radioN.disabled='0'` to enable all the said radio(s).
- Commit the changes executing: `uci commit wireless`.
- Reload the wifi interfaces: `wifi reload`.
- Wait a couple of minutes to allow the radio(s) to start and 5 GHz DFS scanning. Enjoy.
