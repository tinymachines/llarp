# Regaining access to an OpenWrt device in client mode

If you have set your OpenWrt device to become a network client (e.g. to use it as wifi access point only), you most likely will have purposely turned off DHCP and you will have removed the static IP address from OpenWrt configuration. As a result, the OpenWrt device will no longer be listening to SSH or LuCi/http (or whatever you had used as address range before), rendering the device inaccessible on first sight.

But both the SSH deamon and LuCi are still active, just their listening IP address will be different. There is no need to boot the OpenWrt device into fail-safe mode to regain access. Simply connect the OpenWrt device (WAN port) to the LAN port of another router that has DHCP enabled.

Then check the status page of the other router and note the IP address that got issued from the other router to your OpenWrt device (or do a network scan from a client). This IP address will then need to be used for SSH and LUCI access to the OpenWrt device.
