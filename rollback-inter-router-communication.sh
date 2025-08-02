#!/bin/bash

# Rollback script for Inter-Router Communication Configuration
# Removes the routing and firewall rules added between Zephyr and Spydr

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Router IPs
ZEPHYR_IP="15.0.0.1"
SPYDR_IP="192.168.1.1"

# SSH options
SSH_OPTS="-o ConnectTimeout=10 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

echo -e "${BLUE}=== Rolling Back Inter-Router Communication Configuration ===${NC}"

# Function to execute commands on router
exec_router() {
    local router_ip=$1
    local cmd=$2
    local desc=$3
    
    echo -e "${YELLOW}[$router_ip] $desc${NC}"
    if ssh $SSH_OPTS root@$router_ip "$cmd" 2>/dev/null; then
        echo -e "${GREEN}  ✓ Success${NC}"
    else
        echo -e "${RED}  ✗ Failed (may already be removed)${NC}"
    fi
}

# Rollback Zephyr configuration
echo -e "\n${BLUE}=== Rolling Back Zephyr Configuration ===${NC}"

# Remove static route
exec_router $ZEPHYR_IP "uci delete network.route_spydr 2>/dev/null || true" "Removing Spydr route"

# Remove firewall rules
exec_router $ZEPHYR_IP "uci delete firewall.accept_spydr 2>/dev/null || true" "Removing Spydr accept rule"
exec_router $ZEPHYR_IP "uci delete firewall.lan_spydr 2>/dev/null || true" "Removing LAN->Spydr forwarding"
exec_router $ZEPHYR_IP "uci delete firewall.spydr_lan 2>/dev/null || true" "Removing Spydr->LAN forwarding"
exec_router $ZEPHYR_IP "uci delete firewall.spydr 2>/dev/null || true" "Removing Spydr zone"

# Rollback Spydr configuration
echo -e "\n${BLUE}=== Rolling Back Spydr Configuration ===${NC}"

# Remove static route
exec_router $SPYDR_IP "uci delete network.route_zephyr 2>/dev/null || true" "Removing Zephyr route"

# Remove firewall rules
exec_router $SPYDR_IP "uci delete firewall.accept_zephyr 2>/dev/null || true" "Removing Zephyr accept rule"
exec_router $SPYDR_IP "uci delete firewall.lan_zephyr 2>/dev/null || true" "Removing LAN->Zephyr forwarding"
exec_router $SPYDR_IP "uci delete firewall.zephyr_lan 2>/dev/null || true" "Removing Zephyr->LAN forwarding"
exec_router $SPYDR_IP "uci delete firewall.zephyr 2>/dev/null || true" "Removing Zephyr zone"

# Commit changes and restart services
echo -e "\n${BLUE}=== Applying Rollback ===${NC}"

echo -e "${YELLOW}Committing Zephyr rollback...${NC}"
exec_router $ZEPHYR_IP "uci commit network" "Committing network config"
exec_router $ZEPHYR_IP "uci commit firewall" "Committing firewall config"
exec_router $ZEPHYR_IP "/etc/init.d/network restart" "Restarting network"
exec_router $ZEPHYR_IP "/etc/init.d/firewall restart" "Restarting firewall"

echo -e "\n${YELLOW}Committing Spydr rollback...${NC}"
exec_router $SPYDR_IP "uci commit network" "Committing network config"
exec_router $SPYDR_IP "uci commit firewall" "Committing firewall config"
exec_router $SPYDR_IP "/etc/init.d/network restart" "Restarting network"
exec_router $SPYDR_IP "/etc/init.d/firewall restart" "Restarting firewall"

echo -e "\n${GREEN}=== Rollback Complete ===${NC}"
echo -e "${BLUE}Inter-router communication configuration has been removed${NC}"