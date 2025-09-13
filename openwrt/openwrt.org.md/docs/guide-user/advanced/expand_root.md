# Expanding root partition and filesystem

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

## Introduction

- This instruction expands OpenWrt root partition and filesystem on [x86](/docs/guide-user/installation/openwrt_x86 "docs:guide-user:installation:openwrt_x86") target.
- Follow the automated section for quick setup, or click the expand link below for manual setup.

## Features

- Support `ext4` and `squashfs` image types.
- Automatically identify the root partition and filesystem.
- Expand the root partition and filesystem using free space.
- Preserve the scripts through firmware upgrade.
- Automatically run after firmware upgrade.

## Instructions (manual)

Click to display ⇲

Click to hide ⇱

Manual installation of script (C&amp;P)

```
# Configure startup scripts
cat << "EOF" > /etc/uci-defaults/70-rootpt-resize
if [ ! -e /etc/rootpt-resize ] \
&& type parted > /dev/null \
&& lock -n /var/lock/root-resize
then
ROOT_BLK="$(readlink -f /sys/dev/block/"$(awk -e \
'$9=="/dev/root"{print $3}' /proc/self/mountinfo)")"
ROOT_DISK="/dev/$(basename "${ROOT_BLK%/*}")"
ROOT_PART="${ROOT_BLK##*[^0-9]}"
parted -f -s "${ROOT_DISK}" \
resizepart "${ROOT_PART}" 100%
mount_root done
touch /etc/rootpt-resize
 
if [ -e /boot/cmdline.txt ]
then 
NEW_UUID=`blkid ${ROOT_DISK}p${ROOT_PART} | sed -n 's/.*PARTUUID="\([^"]*\)".*/\1/p'`
sed -i "s/PARTUUID=[^ ]*/PARTUUID=${NEW_UUID}/" /boot/cmdline.txt
fi
 
reboot
fi
exit 1
EOF
cat << "EOF" > /etc/uci-defaults/80-rootfs-resize
if [ ! -e /etc/rootfs-resize ] \
&& [ -e /etc/rootpt-resize ] \
&& type losetup > /dev/null \
&& type resize2fs > /dev/null \
&& lock -n /var/lock/root-resize
then
ROOT_BLK="$(readlink -f /sys/dev/block/"$(awk -e \
'$9=="/dev/root"{print $3}' /proc/self/mountinfo)")"
ROOT_DEV="/dev/${ROOT_BLK##*/}"
LOOP_DEV="$(awk -e '$5=="/overlay"{print $9}' \
/proc/self/mountinfo)"
if [ -z "${LOOP_DEV}" ]
then
LOOP_DEV="$(losetup -f)"
losetup "${LOOP_DEV}" "${ROOT_DEV}"
fi
resize2fs -f "${LOOP_DEV}"
mount_root done
touch /etc/rootfs-resize
reboot
fi
exit 1
EOF
cat << "EOF" >> /etc/sysupgrade.conf
/etc/uci-defaults/70-rootpt-resize
/etc/uci-defaults/80-rootfs-resize
EOF
```

Execution

```
# Install packages
opkg update
opkg install parted losetup resize2fs blkid
 
# Expand root partition/filesystem
sh /etc/uci-defaults/70-rootpt-resize
```

## Automated

```
# Install packages
opkg update
opkg install parted losetup resize2fs blkid
 
# Download expand-root.sh
wget -U "" -O expand-root.sh "https://openwrt.org/_export/code/docs/guide-user/advanced/expand_root?codeblock=0"
 
# Source the script (creates /etc/uci-defaults/70-rootpt-resize and /etc/uci-defaults/80-rootpt-resize, and adds them to /etc/sysupgrade.conf so they will be re-run after a sysupgrade)
. ./expand-root.sh
 
# Resize root partition and filesystem (will resize partiton, reboot resize filesystem, and reboot again)
sh /etc/uci-defaults/70-rootpt-resize
```
