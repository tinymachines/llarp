# Troubleshooting Internet Connectivity

Use these steps if you can connect to your OpenWrt router's Web GUI, but cannot connect to the broader Internet (say, [www.google.com](http://www.google.com "http://www.google.com")):

1. Verify that the WAN connection of your router (usually Ethernet) is connected to your cable/DSL modem, or other device that's connected “to the internet”.
2. Check to see if your LAN and WAN ports are in the same address range. To do this:
   
   - Go to **Network → Interfaces**
   - Find the IPv4 address assigned to the **LAN** interface
   - Find the IPv4 address assigned to the **WAN** interface
   - If these two addresses are in the same range, e.g., if they start with the same three sets of numbers, then they are in the same address range. You need to change the address of the LAN interface (see next step).
   - If the address ranges do not conflict, then ask on the [OpenWrt Forum](https://forum.openwrt.org "https://forum.openwrt.org") for more help.
3. Change the LAN interface address, if necessary. To do this:
   
   - From the **Network → Interfaces** page, click the **Edit** button next to the LAN interface.
   - The “IPv4 Address” field will show the LAN address found above.
   - Enter a new address, that differs from the WAN address. For example, the LAN address after a fresh OpenWrt installation will be `192.168.1.1`. A good alternate address would be `192.168.2.1`. _ \[note that other option is to change your cable/DSL modem to the other range]
   - Change the field to the new address, then click **Save and Apply** at the bottom of the page. (You may have to deactivate “AUTO REFRESH ON” or click on “APPLY UNCHECKED”)
   - Write the new address on the sticker that you placed on the bottom of your router. (This will save you or your techie friend a ton of time next time you need to work on the router.)
4. After changing the address, you will need to enter the *new address* in your web browser. You should get the OpenWrt login page again.
5. If you can now access the internet (e.g., [www.google.com](http://www.google.com "http://www.google.com")), you're all set. Continue with the [Quick Start Guide.](/docs/guide-quick-start/start "docs:guide-quick-start:start")
6. If you still cannot access the internet, then ask on the [OpenWrt Forum](https://forum.openwrt.org "https://forum.openwrt.org") for more help.
