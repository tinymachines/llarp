# Guest Wi-Fi using CLI

This page provides a script that creates an additional separated guest network and a new guest firewall zone for your OpenWrt device. That is, to create a guest WLAN, that only has Internet access but cannot access your existing LAN.

## Step by step

1. Take your time, to read this whole page, before starting any configuration. Get at least a rough idea, of what below's code is configuring.
2. Create the guest WLAN as additional config on either your 2,4 or 5 GHz radio which should typically match `@wifi-iface[0]` or `@wifi-iface[1]`. The new guest networks will share the channel/frequency with your probably already existing WLANs.
3. Copy the whole following code block as is into a SSH command prompt of your OpenWrt device and press enter. Alternatively, create and run it as shell script on your OpenWrt device.

```
# Configuration parameters
NET_ID="guest"
WIFI_DEV="$(uci -q get wireless.@wifi-iface[0].device)"
 
# Fetch upstream zone
. /lib/functions/network.sh
network_flush_cache
network_find_wan NET_IF
FW_WAN="$(fw4 -q network ${NET_IF})"
 
# Set up guest WLAN
uci -q batch << EOI
delete network.${NET_ID}_dev
set network.${NET_ID}_dev=device
set network.${NET_ID}_dev.type=bridge
set network.${NET_ID}_dev.name=br-${NET_ID}
delete network.${NET_ID}
set network.${NET_ID}=interface
set network.${NET_ID}.proto=static
set network.${NET_ID}.device=br-${NET_ID}
set network.${NET_ID}.ipaddr=192.168.3.1/24
commit network
delete wireless.${NET_ID}
set wireless.${NET_ID}=wifi-iface
set wireless.${NET_ID}.device=${WIFI_DEV}
set wireless.${NET_ID}.mode=ap
set wireless.${NET_ID}.network=${NET_ID}
set wireless.${NET_ID}.ssid=${NET_ID}
set wireless.${NET_ID}.encryption=none
commit wireless
delete dhcp.${NET_ID}
set dhcp.${NET_ID}=dhcp
set dhcp.${NET_ID}.interface=${NET_ID}
set dhcp.${NET_ID}.start=100
set dhcp.${NET_ID}.limit=150
set dhcp.${NET_ID}.leasetime=1h
commit dhcp
delete firewall.${NET_ID}
set firewall.${NET_ID}=zone
set firewall.${NET_ID}.name=${NET_ID}
set firewall.${NET_ID}.network=${NET_ID}
set firewall.${NET_ID}.input=REJECT
set firewall.${NET_ID}.output=ACCEPT
set firewall.${NET_ID}.forward=REJECT
delete firewall.${NET_ID}_${FW_WAN}
set firewall.${NET_ID}_${FW_WAN}=forwarding
set firewall.${NET_ID}_${FW_WAN}.src=${NET_ID}
set firewall.${NET_ID}_${FW_WAN}.dest=${FW_WAN}
delete firewall.${NET_ID}_dns
set firewall.${NET_ID}_dns=rule
set firewall.${NET_ID}_dns.name=Allow-DNS-${NET_ID}
set firewall.${NET_ID}_dns.src=${NET_ID}
set firewall.${NET_ID}_dns.dest_port=53
add_list firewall.${NET_ID}_dns.proto=tcp
add_list firewall.${NET_ID}_dns.proto=udp
set firewall.${NET_ID}_dns.target=ACCEPT
delete firewall.${NET_ID}_dhcp
set firewall.${NET_ID}_dhcp=rule
set firewall.${NET_ID}_dhcp.name=Allow-DHCP-${NET_ID}
set firewall.${NET_ID}_dhcp.src=${NET_ID}
set firewall.${NET_ID}_dhcp.dest_port=67
set firewall.${NET_ID}_dhcp.proto=udp
set firewall.${NET_ID}_dhcp.family=ipv4
set firewall.${NET_ID}_dhcp.target=ACCEPT
commit firewall
EOI
service network reload
service dnsmasq restart
service firewall restart
```

## Explanation of this config code

All the changes will be visible in the web interface afterwards.

- a guest network called “guest” is created
- a dhcp configuration is created for the “guest” network (assuming that `192.168.3.1/24` is not conflicting with something else on your home network)
- a firewall zone called “guest” is created for the “guest” network
- a firewall zone forwarder from the “guest” to the “wan” zone is created (not the other direction)
- a firewall rule allowing your guests to access your OpenWrt DHCP service is created
- a firewall rule allowing your guests to access your OpenWrt DNS service is created

## Customization

There are endless of personal customization options.

- Be aware that there are no special Internet firewall restrictions active for your guests in this default config. If you want to restrict your weird guests to http(s) protocol or block UDP or do whatever fancy restriction, you have to add some additional customized firewall rules yourself.
- Also you may have to find individual rules/network setups for your personal situations, e.g. if your guests would like access to your printer or need to stream stuff from their smartphones to your Smart-TV. Unfortunately there is not a single one-fits-all solution for that.
- You could go even further and split of a LAN-jack using a custom VLAN configuration and link that split-of LAN jack to that guest net as well, if your guests prefer a wired connection.

## Manual rollback

If you ever want to get rid of the customization created by this script, simply open your OpenWrt web interface.

- Delete the guest network interface in the interface tab.
- Delete the guest firewall zone in the firewall tab.
- All firewall rules will be deleted automatically, once the firewall zone has been deleted.
- The DHCP config will be deleted automatically, once the guest interface is gone.
- Then click “Save &amp; Apply”.

## On demand usage

You may not have guests hanging out in your house all week long. You do not have to delete the whole config, when your guests are leaving. You can just enter the OpenWrt web interface and simply **enable** or **disable** the guest WLAN at will.

## See also

- [OpenWrt-guest\_wifi](https://github.com/Shine-/OpenWrt-guest_wifi "https://github.com/Shine-/OpenWrt-guest_wifi") script to automatically set up Guest WiFi network
- [Guest Wi-Fi extras](/docs/guide-user/network/wifi/guestwifi/extras "docs:guide-user:network:wifi:guestwifi:extras")
