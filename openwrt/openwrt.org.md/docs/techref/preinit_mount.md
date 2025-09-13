# Preinit and Root Mount and Firstboot Scripts

![FIXME](/lib/images/smileys/fixme.svg) Information may be outdated and obsolete information as of April, 2018; Overview, Preinit and Overview, Failsafe updated from April 2018 based on reading `master` code.

See [Rootfs on External Storage](/docs/guide-user/additional-software/extroot_configuration "docs:guide-user:additional-software:extroot_configuration") for information on external rootfs mounting.

# Abstract

This document presents the preinit / firstboot boot sequence. The boot system is extensible via (new) packages such as rootfs on usb, or enhanced failsafe.

We describe the portion of the OpenWrt boot sequence that occurs before the 'init' program is executed (when booting in multiuser mode), as well as the script that is responsible for creating and initializing the root filesystem on the first boot after flashing the device with OpenWrt.

# Context: Boot Sequence

The basic OpenWrt boot sequence is:

1. boot loader loads kernel
2. kernel loads whilst scanning the mtd partition *rootfs* for a valid superblock for mounting the SquashFS partition (which contains /etc). More info at [technical.details](/docs/techref/filesystems#technicaldetails "docs:techref:filesystems")
3. kernel calls `/etc/preinit` (the kernel considers this to be the `init` (or root) process `/sbin/init` now the init process, which in turn launches `/sbin/procd -h /etc/hotplug-preinit.json` (a.k.a., “plugd”) followed by `/bin/sh /etc/preinit`. Each is launched via `fork` and `execvp` and managed by the uloop library in libubox.
4. `/etc/preinit` prepares system for multiuser mode
5. `/etc/preinit` `exec`s `/sbin/init` which becomes the `init` (or root) process and launches multiuser
6. `/sbin/init` launches processes according to /etc/inittab.
7. Typically the first process launched is `/etc/init.d/rcS` which causes the scripts in `/etc/rc.d` which begin with 'S' to be launched (in glob sort order). The `/etc/rc.d` directory is populated with symlinks to the scripts in `/etc/init.d`. Each script in `/etc/init.d` accepts `enable` and `disable` arguments for creating and removing the symlinks.
8. These script initialize the system and also initialize daemons that wait for input, so that when all the scripts have executed the normal system is active. On first boot this initializing includes the process of preparing the root filesystem for use.

* * *

# Overview

The following preinit scripts are available in the OpenWrt master branches for base and packages feed (Status September 2024)

repo packages target subtarget file-repo file-target hook info packages openssh all all net/openssh/files/sshd.failsafe /lib/preinit/99\_10\_failsafe\_sshd failsafe packages btrfs-progs all all utils/btrfs-progs/files/btrfs-scan.init /lib/preinit/85\_btrfs\_scan preinit\_main INITRAMFS check 'NO' packages lvm2 all all utils/lvm2/files/lvm2.preinit /lib/preinit/80\_lvm2 preinit\_main INITRAMFS check 'NO' base dropbear all all package/network/services/dropbear/files/dropbear.failsafe /lib/preinit/99\_10\_failsafe\_dropbear failsafe base zyxel-bootconfig all all package/utils/zyxel-bootconfig/files/95\_apply\_bootconfig /lib/preinit/95\_apply\_bootconfig preinit\_main INITRAMFS check 'YES' base linux imx cortexa53 target/linux/imx/cortexa53/base-files/lib/preinit/79\_move\_config /lib/preinit/79\_move\_config preinit\_mount\_root base linux imx cortexa7 target/linux/imx/cortexa7/base-files/lib/preinit/79\_move\_config /lib/preinit/79\_move\_config preinit\_mount\_root base linux imx cortexa9 target/linux/imx/cortexa9/base-files/lib/preinit/79\_move\_config /lib/preinit/79\_move\_config preinit\_mount\_root base linux rockchip armv8 target/linux/rockchip/armv8/base-files/lib/preinit/79\_move\_config /lib/preinit/79\_move\_config preinit\_mount\_root base linux omap target/linux/omap/base-files/lib/preinit/79\_move\_config /lib/preinit/79\_move\_config preinit\_mount\_root base linux qoriq target/linux/qoriq/base-files/lib/preinit/79\_move\_config /lib/preinit/79\_move\_config preinit\_mount\_root base linux sifiveu target/linux/sifiveu/base-files/lib/preinit/79\_move\_config /lib/preinit/79\_move\_config preinit\_mount\_root base linux tegra target/linux/tegra/base-files/lib/preinit/79\_move\_config /lib/preinit/79\_move\_config preinit\_mount\_root base linux sunxi target/linux/sunxi/base-files/lib/preinit/79\_move\_config /lib/preinit/79\_move\_config preinit\_mount\_root base base-files all all package/base-files/files/lib/preinit/02\_default\_set\_state /lib/preinit/02\_default\_set\_state preinit\_main base base-files all all package/base-files/files/lib/preinit/02\_sysinfo /lib/preinit/02\_sysinfo preinit\_main base base-files all all package/base-files/files/lib/preinit/10\_indicate\_failsafe /lib/preinit/10\_indicate\_failsafe failsafe base base-files all all package/base-files/files/lib/preinit/10\_indicate\_preinit /lib/preinit/10\_indicate\_preinit preinit\_main base base-files all all package/base-files/files/lib/preinit/30\_failsafe\_wait /lib/preinit/30\_failsafe\_wait preinit\_main base base-files all all package/base-files/files/lib/preinit/40\_run\_failsafe\_hook /lib/preinit/40\_run\_failsafe\_hook preinit\_main base base-files all all package/base-files/files/lib/preinit/50\_indicate\_regular\_preinit /lib/preinit/50\_indicate\_regular\_preinit preinit\_main base base-files all all package/base-files/files/lib/preinit/70\_initramfs\_test /lib/preinit/70\_initramfs\_test preinit\_main base base-files all all package/base-files/files/lib/preinit/80\_mount\_root /lib/preinit/80\_mount\_root preinit\_main INITRAMFS check 'YES' base base-files all all package/base-files/files/lib/preinit/99\_10\_failsafe\_login /lib/preinit/99\_10\_failsafe\_login failsafe base base-files all all package/base-files/files/lib/preinit/99\_10\_run\_init /lib/preinit/99\_10\_run\_init preinit\_main INITRAMFS check 'NO' base linux bcm47xx target/linux/bcm47xx/base-files/lib/preinit/01\_sysinfo /lib/preinit/01\_sysinfo preinit\_main base linux lantiq xway\_legacy target/linux/lantiq/xway\_legacy/base-files/lib/preinit/05\_set\_preinit\_iface\_lantiq /lib/preinit/05\_set\_preinit\_iface\_lantiq preinit\_main base linux lantiq xway target/linux/lantiq/xway/base-files/lib/preinit/05\_set\_preinit\_iface\_lantiq /lib/preinit/05\_set\_preinit\_iface\_lantiq preinit\_main base linux lanitq ase target/linux/lantiq/ase/base-files/lib/preinit/05\_set\_preinit\_iface\_lantiq /lib/preinit/05\_set\_preinit\_iface\_lantiq preinit\_main base linux armsr target/linux/armsr/base-files/lib/preinit/01\_sysinfo\_acpi /lib/preinit/01\_sysinfo\_acpi preinit\_main base linux armsr target/linux/armsr/base-files/lib/preinit/79\_move\_config /lib/preinit/79\_move\_config preinit\_mount\_root base linux x86 target/linux/x86/base-files/lib/preinit/02\_load\_x86\_ucode /lib/preinit/02\_load\_x86\_ucode preinit\_main base linux x86 target/linux/x86/base-files/lib/preinit/15\_essential\_fs\_x86 /lib/preinit/15\_essential\_fs\_x86 ? base linux x86 target/linux/x86/base-files/lib/preinit/20\_check\_iso /lib/preinit/20\_check\_iso preinit\_mount\_root base linux x86 target/linux/x86/base-files/lib/preinit/79\_move\_config /lib/preinit/79\_move\_config preinit\_mount\_root base linux x86 target/linux/x86/generic/base-files/lib/preinit/45\_mount\_xenfs /lib/preinit/45\_mount\_xenfs preinit\_mount\_root base linux x86 64 target/linux/x86/64/base-files/lib/preinit/45\_mount\_xenfs /lib/preinit/45\_mount\_xenfs preinit\_mount\_root base linux bcm27xx target/linux/bcm27xx/base-files/lib/preinit/05\_set\_preinit\_iface\_brcm2708 /lib/preinit/05\_set\_preinit\_iface\_brcm2708 preinit\_main base linux bcm27xx target/linux/bcm27xx/base-files/lib/preinit/79\_move\_config /lib/preinit/79\_move\_config preinit\_mount\_root base linux bcm27xx target/linux/bcm27xx/base-files/lib/preinit/81\_set\_root\_part /lib/preinit/81\_set\_root\_part preinit\_main INITRAMFS check 'YES' base linux mediatek target/linux/mediatek/base-files/lib/preinit/05\_set\_preinit\_iface /lib/preinit/05\_set\_preinit\_iface preinit\_main base linux mediatek target/linux/mediatek/base-files/lib/preinit/06\_set\_rps\_sock\_flow /lib/preinit/06\_set\_rps\_sock\_flow preinit\_main base linux mediatek target/linux/mediatek/base-files/lib/preinit/07\_trigger\_fip\_scrubbing /lib/preinit/07\_trigger\_fip\_scrubbing preinit\_main base linux mediatek mt7623 target/linux/mediatek/mt7623/base-files/lib/preinit/07\_set\_iface\_mac /lib/preinit/07\_set\_iface\_mac preinit\_main base linux mediatek mt7623 target/linux/mediatek/mt7623/base-files/lib/preinit/79\_move\_config /lib/preinit/79\_move\_config preinit\_mount\_root base linux mediatek filogic target/linux/mediatek/filogic/base-files/lib/preinit/04\_set\_netdev\_label /lib/preinit/04\_set\_netdev\_label preinit\_main base linux mediatek filogic target/linux/mediatek/filogic/base-files/lib/preinit/05\_extract\_factory\_data.sh /lib/preinit/05\_extract\_factory\_data.sh preinit\_main base linux mediatek filogic target/linux/mediatek/filogic/base-files/lib/preinit/09\_mount\_cfg\_part /lib/preinit/09\_mount\_cfg\_part preinit\_main base linux mediatek filogic target/linux/mediatek/filogic/base-files/lib/preinit/10\_fix\_eth\_mac.sh /lib/preinit/10\_fix\_eth\_mac.sh preinit\_main base linux mediatek filogic target/linux/mediatek/filogic/base-files/lib/preinit/75\_rootfs\_prepare /lib/preinit/75\_rootfs\_prepare preinit\_main INITRAMFS check 'NO' base linux apm821xx target/linux/apm821xx/base-files/lib/preinit/05\_set\_preinit\_iface\_apm821xx /lib/preinit/05\_set\_preinit\_iface\_apm821xx preinit\_main base linux apm821xx target/linux/apm821xx/base-files/lib/preinit/05\_set\_iface\_mac\_apm821xx /lib/preinit/05\_set\_iface\_mac\_apm821xx preinit\_main base linux apm821xx target/linux/apm821xx/base-files/lib/preinit/79\_move\_config /lib/preinit/79\_move\_config preinit\_mount\_root base linux ixp4xx target/linux/ixp4xx/base-files/lib/preinit/05\_set\_ether\_mac\_ixp4xx /lib/preinit/05\_set\_ether\_mac\_ixp4xx preinit\_main base linux kirkwood target/linux/kirkwood/base-files/lib/preinit/07\_set\_iface\_mac /lib/preinit/07\_set\_iface\_mac preinit\_main base linux mvebu target/linux/mvebu/base-files/lib/preinit/79\_move\_config /lib/preinit/79\_move\_config preinit\_mount\_root base linux mvebu cortexa53 target/linux/mvebu/cortexa53/base-files/lib/preinit/82\_uDPU /lib/preinit/82\_uDPU preinit\_main INITRAMFS check 'NO' base linux mvebu cortexa9 target/linux/mvebu/cortexa9/base-files/lib/preinit/81\_linksys\_syscfg /lib/preinit/81\_linksys\_syscfg preinit\_main INITRAMFS check 'NO' base linux ipq806x target/linux/ipq806x/base-files/lib/preinit/04\_reorder\_eth /lib/preinit/04\_reorder\_eth preinit\_main base linux ath79 generic target/linux/ath79/generic/base-files/lib/preinit/02\_sysinfo\_fixup /lib/preinit/02\_sysinfo\_fixup preinit\_main base linux ath79 generic target/linux/ath79/generic/base-files/lib/preinit/10\_fix\_eth\_mac.sh /lib/preinit/10\_fix\_eth\_mac.sh preinit\_main base linux ath79 nand target/linux/ath79/nand/base-files/lib/preinit/10\_fix\_eth\_mac.sh /lib/preinit/10\_fix\_eth\_mac.sh preinit\_main base linux bcm4908 target/linux/bcm4908/base-files/lib/preinit/75\_rootfs\_prepare /lib/preinit/75\_rootfs\_prepare preinit\_main INITRAMFS check 'NO' base linux gemini target/linux/gemini/base-files/lib/preinit/05\_set\_ether\_mac\_gemini /lib/preinit/05\_set\_ether\_mac\_gemini preinit\_main base linux loongarch64 target/linux/loongarch64/base-files/lib/preinit/01\_sysinfo\_acpi /lib/preinit/01\_sysinfo\_acpi preinit\_main base linux loongarch64 target/linux/loongarch64/base-files/lib/preinit/79\_move\_config /lib/preinit/79\_move\_config preinit\_mount\_root base linux mpc85xx target/linux/mpc85xx/base-files/lib/preinit/05\_set\_preinit\_iface\_mpc85xx /lib/preinit/05\_set\_preinit\_iface\_mpc85xx preinit\_main base linux mpc85xx target/linux/mpc85xx/base-files/lib/preinit/10\_fix\_eth\_mac.sh /lib/preinit/10\_fix\_eth\_mac.sh preinit\_main base linux layerscape target/linux/layerscape/base-files/lib/preinit/02\_sysinfo\_fixup /lib/preinit/02\_sysinfo\_fixup preinit\_main base linux layerscape target/linux/layerscape/base-files/lib/preinit/79\_move\_config /lib/preinit/79\_move\_config preinit\_mount\_root base linux ramips mt7621 target/linux/ramips/mt7621/base-files/lib/preinit/04\_set\_netdev\_label /lib/preinit/04\_set\_netdev\_label preinit\_main base linux ramips rt305x target/linux/ramips/rt305x/base-files/lib/preinit/04\_handle\_checksumming /lib/preinit/04\_handle\_checksumming preinit\_main base linux ramips rt3883 target/linux/ramips/rt3883/base-files/lib/preinit/04\_handle\_checksumming /lib/preinit/04\_handle\_checksumming preinit\_main base linux ipq40xx target/linux/ipq40xx/base-files/lib/preinit/05\_set\_iface\_mac\_ipq40xx.sh /lib/preinit/05\_set\_iface\_mac\_ipq40xx.sh preinit\_main base linux octeon target/linux/octeon/base-files/lib/preinit/01\_sysinfo /lib/preinit/01\_sysinfo preinit\_main base linux octeon target/linux/octeon/base-files/lib/preinit/79\_move\_config /lib/preinit/79\_move\_config preinit\_mount\_root

## Preinit

Preinit brings the system from raw kernel to ready for multiuser. To do so, as of April, 2018, `/etc/preinit` (ar71xx, Archer C7) performs the following tasks:

1. Checks to see if `$PREINIT` is empty; if so `exec /sbin/init` and skip the rest
2. Sources a set of files for common functions for boot/mount:
   
   - `/lib/functions.sh`
   - `/lib/functions/preinit.sh`
   - `/lib/functions/system.sh`
3. Prepares the “hooks” for the various stages of the preinit process
   
   - preinit\_essential
   - preinit\_main
   - failsafe
   - initramfs
   - preinit\_mount\_root
4. Source the contents of `/lib/preinit/*` which generally add `sh` functions to the appropriate hooks
5. Runs the `preinit_essential` hooks
6. Runs the `preinit_main` hooks

On an ar71xx device (Archer C7) the default functions added to the various hooks include (with functions from device-specific files in *italics):*

- **preinit\_main**
  
  01. *do\_ar71xx*
  02. define\_default\_set\_state
  03. do\_sysinfo\_generic
  04. *preinit\_set\_mac\_address*
  05. *set\_preinit\_iface*
  06. preinit\_ip
  07. pi\_indicate\_preinit
  08. failsafe\_wait
  09. run\_failsafe\_hook
      
      - **failsafe** (if “$pi\_preinit\_no\_failsafe” != “y” and “$FAILSAFE” = “true”)
        
        1. indicate\_failsafe
        2. failsafe\_netlogin
        3. failsafe\_shell
  10. indicate\_regular\_preinit
  11. do\_mount\_root (if “$INITRAMFS” != “1”)
  12. do\_urandom\_seed
  13. *check\_patch\_ath10k\_firmware*
  14. run\_init

Presently unused hooks, at least for the ar71xx Archer C7, appear to include

- preinit\_essential
- initramfs
- preinit\_mount\_root

## Failsafe

The *root file system* is actually an overlay which can be consisted of a read-only SquashFS file system (mounted at `/rom`) and a writable JFFS2 partition (mounted under `/overlay`). In Failsafe mode only the squashfs FS will be mounted (changes made to jffs2 partitons will be ignored), plus the following steps:

1. Notifies that failsafe mode is being entered (indicate\_failsafe)
2. Launches daemon to allow network logins (failsafe\_netlogin)
3. Allows login via serial console, if there is one (failsafe\_shell)
   
   - If the serial console login process exits, failsafe doesn't exit, but restarts the process for additional logins.

## Mount Root Filesystem

all\_jffs2 refers to a 'jffs2' target in menuconfig; e.g. firmware has no squashfs, but is purely a rw filesystem (jffs2), while, jffs2 in the following text refers to the jffs2 portion of a [squashfs/jffs2](/docs/techref/filesystems#overlayfs "docs:techref:filesystems") system.

1. Kernel has previously mounted squashfs partition by scanning the mtd partition `rootfs` for a valid superblock (see step 2 of [contextboot.sequencel](/docs/techref/preinit_mount#contextbootsequencel "docs:techref:preinit_mount")) ![FIXME](/lib/images/smileys/fixme.svg) **Make sure it's correct**
2. If there is no mtd device with label `rootfs_data`, then mounts `/dev/root` (e.g. squashfs or all\_jffs2 with no squashfs) as root filesystem, and indicates that further steps should be skipped
3. If mtd device `rootfs_data` has not already been formatted, mounts a tmpfs (ramdisk) as root filesystem, and indicates that further steps should be skipped.
4. Mounts previously formatted jffs2 partition on `/overlay` and indicates successful mount.
5. Makes successfully mounted `/overlay` (if it exists) the new root filesystem and moves previous root filesystem to `/rom`, and indicates to skip further steps.
6. This is only reached on an error condition; attempts to mount a tmpfs (ramdisk) as root filesystem
7. This is only reached if no other step succeeds; attempt to mount `/dev/root` (e.g. squashfs/all\_jffs2) as root filesystem.

**\*** `/overlay` was previously named `/jffs2`.  
**\*** NOTE: If volatile files (e.g. a config) were preserved across firmware update via `sysupgrade`, step 3 is skipped. Instead, preinit\_main hangs while the rootfs\_data partition is formatted and the jffs2 overlay is mounted. Hypothetically, this is fatal on systems with weak cpu and exceptionally large rootfs\_data partitions. For more information [consult this forum post](https://forum.openwrt.org/t/error-in-preinit-documentation-regarding-overlays/60188/4 "https://forum.openwrt.org/t/error-in-preinit-documentation-regarding-overlays/60188/4").

## First Boot

Updated to version 23.05. And, likely applies to a number of previous versions.

`/sbin/firstboot` is a script that simply calls `/sbin/jffs2reset $@` which clears the overlay if it's mounted:

- -y Answer yes to “Are you sure?”
- -r Reboot instead of returning control to the caller.
- -k Keep the file `/sysupgrade.tgz` while clearing the overlay.

`/lib/preinit/80_mount_root` will extract the contents of `/sysupgrade.tgz` into the overlay after the reboot. This mechanism may be used to write into `/etc/uci-defaults` as a way to create a custom configuration immediately after the reboot.

### Common

1. Source `/lib/functions/boot.sh` for common functions (e.g. also used by preinit)
2. Source files used by hooks
3. Determine how called, and branch to appropriate commands.

### Sourced rather than executed

1. Determine (and set variable for) MTD rootfs\_data partition
2. Determine (and set variable for) rom partition
3. Determine (and set variable for) jffs2 partition

### Executed with no parameters

- Resets jffs2 to original settings, if possible.
- If jffs2 is not mounted, erases mtd and attempts format, mount, and pivot jffs2 as root.

If jffs2 is mounted, `firstboot` runs hook `jffs2reset`

1. Determine (and set variable for) MTD rootfs\_data partition
2. Determine (and set variable for) rom partition
3. Determine (and set variable for) jffs2 partition
4. Determine (and set variable to indicate) whether the mini overlay filesystem type is supported.
5. If overlay is supported, remove all files on jffs2 and remount it.
6. If overlay not supported, create directories and symlinks, copying only certain critical files

<!--THE END-->

- Note: since r35712 the firstboot script requires an inputted 'y' as confirmation. If using firstboot in a reset button script, you need to get that y inputted, e.g. by using the yes command: yes | firstboot

### Executed with parameter 'switch2jffs'

1. Determine (and set variable for) MTD rootfs\_data partition
2. Determine (and set variable for) rom partition
3. Determine (and set variable for) jffs2 partition
4. Determine if mini overlay is supported. If not run hook no\_fo
5. Otherwise, if mounted, skip the rest, otherwise mount under squashfs (`/rom/jffs`)
6. Copy ramdisk to jffs2
7. Move `/jffs` to `/` (root) and move `/` (root) to `/rom`
8. Cleanup

### hook no\_fo

1. Switch to kernel fs, get rid of union overlay and bind from /tmp/root
2. Mount jffs (and make it safe for union)
3. If not mounted, mount; copy from squashfs, and pivot so that /jffs is now / (root)
4. Copy files from ramdisk
5. Get rid of unnecessary mounts (cleanup)

# Preinit Operation

Preinit consists of a number of scripts. The main script is `/etc/preinit` which reads in the scripts. The scripts define functions which they attach to hooks. These hooks are, when processed, launching the functions in the order they were added to the hooks.

Currently there are five hooks used by the preinit system:

- `preinit_essential`
- `preinit_main`
- `failsafe`
- `initramfs`
- `preinit_mount_root`

Each hook have a corresponding string variable containing the name of each function to be executed, separated by spaces. The hook variables have `_hook` appended to the hook name. Thus the name of the variable for the `preinit_essential` hook is `preinit_essential_hook`.

## Main Preinit Script

The main preinit script is actually quite empty. It:

1. Initializes some variables (including the hook variables)
2. Defines the function `pi_hook_add`, which is used to add functions to a hook
3. Defines the function `pi_run_hook`, which executes the functions that were added to a hook
4. Sources (reads) the shell scripts under folder `/lib/preinit/`, in glob sort order
5. Processes the hook `preinit_essential`
6. Initializes variables used by `preinit_main`
7. Processes the hook `preinit_main`

That's it.

## Variables

There are a number of variables that control options of preinit. Defaults are defined in the main script `/etc/preinit` defined by the `base-files` package. However the variables are customizable via `make menuconfig`, in section “Preinit configuration options”. The OpenWrt build process will then create the file `/lib/preinit/00_preinit.conf` which will be sourced by the main script.

The variables defined at present are:

Variable Description `pi_ifname` The device name of the network interface used to emit network messages during preinit (except failsafe) `pi_ip` The IP address of the preinit network (see above) `pi_broadcast` The broadcast address of the preinit network (see above) `pi_netmask` The netmask for the preinit network (see above) `fs_failsafe_wait_timeout` How long to pause while allowing the user to choose to enter failsafe mode. Default is two (2) seconds. `pi_suppress_stderr` If this is “y”, then output on standard error (stderr, file descriptor 2), is ignored during preinit. This is the default in previous versions of OpenWrt (which did not have this option) `pi_init_suppress_stderr` If `pi_suppress_stderr` is not “y” (i.e. stderr is not suppressed for preinit), then this option controls whether init, and process run by init, except those associated with a terminal device (e.g. `tts/0`, `ttyS0`, `tty1`, `pts/0`, or other similar devices) will have stderr suppressed (not that network terminals such as those from SSH are associated with a pseudo-terminal device such as `pty0/pty1` and are thus unaffected). As with `pi_suppress_stderr`, the default, and behaviour from previous versions of OpenWrt is “y”. `pi_init_path` The default search PATH for binaries for commands run by init. Default is `/bin:/sbin:/usr/bin:/usr/sbin` `pi_init_cmd` The command to run as `init`. Default is `/sbin/init` `pi_preinit_no_failsafe_netmsg` suppress netmsg to say that one can enter failsafe mode `pi_preinit_net_messages` If enabled, show more network messages than just the message that one can enter failsafe mode

There are also variables used in the operation of preinit. They are:

Variable Description `preinit_essential_hook` Variable containing hook names to execute, in order, for hook `preinit_essential` `preinit_main_hook` Ditto, for `preinit_main` `failsafe_hook` Ditto, for `failsafe` `initramfs_hook` Ditto, for `initramfs` `preinit_mount_root_hook` Ditto, for `preinit_mount_root` `pi_mount_skip_next` During hook `preinit_mount_root`, skips most steps; usually set by a preceeding step `pi_jffs2_mount_success` During hook `preinit_mount_root`, used by steps following mount attempt to determine which action they should take

## Hooks

The following sections describe the files and functions used by the various hooks.

**NB**: The files, even though divided by hook here are all in the single `/lib/preinit` directory, and are thus combined in the directory lists, and are processed in glob sort order, not by hook (when sourcing them, the hooks specify the order of the execution of functions, which is as listed below)

### Development

For the purposes of development, you will locate the files under `$ROOTDIR/package/base-files/files/lib/preinit`, for the existing files, and you can add new files anywhere that ultimately ends up in `/lib/preinit` on the router (while in preinit, e.g. not by user edits after read-write is mounted).

### preinit\_essentials

![:!:](/lib/images/smileys/exclaim.svg) With the introduction of [procd](/docs/techref/procd "docs:techref:procd"), effective in Chaos Calmer release, the tasks of this hook are done in c code and at least on some images (verified on a BRCM63xx one) this hook is unused.

The preinit\_essentials hook takes care of mounting essential kernel filesystems such as proc, and initializing the console.

Files containing the functions executed by this hook

File Functions 10\_essential\_fs do\_mount\_procfs, do\_mount\_sysfs, do\_mount\_tmpfs 20\_device\_fs\_mount do\_mount\_devfs, do\_mount\_hotplug, do\_mount\_udev, choose\_device\_fs 30\_device\_daemons init\_hotplug, init\_udev, init\_device\_fs 40\_init\_shm init\_shm 40\_pts\_mount do\_mount\_pts 50\_choose\_console choose\_console 60\_init\_console init\_console

Functions, in order, executed by this hook (doesn't list the functions only called by other functions)

Function Description do\_mount\_procfs mounts /proc do\_mount\_sysfs mounts /sys do\_mount\_tmpfs mounts /tmp choose\_device\_fs determines type of device daemon and the appropriate filesystem to mount on /dev for that device daemon init\_device\_fs launches daemons (if any) responsible for population /dev, and/or creating hotplug events when devices are added/removed (and for initial coldplug events) init\_shm makes sure /dev/shm exists init\_pts makes sure /dev/pts exists do\_mount\_pts mounts devpts on /dev/pts (pseudo-terminals) choose\_console determines devices for stdin, stdout, and stderr init\_console activates stdin, stdout, and stderr of preinit (and subsequent init) (prior to this they are not present in the environment)

Functions which are called by other functions, rather than directly as part of a hook

Function Description do\_mount\_devfs mount devfs on /dev do\_mount\_hotplug mount tmpfs on /dev (for hotplug) do\_mount\_udev mount tmpfs on /dev (for udev) init\_hotplug set hotplug handler (actually initiated after console init) init\_udev start udev

### preinit\_main

The *preinit\_main* hook performs all the functions required of preinit, except those functions, like console, that are essential even for preinit tasks.

File Description 10\_indicate\_preinit preinit\_ip, preinit\_ip\_deconfig, preinit\_net\_echo, preinit\_echo, pi\_indicate\_led, pi\_indicate\_preinit 30\_failsafe\_wait fs\_wait\_for\_key, failsafe\_wait 40\_run\_failsafe\_hook run\_failsafe\_hook 50\_indicate\_regular\_preinit indicate\_regular\_preinit\_boot 60\_init\_hotplug init\_hotplug 70\_initramfs\_test initramfs\_test 80\_mount\_root do\_mount\_root 90\_restore\_config restore\_config 99\_10\_run\_init run\_init

Functions, in order, executed by this hook (doesn't list the functions only called by other functions)

Function Description init\_hotplug Initialize hotplug, if needed (that is for devfs). Hotplug or a device daemon is needed so that devices are available for use for preinit preinit\_ip Initialize network interface (if one has been defined for as available for preinit) pi\_indicate\_preinit Send messages to console, network, and/or led, depending on which, if any, of these is present which say that we are in preinit mode failsafe\_wait Emits messages (to network and console) that indicate the user has the option to enter failsafe mode and wait for the configured period of time (default two seconds) for the user to select failsafe mode run\_failsafe\_hook If user chooses to enter failsafe mode, run the \*failsafe* hook (which at present doesn't return, which means no more functions from preinit\_main get run on this boot) indicate\_regular\_preinit\_boot Emits messages to network, console, and/or LED depending on which (if any) is present, indicating that it's a regular boot not a failsafe boot initramfs\_test If initramfs is present run the \*initramfs* hook and exit do\_mount\_root Executes hook \*preinit\_mount\_root* restore\_config If a previous configuration was stored by sysupgrade, restore it to the rootfs run\_init Exec the command defined by \`pi\_init\_cmd\` with the environment variables defined by \`pi\_init\_env\`, plus PATH \`pi\_init\_path\`

Functions which are called by other functions, rather than directly as part of a hook.

Function Description preinit\_ip\_deconfig deconfigure interface used for preinit network messages etc preinit\_net\_echo emit a message on the preinit network interface preinit\_echo emit a message on the (serial) console pi\_indicate\_led set LED status to indicate preinit mode fs\_wait\_for\_key wait for reset button press, CTRL-C, or &lt;some\_key&gt;&lt;ENTER&gt;, with timeout

### failsafe

Do what needs to done to prepare failsafe mode and enter it.

File Description 10\_indicate\_failsafe indicate\_failsafe\_led, indicate\_failsafe 99\_10\_failsafe\_login failsafe\_netlogin, failsafe\_shell

Functions, in order, executed by this hook (doesn't list the functions only called by other functions)

Function Description indicate\_failsafe Emit message/status to network, console, and/or LED (depending on which, if any, are present) indicating that the device is now in failsafe mode failsafe\_netlogin Launch telnet daemon to allow telnet login on the defined network interface (if any) failsafe\_shell Launch a shell for access via serial console (if present)

Functions which are called by other functions, rather than directly as part of a hook

Function Description indicate\_failsafe\_led set LED status to indicate preinit mode

### preinit\_mount\_root

Mount the root filesystem

File Description 05\_mount\_skip check\_skip 10\_check\_for\_mtd mount\_no\_mtd, check\_for\_mtd

Functions, in order, executed by this hook (doesn't list the functions only called by other functions)

Function Description check\_for\_mtd Check for a mtd partition named rootfs\_data. If not present mount kernel fs as root (e.g. all\_jjfs2 or squashfs only) and skip rest. check\_for\_jffs2 Check if jffs2 formatted yet. If not, mount ramoverlay and skip rest do\_mount\_jffs2 find jffs2 partition and mount it, indicating result rootfs\_pivot if jffs2 mounted, make it root (/) and old root (squashfs) /rom , skipping rest on success do\_mount\_no\_jffs2 If nothing was mounted so far, mount ramdisk (ram overlay), skipping rest on success do\_mount\_no\_mtd If there was nothing mounted , mount /dev/root as root (/)

Functions which are called by other functions, rather than directly as part of a hook

Function Description mount\_no\_mtd if there is not mtd partition named rootfs\_data, mount /dev/root as / (root). E.g. this can occur if the firmware filesystem is entirely a jffs2 partition, with no squashfs) mount\_no\_jffs2 mount ramdisk (ram overlay) if there is rootfs\_data, but it has not been formatted yet) find\_mount\_jffs2 find and mount rootfs\_data jffs2 partition on /jffs jffs2\_not\_mounted returns true (0) if jffs2 is not mounted

### initramfs

No files or functions at this time.

# Firstboot Operation

## Main Firstboot Script

1. Source common functions
2. Source functions for hooks
3. if block:

if invoked as executable

```
       if called with `switch2jffs` parameter (i.e. from rcS)
           run hook `switch2jffs`
       if called standalone (e.g. from commandline)
           if there is a jffs2 partition mounted
                run hook `jffs2reset`
           else
                erase rootfs_data mtd partition
                format
                and remount it
           end
       end
 if sourced (that is not executed)
      set some variables
 end
```

## Hooks

### switch2jffs

Make the filesystem that we want to be the rootfs, to be the rootfs

File Description 10\_determine\_parts deterimine\_mtd\_part, determine\_rom\_part, determine\_jffs2\_part, set\_mtd\_part, set\_rom\_part, set\_jffs2\_part 20\_has\_mini\_fo check\_for\_mini\_fo 30\_is\_rootfs\_mountedskip\_if\_rootfs\_mounted 40\_copy\_ramoverlay copy\_ramoverlay 50\_pivot with\_fo\_pivot 99\_10\_with\_fo\_cleanup with\_fo\_cleanup

Functions, in order, executed by this hook (doesn't list the functions only called by other functions)

Function Description determine\_mtd\_part exit if no mtd partition at all determine\_rom\_part exit if not squashfs partition (firstboot not for all\_jffs2) determine\_jffs2\_part figure out the jffs2 partition (assuming we have an mtd part check\_for\_mini\_fo determine if we have mini\_fo overlay in kernel. If not run \*no\_fo* hook skip\_if\_rootfs\_mounted attempt mount jffs2 on /rom/jffs2. If partition already mounted exit copy\_ramoverlay copy the data from the temporary rootfs (on the ramdisk overlay over the squashfs) to the new jffs2 partition with\_fo\_pivot make current jffs2 partition the root partition and the current root /rom with\_fo\_cleanup clean up unneeded mount of ramdisk, if possible

Functions which are called by other functions, rather than directly as part of a hook

Function Description set\_mtd\_part set variables for mtd partition set\_rom\_part set variable for squashfs (rom) partition set\_jffs\_part set variable for jffs2 partition

### no\_fo

Make the filesystem that we want to be the rootfs, to be the rootfs, given that we have no mini\\\_fo overlay filesystem

File Description 10\_no\_fo\_clear\_overlay no\_fo\_clear\_overlay 20\_no\_fo\_mount\_jffs no\_fo\_mount\_jffs 30\_no\_fo\_pivot no\_fo\_pivot 40\_no\_fo\_copy\_ram\_overlay no\_fo\_copy\_ram\_overlay 99\_10\_no\_fo\_cleanup no\_fo\_cleanup

Functions, in order, executed by this hook (doesn't list the functions only called by other functions)

Function Description no\_fo\_clear\_overlay stop ramdisk overlaying the squashfs no\_fo\_mount\_jffs attempt to mount jffs (work around problem with union). If already mounted exit no\_fo\_pivot make jffs root and old root /rom no\_fo\_copy\_ram\_overlay copy data from ram overlay to jffs2 overlay of squashfs no\_fo\_cleanup get rid of extra binds and mounts

### jffs2reset

Reset jffs2 to defaults

File Description 10\_rest\_has\_mini\_fo reset\_check\_for\_mini\_fo 20\_reset\_clear\_jffs reset\_clear\_jffs 30\_reset\_copy\_rom reset\_copy\_rom

Functions, in order, executed by this hook (doesn't list the functions only called by other functions)

Function Description reset\_check\_for\_mini\_fo Determine if the kernel supports mini\_fo overlay reset\_clear\_jffs if mini\_fo is supported, erase all data in overlay and remount (resets back to 'pure' squashfs versions reset\_copy\_rom if mini\_fo is not supported, make symlinks and copy critical files from squashfs to jffs

# Customizing the system

**NB**: These files must be added to the \*squashfs* (or if using a all\_jffs2 system, to the jffs2). That means, for instance adding it to the image's rootfs. This can be done, for instace, by creating \`${ROOTDIR}/files/filename\` (with appropriate substitutions of course).

## Overriding Example

**Warning!**  
This section describes actions that might damage your device or firmware. Proceed with care!

Customizing the system is quite simple. We give an example of changing the message for preinit from '- preinit -' to '- setting the table for dinner -'

Create a file that replaces the function \`indicate\_regular\_preinit\_boot\`. \`pi\_indicate\_preinit\` is defined in \`20\_indicate\_preinit\`, so we define our replace functions in \`25\_dinner\_not\_router\`.

\`/lib/preinit/25\_dinner\_not\_router\`

```
   pi_indicate_preinit() { 
         echo "- setting the table for dinner -"
         preinit_net_echo "Dinner is just about ready!"
         pi_indicate_led
   }
   
```

This results in the following boot log:

```
NET: Registered protocol family 17
802.1Q VLAN Support v1.8 Ben Greear <greearb@candelatech.com>
All bugs added by David S. Miller <davem@redhat.com>
VFS: Mounted root (squashfs filesystem) readonly on device 31:2.
Freeing unused kernel memory: 132k freed
Please be patient, while OpenWrt loads ...
eth1: link forced UP - 100/full - flow control off/off
- setting the table for dinner -
Press CTRL-C or Press f<ENTER> to enter failsafe mode
switching to jffs2
mini_fo: using base directory: /
mini_fo: using storage directory: /jffs
- init -
```

The default boot log is

```
NET: Registered protocol family 17
802.1Q VLAN Support v1.8 Ben Greear <greearb@candelatech.com>
All bugs added by David S. Miller <davem@redhat.com>
VFS: Mounted root (squashfs filesystem) readonly on device 31:2.
Freeing unused kernel memory: 132k freed
Please be patient, while OpenWrt loads ...
eth1: link forced UP - 100/full - flow control off/off
- preinit -
Press CTRL-C or Press f<ENTER> to enter failsafe mode
switching to jffs2
mini_fo: using base directory: /
mini_fo: using storage directory: /jffs
- init -
   
```

## Adding Example

As another example we will add a message to failsafe, between the notice that we're in failsafe mode in the shell. You could use this, for example, to create a text menu system, or to launch a simple web server (with cgi scripts) to permit the user to do failsafe things.

We want to add the message, 'Remember, at this point there are no writable filesystems'

We create the file \`50\_failsafe\_remember\_no\_rw\`, in \`/lib/preinit\`

```
  remember_no_rw() {
      echo "Remember, at this point there are no writable filesystems"
  }
  
  boot_hook_add failsafe remember_no_rw
  
```

This creates the function \`remember\_no\_rw\` and adds it to the failsafe hook, in between \`10\_indicate\_failsafe\` and \`99\_10\_failsafe\_login\` which define the other functions in the \`failsafe\` hook. This wasn't necessary for the previous example because the function was already in a hook.

The boot log for this, when entering failsafe, is:

```
VFS: Mounted root (squashfs filesystem) readonly on device 31:2.
Freeing unused kernel memory: 132k freed
Please be patient, while OpenWrt loads ...
eth1: link forced UP - 100/full - flow control off/off
- preinit -
Press CTRL-C or Press f<ENTER> to enter failsafe mode
f
- failsafe -
Remember, at this point there are no writable filesystems
```

```
BusyBox v1.15.3 (2010-01-20 19:26:26 EST) built-in shell (ash)
Enter 'help' for a list of built-in commands.
```

```
ash: can't access tty; job control turned off
```

```
  _______                     ________        __
 |       |.-----.-----.-----.|  |  |  |.----.|  |_
 |   -   ||  _  |  -__|     ||  |  |  ||   _||   _|
 |_______||   __|_____|__|__||________||__|  |____|
                |__| W I R E L E S S   F R E E D O M
```

```
 KAMIKAZE (bleeding edge, r19235) ------------------
  * 10 oz Vodka       Shake well with ice and strain
  * 10 oz Triple sec  mixture into 10 shot glasses.
  * 10 oz lime juice  Salute!
 ---------------------------------------------------
```

# Architecture-specific notes

Some architectures have additional files and functions (or overrides of the above functions) in order to accommodate specific needs of that hardware. In that case the files are located in the source tree under `$ROOTDIR/target/linux/<architecture[/subarch]/base-files/lib/preinit`. During build they are merged and appear under `/lib/preinit` along with the rest.
