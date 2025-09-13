#!/bin/bash
# LLARP Script Lego: Create WiFi Network
# Created: $(date)
# Success: This script successfully created "llarp" WiFi network on router 15.0.0.1

ROUTER_IP="$1"
SSID="$2"
PASSWORD="$3"
RADIO="${4:-radio0}"

if [[ -z "$ROUTER_IP" || -z "$SSID" || -z "$PASSWORD" ]]; then
    echo "Usage: $0 <router_ip> <ssid> <password> [radio]"
    echo "Example: $0 15.0.0.1 llarp 11111111 radio0"
    exit 1
fi

SSH_OPTS="-o ConnectTimeout=10 -o StrictHostKeyChecking=no"

echo "📶 CREATING WIFI NETWORK: $SSID on $ROUTER_IP"
echo "=============================================="

ssh $SSH_OPTS root@$ROUTER_IP "
echo 'Current WiFi configuration:'
uci show wireless | grep ssid

echo -e '\nCreating new WiFi network: $SSID'
uci add wireless wifi-iface
uci set wireless.@wifi-iface[-1].device='$RADIO'
uci set wireless.@wifi-iface[-1].mode='ap'
uci set wireless.@wifi-iface[-1].ssid='$SSID'
uci set wireless.@wifi-iface[-1].encryption='psk2'
uci set wireless.@wifi-iface[-1].key='$PASSWORD'
uci set wireless.@wifi-iface[-1].network='lan'

echo 'Committing changes...'
uci commit wireless

echo 'Restarting WiFi...'
wifi

echo 'WiFi network created successfully!'
"

echo ""
echo "✅ WIFI NETWORK CREATION COMPLETE"
echo "📋 Verify with: ssh root@$ROUTER_IP 'iw dev'"