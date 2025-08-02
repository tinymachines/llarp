#!/bin/bash

# Verification script for Inter-Router Communication
# Checks routing tables, firewall rules, and connectivity

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

SPYDR_IP="192.168.1.1"
SPYDR_LAN="192.168.1.0/24"

# SSH options
SSH_OPTS="-o ConnectTimeout=10 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

echo -e "${BLUE}=== Inter-Router Communication Status Check ===${NC}"
echo -e "${BLUE}Checking communication between:${NC}"
echo -e "  • Zephyr (${ZEPHYR_LAN})"
echo -e "  • Spydr (${SPYDR_LAN})"
echo ""

# Function to check router configuration
check_router() {
    local router_name=$1
    local router_ip=$2
    local target_network=$3
    
    echo -e "\n${BLUE}=== Checking $router_name Router ($router_ip) ===${NC}"
    
    # Check if router is reachable
    if ! ssh $SSH_OPTS root@$router_ip "exit" 2>/dev/null; then
        echo -e "${RED}✗ Cannot connect to $router_name router${NC}"
        return 1
    fi
    
    # Check routing table
    echo -e "\n${YELLOW}Routing Table:${NC}"
    ssh $SSH_OPTS root@$router_ip "ip route | grep '$target_network' || echo 'No route found for $target_network'"
    
    # Check firewall zones
    echo -e "\n${YELLOW}Firewall Zones:${NC}"
    ssh $SSH_OPTS root@$router_ip "uci show firewall 2>/dev/null | grep -E '(zone.*name|forwarding.*src|forwarding.*dest|rule.*Accept)' | grep -i '${router_name,,}' || echo 'No specific zones/rules found'"
    
    # Check active connections
    echo -e "\n${YELLOW}Active Connections to Target Network:${NC}"
    ssh $SSH_OPTS root@$router_ip "conntrack -L 2>/dev/null | grep '$target_network' | head -5 || echo 'No active connections found'"
}

# Check Zephyr configuration
check_router "Zephyr" "$ZEPHYR_IP" "$SPYDR_LAN"

# Check Spydr configuration  
check_router "Spydr" "$SPYDR_IP" "$ZEPHYR_LAN"

# Connectivity tests
echo -e "\n${BLUE}=== Connectivity Tests ===${NC}"

# Test from Zephyr to Spydr
echo -e "\n${YELLOW}Testing Zephyr → Spydr:${NC}"
if ssh $SSH_OPTS root@$ZEPHYR_IP "ping -c 3 -W 2 $SPYDR_IP" >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Zephyr can ping Spydr LAN IP ($SPYDR_IP)${NC}"
    
    # Traceroute
    echo -e "${YELLOW}  Traceroute:${NC}"
    ssh $SSH_OPTS root@$ZEPHYR_IP "traceroute -n -m 5 $SPYDR_IP 2>/dev/null || echo '  Traceroute not available'"
else
    echo -e "${RED}✗ Zephyr cannot reach Spydr LAN${NC}"
fi

# Test from Spydr to Zephyr
echo -e "\n${YELLOW}Testing Spydr → Zephyr:${NC}"
if ssh $SSH_OPTS root@$SPYDR_IP "ping -c 3 -W 2 $ZEPHYR_IP" >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Spydr can ping Zephyr LAN IP ($ZEPHYR_IP)${NC}"
    
    # Traceroute
    echo -e "${YELLOW}  Traceroute:${NC}"
    ssh $SSH_OPTS root@$SPYDR_IP "traceroute -n -m 5 $ZEPHYR_IP 2>/dev/null || echo '  Traceroute not available'"
else
    echo -e "${RED}✗ Spydr cannot reach Zephyr LAN${NC}"
fi

# Check WAN IPs
echo -e "\n${BLUE}=== WAN IP Addresses ===${NC}"
ZEPHYR_WAN=$(ssh $SSH_OPTS root@$ZEPHYR_IP "ip -4 addr show wan | grep inet | awk '{print \$2}' | cut -d/ -f1" 2>/dev/null | tr -d '\r\n')
SPYDR_WAN=$(ssh $SSH_OPTS root@$SPYDR_IP "ip -4 addr show wan | grep inet | awk '{print \$2}' | cut -d/ -f1" 2>/dev/null | tr -d '\r\n')

echo -e "Zephyr WAN: ${ZEPHYR_WAN:-Not found}"
echo -e "Spydr WAN: ${SPYDR_WAN:-Not found}"

# Summary
echo -e "\n${BLUE}=== Summary ===${NC}"
if ssh $SSH_OPTS root@$ZEPHYR_IP "ping -c 1 -W 1 $SPYDR_IP" >/dev/null 2>&1 && \
   ssh $SSH_OPTS root@$SPYDR_IP "ping -c 1 -W 1 $ZEPHYR_IP" >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Inter-router communication is WORKING${NC}"
    echo -e "${GREEN}  Devices on both LANs should be able to communicate${NC}"
else
    echo -e "${RED}✗ Inter-router communication is NOT WORKING${NC}"
    echo -e "${YELLOW}  Run ./configure-inter-router-communication.sh to set it up${NC}"
fi