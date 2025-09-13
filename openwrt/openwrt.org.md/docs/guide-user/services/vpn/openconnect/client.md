# OpenConnect client

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

## Introduction

- This how-to describes the method for setting up [openconnect](/packages/pkgdata/openconnect "packages:pkgdata:openconnect") client on OpenWrt.
- Follow [OpenConnect server](/docs/guide-user/services/vpn/openconnect/server "docs:guide-user:services:vpn:openconnect:server") for server setup and [OpenConnect extras](/docs/guide-user/services/vpn/openconnect/extras "docs:guide-user:services:vpn:openconnect:extras") for additional tuning.

## Goals

- Encrypt your internet connection to enforce security and privacy.
  
  - Prevent traffic leaks and spoofing on the client side.
- Bypass regional restrictions using commercial providers.
  
  - Escape client side content filters and internet censorship.
- Access your LAN services remotely without port forwarding.

## Command-line instructions

### 1. Preparation

Install the required packages. Specify configuration parameters for VPN client.

```
# Install packages
opkg update
opkg install openconnect openssl-util
 
# Configuration parameters
VPN_IF="vpn"
VPN_SERV="SERVER_ADDRESS"
VPN_PORT="4443"
VPN_USER="USERNAME"
VPN_PASS="PASSWORD"
```

### 2. Key management

Run the code below directly on the VPN server if you can or [fetch certificate](/docs/guide-user/services/vpn/openconnect/extras#server_certificate "docs:guide-user:services:vpn:openconnect:extras") from the server and generate the hash locally:

```
# Generate certificate hash
VPN_CERT="server-cert.pem"
VPN_HASH="pin-sha256:$(openssl x509 -in ${VPN_CERT} -pubkey -noout \
| openssl pkey -pubin -outform der \
| openssl dgst -sha256 -binary \
| openssl enc -base64)"
```

Variable `$VPN_HASH` will be used in the example below. Alternatively print its value with `echo $VPN_HASH` and use it with `serverhash` in the configuration file or in “VPN Server's certificate SHA1 hash” in Luci.

### 3. Firewall

Consider VPN network as public. Assign VPN interface to WAN zone to minimize firewall setup.

```
# Configure firewall
uci rename firewall.@zone[0]="lan"
uci rename firewall.@zone[1]="wan"
uci del_list firewall.wan.network="${VPN_IF}"
uci add_list firewall.wan.network="${VPN_IF}"
uci commit firewall
service firewall restart
```

### 4. Network

Set up VPN interface.

```
# Configure network
uci -q delete network.${VPN_IF}
uci set network.${VPN_IF}="interface"
uci set network.${VPN_IF}.proto="openconnect"
uci set network.${VPN_IF}.server="${VPN_SERV}"
uci set network.${VPN_IF}.port="${VPN_PORT}"
uci set network.${VPN_IF}.username="${VPN_USER}"
uci set network.${VPN_IF}.password="${VPN_PASS}"
uci set network.${VPN_IF}.serverhash="${VPN_HASH}"
uci commit network
service network restart
```

See all available OpenConnect protocol options [here](/docs/guide-user/network/tunneling_interface_protocols#protocol_openconnect_openconnect_vpn "docs:guide-user:network:tunneling_interface_protocols") and a sample configuration [here](https://github.com/openwrt/packages/blob/master/net/openconnect/README "https://github.com/openwrt/packages/blob/master/net/openconnect/README").

Disable [gateway redirection](/docs/guide-user/services/vpn/openconnect/extras#gateway_redirection "docs:guide-user:services:vpn:openconnect:extras") and/or [keep the existing gateway](/docs/guide-user/services/vpn/openconnect/extras#keep_existing_gateway "docs:guide-user:services:vpn:openconnect:extras") if necessary.

## Web-based configuration

Web-based configuration is available through [luci-proto-openconnect](/packages/pkgdata/luci-proto-openconnect "packages:pkgdata:luci-proto-openconnect") package.

```
# Install packages
opkg update
opkg install luci-proto-openconnect
service rpcd restart
```

Open Luci web interface and navigate to Network → Interfaces, then Add new interface… → Protocol: OpenConnect

Currently not all the [options](/docs/guide-user/network/tunneling_interface_protocols#protocol_openconnect_openconnect_vpn "docs:guide-user:network:tunneling_interface_protocols") can be set through Luci, so manual changes in `/etc/config/network` might be needed.

## Testing

Establish the VPN connection. Verify your routing with [traceroute](http://man.cx/traceroute%288%29 "http://man.cx/traceroute%288%29") and [traceroute6](http://man.cx/traceroute6%288%29 "http://man.cx/traceroute6%288%29").

```
traceroute openwrt.org
traceroute6 openwrt.org
```

Check your external IP address and DNS provider in use

- [WhatIsMyIP](https://whatsmyip.com/ "https://whatsmyip.com/") should show a public IP address of VPN server if all the traffic is routed through the VPN connection
- [ipleak.net](https://ipleak.net/ "https://ipleak.net/"), [dnsleaktest.com](https://www.dnsleaktest.com/ "https://www.dnsleaktest.com/") results depend on whether DNS traffic is routed through the VPN connection

On router:

- Go to **LuCI &gt; Network &gt; Interfaces** and look for VPN interface state, its IP address and Tx/Rx counters
- Go to **LuCI &gt; Network &gt; Diagnostics** and **ipv4 ping** any address that should be accessible through the VPN connection

## Troubleshooting

Collect and analyze the following information.

```
# Restart services
service log restart; service network restart; sleep 10
 
# Log and status
logread -e openconnect
 
# Runtime configuration
pgrep -f -a openconnect
ip address show; ip route show table all
ip rule show; ip -6 rule show; nft list ruleset
 
# Persistent configuration
uci show network; uci show firewall
```
