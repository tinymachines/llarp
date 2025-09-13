#!/bin/bash
# LLARP Script Lego: Fix WAN Connectivity Issues
# Created: $(date)
# Purpose: Troubleshoot and fix WAN connectivity problems

ROUTER_IP="$1"

if [[ -z "$ROUTER_IP" ]]; then
    echo "Usage: $0 <router_ip>"
    exit 1
fi

SSH_OPTS="-o ConnectTimeout=10 -o StrictHostKeyChecking=no"

echo "🔧 WAN CONNECTIVITY FIX for $ROUTER_IP"
echo "====================================="

ssh $SSH_OPTS root@$ROUTER_IP "
echo '1. Current WAN configuration:'
uci show network.wan

echo -e '\n2. Testing current gateway:'
GATEWAY=\$(ip route | grep default | awk '{print \$3}')
echo \"Current gateway: \$GATEWAY\"
ping -c 2 \$GATEWAY

echo -e '\n3. Switching WAN to DHCP mode:'
uci set network.wan.proto='dhcp'
uci delete network.wan.ipaddr
uci delete network.wan.netmask  
uci delete network.wan.gateway
uci delete network.wan.dns
uci commit network

echo -e '\n4. Restarting network:'
/etc/init.d/network restart

echo -e '\n5. Waiting for DHCP...'
sleep 10

echo -e '\n6. New WAN configuration:'
uci show network.wan

echo -e '\n7. New IP and routing:'
ip addr show wan
ip route show

echo -e '\n8. Testing new connectivity:'
GATEWAY=\$(ip route | grep default | awk '{print \$3}')
echo \"New gateway: \$GATEWAY\"
ping -c 3 \$GATEWAY

echo -e '\n9. Internet test:'
ping -c 3 8.8.8.8
"

echo ""
echo "✅ WAN CONNECTIVITY FIX ATTEMPT COMPLETE"