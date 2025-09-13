# SSHFS client

## SSHFS (Secure SHell FileSystem)

```
Package: sshfs
Version: 2.2-1
Depends: libfuse, fuse-utils, glib2, libpthread
Provides:
Status: unknown ok not-installed
Section: net
Architecture: ar71xx
Maintainer: OpenWrt Developers Team <openwrt-devel@openwrt.org>
MD5Sum: 6cdaa98ff2009b474db3f536fd34e81b
Size: 20929
Filename: sshfs_2.2-1_ar71xx.ipk
Source: feeds/packages/net/sshfs
Description: Mount remote system over sftp.
```

```
mkdir /mnt/internet
sshfs user@host:/remote/dir /mnt/internet
```

[manpage of sshfs](http://linux.die.net/man/1/sshfs "http://linux.die.net/man/1/sshfs")

## shfs

- shfs / shfsmount are quite old (ca. 2004) alternatives to sshfs.
- shfs is not available as openwrt package.

```
shfsmount -P 2222 user@host /mnt/shfs
```

To specify another ssh option:

```
shfsmount --cmd="ssh -c blowfish %u@%h /bin/bash" user@host:/tmp /mnt/shfs/
```

To make mount survive temporary connection outage (reconnect mode):

```
shfsmount --persistent user@host /mnt/shfs
```

Longer transfers? Increase cache size (1MB cache per file):

```
shfsmount user@host /mnt/shfs -o cachesize=256
```

To enable symlink resolution:

```
shfsmount -s user@host /mnt/shfs
```

To preserve uid (gid) (NFS replace mode ![:-)](/lib/images/smileys/smile.svg)):

```
shfsmount root@host /mnt/shfs -o preserve,rmode=755
```

To see what is wrong (forces kernel debug output too):

```
shfsmount -vvv user@host /mnt/shfs
```

Mount without password using identity file

```
shfsmount --cmd="ssh -i /identity/file/path %u@%h /bin/bash" user@host:/tmp /mnt/shfs/
```

getting warning: ssh nodelay workaround disabled?

sshfs does not handle the certificate negotiation, so you have to

```
ssh user@host 
The authenticity of host '[host] ([00.00.00.00])' can't be established.
RSA key fingerprint is b3:b2:4f:53:bc:b9:40:c4:48:af:7a:a5:a3:1a:3f:51.
Are you sure you want to continue connecting (yes/no)?
answer with y(es) here
```

See [http://shfs.sourceforge.net/](http://shfs.sourceforge.net/ "http://shfs.sourceforge.net/") for further details.
