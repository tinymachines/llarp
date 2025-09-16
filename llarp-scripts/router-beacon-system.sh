#!/bin/bash

# Router UDP Beacon System - "Here I Am" Emergency Communication
# Deploys UDP beacon service on OpenWRT routers for IP-agnostic discovery

set -euo pipefail

BEACON_PORT=31337
BEACON_SERVICE_NAME="llarp-beacon"
BEACON_SCRIPT_PATH="/usr/bin/llarp-beacon.sh"

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

# Generate beacon service script for router
generate_beacon_script() {
    cat << 'EOF'
#!/bin/sh

# LLARP Router Beacon Service
# Responds to UDP discovery requests with router information

BEACON_PORT=31337
RESPONSE_PORT=31338
LOG_TAG="llarp-beacon"

get_router_info() {
    local hostname=$(uci get system.@system[0].hostname 2>/dev/null || echo 'unknown')
    local current_ip=$(uci get network.lan.ipaddr 2>/dev/null || ip route get 1 | awk '{print $7; exit}' 2>/dev/null || echo 'unknown')
    local wan_ip=$(uci get network.wan.ipaddr 2>/dev/null || ip route get 8.8.8.8 | awk '{print $7; exit}' 2>/dev/null || echo 'unknown')
    local uptime=$(uptime | awk '{print $3" "$4}' | sed 's/,//')
    local load=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')

    echo "LLARP_ROUTER:$hostname:$current_ip:$wan_ip:$uptime:$load"
}

# UDP listener using netcat
start_beacon_listener() {
    logger -t "$LOG_TAG" "Starting LLARP beacon service on port $BEACON_PORT"

    while true; do
        # Listen for discovery requests
        if command -v nc >/dev/null 2>&1; then
            received=$(nc -l -u -p $BEACON_PORT -w 1 2>/dev/null || echo "")

            if [[ "$received" =~ ^LLARP_DISCOVERY: ]]; then
                # Extract sender info
                sender_host=$(echo "$received" | cut -d: -f2)
                sender_time=$(echo "$received" | cut -d: -f3)

                logger -t "$LOG_TAG" "Discovery request from $sender_host at $sender_time"

                # Send response with router info
                router_info=$(get_router_info)
                echo "$router_info" | nc -u -w 1 ${sender_host} $RESPONSE_PORT 2>/dev/null || {
                    # Fallback: broadcast response
                    echo "$router_info" | nc -u -w 1 -b 255.255.255.255 $RESPONSE_PORT 2>/dev/null || true
                }

                logger -t "$LOG_TAG" "Sent response: $router_info"
            fi
        else
            logger -t "$LOG_TAG" "netcat not available, beacon service disabled"
            sleep 60
        fi

        sleep 2  # Rate limiting
    done
}

# Check if we're running on OpenWRT
if ! grep -q "OpenWrt" /etc/os-release 2>/dev/null; then
    echo "This script is designed for OpenWRT routers"
    exit 1
fi

case "${1:-start}" in
    "start")
        start_beacon_listener &
        echo $! > /var/run/llarp-beacon.pid
        echo "LLARP beacon service started (PID: $!)"
        ;;
    "stop")
        if [[ -f /var/run/llarp-beacon.pid ]]; then
            kill $(cat /var/run/llarp-beacon.pid) 2>/dev/null || true
            rm -f /var/run/llarp-beacon.pid
            echo "LLARP beacon service stopped"
        else
            echo "Beacon service not running"
        fi
        ;;
    "status")
        if [[ -f /var/run/llarp-beacon.pid ]] && kill -0 $(cat /var/run/llarp-beacon.pid) 2>/dev/null; then
            echo "LLARP beacon service is running (PID: $(cat /var/run/llarp-beacon.pid))"
        else
            echo "LLARP beacon service is not running"
        fi
        ;;
    "info")
        get_router_info
        ;;
    *)
        echo "Usage: $0 {start|stop|status|info}"
        echo ""
        echo "LLARP Router Beacon Service"
        echo "Provides UDP-based router discovery immune to IP changes"
        exit 1
        ;;
esac
EOF
}

# Deploy beacon system to router
deploy_beacon() {
    local router_ip="$1"

    log "Deploying beacon system to router at $router_ip..."

    # Test connection first
    if ! ssh $SSH_OPTIONS "$SSH_USER@$router_ip" "exit" 2>/dev/null; then
        error "Cannot connect to router at $router_ip"
        return 1
    fi

    # Generate and deploy beacon script
    local beacon_script
    beacon_script=$(generate_beacon_script)

    log "Installing beacon script..."
    echo "$beacon_script" | ssh $SSH_OPTIONS "$SSH_USER@$router_ip" "cat > $BEACON_SCRIPT_PATH && chmod +x $BEACON_SCRIPT_PATH"

    # Create init script
    log "Creating init script..."
    ssh $SSH_OPTIONS "$SSH_USER@$router_ip" "cat > /etc/init.d/$BEACON_SERVICE_NAME << 'EOF'
#!/bin/sh /etc/rc.common

START=99
STOP=10

USE_PROCD=1

start_service() {
    procd_open_instance
    procd_set_param command $BEACON_SCRIPT_PATH start
    procd_set_param respawn
    procd_close_instance
}

stop_service() {
    $BEACON_SCRIPT_PATH stop
}
EOF"

    # Make init script executable
    ssh $SSH_OPTIONS "$SSH_USER@$router_ip" "chmod +x /etc/init.d/$BEACON_SERVICE_NAME"

    # Enable and start service
    log "Enabling beacon service..."
    ssh $SSH_OPTIONS "$SSH_USER@$router_ip" "/etc/init.d/$BEACON_SERVICE_NAME enable"
    ssh $SSH_OPTIONS "$SSH_USER@$router_ip" "/etc/init.d/$BEACON_SERVICE_NAME start"

    success "Beacon system deployed and started"

    # Test the beacon
    log "Testing beacon response..."
    local router_info
    router_info=$(ssh $SSH_OPTIONS "$SSH_USER@$router_ip" "$BEACON_SCRIPT_PATH info")
    echo "Router info: $router_info"

    return 0
}

# Test discovery system
test_discovery() {
    log "Testing router discovery system..."

    # Try smart connect
    if smart_connect "echo 'Discovery test successful'"; then
        success "Discovery system working"
        return 0
    else
        error "Discovery system failed"
        return 1
    fi
}

# Main command dispatcher
main() {
    case "${1:-help}" in
        "deploy")
            if [[ $# -lt 2 ]]; then
                error "Router IP required"
                echo "Usage: $0 deploy <router_ip>"
                exit 1
            fi
            deploy_beacon "$2"
            ;;
        "discover")
            discover_routers
            ;;
        "test")
            test_discovery
            ;;
        "connect")
            smart_connect "${2:-}"
            ;;
        "exec")
            if [[ $# -lt 2 ]]; then
                error "Command required"
                exit 1
            fi
            shift
            smart_connect "$*"
            ;;
        "help"|*)
            echo "LLARP Router Beacon System"
            echo ""
            echo "COMMANDS:"
            echo "    deploy <router_ip>     Deploy beacon service to router"
            echo "    discover               Discover available routers"
            echo "    test                   Test discovery system"
            echo "    connect [command]      Smart connect to router"
            echo "    exec <command>         Execute command on discovered router"
            echo ""
            echo "EXAMPLES:"
            echo "    $0 deploy 192.168.1.1"
            echo "    $0 discover"
            echo "    $0 exec 'uci show system'"
            echo ""
            echo "The beacon system provides IP-agnostic router discovery"
            echo "using UDP broadcasts on port $BEACON_PORT"
            ;;
    esac
}

main "$@"