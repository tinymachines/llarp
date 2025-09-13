# OpenWrt File System Hierarchy / Memory Usage

OpenWrt File System Hierarchy Flash Storage Partitioning (TP-Link WR1043ND) Main Memory Usage Hardware m25p80 [spi](https://en.wikipedia.org/wiki/spi "https://en.wikipedia.org/wiki/spi")0.0: m25p64 8192 KiB main memory 32 768 KiB Layer1 mtd0 ***u-boot*** 128 KiB mtd5 ***firmware*** 8000 KiB mtd4 ***art*** 64 KiB Kernel space 3828 KiB User space 28 940 KiB Layer2 mtd1 ***kernel*** 1280 KiB mtd2 ***rootfs*** 6720 KiB up to 50% 512 KiB remaining mountpoint / filesystem [overlayfs](/docs/techref/filesystems#overlayfs "docs:techref:filesystems") Layer3 1536 KiB mtd3 ***rootfs\_data*** 5184 KiB mountpoint none none /rom /overlay none /tmp /dev filesystem none none [SquashFS](/docs/techref/filesystems#squashfs "docs:techref:filesystems") [JFFS2](/docs/techref/filesystems#jffs2 "docs:techref:filesystems") none [tmpfs](/docs/techref/filesystems#tmpfs "docs:techref:filesystems") [tmpfs](/docs/techref/filesystems#tmpfs "docs:techref:filesystems")

### Mount Points

- `/` this is your entire root filesystem, it comprises `/rom` and `/overlay`. Please ignore `/rom` and `/overlay` and use exclusively `/` for your daily routines!
- `/rom` contains all the basic files, like `busybox`, `dropbear` or `iptables`. It also includes default configuration files used when booting into [OpenWrt Failsafe mode](/docs/guide-user/troubleshooting/failsafe_and_factory_reset "docs:guide-user:troubleshooting:failsafe_and_factory_reset"). It does not contain the Linux kernel. All files in this directory are located on the SqashFS partition, and thus cannot be altered or deleted. But, because we use overlay\_fs filesystem, so called *overlay-whiteout*-symlinks can be created on the JFFS2 partition.
- `/overlay` is the writable part of the file system that gets merged with `/rom` to create a uniform `/`-tree. It contains anything that was written to the router after [installation](/docs/guide-user/installation/generic.flashing "docs:guide-user:installation:generic.flashing"), e.g. changed configuration files, additional packages installed with `opkg`, etc. It is formated with JFFS2.  
  Rather than deleting the files, insert a whiteout, a special high-priority entry that marks the file as deleted. File system code that sees a whiteout entry for file F behaves as if F does not exist.
  
  ```
  #!/bin/sh
  # shows all overlay-whiteout symlinks in the directory /overlay
   
  find /overlay -type l | while read FILE
    do
      [ -z "$FILE" ] && break
      if ls -la "$FILE" 2>&- | grep -q '(overlay-whiteout)'; then
      echo "$FILE"
      fi
    done
  ```
- `/tmp` is a tmpfs-partition
  
  ```
  #!/bin/sh
  # shows current size of the tmpfs-partition mounted to /tmp
  calc_tmpfs_size() {pi_size=$(awk '/MemTotal:/ {l=10485760;mt=($2*1024);print((s=mt/2)<l)&&(mt>l)?mt-l:s}' /proc/meminfo)}}
  echo $pi_size
  ```
- `/dev` [Driver Core: devtmpfs - kernel-maintained tmpfs-based /dev](http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=2b2af54a5bb6f7e80ccf78f20084b93c398c3a8b "http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=2b2af54a5bb6f7e80ccf78f20084b93c398c3a8b")

## History

- early OpenWrt-versions: the rootfs was readonly and only NVRAM-variables could be edited
- symlink approach
- mini\_fo [r3667 add mini\_fo patches to mount\_root and firstboot](https://dev.openwrt.org/changeset/3667 "https://dev.openwrt.org/changeset/3667") and [r3669 mini\_fo works](https://dev.openwrt.org/changeset/3669 "https://dev.openwrt.org/changeset/3669") and [r3928 enabled mini\_fo by default](https://dev.openwrt.org/changeset/3928 "https://dev.openwrt.org/changeset/3928")
- overlayfs [r26209 kernel: replace mini\_fo with overlayfs for 2.6.37](https://dev.openwrt.org/changeset/26209 "https://dev.openwrt.org/changeset/26209") and [r26213 kernel: replace mini\_fo with overlayfs for 2.6.38](https://dev.openwrt.org/changeset/26213 "https://dev.openwrt.org/changeset/26213")
