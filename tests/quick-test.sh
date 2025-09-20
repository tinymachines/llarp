#!/bin/bash
# Quick Test - Verify basic cluster functionality

MASTER_IP="17.0.0.1"
WORKERS=("17.0.0.10" "17.0.0.11" "17.0.0.12")

echo "🚀 Quick Cluster Functionality Test"
echo "================================="

echo "1. Testing basic connectivity..."
for worker in "${WORKERS[@]}"; do
    if ping -c 1 -W 2 $worker >/dev/null 2>&1; then
        echo "  ✅ $worker reachable"
    else
        echo "  ❌ $worker unreachable"
    fi
done

echo ""
echo "2. Testing HAProxy status..."
if curl -s --max-time 3 http://$MASTER_IP:8404/stats | grep -q "Statistics"; then
    echo "  ✅ HAProxy statistics accessible"
else
    echo "  ❌ HAProxy statistics not accessible"
fi

echo ""
echo "3. Testing VPN connections..."
for worker in "${WORKERS[@]}"; do
    worker_num=$(($(echo $worker | cut -d. -f4) - 9))
    vpn_status=$(ssh -o ConnectTimeout=3 root@$worker "
        if ps | grep -q openvpn && ip link show tun0 >/dev/null 2>&1; then
            echo 'Connected'
        else
            echo 'Disconnected'
        fi
    " 2>/dev/null)

    if [ "$vpn_status" = "Connected" ]; then
        echo "  ✅ Worker $worker_num VPN connected"
    else
        echo "  ❌ Worker $worker_num VPN disconnected"
    fi
done

echo ""
echo "4. Testing load balancer ports..."
for port in 8080 1194 8404 9443; do
    if netstat -ln | grep -q ":$port.*LISTEN"; then
        echo "  ✅ Port $port listening"
    else
        echo "  ❌ Port $port not listening"
    fi
done

echo ""
echo "✅ Quick test complete!"
echo "Run './tests/run-all-tests.sh' for comprehensive testing"