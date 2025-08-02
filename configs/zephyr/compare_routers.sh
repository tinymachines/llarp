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
