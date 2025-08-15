#!/bin/bash

# USB Storage Setup Script for Zephyr Router
# Configures USB drive mounting at /mnt/sda1 with auto-mount on boot

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}USB Storage Setup for Zephyr Router${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Test connectivity to router
echo -e "${YELLOW}Testing connection to Zephyr router...${NC}"
if ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no root@zephyr.router "echo 'Connected'" >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Zephyr router is reachable${NC}"
else
    echo -e "${RED}✗ Cannot reach Zephyr router${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}Step 1: Installing USB Storage Packages${NC}"
echo -e "${YELLOW}This may take a few minutes...${NC}"

ssh -o StrictHostKeyChecking=no root@zephyr.router << 'EOF'
set -e

echo "Updating package lists..."
opkg update

echo ""
echo "Installing USB storage support packages..."
# Core USB storage support
opkg install kmod-usb-storage
opkg install kmod-usb-storage-uas

# Filesystem support
echo "Installing filesystem drivers..."
opkg install kmod-fs-ext4
opkg install kmod-fs-ntfs3
opkg install kmod-fs-vfat
opkg install kmod-fs-exfat

# Block device and partition support
echo "Installing block device utilities..."
opkg install block-mount
opkg install e2fsprogs
opkg install fdisk
opkg install blkid

# Additional utilities
echo "Installing additional utilities..."
opkg install usbutils
opkg install kmod-usb2
opkg install kmod-usb3

echo ""
echo "Packages installed successfully!"
EOF

echo ""
echo -e "${BLUE}Step 2: Detecting USB Drive${NC}"

ssh -o StrictHostKeyChecking=no root@zephyr.router << 'EOF'
set -e

echo "Reloading USB modules..."
modprobe usb-storage 2>/dev/null || true
sleep 3

echo ""
echo "Scanning for USB devices..."
if command -v lsusb >/dev/null 2>&1; then
    lsusb
else
    echo "USB devices in /sys:"
    ls -la /sys/bus/usb/devices/ 2>/dev/null | grep -v "^total" | head -10
fi

echo ""
echo "Checking for block devices..."
ls -la /dev/sd* 2>/dev/null || echo "No /dev/sd* devices found yet"

echo ""
echo "Checking kernel messages for USB storage..."
dmesg | grep -i "usb\|storage\|scsi" | tail -20

echo ""
echo "Running block detect..."
block detect
EOF

echo ""
echo -e "${BLUE}Step 3: Configuring Mount Point${NC}"

ssh -o StrictHostKeyChecking=no root@zephyr.router << 'EOF'
set -e

# Create mount point
echo "Creating mount point /mnt/sda1..."
mkdir -p /mnt/sda1
chmod 755 /mnt/sda1

# Check if device exists
if [ -b /dev/sda1 ]; then
    echo "USB device /dev/sda1 detected!"
    
    # Get filesystem type
    FSTYPE=$(blkid /dev/sda1 -s TYPE -o value 2>/dev/null || echo "unknown")
    echo "Filesystem type: $FSTYPE"
    
    # Try to mount manually first
    echo "Attempting to mount /dev/sda1..."
    umount /dev/sda1 2>/dev/null || true
    
    case "$FSTYPE" in
        ext4)
            mount -t ext4 /dev/sda1 /mnt/sda1
            ;;
        ntfs|ntfs3)
            mount -t ntfs3 /dev/sda1 /mnt/sda1 2>/dev/null || mount -t ntfs /dev/sda1 /mnt/sda1
            ;;
        vfat)
            mount -t vfat /dev/sda1 /mnt/sda1
            ;;
        exfat)
            mount -t exfat /dev/sda1 /mnt/sda1
            ;;
        *)
            mount /dev/sda1 /mnt/sda1
            ;;
    esac
    
    if mount | grep -q "/mnt/sda1"; then
        echo "✓ Successfully mounted /dev/sda1 to /mnt/sda1"
        df -h /mnt/sda1
    else
        echo "✗ Failed to mount /dev/sda1"
    fi
elif [ -b /dev/sda ]; then
    echo "USB device /dev/sda detected but no partition found!"
    echo "You may need to create a partition:"
    echo "  fdisk /dev/sda"
    echo "  mkfs.ext4 /dev/sda1"
else
    echo "No USB storage device detected at /dev/sda*"
    echo "Please ensure the USB drive is properly connected"
fi
EOF

echo ""
echo -e "${BLUE}Step 4: Configuring Auto-Mount${NC}"

ssh -o StrictHostKeyChecking=no root@zephyr.router << 'EOF'
set -e

echo "Generating fstab configuration..."

# Clear any existing USB mount configs
sed -i '/\/mnt\/sda1/d' /etc/config/fstab 2>/dev/null || true

# Generate new config
block detect > /tmp/fstab.new

# Check if USB device was detected
if grep -q "sda1" /tmp/fstab.new; then
    echo "USB device configuration found!"
    
    # Configure the mount
    uci import fstab < /tmp/fstab.new
    
    # Find the section for sda1
    SECTION=$(uci show fstab | grep "device='/dev/sda1'" | cut -d. -f2 | cut -d= -f1)
    
    if [ -n "$SECTION" ]; then
        echo "Configuring mount section: $SECTION"
        uci set fstab.$SECTION.enabled='1'
        uci set fstab.$SECTION.target='/mnt/sda1'
        uci commit fstab
        
        echo "Auto-mount configuration saved!"
        echo ""
        echo "Current fstab configuration:"
        uci show fstab | grep -A5 "sda1"
    else
        echo "Could not find configuration section for sda1"
    fi
else
    echo "No USB device found in block detect output"
    echo "Manual configuration may be needed"
    
    # Try manual configuration if device exists
    if [ -b /dev/sda1 ]; then
        echo "Attempting manual configuration..."
        UUID=$(blkid /dev/sda1 -s UUID -o value 2>/dev/null)
        
        if [ -n "$UUID" ]; then
            uci add fstab mount
            uci set fstab.@mount[-1].uuid="$UUID"
            uci set fstab.@mount[-1].target='/mnt/sda1'
            uci set fstab.@mount[-1].enabled='1'
            uci commit fstab
            echo "Manual configuration added for UUID: $UUID"
        fi
    fi
fi

# Restart block mount service
echo ""
echo "Restarting block mount service..."
/etc/init.d/fstab enable
/etc/init.d/fstab restart

sleep 2

echo ""
echo "Checking mount status..."
if mount | grep -q "/mnt/sda1"; then
    echo "✓ USB drive is mounted at /mnt/sda1"
    df -h /mnt/sda1
else
    echo "✗ USB drive is not mounted"
    echo "You may need to manually mount or reboot the router"
fi
EOF

echo ""
echo -e "${BLUE}Step 5: Creating Test File${NC}"

ssh -o StrictHostKeyChecking=no root@zephyr.router << 'EOF'
if mount | grep -q "/mnt/sda1"; then
    echo "Creating test file on USB drive..."
    echo "Zephyr USB Storage - $(date)" > /mnt/sda1/test.txt
    
    if [ -f /mnt/sda1/test.txt ]; then
        echo "✓ Test file created successfully"
        echo "Contents: $(cat /mnt/sda1/test.txt)"
    else
        echo "✗ Could not create test file"
    fi
    
    echo ""
    echo "USB drive contents:"
    ls -la /mnt/sda1/ | head -10
else
    echo "USB drive not mounted, skipping test file creation"
fi
EOF

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}USB Storage Setup Complete${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${GREEN}Summary:${NC}"
echo "  • USB storage packages installed"
echo "  • Mount point created at /mnt/sda1"
echo "  • Auto-mount configured in /etc/config/fstab"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "  1. If USB is not detected, check physical connection and reboot router"
echo "  2. To manually mount: mount /dev/sda1 /mnt/sda1"
echo "  3. To check status: df -h /mnt/sda1"
echo "  4. To see USB devices: lsusb or ls /dev/sd*"
echo ""
echo -e "${YELLOW}Troubleshooting:${NC}"
echo "  • If drive has no partition: fdisk /dev/sda"
echo "  • If filesystem is corrupted: fsck /dev/sda1"
echo "  • Check logs: logread | grep -i usb"