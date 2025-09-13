# Internet connectivity and troubleshooting

- For a first quick Internet access test: If you have an existing router, connect the WAN port of your OpenWrt device to a LAN port of that router and confirm internet connectivity of your OpenWrt device with the following steps:
  
  - In the OpenWrt admin web interface, go to Network → Diagnostics and Click on “ping” button
  - or, if using OpenWrt SSH command line, you can use the command `ping openwrt.org`
  - This should return “0% packet loss” if everything is alright with your Internet connection
  - If your device has two (or more) ethernet ports, maybe OpenWrt and upstream WAN routers having conflicting IP address ranges. To correct this, adjust the OpenWrt router subnet by changing the [network settings](/docs/guide-user/network/network_configuration "docs:guide-user:network:network_configuration") in the file `/etc/config/network`
  - if the device has a single port, it's probably configured as a router anyway because that's what OpenWrt usually does so it has a static IP 192.168.1.1, no gateway or dns server set up so it won't connect to the Internet (or even local network if it is not 192.168.1.x) in this state. Connect to Luci web interface at the mentioned IP address and change the LAN interface settings to add the IP of your router as gateway and DNS server. If you have only SSH or console access, please see the [Use SSH to connect to the internet and install Luci Web interface](/docs/guide-quick-start/ssh_connect_to_the_internet_and_install_luci "docs:guide-quick-start:ssh_connect_to_the_internet_and_install_luci") article.
  - if the device has a single port and you can't access it from the default IP address of 192.168.1.1 then it was set by default with a dynamic address (some NAS devices in OpenWrt have that default setting), and you need to check your modem/router's “connected devices” page to see what IP your OpenWrt received from it. In this case the device should be able to access the internet because it has received the IP, gateway and dns setting from the line above.
  - if you wish to use the wifi to connect your device to a local wifi 'internet' source see [connect\_client\_wifi](/docs/guide-user/network/wifi/connect_client_wifi "docs:guide-user:network:wifi:connect_client_wifi")
- Decide whether you want to use OpenWrt [as a switch, router, or gateway](/docs/guide-user/network/switch_router_gateway_and_nat "docs:guide-user:network:switch_router_gateway_and_nat")
- When using your OpenWrt device as a Wi-Fi access point, **please remember to initially set your country code in the OpenWrt Wi-Fi configuration, to properly comply with your country's Wi-Fi legal regulations!**, e.g. see here for a first [basic Wi-Fi setup](/docs/guide-quick-start/basic_wifi "docs:guide-quick-start:basic_wifi").
- Consult the [User Guide](/docs/guide-user/start "docs:guide-user:start") for more advanced configuration.
- Install custom software packages that you might be interested in.

## Troubleshooting your first steps with the new OpenWrt device

- If OpenWrt is configured as a router with default settings, you can access [LuCI web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") and [SSH command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration") by [domain name](http://openwrt.lan/ "http://openwrt.lan/"). If OpenWrt is configured as a network client, switch or access point, use its IP-address explicitly. You can utilize a network scanner or status page of your main router to find out OpenWrt IP-address.
- If you have flashed a development/snapshot firmware of OpenWrt, you first need to [manually enable the web interface](/docs/guide-quick-start/developmentinstallation "docs:guide-quick-start:developmentinstallation"). Or verify the result on snapshot builds connecting to OpenWrt via [SSH](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration").
- You can consult the troubleshooting section of the [User Guide](/docs/guide-user/start "docs:guide-user:start"), if you think that resetting OpenWrt's settings might help.
- You can consult the [Installing and Using OpenWrt forum section](https://forum.openwrt.org/c/installation "https://forum.openwrt.org/c/installation"), if something went wrong. Please provide specific details of your device and what you did so far and what you have attempted to fix it.
- Do not worry if the 5 GHz Wi-Fi does not seem to start immediately after having enabled it. It might be busy for 1-10 min scanning for weather radar, see [basic Wi-Fi setup](/docs/guide-quick-start/basic_wifi "docs:guide-quick-start:basic_wifi") for more background info.
- Note that you can always run `logread` on the SSH command line, to gain more insight into what the device is currently doing or to diagnose any kind of problems.
- If needed, you can also take a look at [Troubleshooting internet connectivity](/docs/guide-quick-start/troubleshooting_internetconnectivity "docs:guide-quick-start:troubleshooting_internetconnectivity").

## Troubleshooting WiFi connectivity

### WiFi clients are connected but cannot access the network

- Is the wireless network attached to one of the networks defined in “interfaces”?
- If the WiFi works for a while and then stops (while the client is still shown as connected), you might be affected by [this issue](https://github.com/openwrt/openwrt/issues/9555 "https://github.com/openwrt/openwrt/issues/9555").
