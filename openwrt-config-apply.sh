#!/bin/bash

# OpenWRT Configuration Applier
# Applies collected configurations to OpenWRT routers
# Usage: ./openwrt_applier.sh <router_ip> <config_dir> [options]

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Parse arguments
ROUTER_IP="${1:-}"
CONFIG_DIR="${2:-}"
DRY_RUN=false
SELECTIVE=false
BACKUP_FIRST=true

# Show usage
usage() {
    echo "Usage: $0 <router_ip> <config_dir> [options]"
    echo "Options:"
    echo "  --dry-run        Show what would be changed without applying"
    echo "  --selective      Choose which configurations to apply"
    echo "  --no-backup      Skip backing up current configuration"
    echo "  --force          Apply without confirmation prompts"
    exit 1
}

# Parse options
shift 2 || usage
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --selective)
            SELECTIVE=true
            shift
            ;;
        --no-backup)
            BACKUP_FIRST=false
            shift
            ;;
        --force)
            FORCE=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

# Validate inputs
if [ -z "$ROUTER_IP" ] || [ -z "$CONFIG_DIR" ]; then
    usage
fi

if [ ! -d "$CONFIG_DIR" ]; then
    echo -e "${RED}Error: Configuration directory not found: $CONFIG_DIR${NC}"
    exit 1
fi

# SSH options
SSH_OPTS="-o ConnectTimeout=10 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
SSH_CMD="ssh $SSH_OPTS root@$ROUTER_IP"
SCP_CMD="scp $SSH_OPTS"

# Test SSH connection
echo -e "${YELLOW}Testing SSH connection to $ROUTER_IP...${NC}"
if ! $SSH_CMD "exit" 2>/dev/null; then
    echo -e "${RED}Error: Cannot connect to router at $ROUTER_IP${NC}"
    exit 1
fi

# Function to apply UCI configuration
apply_uci_config() {
    local config_name="$1"
    local config_file="$2"
    
    if [ "$DRY_RUN" = true ]; then
        echo -e "${BLUE}[DRY RUN] Would apply UCI config: $config_name${NC}"
        return
    fi
    
    echo -e "${YELLOW}Applying UCI config: $config_name${NC}"
    
    # Upload the config file
    $SCP_CMD "$config_file" "root@$ROUTER_IP:/tmp/uci_import_$config_name.conf" 2>/dev/null
    
    # Import the configuration
    if $SSH_CMD "uci import $config_name < /tmp/uci_import_$config_name.conf && uci commit $config_name" 2>/dev/null; then
        echo -e "${GREEN}  ✓ Successfully applied $config_name${NC}"
    else
        echo -e "${RED}  ✗ Failed to apply $config_name${NC}"
    fi
    
    # Clean up
    $SSH_CMD "rm -f /tmp/uci_import_$config_name.conf" 2>/dev/null
}

# Function to show differences
show_diff() {
    local config_name="$1"
    local local_file="$2"
    
    echo -e "${YELLOW}Checking differences for $config_name...${NC}"
    
    # Export current config from router
    CURRENT_CONFIG=$($SSH_CMD "uci export $config_name 2>/dev/null || echo 'Config not found'")
    
    # Create temp file for comparison
    TEMP_FILE="/tmp/current_$config_name_$$.conf"
    echo "$CURRENT_CONFIG" > "$TEMP_FILE"
    
    # Show differences
    if diff -u "$TEMP_FILE" "$local_file" > /dev/null 2>&1; then
        echo -e "${GREEN}  No changes needed for $config_name${NC}"
    else
        echo -e "${YELLOW}  Changes to be applied:${NC}"
        diff -u "$TEMP_FILE" "$local_file" | grep -E "^[+-]" | head -20 || true
    fi
    
    rm -f "$TEMP_FILE"
}

# Backup current configuration
if [ "$BACKUP_FIRST" = true ] && [ "$DRY_RUN" = false ]; then
    echo -e "\n${GREEN}=== Backing up current configuration ===${NC}"
    BACKUP_DIR="./router_backup_${ROUTER_IP}_$(date +%Y%m%d_%H%M%S)"
    ./openwrt_scanner.sh "$ROUTER_IP" "$BACKUP_DIR"
fi

# Get list of available UCI configs
echo -e "\n${GREEN}=== Available UCI Configurations ===${NC}"
UCI_CONFIGS=()
for conf in "$CONFIG_DIR"/configs/uci_*.conf; do
    if [ -f "$conf" ]; then
        config_name=$(basename "$conf" | sed 's/uci_\(.*\)\.conf/\1/')
        UCI_CONFIGS+=("$config_name")
        echo "  - $config_name"
    fi
done

# Select configurations to apply
if [ "$SELECTIVE" = true ]; then
    echo -e "\n${YELLOW}Select configurations to apply (space-separated numbers):${NC}"
    for i in "${!UCI_CONFIGS[@]}"; do
        echo "  $((i+1)). ${UCI_CONFIGS[$i]}"
    done
    read -p "Enter numbers (e.g., 1 3 5) or 'all': " selection
    
    if [ "$selection" != "all" ]; then
        SELECTED_CONFIGS=()
        for num in $selection; do
            idx=$((num-1))
            if [ $idx -ge 0 ] && [ $idx -lt ${#UCI_CONFIGS[@]} ]; then
                SELECTED_CONFIGS+=("${UCI_CONFIGS[$idx]}")
            fi
        done
        UCI_CONFIGS=("${SELECTED_CONFIGS[@]}")
    fi
fi

# Show what will be changed
echo -e "\n${GREEN}=== Configuration Changes Preview ===${NC}"
for config in "${UCI_CONFIGS[@]}"; do
    config_file="$CONFIG_DIR/configs/uci_${config}.conf"
    if [ -f "$config_file" ]; then
        show_diff "$config" "$config_file"
    fi
done

# Confirm before applying
if [ "$DRY_RUN" = false ] && [ "${FORCE:-false}" != true ]; then
    echo -e "\n${YELLOW}Do you want to apply these configurations? (yes/no)${NC}"
    read -p "> " confirm
    if [ "$confirm" != "yes" ]; then
        echo "Aborted."
        exit 0
    fi
fi

# Apply configurations
if [ "$DRY_RUN" = false ]; then
    echo -e "\n${GREEN}=== Applying Configurations ===${NC}"
    for config in "${UCI_CONFIGS[@]}"; do
        config_file="$CONFIG_DIR/configs/uci_${config}.conf"
        if [ -f "$config_file" ]; then
            apply_uci_config "$config" "$config_file"
        fi
    done
    
    # Restart affected services
    echo -e "\n${GREEN}=== Restarting Services ===${NC}"
    
    # Determine which services to restart based on configs applied
    SERVICES_TO_RESTART=()
    [[ " ${UCI_CONFIGS[@]} " =~ " network " ]] && SERVICES_TO_RESTART+=("network")
    [[ " ${UCI_CONFIGS[@]} " =~ " wireless " ]] && SERVICES_TO_RESTART+=("network")
    [[ " ${UCI_CONFIGS[@]} " =~ " firewall " ]] && SERVICES_TO_RESTART+=("firewall")
    [[ " ${UCI_CONFIGS[@]} " =~ " dhcp " ]] && SERVICES_TO_RESTART+=("dnsmasq" "odhcpd")
    [[ " ${UCI_CONFIGS[@]} " =~ " dropbear " ]] && SERVICES_TO_RESTART+=("dropbear")
    
    # Remove duplicates
    SERVICES_TO_RESTART=($(echo "${SERVICES_TO_RESTART[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
    
    for service in "${SERVICES_TO_RESTART[@]}"; do
        echo -e "${YELLOW}Restarting $service...${NC}"
        if $SSH_CMD "/etc/init.d/$service restart" 2>/dev/null; then
            echo -e "${GREEN}  ✓ $service restarted${NC}"
        else
            echo -e "${RED}  ✗ Failed to restart $service${NC}"
        fi
    done
fi

echo -e "\n${GREEN}=== Complete ===${NC}"
if [ "$DRY_RUN" = true ]; then
    echo "This was a dry run. No changes were applied."
else
    echo "Configuration has been applied to $ROUTER_IP"
fi

# Show post-apply verification commands
echo -e "\n${YELLOW}Verification commands you can run:${NC}"
echo "  ssh root@$ROUTER_IP 'uci show network'"
echo "  ssh root@$ROUTER_IP 'ip addr show'"
echo "  ssh root@$ROUTER_IP 'logread | tail -50'"
