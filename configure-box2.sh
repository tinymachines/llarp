#!/bin/bash
# Configuration script for Lazarus Box 2 (Switch-based setup)
# Run this on the cloned image to convert it to Box 2

echo "Configuring Lazarus Box 2 for switch-based setup..."

# Change network configuration for switch setup
uci set network.lan.ipaddr='17.0.0.11'
uci set network.lan.gateway='17.0.0.1'
uci delete network.lan2 2>/dev/null || true
uci delete network.lan3 2>/dev/null || true

# Remove load balancer services (this box is VPN endpoint only)
/etc/init.d/haproxy stop
/etc/init.d/haproxy disable
/etc/init.d/mwan3 stop 2>/dev/null || true
/etc/init.d/mwan3 disable 2>/dev/null || true

# Clean up HAProxy and mwan3 configs
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
uci set system.@system[0].hostname='lazarus-box2'

# Commit all changes
uci commit network
uci commit system
uci commit mwan3 2>/dev/null || true

# Restart network
/etc/init.d/network restart

echo "Box 2 configuration complete!"
echo "IP: 17.0.0.11 (switch-based)"
echo "Gateway: 17.0.0.1"
echo "Role: VPN Endpoint"
echo "Connect via ethernet switch to master router"