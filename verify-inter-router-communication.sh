#!/bin/bash

# Verification Script for Inter-Router Communication
# Tests connectivity between all network segments

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Inter-Router Communication Verification${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Function to run test and report result
run_test() {
    local from_router=$1
    local from_name=$2
    local to_ip=$3
    local to_name=$4
    
    echo -n -e "  ${from_name} → ${to_name} (${to_ip}): "
    
    if ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no root@${from_router} "ping -c 2 -W 2 ${to_ip}" >/dev/null 2>&1; then
        echo -e "${GREEN}✓ SUCCESS${NC}"
        return 0
    else
        echo -e "${RED}✗ FAILED${NC}"
        return 1
    fi
}

# Show current routing tables
echo -e "${YELLOW}Current Routing Tables:${NC}"
echo ""
echo -e "${BLUE}Zephyr Router:${NC}"
ssh -o StrictHostKeyChecking=no root@zephyr.router "ip route show" 2>/dev/null | sed 's/^/  /'
echo ""
echo -e "${BLUE}Spydr Router:${NC}"
ssh -o StrictHostKeyChecking=no root@spydr.router "ip route show" 2>/dev/null | sed 's/^/  /'
echo ""

# Test Matrix
echo -e "${YELLOW}Connectivity Test Matrix:${NC}"
echo ""

# From Zephyr
echo -e "${BLUE}From Zephyr Router:${NC}"
run_test "zephyr.router" "Zephyr" "192.168.1.1" "Spydr LAN"
run_test "zephyr.router" "Zephyr" "13.0.0.250" "Spydr WAN"
run_test "zephyr.router" "Zephyr" "13.0.0.254" "ATT Gateway"
run_test "zephyr.router" "Zephyr" "8.8.8.8" "Internet (Google DNS)"
echo ""

# From Spydr
echo -e "${BLUE}From Spydr Router:${NC}"
run_test "spydr.router" "Spydr" "15.0.0.1" "Zephyr LAN"
run_test "spydr.router" "Spydr" "13.0.0.73" "Zephyr WAN"
run_test "spydr.router" "Spydr" "13.0.0.254" "ATT Gateway"
run_test "spydr.router" "Spydr" "8.8.8.8" "Internet (Google DNS)"
echo ""

# Test DNS resolution
echo -e "${YELLOW}DNS Resolution Tests:${NC}"
echo ""
echo -e "${BLUE}From Zephyr:${NC}"
if ssh -o StrictHostKeyChecking=no root@zephyr.router "nslookup google.com" 2>/dev/null | grep -q "Address"; then
    echo -e "  DNS Resolution: ${GREEN}✓ Working${NC}"
else
    echo -e "  DNS Resolution: ${RED}✗ Failed${NC}"
fi

echo ""
echo -e "${BLUE}From Spydr:${NC}"
if ssh -o StrictHostKeyChecking=no root@spydr.router "nslookup google.com" 2>/dev/null | grep -q "Address"; then
    echo -e "  DNS Resolution: ${GREEN}✓ Working${NC}"
else
    echo -e "  DNS Resolution: ${RED}✗ Failed${NC}"
fi

# Check ARP tables
echo ""
echo -e "${YELLOW}ARP Tables (showing cross-network entries):${NC}"
echo ""
echo -e "${BLUE}Zephyr ARP entries for Spydr:${NC}"
ssh -o StrictHostKeyChecking=no root@zephyr.router "ip neigh show | grep -E '13.0.0.250|13.0.0.254'" 2>/dev/null | sed 's/^/  /' || echo "  No entries"

echo ""
echo -e "${BLUE}Spydr ARP entries for Zephyr:${NC}"
ssh -o StrictHostKeyChecking=no root@spydr.router "ip neigh show | grep -E '13.0.0.73|13.0.0.254'" 2>/dev/null | sed 's/^/  /' || echo "  No entries"

# Summary
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Network Topology Summary:${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "  [Zephyr Lab Network]"
echo "    15.0.0.0/24"
echo "         |"
echo "    15.0.0.1 (Zephyr LAN)"
echo "         |"
echo "    13.0.0.73 (Zephyr WAN)"
echo "         |"
echo "  [ATT Network 13.0.0.0/24]"
echo "         |"
echo "    13.0.0.254 (ATT Gateway) --> Internet"
echo "         |"
echo "    13.0.0.250 (Spydr WiFi Client)"
echo "         |"
echo "    192.168.1.1 (Spydr LAN)"
echo "         |"
echo "  [Spydr Network]"
echo "    192.168.1.0/24"
echo ""
echo -e "${GREEN}All networks should be able to communicate with each other.${NC}"
echo -e "${YELLOW}If any tests failed, check firewall rules or network configuration.${NC}"