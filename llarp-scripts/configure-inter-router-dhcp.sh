#!/bin/bash
# LLARP Script Lego: Configure Inter-Router DHCP
# Created: $(date)  
# Purpose: Fix DHCP configuration between connected OpenWRT routers

UPSTREAM_ROUTER="$1"  # Spydr at 192.168.1.1
DOWNSTREAM_ROUTER="$2"  # LLARP at 15.0.0.1 (should be 13.0.0.73)

if [[ -z "$UPSTREAM_ROUTER" || -z "$DOWNSTREAM_ROUTER" ]]; then
    echo "Usage: $0 <upstream_router_ip> <downstream_router_ip>"
    echo "Example: $0 192.168.1.1 15.0.0.1"
    exit 1
fi

SSH_OPTS="-o ConnectTimeout=10 -o StrictHostKeyChecking=no"

echo "🔗 CONFIGURING INTER-ROUTER DHCP"
echo "Upstream: $UPSTREAM_ROUTER"
echo "Downstream: $DOWNSTREAM_ROUTER"
echo "================================"

# Step 1: Check current configuration on upstream router
echo "📊 Step 1: Analyzing upstream router ($UPSTREAM_ROUTER)"
ssh $SSH_OPTS root@$UPSTREAM_ROUTER "
echo 'Current network interfaces:'
ip addr show | grep -A3 '13.0.0'

echo -e '\nCurrent DHCP configuration:'
uci show dhcp

echo -e '\nCurrent routing:'
ip route show | grep 13.0.0
"

# Step 2: Configure DHCP server for 13.0.0.x network
echo -e "\n🔧 Step 2: Configuring DHCP for 13.0.0.x network"
ssh $SSH_OPTS root@$UPSTREAM_ROUTER "
echo 'Creating DHCP configuration for 13.0.0.x network...'

# Add a new DHCP section for the 13.0.0.x network
uci add dhcp dhcp
uci set dhcp.@dhcp[-1].interface='wwan'  # phy0-sta0 interface
uci set dhcp.@dhcp[-1].start='50'
uci set dhcp.@dhcp[-1].limit='100'  
uci set dhcp.@dhcp[-1].leasetime='12h'
uci set dhcp.@dhcp[-1].dhcpv4='server'

echo 'Committing DHCP configuration...'
uci commit dhcp

echo 'Restarting DHCP server...'
/etc/init.d/dnsmasq restart

echo 'DHCP server configured for 13.0.0.x network'
"

# Step 3: Test connectivity
echo -e "\n🧪 Step 3: Testing connectivity"
ssh $SSH_OPTS root@$DOWNSTREAM_ROUTER "
echo 'Restarting network on downstream router...'
/etc/init.d/network restart

echo 'Waiting for DHCP...'
sleep 10

echo 'Testing DHCP on WAN interface:'
udhcpc -i wan -n -q && echo 'DHCP successful!' || echo 'DHCP still failing'

echo 'Current WAN status:'
ip addr show wan

echo 'Testing internet connectivity:'
ping -c 2 8.8.8.8 && echo 'Internet working!' || echo 'No internet access'
"

echo ""
echo "✅ INTER-ROUTER DHCP CONFIGURATION COMPLETE"
echo "📋 If successful, both routers should now be able to communicate"