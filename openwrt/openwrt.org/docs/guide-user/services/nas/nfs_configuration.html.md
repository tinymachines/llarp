# NFS share configuration

The [Network File System](https://en.wikipedia.org/wiki/Network%20File%20System "https://en.wikipedia.org/wiki/Network File System") is a fast and light way to share files over an internal LAN with Linux (on PC or in embedded devices like smart TVs and media centers), Unix and macOS clients. Depending on your needs, you may want to use [Samba](/docs/guide-user/services/nas/samba_configuration "docs:guide-user:services:nas:samba_configuration") or the SSH filesystem too or instead.

In this tutorial we will create the following setup: NFS shares available to devices in LAN. NFS will create a “virtual” root on the exported filesystem, this prevents users from manipulating files outside of the shared folder. (fsid=root) NFS won't be checking if accessed tree of dirs is in the NFS filesystem because above option makes sure they can't get out of it anyway (no\_subtree\_check, default option so we don't need to write this in the config) NFS treats all users who access this disk's contents (create, read, modify, delete) as anonymous. (all\_squash) NFS replies to requests before any changes made by that requests have been committed to the storage (async) NFS allows access from clients that don't use a reserved port for NFS (insecure)

## Installation

In the tutorial we assume that you have already set up the storage system with the folder you want to share with nfs, if you didn't do that yet, please do it before proceeding.  
Note that for this to work you will need to change read/write permissions to the folder you are sharing.  
`chmod -R a+rw /mnt/share`

Optimal way would be to change the group of the folder to “users” and have r/w added only to the group, or anyway use the POSIX user/group ownerships.  
For most users a single free-for-all share like this is enough, so for now it will stay like this.

We will now need to set up the firewall to open ports needed by this service.

The *portmap* service uses port 111 on both TCP and UDP, *nfsd* standard are ports between 32777 and 32780 on both TCP and UDP.

These ports are opened automatically on LAN when you install the packages. You can check yourself with `netstat -an`

### OpenWrt server

Install **nfs-kernel-server** metapackage, it will pull down all other needed packages for you.

```
opkg update
opkg install nfs-kernel-server
```

![:!:](/lib/images/smileys/exclaim.svg) **NOTE:** You may need to install **kmod-loop** to fix “mount: can't setup loop device: No such file or directory” errors. (see [https://dev.openwrt.org/ticket/11541](https://dev.openwrt.org/ticket/11541 "https://dev.openwrt.org/ticket/11541"))

### OpenWrt client

WIP (should work the same as with most linux, once you install the packages for the client)

### PC client

Most Linux distributions support NFS without need to install anything, or provide pre-configured NFS clients as installable packages. In case your distribution is missing support, you need to install the client software. Arch Linux wiki is a good starting point: [https://wiki.archlinux.org/index.php/NFS](https://wiki.archlinux.org/index.php/NFS "https://wiki.archlinux.org/index.php/NFS"). macOS also supports NFS natively.

For Windows it's a bit more complex as you may or may not have it depending on Windows version and type, also the native one does not really perform that well. [JFtp](http://j-ftp.sourceforge.net "http://j-ftp.sourceforge.net") is a third party client, but there are probably others too. Quite frankly, if you want to share files with Windows it's far better to set up Samba instead.

## Server configuration

Use the file `/etc/exports` to configure your shares. These are the default contents:

```
/mnt    *(ro,all_squash,insecure,sync)
```

This is what you should write in it if you have a shared folder in /mnt/share

```
/mnt/share    *(rw,all_squash,insecure,sync)
```

First goes the path of the shared folder, (/mnt).  
Then goes the IP list of clients (in this case * as any IP is accepted)  
Then there is a list of options for this share, that are nfs options you can read in the [nfs manpage](https://linux.die.net/man/5/exports "https://linux.die.net/man/5/exports")

Here is another example, showing how you can write IPs and their netmasks:

```
/mnt/sda2   192.168.1.2,192.168.1.3,192.168.1.4(ro,sync)
/mnt/sda3   192.168.1.2(rw,sync)
/mnt/sda4   192.168.1.0/255.255.255.0(rw,sync)
/mnt/sda5 192.168.1.0/24(rw,sync)
```

If you set up extroot on an nfs share, use the path on /overlay/ partition, else you cannot export the mounted fs.

When NFS services are already running, use the command **service nfsd reload** to reload and apply changes on the fly.

#### Start on boot

NFS services are usually enabled and started on installation, verify with `top` or `ps` whether the services are running.  
The following entries should appear in the process list:

```
/usr/sbin/rpc.mountd -p 32780    
/usr/sbin/rpc.statd -p 32778 -o 32779
/usr/sbin/portmap
```

in case they are not then you need to do this manually.

```
root@LEDE:~# service portmap start && service portmap enable
root@LEDE:~# service nfsd start && service nfsd enable
```

Use the `netstat -l` command to see whether *portmap* is listening on port 111 for both tcp and udp. The *nfsd* process may use varying ports.

### Client configuration

#### Linux client

Mount manually:

```
sudo mount 192.168.1.1:/mnt/share /home/alby/nfs_share
```

Or mount permanently with entries in the `/etc/fstab` on each client PC:

```
192.168.1.1:/mnt/sda2 /media/LEDE          nfs  ro,async,auto  0  0
192.168.1.1:/mnt/sda4 /media/remote_stuff  nfs  rw,async,auto  0  0
```

Check the [Arch Wiki](https://wiki.archlinux.org/index.php/NFS#Tips_and_tricks "https://wiki.archlinux.org/index.php/NFS#Tips_and_tricks") for more info. ![:!:](/lib/images/smileys/exclaim.svg) **WARNING:** If you are using a Linux distro with **systemd** init system (Debian/Unbuntu/Arch/OpenSUSE/Fedora/CentOS and derivatives, most major distros use it) always place “nofail” in nfs mount options. This will tell systemd that this partition isn't critical for boot so your PC will start up fine even if the NFS share is unavailable. If you don't add this option and the NFS share isn't available on boot, your PC will not start up ***at all*** and you will have to use a Linux live-cd to go and fix the fstab entry.

With portmap running on your OpenWrt-Machine you can use `rpcinfo -p 192.168.1.254` on clients side to see open ports.

#### macOS client

[This is a tutorial](https://www.cyberciti.biz/faq/apple-mac-osx-nfs-mount-command-tutorial/ "https://www.cyberciti.biz/faq/apple-mac-osx-nfs-mount-command-tutorial/") There are many other tutorials if you search on the net.

#### Windows client

Java client: [JFtp](http://j-ftp.sourceforge.net "http://j-ftp.sourceforge.net").

Native client is avalible only for some editions of windows, including:

- Windows 7 Ultimate and Enterprise
- Windows 8 Enterprise
- Windows 10 Pro and Enterprise
- Windows Server 2008 R2 and up

The NFS Services is turned off by default. You have to enable them on **Start &gt; Control Panel &gt; Programs &gt; Turn Windows features on or off &gt; Services for NFS**. Then you could map the network drives on My Computer.

Step by Step guide available [here](https://graspingtech.com/mount-nfs-share-windows-10/ "https://graspingtech.com/mount-nfs-share-windows-10/") or [here](https://maprdocs.mapr.com/51/DevelopmentGuide/c-mounting-nfs-on-a-windows-client.html "https://maprdocs.mapr.com/51/DevelopmentGuide/c-mounting-nfs-on-a-windows-client.html").

## Problems

If the loopback device support is missing, an error like “*Cannot register service: RPC: Timed out*” may appear. Installing the **kmod-loop** package should solve this issue.

## Performance / Tuning

number of threads usable by nfsd can be increased by echo X &gt; /proc/fs/nfsd/threads

Max block size can be changed similar way, it's here /proc/fs/nfsd/max\_block\_size

Client-side you can add these mount options async,rsize=XXX,wsize=XXX,noatime

rsize and wsize specify the size of read and writes, increasing or decreasing them can make a difference, depending on network configuration. Max size is stated in /proc/fs/nfsd/max\_block\_size and is 16384 bytes (16 KiB) in a default install.

### Throughput issues

Since netfilter will track every connection, if you use MASQUERADING for example, you could disable con-tracking for data connections by adding this in your */etc/firewall.user*:

```
IPT=iptables
NET_LAN=192.168.1.1/24
IF_LAN=eth0
 
$IPT -t raw -A PREROUTING -i $IF_LAN -s $NET_LAN -p tcp --dport 32777:32780 -j CT --notrack #---------- don't track nfs
$IPT -t raw -A PREROUTING -i $IF_LAN -s $NET_LAN -p udp --dport 32777:32780 -j CT --notrack #---------- don't track nfs
$IPT -t raw -A OUTPUT -o $IF_LAN -d $NET_LAN -p tcp --sport 32777:32780 -j CT --notrack #---------- don't track nfs
$IPT -t raw -A OUTPUT -o $IF_LAN -d $NET_LAN -p udp --sport 32777:32780 -j CT --notrack #---------- don't track nfs
```
