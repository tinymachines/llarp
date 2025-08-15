# Troubleshooting Guide

Common issues and solutions for OpenWRT configuration management, network routing, and USB storage.

## Table of Contents

- [Connection Issues](#connection-issues)
- [Network Routing Problems](#network-routing-problems)
- [USB Storage Issues](#usb-storage-issues)
- [Package Installation Problems](#package-installation-problems)
- [Script Execution Errors](#script-execution-errors)
- [Recovery Procedures](#recovery-procedures)

## Connection Issues

### Cannot SSH to Router

**Symptoms:**
- `Connection refused` or `Connection timeout`
- Scripts fail with "Cannot reach router"

**Solutions:**

1. **Verify network connectivity:**
   ```bash
   ping <router-ip>
   ```

2. **Check SSH service:**
   ```bash
   # From router console
   /etc/init.d/dropbear status
   /etc/init.d/dropbear restart
   ```

3. **Check firewall rules:**
   ```bash
   # Temporarily disable firewall
   /etc/init.d/firewall stop
   # Test SSH
   # Re-enable firewall
   /etc/init.d/firewall start
   ```

4. **Reset SSH keys:**
   ```bash
   ssh-keygen -R <router-ip>
   ssh-copy-id root@<router-ip>
   ```

### DNS Resolution Failures

**Symptoms:**
- Cannot resolve hostnames
- `nslookup` fails

**Solutions:**

1. **Check DNS configuration:**
   ```bash
   cat /etc/resolv.conf
   ```

2. **Set DNS servers manually:**
   ```bash
   uci set network.wan.dns='8.8.8.8 1.1.1.1'
   uci commit network
   /etc/init.d/network restart
   ```

3. **Test with specific DNS:**
   ```bash
   nslookup google.com 8.8.8.8
   ```

## Network Routing Problems

### Routes Not Working

**Symptoms:**
- Cannot reach other network segments
- Ping fails between routers

**Solutions:**

1. **Verify routes are active:**
   ```bash
   ip route show
   ```

2. **Check gateway reachability:**
   ```bash
   ping -c 2 <gateway-ip>
   ```

3. **Add route manually (temporary):**
   ```bash
   ip route add 192.168.1.0/24 via 10.0.0.1 dev wan
   ```

4. **Make route persistent:**
   ```bash
   uci set network.route_name=route
   uci set network.route_name.target='192.168.1.0/24'
   uci set network.route_name.gateway='10.0.0.1'
   uci set network.route_name.interface='wan'
   uci commit network
   /etc/init.d/network restart
   ```

### Firewall Blocking Traffic

**Symptoms:**
- Routes exist but traffic blocked
- Can ping gateway but not beyond

**Solutions:**

1. **Check firewall logs:**
   ```bash
   logread | grep -i "drop\|reject"
   ```

2. **Add firewall exception:**
   ```bash
   # Allow specific network
   uci add firewall rule
   uci set firewall.@rule[-1].name='Allow-Network'
   uci set firewall.@rule[-1].src='wan'
   uci set firewall.@rule[-1].src_ip='192.168.1.0/24'
   uci set firewall.@rule[-1].dest='lan'
   uci set firewall.@rule[-1].target='ACCEPT'
   uci commit firewall
   /etc/init.d/firewall restart
   ```

3. **Enable forwarding between zones:**
   ```bash
   uci set firewall.@forwarding[0]=forwarding
   uci set firewall.@forwarding[0].src='lan'
   uci set firewall.@forwarding[0].dest='wan'
   uci commit firewall
   ```

## USB Storage Issues

### USB Drive Not Detected

**Symptoms:**
- No `/dev/sda*` devices
- `lsusb` doesn't show drive

**Solutions:**

1. **Check kernel messages:**
   ```bash
   dmesg | grep -i "usb\|storage" | tail -20
   ```

2. **Load USB modules:**
   ```bash
   modprobe usb-storage
   modprobe kmod-usb-storage-uas
   sleep 5
   ls -la /dev/sd*
   ```

3. **Check USB power:**
   - Try different USB port
   - Use powered USB hub for high-power drives
   - Check cable connections

4. **Reinstall USB packages:**
   ```bash
   opkg update
   opkg install --force-reinstall kmod-usb-storage
   ```

### Mount Fails

**Symptoms:**
- `mount: mounting /dev/sda1 on /mnt/sda1 failed`
- `wrong fs type, bad option, bad superblock`

**Solutions:**

1. **Identify filesystem:**
   ```bash
   blkid /dev/sda1
   ```

2. **Install correct filesystem driver:**
   ```bash
   # For NTFS
   opkg install kmod-fs-ntfs3
   
   # For exFAT
   opkg install kmod-fs-exfat
   ```

3. **Try manual mount with type:**
   ```bash
   mount -t ntfs3 /dev/sda1 /mnt/sda1
   mount -t ext4 /dev/sda1 /mnt/sda1
   ```

4. **Check filesystem for errors:**
   ```bash
   # For ext4
   fsck.ext4 -f /dev/sda1
   
   # For FAT32
   fsck.vfat /dev/sda1
   ```

### Auto-Mount Not Working

**Symptoms:**
- USB unmounted after reboot
- fstab configuration ignored

**Solutions:**

1. **Check fstab configuration:**
   ```bash
   uci show fstab
   block info
   ```

2. **Regenerate fstab:**
   ```bash
   block detect > /tmp/fstab.new
   uci import fstab < /tmp/fstab.new
   uci set fstab.@mount[0].enabled='1'
   uci commit fstab
   ```

3. **Enable block-mount service:**
   ```bash
   /etc/init.d/fstab enable
   /etc/init.d/fstab start
   ```

## Package Installation Problems

### Out of Space Errors

**Symptoms:**
- `No space left on device`
- `verify_pkg_installable: Only have XXkb available`

**Solutions:**

1. **Check available space:**
   ```bash
   df -h /
   ```

2. **Clean package cache:**
   ```bash
   rm -rf /tmp/opkg-lists/*
   ```

3. **Install to USB:**
   ```bash
   # Configure USB destination
   echo "dest usb /mnt/sda1/opkg" >> /etc/opkg.conf
   
   # Install package
   opkg install <package> --dest usb
   ```

4. **Remove unnecessary packages:**
   ```bash
   opkg list-installed | grep -v "^kernel\|^kmod"
   opkg remove <unnecessary-package>
   ```

### Library Errors for USB Packages

**Symptoms:**
- `error while loading shared libraries`
- Program installed but won't run

**Solutions:**

1. **Set library path:**
   ```bash
   export LD_LIBRARY_PATH="/mnt/sda1/opkg/usr/lib:$LD_LIBRARY_PATH"
   ```

2. **Create wrapper script:**
   ```bash
   cat > /usr/bin/program-name << 'EOF'
   #!/bin/sh
   export LD_LIBRARY_PATH="/mnt/sda1/opkg/usr/lib:$LD_LIBRARY_PATH"
   exec /mnt/sda1/opkg/usr/bin/program-name "$@"
   EOF
   chmod +x /usr/bin/program-name
   ```

3. **Install missing libraries:**
   ```bash
   ldd /mnt/sda1/opkg/usr/bin/program-name
   opkg install missing-library --dest usb
   ```

## Script Execution Errors

### Permission Denied

**Solutions:**

1. **Make script executable:**
   ```bash
   chmod +x script-name.sh
   ```

2. **Check script ownership:**
   ```bash
   ls -la script-name.sh
   chown user:group script-name.sh
   ```

### Command Not Found

**Solutions:**

1. **Use full paths in scripts:**
   ```bash
   /usr/bin/ssh instead of ssh
   /bin/ping instead of ping
   ```

2. **Check PATH variable:**
   ```bash
   echo $PATH
   export PATH="/usr/bin:/bin:/sbin:/usr/sbin:$PATH"
   ```

## Recovery Procedures

### Reset to Defaults

**Safe Mode Boot:**
1. Power off router
2. Hold reset button
3. Power on while holding reset
4. Release after 10 seconds
5. Router boots in failsafe mode

**Access Failsafe Mode:**
```bash
# Router IP in failsafe: 192.168.1.1
telnet 192.168.1.1
# or
ssh root@192.168.1.1
```

### Restore Configuration

**From Backup:**
```bash
# Copy backup to router
scp backup.tar.gz root@router-ip:/tmp/

# Extract on router
cd /
tar -xzf /tmp/backup.tar.gz

# Restart services
/etc/init.d/network restart
/etc/init.d/firewall restart
```

### Fix Broken Package System

```bash
# Clear package lists
rm -rf /var/opkg-lists/*

# Update package database
opkg update

# Fix broken dependencies
opkg install --force-depends <package>

# Remove and reinstall problematic package
opkg remove --force-remove <package>
opkg install <package>
```

### Emergency Network Access

If locked out of network:

1. **Connect via serial console** (if available)
2. **Use failsafe mode** (IP: 192.168.1.1)
3. **Direct ethernet connection** to LAN port
4. **Reset network configuration:**
   ```bash
   # In failsafe mode
   firstboot -y
   reboot
   ```

## Diagnostic Commands

### System Information
```bash
# System version
cat /etc/openwrt_release

# Kernel version
uname -a

# Memory usage
free -h

# Disk usage
df -h

# Process list
ps | head -20
```

### Network Diagnostics
```bash
# Interface status
ip addr show

# Route table
ip route show

# ARP table
ip neigh show

# Connection tracking
conntrack -L

# Firewall rules
iptables -L -n -v
```

### USB Diagnostics
```bash
# USB devices
lsusb -t

# Block devices
lsblk

# Mounted filesystems
mount | grep sd

# USB kernel messages
dmesg | grep -i usb | tail -20
```

## Getting Help

### Log Files
- System log: `logread` or `/var/log/messages`
- Kernel log: `dmesg`
- Package log: `opkg info <package>`

### Debug Mode
Run scripts with debug output:
```bash
bash -x script-name.sh
```

### Community Resources
- [OpenWRT Forum](https://forum.openwrt.org/)
- [OpenWRT Documentation](https://openwrt.org/docs/start)
- [GitHub Issues](https://github.com/yourusername/openwrt-toolkit/issues)

## Prevention Tips

1. **Always backup before changes:**
   ```bash
   ./openwrt-config-scan.sh router-ip
   ```

2. **Test in dry-run mode when available:**
   ```bash
   ./script-name.sh --dry-run
   ```

3. **Monitor system resources:**
   ```bash
   # Watch disk space
   watch -n 60 df -h
   
   # Monitor memory
   watch -n 60 free -h
   ```

4. **Keep documentation updated:**
   - Document network topology
   - Track configuration changes
   - Note custom modifications

5. **Regular maintenance:**
   - Update packages regularly
   - Clean package cache
   - Check log sizes
   - Verify backups