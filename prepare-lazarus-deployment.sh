#!/bin/bash

# Prepare Lazarus OpenVPN deployment package
# This creates a ready-to-deploy package for the Lazarus router

set -euo pipefail

DEPLOY_DIR="lazarus-openvpn-deploy"
RESOURCES_DIR="./resources/openvpn"

echo "Creating Lazarus OpenVPN deployment package..."

# Create deployment directory
rm -rf "$DEPLOY_DIR"
mkdir -p "$DEPLOY_DIR/profiles"

# Copy VPN profiles and credentials
echo "Copying VPN profiles..."
cp "$RESOURCES_DIR"/*.ovpn "$DEPLOY_DIR/profiles/"
cp "$RESOURCES_DIR"/pass.txt "$DEPLOY_DIR/"

# Copy setup script
echo "Copying setup script..."
cp lazarus-openvpn-setup.sh "$DEPLOY_DIR/"
chmod +x "$DEPLOY_DIR/lazarus-openvpn-setup.sh"

# Create profile selector script
echo "Creating profile selector..."
cat > "$DEPLOY_DIR/select-random-profile.sh" << 'EOF'
#!/bin/sh

PROFILES_DIR="/etc/openvpn/profiles"
DEFAULT_PROFILE_FILE="/etc/config/openvpn_default_profile"
ACTIVE_PROFILE="/etc/openvpn/client.conf"

select_random_profile() {
    profiles=$(ls $PROFILES_DIR/*.ovpn 2>/dev/null)
    count=$(echo "$profiles" | wc -w)

    if [ "$count" -eq 0 ]; then
        echo "No VPN profiles found!"
        exit 1
    fi

    random_num=$(awk 'BEGIN{srand();print int(rand()*'$count')+1}')
    selected=$(echo "$profiles" | tr ' ' '\n' | sed -n "${random_num}p")

    echo "$selected"
}

select_default_profile() {
    if [ -f "$DEFAULT_PROFILE_FILE" ]; then
        default_name=$(cat "$DEFAULT_PROFILE_FILE")
        default_path="$PROFILES_DIR/$default_name"

        if [ -f "$default_path" ]; then
            echo "$default_path"
            return 0
        fi
    fi
    return 1
}

if select_default_profile; then
    SELECTED_PROFILE=$(select_default_profile)
    echo "Using default profile: $(basename $SELECTED_PROFILE)"
else
    SELECTED_PROFILE=$(select_random_profile)
    echo "Selected random profile: $(basename $SELECTED_PROFILE)"
fi

cp "$SELECTED_PROFILE" "$ACTIVE_PROFILE"

if ! grep -q "auth-user-pass" "$ACTIVE_PROFILE"; then
    echo "auth-user-pass /etc/openvpn/auth.txt" >> "$ACTIVE_PROFILE"
else
    sed -i 's|^auth-user-pass.*|auth-user-pass /etc/openvpn/auth.txt|' "$ACTIVE_PROFILE"
fi

echo "$(date '+%Y-%m-%d %H:%M:%S') - Selected: $(basename $SELECTED_PROFILE)" >> /var/log/openvpn-profile.log

exit 0
EOF

chmod +x "$DEPLOY_DIR/select-random-profile.sh"

# Create init script
echo "Creating init script..."
cat > "$DEPLOY_DIR/openvpn-random" << 'EOF'
#!/bin/sh /etc/rc.common

START=90
STOP=10

USE_PROCD=1
PROG=/usr/sbin/openvpn

start_service() {
    /etc/openvpn/select-random-profile.sh

    procd_open_instance
    procd_set_param command $PROG --config /etc/openvpn/client.conf
    procd_set_param file /etc/openvpn/client.conf
    procd_set_param respawn
    procd_close_instance
}

stop_service() {
    killall openvpn 2>/dev/null
}

reload_service() {
    stop
    start
}
EOF

chmod +x "$DEPLOY_DIR/openvpn-random"

# Create quick install script
echo "Creating quick install script..."
cat > "$DEPLOY_DIR/quick-install.sh" << 'EOF'
#!/bin/sh

echo "Lazarus OpenVPN Quick Install"
echo "============================="

# Install OpenVPN
echo "Installing OpenVPN..."
opkg update
opkg install openvpn-openssl

# Create directories
echo "Setting up directories..."
mkdir -p /etc/openvpn/profiles

# Copy files
echo "Copying files..."
cp profiles/*.ovpn /etc/openvpn/profiles/
cp pass.txt /etc/openvpn/auth.txt
cp select-random-profile.sh /etc/openvpn/
cp openvpn-random /etc/init.d/

# Set permissions
chmod 600 /etc/openvpn/auth.txt
chmod 755 /etc/openvpn/select-random-profile.sh
chmod 755 /etc/init.d/openvpn-random

# Configure firewall
echo "Configuring firewall..."
cat >> /etc/config/firewall << 'FIREWALL'

config zone
    option name 'vpn'
    option input 'REJECT'
    option output 'ACCEPT'
    option forward 'REJECT'
    option masq '1'
    option mtu_fix '1'
    list device 'tun0'

config forwarding
    option src 'lan'
    option dest 'vpn'
FIREWALL

/etc/init.d/firewall reload

# Enable and start
echo "Starting OpenVPN service..."
/etc/init.d/openvpn-random enable
/etc/init.d/openvpn-random start

echo "Installation complete!"
echo "Check status with: ifconfig tun0"
EOF

chmod +x "$DEPLOY_DIR/quick-install.sh"

# Create deployment instructions
cat > "$DEPLOY_DIR/README.md" << 'EOF'
# Lazarus OpenVPN Deployment

## Quick Deploy

1. Copy this entire directory to Lazarus router:
   ```bash
   scp -r lazarus-openvpn-deploy root@17.0.0.1:/tmp/
   ```

2. SSH to Lazarus and run:
   ```bash
   ssh root@17.0.0.1
   cd /tmp/lazarus-openvpn-deploy
   ./quick-install.sh
   ```

3. Verify connection:
   ```bash
   ifconfig tun0
   wget -qO- http://ipinfo.io/ip
   ```

## Files Included

- `profiles/` - ProtonVPN configuration files
- `pass.txt` - Authentication credentials
- `select-random-profile.sh` - Random profile selector
- `openvpn-random` - Init script
- `quick-install.sh` - Automated installer
- `lazarus-openvpn-setup.sh` - Full setup script with logging

## Management Commands

- Restart with new profile: `/etc/init.d/openvpn-random restart`
- Set default profile: `echo "us-ca-05.protonvpn.udp.ovpn" > /etc/config/openvpn_default_profile`
- Use random selection: `rm /etc/config/openvpn_default_profile`
- Check current profile: `tail -1 /var/log/openvpn-profile.log`
EOF

# Create tarball
echo "Creating deployment archive..."
tar czf lazarus-openvpn-deploy.tar.gz "$DEPLOY_DIR"

echo ""
echo "Deployment package created: lazarus-openvpn-deploy.tar.gz"
echo ""
echo "To deploy to Lazarus:"
echo "  1. scp lazarus-openvpn-deploy.tar.gz root@17.0.0.1:/tmp/"
echo "  2. ssh root@17.0.0.1"
echo "  3. cd /tmp && tar xzf lazarus-openvpn-deploy.tar.gz"
echo "  4. cd lazarus-openvpn-deploy && ./quick-install.sh"
echo ""
echo "Ground truth document: LAZARUS_OPENVPN_GROUND_TRUTH.md"