#!/bin/bash

# OpenWRT Configuration Scanner
# Collects comprehensive configuration and system information from OpenWRT routers
# Usage: ./openwrt_scanner.sh <router_ip> [output_base_dir]

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default values
ROUTER_IP="${1:-}"
BASE_OUTPUT_DIR="${2:-./router_configs}"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Validate input
if [ -z "$ROUTER_IP" ]; then
    echo -e "${RED}Error: Router IP address required${NC}"
    echo "Usage: $0 <router_ip> [output_base_dir]"
    exit 1
fi

# SSH options for better reliability
SSH_OPTS="-o ConnectTimeout=10 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
SSH_CMD="ssh $SSH_OPTS root@$ROUTER_IP"
SCP_CMD="scp $SSH_OPTS"

# Test SSH connection
echo -e "${YELLOW}Testing SSH connection to $ROUTER_IP...${NC}"
if ! $SSH_CMD "exit" 2>/dev/null; then
    echo -e "${RED}Error: Cannot connect to router at $ROUTER_IP${NC}"
    exit 1
fi

# Get router hostname for directory naming
ROUTER_HOSTNAME=$($SSH_CMD "uci get system.@system[0].hostname 2>/dev/null || echo 'unknown'" | tr -d '\r')
OUTPUT_DIR="${BASE_OUTPUT_DIR}/${ROUTER_HOSTNAME}_${ROUTER_IP}_${TIMESTAMP}"

# Create output directory structure
echo -e "${GREEN}Creating output directory: $OUTPUT_DIR${NC}"
mkdir -p "$OUTPUT_DIR"/{configs,system,network,logs,services}

# Create metadata file
cat > "$OUTPUT_DIR/metadata.json" << EOF
{
  "scan_timestamp": "$(date -u +"%Y-%m-%d %H:%M:%S UTC")",
  "router_ip": "$ROUTER_IP",
  "router_hostname": "$ROUTER_HOSTNAME",
  "scanner_version": "1.0"
}
EOF

# Function to run command and save output
run_and_save() {
    local cmd="$1"
    local output_file="$2"
    local description="$3"
    
    echo -e "${YELLOW}Collecting: $description${NC}"
    if $SSH_CMD "$cmd" > "$output_file" 2>/dev/null; then
        echo -e "${GREEN}  ✓ Saved to: $output_file${NC}"
    else
        echo -e "${RED}  ✗ Failed to collect $description${NC}"
        echo "Command failed: $cmd" > "$output_file.error"
    fi
}

# Collect UCI configuration files
echo -e "\n${GREEN}=== Collecting UCI Configuration Files ===${NC}"
UCI_CONFIGS=(
    "network"
    "wireless"
    "firewall"
    "dhcp"
    "system"
    "dropbear"
    "uhttpd"
    "openvpn"
    "wireguard"
    "ddns"
    "sqm"
    "qos"
    "mwan3"
)

for config in "${UCI_CONFIGS[@]}"; do
    run_and_save "uci export $config 2>/dev/null || echo 'Config not found'" \
                 "$OUTPUT_DIR/configs/uci_${config}.conf" \
                 "UCI config: $config"
done

# Collect raw configuration files
echo -e "\n${GREEN}=== Collecting Raw Configuration Files ===${NC}"
RAW_CONFIGS=(
    "/etc/config/*"
    "/etc/hosts"
    "/etc/dnsmasq.conf"
    "/etc/dropbear/authorized_keys"
    "/etc/rc.local"
    "/etc/sysupgrade.conf"
    "/etc/opkg/customfeeds.conf"
    "/etc/crontabs/root"
)

# Create a tar archive of raw configs on the router and transfer
$SSH_CMD "tar czf /tmp/raw_configs.tar.gz ${RAW_CONFIGS[*]} 2>/dev/null || true"
$SCP_CMD "root@$ROUTER_IP:/tmp/raw_configs.tar.gz" "$OUTPUT_DIR/configs/" 2>/dev/null || true
$SSH_CMD "rm -f /tmp/raw_configs.tar.gz"

# Extract the tar file locally
if [ -f "$OUTPUT_DIR/configs/raw_configs.tar.gz" ]; then
    cd "$OUTPUT_DIR/configs"
    tar xzf raw_configs.tar.gz 2>/dev/null || true
    cd - > /dev/null
fi

# Collect system information
echo -e "\n${GREEN}=== Collecting System Information ===${NC}"
run_and_save "cat /proc/version" "$OUTPUT_DIR/system/kernel_version.txt" "Kernel version"
run_and_save "cat /etc/openwrt_release" "$OUTPUT_DIR/system/openwrt_release.txt" "OpenWRT release"
run_and_save "cat /proc/cpuinfo" "$OUTPUT_DIR/system/cpuinfo.txt" "CPU information"
run_and_save "cat /proc/meminfo" "$OUTPUT_DIR/system/meminfo.txt" "Memory information"
run_and_save "df -h" "$OUTPUT_DIR/system/disk_usage.txt" "Disk usage"
run_and_save "mount" "$OUTPUT_DIR/system/mount_points.txt" "Mount points"
run_and_save "opkg list-installed" "$OUTPUT_DIR/system/installed_packages.txt" "Installed packages"
run_and_save "ubus call system board" "$OUTPUT_DIR/system/board_info.json" "Board information"

# Collect network information
echo -e "\n${GREEN}=== Collecting Network Information ===${NC}"
run_and_save "ip addr show" "$OUTPUT_DIR/network/ip_addresses.txt" "IP addresses"
run_and_save "ip route show" "$OUTPUT_DIR/network/routes.txt" "Routing table"
run_and_save "ip -6 route show" "$OUTPUT_DIR/network/routes_ipv6.txt" "IPv6 routing table"
run_and_save "ip rule show" "$OUTPUT_DIR/network/ip_rules.txt" "IP rules"
run_and_save "bridge fdb show" "$OUTPUT_DIR/network/bridge_fdb.txt" "Bridge FDB"
run_and_save "ip neigh show" "$OUTPUT_DIR/network/arp_table.txt" "ARP table"
run_and_save "netstat -tuln" "$OUTPUT_DIR/network/listening_ports.txt" "Listening ports"
run_and_save "iptables-save" "$OUTPUT_DIR/network/iptables_rules.txt" "Iptables rules"
run_and_save "ip6tables-save" "$OUTPUT_DIR/network/ip6tables_rules.txt" "IPv6 tables rules"
run_and_save "tc qdisc show" "$OUTPUT_DIR/network/tc_qdisc.txt" "Traffic control"
run_and_save "iw dev" "$OUTPUT_DIR/network/wireless_devices.txt" "Wireless devices"

# Collect DHCP leases
echo -e "\n${GREEN}=== Collecting DHCP Information ===${NC}"
run_and_save "cat /tmp/dhcp.leases" "$OUTPUT_DIR/network/dhcp_leases.txt" "DHCP leases"
run_and_save "cat /tmp/hosts/odhcpd" "$OUTPUT_DIR/network/dhcpv6_leases.txt" "DHCPv6 leases"

# Collect service information
echo -e "\n${GREEN}=== Collecting Service Information ===${NC}"
run_and_save "ps aux" "$OUTPUT_DIR/services/processes.txt" "Running processes"
run_and_save "/etc/init.d/* enabled 2>&1 | grep -E '^\s*/etc/init.d/'" "$OUTPUT_DIR/services/enabled_services.txt" "Enabled services"
run_and_save "logread" "$OUTPUT_DIR/logs/system_log.txt" "System log"
run_and_save "dmesg" "$OUTPUT_DIR/logs/kernel_log.txt" "Kernel log"

# Collect wireless information if available
echo -e "\n${GREEN}=== Collecting Wireless Information ===${NC}"
run_and_save "iwinfo" "$OUTPUT_DIR/network/wireless_info.txt" "Wireless information"
run_and_save "iw phy" "$OUTPUT_DIR/network/wireless_phy.txt" "Wireless PHY info"

# Create summary report
echo -e "\n${GREEN}=== Creating Summary Report ===${NC}"
cat > "$OUTPUT_DIR/summary_report.txt" << EOF
OpenWRT Router Configuration Summary
====================================
Scan Date: $(date)
Router IP: $ROUTER_IP
Router Hostname: $ROUTER_HOSTNAME

System Information:
------------------
EOF

# Add system info to summary
if [ -f "$OUTPUT_DIR/system/openwrt_release.txt" ]; then
    echo -e "\nOpenWRT Version:" >> "$OUTPUT_DIR/summary_report.txt"
    cat "$OUTPUT_DIR/system/openwrt_release.txt" >> "$OUTPUT_DIR/summary_report.txt"
fi

# Add network interfaces to summary
echo -e "\nNetwork Interfaces:" >> "$OUTPUT_DIR/summary_report.txt"
echo "-------------------" >> "$OUTPUT_DIR/summary_report.txt"
if [ -f "$OUTPUT_DIR/network/ip_addresses.txt" ]; then
    grep -E "^[0-9]+:|inet " "$OUTPUT_DIR/network/ip_addresses.txt" >> "$OUTPUT_DIR/summary_report.txt" || true
fi

# Add installed packages count
echo -e "\nInstalled Packages:" >> "$OUTPUT_DIR/summary_report.txt"
echo "-------------------" >> "$OUTPUT_DIR/summary_report.txt"
if [ -f "$OUTPUT_DIR/system/installed_packages.txt" ]; then
    echo "Total packages: $(wc -l < "$OUTPUT_DIR/system/installed_packages.txt")" >> "$OUTPUT_DIR/summary_report.txt"
fi

# Create a JSON inventory file for automation
echo -e "\n${GREEN}=== Creating JSON Inventory ===${NC}"
cat > "$OUTPUT_DIR/inventory.json" << EOF
{
  "router": {
    "hostname": "$ROUTER_HOSTNAME",
    "ip_address": "$ROUTER_IP",
    "scan_timestamp": "$(date -u +"%Y-%m-%d %H:%M:%S UTC")"
  },
  "configs_collected": [
$(find "$OUTPUT_DIR" -type f -name "*.conf" -o -name "*.txt" -o -name "*.json" | \
  grep -v "inventory.json" | \
  sed 's/.*/"    "&",/' | \
  sed '$ s/,$//')
  ]
}
EOF

# Create comparison helper script
cat > "$OUTPUT_DIR/../compare_routers.sh" << 'EOF'
#!/bin/bash
# Helper script to compare configurations between two router scans

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <router_dir1> <router_dir2>"
    exit 1
fi

DIR1="$1"
DIR2="$2"

echo "Comparing configurations between:"
echo "  Router 1: $(basename "$DIR1")"
echo "  Router 2: $(basename "$DIR2")"
echo

# Compare UCI configs
for config in "$DIR1"/configs/uci_*.conf; do
    config_name=$(basename "$config")
    if [ -f "$DIR2/configs/$config_name" ]; then
        if ! diff -q "$config" "$DIR2/configs/$config_name" > /dev/null; then
            echo "Differences found in $config_name:"
            diff -u "$config" "$DIR2/configs/$config_name" | head -20
            echo
        fi
    else
        echo "Config $config_name missing in Router 2"
    fi
done
EOF

chmod +x "$OUTPUT_DIR/../compare_routers.sh"

# Clean up sensitive data if needed (optional)
# find "$OUTPUT_DIR" -name "authorized_keys" -exec rm {} \;

# Create archive for easy transfer
echo -e "\n${GREEN}=== Creating Archive ===${NC}"
ARCHIVE_NAME="${ROUTER_HOSTNAME}_${ROUTER_IP}_${TIMESTAMP}.tar.gz"
cd "$BASE_OUTPUT_DIR"
tar czf "$ARCHIVE_NAME" "$(basename "$OUTPUT_DIR")"
cd - > /dev/null

echo -e "\n${GREEN}=== Scan Complete ===${NC}"
echo -e "Configuration saved to: ${GREEN}$OUTPUT_DIR${NC}"
echo -e "Archive created: ${GREEN}$BASE_OUTPUT_DIR/$ARCHIVE_NAME${NC}"
echo -e "\nTo compare with another router, use:"
echo -e "  ${YELLOW}$OUTPUT_DIR/../compare_routers.sh $OUTPUT_DIR <other_router_dir>${NC}"
