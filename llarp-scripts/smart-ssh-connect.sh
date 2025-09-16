#!/bin/bash

# Smart SSH Connection with Router Discovery and Failover
# Handles dynamic IP changes and provides multiple connection methods

set -euo pipefail

# Default configuration
DEFAULT_ROUTER_IPS=("192.168.100.1" "192.168.1.1" "15.0.0.1" "10.0.0.1")
DEFAULT_FAILSAFE_IP="192.168.1.1"
SSH_USER="root"
SSH_TIMEOUT=10
SSH_OPTIONS="-o ConnectTimeout=$SSH_TIMEOUT -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Discovery cache
DISCOVERY_CACHE="/tmp/llarp_router_discovery.cache"
UDP_BEACON_PORT=31337

# Log function
log() {
    echo -e "${BLUE}[$(date '+%H:%M:%S')] $1${NC}"
}

# Error function
error() {
    echo -e "${RED}[ERROR] $1${NC}" >&2
}

# Success function
success() {
    echo -e "${GREEN}[SUCCESS] $1${NC}"
}

# Warning function
warn() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

# Check if router responds to ping
ping_check() {
    local ip="$1"
    ping -c 1 -W 2 "$ip" >/dev/null 2>&1
}

# Test SSH connection and get router info
test_ssh_connection() {
    local ip="$1"
    local result

    # Test basic SSH connection
    if ! ssh $SSH_OPTIONS "$SSH_USER@$ip" "exit" 2>/dev/null; then
        return 1
    fi

    # Get router information
    result=$(ssh $SSH_OPTIONS "$SSH_USER@$ip" "
        echo 'HOSTNAME:' \$(uci get system.@system[0].hostname 2>/dev/null || echo 'unknown')
        echo 'CURRENT_IP:' \$(uci get network.lan.ipaddr 2>/dev/null || ip route get 1 | awk '{print \$7; exit}')
        echo 'MODEL:' \$(cat /proc/cpuinfo | grep 'machine' | cut -d: -f2 | tr -d ' ' || echo 'unknown')
        echo 'UPTIME:' \$(uptime | awk '{print \$3\" \"\$4}' | sed 's/,//')
        echo 'VERSION:' \$(cat /etc/openwrt_release | grep DISTRIB_DESCRIPTION | cut -d= -f2 | tr -d '\"')
    " 2>/dev/null)

    if [[ -n "$result" ]]; then
        echo "$result"
        return 0
    else
        return 1
    fi
}

# Discovery scan across multiple IP ranges
discover_routers() {
    log "Starting router discovery scan..."

    local found_routers=()

    # Check default IPs first
    for ip in "${DEFAULT_ROUTER_IPS[@]}"; do
        log "Checking $ip..."
        if ping_check "$ip"; then
            log "Ping successful for $ip, testing SSH..."
            if router_info=$(test_ssh_connection "$ip"); then
                success "Found router at $ip"
                echo "$router_info" | while IFS=: read -r key value; do
                    echo "  $key: $(echo $value | xargs)"
                done
                found_routers+=("$ip")

                # Cache the discovery
                echo "$ip" > "$DISCOVERY_CACHE"
                echo "$router_info" >> "$DISCOVERY_CACHE"
            else
                warn "SSH failed for $ip"
            fi
        fi
    done

    # Subnet scan if no routers found
    if [[ ${#found_routers[@]} -eq 0 ]]; then
        log "No routers found on default IPs, scanning common subnets..."

        local subnets=("192.168.1" "192.168.0" "192.168.100" "10.0.0" "172.16.0")
        for subnet in "${subnets[@]}"; do
            log "Scanning ${subnet}.0/24..."

            # Quick scan of common router IPs (.1, .254, .10, .100)
            local common_ips=("${subnet}.1" "${subnet}.254" "${subnet}.10" "${subnet}.100")
            for ip in "${common_ips[@]}"; do
                if ping_check "$ip"; then
                    if router_info=$(test_ssh_connection "$ip"); then
                        success "Discovered router at $ip"
                        echo "$router_info" | while IFS=: read -r key value; do
                            echo "  $key: $(echo $value | xargs)"
                        done
                        found_routers+=("$ip")
                        echo "$ip" > "$DISCOVERY_CACHE"
                        echo "$router_info" >> "$DISCOVERY_CACHE"
                        break 2  # Exit both loops
                    fi
                fi
            done
        done
    fi

    if [[ ${#found_routers[@]} -eq 0 ]]; then
        error "No OpenWRT routers discovered"
        return 1
    else
        success "Discovery complete. Found ${#found_routers[@]} router(s)"
        return 0
    fi
}

# Load cached router info
load_cached_router() {
    if [[ -f "$DISCOVERY_CACHE" ]]; then
        local cached_ip
        cached_ip=$(head -1 "$DISCOVERY_CACHE")

        log "Checking cached router at $cached_ip..."
        if ping_check "$cached_ip"; then
            if router_info=$(test_ssh_connection "$cached_ip"); then
                success "Cached router at $cached_ip is responsive"
                echo "$router_info"
                echo "$cached_ip"
                return 0
            fi
        fi
        warn "Cached router not responsive, removing cache"
        rm -f "$DISCOVERY_CACHE"
    fi
    return 1
}

# Send UDP beacon to discover routers
send_udp_beacon() {
    local broadcast_ip="$1"
    local message="LLARP_DISCOVERY:$(hostname):$(date +%s)"

    log "Sending UDP beacon to $broadcast_ip:$UDP_BEACON_PORT"

    # Send UDP beacon (requires netcat or similar)
    if command -v nc >/dev/null 2>&1; then
        echo "$message" | nc -u -w 1 "$broadcast_ip" "$UDP_BEACON_PORT" 2>/dev/null || true
    elif command -v nmap >/dev/null 2>&1; then
        # Alternative using nmap
        nmap -sU -p "$UDP_BEACON_PORT" --script-args "data=$message" "$broadcast_ip" >/dev/null 2>&1 || true
    else
        warn "No UDP send capability (nc or nmap) available"
    fi
}

# Listen for UDP beacon responses
listen_udp_responses() {
    local timeout="$1"

    log "Listening for router responses for ${timeout}s..."

    if command -v nc >/dev/null 2>&1; then
        timeout "$timeout" nc -u -l -p "$UDP_BEACON_PORT" 2>/dev/null | while IFS=: read -r response_type hostname ip; do
            if [[ "$response_type" == "LLARP_ROUTER" ]]; then
                success "Router beacon from $hostname at $ip"
                echo "$ip"
                return 0
            fi
        done
    else
        warn "Cannot listen for UDP responses (nc not available)"
        return 1
    fi
}

# Emergency failsafe connection
failsafe_connect() {
    log "Attempting failsafe connection..."

    # OpenWRT failsafe mode typically uses 192.168.1.1
    local failsafe_ip="$DEFAULT_FAILSAFE_IP"

    log "Checking failsafe IP: $failsafe_ip"
    if ping_check "$failsafe_ip"; then
        # In failsafe mode, SSH is usually available without auth
        if ssh -o PasswordAuthentication=no -o ConnectTimeout=5 "$SSH_USER@$failsafe_ip" "echo 'Failsafe connection successful'" 2>/dev/null; then
            success "Connected to router in failsafe mode at $failsafe_ip"
            warn "Router is in FAILSAFE MODE - limited functionality available"
            echo "HOSTNAME: failsafe"
            echo "CURRENT_IP: $failsafe_ip"
            echo "MODE: failsafe"
            echo "$failsafe_ip"
            return 0
        fi
    fi

    error "Failsafe connection failed"
    return 1
}

# Smart connect with multiple fallback methods
smart_connect() {
    local target_command="$1"

    log "Starting smart router connection..."

    # Method 1: Try cached router
    if load_cached_router >/dev/null 2>&1; then
        local cached_result
        cached_result=$(load_cached_router)
        local cached_ip
        cached_ip=$(echo "$cached_result" | tail -1)

        success "Using cached router at $cached_ip"
        if [[ -n "$target_command" ]]; then
            ssh $SSH_OPTIONS "$SSH_USER@$cached_ip" "$target_command"
        fi
        return 0
    fi

    # Method 2: Discovery scan
    if discover_routers; then
        local discovered_ip
        discovered_ip=$(head -1 "$DISCOVERY_CACHE")

        if [[ -n "$target_command" ]]; then
            ssh $SSH_OPTIONS "$SSH_USER@$discovered_ip" "$target_command"
        fi
        return 0
    fi

    # Method 3: UDP beacon discovery
    log "Attempting UDP beacon discovery..."
    local broadcast_ips=("255.255.255.255" "192.168.1.255" "192.168.100.255")
    for broadcast_ip in "${broadcast_ips[@]}"; do
        send_udp_beacon "$broadcast_ip"
        if beacon_ip=$(listen_udp_responses 5); then
            success "Router discovered via UDP beacon at $beacon_ip"
            if [[ -n "$target_command" ]]; then
                ssh $SSH_OPTIONS "$SSH_USER@$beacon_ip" "$target_command"
            fi
            return 0
        fi
    done

    # Method 4: Failsafe connection
    if failsafe_connect >/dev/null 2>&1; then
        if [[ -n "$target_command" ]]; then
            warn "Executing command in failsafe mode (limited functionality)"
            ssh -o PasswordAuthentication=no -o ConnectTimeout=5 "$SSH_USER@$DEFAULT_FAILSAFE_IP" "$target_command"
        fi
        return 0
    fi

    error "All connection methods failed"
    return 1
}

# Main function
main() {
    case "${1:-help}" in
        "discover")
            discover_routers
            ;;
        "connect")
            smart_connect "${2:-}"
            ;;
        "cached")
            load_cached_router
            ;;
        "failsafe")
            failsafe_connect
            ;;
        "beacon")
            send_udp_beacon "${2:-255.255.255.255}"
            ;;
        "listen")
            listen_udp_responses "${2:-30}"
            ;;
        "exec")
            if [[ $# -lt 2 ]]; then
                error "Command required for exec mode"
                exit 1
            fi
            shift
            smart_connect "$*"
            ;;
        "help"|*)
            echo "Smart SSH Connection for LLARP"
            echo ""
            echo "USAGE:"
            echo "    $0 discover                    # Discover available routers"
            echo "    $0 connect [command]           # Smart connect with optional command"
            echo "    $0 exec <command>              # Execute command on discovered router"
            echo "    $0 cached                      # Use cached router info"
            echo "    $0 failsafe                    # Attempt failsafe connection"
            echo "    $0 beacon [broadcast_ip]       # Send UDP discovery beacon"
            echo "    $0 listen [timeout]            # Listen for router beacons"
            echo ""
            echo "EXAMPLES:"
            echo "    $0 discover"
            echo "    $0 exec 'uci get system.@system[0].hostname'"
            echo "    $0 connect"
            ;;
    esac
}

main "$@"