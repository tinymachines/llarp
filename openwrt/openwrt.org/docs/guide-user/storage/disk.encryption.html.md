# Disk Encryption

You may want to encrypt your external disk to improve privacy (in case other people have physical access to your router) or so that you can securely reuse the disk later for another purpose if it's flash (see [SSDs prove difficult to securely erase](http://nakedsecurity.sophos.com/2011/02/20/ssds-prove-difficult-to-securely-erase/ "http://nakedsecurity.sophos.com/2011/02/20/ssds-prove-difficult-to-securely-erase/")).

Install encryption packages:

```
opkg install kmod-crypto-ecb kmod-crypto-xts kmod-crypto-seqiv kmod-crypto-misc kmod-crypto-user cryptsetup
```

Install ext4 packages:

```
opkg install kmod-fs-ext4 e2fsprogs
```

There are different ways of handling the encryption key. In this example we generate a new random key on every mount.

![](/_media/meta/icons/tango/48px-dialog-warning.svg.png) Don't follow these instructions blindly! Read the [CryptSetup FAQ](https://gitlab.com/cryptsetup/cryptsetup/wikis/FrequentlyAskedQuestions "https://gitlab.com/cryptsetup/cryptsetup/wikis/FrequentlyAskedQuestions") to learn more about the `cryptsetup` command.

The following command will create a standard encrypted container on the device or partition `[encrypted-device]` (eg. `/dev/sda`), and requires you to enter a passphrase that will be used to access the encrypted data later. WARNING: This will destroy anything on `[encrypted-device]`!

```
cryptsetup luksFormat [encrypted-device]
```

This step may take a long time while `/dev/random` gathers enough entropy to generate the key. The security of the passphrase is based on it's strength and the number of iterations it is hashed... as the CPU on embedded systems is usually slow, it's advisable to force the use of a higher iteration count for simple passphrases: use the option `--iter-time=[milliseconds]` to increase the iteration count (default is usually 2000 milliseconds. Note: higher values will increase the time it takes to map the device, not access it once it's mounted).

To use the encrypted container, you must map a decrypted device... this must be done before the device can be formatted or mounted (eg. after each reboot). The following command creates a mapping called `[map-name]` (you can choose the name yourself, eg. crypt) -- you must supply the same passphrase you used when performing `luksFormat` above.

```
cryptsetup open [encrypted-device] [map-name]
```

Format and mount the (now available) decrypted device. `[mount-point]` is where you want the filesystem mounted (eg. `/mnt`):

```
mkfs.ext4 /dev/mapper/[map-name]
mount /dev/mapper/[map-name] [mount-point]
```

On a fresh reboot, you just need for perform the mapping and mount (Note: the mapping will require a passphrase)

```
cryptsetup open [encrypted-device] [map-name]
mount /dev/mapper/[map-name] [mount-point]
```

Unmount:

```
umount [mount-point]
cryptsetup close [map-name]
```

Automated:

The following script can be used to automate decrypting and mounting removable storage that is encrypted by using entries in `/etc/crypttab` (like many linux distros) and `/etc/config/fstab`. To use the following script, a key-file must be generated. To see the occupied Keyslots in the LUKS device:

```
cryptsetup luksDump [encrypted-device]
```

`Keyslots` should have 1 entry (`0:`, from the passphrase created earlier). To use a previously generated key-file, this step may be omitted. To create a new key-file:

```
dd if=/dev/urandom of=[path/to/key-file] bs=512 count=8
```

This will create a key-file that is filled with 4096 bytes of random data. Add this key-file to the LUKS device:

```
cryptsetup luksAddKey [encrypted-device] [path/to/key-file]
```

You will be prompted for the passphrase from above.

```
cryptsetup luksDump [encrypted-device]
```

`Keyslots` should now contain 2 entries (`1:` correlating to the newly created key-file). The format of `/etc/crypttab` should be as follows: `[map-name] [UUID=UUID-of-encrypted-device] [path/to/key-file] [type-of-encryption]`

`[UUID]` and `[type-of-encryption]` may be obtained from the output of:

```
block info
```

`[type-of-encryption]` must match exactly with `TYPE=` given by `block info`.

[install-decrypt.sh](/_export/code/docs/guide-user/storage/disk.encryption?codeblock=12 "Download Snippet")

```
cat << "EOF" > /etc/hotplug.d/block/99-lukscrypt
# note: this needs ash installed
ash /sbin/decrypt.sh
EOF
 
cat << "EOF" > /sbin/decrypt.sh
#!/bin/sh
# Perform tasks when called by BLOCK hotplug (/etc/hotplug.d/block/99-lukscrypt)
# CC0: 21JUL18 by WaLLy3K, updated 09AUG18
# Further adapted for OpenWRT 18.06 by jmm on 2018-09-04
# Further adapted for OpenWRT 21.02.2 by mdpc on 2022-12-30
# Further adapted for OpenWRT 22.03 by crass on 2023-07-24
#  * remove dependency on awk
#  * allow specifying alternate path to crypttab and alternate root for keyfile
# https://openwrt.org/docs/guide-user/storage/disk.encryption
 
# Hotplug Vars: $ACTION (add/remove), $DEVICE (?), $DEVNAME (sdx)
 
# logger -s "start decrypt luks" $DEVNAME $ACTION
 
if [ -z "${DEVNAME}" ]; then
    DEVNAME="${1##*/}"
fi
 
msg() {
    echo "$@" >/dev/kmsg
}
 
if [ "$ACTION" != "add" ]; then
    #only do something if a device is being added
    exit 1
fi
 
if [[ "$DEVNAME" == dm-[0-9] ]]; then
    #/dev/mapper block device has been created so now try to mount FS if set up
    # in /etc/config/fstab (or LuCI > System > Mount Points)
    block mount
    exit 0
fi
 
# Determine whether drive needs to be decrypted
CRYPTTAB=${CRYPTTAB:-"${ALTROOT}/etc/crypttab"}
if [[ ! -r "$CRYPTTAB" ]]; then
    msg "Unable to read crypttab file: ${CRYPTTAB}"
    exit 1
fi
 
[ -e /dev/fd ] || ln -s /proc/self/fd /dev
 
#IFS=: read BID_DEVNAME BID_RAW < <(block info "/dev/$DEVNAME")
BID_DEVNAME=$(block info "/dev/$DEVNAME" | (read V _; echo $V))
BID_RAW=$(block info "/dev/$DEVNAME" | (read _ V; echo $V))
if [[ -n "${BID_RAW}" ]]; then
    eval "export ${BID_RAW#*:}"
fi
 
if [[ -n "$UUID" ]]; then
    CT_RAW="$(grep -m 1 "UUID=${UUID}" "$CRYPTTAB")"
fi
 
if [[ -z "$CT_RAW" ]] && [[ -n "$LABEL" ]]; then
    CT_RAW="$(grep -m 1 "LABEL=${LABEL}" "$CRYPTTAB")"
fi
 
if [[ -z "$CT_RAW" ]]; then
    CT_RAW="$(grep -m 1 " /dev/${DEVNAME} " "$CRYPTTAB")"
fi
 
if [[ -z "${CT_RAW:-}" ]]; then
    # No crypttab entry found for this device
    exit 1
fi
#read CT_LABEL _ CT_KEYFILE CT_TYPE < <(echo $CT_RAW)
CT_LABEL=$(echo $CT_RAW | (read V _; echo $V))
CT_KEYFILE=$(echo $CT_RAW | (read _ _ V _; echo $V))
CT_TYPE=$(echo $CT_RAW | (read _ _ _ V; echo $V))
 
if [[ -e "/dev/mapper/${CT_LABEL}" ]]; then
    msg "Drive already decrypted: $CT_LABEL"
    exit 1
fi
 
# Error Handling
if [[ ! -e "${ALTROOT:+${ALTROOT}/}$CT_KEYFILE" ]]; then
    msg "Unable to view keyfile: '$CT_KEYFILE'"
    exit 1
fi
if [[ ! "${TYPE}" == *"${CT_TYPE}"* ]]; then
    msg "Unable to decrypt format: $CT_TYPE"
    exit 1
fi
 
msg "Decrypting drive: $CT_LABEL (/dev/$DEVNAME)"
cryptsetup open "/dev/$DEVNAME" "${CT_LABEL}" -d "${ALTROOT:+${ALTROOT}/}$CT_KEYFILE"
CS_EXIT="$?"
case "$CS_EXIT" in
0)  if [ -e "/dev/mapper/${CT_LABEL}" ]; then
        msg "Drive decrypted: $CT_LABEL"
    else
        msg "Drive not found after decrypting: $CT_LABEL"
        exit 1
    fi;;
5)  msg "Device already exists: $CT_LABEL (Dmsetup stuck?)"; exit 1;;
*)  msg "Unable to decrypt drive: $CT_LABEL ($CS_EXIT)"; exit 1;;
esac
 
exit 0
EOF
 
chmod +x /sbin/decrypt.sh
```

The above script does not unmount or remove `/dev/mapper` devices when a USB device is removed so this must be done manually as outlined above.

## Example

A video demonstration on OpenWrt 14.07 Barrier Breaker using LUKS: [https://www.youtube.com/watch?v=NSVWb6dscVI](https://www.youtube.com/watch?v=NSVWb6dscVI "https://www.youtube.com/watch?v=NSVWb6dscVI") (broken link, 07.Mar.2016)
