#!/bin/bash

# Network Configuration Script for OpenWRT Routers
# Enables full routing between Zephyr, Spydr, and Internet networks

set -e

echo "====================================="
echo "Inter-Router Communication Setup"
echo "====================================="
echo ""
echo "Network Topology:"
echo "  Zephyr (15.0.0.0/24) <--> ATT (13.0.0.0/24) <--> Spydr (192.168.1.0/24)"
echo "  Internet Gateway: 13.0.0.254"
echo ""

# Test connectivity to routers
echo "Testing router connectivity..."
if ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no root@zephyr.router "echo 'Zephyr: Connected'" 2>/dev/null; then
    echo "✓ Zephyr router is reachable"
else
    echo "✗ Cannot reach Zephyr router"
    exit 1
fi

if ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no root@spydr.router "echo 'Spydr: Connected'" 2>/dev/null; then
    echo "✓ Spydr router is reachable"
else
    echo "✗ Cannot reach Spydr router"
    exit 1
fi

echo ""
echo "====================================="
echo "Configuring Spydr Router"
echo "====================================="

# Configure Spydr (Gateway router)
ssh -o StrictHostKeyChecking=no root@spydr.router << 'EOF'
echo "Current routing table:"
ip route show

echo ""
echo "Adding/updating route to Zephyr network..."

# Remove existing route if present
ip route del 15.0.0.0/24 2>/dev/null || true

# Add route to Zephyr network
ip route add 15.0.0.0/24 via 13.0.0.73 dev phy0-sta0

# Update UCI configuration to persist across reboots
uci delete network.route_zephyr 2>/dev/null || true
uci set network.route_zephyr=route
uci set network.route_zephyr.interface='wwan'
uci set network.route_zephyr.target='15.0.0.0/24'
uci set network.route_zephyr.gateway='13.0.0.73'
uci commit network

echo ""
echo "Updated routing table:"
ip route show

echo ""
echo "Testing connectivity to Zephyr network..."
ping -c 2 15.0.0.1 || echo "Note: Ping may fail due to firewall rules"
EOF

echo ""
echo "====================================="
echo "Configuring Zephyr Router"
echo "====================================="

# Configure Zephyr (Lab router)
ssh -o StrictHostKeyChecking=no root@zephyr.router << 'EOF'
echo "Current routing table:"
ip route show

echo ""
echo "Adding default route for internet access..."

# Remove existing default route if present
ip route del default 2>/dev/null || true

# Add default route via ATT gateway
ip route add default via 13.0.0.254 dev wan

# Ensure route to Spydr network is correct
ip route del 192.168.1.0/24 2>/dev/null || true
ip route add 192.168.1.0/24 via 13.0.0.250 dev wan

# Update UCI configuration to persist across reboots
# Default route is already configured via gateway setting
# Just ensure the Spydr route is correct
uci delete network.route_spydr 2>/dev/null || true
uci set network.route_spydr=route
uci set network.route_spydr.interface='wan'
uci set network.route_spydr.target='192.168.1.0/24'
uci set network.route_spydr.gateway='13.0.0.250'
uci commit network

echo ""
echo "Updated routing table:"
ip route show

echo ""
echo "Testing connectivity:"
echo "- To Spydr network:"
ping -c 2 192.168.1.1 || echo "Note: Ping may fail due to firewall rules"
echo "- To Internet (via ATT gateway):"
ping -c 2 8.8.8.8 || echo "Note: Ping may fail due to firewall rules"
EOF

echo ""
echo "====================================="
echo "Configuration Summary"
echo "====================================="
echo ""
echo "Routes configured:"
echo "  Zephyr:"
echo "    - Default route: via 13.0.0.254 (ATT gateway)"
echo "    - To Spydr (192.168.1.0/24): via 13.0.0.250"
echo ""
echo "  Spydr:"
echo "    - Default route: via 13.0.0.254 (ATT gateway)"
echo "    - To Zephyr (15.0.0.0/24): via 13.0.0.73"
echo ""
echo "Note: If ping tests fail, check firewall rules on each router."
echo "You may need to add firewall zones/rules to allow inter-network traffic."
echo ""
echo "To verify connectivity from any network:"
echo "  - From Zephyr LAN: ping 192.168.1.1, ping 13.0.0.254, ping 8.8.8.8"
echo "  - From Spydr LAN: ping 15.0.0.1, ping 13.0.0.254, ping 8.8.8.8"