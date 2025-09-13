# PPPoSSH server

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

## Introduction

- This how-to describes the method for setting up PPPoSSH server on OpenWrt.
- Follow [PPPoSSH client](/docs/guide-user/services/vpn/pppossh/client "docs:guide-user:services:vpn:pppossh:client") for client setup and [PPPoSSH extras](/docs/guide-user/services/vpn/pppossh/extras "docs:guide-user:services:vpn:pppossh:extras") for additional tuning.

## Goals

- Encrypt your internet connection to enforce security and privacy.
  
  - Prevent traffic leaks and spoofing on the client side.
- Bypass regional restrictions using commercial providers.
  
  - Escape client side content filters and internet censorship.
- Access your LAN services remotely without port forwarding.

## Command-line instructions

### 1. Preparation

Specify configuration parameters for VPN server.

```
# Configuration parameters
VPN_PORT="22"
```

### 2. Key management

Generate and [exchange keys](/docs/guide-user/services/vpn/pppossh/start#key_management "docs:guide-user:services:vpn:pppossh:start") between server and client. Set up key-based authentication.

```
# Server private key
VPN_KEY="/etc/dropbear/dropbear_ed25519_host_key"
 
# Generate server public key
dropbearkey -y -f ${VPN_KEY} \
| sed -n -e "/^ssh-\S*\s/p" > sshserver.pub
 
# Client public key
VPN_PUB="$(cat sshclient.pub)"
 
# Configure PKI
cat << EOF >> /etc/dropbear/authorized_keys
${VPN_PUB}
EOF
```

### 3. Firewall

Consider VPN network as private. Assign VPN interface to LAN zone to minimize firewall setup. Allow access to VPN server from WAN zone.

```
# Configure firewall
uci rename firewall.@zone[0]="lan"
uci rename firewall.@zone[1]="wan"
uci del_list firewall.lan.device="ppp+"
uci add_list firewall.lan.device="ppp+"
uci -q delete firewall.pppossh
uci set firewall.pppossh="rule"
uci set firewall.pppossh.name="Allow-PPPoSSH"
uci set firewall.pppossh.src="wan"
uci set firewall.pppossh.dest_port="${VPN_PORT}"
uci set firewall.pppossh.proto="tcp"
uci set firewall.pppossh.target="ACCEPT"
uci commit firewall
service firewall restart
```

### 4. VPN service

Configure VPN service. Disable password authentication.

```
# Configure VPN service
uci set dropbear.@dropbear[0].Port="${VPN_PORT}"
uci set dropbear.@dropbear[0].PasswordAuth="0"
uci set dropbear.@dropbear[0].RootPasswordAuth="0"
uci commit dropbear
service dropbear restart
```

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
service log restart; service dropbear restart; sleep 10
 
# Log and status
logread -e dropbear; netstat -l -n -p | grep -e dropbear
 
# Runtime configuration
pgrep -f -a dropbear; pgrep -f -a pppd
ip address show; ip route show table all
ip rule show; ip -6 rule show; nft list ruleset
 
# Persistent configuration
uci show network; uci show firewall; uci show dropbear
```
