#!/bin/bash
# Parameterized Configuration script for Lazarus Worker Boxes (Switch-based setup)
# Usage: ./configure-worker-box.sh <box_number> [hostname]
#
# Examples:
#   ./configure-worker-box.sh 1           # Sets up Box 1 as 17.0.0.10 with hostname 'lazarus-worker1'
#   ./configure-worker-box.sh 2           # Sets up Box 2 as 17.0.0.11 with hostname 'lazarus-worker2'
#   ./configure-worker-box.sh 5 vpn-exit5 # Sets up Box 5 as 17.0.0.14 with hostname 'vpn-exit5'

if [ $# -lt 1 ]; then
    echo "Usage: $0 <box_number> [hostname]"
    echo ""
    echo "Examples:"
    echo "  $0 1           # Box 1 -> 17.0.0.10, hostname 'lazarus-worker1'"
    echo "  $0 2           # Box 2 -> 17.0.0.11, hostname 'lazarus-worker2'"
    echo "  $0 5 vpn-exit5 # Box 5 -> 17.0.0.14, hostname 'vpn-exit5'"
    echo ""
    echo "IP Formula: 17.0.0.<9 + box_number>"
    exit 1
fi

BOX_NUMBER=$1
HOSTNAME=${2:-"lazarus-worker${BOX_NUMBER}"}

# Calculate IP address: 17.0.0.10, 17.0.0.11, 17.0.0.12, etc.
BOX_IP="17.0.0.$((9 + BOX_NUMBER))"

echo "=========================================="
echo "Configuring Lazarus Worker Box ${BOX_NUMBER}"
echo "=========================================="
echo "Box Number: ${BOX_NUMBER}"
echo "IP Address: ${BOX_IP}"
echo "Hostname: ${HOSTNAME}"
echo "Gateway: 17.0.0.1"
echo "Role: VPN Endpoint Worker"
echo "=========================================="

read -p "Continue with configuration? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Configuration cancelled."
    exit 1
fi

echo "Starting configuration..."

# Change network configuration for switch setup
echo "Setting IP address to ${BOX_IP}..."
uci set network.lan.ipaddr="${BOX_IP}"
uci set network.lan.gateway='17.0.0.1'

# Clean up any multi-segment network configs (from master image)
echo "Cleaning up multi-segment network configs..."
uci delete network.lan2 2>/dev/null || true
uci delete network.lan3 2>/dev/null || true

# Remove load balancer services (this box is VPN endpoint only)
echo "Stopping and disabling load balancer services..."
/etc/init.d/haproxy stop 2>/dev/null || true
/etc/init.d/haproxy disable 2>/dev/null || true
/etc/init.d/mwan3 stop 2>/dev/null || true
/etc/init.d/mwan3 disable 2>/dev/null || true

# Clean up HAProxy and mwan3 configs
echo "Removing load balancer configurations..."
rm -f /etc/haproxy.cfg
uci delete mwan3.wan1 2>/dev/null || true
uci delete mwan3.wan2 2>/dev/null || true
uci delete mwan3.wan3 2>/dev/null || true
uci delete mwan3.wan1_m1_w3 2>/dev/null || true
uci delete mwan3.wan2_m1_w3 2>/dev/null || true
uci delete mwan3.wan3_m1_w3 2>/dev/null || true
uci delete mwan3.balanced 2>/dev/null || true
uci delete mwan3.default_rule 2>/dev/null || true

# Change hostname
echo "Setting hostname to ${HOSTNAME}..."
uci set system.@system[0].hostname="${HOSTNAME}"

# Commit all changes
echo "Committing configuration changes..."
uci commit network
uci commit system
uci commit mwan3 2>/dev/null || true

# Restart network
echo "Restarting network services..."
/etc/init.d/network restart

# Wait for network to come up
echo "Waiting for network to stabilize..."
sleep 5

echo ""
echo "=========================================="
echo "Worker Box ${BOX_NUMBER} configuration complete!"
echo "=========================================="
echo "IP Address: ${BOX_IP}"
echo "Hostname: ${HOSTNAME}"
echo "Gateway: 17.0.0.1"
echo "Role: VPN Endpoint Worker"
echo ""
echo "Next steps:"
echo "1. Connect this box to the ethernet switch"
echo "2. Configure VPN client (OpenVPN/WireGuard)"
echo "3. Test connectivity from master load balancer"
echo ""
echo "Master load balancer should be accessible at:"
echo "- HAProxy Stats: http://17.0.0.1:8404/stats"
echo "- LuCI Web UI: http://17.0.0.1/cgi-bin/luci"
echo "=========================================="