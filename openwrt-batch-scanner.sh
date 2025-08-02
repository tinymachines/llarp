#!/bin/bash

# OpenWRT Batch Scanner with Network Report
# Scans multiple routers and creates a comprehensive network report
# Usage: ./batch_scanner.sh routers.txt [output_dir]

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Input file containing router IPs (one per line)
ROUTER_LIST="${1:-routers.txt}"
OUTPUT_BASE_DIR="${2:-./network_scan_$(date +%Y%m%d_%H%M%S)}"

# Validate input
if [ ! -f "$ROUTER_LIST" ]; then
    echo -e "${RED}Error: Router list file not found: $ROUTER_LIST${NC}"
    echo "Usage: $0 <router_list_file> [output_directory]"
    echo ""
    echo "Create a file with router IPs, one per line:"
    echo "192.168.1.1"
    echo "192.168.1.2"
    echo "10.0.0.1"
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_BASE_DIR"

# Copy scanner script if not in PATH
if ! command -v openwrt_scanner.sh &> /dev/null; then
    if [ -f "./openwrt_scanner.sh" ]; then
        cp ./openwrt_scanner.sh "$OUTPUT_BASE_DIR/"
        SCANNER_CMD="$OUTPUT_BASE_DIR/openwrt_scanner.sh"
    else
        echo -e "${RED}Error: openwrt_scanner.sh not found${NC}"
        exit 1
    fi
else
    SCANNER_CMD="openwrt_scanner.sh"
fi

# Initialize report files
SUMMARY_REPORT="$OUTPUT_BASE_DIR/network_summary_report.html"
INVENTORY_JSON="$OUTPUT_BASE_DIR/network_inventory.json"
SCAN_LOG="$OUTPUT_BASE_DIR/scan_log.txt"

# Start HTML report
cat > "$SUMMARY_REPORT" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>OpenWRT Network Configuration Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background-color: white; padding: 20px; box-shadow: 0 0 10px rgba(0,0,0,0.1); }
        h1, h2, h3 { color: #333; }
        .router-card { border: 1px solid #ddd; padding: 15px; margin: 10px 0; border-radius: 5px; }
        .success { background-color: #d4edda; }
        .failed { background-color: #f8d7da; }
        table { border-collapse: collapse; width: 100%; margin: 10px 0; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; font-weight: bold; }
        .status-ok { color: green; }
        .status-error { color: red; }
        .summary-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 10px; margin: 20px 0; }
        .summary-box { background-color: #e9ecef; padding: 15px; border-radius: 5px; text-align: center; }
        .summary-box h3 { margin: 0 0 10px 0; }
        .summary-box .number { font-size: 2em; font-weight: bold; color: #007bff; }
        pre { background-color: #f8f9fa; padding: 10px; overflow-x: auto; }
        .collapsible { cursor: pointer; padding: 10px; background-color: #007bff; color: white; border: none; text-align: left; width: 100%; }
        .collapsible:hover { background-color: #0056b3; }
        .content { padding: 0 18px; display: none; overflow: hidden; background-color: #f1f1f1; }
    </style>
    <script>
        function toggleContent(id) {
            var content = document.getElementById(id);
            if (content.style.display === "block") {
                content.style.display = "none";
            } else {
                content.style.display = "block";
            }
        }
    </script>
</head>
<body>
    <div class="container">
        <h1>OpenWRT Network Configuration Report</h1>
        <p>Generated on: <strong>SCAN_DATE</strong></p>
        
        <div class="summary-grid">
            <div class="summary-box">
                <h3>Total Routers</h3>
                <div class="number" id="total-routers">0</div>
            </div>
            <div class="summary-box">
                <h3>Successful Scans</h3>
                <div class="number" id="successful-scans">0</div>
            </div>
            <div class="summary-box">
                <h3>Failed Scans</h3>
                <div class="number" id="failed-scans">0</div>
            </div>
            <div class="summary-box">
                <h3>Total Packages</h3>
                <div class="number" id="total-packages">0</div>
            </div>
        </div>
        
        <h2>Router Overview</h2>
        <table id="router-overview">
            <tr>
                <th>Hostname</th>
                <th>IP Address</th>
                <th>OpenWRT Version</th>
                <th>Kernel</th>
                <th>Packages</th>
                <th>Status</th>
                <th>Config Path</th>
            </tr>
        </table>
        
        <h2>Network Topology</h2>
        <div id="network-topology">
            <!-- Will be populated by script -->
        </div>
        
        <h2>Common Packages</h2>
        <div id="common-packages">
            <!-- Will be populated by script -->
        </div>
        
        <h2>Detailed Router Information</h2>
        <div id="detailed-info">
            <!-- Will be populated by script -->
        </div>
    </div>
</body>
</html>
EOF

# Initialize JSON inventory
echo '{"scan_info": {' > "$INVENTORY_JSON"
echo "  \"scan_date\": \"$(date -u +"%Y-%m-%d %H:%M:%S UTC")\"," >> "$INVENTORY_JSON"
echo "  \"total_routers\": 0," >> "$INVENTORY_JSON"
echo "  \"successful_scans\": 0," >> "$INVENTORY_JSON"
echo "  \"failed_scans\": 0" >> "$INVENTORY_JSON"
echo "}," >> "$INVENTORY_JSON"
echo '"routers": [' >> "$INVENTORY_JSON"

# Count routers
TOTAL_ROUTERS=$(grep -v '^#' "$ROUTER_LIST" | grep -v '^$' | wc -l)
SUCCESSFUL_SCANS=0
FAILED_SCANS=0
FIRST_ROUTER=true

echo -e "${GREEN}=== Starting Batch Scan of $TOTAL_ROUTERS Routers ===${NC}"
echo "Scan started at $(date)" > "$SCAN_LOG"

# Scan each router
while IFS= read -r ROUTER_IP || [ -n "$ROUTER_IP" ]; do
    # Skip comments and empty lines
    [[ "$ROUTER_IP" =~ ^#.*$ ]] && continue
    [[ -z "$ROUTER_IP" ]] && continue
    
    echo -e "\n${BLUE}Scanning router: $ROUTER_IP${NC}"
    echo "----------------------------------------" | tee -a "$SCAN_LOG"
    echo "Scanning $ROUTER_IP at $(date)" | tee -a "$SCAN_LOG"
    
    # Run the scanner
    if $SCANNER_CMD "$ROUTER_IP" "$OUTPUT_BASE_DIR" >> "$SCAN_LOG" 2>&1; then
        echo -e "${GREEN}✓ Successfully scanned $ROUTER_IP${NC}"
        SUCCESSFUL_SCANS=$((SUCCESSFUL_SCANS + 1))
        
        # Find the latest scan directory for this router
        SCAN_DIR=$(find "$OUTPUT_BASE_DIR" -maxdepth 1 -type d -name "*_${ROUTER_IP}_*" | sort -r | head -1)
        
        if [ -n "$SCAN_DIR" ] && [ -d "$SCAN_DIR" ]; then
            # Extract information for the report
            HOSTNAME=$(basename "$SCAN_DIR" | cut -d'_' -f1)
            
            # Add to JSON inventory
            if [ "$FIRST_ROUTER" = false ]; then
                echo "," >> "$INVENTORY_JSON"
            fi
            FIRST_ROUTER=false
            
            echo "  {" >> "$INVENTORY_JSON"
            echo "    \"hostname\": \"$HOSTNAME\"," >> "$INVENTORY_JSON"
            echo "    \"ip_address\": \"$ROUTER_IP\"," >> "$INVENTORY_JSON"
            echo "    \"scan_status\": \"success\"," >> "$INVENTORY_JSON"
            echo "    \"scan_directory\": \"$SCAN_DIR\"," >> "$INVENTORY_JSON"
            
            # Extract version info
            if [ -f "$SCAN_DIR/system/openwrt_release.txt" ]; then
                VERSION=$(grep "DISTRIB_DESCRIPTION" "$SCAN_DIR/system/openwrt_release.txt" | cut -d'=' -f2 | tr -d "'\"" || echo "Unknown")
                echo "    \"openwrt_version\": \"$VERSION\"," >> "$INVENTORY_JSON"
            fi
            
            # Count packages
            if [ -f "$SCAN_DIR/system/installed_packages.txt" ]; then
                PKG_COUNT=$(wc -l < "$SCAN_DIR/system/installed_packages.txt")
                echo "    \"package_count\": $PKG_COUNT," >> "$INVENTORY_JSON"
            fi
            
            echo "    \"scan_timestamp\": \"$(date -u +"%Y-%m-%d %H:%M:%S UTC")\"" >> "$INVENTORY_JSON"
            echo "  }" >> "$INVENTORY_JSON"
        fi
    else
        echo -e "${RED}✗ Failed to scan $ROUTER_IP${NC}"
        FAILED_SCANS=$((FAILED_SCANS + 1))
        
        # Add failed entry to JSON
        if [ "$FIRST_ROUTER" = false ]; then
            echo "," >> "$INVENTORY_JSON"
        fi
        FIRST_ROUTER=false
        
        echo "  {" >> "$INVENTORY_JSON"
        echo "    \"hostname\": \"unknown\"," >> "$INVENTORY_JSON"
        echo "    \"ip_address\": \"$ROUTER_IP\"," >> "$INVENTORY_JSON"
        echo "    \"scan_status\": \"failed\"," >> "$INVENTORY_JSON"
        echo "    \"scan_timestamp\": \"$(date -u +"%Y-%m-%d %H:%M:%S UTC")\"" >> "$INVENTORY_JSON"
        echo "  }" >> "$INVENTORY_JSON"
    fi
done < "$ROUTER_LIST"

# Close JSON inventory
echo "]}" >> "$INVENTORY_JSON"

# Update JSON inventory stats
sed -i "s/\"total_routers\": 0/\"total_routers\": $TOTAL_ROUTERS/" "$INVENTORY_JSON"
sed -i "s/\"successful_scans\": 0/\"successful_scans\": $SUCCESSFUL_SCANS/" "$INVENTORY_JSON"
sed -i "s/\"failed_scans\": 0/\"failed_scans\": $FAILED_SCANS/" "$INVENTORY_JSON"

# Generate analysis scripts
echo -e "\n${GREEN}=== Generating Analysis Scripts ===${NC}"

# Create package analysis script
cat > "$OUTPUT_BASE_DIR/analyze_packages.sh" << 'EOF'
#!/bin/bash
# Analyze packages across all routers

OUTPUT_DIR="$1"
if [ -z "$OUTPUT_DIR" ]; then
    echo "Usage: $0 <scan_output_directory>"
    exit 1
fi

echo "Package Analysis Report"
echo "======================"
echo

# Find all package files
PKG_FILES=$(find "$OUTPUT_DIR" -name "installed_packages.txt" -type f 2>/dev/null)

# Create a combined package list with counts
echo "Most Common Packages:"
echo "--------------------"
cat $PKG_FILES 2>/dev/null | grep -v "^$" | cut -d' ' -f1 | sort | uniq -c | sort -rn | head -20

echo -e "\nPackages installed on ALL routers:"
echo "-----------------------------------"
# Find packages common to all routers
if [ -n "$PKG_FILES" ]; then
    ROUTER_COUNT=$(echo "$PKG_FILES" | wc -l)
    cat $PKG_FILES | cut -d' ' -f1 | sort | uniq -c | sort -rn | awk -v count=$ROUTER_COUNT '$1 == count {print $2}'
fi

echo -e "\nUnique packages per router:"
echo "---------------------------"
for pkg_file in $PKG_FILES; do
    ROUTER=$(echo "$pkg_file" | grep -o "[^/]*_[0-9.]*_[0-9]*" | head -1)
    echo -e "\n$ROUTER:"
    # Find packages unique to this router
    cat "$pkg_file" | cut -d' ' -f1 > /tmp/this_router_pkgs_$$
    cat $PKG_FILES | grep -v "$pkg_file" | cut -d' ' -f1 | sort -u > /tmp/other_routers_pkgs_$$
    comm -23 <(sort /tmp/this_router_pkgs_$$) /tmp/other_routers_pkgs_$$ | head -10
done

rm -f /tmp/this_router_pkgs_$$ /tmp/other_routers_pkgs_$$
EOF

chmod +x "$OUTPUT_BASE_DIR/analyze_packages.sh"

# Create network analysis script
cat > "$OUTPUT_BASE_DIR/analyze_networks.sh" << 'EOF'
#!/bin/bash
# Analyze network configurations across all routers

OUTPUT_DIR="$1"
if [ -z "$OUTPUT_DIR" ]; then
    echo "Usage: $0 <scan_output_directory>"
    exit 1
fi

echo "Network Configuration Analysis"
echo "=============================="
echo

# Find all IP address files
IP_FILES=$(find "$OUTPUT_DIR" -name "ip_addresses.txt" -type f 2>/dev/null)

echo "Network Interfaces Summary:"
echo "--------------------------"
for ip_file in $IP_FILES; do
    ROUTER=$(echo "$ip_file" | grep -o "[^/]*_[0-9.]*_[0-9]*" | head -1)
    echo -e "\n$ROUTER:"
    grep "inet " "$ip_file" | awk '{print "  " $2 " on " $NF}' | sort
done

echo -e "\nSubnets in use:"
echo "---------------"
cat $IP_FILES | grep "inet " | awk '{print $2}' | cut -d'/' -f1 | cut -d'.' -f1-3 | sort -u | awk '{print $0 ".0/24"}'

echo -e "\nVLAN Configuration:"
echo "------------------"
find "$OUTPUT_DIR" -name "uci_network.conf" -type f -exec grep -l "vlan" {} \; | while read conf; do
    ROUTER=$(echo "$conf" | grep -o "[^/]*_[0-9.]*_[0-9]*" | head -1)
    echo -e "\n$ROUTER has VLAN configuration"
    grep "vlan" "$conf" | head -5
done
EOF

chmod +x "$OUTPUT_BASE_DIR/analyze_networks.sh"

# Update HTML report
sed -i "s/SCAN_DATE/$(date)/" "$SUMMARY_REPORT"

# Generate final report
echo -e "\n${GREEN}=== Scan Summary ===${NC}"
echo "Total Routers: $TOTAL_ROUTERS"
echo "Successful Scans: $SUCCESSFUL_SCANS"
echo "Failed Scans: $FAILED_SCANS"
echo ""
echo "Output Directory: $OUTPUT_BASE_DIR"
echo "Summary Report: $SUMMARY_REPORT"
echo "JSON Inventory: $INVENTORY_JSON"
echo "Scan Log: $SCAN_LOG"
echo ""
echo "Analysis Scripts:"
echo "  $OUTPUT_BASE_DIR/analyze_packages.sh $OUTPUT_BASE_DIR"
echo "  $OUTPUT_BASE_DIR/analyze_networks.sh $OUTPUT_BASE_DIR"

# Open the HTML report if possible
if command -v xdg-open &> /dev/null; then
    xdg-open "$SUMMARY_REPORT" 2>/dev/null || true
elif command -v open &> /dev/null; then
    open "$SUMMARY_REPORT" 2>/dev/null || true
fi
