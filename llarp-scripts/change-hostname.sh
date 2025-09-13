#!/bin/bash
# LLARP Script Lego: Change Router Hostname
# Created: $(date)
# Success: This script successfully changed hostname from "Zephyr" to "LLARP"

ROUTER_IP="$1"
NEW_HOSTNAME="$2"

if [[ -z "$ROUTER_IP" || -z "$NEW_HOSTNAME" ]]; then
    echo "Usage: $0 <router_ip> <new_hostname>"
    echo "Example: $0 15.0.0.1 LLARP"
    exit 1
fi

SSH_OPTS="-o ConnectTimeout=10 -o StrictHostKeyChecking=no"

echo "🏷️  CHANGING HOSTNAME to $NEW_HOSTNAME on $ROUTER_IP"
echo "================================================="

ssh $SSH_OPTS root@$ROUTER_IP "
echo 'Current hostname:'
uci get system.@system[0].hostname

echo 'Setting new hostname: $NEW_HOSTNAME'
uci set system.@system[0].hostname='$NEW_HOSTNAME'
uci commit system

echo 'New hostname:'
uci get system.@system[0].hostname

echo 'Hostname change complete!'
"

echo ""
echo "✅ HOSTNAME CHANGE COMPLETE"
echo "📋 New hostname: $NEW_HOSTNAME"