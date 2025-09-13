# Use SSH to connect to the internet and install LuCI web interface

The following instructions give the OpenWrt device an IP address in the same network of the ISP modem, then set the ISP modem's IP address as “gateway” and “dns server” for the OpenWrt device, which is providing internet access to it's clients.

The OpenWrt device will act as a client of the ISS modem and will be accessible through its LAN port.

For example that the **ISP modem** has IP address **192.168.2.1**; so we can assign any IP that starts with 192.168.2.xxx. I will assign **192.168.2.200** to the **OpenWrt device** in the example.

```
uci set network.lan.ipaddr="192.168.2.200"
uci set network.lan.gateway="192.168.2.1"
uci set network.lan.dns="192.168.2.1"
uci commit
/etc/init.d/network restart
```

This should save the setting and close the ssh connection as the IP address was changed.

You can also disconnect power from the OpenWrt device now, the setting is saved.

Disconnect the cable from the notebook and connect it to the ISP modem's Ethernet port.

Connect the PC to the ISP modem with DHCP (normal “automatic IP” way), Wi-Fi or Ethernet should be the same. Connect to the OpenWrt device with ssh at IP 192.168.2.200.

Now it should be able to [install LuCI](/docs/guide-user/luci/luci.essentials#basic_installation "docs:guide-user:luci:luci.essentials").
