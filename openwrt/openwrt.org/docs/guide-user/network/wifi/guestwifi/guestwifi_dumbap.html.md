# Guest Wi-Fi on a dumb wireless AP using LuCI

A guest Wi-Fi setup will provide internet access to untrusted Wi-Fi devices while isolating them from other devices on your main network.

This guide will create a new guest network and use firewall security rules and masquerading to isolate it.

This guide is the user-friendly LuCI (web interface) alternative to [Guest Wi-Fi basics](/docs/guide-user/network/wifi/guestwifi/guest-wlan "docs:guide-user:network:wifi:guestwifi:guest-wlan") and [Guest Wi-Fi extras](/docs/guide-user/network/wifi/guestwifi/extras#restricting_upstream_accesswireless_ap "docs:guide-user:network:wifi:guestwifi:extras") (command-line).

**This article assumes an OpenWrt default configuration already modified as a wireless access point** (aka “Dumb” Access Point, aka “dumbAP”).  
For the procedure, refer to this article: [Create dumb AP with LuCI](/docs/guide-user/network/wifi/dumbap#configuration_via_luci_the_openwrt_web_interface "docs:guide-user:network:wifi:dumbap").

This guide will create a guest WLAN on 192.168.2.xxx, and assumes that the default private LAN / WLAN is present on 192.168.1.xxx.

## 1. Add a new Device and new Interface

Before we create the Guest\_WiFi AP, we are going to create the complete interface this WiFI will use.  
We start with creating a new device (it is a empty bridge!), to have a clean empty device for the new interface we create later.  
The bridge is not 100% necessary, but helps to avoid other problems and helps to start the new interface without errors.

[![](/_media/media/docs/howto/guestwifi-dumbap-23.05_config_01new_1_overview_interface_start.jpg?w=900&tok=62b3f5)](/_media/media/docs/howto/guestwifi-dumbap-23.05_config_01new_1_overview_interface_start.jpg "media:docs:howto:guestwifi-dumbap-23.05_config_01new_1_overview_interface_start.jpg")

#### Starting Point

Go to Network&gt;Interfaces  
As stated earlier, it is assumed that you already have a working dumb AP configuration.  
This means that the LAN IP address of your OpenWrt dumb AP is in the same subnet as your main router and that its address does not conflict with any other devices on the network.  
Often that means that address is something other than 192.168.1.1 which is typically already used by your main router.  
If you setup your dumb AP's lan interface as a DHCP client, this will be handled by the main router/DHCP server  
If you strictly followed this guide - [Create dumb AP with LuCI](/docs/guide-user/network/wifi/dumbap#configuration_via_luci_the_openwrt_web_interface "docs:guide-user:network:wifi:dumbap") (non dhcp, but the static ip version), your dumb AP IP is most likely 192.168.1.2

Now change to “Devices” Tab, lets do the first step to configure your GUEST WiFi.

[![](/_media/media/docs/howto/guestwifi-dumbap-23.05_config_01new_2_devices.jpg?w=900&tok=92e0b4)](/_media/media/docs/howto/guestwifi-dumbap-23.05_config_01new_2_devices.jpg "media:docs:howto:guestwifi-dumbap-23.05_config_01new_2_devices.jpg")

Press “Add device configuration...”

[![](/_media/media/docs/howto/guestwifi-dumbap-23.05_config_01new_4_new_bridge.jpg?w=900&tok=bd310c)](/_media/media/docs/howto/guestwifi-dumbap-23.05_config_01new_4_new_bridge.jpg "media:docs:howto:guestwifi-dumbap-23.05_config_01new_4_new_bridge.jpg")

Select as device type a “Bridge Device”  
name it “br-guest”  
do NOT choose anything in “Bridge ports”  
and select “Bring up empty bridge”

[![](/_media/media/docs/howto/guestwifi-dumbap-23.05_config_01new_3_device_list.jpg?w=900&tok=46820e)](/_media/media/docs/howto/guestwifi-dumbap-23.05_config_01new_3_device_list.jpg "media:docs:howto:guestwifi-dumbap-23.05_config_01new_3_device_list.jpg")

Your device list should look like this. Save it.  
Let's change back to the “Interfaces” tab and use our new device

[![](/_media/media/docs/howto/guestwifi-dumbap-23.05_config_01new_1_overview_interface_start.jpg?w=900&tok=62b3f5)](/_media/media/docs/howto/guestwifi-dumbap-23.05_config_01new_1_overview_interface_start.jpg "media:docs:howto:guestwifi-dumbap-23.05_config_01new_1_overview_interface_start.jpg")

Press “Add new interface”

[![](/_media/media/docs/howto/guestwifi-dumbap-23.05_config_01new_5_0_new_interface.jpg?w=900&tok=b31102)](/_media/media/docs/howto/guestwifi-dumbap-23.05_config_01new_5_0_new_interface.jpg "media:docs:howto:guestwifi-dumbap-23.05_config_01new_5_0_new_interface.jpg")

Set parameters according to screenshot and select “create interface”

[![](/_media/media/docs/howto/guestwifi-dumbap-23.05_config_01new_5_1_new_interface.jpg?w=900&tok=bd26ac)](/_media/media/docs/howto/guestwifi-dumbap-23.05_config_01new_5_1_new_interface.jpg "media:docs:howto:guestwifi-dumbap-23.05_config_01new_5_1_new_interface.jpg")

Now give the new interface a new static IP.  
In this example it is 192.168.2.1  
The IP and subnet MUST be different from your LAN.  
Here, the LAN is 192.168.1.0/24 (192.168.1.1 - 192.168.1.254),  
so we will use for the GUEST interface address 192.168.2.1 with an IPv4 subnet mask 255.255.255.0 (which is the 192.168.2.0/24 subnet).

Leave the gateway untouched/empty. Screenshot shows 192.168.1.1 in grey text which is the address of the main router as assumed in this article).

Now Select “DHCP Server” Tab

[![](/_media/media/docs/howto/guestwifi-dumbap-23.05_config_01new_7_dhcp1.jpg?w=900&tok=75a782)](/_media/media/docs/howto/guestwifi-dumbap-23.05_config_01new_7_dhcp1.jpg "media:docs:howto:guestwifi-dumbap-23.05_config_01new_7_dhcp1.jpg")

Enable DHCP Server for GUEST Network by pressing the Button “Set Up DHCP Server”

[![](/_media/media/docs/howto/dhcp-dns.jpg?w=900&tok=d18840)](/_media/media/docs/howto/dhcp-dns.jpg "media:docs:howto:dhcp-dns.jpg")

You do not need to change settings. Press “Save” &amp; “Save &amp; Apply” on the interface page

Note that you GUEST network uses the LAN network as its upstream network  
Therefore we need to check and/or make sure that the LAN on your dumb AP is configured correctly  
The LAN on your dumb AP needs at least two paramter set correctly to be able to upstram your GUEST traffic, namely the LAN “Standard Gateway” and the LAN “DNS Server”.  
Good news is: If you configured your dumb AP as a DHCP client, this two paramters are already set automatically.

If you have configured your dumb AP manually, you need to make sure that LAN Standard Gateway and LAN DNS Server are set.  
You can skip the edits / checks (next three Screenshots) in LAN if you are on a dumb AP as a DHCP client and continue in the firewall section of this guide.

[![](/_media/media/docs/howto/guestwifi-dumbap-23.05_config_01new_9_new_interface_enabled_.jpg?w=900&tok=731a27)](/_media/media/docs/howto/guestwifi-dumbap-23.05_config_01new_9_new_interface_enabled_.jpg "media:docs:howto:guestwifi-dumbap-23.05_config_01new_9_new_interface_enabled_.jpg")

Head to the “Interfaces” Page, find your LAN Interface and press “Edit” to edit your LAN Interface

[![](/_media/media/docs/howto/dumb_ap_guest_standard_gateway.jpg?w=900&tok=7adf12)](/_media/media/docs/howto/dumb_ap_guest_standard_gateway.jpg "media:docs:howto:dumb_ap_guest_standard_gateway.jpg")

Select the “General” Tab of the LAN configuration page.  
Make sure that the “Standard Gateway” shows your standard gateway.  
If not - put in 192.168.1.1 as “Standard Gateway” (Standard openWrt).

[![](/_media/media/docs/howto/dumb_ap_guest_dns.jpg?w=900&tok=18f30c)](/_media/media/docs/howto/dumb_ap_guest_dns.jpg "media:docs:howto:dumb_ap_guest_dns.jpg")

Select the “Advanced Settings” Tab.  
Make sure that a working DNS is configured.  
The “Custom DNS server” should show the DNS Server in your System, openWrt Standard would be 192.168.1.1 , your main router.  
→ Any public DNS server like 1.1.1.1 would work as well, but you MUST configure one DNS Server for your GUEST network.

Hit “save”, you are led back to the “Interface” overview page

[![](/_media/media/docs/howto/guestwifi-dumbap-23.05_config_01new_9_new_interface_enabled_.jpg?w=900&tok=731a27)](/_media/media/docs/howto/guestwifi-dumbap-23.05_config_01new_9_new_interface_enabled_.jpg "media:docs:howto:guestwifi-dumbap-23.05_config_01new_9_new_interface_enabled_.jpg")

Press “Save &amp; Apply” if there are unsaved changes.  
You have created a new interface with a static IP, Guest DHCP Server enabled and you put a empty bridge as device behind it.  
You also made sure that your upstream network “LAN” has its “Standard Gateway” and its “DNS Server” configured.  
Great!  
Let's now also create a firewall zone for our new interface  
Press “edit” next to your “guest” interface and configure your interface again.

[![](/_media/media/docs/howto/guestwifi-dumbap-23.05_config_01new_11_create_firewall_zone.jpg?w=900&tok=255c61)](/_media/media/docs/howto/guestwifi-dumbap-23.05_config_01new_11_create_firewall_zone.jpg "media:docs:howto:guestwifi-dumbap-23.05_config_01new_11_create_firewall_zone.jpg")

Create a new firewall zone called “guest” on the “Firewall” Tab of your Interface configuration page.  
Press “Save”  
Your interface for the guest traffic is ready, it got its own firwall zone added.  
Let's head to the firewall section of your router to configure this new firewall zone we just created.

## 2. Firewall - Part 1

[![](/_media/media/docs/howto/guestwifi-dumbap-23.05_config_05_fw2.jpg?w=900&tok=08d5bb)](/_media/media/docs/howto/guestwifi-dumbap-23.05_config_05_fw2.jpg "media:docs:howto:guestwifi-dumbap-23.05_config_05_fw2.jpg")

After you did “Save &amp; Apply” all settings in the interface section,  
move on in LuCI to “Network → Firewall Settings” and edit the firewall zone “guest” that you just created.

[![](/_media/media/docs/howto/guestwifi-dumbap-23.05_config_05_fw3.jpg?w=900&tok=173aa7)](/_media/media/docs/howto/guestwifi-dumbap-23.05_config_05_fw3.jpg "media:docs:howto:guestwifi-dumbap-23.05_config_05_fw3.jpg")

Set for your “guest” zone the following parameter:  
Input to REJECT, Output to ACCEPT and Foward to REJECT.  
Allow forward to destination zone: \`lan\`.  
Press “Save &amp; Apply”.

[![](/_media/media/docs/howto/guestwifi-dumbap-23.05_config_05_fw4.jpg?w=900&tok=cf19f8)](/_media/media/docs/howto/guestwifi-dumbap-23.05_config_05_fw4.jpg "media:docs:howto:guestwifi-dumbap-23.05_config_05_fw4.jpg")

**After you have enabled “masquerading” for lan**,  
your screen should look like the screenshot above  
In principle, you have finished your GUEST network setup.

In the next section, we set up a firewall rule to isolate the guest network from LAN.

## 3. Firewall Part 2 - Firewall traffic rules

Now go to the traffic rules tab inside firewall and add the following three rules:

[![](/_media/media/docs/howto/guestwifi-dumbap-23.05_config_06_fw_dhcp.jpg?w=900&tok=e03211)](/_media/media/docs/howto/guestwifi-dumbap-23.05_config_06_fw_dhcp.jpg "media:docs:howto:guestwifi-dumbap-23.05_config_06_fw_dhcp.jpg")

Allow DHCP traffic from your Guests to your Router

[![](/_media/media/docs/howto/guestwifi-dumbap-23.05_config_06_fw_dns.jpg?w=900&tok=3b7f33)](/_media/media/docs/howto/guestwifi-dumbap-23.05_config_06_fw_dns.jpg "media:docs:howto:guestwifi-dumbap-23.05_config_06_fw_dns.jpg")

Allow DNS traffic from your Guests to your Router

[![](/_media/media/docs/howto/guestwifi-dumbap-23.05_config_06_fw_block-all.jpg?w=900&tok=098e40)](/_media/media/docs/howto/guestwifi-dumbap-23.05_config_06_fw_block-all.jpg "media:docs:howto:guestwifi-dumbap-23.05_config_06_fw_block-all.jpg")

Block all traffic that comes from “guest” zone if the guest wants to connect to network devices in your “LAN” zone

Everything is prepared to add the “wireless guest” part to your configuration  
Head to “Network → Wireless” to do the final part

## 4. Add a new WiFi and connect it to your "guest" interface

[![](/_media/media/docs/howto/guestwifi-dumbap-23.05_config_01.jpg?w=900&tok=3fdf96)](/_media/media/docs/howto/guestwifi-dumbap-23.05_config_01.jpg "media:docs:howto:guestwifi-dumbap-23.05_config_01.jpg")

Add a new wireless radio using the “Add” button either on radio0 or radio1  
In this example we are going to use radio1

[![|](/_media/media/docs/guestwifi-dumbap-23.05_config_new_chap4-1_add_wirless.jpg?w=900&tok=c029c0 "|")](/_media/media/docs/guestwifi-dumbap-23.05_config_new_chap4-1_add_wirless.jpg "media:docs:guestwifi-dumbap-23.05_config_new_chap4-1_add_wirless.jpg")

Choose an SSID fur your wirless guest network.  
In this guide we use Guest\_WiFi  
Connect your Guest\_WiFi to the Interface “guest” which we created in step 1  
We do not change wireless security settings (= WiFi Password Setting) in this guide - you maybe should ;)  
press “save” button

[![](/_media/media/docs/guestwifi-dumbap-23.05_config_new_chap4-2_wirelless_ap_ok.jpg?w=900&tok=881941)](/_media/media/docs/guestwifi-dumbap-23.05_config_new_chap4-2_wirelless_ap_ok.jpg "media:docs:guestwifi-dumbap-23.05_config_new_chap4-2_wirelless_ap_ok.jpg")

Press “Save &amp; Apply”

[![](/_media/media/docs/guestwifi-dumbap-23.05_config_new_chap4-3_wirelless_ap_ok.jpg?w=900&tok=8f7759)](/_media/media/docs/guestwifi-dumbap-23.05_config_new_chap4-3_wirelless_ap_ok.jpg "media:docs:guestwifi-dumbap-23.05_config_new_chap4-3_wirelless_ap_ok.jpg")

**YOU ARE DONE.** All necessary steps are taken to have an isolated guest network on an “dumb wireless access point”.  
If you are interested how things work and how to get the setting even cleaner (with all WAN traces eliminated) read on.

## 5. Additional Info / Explanation

We created a new interface, based on a new virtual device (empty bridge), and connected a WLAN Access Point to it. The new (Guest WiFI) has an interface with own, separated DHCP Service / separated IP addresses, firewall zone which differ from the ones in the LAN net segment  
The traffic from the Guest\_WiFI Network is routed to the upstream gateway (the main router), and that router interfaces with the internet.

From the perspective of the main router, the guest traffic all appears to come from the LAN IP address of the dumb AP which is possible because of the “masquerading” option in the lan firewall zone.  
Without this, the upstream router would not know how to route to the network. Without the three firewall rules and the “reject” setting, guest users could try to access the AccessPoint Router and all other devices in LAN.

Optional / EXTRA:  
In dumb AP mode, the WAN Zone and WAN firewall settings can be deleted, as WAN is not used in dumb AP mode. Everything looks a bit “cleaner” if you also go for this extra.  
Your Firewall dashboard then looks like this:

[![](/_media/media/docs/howto/8unbenannt.jpg?w=900&tok=4c5112)](/_media/media/docs/howto/8unbenannt.jpg "media:docs:howto:8unbenannt.jpg")

This screenshot (with all WAN traces eliminated) makes it clearer what is really going on in Firewall section of dumbAP + Guest szenario.

[![](/_media/media/docs/howto/dumbap-nw-overview.jpg?w=900&tok=6873f7)](/_media/media/docs/howto/dumbap-nw-overview.jpg "media:docs:howto:dumbap-nw-overview.jpg")

and Interface overview looks like this (please note the used IPs / Networks on the screenshot are different to openWrt standard )

Compared to the Standard Installation of openWrt,  
“Guest” behaves a bit like LAN in openWRT standard, with its own IP Space / DHCP and does forward its traffic to its upstream network zone. But upstream network zone is now LAN, not WAN  
and  
LAN takes the role of WAN (compared to standard openWrt Intsallation), recieving forwarded traffic from Guest including masquerading that traffic  
The role of WAN is taken over by another router with real WAN access .. that offers its DHCP and Standard Gateway and Firewall to the dumbAP LAN clients, and also acts as the Standard Gateway / DNS Server / primary Firewall for Guest WiFi.

## 6. Troubleshooting

In Guest\_DHCP traffic Rule, in destination port field, try to choose either 67 or 68 port
