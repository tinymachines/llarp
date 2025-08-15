#!/bin/bash

# USB Package Installation Setup for Zephyr Router
# Enables installing packages to USB storage when main storage is full

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}USB Package Installation Setup${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Test connectivity to router
echo -e "${YELLOW}Testing connection to Zephyr router...${NC}"
if ! ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no root@zephyr.router "echo 'Connected'" >/dev/null 2>&1; then
    echo -e "${RED}✗ Cannot reach Zephyr router${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Connected to Zephyr${NC}"

echo ""
echo -e "${BLUE}Step 1: Checking USB Mount Status${NC}"

USB_STATUS=$(ssh -o StrictHostKeyChecking=no root@zephyr.router "mount | grep '/mnt/sda1' && echo 'MOUNTED' || echo 'NOT_MOUNTED'")
if [[ "$USB_STATUS" != *"MOUNTED"* ]]; then
    echo -e "${RED}✗ USB drive not mounted at /mnt/sda1${NC}"
    echo "Please run ./setup-usb-storage-zephyr.sh first"
    exit 1
fi
echo -e "${GREEN}✓ USB drive is mounted${NC}"

echo ""
echo -e "${BLUE}Step 2: Setting up USB Package Directory Structure${NC}"

ssh -o StrictHostKeyChecking=no root@zephyr.router << 'EOF'
set -e

echo "Creating package directories on USB..."
mkdir -p /mnt/sda1/opkg/{bin,sbin,lib,usr/bin,usr/sbin,usr/lib,etc,opt}
mkdir -p /mnt/sda1/opkg/var/lock

echo "Setting permissions..."
chmod -R 755 /mnt/sda1/opkg

echo "Directory structure created"
ls -la /mnt/sda1/opkg/
EOF

echo ""
echo -e "${BLUE}Step 3: Configuring opkg for USB Installation${NC}"

ssh -o StrictHostKeyChecking=no root@zephyr.router << 'EOF'
set -e

echo "Backing up original opkg.conf..."
cp /etc/opkg.conf /etc/opkg.conf.backup 2>/dev/null || true

echo "Creating USB destination configuration..."
cat > /etc/opkg.conf.d/usb.conf << 'EOCONF'
# USB Storage destination for large packages
dest usb /mnt/sda1/opkg
# Increase cache size for USB installations
option cache_dir /mnt/sda1/opkg/var/cache
option lists_dir /mnt/sda1/opkg/var/lists
EOCONF

echo "Configuration saved to /etc/opkg.conf.d/usb.conf"
cat /etc/opkg.conf.d/usb.conf
EOF

echo ""
echo -e "${BLUE}Step 4: Setting up PATH and Library Paths${NC}"

ssh -o StrictHostKeyChecking=no root@zephyr.router << 'EOF'
set -e

echo "Creating profile script for USB paths..."
cat > /etc/profile.d/usb-packages.sh << 'EOPROFILE'
# USB Package paths
export PATH="/mnt/sda1/opkg/usr/bin:/mnt/sda1/opkg/usr/sbin:/mnt/sda1/opkg/bin:/mnt/sda1/opkg/sbin:$PATH"
export LD_LIBRARY_PATH="/mnt/sda1/opkg/lib:/mnt/sda1/opkg/usr/lib:$LD_LIBRARY_PATH"
EOPROFILE

chmod +x /etc/profile.d/usb-packages.sh

echo "Updating current shell environment..."
source /etc/profile.d/usb-packages.sh

echo "PATH updated:"
echo $PATH | tr ':' '\n' | grep sda1 || echo "USB paths will be active on next login"
EOF

echo ""
echo -e "${BLUE}Step 5: Creating Symlink Helper Script${NC}"

ssh -o StrictHostKeyChecking=no root@zephyr.router << 'EOF'
set -e

cat > /mnt/sda1/opkg/link-usb-package.sh << 'EOSCRIPT'
#!/bin/sh
# Helper script to create symlinks for USB-installed packages

PACKAGE=$1
if [ -z "$PACKAGE" ]; then
    echo "Usage: $0 <package-name>"
    exit 1
fi

echo "Creating symlinks for $PACKAGE..."

# Link binaries
for bin in /mnt/sda1/opkg/usr/bin/*; do
    if [ -f "$bin" ]; then
        name=$(basename "$bin")
        ln -sf "$bin" "/usr/bin/$name" 2>/dev/null && echo "  Linked /usr/bin/$name"
    fi
done

for sbin in /mnt/sda1/opkg/usr/sbin/*; do
    if [ -f "$sbin" ]; then
        name=$(basename "$sbin")
        ln -sf "$sbin" "/usr/sbin/$name" 2>/dev/null && echo "  Linked /usr/sbin/$name"
    fi
done

# Link libraries if needed
for lib in /mnt/sda1/opkg/usr/lib/*.so*; do
    if [ -f "$lib" ]; then
        name=$(basename "$lib")
        ln -sf "$lib" "/usr/lib/$name" 2>/dev/null && echo "  Linked /usr/lib/$name"
    fi
done

echo "Symlinks created successfully"
EOSCRIPT

chmod +x /mnt/sda1/opkg/link-usb-package.sh
echo "Helper script created at /mnt/sda1/opkg/link-usb-package.sh"
EOF

echo ""
echo -e "${BLUE}Step 6: Installing vim-fuller to USB${NC}"

ssh -o StrictHostKeyChecking=no root@zephyr.router << 'EOF'
set -e

echo "Updating package lists..."
opkg update

echo ""
echo "Installing vim-fuller to USB storage..."
opkg install vim-fuller --dest usb --nodeps 2>/dev/null || {
    echo "Initial install attempt failed, trying with dependencies..."
    
    # Install dependencies first
    echo "Installing ncurses to USB..."
    opkg install libncurses6 --dest usb 2>/dev/null || true
    
    echo "Installing vim-fuller..."
    opkg install vim-fuller --dest usb || {
        echo "Installation failed. Trying alternative method..."
        
        # Download and extract manually
        cd /tmp
        opkg download vim-fuller
        
        if [ -f vim-fuller*.ipk ]; then
            echo "Extracting package manually..."
            tar -xzf vim-fuller*.ipk
            tar -xzf data.tar.gz -C /mnt/sda1/opkg/
            rm -f vim-fuller*.ipk control.tar.gz data.tar.gz debian-binary
            echo "Manual extraction complete"
        fi
    }
}

# Create symlinks for vim
echo ""
echo "Creating symlinks for vim..."
if [ -f /mnt/sda1/opkg/usr/bin/vim ]; then
    ln -sf /mnt/sda1/opkg/usr/bin/vim /usr/bin/vim
    ln -sf /mnt/sda1/opkg/usr/bin/vim /usr/bin/vi
    echo "✓ Vim symlinks created"
else
    # Check alternative locations
    find /mnt/sda1/opkg -name "vim" -type f 2>/dev/null | while read vim_path; do
        echo "Found vim at: $vim_path"
        ln -sf "$vim_path" /usr/bin/vim
        ln -sf "$vim_path" /usr/bin/vi
        break
    done
fi

# Verify installation
echo ""
echo "Verifying installation..."
if command -v vim >/dev/null 2>&1 || [ -f /mnt/sda1/opkg/usr/bin/vim ]; then
    echo "✓ vim-fuller installed successfully"
    echo "Location: $(which vim 2>/dev/null || echo '/mnt/sda1/opkg/usr/bin/vim')"
else
    echo "✗ vim-fuller installation needs manual verification"
fi
EOF

echo ""
echo -e "${BLUE}Step 7: Creating Permanent Solution${NC}"

ssh -o StrictHostKeyChecking=no root@zephyr.router << 'EOF'
set -e

# Create startup script to ensure paths are set
cat > /etc/init.d/usb-packages << 'EOINIT'
#!/bin/sh /etc/rc.common

START=99
STOP=01

start() {
    if [ -d /mnt/sda1/opkg ]; then
        # Ensure USB binaries are in PATH
        export PATH="/mnt/sda1/opkg/usr/bin:/mnt/sda1/opkg/usr/sbin:$PATH"
        
        # Create/update symlinks for commonly used programs
        for prog in vim vi nano htop tmux; do
            src="/mnt/sda1/opkg/usr/bin/$prog"
            if [ -f "$src" ]; then
                ln -sf "$src" "/usr/bin/$prog" 2>/dev/null
            fi
        done
        
        echo "USB packages initialized"
    fi
}

stop() {
    # Remove symlinks on stop if needed
    echo "USB packages cleanup"
}
EOINIT

chmod +x /etc/init.d/usb-packages
/etc/init.d/usb-packages enable
/etc/init.d/usb-packages start

echo "Startup script created and enabled"
EOF

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Setup Complete!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${GREEN}USB package installation is now configured.${NC}"
echo ""
echo -e "${YELLOW}Usage Instructions:${NC}"
echo "  • Install to USB: opkg install <package> --dest usb"
echo "  • List USB packages: opkg list-installed --dest usb"
echo "  • Remove from USB: opkg remove <package> --dest usb"
echo ""
echo -e "${YELLOW}Testing vim:${NC}"
ssh -o StrictHostKeyChecking=no root@zephyr.router "vim --version 2>/dev/null | head -1 || echo 'Run: /mnt/sda1/opkg/usr/bin/vim'"
echo ""
echo -e "${YELLOW}Note:${NC} You may need to logout and login again for PATH changes to take effect."
echo "Or run: source /etc/profile.d/usb-packages.sh"