# CIFS Client

## Description

[Common Internet File System (CIFS)](https://en.wikipedia.org/wiki/Server%20Message%20Block "https://en.wikipedia.org/wiki/Server Message Block") allows you to mount networked drives. You'll need a Internet connection for downloading the packages and a computer with CIFS/SAMBA server with some shares.

![](/_media/meta/icons/tango/dialog-information.png) ***`Note1`:*** cifs mount is not compatible with luci (see [#10366](https://dev.openwrt.org/ticket/10366 "https://dev.openwrt.org/ticket/10366"))  
***`Note2`:*** In [r31584](https://dev.openwrt.org/changeset/31584 "https://dev.openwrt.org/changeset/31584") the package `cifsmount` was replaced with `cifs-utils`

#### Packages

- **kmod-fs-cifs** Package is required for the actual mounting of cifs drives.
- **cifsmount** contains a helper program **mount.cifs** which can be used instead of **mount -t cifs** command. Personal note: On Backfire 10.03.1-rc6, I observed that cifsmount is necessary (in addition to kmod-fs-cifs). “mount -t cifs” fails without cifsmount.
- **kmod-nls-utf8** [Native language support](https://en.wikipedia.org/wiki/Native%20language%20support "https://en.wikipedia.org/wiki/Native language support")-Package is required for anonymous/guest access to cifs mounts. Otherwise, “mount error 83 = Can not access a needed shared library” results.

## Install

##### Required

```
opkg install kmod-fs-cifs kmod-nls-base
```

##### Optional

```
opkg install kmod-nls-utf8 kmod-crypto-hmac kmod-crypto-md5 kmod-crypto-misc cifsmount
```

Note: kmod-crypto-misc for md4-hash algorithm --- *ivang 2011/11/06 22:12*

## Examples

Options required for a successful mount vary by kernel version. Newer kernels require more options for a successful mount.

Example of authenticated share with options, kernel 3.14+

```
mount -t cifs //cifs-server/share /mnt -o username=admin,password=pwpwpw,sec=ntlm,file_mode=0644,unc=\\\\cifs-server\\share
```

Basic example of authenticated share (no options, may work with old kernels)

```
mount -t cifs //cifs-server/share /localfolder -o user=username,password=password
```

Same as above, but specifies more options

```
mount -t cifs //cifs-server/share /localfolder -o unc=\\\\cifs-server\\share,ip=IP-Address,user=john,pass=doe,dom=workgroup
```

Anonymous or guest share mounting, current 3.14+ kernels:

```
mount -t cifs //cifs-server/share /mnt/share -o user=,file_mode=0777,dir_mode=0777,unc=\\\\cifs-server\\share
```

Anonymous or guest share mounting, old version.

```
mount -t cifs '\\cifs-server\share' /localfolder -o guest,iocharset=utf8,file_mode=0777,dir_mode=0777,nounix,noserverino
```

Anonymous or guest share mounting. If you have a problems with mounting CIFS with Anonymous or guest share try this. Its known bug/issue on kernel 3.8.x.

```
mount.cifs //cifs-server/share /localfolder -o guest,sec=ntlm
```

And for fstab.

```
//wndr4300/extroot /mnt cifs username=root,password=72587258,sec=ntlm,file_mode=0777	 0	 0
```

Another example for fstab

```
//cifs-server/share /localfolder cifs credentials=/etc/samba_pswds_my_share,_netdev,uid=user,gid=group 0 0
```

where credentials file (chmod 0700) is formatted as

```
username=shareuser
password=sharepassword
```

If the **cifsmount** package is installed the **mount.cifs** can be used be instead of **mount -t cifs**.

Check [manpage of mount.cifs](http://linux.die.net/man/8/mount.cifs "http://linux.die.net/man/8/mount.cifs")

Note: if you face the error “Value too large for defined data type”, use the option “nounix,noserverino” as per Samba FAQ

### Throughput Issues

Since [netfilter](/docs/guide-user/firewall/netfilter-iptables/netfilter "docs:guide-user:firewall:netfilter-iptables:netfilter") will track every connection, if you use MASQUERADING for example, you could disable conntrack'ing for data connection:

```
$IPT -t raw -A OUTPUT -o $IF_LAN -s $IP_LAN -p tcp --dport 139 -j CT --notrack #------------------ don't track SMB
$IPT -t raw -A OUTPUT -o $IF_LAN -s $IP_LAN -p tcp --dport 445 -j CT --notrack #------------------ don't track SMB
$IPT -t raw -A PREROUTING -o $IF_LAN -s $IP_LAN -p tcp --sport 139 -j CT --notrack #------------------ don't track SMB
$IPT -t raw -A PREROUTING -o $IF_LAN -s $IP_LAN -p tcp --sport 445 -j CT --notrack #------------------ don't track SMB
```

Note this is not the same as for the server, the source and destination ports differ. The INPUT is for when you read from the remote filesystem and the OUTPUT for when you write to it.
