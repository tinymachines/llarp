# banIP

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

## Introduction

[banIP](https://github.com/openwrt/packages/blob/master/net/banip/files/README.md "https://github.com/openwrt/packages/blob/master/net/banip/files/README.md") can block services using IP/CIDR lists including ASN and GeoIP lists.

## Command-line instructions

Install and enable banIP.

```
# Install packages
opkg update
opkg install banip
 
# Enable banIP
uci set banip.global.ban_enabled="1"
uci commit banip
service banip restart
```

## Extras

### Web interface

If you want to manage banIP settings using web interface. Install the necessary packages.

```
# Install packages
opkg update
opkg install luci-app-banip
service rpcd restart
```

### Blocking domains

Block domains by IP.

```
# Block domains
cat << EOF >> /etc/banip/banip.blocklist
example.com
example.net
EOF
service banip restart
```

### Blocking ASNs

Block Netflix by ASN.

```
# Block Netflix
uci add_list banip.global.ban_feed="asn"
uci add_list banip.global.ban_asn="2906"
uci add_list banip.global.ban_asn="40027"
uci commit banip
service banip restart
```

### Blocking countries

Block countries by GeoIP.

```
# Blocking countries
uci add_list banip.global.ban_feed="country"
uci add_list banip.global.ban_country="cn"
uci add_list banip.global.ban_country="ru"
uci commit banip
service banip restart
```

### Blocking DoH

Block DoH using a built-in list from [dibdot/DoH-IP-blocklists](https://github.com/dibdot/DoH-IP-blocklists "https://github.com/dibdot/DoH-IP-blocklists").

```
# Block DoH
uci add_list banip.global.ban_feed="doh"
uci commit banip
service banip restart
```

### Blocking WhatsApp

Block WhatsApp using a custom list from [HybridNetworks/whatsapp-cidr](https://github.com/HybridNetworks/whatsapp-cidr "https://github.com/HybridNetworks/whatsapp-cidr").

```
# Block WhatsApp
. /usr/share/libubox/jshn.sh
json_init
json_load_file /etc/banip/banip.custom.feeds 2> /dev/null
json_add_object "whatsapp"
json_add_string "descr" "WhatsApp CIDR"
json_add_string "url_4" "https://raw.githubusercontent.com/\
HybridNetworks/whatsapp-cidr/main/WhatsApp/whatsapp_cidr_ipv4.txt"
json_add_string "rule_4" "/^[^#]/{print \$1\",\"}"
json_close_object
json_dump > /etc/banip/banip.custom.feeds
uci add_list banip.global.ban_feed="whatsapp"
uci commit banip
service banip restart
```

### Blocking Facebook

Block Facebook using a custom list from [SecOps-Institute/FacebookIPLists](https://github.com/SecOps-Institute/FacebookIPLists "https://github.com/SecOps-Institute/FacebookIPLists").

```
# Block Facebook
. /usr/share/libubox/jshn.sh
json_init
json_load_file /etc/banip/banip.custom.feeds 2> /dev/null
json_add_object "facebook"
json_add_string "descr" "Facebook CIDR"
json_add_string "url_4" "https://raw.githubusercontent.com/\
SecOps-Institute/FacebookIPLists/master/facebook_ipv4_cidr_blocks.lst"
json_add_string "rule_4" "/^[^#]/{print \$1\",\"}"
json_add_string "url_6" "https://raw.githubusercontent.com/\
SecOps-Institute/FacebookIPLists/master/facebook_ipv6_list.lst"
json_add_string "rule_6" "/^[^#]/{print \$1\",\"}"
json_close_object
json_dump > /etc/banip/banip.custom.feeds
uci add_list banip.global.ban_feed="facebook"
uci commit banip
service banip restart
```

### Whitelisting networks

Whitelist network interfaces.

```
# Whitelist interfaces
uci add_list banip.global.ban_vlanallow="br-lan"
uci add_list banip.global.ban_vlanallow="br-dmz"
uci commit banip
service banip restart
```

### Whitelisting clients

Whitelist client MACs.

```
# Whitelist MACs
cat << EOF >> /etc/banip/banip.allowlist
11:22:33:44:55:66
aa:bb:cc:dd:ee:ff
EOF
service banip restart
```

### Whitelisting domains

Whitelist domains.

```
# Whitelist domains
cat << EOF >> /etc/banip/banip.allowlist
example.com
example.net
EOF
service banip restart
```

### Whitelist only

Allow only whitelisted entries.

```
# Whitelist only
uci set banip.global.ban_allowlistonly="1"
uci commit banip
service banip restart
```
