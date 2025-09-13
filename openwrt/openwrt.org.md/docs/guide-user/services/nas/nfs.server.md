# Network File System (NFS)

The [Network File System](https://en.wikipedia.org/wiki/Network%20File%20System "https://en.wikipedia.org/wiki/Network File System") is the protocol of choice to share files over an internal Local Area Network. Depending on your needs, you may also want to use [Samba](/docs/guide-user/services/nas/samba "docs:guide-user:services:nas:samba") or the [SSH Filesystem](/docs/guide-user/services/ssh/sshfs.server "docs:guide-user:services:ssh:sshfs.server") additionally or instead.

## Preparations

Normally an OpenWrt host acting as an NFS server will have external storage attached (e.g. USB). Assuming clients access the NFS server from the LAN zone, OpenWrt's default configuration should not need any changes to the firewall to allow client access.

### Prerequisites

1. [usb-installing](/docs/guide-user/storage/usb-installing "docs:guide-user:storage:usb-installing") obtain basic support for USB.
2. [usb-drives](/docs/guide-user/storage/usb-drives "docs:guide-user:storage:usb-drives") obtain support for USB storage and mount local filesystem
3. In case you have a restrictive firewall policy applied, allow incoming flows to port 111 TCP and UDP, and 32777-32780 TCP and UDP from your LAN zone. This should already be allowed with the default OpenWrt configuration/policy. If needed, an appropriate set of firewall rules allowing all NFS traffic and protocol versions in the LAN zone looks like the following:

```
uci add firewall rule
uci set firewall.@rule[-1].name='Allow-NFS-RPC'
uci set firewall.@rule[-1].src='lan'
uci set firewall.@rule[-1].proto='tcp udp'
uci set firewall.@rule[-1].dest_port='111'
uci set firewall.@rule[-1].target='ACCEPT'
 
uci add firewall rule
uci set firewall.@rule[-1].name='Allow-NFS'
uci set firewall.@rule[-1].src='lan'
uci set firewall.@rule[-1].proto='tcp udp'
uci set firewall.@rule[-1].dest_port='2049'
uci set firewall.@rule[-1].target='ACCEPT'
 
uci add firewall rule
uci set firewall.@rule[-1].name='Allow-NFS-Lock'
uci set firewall.@rule[-1].src='lan'
uci set firewall.@rule[-1].proto='tcp udp'
uci set firewall.@rule[-1].dest_port='32777:32780'
uci set firewall.@rule[-1].target='ACCEPT'
 
uci commit firewall
service firewall restart
```

The *rpcbind* service uses port 111 on both TCP and UDP, while *nfsd* uses ports between 32777 and 32780 on both TCP and UDP. NFSv4 uses port 2049 on TCP only.

### NFS Service Setup

#### Server (OpenWrt)

To be able to export a filesystem via NFS (v2, v3 and v4 protocol versions are all supported), make sure to install both the `nfs-kernel-server` and `nfs-kernel-server-utils` packages, along with all their dependencies. This will cause the `nfsd` and `rpcbind` services to be installed and started, both of which are required to provide NFS services.

Shares are defined in `/etc/exports` in the usual manner. To verify your server is basically working for NFSv4, you can create a loopback setup, using an empty directory on **tmpfs**:

**NOTE:** This **destroys** the contents of your existing `/etc/exports` file!

```
# Create a directory and set up exports(5) to share it with the world in read/write mode
mkdir /tmp/nfsdemo/
chmod 1777 /tmp/nfsdemo/
echo '/tmp/nfsdemo/ *(rw,all_squash,insecure,no_subtree_check,fsid=0)' > /etc/exports
exportfs -ra
 
# Verify exporting worked
showmount -e localhost
 
# Mount the exported directory in another directory on the same host via NFSv4
mkdir /tmp/nfsclienttest/
mount -t nfs -o vers=4 localhost:/ /tmp/nfsclienttest/
```

At this point, you should be able to play around with various filesystem-affecting commands (`touch`, `cp`, et al.) in both `/tmp/nfstest` (the server view) and `/tmp/nfsclienttest` (the client view) to observe how state in one reflects in the other, and how the consequences of UID squashing over NFS play out.

#### Client (your PCs)

Most GNU/Linux distributions come with pre-installed support for NFS - if yours does not, please refer to your distribution-specific documentation on how to install it via its package management. Most other UNIX variants like FreeBSD or macOS also come with NFS support out of the box.

Microsoft Windows features an optionally installable NFS client that supports NFSv2 and NFSv3. For more information, please take a look at the [official documentation](https://docs.microsoft.com/en-us/windows-server/storage/nfs/nfs-overview "https://docs.microsoft.com/en-us/windows-server/storage/nfs/nfs-overview") provided by Microsoft.

You can also use the Java-based [JFtp](http://j-ftp.sourceforge.net "http://j-ftp.sourceforge.net") as an alternative client that does not require any OS-level support for NFS.

## Configuration

We have a typical client &lt;&lt;&gt;&gt; server configuration.

### Server configuration

Use the file `/etc/exports` to configure your shares. NFSv4 export paths don't work the way they did in NFSv3. NFSv4 has a global root directory (configured as `fsid=0`) and all exported directories are children to it. So what would have been `nfs-server:/export/users` on NFSv3 is `nfs-server:/users` on NFSv4, because `/export` is the root directory. Example:

```
/mnt        *(fsid=0,ro,sync,no_subtree_check)
/mnt/sda1   192.168.1.0/24(rw,sync,no_subtree_check)
/mnt/sda2   192.168.2.0/255.255.255.0(rw,sync,no_subtree_check)
```

See [exports(5)](https://linux.die.net/man/5/exports "https://linux.die.net/man/5/exports") for configuration semantics. A single asterisk matches all IP addresses/hosts (allowing anonymous access).

If you set up pivot-root or pivot-overlay, use the path on /overlay/ partition, else you cannot export mounted fs.

NOTE that on OpenWrt 21.02+, it's required to explicitly specify a unique `fsid` (integer between 1–255) for *all* shares, not just the NFS root directory. See [issue #17234](https://github.com/openwrt/packages/issues/17234 "https://github.com/openwrt/packages/issues/17234") for further details.

Assuming the daemons are already running, use the command `exportfs -ar` to reload and apply changes on the fly.

#### Troubleshooting

If you have trouble getting the NFS server on your OpenWrt host to work, use the `netstat -nlpu | grep rpcbind` command to see whether *rpcbind* is actually listening on port 111 for both tcp and udp. Check if the process table contains `[nfsd]` kernel threads and instances of `rpcbind`, `rpc.statd`, and `rpc.mountd`.

With the `rpcbind` service running on your OpenWrt device, you can use `rpcinfo -p 192.168.1.254` (substituting its actual IP address) on clients to see open/mapped ports.

### Client configuration

#### Linux-Client

Mount manually:

```
sudo mount 192.168.1.254:/sda1 /home/sandra/nfs_share
```

Or mount permanently with entries in the `/etc/fstab` on each client PC:

```
192.168.1.254:/sda1 /media/openwrt       nfs  ro,async,auto,_netdev  0  0
192.168.1.254:/sda2 /media/remote_stuff  nfs  rw,async,auto,_netdev  0  0
```

Check the manual for [mount](http://linux.die.net/man/8/mount "http://linux.die.net/man/8/mount") and take a particular look at the options. Choose wisely.

On distributions using systemd, [systemd mount units](https://www.freedesktop.org/software/systemd/man/systemd.mount.html "https://www.freedesktop.org/software/systemd/man/systemd.mount.html") are an optional and potentially more robust alternative to fstab entries.

## Problems

If the loopback device support is missing, an error like “*Cannot register service: RPC: Timed out*” may appear. Installing the kmod-loop package should solve this issue.

### Throughput Issues

Since [netfilter](/docs/guide-user/firewall/netfilter-iptables/netfilter "docs:guide-user:firewall:netfilter-iptables:netfilter") will track every connection, if you use MASQUERADING for example, you could disable con-tracking for data connections:

```
$IPT -t raw -A PREROUTING -i $IF_LAN -s $NET_LAN -p tcp --dport 32777:32780 -j CT --notrack #---------- don't track nfs
$IPT -t raw -A PREROUTING -i $IF_LAN -s $NET_LAN -p udp --dport 32777:32780 -j CT --notrack #---------- don't track nfs
$IPT -t raw -A OUTPUT -o $IF_LAN -d $NET_LAN -p tcp --sport 32777:32780 -j CT --notrack #---------- don't track nfs
$IPT -t raw -A OUTPUT -o $IF_LAN -d $NET_LAN -p udp --sport 32777:32780 -j CT --notrack #---------- don't track nfs
```
