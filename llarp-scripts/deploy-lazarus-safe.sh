#!/bin/bash

# Safe Lazarus Emergency Router Deployment
# With IP collision detection and automatic conflict resolution

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COLLISION_CHECK="${SCRIPT_DIR}/check-ip-collision.sh"
DEFAULT_NETWORK="17.0.0.0/24"
DEFAULT_GATEWAY="17.0.0.1"
LAZARUS_HOST="${LAZARUS_HOST:-lazarus.local}"

echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo -e "${BLUE}      Lazarus Emergency Router Deployment${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo

# Function to run pre-deployment checks
run_safety_checks() {
    local network="${1:-$DEFAULT_NETWORK}"
    local gateway="${2:-$DEFAULT_GATEWAY}"

    echo -e "${YELLOW}Running pre-deployment safety checks...${NC}"
    echo

    if LAZARUS_NETWORK="$network" LAZARUS_IP="$gateway" "$COLLISION_CHECK"; then
        return 0
    else
        return 1
    fi
}

# Function to find safe network range
find_safe_network() {
    echo -e "${YELLOW}Searching for safe network range...${NC}"

    local test_networks=(
        "17.0.0.0/24:17.0.0.1"
        "10.99.0.0/24:10.99.0.1"
        "172.31.0.0/24:172.31.0.1"
        "192.168.99.0/24:192.168.99.1"
        "192.168.88.0/24:192.168.88.1"
    )

    for net_config in "${test_networks[@]}"; do
        local network=$(echo $net_config | cut -d':' -f1)
        local gateway=$(echo $net_config | cut -d':' -f2)

        echo -n "Testing $network... "

        if LAZARUS_NETWORK="$network" LAZARUS_IP="$gateway" "$COLLISION_CHECK" &>/dev/null; then
            echo -e "${GREEN}Available!${NC}"
            echo
            echo -e "${GREEN}Found safe network: $network (gateway: $gateway)${NC}"
            export SAFE_NETWORK="$network"
            export SAFE_GATEWAY="$gateway"
            return 0
        else
            echo -e "${RED}Conflict${NC}"
        fi
    done

    echo -e "${RED}No safe network range found automatically${NC}"
    return 1
}

# Function to disconnect conflicting interfaces
disconnect_conflicts() {
    local target_network=$1
    local target_base=$(echo $target_network | cut -d'/' -f1 | cut -d'.' -f1-3)

    echo -e "${YELLOW}Checking for interfaces to disconnect...${NC}"

    local conflicts=()
    while IFS= read -r line; do
        if [[ -z "$line" ]]; then continue; fi

        local ip=$(echo $line | awk '{print $2}' | cut -d'/' -f1)
        local network=$(echo $line | awk '{print $2}')
        local iface=$(echo $line | awk '{print $NF}')

        local ip_base=$(echo $ip | cut -d'.' -f1-3)
        if [[ "$ip_base" == "$target_base" ]]; then
            conflicts+=("$network:$iface")
        fi
    done < <(ip addr show | grep "inet " | grep -v "127.0.0.1" | awk '{print $2, $NF}')

    if [[ ${#conflicts[@]} -gt 0 ]]; then
        echo "Found conflicting interfaces:"
        for conflict in "${conflicts[@]}"; do
            local addr=$(echo $conflict | cut -d':' -f1)
            local iface=$(echo $conflict | cut -d':' -f2)
            echo "  - $addr on $iface"
        done

        echo
        echo -e "${YELLOW}Would you like to automatically disconnect these interfaces? (y/n)${NC}"
        read -r response

        if [[ "$response" == "y" ]]; then
            for conflict in "${conflicts[@]}"; do
                local addr=$(echo $conflict | cut -d':' -f1)
                local iface=$(echo $conflict | cut -d':' -f2)
                echo "Removing $addr from $iface..."
                sudo ip addr del "$addr" dev "$iface" 2>/dev/null || true
            done
            echo -e "${GREEN}Conflicting interfaces disconnected${NC}"
            return 0
        else
            echo -e "${YELLOW}Skipping automatic disconnect${NC}"
            return 1
        fi
    else
        echo "No conflicting interfaces found"
        return 0
    fi
}

# Function to deploy Lazarus
deploy_lazarus() {
    local network="${1}"
    local gateway="${2}"

    echo
    echo -e "${GREEN}Deploying Lazarus Emergency Router${NC}"
    echo "  Network: $network"
    echo "  Gateway: $gateway"
    echo "  Target: $LAZARUS_HOST"
    echo

    # Here you would add the actual deployment commands
    # For now, we'll simulate
    echo -e "${YELLOW}Configuring Lazarus router...${NC}"

    # SSH to Lazarus and configure
    if ping -c 1 -W 2 "$LAZARUS_HOST" &>/dev/null; then
        echo "Connecting to $LAZARUS_HOST..."

        # Create configuration commands
        cat > /tmp/lazarus_config.sh << EOF
#!/bin/sh
# Lazarus Emergency Network Configuration
uci set network.lan.ipaddr='$gateway'
uci set network.lan.netmask='255.255.255.0'
uci commit network
/etc/init.d/network restart
echo "Lazarus configured with IP: $gateway"
EOF

        # Deploy configuration
        if scp -o ConnectTimeout=5 /tmp/lazarus_config.sh root@"$LAZARUS_HOST":/tmp/; then
            if ssh -o ConnectTimeout=5 root@"$LAZARUS_HOST" "sh /tmp/lazarus_config.sh"; then
                echo -e "${GREEN}✓ Lazarus successfully configured${NC}"
                return 0
            fi
        fi
    else
        echo -e "${RED}Cannot reach Lazarus at $LAZARUS_HOST${NC}"
        echo "Please ensure Lazarus is connected and powered on"
        return 1
    fi
}

# Main execution
main() {
    local network="${1:-$DEFAULT_NETWORK}"
    local gateway="${2:-$DEFAULT_GATEWAY}"
    local force="${3:-}"

    # Step 1: Run safety checks
    if ! run_safety_checks "$network" "$gateway"; then
        if [[ "$force" == "--force" ]]; then
            echo -e "${YELLOW}Forcing deployment despite conflicts...${NC}"
        else
            echo
            echo -e "${YELLOW}Would you like to:${NC}"
            echo "  1) Find an alternative safe network automatically"
            echo "  2) Disconnect conflicting interfaces"
            echo "  3) Force deployment (risky!)"
            echo "  4) Cancel"
            echo
            read -p "Choice (1-4): " choice

            case $choice in
                1)
                    if find_safe_network; then
                        network="$SAFE_NETWORK"
                        gateway="$SAFE_GATEWAY"
                    else
                        echo -e "${RED}Deployment cancelled${NC}"
                        exit 1
                    fi
                    ;;
                2)
                    if disconnect_conflicts "$network"; then
                        # Re-run safety check after disconnect
                        if ! run_safety_checks "$network" "$gateway"; then
                            echo -e "${RED}Still have conflicts after disconnect${NC}"
                            exit 1
                        fi
                    else
                        echo -e "${RED}Deployment cancelled${NC}"
                        exit 1
                    fi
                    ;;
                3)
                    echo -e "${YELLOW}WARNING: Forcing deployment with conflicts!${NC}"
                    ;;
                4)
                    echo -e "${YELLOW}Deployment cancelled by user${NC}"
                    exit 0
                    ;;
                *)
                    echo -e "${RED}Invalid choice${NC}"
                    exit 1
                    ;;
            esac
        fi
    fi

    # Step 2: Deploy Lazarus
    if deploy_lazarus "$network" "$gateway"; then
        echo
        echo -e "${GREEN}═══════════════════════════════════════════════════${NC}"
        echo -e "${GREEN}     Lazarus Emergency Router Deployed!${NC}"
        echo -e "${GREEN}═══════════════════════════════════════════════════${NC}"
        echo
        echo "Network: $network"
        echo "Gateway: $gateway"
        echo
        echo "To connect:"
        echo "  1. Set your network interface to DHCP"
        echo "  2. Or manually set IP in range: ${gateway%.*}.100-200"
        echo
    else
        echo -e "${RED}Deployment failed${NC}"
        exit 1
    fi
}

# Check if collision check script exists
if [[ ! -f "$COLLISION_CHECK" ]]; then
    echo -e "${RED}Error: Collision check script not found at $COLLISION_CHECK${NC}"
    exit 1
fi

# Run main
main "$@"