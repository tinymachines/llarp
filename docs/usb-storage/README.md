# USB Storage Configuration Guide

Complete guide for setting up USB storage on OpenWRT routers, including mounting drives and installing packages to USB when internal storage is limited.

## Overview

OpenWRT routers often have limited internal storage (16-128MB). This guide shows how to:
- Mount USB drives for additional storage
- Install large packages to USB storage
- Configure automatic mounting on boot
- Use USB storage as extended root (extroot)

## Prerequisites

- OpenWRT router with USB port(s)
- USB drive (recommended: USB 3.0 for better performance)
- SSH access to router

## Scripts

### setup-usb-storage-zephyr.sh

Configures USB drive mounting and automatic mount on boot.

**Features:**
- Installs required USB storage drivers
- Supports multiple filesystems (ext4, NTFS, FAT32, exFAT)
- Configures automatic mounting at `/mnt/sda1`
- Creates persistent fstab configuration
- Tests read/write access

**Usage:**
```bash
./setup-usb-storage-zephyr.sh
```

**What it installs:**
- USB storage kernel modules
- Filesystem drivers (ext4, ntfs3, vfat, exfat)
- Block device utilities (fdisk, blkid, e2fsprogs)
- USB utilities (lsusb, usbutils)

### setup-usb-packages-zephyr.sh

Enables package installation to USB storage when internal storage is full.

**Features:**
- Configures opkg for USB installation destination
- Creates wrapper scripts for USB-installed programs
- Sets up library paths for USB packages
- Installs vim-fuller as example

**Usage:**
```bash
./setup-usb-packages-zephyr.sh
```

## Manual Configuration

### 1. Install USB Storage Support

```bash
# Update package lists
opkg update

# Install USB storage kernel modules
opkg install kmod-usb-storage kmod-usb-storage-uas

# Install filesystem support
opkg install kmod-fs-ext4 kmod-fs-ntfs3 kmod-fs-vfat kmod-fs-exfat

# Install utilities
opkg install block-mount e2fsprogs fdisk blkid usbutils
```

### 2. Mount USB Drive

```bash
# Create mount point
mkdir -p /mnt/sda1

# Check if drive is detected
ls -la /dev/sd*

# Mount manually (adjust filesystem type as needed)
mount -t ext4 /dev/sda1 /mnt/sda1

# Verify mount
df -h /mnt/sda1
```

### 3. Configure Auto-Mount

```bash
# Generate fstab configuration
block detect > /tmp/fstab.new

# Import configuration
uci import fstab < /tmp/fstab.new

# Enable auto-mount
uci set fstab.@mount[0].enabled='1'
uci set fstab.@mount[0].target='/mnt/sda1'
uci commit fstab

# Enable and restart service
/etc/init.d/fstab enable
/etc/init.d/fstab restart
```

## Installing Packages to USB

### Configure opkg Destination

```bash
# Add USB destination to opkg.conf
echo "dest usb /mnt/sda1/opkg" >> /etc/opkg.conf

# Create directory structure
mkdir -p /mnt/sda1/opkg/{usr/bin,usr/lib,etc}
```

### Install Package to USB

```bash
# Update package lists
opkg update

# Install to USB destination
opkg install <package-name> --dest usb

# Example: Install vim-fuller
opkg install vim-fuller --dest usb
```

### Create Wrapper Scripts

For USB-installed programs to work properly, create wrapper scripts:

```bash
# Example wrapper for vim
cat > /usr/bin/vim << 'EOF'
#!/bin/sh
export LD_LIBRARY_PATH="/mnt/sda1/opkg/usr/lib:$LD_LIBRARY_PATH"
exec /mnt/sda1/opkg/usr/bin/vim "$@"
EOF

chmod +x /usr/bin/vim
```

## USB Drive Preparation

### Format USB Drive (if needed)

```bash
# WARNING: This will erase all data on the drive!

# Partition the drive
fdisk /dev/sda
# Press: n (new partition)
# Press: p (primary)
# Press: 1 (partition number)
# Press: Enter (default first sector)
# Press: Enter (default last sector)
# Press: w (write and exit)

# Format as ext4
mkfs.ext4 /dev/sda1

# Mount the drive
mount /dev/sda1 /mnt/sda1
```

### Recommended Filesystems

| Filesystem | Pros | Cons | Use Case |
|------------|------|------|----------|
| **ext4** | Native Linux, best performance | Not readable on Windows | Best for Linux-only use |
| **NTFS** | Windows compatible | Slower on Linux | Dual-boot or Windows sharing |
| **FAT32** | Universal compatibility | 4GB file size limit | Small files, compatibility |
| **exFAT** | No file size limit, compatible | Requires extra driver | Large files, cross-platform |

## Troubleshooting

### USB Drive Not Detected

1. **Check physical connection:**
   ```bash
   # Check kernel messages
   dmesg | grep -i usb | tail -20
   ```

2. **Check USB devices:**
   ```bash
   lsusb
   ```

3. **Load USB modules manually:**
   ```bash
   modprobe usb-storage
   sleep 3
   ls -la /dev/sd*
   ```

### Mount Fails

1. **Check filesystem:**
   ```bash
   blkid /dev/sda1
   ```

2. **Try different filesystem type:**
   ```bash
   # For NTFS
   mount -t ntfs3 /dev/sda1 /mnt/sda1
   
   # For FAT32
   mount -t vfat /dev/sda1 /mnt/sda1
   ```

3. **Check for errors:**
   ```bash
   # For ext4
   fsck.ext4 /dev/sda1
   ```

### Package Installation Fails

1. **Check USB space:**
   ```bash
   df -h /mnt/sda1
   ```

2. **Verify opkg configuration:**
   ```bash
   grep "dest usb" /etc/opkg.conf
   ```

3. **Install with verbose output:**
   ```bash
   opkg install <package> --dest usb -V2
   ```

### Library Errors

If USB-installed programs fail with library errors:

1. **Set library path:**
   ```bash
   export LD_LIBRARY_PATH="/mnt/sda1/opkg/usr/lib:$LD_LIBRARY_PATH"
   ```

2. **Check library dependencies:**
   ```bash
   ldd /mnt/sda1/opkg/usr/bin/<program>
   ```

3. **Install missing libraries:**
   ```bash
   opkg install <library-package> --dest usb
   ```

## Advanced Configuration

### Full Extroot Setup

To use USB as extended root (entire overlay on USB):

```bash
# WARNING: This is advanced - backup first!

# Copy current overlay to USB
mount /dev/sda1 /mnt/sda1
cp -a /overlay/* /mnt/sda1/

# Configure as extroot
block detect > /etc/config/fstab
uci set fstab.@mount[0].target='/overlay'
uci set fstab.@mount[0].enabled='1'
uci commit fstab

# Reboot
reboot
```

### USB Hub Support

For multiple USB devices:

```bash
# Install USB hub support
opkg install kmod-usb2 kmod-usb-ohci kmod-usb-uhci
```

### USB 3.0 Performance

Enable USB 3.0 for better performance:

```bash
# Install USB 3.0 support
opkg install kmod-usb3

# Check USB speed
lsusb -t
```

## Storage Management

### Monitor Disk Usage

```bash
# Check all mounted filesystems
df -h

# Check specific directory usage
du -sh /mnt/sda1/*

# Monitor in real-time
watch -n 1 df -h /mnt/sda1
```

### Clean Package Cache

```bash
# Clear opkg cache
rm -rf /mnt/sda1/opkg/var/cache/*

# Remove orphaned packages
opkg remove --autoremove
```

### Backup USB Configuration

```bash
# Backup fstab configuration
uci export fstab > /etc/fstab.backup

# Backup package list
opkg list-installed --dest usb > /mnt/sda1/packages.list
```

## Best Practices

1. **Use ext4 for best performance** on Linux-only systems
2. **Create regular backups** of USB configuration
3. **Monitor disk space** regularly
4. **Use USB 3.0** drives for better performance
5. **Test configuration** after router reboots
6. **Document installed packages** for recovery

## Performance Tips

- Use USB 3.0 drives when possible
- Format with ext4 for best performance
- Avoid NTFS if not needed for Windows compatibility
- Use `noatime` mount option to reduce writes
- Consider SSD-based USB drives for heavy use

## Related Documentation

- [OpenWRT USB Storage Documentation](https://openwrt.org/docs/guide-user/storage/usb-drives)
- [Extroot Configuration](https://openwrt.org/docs/guide-user/additional-software/extroot_configuration)
- [opkg Package Manager](https://openwrt.org/docs/guide-user/additional-software/opkg)