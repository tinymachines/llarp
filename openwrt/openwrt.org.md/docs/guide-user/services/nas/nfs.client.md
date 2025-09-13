# NFS client

## Core Packages

**nfs-utils** Updated mount.nfs command - allows mounting nfs4 volumes

**kmod-fs-nfs** Kernel module for NFS support

**kmod-fs-nfs-common** Common NFS filesystem modules

## Filesystem Support

For NFSv4 server → install **kmod-fs-nfs-v4** For NFSv3 server → install **kmod-fs-nfs-v3**

## Opkg Setup

```
opkg update
opkg install nfs-utils kmod-fs-nfs kmod-fs-nfs-v4 kmod-fs-nfs-v3
```

**WARNING:** The librpc is missing in some versions. You can safely use `-force-depends` if it happens to you Note that to use `mount -t cifs`, NFS mount support in busybox has to be enabled.

### Configuration

```
mkdir /mnt/remote2
mount.nfs //192.168.2.254/router_main /mnt/remote2 [-rvVwfnh ] [-t version] [-o options]
```

```
mount -t nfs 192.168.1.101:/share /mnt/point -o nolock
```

```
# To connect using NFSv4
mount -t nfs4 192.168.1.101:/share /mnt/point -o nolock
```

```
# For Fedora 17+ servers, which are nfs4 out of the box...
mount -t nfs 192.168.255.124:/home/karlp/src src -o nfsvers=3 -o nolock
```

The `nolock` will disable NFS file locking. If you really need file locking, you must install the **`portmap`** package and start the `portmap daemon` before trying to mount an exported filesystem without the `nolock` option.

In some revisions mounting is not possible because default disabled in kernel: BUSYBOX\_CONFIG\_FEATURE\_MOUNT\_NFS \[=n]

Read [manpage of mount.nfs](http://linux.die.net/man/8/mount.nfs "http://linux.die.net/man/8/mount.nfs")

Put it in `/etc/fstab`.

## Troubleshooting

Append -v to your mount command to see detailed debugging info... i.e.;

```
mount -t nfs 192.168.1.101:/share /mnt/point -o nolock  -v
```

### Throughput Issues

Since [netfilter](/docs/guide-user/firewall/netfilter-iptables/netfilter "docs:guide-user:firewall:netfilter-iptables:netfilter") will track every connection, if you use MASQUERADING for example, you could disable con-tracking for data connections:

```
$IPT -t raw -A PREROUTING -i $IF_LAN -s $NET_LAN -p tcp --sport 32777:32780 -j CT --notrack #---------- don't track nfs
$IPT -t raw -A PREROUTING -i $IF_LAN -s $NET_LAN -p udp --sport 32777:32780 -j CT --notrack #---------- don't track nfs
$IPT -t raw -A OUTPUT -o $IF_LAN -d $NET_LAN -p tcp --dport 32777:32780 -j CT --notrack #---------- don't track nfs
$IPT -t raw -A OUTPUT -o $IF_LAN -d $NET_LAN -p udp --dport 32777:32780 -j CT --notrack #---------- don't track nfs
```

Note this is not the same as for the server, the source and destination ports differ. The INPUT is for when you read from the remote filesystem and the OUTPUT for when you write to it.
