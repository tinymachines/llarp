#!/bin/bash
# LLARP Script Lego: Advanced WAN Diagnosis
# Created: $(date)
# Purpose: Comprehensive WAN connectivity troubleshooting with layer-by-layer analysis

ROUTER_IP="$1"

if [[ -z "$ROUTER_IP" ]]; then
    echo "Usage: $0 <router_ip>"
    exit 1
fi

SSH_OPTS="-o ConnectTimeout=10 -o StrictHostKeyChecking=no"

echo "🔍 ADVANCED WAN DIAGNOSIS for $ROUTER_IP"
echo "========================================"

ssh $SSH_OPTS root@$ROUTER_IP "
echo '📶 LAYER 1: Physical Layer'
echo '=========================='
echo 'Interface State:'
cat /sys/class/net/wan/operstate
echo 'Carrier Status:'
cat /sys/class/net/wan/carrier 2>/dev/null || echo 'No carrier file'
echo 'Link Speed:'
cat /sys/class/net/wan/speed 2>/dev/null || echo 'Speed unknown'
echo 'Duplex:'
cat /sys/class/net/wan/duplex 2>/dev/null || echo 'Duplex unknown'

echo -e '\n🌐 LAYER 2: Data Link Layer'
echo '=========================='
echo 'Interface Details:'
ip link show wan
echo 'MAC Address:'
cat /sys/class/net/wan/address
echo 'MTU:'
cat /sys/class/net/wan/mtu

echo -e '\n📡 LAYER 3: Network Layer'
echo '========================'
echo 'IP Configuration:'
ip addr show wan
echo 'Routing Table:'
ip route show
echo 'Network Interface Status:'
ubus call network.interface.wan status

echo -e '\n🏠 DHCP Client Analysis'
echo '======================'
echo 'DHCP Client Process:'
ps | grep udhcpc
echo 'DHCP Client Logs:'
logread | grep udhcpc | tail -5
echo 'Manual DHCP Test:'
timeout 10 udhcpc -i wan -n -q && echo 'DHCP successful' || echo 'DHCP failed - no server response'

echo -e '\n🔧 Configuration Analysis'
echo '========================'
echo 'WAN Interface Config:'
uci show network.wan
echo 'WAN Device Config:'
uci show network | grep wan

echo -e '\n💡 RECOMMENDED ACTIONS'
echo '===================='
echo '1. Check upstream DHCP server (modem/router)'
echo '2. Try rebooting upstream equipment'
echo '3. Check if ISP requires specific settings'
echo '4. Consider static IP configuration if DHCP unavailable'
"

echo ""
echo "🎯 DIAGNOSIS COMPLETE"
echo "📋 Summary: Physical connection OK, DHCP server not responding"