# PPPoSSH client

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

## Introduction

- This how-to describes the method for setting up PPPoSSH client on OpenWrt.
- Follow [PPPoSSH server](/docs/guide-user/services/vpn/pppossh/server "docs:guide-user:services:vpn:pppossh:server") for server setup and [PPPoSSH extras](/docs/guide-user/services/vpn/pppossh/extras "docs:guide-user:services:vpn:pppossh:extras") for additional tuning.

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
opkg install pppossh
 
# Configuration parameters
VPN_IF="vpn"
VPN_PORT="22"
VPN_SERV="SERVER_ADDRESS"
VPN_ADDR="192.168.9.2 192.168.9.1"
VPN_USER="root"
```

### 2. Key management

Generate and [exchange keys](/docs/guide-user/services/vpn/pppossh/start#key_management "docs:guide-user:services:vpn:pppossh:start") between server and client. Set up key-based authentication.

```
# Client private key
VPN_KEY="/etc/dropbear/dropbear_ed25519_host_key"
 
# Generate client public key
dropbearkey -y -f ${VPN_KEY} \
| sed -n -e "/^ssh-\S*\s/p" > sshclient.pub
 
# Server public key
VPN_PUB="$(cat sshserver.pub)"
 
# Configure PKI
mkdir -p /root/.ssh
cat << EOF >> /root/.ssh/known_hosts
${VPN_SERV} ${VPN_PUB% *}
EOF
cat << EOF >> /etc/sysupgrade.conf
/root/.ssh
EOF
```

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
uci set network.${VPN_IF}.proto="pppossh"
uci set network.${VPN_IF}.server="${VPN_SERV}"
uci set network.${VPN_IF}.port="${VPN_PORT}"
uci set network.${VPN_IF}.ipaddr="${VPN_ADDR% *}"
uci set network.${VPN_IF}.peeraddr="${VPN_ADDR#* }"
uci set network.${VPN_IF}.sshuser="${VPN_USER}"
uci add_list network.${VPN_IF}.identity="${VPN_KEY}"
uci set network.${VPN_IF}.ipv6="1"
uci commit network
service network restart
```

Configure [dynamic connection](/docs/guide-user/services/vpn/pppossh/extras#dynamic_connection "docs:guide-user:services:vpn:pppossh:extras") if necessary.

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
logread -e netifd -e pppd
 
# Runtime configuration
pgrep -f -a ssh; pgrep -f -a pppd
ip address show; ip route show table all
ip rule show; ip -6 rule show; nft list ruleset
ssh -i ${VPN_KEY} -p ${VPN_PORT} \
${VPN_USER}@${VPN_SERV} ubus call system board
 
# Persistent configuration
uci show network; uci show firewall
```
