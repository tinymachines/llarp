# Tor extras

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

## Introduction

- This how-to describes the most common [Tor](https://en.wikipedia.org/wiki/Tor_%28anonymity_network%29 "https://en.wikipedia.org/wiki/Tor_(anonymity_network)") tuning scenarios adapted for OpenWrt.
- Follow [Tor client](/docs/guide-user/services/tor/client "docs:guide-user:services:tor:client") for client setup and [Tor hidden service](/docs/guide-user/services/tor/hs "docs:guide-user:services:tor:hs") for onion service setup.
- Follow [Random generator](/docs/guide-user/services/rng "docs:guide-user:services:rng") to overcome low entropy issues.

## Extras

### References

- [Tor manual](https://2019.www.torproject.org/docs/tor-manual.html.en "https://2019.www.torproject.org/docs/tor-manual.html.en")
- [Tor community documentation](https://community.torproject.org/ "https://community.torproject.org/")
- [Tor frequently asked questions](https://support.torproject.org/ "https://support.torproject.org/")

### Exit nodes

Exclude dubious exit nodes by their [country code](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2 "https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2").

```
# Install packages
opkg update
opkg install tor-geoip
 
# Exclude exit nodes
cat << EOF >> /etc/tor/custom
ExcludeExitNodes {??}, {by}, {kz}, {ru}, {ua}
EOF
service tor restart
```

### Socks proxy

Enable Tor socks proxy.

```
# Enable Tor socks proxy
cat << EOF >> /etc/tor/custom
SOCKSPort 0.0.0.0:9050
SOCKSPort [::]:9050
EOF
service tor restart
```

### Pluggable transports

Circumvent ISP restrictions with [bridges](https://tb-manual.torproject.org/bridges/ "https://tb-manual.torproject.org/bridges/").

```
# Install packages
opkg update
opkg install obfs4proxy
 
# Configure bridges
cat << EOF >> /etc/tor/custom
UseBridges 1
ClientTransportPlugin obfs4 exec /usr/bin/obfs4proxy
Bridge obfs4 154.35.22.10:443 8FB9F4319E89E5C6223052AA525A192AFBC85D55 \
cert=GGGS1TX4R81m3r0HBl79wKy1OtPPNR2CZUIrHjkRg65Vc2VR8fOyo64f9kmT1UAFG7j0HQ iat-mode=0
Bridge obfs4 154.35.22.12:80 00DC6C4FA49A65BD1472993CF6730D54F11E0DBB \
cert=N86E9hKXXXVz6G7w2z8wFfhIDztDAzZ/3poxVePHEYjbKDWzjkRDccFMAnhK75fc65pYSg iat-mode=0
EOF
service tor restart
```

### Onion services

Allow remote access to the router with [Tor Onion services](/docs/guide-user/services/tor/hs "docs:guide-user:services:tor:hs"). Be sure to enable [client authorization](/docs/guide-user/services/tor/extras#client_authorization "docs:guide-user:services:tor:extras").

```
# Install packages
opkg update
opkg install tor-hs
 
# Configure Tor onion service
uci -q delete tor-hs.ssh
uci set tor-hs.ssh="hidden-service"
uci set tor-hs.ssh.Name="ssh"
uci set tor-hs.ssh.Enabled="1"
uci set tor-hs.ssh.IPv4="127.0.0.1"
uci add_list tor-hs.ssh.PublicLocalPort="22;22"
uci commit tor-hs
service tor-hs restart
 
# Fetch onion service hostname
cat /etc/tor/hidden_service/ssh/hostname
```

Access the onion service from Tor client.

```
# Install packages
opkg update
opkg install torsocks
 
# Access onion service
torsocks ssh ${TOR_HOST}
```

### Client authorization

Secure access to onion services with [client authorization](https://community.torproject.org/onion-services/advanced/client-auth/ "https://community.torproject.org/onion-services/advanced/client-auth/").

```
# Install packages
opkg update
opkg install openssl-util coreutils-base32
 
# Enable client authorization
openssl genpkey -algorithm x25519 -out /etc/tor/hidden_service.pem
TOR_KEY="$(openssl pkey -in /etc/tor/hidden_service.pem -outform der \
| tail -c 32 \
| base32 \
| sed -e "s/=//g")"
TOR_PUB="$(openssl pkey -in /etc/tor/hidden_service.pem -outform der -pubout \
| tail -c 32 \
| base32 \
| sed -e "s/=//g")"
TOR_HOST="$(cat /etc/tor/hidden_service/ssh/hostname)"
cat << EOF > client.auth_private
${TOR_HOST%.onion}:descriptor:x25519:${TOR_KEY}
EOF
cat << EOF > /etc/tor/hidden_service/ssh/authorized_clients/client.auth
descriptor:x25519:${TOR_PUB}
EOF
chown -R tor:tor /etc/tor/hidden_service/
service tor restart
```

Configure authorization on the client using the private key.

```
# Configure client authorization
cat << EOF >> /etc/tor/custom
ClientOnionAuthDir /etc/tor/onion_auth
EOF
umask go=
TOR_AUTH="$(cat client.auth_private)"
TOR_HOST="${TOR_AUTH%%:*}.onion"
mkdir -p /etc/tor/onion_auth
cat << EOF > /etc/tor/onion_auth/client.auth_private
${TOR_AUTH}
EOF
chown -R tor:tor /etc/tor/onion_auth
service tor restart
```

### Selective routing

Route only specific domains to Tor network. Selectively utilize DNS over Tor. Beware of privacy issues as each site may use multiple domains.

```
# Process traffic by destination
for IPV in 4 6
do case ${IPV} in
(4) TOR_DST="172.16.0.0/12" ;;
(6) TOR_DST="fc00::/8" ;;
esac
uci -q delete firewall.tcp_int${IPV%4}
uci set firewall.tcp_int${IPV%4}="redirect"
uci set firewall.tcp_int${IPV%4}.name="Intercept-TCP"
uci set firewall.tcp_int${IPV%4}.src="lan"
uci set firewall.tcp_int${IPV%4}.src_dip="${TOR_DST}"
uci set firewall.tcp_int${IPV%4}.src_dport="0-65535"
uci set firewall.tcp_int${IPV%4}.dest_port="9040"
uci set firewall.tcp_int${IPV%4}.proto="tcp"
uci set firewall.tcp_int${IPV%4}.target="DNAT"
uci -q delete firewall.lan_wan${IPV%4}
uci set firewall.lan_wan${IPV%4}="rule"
uci set firewall.lan_wan${IPV%4}.name="Allow-NonTor-Forward"
uci set firewall.lan_wan${IPV%4}.src="lan"
uci set firewall.lan_wan${IPV%4}.dest="wan"
uci set firewall.lan_wan${IPV%4}.dest_ip="!${TOR_DST}"
uci set firewall.lan_wan${IPV%4}.proto="all"
uci set firewall.lan_wan${IPV%4}.target="ACCEPT"
done
uci -q delete firewall.tor_nft
uci commit firewall
service firewall restart
 
# Configure Tor domains
uci -q delete dhcp.@dnsmasq[0].noresolv
uci -q delete dhcp.@dnsmasq[0].server
uci add_list dhcp.@dnsmasq[0].server="/onion/127.0.0.1#9053"
uci add_list dhcp.@dnsmasq[0].server="/example.com/127.0.0.1#9053"
uci add_list dhcp.@dnsmasq[0].server="/example.net/127.0.0.1#9053"
uci commit dhcp
service dnsmasq restart
```

### Hardware acceleration

Some devices have [hardware crypto accelerator chips](/docs/techref/hardware/cryptographic.hardware.accelerators "docs:techref:hardware:cryptographic.hardware.accelerators"). Enabling Tor to use a hardware accelerator offloads CPU pressure. Because Tor uses the openssl library acceleration must also be enabled by openssl, which can be done by following these [instructions](/docs/techref/hardware/cryptographic.hardware.accelerators#cryptodev "docs:techref:hardware:cryptographic.hardware.accelerators"). Then hardware acceleration must be enabled in Tor. In the Tor notice log after the above setup, you should notice multiple lines like **`Default OpenSSL engine for 3DES-CBC is /dev/crypto engine [devcrypto]`** .

```
# Enable Tor hardware acceleration
cat << EOF >> /etc/tor/custom
HardwareAccel 1
EOF
service tor restart
```

### Automated

Automated Tor client installation.

```
URL="https://openwrt.org/_export/code/docs/guide-user/services/tor/client"
cat << EOF > tor-client.sh
$(wget -U "" -O - "${URL}?codeblock=0")
$(wget -U "" -O - "${URL}?codeblock=1")
$(wget -U "" -O - "${URL}?codeblock=2")
$(wget -U "" -O - "${URL}?codeblock=3")
EOF
sh tor-client.sh
```
