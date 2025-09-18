#!/bin/bash

# IP Collision Detection for Lazarus Emergency Router
# Prevents IP conflicts when deploying emergency network

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
LAZARUS_NETWORK="${LAZARUS_NETWORK:-17.0.0.0/24}"
LAZARUS_IP="${LAZARUS_IP:-17.0.0.1}"
CHECK_TIMEOUT=2

echo -e "${BLUE}=== IP Collision Detection for Lazarus Emergency Router ===${NC}"
echo

check_current_ips() {
    echo -e "${YELLOW}Checking current network interfaces...${NC}"

    # Get all current IPs
    local current_ips=$(ip addr show | grep "inet " | grep -v "127.0.0.1" | awk '{print $2}' | cut -d'/' -f1)

    echo "Current IP addresses on this system:"
    for ip in $current_ips; do
        local iface=$(ip addr show | grep -B2 "inet $ip" | head -1 | cut -d':' -f2 | tr -d ' ')
        echo "  - $ip ($iface)"
    done
    echo
}

check_network_overlap() {
    local target_network=$1
    local target_base=$(echo $target_network | cut -d'/' -f1 | cut -d'.' -f1-3)

    echo -e "${YELLOW}Checking for network overlaps with $target_network...${NC}"

    # Check if any current interface is on the same network
    local conflicts=()
    while IFS= read -r line; do
        if [[ -z "$line" ]]; then continue; fi

        local ip=$(echo $line | awk '{print $2}' | cut -d'/' -f1)
        local network=$(echo $line | awk '{print $2}')
        local iface=$(echo $line | awk '{print $NF}')

        # Check if IP is in same subnet
        local ip_base=$(echo $ip | cut -d'.' -f1-3)
        if [[ "$ip_base" == "$target_base" ]]; then
            conflicts+=("$ip on $iface (network: $network)")
        fi
    done < <(ip addr show | grep "inet " | grep -v "127.0.0.1" | awk '{print $2, $NF}')

    if [[ ${#conflicts[@]} -gt 0 ]]; then
        echo -e "${RED}⚠ WARNING: IP conflicts detected!${NC}"
        echo "The following interfaces conflict with Lazarus network $target_network:"
        for conflict in "${conflicts[@]}"; do
            echo "  - $conflict"
        done
        return 1
    else
        echo -e "${GREEN}✓ No IP conflicts detected${NC}"
        return 0
    fi
}

check_gateway_reachability() {
    local gateway=$1

    echo -e "${YELLOW}Checking if gateway $gateway is reachable...${NC}"

    if ping -c 1 -W $CHECK_TIMEOUT $gateway &>/dev/null; then
        echo -e "${RED}⚠ WARNING: Gateway $gateway is already active!${NC}"
        echo "This could indicate:"
        echo "  1. Another router is using this IP"
        echo "  2. Lazarus is already running"
        echo "  3. Network misconfiguration"
        return 1
    else
        echo -e "${GREEN}✓ Gateway $gateway is not currently active${NC}"
        return 0
    fi
}

check_arp_cache() {
    local target_ip=$1

    echo -e "${YELLOW}Checking ARP cache for $target_ip...${NC}"

    local arp_entry=$(arp -n 2>/dev/null | grep "^$target_ip " || true)

    if [[ -n "$arp_entry" ]]; then
        echo -e "${YELLOW}⚠ Found ARP entry for $target_ip:${NC}"
        echo "  $arp_entry"
        echo "  This device was recently active on the network"
        return 1
    else
        echo -e "${GREEN}✓ No recent ARP entry for $target_ip${NC}"
        return 0
    fi
}

suggest_alternative_network() {
    echo
    echo -e "${BLUE}Suggested alternative networks for Lazarus:${NC}"

    # Common private network ranges that might be available
    local alternatives=(
        "10.99.0.0/24"
        "172.31.0.0/24"
        "192.168.99.0/24"
        "192.168.123.0/24"
    )

    for net in "${alternatives[@]}"; do
        local base_ip=$(echo $net | cut -d'/' -f1 | cut -d'.' -f1-3)
        local gateway="${base_ip}.1"

        # Quick check if this network is in use
        if ! ip route | grep -q "$base_ip"; then
            if ! ping -c 1 -W 1 $gateway &>/dev/null; then
                echo "  - $net (gateway: $gateway) - likely available"
            fi
        fi
    done
}

perform_safety_checks() {
    local safe=true

    # Display current network state
    check_current_ips

    # Check for network overlaps
    if ! check_network_overlap "$LAZARUS_NETWORK"; then
        safe=false
    fi
    echo

    # Check if gateway IP is already in use
    if ! check_gateway_reachability "$LAZARUS_IP"; then
        safe=false
    fi
    echo

    # Check ARP cache
    if ! check_arp_cache "$LAZARUS_IP"; then
        safe=false
    fi
    echo

    if [[ "$safe" == "false" ]]; then
        echo -e "${RED}═══════════════════════════════════════════${NC}"
        echo -e "${RED}⚠  SAFETY CHECK FAILED  ⚠${NC}"
        echo -e "${RED}═══════════════════════════════════════════${NC}"
        echo
        echo "Deploying Lazarus with these conflicts could cause:"
        echo "  • Network loops"
        echo "  • IP address conflicts"
        echo "  • Connectivity loss"
        echo "  • DHCP conflicts"
        echo
        suggest_alternative_network
        echo
        echo -e "${YELLOW}Recommendations:${NC}"
        echo "1. Choose a different network range for Lazarus"
        echo "2. Disconnect from conflicting networks first"
        echo "3. Use 'ip addr del <ip>/<mask> dev <interface>' to remove conflicts"
        echo
        return 1
    else
        echo -e "${GREEN}═══════════════════════════════════════════${NC}"
        echo -e "${GREEN}✓  ALL SAFETY CHECKS PASSED  ✓${NC}"
        echo -e "${GREEN}═══════════════════════════════════════════${NC}"
        echo
        echo "It's safe to deploy Lazarus emergency router on:"
        echo "  Network: $LAZARUS_NETWORK"
        echo "  Gateway: $LAZARUS_IP"
        echo
        return 0
    fi
}

# Main execution
main() {
    local exit_code=0

    if ! perform_safety_checks; then
        exit_code=1
    fi

    # Allow override with --force flag
    if [[ "${1:-}" == "--force" ]] && [[ $exit_code -eq 1 ]]; then
        echo
        echo -e "${YELLOW}WARNING: --force flag detected. Proceeding despite conflicts!${NC}"
        echo -e "${YELLOW}This may cause network issues. Use with caution!${NC}"
        exit_code=0
    fi

    exit $exit_code
}

main "$@"