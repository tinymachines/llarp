# DHCP client scripts

See: [DHCP client](/docs/guide-user/network/ipv4/configuration#protocol_dhcp "docs:guide-user:network:ipv4:configuration"), [DHCPv6 client](/docs/guide-user/network/ipv6/configuration#protocol_dhcpv6 "docs:guide-user:network:ipv6:configuration")

## Troubleshooting

```
# Install packages 
opkg update
opkg install tcpdump
 
# Capture DHCP traffic
tcpdump -evni any udp port 67 & \
sleep 5; \
killall -SIGUSR1 udhcpc; \
sleep 5; \
killall tcpdump
 
# Capture DHCPv6 traffic
tcpdump -evni any udp port 547 & \
sleep 5; \
killall -SIGUSR1 odhcp6c; \
sleep 5; \
killall tcpdump
```

## DHCP client scripts

See also: [Providing ISP DNS with DHCP](/docs/guide-user/base-system/dhcp_configuration#providing_isp_dns_with_dhcp "docs:guide-user:base-system:dhcp_configuration"), [Hotplug](/docs/guide-user/base-system/hotplug "docs:guide-user:base-system:hotplug")

```
# Logging DHCP client
cat << "EOF" > /etc/udhcpc.user.d/00-logger
logger -t ${0##*/} ${@} $(env)
EOF
 
# Logging DHCPv6 client
cat << "EOF" > /etc/odhcp6c.user.d/00-logger
logger -t ${0##*/} ${@} $(env)
EOF
 
# Fetching new leases
ifup wan
ifup wan6
 
# Reading logs
logread -e dhcp.script
logread -e dhcpv6.script
 
# Checking status
ifstatus wan
ifstatus wan6
```

## References

- [udhcpc documentation](https://udhcp.busybox.net/README.udhcpc "https://udhcp.busybox.net/README.udhcpc")
- [odhcp6c documentation and examples](https://github.com/openwrt/odhcp6c#readme "https://github.com/openwrt/odhcp6c#readme")

## Extras

### Updating default route

Update default route.

```
cat << "EOF" > /etc/udhcpc.user.d/30-default-route
DHCPC_EVENT="${1}"
DHCPC_IF="${interface}"
DHCPC_GW="${router}"
case ${DHCPC_EVENT} in
(bound|renew) ;;
(*) exit 0 ;;
esac
ip route delete default dev "${DHCPC_IF}"
ip route add default via "${DHCPC_GW}" dev "${DHCPC_IF}"
EOF
```

### Updating IPv6 default route

Update IPv6 default route.

```
cat << "EOF" > /etc/odhcp6c.user.d/30-default-route
DHCPC_EVENT="${2}"
DHCPC_IF="${INTERFACE}"
DHCPC_GW="${SERVER}"
case ${DHCPC_EVENT} in
(bound|informed|updated|rebound|ra-updated) ;;
(*) exit 0 ;;
esac
ip -6 route delete default dev "${DHCPC_IF}"
ip -6 route add default via "${DHCPC_GW}" dev "${DHCPC_IF}"
EOF
```

### Updating DHCP server route

Update DHCP server route.

```
cat << "EOF" > /etc/udhcpc.user.d/30-dhcp-route
DHCPC_EVENT="${1}"
DHCPC_IF="${interface}"
DHCPC_SERV="${serverid}"
case ${DHCPC_EVENT} in
(bound|renew) ;;
(*) exit 0 ;;
esac
ip route delete "${DHCPC_SERV}" dev "${DHCPC_IF}"
ip route add "${DHCPC_SERV}" dev "${DHCPC_IF}"
EOF
```

### Providing ISP DNS with DHCP

Announce ISP DNS servers with DHCP.

```
cat << "EOF" > /etc/udhcpc.user.d/50-isp-dns
DHCP_POOL="lan"
DHCPC_EVENT="${1}"
DNS_SERV="${dns}"
case ${DHCPC_EVENT} in
(bound|renew) ;;
(*) exit 0 ;;
esac
for DHCP_POOL in ${DHCP_POOL}
do DHCP_OPT="$(uci -q get dhcp.${DHCP_POOL}.dhcp_option)"
for DHCP_OPT in ${DHCP_OPT}
do case ${DHCP_OPT%%,*} in
(6|option:dns-server)
uci del_list dhcp.${DHCP_POOL}.dhcp_option="${DHCP_OPT}" ;;
esac
done
uci add_list dhcp.${DHCP_POOL}.dhcp_option="6,${DNS_SERV// /,}"
done
uci commit dhcp
/etc/init.d/dnsmasq restart
EOF
```

Reconnect your clients to apply changes.

### Providing IPv6 ISP DNS with DHCPv6

Announce IPv6 ISP DNS servers with DHCPv6.

```
cat << "EOF" > /etc/odhcp6c.user.d/50-isp-dns
DHCP_POOL="lan"
DHCPC_EVENT="${2}"
DNS_SERV="${RA_DNS} ${RDNSS}"
case ${DHCPC_EVENT} in
(bound|informed|updated|rebound|ra-updated) ;;
(*) exit 0 ;;
esac
for DHCP_POOL in ${DHCP_POOL}
do uci -q delete dhcp.${DHCP_POOL}.dns
for DNS_SERV in ${DNS_SERV}
do uci add_list dhcp.${DHCP_POOL}.dns="${DNS_SERV}"
done
done
uci commit dhcp
/etc/init.d/odhcpd restart
EOF
```

Reconnect your clients to apply changes.

### Getting specific WAN IP address

Assuming your ISP provides a dynamic IP address with DHCP. Reconnect until you get the one matching a specific regexp. Delay for 10 seconds between reconnects.

```
cat << "EOF" > /etc/udhcpc.user.d/10-wan-ipaddr
WAN_ADDR="${ip}"
case ${WAN_ADDR} in
(??.???.*) exit 0 ;;
esac
sleep 10
ifup ${INTERFACE}
EOF
```

### Resolving WAN/LAN subnet conflicts

Automatically resolve WAN/LAN subnet conflicts. Change LAN subnet if it overlaps with WAN.

```
cat << "EOF" > /etc/udhcpc.user.d/10-lan-ipaddr
WAN_ADDR="${ip}"
LAN_IF="lan"
LAN_ADDR="$(uci -q get network.${LAN_IF}.ipaddr)"
case ${WAN_ADDR} in
(192.168.*) NEW_ADDR="172.16.1.1" ;;
(*) NEW_ADDR="192.168.1.1" ;;
esac
case ${NEW_ADDR} in
(${LAN_ADDR}) exit 0 ;;
esac
uci set network.${LAN_IF}.ipaddr="${NEW_ADDR}"
uci commit network
ifup ${LAN_IF}
EOF
```
