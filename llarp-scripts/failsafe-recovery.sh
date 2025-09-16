#!/bin/bash

# OpenWRT Failsafe Mode Recovery for LLARP
# Automated procedures for router recovery via failsafe mode

set -euo pipefail

# Configuration
FAILSAFE_IP="192.168.1.1"
LOCAL_IP="192.168.1.100"
NETMASK="255.255.255.0"
INTERFACE="${INTERFACE:-eth0}"
TELNET_TIMEOUT=30

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}[$(date '+%H:%M:%S')] $1${NC}"; }
error() { echo -e "${RED}[ERROR] $1${NC}" >&2; }
success() { echo -e "${GREEN}[SUCCESS] $1${NC}"; }
warn() { echo -e "${YELLOW}[WARNING] $1${NC}"; }

# Check if running as root (required for network interface configuration)
check_root() {
    if [[ $EUID -ne 0 ]]; then
        error "This script requires root privileges for network interface configuration"
        echo "Run with: sudo $0 $*"
        exit 1
    fi
}

# Configure local network interface for failsafe access
configure_local_interface() {
    log "Configuring local interface $INTERFACE for failsafe access..."

    # Check if interface exists
    if ! ip link show "$INTERFACE" >/dev/null 2>&1; then
        error "Network interface $INTERFACE not found"
        echo "Available interfaces:"
        ip link show | grep '^[0-9]' | awk '{print $2}' | sed 's/://'
        return 1
    fi

    # Backup current configuration
    ip addr show "$INTERFACE" > "/tmp/interface_backup_$(date +%s).txt"

    # Add failsafe IP
    if ! ip addr show "$INTERFACE" | grep -q "$LOCAL_IP"; then
        ip addr add "$LOCAL_IP/$NETMASK" dev "$INTERFACE"
        success "Added $LOCAL_IP to interface $INTERFACE"
    else
        log "Interface already configured with $LOCAL_IP"
    fi

    # Bring interface up
    ip link set "$INTERFACE" up

    # Test connectivity
    if ping -c 1 -W 2 "$FAILSAFE_IP" >/dev/null 2>&1; then
        success "Failsafe IP $FAILSAFE_IP is reachable"
        return 0
    else
        warn "Failsafe IP not reachable - router may not be in failsafe mode"
        return 1
    fi
}

# Test telnet connection to failsafe router
test_telnet_connection() {
    log "Testing telnet connection to failsafe router..."

    if ! command -v telnet >/dev/null 2>&1; then
        error "telnet command not found. Install with: apt-get install telnet"
        return 1
    fi

    # Test telnet connectivity
    timeout 5 bash -c "echo | telnet $FAILSAFE_IP 23" >/dev/null 2>&1
}

# Execute commands via telnet in failsafe mode
failsafe_telnet_exec() {
    local commands="$1"

    log "Executing commands via telnet..."

    # Create expect script for telnet automation
    if command -v expect >/dev/null 2>&1; then
        expect << EOF
spawn telnet $FAILSAFE_IP
expect "OpenWrt"
send "$commands\r"
expect "#"
send "exit\r"
expect eof
EOF
    else
        # Manual telnet instructions
        warn "expect not available - manual telnet required"
        echo "Manual steps:"
        echo "1. telnet $FAILSAFE_IP"
        echo "2. Execute: $commands"
        echo "3. Type 'exit' to disconnect"
        return 1
    fi
}

# Guided failsafe mode entry
guide_failsafe_entry() {
    echo ""
    echo "FAILSAFE MODE ENTRY GUIDE"
    echo "========================="
    echo ""
    echo "1. Power off the router completely"
    echo "2. Power on the router"
    echo "3. Watch for LED blinking pattern (usually power LED)"
    echo "4. When LED blinks rapidly (5x per second), press and hold any button"
    echo "5. Hold button for 2-4 seconds until LED pattern changes"
    echo "6. Release button - router should boot to failsafe mode"
    echo ""
    echo "Failsafe Indicators:"
    echo "- Router IP becomes 192.168.1.1"
    echo "- DHCP is disabled"
    echo "- Wireless is disabled"
    echo "- Only LAN ports active"
    echo ""

    read -p "Press Enter when router is in failsafe mode..."
}

# Automatic failsafe recovery sequence
auto_failsafe_recovery() {
    local recovery_type="${1:-basic}"

    log "Starting automatic failsafe recovery ($recovery_type)..."

    # Configure local interface
    if ! configure_local_interface; then
        error "Failed to configure local interface"
        return 1
    fi

    # Test telnet connection
    if ! test_telnet_connection; then
        warn "Telnet connection failed - manual intervention may be required"
        guide_failsafe_entry
    fi

    case "$recovery_type" in
        "basic")
            local recovery_commands="
                mount_root
                uci set network.lan.ipaddr='192.168.1.1'
                uci set network.lan.netmask='255.255.255.0'
                uci commit network
                /etc/init.d/network restart
                /etc/init.d/dropbear start
            "
            ;;
        "factory")
            local recovery_commands="
                mount_root
                firstboot
                reboot
            "
            ;;
        "network-only")
            local recovery_commands="
                mount_root
                uci delete network
                uci commit network
                /etc/init.d/network restart
            "
            ;;
        *)
            error "Unknown recovery type: $recovery_type"
            return 1
            ;;
    esac

    log "Executing recovery commands..."
    if failsafe_telnet_exec "$recovery_commands"; then
        success "Failsafe recovery completed"
        log "Router should reboot and be accessible at 192.168.1.1"
        return 0
    else
        error "Failsafe recovery failed"
        return 1
    fi
}

# Restore from LLARP backup
restore_from_backup() {
    local backup_dir="$1"

    if [[ ! -d "$backup_dir" ]]; then
        error "Backup directory not found: $backup_dir"
        return 1
    fi

    log "Restoring configuration from $backup_dir..."

    # Find configuration files
    local config_files
    config_files=$(find "$backup_dir" -name "*.uci" -o -name "*config*")

    if [[ -z "$config_files" ]]; then
        error "No configuration files found in backup"
        return 1
    fi

    # Upload and restore each config
    for config_file in $config_files; do
        local config_name
        config_name=$(basename "$config_file" | sed 's/\.uci$//')

        log "Restoring $config_name configuration..."

        # Upload config file
        scp "$config_file" "root@$FAILSAFE_IP:/tmp/restore_$config_name.uci"

        # Import and commit
        ssh root@"$FAILSAFE_IP" "
            mount_root
            uci import $config_name < /tmp/restore_$config_name.uci
            uci commit $config_name
            rm /tmp/restore_$config_name.uci
        "
    done

    # Restart services
    ssh root@"$FAILSAFE_IP" "
        /etc/init.d/network restart
        /etc/init.d/dnsmasq restart
        /etc/init.d/firewall restart
        reboot
    "

    success "Configuration restored - router rebooting"
}

# Main command dispatcher
main() {
    case "${1:-help}" in
        "configure-interface")
            check_root
            configure_local_interface
            ;;
        "test-connection")
            test_telnet_connection && success "Telnet connection OK" || error "Telnet connection failed"
            ;;
        "guide")
            guide_failsafe_entry
            ;;
        "recover")
            check_root
            auto_failsafe_recovery "${2:-basic}"
            ;;
        "restore")
            if [[ $# -lt 2 ]]; then
                error "Backup directory required"
                echo "Usage: $0 restore <backup_directory>"
                exit 1
            fi
            restore_from_backup "$2"
            ;;
        "factory-reset")
            check_root
            auto_failsafe_recovery "factory"
            ;;
        "help"|*)
            echo "LLARP Failsafe Recovery System"
            echo ""
            echo "COMMANDS:"
            echo "    configure-interface        Configure local interface for failsafe"
            echo "    test-connection           Test telnet connection to failsafe router"
            echo "    guide                     Show failsafe mode entry guide"
            echo "    recover [basic|factory|network-only]  Automatic failsafe recovery"
            echo "    restore <backup_dir>      Restore from LLARP backup"
            echo "    factory-reset             Complete factory reset via failsafe"
            echo ""
            echo "EXAMPLES:"
            echo "    sudo $0 configure-interface"
            echo "    $0 guide"
            echo "    sudo $0 recover basic"
            echo "    $0 restore ./router_configs/backup_20250915/"
            echo ""
            echo "REQUIREMENTS:"
            echo "    - Root privileges for network configuration"
            echo "    - telnet command (apt-get install telnet)"
            echo "    - expect command for automation (apt-get install expect)"
            echo "    - Router in failsafe mode at 192.168.1.1"
            ;;
    esac
}

main "$@"