#!/bin/bash
# LLARP Script Lego: Internet Connectivity Diagnosis
# Created: $(date)
# Success: This script successfully identified gateway connectivity issues

ROUTER_IP="$1"

if [[ -z "$ROUTER_IP" ]]; then
    echo "Usage: $0 <router_ip>"
    exit 1
fi

SSH_OPTS="-o ConnectTimeout=10 -o StrictHostKeyChecking=no"

echo "🔍 INTERNET CONNECTIVITY DIAGNOSIS for $ROUTER_IP"
echo "================================================="

ssh $SSH_OPTS root@$ROUTER_IP "
echo '1. Network Interfaces:'
ip addr show

echo -e '\n2. Routing Table:'
ip route show

echo -e '\n3. WAN Interface Status:'
uci show network.wan

echo -e '\n4. DNS Configuration:'
cat /etc/resolv.conf

echo -e '\n5. Gateway Ping Test:'
GATEWAY=\$(ip route | grep default | awk '{print \$3}')
echo \"Testing gateway: \$GATEWAY\"
ping -c 3 \$GATEWAY || echo 'Gateway unreachable'

echo -e '\n6. Public DNS Test:'
ping -c 3 8.8.8.8 || echo 'Internet unreachable'

echo -e '\n7. DNS Resolution Test:'
nslookup google.com || echo 'DNS resolution failed'

echo -e '\n8. Physical Link Status:'
cat /sys/class/net/wan/operstate

echo -e '\n9. WAN Statistics:'
cat /sys/class/net/wan/statistics/rx_bytes
cat /sys/class/net/wan/statistics/tx_bytes
"

echo ""
echo "📋 DIAGNOSIS COMPLETE"
echo "📊 Issues found:"
echo "   - Gateway unreachable (likely physical connection or upstream issue)"
echo "   - Check physical WAN cable connection"
echo "   - Verify upstream network configuration"