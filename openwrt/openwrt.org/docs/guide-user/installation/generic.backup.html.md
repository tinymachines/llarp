# Generic NOR backup

- This guide describes how to perform block-level backup/restore via [CLI](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration").
- Follow [Backup and restore](/docs/guide-user/troubleshooting/backup_restore "docs:guide-user:troubleshooting:backup_restore") for file-level backup/restore.

NAND-based devices should use [NAND-aware utilities](/docs/techref/flash#nand-specific_tools_for_reading_and_writing_to_raw_nand "docs:techref:flash"), as `dd` does not properly handle the error correction or bad-block marking of NAND flash.

Please have a look at [file\_system](/docs/techref/file_system "docs:techref:file_system") and the [flash layout details](/docs/techref/flash.layout#details "docs:techref:flash.layout") and take notice, that OpenWrt covers only the `firmware` part. The **[bootloader](/docs/techref/bootloader "docs:techref:bootloader") partition**, `ART`/`NVRAM` and similar partitions are NOT part of the OpenWrt firmware. If something should go wrong and the data on these partition gets unexpectedly corrupted, you will not be able to replace it via public OpenWrt sources!

Since OpenWrt does not write to those partitions, it is very unlikely that they get corrupted by OpenWrt itself. However, if you mess around with the bootloader, you certainly should create a copy of this data on your PC. Otherwise, in case you lose that data, you would have to go to the forum, ask somebody to make a backup of theirs and send it to you, then you would have to replace the MAC address, and then flash it via [port.jtag](/docs/techref/hardware/port.jtag "docs:techref:hardware:port.jtag"), since your device would probably not boot any longer.

## Create ART backup

If your ART-partition got corrupted, you would still be able to boot OpenWrt and only your wireless would not function correctly any longer. Easy fix with `mtd`.

```
dd if=/dev/$(sed -n -e '/:.*"art"/s///p' /proc/mtd) of=/tmp/art.backup
```

If your bootloader-partition got corrupted, you would not even have a [booloader console](/docs/techref/bootloader#additional_functions "docs:techref:bootloader") which you could only access through [Serial Port](/docs/techref/hardware/port.serial "docs:techref:hardware:port.serial") any longer, and the only way to recover from this would be though the [JTAG Port](/docs/techref/hardware/port.jtag "docs:techref:hardware:port.jtag") or by de-soldering the flash-chip, but please see [generic.debrick](/docs/guide-user/troubleshooting/generic.debrick "docs:guide-user:troubleshooting:generic.debrick") for help.

However, once you've gotten yourself into the position to write to the flash again, you will still need something you can write to it. Something that will work. And here is, where your backup will come in handy:

```
dd if=/dev/mtd0 of=/tmp/boot.backup
```

Then copy your backup-file via scp or ssh to your PC and keep them safe for the time when you may need them.

## Create full MTD backup

This script assumes a working Bash and SSH in native Unix-like or WSL environment. If you've changed your router's IP address, change the OPENWRT variable value to the hostname/IP of your OpenWrt router. This will backup your mtd contents to a compressed tarball file `mtd_backup.tgz` in the same folder as the script.

```
cat << "EOF" > mtdbk.sh
#!/bin/bash
 
set -e
 
function die() {
	echo "${@}"
	exit 2
}
 
OUTPUT_FILE="mtd_backup.tgz"
OPENWRT="root@openwrt.lan"
TMPDIR=$(mktemp -d)
BACKUP_DIR="${TMPDIR}/mtd_backup"
mkdir -p "${BACKUP_DIR}"
SSH_CONTROL="${TMPDIR}/ssh_control"
 
function cleanup() {
	set +e
 
	echo "Closing master SSH connection"
	"${SSH_CMD[@]}" -O stop
 
	echo "Removing temporary backup files"
	rm -r "${TMPDIR}"
}
trap cleanup EXIT
 
# Open master ssh connection, to avoid the need to authenticate multiple times
echo "Opening master SSH connection"
ssh -o "ControlMaster=yes" -o "ControlPath=${SSH_CONTROL}" -o "ControlPersist=10" -n -N "${OPENWRT}"
 
# This is the command we'll use to reuse the master connection
SSH_CMD=(ssh -o "ControlMaster=no" -o "ControlPath=${SSH_CONTROL}" -n "${OPENWRT}")
 
# List remote mtd devices from /proc/mtd. The first line is just a table
# header, so skip it (using tail)
"${SSH_CMD[@]}" 'cat /proc/mtd' | tail -n+2 | while read; do
	MTD_DEV=$(echo ${REPLY} | cut -f1 -d:)
	MTD_NAME=$(echo ${REPLY} | cut -f2 -d\")
	echo "Backing up ${MTD_DEV} (${MTD_NAME})"
	# It's important that the remote command only prints the actual file
	# contents to stdout, otherwise our backup files will be corrupted. Other
	# info must be printed to stderr instead. Luckily, this is how the dd
	# command already behaves by default, so no additional flags are needed.
	"${SSH_CMD[@]}" "dd if='/dev/${MTD_DEV}ro'" > "${BACKUP_DIR}/${MTD_DEV}_${MTD_NAME}.backup" || die "dd failed, aborting..."
done
 
# Use gzip and tar to compress the backup files
echo "Compressing backup files to \"${OUTPUT_FILE}\""
(cd "${TMPDIR}" && tar czf - "$(basename "${BACKUP_DIR}")") > "${OUTPUT_FILE}" || die 'tar failed, aborting...'
 
# Clean up a little earlier, so the completion message is the last thing the user sees
cleanup
# Reset signal handler
trap EXIT
 
echo -e "\nMTD backup complete. Extract the files using:\ntar xzf \"${OUTPUT_FILE}\""
EOF
chmod +x mtdbk.sh
./mtdbk.sh
```

## Create full MTD backup from OpenWrt

The method above works great, but only if you have SSH root access to you router. In some cases when you don't have SSH root access to router, but can connected from UART console. For example TP-Link Archer C9 HW ver 5.0 with original stock firmware. You can make backup from router to you host.

```
# Save the script
cat << "EOF" > /tmp/backup.sh
#!/bin/sh
 
BACKUP_HOST="pc.lan"
BACKUP_USER="root"
echo "Backup host ${BACKUP_HOST}"
 
cat /proc/mtd | tail -n+2 | while read; do
  MTD_DEV=$(echo ${REPLY} | cut -f1 -d:)
  MTD_NAME=$(echo ${REPLY} | cut -f2 -d\")
  echo "Backing up ${MTD_DEV} (${MTD_NAME})"
  dd if=/dev/${MTD_DEV}ro | ssh -y ${BACKUP_USER}@${BACKUP_HOST} "dd of=~/${MTD_DEV}_${MTD_NAME}.backup"
done
EOF
 
# Run the script
sh /tmp/backup.sh
```

Now you'll be asked for SSH password from PC for each mtd device 5 or more times.

After operation completed, you'll find all files in user home directory on PC.

If you on linux and wish to see progress you can run in separate console on PC:

```
watch -n 0.2 ls -l --block-size=K ~
```

## Create backup from bootloader

Sometimes it might be necessary to backup settings/partitions from original firmware. Depending on the bootloader, different strategies might be possible.

The flash-chip is mapped to a start address. With uboot it should be in the following settings:

```
printenv
bdinfo
```

Memory dump to serial that is logged (uboot: *md* ; redboot: *dump*). Writing dumps to tftp or nfs.

## Restore backup from bootloader console

Many bootloader allow you to work with mtd partition, but beware: they do not have to be identical with the Kernel mtd partitions! Also, with some bootloaders, you cannot use mtd-partition, you must work with offsets. In the latter case, it is probably a good idea to write down these correct offsets when you make the backups.

## Restore backup from OpenWrt console

```
mtd write art.backup art
```

Above method could work, but most probably will not as art partition is usually not writable, so you will have to compile you own kernel after doing some [minor modification](/toh/tp-link/tl-wr1043nd#making_bootloader_partition_writable "toh:tp-link:tl-wr1043nd"). Then you must flash this to you device, boot it, and now the partition should be writable.

## Exploring MTD Backups

If you want to explore the contents of an MTD backup on your computer, without restoring it to OpenWrt, you can use [jefferson](https://github.com/sviehb/jefferson "https://github.com/sviehb/jefferson") with the command

```
jefferson mtd4_rootfs_data.backup -d rootfs
```

Where the mtd4\_rootfs\_data.backup file is the mtd block you want to explore. Likely this will be rootfs\_data as it contains most of the customizations you will have made to OpenWrt.
