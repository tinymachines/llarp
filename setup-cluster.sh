#!/bin/bash
# Mass deployment script for Lazarus VPN cluster
# Supports configuring multiple worker boxes in sequence

MASTER_IP="17.0.0.1"
SCRIPT_PATH="./configure-worker-box.sh"

# IP assignment table for easy reference
declare -A BOX_IPS=(
    [1]="17.0.0.10"
    [2]="17.0.0.11"
    [3]="17.0.0.12"
    [4]="17.0.0.13"
    [5]="17.0.0.14"
    [6]="17.0.0.15"
    [7]="17.0.0.16"
    [8]="17.0.0.17"
    [9]="17.0.0.18"
    [10]="17.0.0.19"
)

# VPN provider suggestions for diversity
declare -A VPN_PROVIDERS=(
    [1]="NordVPN"
    [2]="ExpressVPN"
    [3]="Surfshark"
    [4]="ProtonVPN"
    [5]="CyberGhost"
    [6]="PIA"
    [7]="Windscribe"
    [8]="IPVanish"
    [9]="TunnelBear"
    [10]="HideMyAss"
)

echo "========================================"
echo "Lazarus VPN Cluster Setup Script"
echo "========================================"
echo "Master Load Balancer: ${MASTER_IP}"
echo "Configuration Script: ${SCRIPT_PATH}"
echo ""

if [ ! -f "$SCRIPT_PATH" ]; then
    echo "ERROR: Configuration script not found: $SCRIPT_PATH"
    echo "Please ensure configure-worker-box.sh is in the current directory."
    exit 1
fi

function show_ip_table() {
    echo "IP Assignment Table:"
    echo "==================="
    echo "Master:  17.0.0.1   (HAProxy Load Balancer)"
    for i in {1..10}; do
        echo "Box $i:   ${BOX_IPS[$i]}   (Suggested VPN: ${VPN_PROVIDERS[$i]})"
    done
    echo ""
}

function configure_box() {
    local box_number=$1
    local custom_hostname=$2
    local box_ip=${BOX_IPS[$box_number]}

    if [ -z "$box_ip" ]; then
        echo "ERROR: Invalid box number: $box_number (valid range: 1-10)"
        return 1
    fi

    echo "========================================"
    echo "Configuring Worker Box $box_number"
    echo "========================================"
    echo "Target IP: $box_ip"
    echo "Suggested VPN: ${VPN_PROVIDERS[$box_number]}"
    echo ""
    echo "INSTRUCTIONS:"
    echo "1. Connect ONLY the box to be configured"
    echo "2. Ensure it's accessible at 17.0.0.1 (master image)"
    echo "3. Master router should be disconnected to avoid IP conflicts"
    echo ""

    read -p "Is the target box connected and ready? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Configuration cancelled."
        return 1
    fi

    echo "Copying configuration script to target box..."
    scp "$SCRIPT_PATH" root@17.0.0.1:/tmp/ || {
        echo "ERROR: Failed to copy script. Is the box accessible?"
        return 1
    }

    echo "Running configuration script..."
    if [ -n "$custom_hostname" ]; then
        ssh root@17.0.0.1 "cd /tmp && chmod +x configure-worker-box.sh && echo 'y' | ./configure-worker-box.sh $box_number $custom_hostname"
    else
        ssh root@17.0.0.1 "cd /tmp && chmod +x configure-worker-box.sh && echo 'y' | ./configure-worker-box.sh $box_number"
    fi

    if [ $? -eq 0 ]; then
        echo ""
        echo "✅ Box $box_number configured successfully!"
        echo "New IP: $box_ip"
        echo "Suggested VPN: ${VPN_PROVIDERS[$box_number]}"
        echo ""
        echo "Next steps:"
        echo "1. Disconnect this box"
        echo "2. Connect next box to configure"
        echo "3. Or connect master router to test load balancing"
        echo ""
    else
        echo "❌ Configuration failed for Box $box_number"
        return 1
    fi
}

function update_haproxy_config() {
    local num_boxes=$1

    echo "Generating HAProxy configuration for $num_boxes worker boxes..."

    cat > haproxy-cluster.cfg << EOF
global
    maxconn 4096
    ulimit-n 65535
    nbthread 4
    log stdout local0

defaults
    mode tcp
    timeout connect 5000ms
    timeout client 50000ms
    timeout server 50000ms
    option dontlognull
    retries 3

# TCP Load Balancer Frontend
frontend tcp_frontend
    bind *:8080
    mode tcp
    default_backend tcp_backend

# TCP Backend Pool - Switch-based setup
backend tcp_backend
    mode tcp
    balance roundrobin
EOF

    for i in $(seq 1 $num_boxes); do
        local ip=${BOX_IPS[$i]}
        echo "    server lazarus$i $ip:8080 check" >> haproxy-cluster.cfg
    done

    cat >> haproxy-cluster.cfg << EOF

# UDP Load Balancer (for VPN traffic)
frontend udp_frontend
    bind *:1194
    mode tcp
    default_backend udp_backend

backend udp_backend
    mode tcp
    balance roundrobin
EOF

    for i in $(seq 1 $num_boxes); do
        local ip=${BOX_IPS[$i]}
        echo "    server vpn$i $ip:1194 check" >> haproxy-cluster.cfg
    done

    cat >> haproxy-cluster.cfg << EOF

# HTTPS Load Balancer
frontend https_frontend
    bind *:9443
    mode tcp
    default_backend https_backend

backend https_backend
    mode tcp
    balance roundrobin
EOF

    for i in $(seq 1 $num_boxes); do
        local ip=${BOX_IPS[$i]}
        echo "    server web$i $ip:443 check" >> haproxy-cluster.cfg
    done

    cat >> haproxy-cluster.cfg << EOF

# Statistics Interface (HTTP mode)
frontend stats
    bind *:8404
    mode http
    stats enable
    stats uri /stats
    stats refresh 30s
EOF

    echo "✅ HAProxy configuration generated: haproxy-cluster.cfg"
    echo ""
    echo "To apply to master router:"
    echo "scp haproxy-cluster.cfg root@17.0.0.1:/etc/haproxy.cfg"
    echo "ssh root@17.0.0.1 '/etc/init.d/haproxy restart'"
}

# Main menu
case "${1:-menu}" in
    "menu")
        show_ip_table
        echo "Usage: $0 <command> [options]"
        echo ""
        echo "Commands:"
        echo "  configure <box_number> [hostname]  - Configure a specific worker box"
        echo "  haproxy <num_boxes>               - Generate HAProxy config for N boxes"
        echo "  table                             - Show IP assignment table"
        echo ""
        echo "Examples:"
        echo "  $0 configure 1                    - Configure Box 1 as lazarus-worker1"
        echo "  $0 configure 2 vpn-exit-eu        - Configure Box 2 with custom hostname"
        echo "  $0 haproxy 5                      - Generate HAProxy config for 5 boxes"
        ;;
    "configure")
        if [ -z "$2" ]; then
            echo "ERROR: Box number required"
            echo "Usage: $0 configure <box_number> [hostname]"
            exit 1
        fi
        configure_box "$2" "$3"
        ;;
    "haproxy")
        if [ -z "$2" ]; then
            echo "ERROR: Number of boxes required"
            echo "Usage: $0 haproxy <num_boxes>"
            exit 1
        fi
        update_haproxy_config "$2"
        ;;
    "table")
        show_ip_table
        ;;
    *)
        echo "ERROR: Unknown command: $1"
        echo "Run '$0 menu' for usage information"
        exit 1
        ;;
esac