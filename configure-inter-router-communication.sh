#!/bin/bash

# OpenWRT Inter-Router Communication Configuration
# Enables communication between Zephyr (15.0.0.0/24) and Spydr (192.168.1.0/24) networks

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Router configurations
ZEPHYR_IP="15.0.0.1"
ZEPHYR_LAN="15.0.0.0/24"
ZEPHYR_WAN_IP="13.0.0.73"

SPYDR_IP="192.168.1.1"
SPYDR_LAN="192.168.1.0/24"
# Spydr WAN IP will be determined dynamically

# SSH options
SSH_OPTS="-o ConnectTimeout=10 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

echo -e "${BLUE}=== OpenWRT Inter-Router Communication Setup ===${NC}"
echo -e "${BLUE}Enabling communication between:${NC}"
echo -e "  • Zephyr LAN: ${ZEPHYR_LAN}"
echo -e "  • Spydr LAN: ${SPYDR_LAN}"
echo ""

# Function to execute commands on router
exec_router() {
    local router_ip=$1
    local cmd=$2
    local desc=$3
    
    echo -e "${YELLOW}[$router_ip] $desc${NC}"
    if ssh $SSH_OPTS root@$router_ip "$cmd"; then
        echo -e "${GREEN}  ✓ Success${NC}"
    else
        echo -e "${RED}  ✗ Failed${NC}"
        return 1
    fi
}

# Get Spydr's WAN IP dynamically
echo -e "${YELLOW}Getting Spydr's current WAN IP...${NC}"
# Try multiple interface names as Spydr might use different interfaces
for iface in wan phy0-sta0 eth1; do
    SPYDR_WAN_IP=$(ssh $SSH_OPTS root@$SPYDR_IP "ip -4 addr show $iface 2>/dev/null | grep 'inet ' | grep -v '127.0.0.1' | awk '{print \$2}' | cut -d/ -f1" | tr -d '\r\n')
    if [ -n "$SPYDR_WAN_IP" ]; then
        echo -e "${GREEN}  Found Spydr WAN IP on interface $iface${NC}"
        break
    fi
done

# If still not found, look for any IP on 13.0.0.0/24 network
if [ -z "$SPYDR_WAN_IP" ]; then
    SPYDR_WAN_IP=$(ssh $SSH_OPTS root@$SPYDR_IP "ip -4 addr show | grep 'inet 13.0.0.' | awk '{print \$2}' | cut -d/ -f1 | head -1" | tr -d '\r\n')
fi

if [ -z "$SPYDR_WAN_IP" ]; then
    echo -e "${RED}Error: Could not determine Spydr's WAN IP${NC}"
    exit 1
fi
echo -e "${GREEN}  Spydr WAN IP: $SPYDR_WAN_IP${NC}"

# Test connectivity
echo -e "\n${YELLOW}Testing connectivity...${NC}"
exec_router $ZEPHYR_IP "ping -c 1 $ZEPHYR_IP >/dev/null 2>&1" "Testing Zephyr SSH"
exec_router $SPYDR_IP "ping -c 1 $SPYDR_IP >/dev/null 2>&1" "Testing Spydr SSH"

# Configure Zephyr
echo -e "\n${BLUE}=== Configuring Zephyr Router ===${NC}"

# Add static route on Zephyr to reach Spydr's LAN
exec_router $ZEPHYR_IP "uci set network.route_spydr=route" "Creating route to Spydr"
exec_router $ZEPHYR_IP "uci set network.route_spydr.interface='wan'" "Setting route interface"
exec_router $ZEPHYR_IP "uci set network.route_spydr.target='$SPYDR_LAN'" "Setting route target"
exec_router $ZEPHYR_IP "uci set network.route_spydr.gateway='$SPYDR_WAN_IP'" "Setting route gateway"

# Create firewall zone for Spydr network
exec_router $ZEPHYR_IP "uci set firewall.spydr=zone" "Creating Spydr firewall zone"
exec_router $ZEPHYR_IP "uci set firewall.spydr.name='spydr'" "Naming firewall zone"
exec_router $ZEPHYR_IP "uci set firewall.spydr.input='ACCEPT'" "Setting zone input policy"
exec_router $ZEPHYR_IP "uci set firewall.spydr.output='ACCEPT'" "Setting zone output policy"
exec_router $ZEPHYR_IP "uci set firewall.spydr.forward='ACCEPT'" "Setting zone forward policy"
exec_router $ZEPHYR_IP "uci add_list firewall.spydr.subnet='$SPYDR_LAN'" "Adding Spydr subnet"

# Add forwarding rules
exec_router $ZEPHYR_IP "uci set firewall.lan_spydr=forwarding" "Creating LAN to Spydr forwarding"
exec_router $ZEPHYR_IP "uci set firewall.lan_spydr.src='lan'" "Setting forwarding source"
exec_router $ZEPHYR_IP "uci set firewall.lan_spydr.dest='spydr'" "Setting forwarding destination"

exec_router $ZEPHYR_IP "uci set firewall.spydr_lan=forwarding" "Creating Spydr to LAN forwarding"
exec_router $ZEPHYR_IP "uci set firewall.spydr_lan.src='spydr'" "Setting forwarding source"
exec_router $ZEPHYR_IP "uci set firewall.spydr_lan.dest='lan'" "Setting forwarding destination"

# Add specific rule to accept traffic from Spydr network
exec_router $ZEPHYR_IP "uci set firewall.accept_spydr=rule" "Creating accept rule for Spydr"
exec_router $ZEPHYR_IP "uci set firewall.accept_spydr.name='Accept-Spydr-Network'" "Naming accept rule"
exec_router $ZEPHYR_IP "uci set firewall.accept_spydr.src='wan'" "Setting rule source zone"
exec_router $ZEPHYR_IP "uci add_list firewall.accept_spydr.src_ip='$SPYDR_LAN'" "Setting source IP range"
exec_router $ZEPHYR_IP "uci set firewall.accept_spydr.dest='lan'" "Setting rule destination"
exec_router $ZEPHYR_IP "uci set firewall.accept_spydr.target='ACCEPT'" "Setting rule target"

# Configure Spydr
echo -e "\n${BLUE}=== Configuring Spydr Router ===${NC}"

# Add static route on Spydr to reach Zephyr's LAN
exec_router $SPYDR_IP "uci set network.route_zephyr=route" "Creating route to Zephyr"
exec_router $SPYDR_IP "uci set network.route_zephyr.interface='wan'" "Setting route interface"
exec_router $SPYDR_IP "uci set network.route_zephyr.target='$ZEPHYR_LAN'" "Setting route target"
exec_router $SPYDR_IP "uci set network.route_zephyr.gateway='$ZEPHYR_WAN_IP'" "Setting route gateway"

# Create firewall zone for Zephyr network
exec_router $SPYDR_IP "uci set firewall.zephyr=zone" "Creating Zephyr firewall zone"
exec_router $SPYDR_IP "uci set firewall.zephyr.name='zephyr'" "Naming firewall zone"
exec_router $SPYDR_IP "uci set firewall.zephyr.input='ACCEPT'" "Setting zone input policy"
exec_router $SPYDR_IP "uci set firewall.zephyr.output='ACCEPT'" "Setting zone output policy"
exec_router $SPYDR_IP "uci set firewall.zephyr.forward='ACCEPT'" "Setting zone forward policy"
exec_router $SPYDR_IP "uci add_list firewall.zephyr.subnet='$ZEPHYR_LAN'" "Adding Zephyr subnet"

# Add forwarding rules
exec_router $SPYDR_IP "uci set firewall.lan_zephyr=forwarding" "Creating LAN to Zephyr forwarding"
exec_router $SPYDR_IP "uci set firewall.lan_zephyr.src='lan'" "Setting forwarding source"
exec_router $SPYDR_IP "uci set firewall.lan_zephyr.dest='zephyr'" "Setting forwarding destination"

exec_router $SPYDR_IP "uci set firewall.zephyr_lan=forwarding" "Creating Zephyr to LAN forwarding"
exec_router $SPYDR_IP "uci set firewall.zephyr_lan.src='zephyr'" "Setting forwarding source"
exec_router $SPYDR_IP "uci set firewall.zephyr_lan.dest='lan'" "Setting forwarding destination"

# Add specific rule to accept traffic from Zephyr network
exec_router $SPYDR_IP "uci set firewall.accept_zephyr=rule" "Creating accept rule for Zephyr"
exec_router $SPYDR_IP "uci set firewall.accept_zephyr.name='Accept-Zephyr-Network'" "Naming accept rule"
exec_router $SPYDR_IP "uci set firewall.accept_zephyr.src='wan'" "Setting rule source zone"
exec_router $SPYDR_IP "uci add_list firewall.accept_zephyr.src_ip='$ZEPHYR_LAN'" "Setting source IP range"
exec_router $SPYDR_IP "uci set firewall.accept_zephyr.dest='lan'" "Setting rule destination"
exec_router $SPYDR_IP "uci set firewall.accept_zephyr.target='ACCEPT'" "Setting rule target"

# Commit changes and restart services
echo -e "\n${BLUE}=== Applying Configuration ===${NC}"

echo -e "${YELLOW}Committing Zephyr configuration...${NC}"
exec_router $ZEPHYR_IP "uci commit network" "Committing network config"
exec_router $ZEPHYR_IP "uci commit firewall" "Committing firewall config"
exec_router $ZEPHYR_IP "/etc/init.d/network restart" "Restarting network"
exec_router $ZEPHYR_IP "/etc/init.d/firewall restart" "Restarting firewall"

echo -e "\n${YELLOW}Committing Spydr configuration...${NC}"
exec_router $SPYDR_IP "uci commit network" "Committing network config"
exec_router $SPYDR_IP "uci commit firewall" "Committing firewall config"
exec_router $SPYDR_IP "/etc/init.d/network restart" "Restarting network"
exec_router $SPYDR_IP "/etc/init.d/firewall restart" "Restarting firewall"

# Wait for services to stabilize
echo -e "\n${YELLOW}Waiting for services to stabilize...${NC}"
sleep 10

# Test connectivity
echo -e "\n${BLUE}=== Testing Inter-Router Communication ===${NC}"

echo -e "${YELLOW}Testing from Zephyr to Spydr LAN...${NC}"
if ssh $SSH_OPTS root@$ZEPHYR_IP "ping -c 3 -W 2 $SPYDR_IP"; then
    echo -e "${GREEN}  ✓ Zephyr can reach Spydr LAN${NC}"
else
    echo -e "${RED}  ✗ Zephyr cannot reach Spydr LAN${NC}"
fi

echo -e "\n${YELLOW}Testing from Spydr to Zephyr LAN...${NC}"
if ssh $SSH_OPTS root@$SPYDR_IP "ping -c 3 -W 2 $ZEPHYR_IP"; then
    echo -e "${GREEN}  ✓ Spydr can reach Zephyr LAN${NC}"
else
    echo -e "${RED}  ✗ Spydr cannot reach Zephyr LAN${NC}"
fi

echo -e "\n${GREEN}=== Configuration Complete ===${NC}"
echo -e "${BLUE}Summary:${NC}"
echo -e "  • Zephyr LAN (${ZEPHYR_LAN}) ←→ Spydr LAN (${SPYDR_LAN})"
echo -e "  • Static routes configured on both routers"
echo -e "  • Firewall rules allow bidirectional communication"
echo -e "\n${YELLOW}Note: Devices on each LAN should now be able to communicate${NC}"
echo -e "${YELLOW}You may need to add routes on individual devices or use the routers as gateways${NC}"