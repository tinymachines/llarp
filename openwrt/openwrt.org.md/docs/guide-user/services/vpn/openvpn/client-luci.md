# OpenVPN client using LuCI

## Introduction

- This guide describes how install and operate the [OpenVPN](https://en.wikipedia.org/wiki/OpenVPN "https://en.wikipedia.org/wiki/OpenVPN") client using LuCI web interface.
- You can use it to connect to your own OpenVPN server or a commercial OpenVPN provider.
- Follow [OpenVPN basic](/docs/guide-user/services/vpn/openvpn/server "docs:guide-user:services:vpn:openvpn:server") for server setup and [OpenVPN extras](/docs/guide-user/services/vpn/openvpn/extras "docs:guide-user:services:vpn:openvpn:extras") for additional tuning.
- The performance of different SoCs can be found here [OpenVPN performance](/docs/guide-user/services/vpn/openvpn/performance "docs:guide-user:services:vpn:openvpn:performance").

## Goals

- Encrypt your internet connection to enforce security and privacy.
  
  - Prevent traffic leaks and spoofing on the client side.
- Bypass regional restrictions using commercial providers.
  
  - Escape client side content filters and internet censorship.
- Access your LAN services remotely without port forwarding.

## Web interface instructions

### 1. Install needed packages

Install [openvpn-openssl](/packages/pkgdata/openvpn-openssl "packages:pkgdata:openvpn-openssl") and [luci-app-openvpn](/packages/pkgdata/luci-app-openvpn "packages:pkgdata:luci-app-openvpn") to be able to manage OpenVPN using web interface.

A new page in the LuCI web interface should appear.

Navigate to **LuCI → VPN → OpenVPN** to open the OpenVPN config management page.

[![](/_media/docs/guide-user/services/vpn/openvpn/openwrt_openvpn_client_1_.png?w=600&tok=80c6a7)](/_media/docs/guide-user/services/vpn/openvpn/openwrt_openvpn_client_1_.png "docs:guide-user:services:vpn:openvpn:openwrt_openvpn_client_1_.png")

### 2.a Write the configuration manually to create a config file

Create a new config with the **Template-based configuration** line by choosing the template, writing a name and clicking **Add** button to create it.

Then it will appear in the table and you can edit this configuration file by clicking on **Edit** button to open the edit page for this configuration.

[![](/_media/docs/guide-user/services/vpn/openvpn/openwrt_openvpn_client_2_create_openvpn_config.png?w=600&tok=9906ea)](/_media/docs/guide-user/services/vpn/openvpn/openwrt_openvpn_client_2_create_openvpn_config.png "docs:guide-user:services:vpn:openvpn:openwrt_openvpn_client_2_create_openvpn_config.png")

### 2.b Upload a OpenVPN config file

This is available from OpenWrt 19.07 onwards.

All self-respecting commercial OpenVPN providers will offer self-sufficient OpenVPN config files you can load in your consumer router or network appliance to connect to their service.

You can use them in OpenWrt too.

Use the **OVPN configuration file upload** to give a name and upload one of such config files.

It will appear in the table of available OpenVPN configurations.

If your provider requires you to write your username and a password, click on the Edit button, and in the edit page, write your username and password in the second text box, as shown in this example

[![](/_media/docs/guide-user/services/vpn/openvpn/openwrt_openvpn_client_2_upload_openvpn_config_add_user_pass.png?w=600&tok=a942ec)](/_media/docs/guide-user/services/vpn/openvpn/openwrt_openvpn_client_2_upload_openvpn_config_add_user_pass.png "docs:guide-user:services:vpn:openvpn:openwrt_openvpn_client_2_upload_openvpn_config_add_user_pass.png")

Now edit the line beginning **auth-user-pass** in the first text box to included the full path to the username/password .auth file. The full path is visible just above the second text box. For above example:

```
auth-user-pass /etc/openvpn/NLMiramUDP443E3.auth
```

### 3. Start and enable the client

Start the client by pressing on the **Start** button in the table of available configurations. OpenVPN startup and shutdown are slow, it can take up to 10 seconds to complete.

If you want this VPN client connection to be started on boot and always active, click in the **Enable** checkbox of its line in the table.

**Note:** If clicking on **Start** button in the table does not start the VPN instance. Tick the **Enable** checkbox, and press **Save &amp; Apply** button to start the VPN instance

### 4. Firewall

At this point the VPN is set up and the router can use it, but devices in the LAN of your router won't be able to access the internet anymore.

We need to set the VPN network interface as public by assigning VPN interface to WAN zone.

#### 4.1-a With Openwrt up to 18.06 and 19.07

1. Click on **Network** in the top bar and then on **Interfaces** to open the interfaces configuration page.
2. Click on button **Add new Interface...**
3. Fill the form with the following values: **Name** = `OpenVPN`, **Protocol** = `Unmanaged`, **Interface** = `tun0`. Then click on **Create Interface**.
4. Edit the interface.
5. In panel **General Settings**: unselect the checkbox **Bring up on boot**.
6. In panel **Firewall Settings**: **Assign firewall-zone** to `wan`.
7. Click on **Save and Apply** the new configuration.
8. Reboot the router.

[![](/_media/docs/guide-user/services/vpn/openvpn/openwrt_openvpn_client_4_firewall_alternate.png?w=600&tok=f900ac)](/_media/docs/guide-user/services/vpn/openvpn/openwrt_openvpn_client_4_firewall_alternate.png "docs:guide-user:services:vpn:openvpn:openwrt_openvpn_client_4_firewall_alternate.png")

[![](/_media/docs/guide-user/services/vpn/openvpn/openwrt_openvpn_client_4_firewall_alternate_2.png?w=600&tok=56a08a)](/_media/docs/guide-user/services/vpn/openvpn/openwrt_openvpn_client_4_firewall_alternate_2.png "docs:guide-user:services:vpn:openvpn:openwrt_openvpn_client_4_firewall_alternate_2.png")

#### 4.1-b With Openwrt 19.07 (alternative to the above step 4.1)

Click on **Network** in the top bar and then on **Firewall** to open the firewall configuration page.

Click on the **Edit** button of the **wan** (red) zone in the **Zones** list at the bottom of the page.

Click on the **Advanced Settings** tab and select the **tunX** interface (**tun0** in the screenshot, which is the most likely if you have a single OpenVPN client/server running)

[![](/_media/docs/guide-user/services/vpn/openvpn/openwrt_openvpn_client_4_firewall.png?w=600&tok=faebad)](/_media/docs/guide-user/services/vpn/openvpn/openwrt_openvpn_client_4_firewall.png "docs:guide-user:services:vpn:openvpn:openwrt_openvpn_client_4_firewall.png")

You can see the interface name if you click on **Status** on the top bar and then click on **System Log**.

A few lines from the system log where you can see the interface name of the OpenVPN client started with the configuration file **NLMiramUDP443E3**

```
 Fri Aug 30 11:28:32 2019 daemon.notice openvpn(NLMiramUDP443E3)[7993]: TUN/TAP device tun0 opened
 Fri Aug 30 11:28:32 2019 daemon.notice openvpn(NLMiramUDP443E3)[7993]: TUN/TAP TX queue length set to 100
 Fri Aug 30 11:28:32 2019 daemon.notice openvpn(NLMiramUDP443E3)[7993]: /sbin/ifconfig tun0 10.24.74.134 netmask 255.255.255.0 mtu 1500 broadcast 10.24.74.255
```

### 5. Test that all is working

Establish the VPN connection. Verify your routing with [traceroute](http://man.cx/traceroute%288%29 "http://man.cx/traceroute%288%29") and [traceroute6](http://man.cx/traceroute6%288%29 "http://man.cx/traceroute6%288%29").

```
traceroute openwrt.org
traceroute6 openwrt.org
```

Check your IP and DNS provider.

- [ipleak.net](https://ipleak.net/ "https://ipleak.net/")
- [dnsleaktest.com](https://www.dnsleaktest.com/ "https://www.dnsleaktest.com/")

On router:

- Go to **LuCI &gt; Status &gt; Wireguard** and look for peer device connected with an IPv4 or IPv6 address and with a recent handshake time
- Go to **LuCI &gt; Network &gt; Diagnostics** and **ipv4 ping** client device IP eg. 10.0.0.10

On client device depending on wireguard software:

- Check transfer traffic for tx &amp; rx
- Ping router internal lan IP
- Check public IP address in a browser – [https://whatsmyip.com](https://whatsmyip.com "https://whatsmyip.com") – should see public IP address of ISP for the router

### 6. Enable Network Killswitch (Optional, Recommended)

The “Network Killswitch” functionality, forces all traffic to go through the VPN. It's a fancy name for what is actually just a firewall rule.  
This is best for privacy and security as it will ensure that no traffic can reach the Internet bypassing the VPN you have set up.  
This also means that if the VPN connection is terminated, you lose access to the Internet, since no traffic is allowed outside of your VPN.

If you are setting up a Killswitch, it's strongly recommended to set the OpenVPN client to start and connect automatically on boot with the “Enable” checkbox, so that if the router is rebooted you don't lose Internet access (as without a VPN connected you will not be able to access the Internet anymore).

First remove the **tun** interface from **wan** zone in case you have followed the previous step 4.  
Go to **Network** -→ **Firewall**, click on the Edit button of the **Lan** zone.

Click on the Allow forward to destination zones: menu and deselect the WAN zone, then click on Save.

[![](/_media/docs/guide-user/services/vpn/openvpn/openwrt_openvpn_client_6_killswitch_4.png?w=600&tok=1edcfc)](/_media/docs/guide-user/services/vpn/openvpn/openwrt_openvpn_client_6_killswitch_4.png "docs:guide-user:services:vpn:openvpn:openwrt_openvpn_client_6_killswitch_4.png")

Then click on **Add** button under the **Zones list** to add a new zone.  
Select **Masquerading**, **MSS Clamping** and select the **LAN interface** in the **Allow forward from source zones** menu

[![](/_media/docs/guide-user/services/vpn/openvpn/openwrt_openvpn_client_6_killswitch_1.png?w=600&tok=4f4cdb)](/_media/docs/guide-user/services/vpn/openvpn/openwrt_openvpn_client_6_killswitch_1.png "docs:guide-user:services:vpn:openvpn:openwrt_openvpn_client_6_killswitch_1.png")

#### 6.1-a With Openwrt up to 18.06 and 19.07

If you followed point **4.1-a**, you should select your OpenWrt interface(s) in the **Covered Networks** menu and then click on **Save**.

[![](/_media/docs/guide-user/services/vpn/openvpn/openwrt_openvpn_client_6_killswitch_alternate_1.png?w=600&tok=59c330)](/_media/docs/guide-user/services/vpn/openvpn/openwrt_openvpn_client_6_killswitch_alternate_1.png "docs:guide-user:services:vpn:openvpn:openwrt_openvpn_client_6_killswitch_alternate_1.png")

Then on the bottom of the page, click on **Save and Apply** button as usual to confirm and save your changes.

#### 6.1-b With Openwrt 19.07 and later

If you followed point **4.1-b**, you click on the **Advanced Settings** tab, open the Covered Interfaces menu, write **tun+** in the open text box in the last.  
[![](/_media/docs/guide-user/services/vpn/openvpn/openwrt_openvpn_client_6_killswitch_2.png?w=600&tok=46346a)](/_media/docs/guide-user/services/vpn/openvpn/openwrt_openvpn_client_6_killswitch_2.png "docs:guide-user:services:vpn:openvpn:openwrt_openvpn_client_6_killswitch_2.png")  
Press Enter to add it.  
[![](/_media/docs/guide-user/services/vpn/openvpn/openwrt_openvpn_client_6_killswitch_3.png?w=600&tok=690b9b)](/_media/docs/guide-user/services/vpn/openvpn/openwrt_openvpn_client_6_killswitch_3.png "docs:guide-user:services:vpn:openvpn:openwrt_openvpn_client_6_killswitch_3.png")

This **tun+** is a regex that allows this rule to work with up to 10 tun interfaces (i.e. 10 VPNs) at the same time, if you have more, you need to adjust it. Then on the bottom of the page, click on **Save and Apply** button as usual to confirm and save your changes.

#### 6.2 Disable network Killswitch

Go to **Network** -→ **Firewall**, click on the Edit button of the Lan zone.

Click on the Allow forward to destination zones: menu and select the WAN zone again, then click on Save.  
[![](/_media/docs/guide-user/services/vpn/openvpn/openwrt_openvpn_client_6_killswitch_5.png?w=600&tok=f75291)](/_media/docs/guide-user/services/vpn/openvpn/openwrt_openvpn_client_6_killswitch_5.png "docs:guide-user:services:vpn:openvpn:openwrt_openvpn_client_6_killswitch_5.png")

Then on the bottom of the page, click on **Save and Apply** button as usual to confirm and save your changes.

## Troubleshooting

If you discover DNS is not working, use LuCI and navigate to **Network → Interfaces → LAN**, disable peer DNS and specify your preferred DNS servers in the **Use Custom DNS** field, e.g. `8.8.8.8` and `8.8.4.4` for Google DNS.

Open a ssh remote terminal connection to the router.

Collect and analyze the following information.

```
# Restart services
service log restart; service openvpn restart; sleep 10
 
# Log and status
logread -e openvpn; netstat -l -n -p | grep -e openvpn
 
# Runtime configuration
pgrep -f -a openvpn
ip address show; ip route show table all
ip rule show; ip -6 rule show; nft list ruleset
 
# Persistent configuration
uci show network; uci show firewall; uci show openvpn
head -v -n -0 /etc/openvpn/*.conf
```

## Alternative guide for OpenVPN client using LuCI

The link below is to a tutorial which was written for the BT Home Hub 5A and Windows Users in mind, and using free account from **ProtonVPN** offering access to Netherlands, Japan and USA. The guide is sufficiently generic to apply to most other OpenWrt routers with a working internet connection. It has been tested with a variety of different routers.

The current tutorial is for OpenWrt 19.07-22.03 using the .ovpn file upload function. Includes information on DNS resolver, Kill switch, and some popular VPN providers. It uses a **different** earlier OpenWrt firewall configuration than described in above wiki pages.

**If you are struggling with getting openvpn client to work using the instructions contained at the top of this wiki page, you may wish to download and study the tutorial '4-OpenVPN Client for HH5a.PDF' from the Dropbox folder found in:[Dropbox folder](https://www.dropbox.com/sh/c8cqmpc6cacs5n8/AAA2f8htk1uMitBckDW8Jq88a?dl=0 "https://www.dropbox.com/sh/c8cqmpc6cacs5n8/AAA2f8htk1uMitBckDW8Jq88a?dl=0")**

[![](/_media/media/bt/openwrt_openvpn_client_hh5a.jpg?w=400&tok=97f281)](/_detail/media/bt/openwrt_openvpn_client_hh5a.jpg?id=docs%3Aguide-user%3Aservices%3Avpn%3Aopenvpn%3Aclient-luci "media:bt:openwrt_openvpn_client_hh5a.jpg")
