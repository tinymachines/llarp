# Backup and restore

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

## Introduction

- This how-to describes the method for using OpenWrt file-level backup/restore.
- Follow [Preserving packages](/docs/guide-user/installation/sysupgrade.packages "docs:guide-user:installation:sysupgrade.packages") to back up user-removed/installed packages.
- Follow [Preserving configuration](/docs/guide-quick-start/admingui_sysupgrade_keepsettings "docs:guide-quick-start:admingui_sysupgrade_keepsettings") to determine whether to keep the settings.
- Follow [Generic backup](/docs/guide-user/installation/generic.backup "docs:guide-user:installation:generic.backup") for block-level backup/restore.
- Extroot or additional overlay setups require extra measures.

## Goals

- Back up and restore OpenWrt configuration.

## Web interface instructions

### 1. Customize and verify

Customize your backup configuration.

1. Navigate to **LuCI → System → Backup / Flash Firmware → Configuration**.
2. Add/remove files/directories and click **Submit** when done editing.
3. Click **Open list...** button to view the list of files for backup.

Make sure the list contains all the files you want to save.

### 2. Back up

Back up OpenWrt configuration to local PC.

1. Navigate to **LuCI → System → Backup / Flash Firmware → Actions: Backup**.
2. Click **Generate archive** button to download the archive.

### 3. Restore

Restore previously saved OpenWrt configuration from local PC.

1. Navigate to **LuCI → System → Backup / Flash Firmware → Actions: Restore**.
2. Click **Choose File** button to select the archive.
3. Click **Upload archive...** button to upload the archive.

## Command-line instructions

OpenWrt provides [Sysupgrade](/docs/techref/sysupgrade "docs:techref:sysupgrade") utility for file-level backup/restore.

### 1. Customize and verify

Customize and verify your backup configuration.

```
# Add files/directories
cat << EOF >> /etc/sysupgrade.conf
/etc/sudoers
/etc/sudoers.d
EOF
 
# Edit backup configuration
vi /etc/sysupgrade.conf
 
# Verify backup configuration
sysupgrade -l
```

### 2. Back up

Back up OpenWrt configuration to local PC.

```
# Generate backup
umask go=
sysupgrade -b /tmp/backup-${HOSTNAME}-$(date +%F).tar.gz
ls /tmp/backup-*.tar.gz
 
# From the client, download backup 
scp root@openwrt.lan:/tmp/backup-*.tar.gz .
# On recent clients, it may be necessary to use the -O flag for compatibility reasons
scp -O root@openwrt.lan:/tmp/backup-*.tar.gz .
```

### 3. Restore

Restore previously saved OpenWrt configuration from local PC. Reboot to apply changes.

```
# Upload backup
scp backup-*.tar.gz root@openwrt.lan:/tmp
 
# Restore backup
ls /tmp/backup-*.tar.gz
sysupgrade -r /tmp/backup-*.tar.gz
reboot
```

## Extras

### Configuration

Backup combines multiple sources and covers most configurations by default.

```
# Automatically detected modifications
opkg list-changed-conffiles
 
# System configurations supplied by individual packages
grep -r -e . /lib/upgrade/keep.d
 
# User configuration to edit if necessary
grep -e . /etc/sysupgrade.conf
 
# Obsolete settings no longer supported
uci show luci.flash_keep
```
