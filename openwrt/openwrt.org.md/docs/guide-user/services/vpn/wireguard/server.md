# WireGuard server

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

## Introduction

- This how-to describes the method for setting up [WireGuard](https://en.wikipedia.org/wiki/WireGuard "https://en.wikipedia.org/wiki/WireGuard") server on OpenWrt.
- Follow [WireGuard client](/docs/guide-user/services/vpn/wireguard/client "docs:guide-user:services:vpn:wireguard:client") for client setup and [WireGuard extras](/docs/guide-user/services/vpn/wireguard/extras "docs:guide-user:services:vpn:wireguard:extras") for additional tuning.

## Goals

- Encrypt your internet connection to enforce security and privacy.
  
  - Prevent traffic leaks and spoofing on the client side.
- Bypass regional restrictions using commercial providers.
  
  - Escape client side content filters and internet censorship.
- Access your LAN services remotely without port forwarding.

## Command-line instructions

### 1. Preparation

Install the required packages. Specify configuration parameters for VPN server.

```
# Install packages
opkg update
opkg install wireguard-tools
 
# Configuration parameters
VPN_IF="vpn"
VPN_PORT="51820"
VPN_ADDR="192.168.9.1/24"
VPN_ADDR6="fd00:9::1/64"
```

### 2. Key management

Generate and [exchange keys](/docs/guide-user/services/vpn/wireguard/basics#key_management "docs:guide-user:services:vpn:wireguard:basics") between server and client.

```
# Generate keys
umask go=
wg genkey | tee wgserver.key | wg pubkey > wgserver.pub
wg genkey | tee wgclient.key | wg pubkey > wgclient.pub
wg genpsk > wgclient.psk
 
# Server private key
VPN_KEY="$(cat wgserver.key)"
 
# Pre-shared key
VPN_PSK="$(cat wgclient.psk)"
 
# Client public key
VPN_PUB="$(cat wgclient.pub)"
```

### 3. Firewall

Consider VPN network as private. Assign VPN interface to LAN zone to minimize firewall setup. Allow access to VPN server from WAN zone.

```
# Configure firewall
uci rename firewall.@zone[0]="lan"
uci rename firewall.@zone[1]="wan"
uci del_list firewall.lan.network="${VPN_IF}"
uci add_list firewall.lan.network="${VPN_IF}"
uci -q delete firewall.wg
uci set firewall.wg="rule"
uci set firewall.wg.name="Allow-WireGuard"
uci set firewall.wg.src="wan"
uci set firewall.wg.dest_port="${VPN_PORT}"
uci set firewall.wg.proto="udp"
uci set firewall.wg.target="ACCEPT"
uci commit firewall
service firewall restart
```

### 4. Network

Configure VPN interface and peers.

```
# Configure network
uci -q delete network.${VPN_IF}
uci set network.${VPN_IF}="interface"
uci set network.${VPN_IF}.proto="wireguard"
uci set network.${VPN_IF}.private_key="${VPN_KEY}"
uci set network.${VPN_IF}.listen_port="${VPN_PORT}"
uci add_list network.${VPN_IF}.addresses="${VPN_ADDR}"
uci add_list network.${VPN_IF}.addresses="${VPN_ADDR6}"
 
# Add VPN peers
uci -q delete network.wgclient
uci set network.wgclient="wireguard_${VPN_IF}"
uci set network.wgclient.public_key="${VPN_PUB}"
uci set network.wgclient.preshared_key="${VPN_PSK}"
uci add_list network.wgclient.allowed_ips="${VPN_ADDR%.*}.2/32"
uci add_list network.wgclient.allowed_ips="${VPN_ADDR6%:*}:2/128"
uci commit network
service network restart
```

* * *

## LuCI Web Interface instructions

### 1. Installing packages

Navigate to **LuCI → System → Software** and install the package [luci-proto-wireguard](/packages/pkgdata/luci-proto-wireguard "packages:pkgdata:luci-proto-wireguard").

Optionally install the package [qrencode](/packages/pkgdata/qrencode "packages:pkgdata:qrencode") to allow creation of a QR code when creating a peer configuration for simple import onto a phone wireguard client.

### 2. Restarting services

Navigate to **LuCI → System → Startup → Initscripts** and click on **network → Restart**.

### 3. Add WireGuard Network Interface

To create a new WireGuard interface go to **LuCI → Network → Interfaces → Add new interface...**

- Select **WireGuard VPN** from the **Protocol** dropdown menu.
- Name the interface **wg0** (or whatever is preferred)
- Click on **Create Interface** to create it and open it for editing

### 4. Configure the WireGuard Network Interface

In the open edit window of the interface configure the following:

- Click on **Generate new key pair** to populate the private and public keys
- Listen port: **51820** or preferred port
- IP addresses: 10.0.0.1/24 or preferred internal VPN IPv4 address for the WireGuard server interface end of the VPN
- Save this configuration

### 5. Configure WireGuard Peers

To create a new WireGuard peer configuration go to **LuCI → Network → Interfaces → wg0 → Edit → Peers**

- Click on **Add peer**
- Click on **Generate new key pair** to populate the public and private key fields
- Allowed IPs: 10.0.0.10/24 or other address in IP range being used
- Enable **Route allowed IPs**
- Endpoint port: 51820
- Persistent Keep Alive: 25
- Save

Click on **Edit** for the peer just created

- Click on **Generate configuration...** and under Connection endpoint select:
- \* If connecting from a publicly accessible IPv4 address the router wan interface IPv4 address
- \* If connecting from a publicly accessible IPv6 address the router wan interface IPv6 address
- \* If using a publicly accessible hostname enter as a custom entry

To transfer the peer configuration to the client device either:

- Use a Wireguard client on a phone / tablet that can scan the generated QR code or
- Copy and paste the generated configuration data into a device.conf file for import into a WireGuard client

Go to **LuCI → Network → Interfaces** and restart the **wg0 interface**

### 6. Configure Firewall for WireGuard traffic

Go to **LuCI → Network → Firewall → General Settings** and under **Zones** add a new zone:

- Name: **WireguardVPN** (or preferred name)
- Input: **accept**
- Output: **accept**
- Intra zone forward: **accept**
- Masquerading: **checked**
- MSS Clamping: **checked**
- Covered networks: **wg0**
- Allow forward to destination zones: **lan and wan**
- Allow forward from source zones: **lan**
- Save

Create rule to allow IPv4 &amp; IPv6 traffic through from internet for connecting from client device using IPv4 (if router has public IPv4 address) or from client device using IPv6 (if router has public IPv6 address available).

Go to **LuCI → Network → Firewall → Traffic Rules**

- Name: **WireGuard-incoming** (or preferred name)
- Protocol: **UDP**
- Source zone: **wan**
- Source address: **-- add IP --**
- Source port: **any**
- Destination zone: **Device**
- Destination address: **-- add IP--**
- Destination port: **51820**
- Action: **accept**
- Save, Save &amp; apply

Note: If only IPv4 is being used to connect to the WireGuard server the above firewall traffic rule could be replaced with a **Port Forward** rule instead.

If you have an upstream ISP router between the Openwrt router configured as a WireGuard server and the internet then port 51820 will also need to be opened up for IPv4/IPv6 traffic to the Openwrt router.

## Testing

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

## Troubleshooting

Collect and analyze the following information.

```
# Restart services
service log restart; service network restart; sleep 10
 
# Log and status
logread -e vpn; netstat -l -n -p | grep -e "^udp\s.*\s-$"
 
# Runtime configuration
pgrep -f -a wg; wg show; wg showconf wg0
ip address show; ip route show table all
ip rule show; ip -6 rule show; nft list ruleset
 
# Persistent configuration
uci show network; uci show firewall; crontab -l
```
