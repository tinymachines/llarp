# Wi-Fi Repeater using AP+STA mode

A Wi-Fi Repeater is a configuration of an OpenWrt router that “extends” the network.

An OpenWrt router operating in AP+STA mode (sometimes referred to as “wi-fi tethering”) does this by making a wireless uplink to a hotspot (an access point or “AP”) and then repeating to other devices connected wirelessly or to its Ethernet interface.

AP+STA mode is by far the simplest means of extending Wi-Fi coverage because it does not require any changes to the upstream access point.

**Terminology:** this page refers to the upstream access point (AP) as the **hotspot**; the OpenWrt Wi-Fi repeater/extender as the **router**; STA refers to the fact that the router connects to the hotspot as a “station” (a regular Wi-Fi device).

*Note: For an even easier installation, check out the [Travelmate package](/docs/guide-user/network/wifi/wifiextenders/travelmate "docs:guide-user:network:wifi:wifiextenders:travelmate") that also extends a Wi-Fi network.*

## Make Backups

The procedure below updates the updates the following files to configure your router to act as a Wi-Fi repeater/extender. It assumes that your router has the default settings and that its wireless and Ethernet are bridged. ([/etc/config/network](/docs/guide-user/base-system/basic-networking "docs:guide-user:base-system:basic-networking"), [/etc/config/wireless](/docs/guide-user/network/wifi/basic "docs:guide-user:network:wifi:basic"), [/etc/config/firewall](/docs/guide-user/firewall/firewall_configuration "docs:guide-user:firewall:firewall_configuration"), and [/etc/config/dhcp](/docs/guide-user/base-system/dhcp "docs:guide-user:base-system:dhcp"))

Before you begin, it's always wise to make backups of all your configuration files.

```
# Back up the configuration files
echo 'Backing up configuration files'
cp /etc/config/network  /etc/config/network.bak
cp /etc/config/wireless /etc/config/wireless.bak
cp /etc/config/firewall /etc/config/firewall.bak
cp /etc/config/dhcp     /etc/config/dhcp.bak
```

## Configuring the Wi-Fi Repeater

Use the script below to change the configuration. It performs these tasks:

- Configure the router's LAN interface to 192.168.2.1 (default) Assume LAN subnet mask is 255.255.255.0
- Create a WWAN interface to get a DHCP from the hotspot
- Add the WWAN interface to the “wan” firewall zone
- Configure WWAN interface to use 'radio0' in STA mode
- Set the Wi-Fi credentials so the router can connect to the hotspot

To use the script, edit the IP address and the Wi-Fi credentials at the top of the file, then [run the script.](/docs/guide-user/network/wifi/wifiextenders/ap_sta#how_to_run_these_scripts "docs:guide-user:network:wifi:wifiextenders:ap_sta")

```
# Fill in these values, then run the script
ROUTER_LAN_IP='192.168.2.1'
HOTSPOT_ENCRYPTION_MODE='none' 
HOTSPOT_SSID='upstream-hotspot-wifi-ssid'
HOTSPOT_PASSWORD='super-secret-password'
 
# Set the router's LAN IP address to a different subnet from the hotspot (AP) IP address.
echo 'Setting the LAN IP address to $ROUTER_LAN_IP'
uci set network.lan.ipaddr=$ROUTER_LAN_IP
 
# Add the WWAN network is in the WAN firewall zone
echo 'Setting firewall zone for "wwan"'
uci add_list firewall.@zone[1].network="wwan"
uci commit firewall
/etc/init.d/firewall restart
 
# The WWAN interface is the "uplink". It obtains a DHCP address from the upstream hotspot.
echo 'Configuring WWAN'
uci set network.wwan="interface"
uci set network.wwan.proto="dhcp"
uci commit network
/etc/init.d/network restart
 
# Add the Wi-Fi interface for the uplink.
# STA mode, with the proper Wi-Fi credentials (SSID, encryption mode, key)
echo 'Configuring the Wi-Fi uplink'
uci set wireless.wwan="wifi-iface"
uci set wireless.wwan.device="radio0"
uci set wireless.wwan.network="wwan"
uci set wireless.wwan.mode="sta"
# Change the encryption and ssid values to match those of the hotspot (AP)
uci set wireless.wwan.encryption=$HOTSPOT_ENCRYPTION_MODE
uci set wireless.wwan.ssid=$HOTSPOT_SSID
uci set wireless.wwan.key=$HOTSPOT_PASSWORD
uci commit wireless
wifi reload
```

### Revert to AP-Only mode (Optional)

*This is an optional, but recommended step.*  
When the upstream hotspot is not available or if the wireless configuration file (created above) is incorrect, the router disables its own AP. If that happens, you would lose wireless access to your router, and could only connect through its Ethernet port. The following step installs a script that tests for hotspot availability after boot. If the router cannot connect to the hotspot after 30 seconds, it automatically reconfigures itself to AP Only mode so you an again access the router wirelessly.

```
# Create AP Only and AP+STA wireless configuration files
cp /etc/config/wireless.bak /etc/config/wireless.ap-only
cp /etc/config/wireless /etc/config/wireless.ap+sta
 
# Install the necessary packages
opkg update
opkg install iwinfo
 
# Save the script
cat << "EOF" > /usr/local/bin/fix_sta_ap.sh
#!/bin/sh
#
# Fix loss of AP when STA (Client) mode fails by reverting to default
# AP only configuration. Default AP configuration is assumed to be in
# /etc/config/wireless.ap-only
#
 
TIMEOUT=30
SLEEP=3
sta_err=0
 
while [ $(iwinfo | grep -c "ESSID: unknown") -ge 1 ]; do
   let sta_err=$sta_err+1
   if [ $((sta_err * SLEEP)) -ge $TIMEOUT ]; then
     cp /etc/config/wireless.ap-only /etc/config/wireless
     wifi up
#    uncomment the following lines to try AP+STA after reboot
#    sleep 3
#    cp /etc/config/wireless.ap+sta /etc/config/wireless
     break
   fi
   sleep $SLEEP
done
EOF
 
# Make the script executable
chmod +x /usr/local/bin/fix_sta_ap.sh
 
# Configure autostart
sed -i -e "
\$i /usr/local/bin/fix_sta_ap.sh > /dev/null &
" /etc/rc.local
```

![:!:](/lib/images/smileys/exclaim.svg) An alternative **event-driven** recovery solution is to be found [here](https://forum.openwrt.org/viewtopic.php?pid=309131#p309131 "https://forum.openwrt.org/viewtopic.php?pid=309131#p309131").

### wwanHotspot: maintain always up a dual wifi config, Access Point and HotSpot client (Optional)

In one location there may be several Hotspots that may be available or not according to the comings and goings of their owners; we will enter the parameters of each one of them in the configuration file therefore wwanHotspot will connect and disconnect the OpenWrt HotSpot client to one of them as they become available.

This daemon may be used instead of the method described in step 3. Download the latest version of [wwanHotspot](https://github.com/jordi-pujol/wwanHotspot/ "https://github.com/jordi-pujol/wwanHotspot/") and follow the instructions.

### Disable DNS rebind protection (Optional)

Disable DNS rebind protection if you need to trust upstream resolvers.

```
uci set dhcp.@dnsmasq[0].rebind_protection="0"
uci commit dhcp
/etc/init.d/dnsmasq restart
```

### How to run these scripts

To run one of the scripts above, [ssh into the router](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration"), then perform each of these steps:

```
# Copy the script into your favorite editor and make any changes
# Run each of the steps below sequentially
# When you get to the "paste" step, copy the script and paste it into the SSH session.
# 
ssh root@192.168.2.1 # use the actual address for your router
cd /tmp
cat > config.sh 
# paste in the contents of the script, then hit ^D (Control-D)
sh config.sh
# Presto! 
```
