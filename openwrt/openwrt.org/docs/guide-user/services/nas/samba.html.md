# Samba Advanced Settings

For installation instructions see [Samba How To](/docs/guide-user/services/nas/cifs.server "docs:guide-user:services:nas:cifs.server")

## UCI configuration options

The UCI configuration file is located at /etc/config/samba. Be extremely careful editing this file by hand - the samba shell interface (`service samba restart`) will ignore invalid options, but LuCI Services/Network Shares will bring up an error like this:

```
/usr/lib/lua/luci/dispatcher.lua:449: Failed to execute cbi dispatcher target for entry '/admin/services/samba'.
```

![:!:](/lib/images/smileys/exclaim.svg) It is hence **strongly recommended** that you use LuCI to establish the initial configuration and then edit the template file (/etc/samba/smb.conf.template) via LuCI Edit Template tab or from the shell as needed.

If luci-app-samba not working or can't find in web gui - &gt; type “rm /tmp/luci-indexcache” or restart router.

### Common Options

The config section type `samba` determines values and options relevant to the overall operation of samba. The following table lists all available options, their default value and respectively a short characterization. See [smb.conf man page](http://www.samba.org/samba/docs/man/manpages-3/smb.conf.5.html#idp58030944 "http://www.samba.org/samba/docs/man/manpages-3/smb.conf.5.html#idp58030944") for further details.

These are the default settings for the common options:

```
config 'samba'
        option 'name' 'OpenWrt'
        option 'workgroup' 'OpenWrt'
        option 'description' 'Samba on OpenWrt'
        option 'charset' 'UTF-8'
        option 'homes' '0'
        option 'interface' 'loopback lan'
```

Name Type Required Default Option Description `name` string no hostname or OpenWrt Name of the Server `workgroup` string no hostname or OpenWrt Name of the Workgroup `description` string no Samba on hostname or OpenWrt Description of the Server `charset` string no UTF-8 Display charset &amp; unix charset `homes` boolean no 0 0, 1 Share the user directory `interface` string no loopback lan Interfaces samba should listen on. Syntax: “&lt;uci-interface-name&gt; &lt;uci-interface-name&gt; ...”. Note, that it is *not* of type list.

### Sambashare

The daemons are up and running and recheable via NetBIOS. Now you only need to configure the directories you intend to make accesible to users in your LAN. This example assumes you attached a USB harddisk to the USB-Port and *correctly* mounted a partition. You can now choose to share the partition as a whole, or just individual directories on it. Fo each entry you need to create an individual config 'sambashare' section.

```
config 'sambashare'
        option 'name' 'Shares'
        option 'path' '/mnt/sda3'
#       option 'users' 'sandra'
        option 'guest_ok' 'yes'
        option 'create_mask' '0700'
        option 'dir_mask' '0700'
        option 'read_only' 'yes'
```

Name Type Required Default Option Description `name` string yes *(none)* Name of the entry. Will be shown in the filebrowser. `path` file path yes *(none)* The complete path of the directory. [path](http://www.samba.org/samba/docs/man/manpages-3/smb.conf.5.html#PATH "http://www.samba.org/samba/docs/man/manpages-3/smb.conf.5.html#PATH") `users` string no guest account or from global template the samba-users allowed access to this entry; use `smbpasswd` to create a user-pwd combination! Several users can be specified, separated by a coma (ex : option 'users' 'root,nobody' ). Translated to [valid users](http://www.samba.org/samba/docs/man/manpages-3/smb.conf.5.html#VALIDUSERS "http://www.samba.org/samba/docs/man/manpages-3/smb.conf.5.html#VALIDUSERS"). `read_only` string no yes or from global template no, yes no allows for read/write, else only read access is granted; (for rw, you also need to mount fs rw!). [read only](http://www.samba.org/samba/docs/man/manpages-3/smb.conf.5.html#READONLY "http://www.samba.org/samba/docs/man/manpages-3/smb.conf.5.html#READONLY"). `guest_ok` string no no or from global template no, yes Specifies if you need to login via samba-username and password to access this share. [guest ok](http://www.samba.org/samba/docs/man/manpages-3/smb.conf.5.html#GUESTOK "http://www.samba.org/samba/docs/man/manpages-3/smb.conf.5.html#GUESTOK"). `create_mask` integer no 0744 or from global template chmod mask for files created (need write access). [create mask](http://www.samba.org/samba/docs/man/manpages-3/smb.conf.5.html#CREATEMASK "http://www.samba.org/samba/docs/man/manpages-3/smb.conf.5.html#CREATEMASK") `dir_mask` integer no 0755 or from global template chmod mask for directories created (need write access). [directory mask](http://www.samba.org/samba/docs/man/manpages-3/smb.conf.5.html#DIRECTORYMASK "http://www.samba.org/samba/docs/man/manpages-3/smb.conf.5.html#DIRECTORYMASK").

## Additional Configuration Options

### Common Options

In addition to the UCI file (`/etc/config/samba`), modifications can be made to the `/etc/samba/smb.conf.template` file.

### Sambashare

Modifications can be made to the `/etc/samba/smb.conf.template` file, based on `/var/etc/smb.conf` file, created by the `samba` service.

The full section from `/var/etc/smb.conf` should be added to `/etc/samba/smb.conf.template` and removed from UCI.

For example:

```
uci show samba | grep name
samba.@sambashare[0].name=over9000
sed -e '/\[over9000\]/,/^$/ !d' /var/etc/smb.conf >> /etc/samba/smb.conf.template
uci delete samba.@sambashare[0]
uci commit samba
service samba restart
```

In a second approach the `samba` service could also be edited for spit whatever to `/var/etc/smb.conf` associated with UCI.

For example, hack once:

```
sed -i -e '/dir_mask/p;s/dir_mask\|directory mask/browsable/g' /etc/init.d/samba
```

Then, anytime:

```
uci show samba | grep name
samba.@sambashare[0].name=over9000
uci set samba.@sambashare[0].browsable=no
uci commit samba
service samba restart
cat /var/etc/smb.conf
```

## Configuration examples

Samba can be configured at either share level access or user level access. At share level access all users on the network can access the share, and all files are shared with all users. At user level access a username and password are needed to access the share. By default Samba is configured for user level access.

These configurations have proven to work for some:

### Share level access

At share level access all users on the network can access the share, and all files are shared with all users. To set share level access change `security = user` to `security = share` in `/etc/samba/smb.conf.template`:

```
[global]
	netbios name = |NAME| 
	workgroup = |WORKGROUP|
	server string = |DESCRIPTION|
	syslog = 10
	encrypt passwords = true
	passdb backend = smbpasswd
	obey pam restrictions = yes
	socket options = TCP_NODELAY
	unix charset = ISO-8859-1
	local master = yes
	preferred master = yes
	os level = 20
	security = share
	guest account = nobody
	invalid users = root
	smb passwd file = /etc/samba/smbpasswd
```

Then add a share to `/etc/config/samba`. Make sure that `guest ok` is set to `yes`

```
config 'samba'
	option 'name' 'openwrt'
	option 'workgroup' 'WORKGROUP'
	option 'description' 'openwrt'
	option 'homes' '1'
 
config 'sambashare'
	option 'read_only' 'no'
	option 'create_mask' '0700'
	option 'dir_mask' '0700'
	option 'name' 'name-of-share'
	option 'path' '/path/of/share'
	option 'guest_ok' 'yes'
```

This share should now be accessible by `\\ip-adress-openwrt\name-of-share` (windows, username and password can be anything).

### User level access

At user level access a username and password are needed to access the share.

Steps:

#### 1. Add user to system

To access a samba share with user level access there must be a user added to the system. Edit `/etc/passwd` and add a line for the new user “foo”. Choose a user id (the first number in the line) of 1000 or higher that does not exist yet.

```
root:!:0:0:root:/root:/bin/ash
nobody:*:65534:65534:nobody:/var:/bin/false
daemon:*:65534:65534:daemon:/var:/bin/false
foo:x:1001:1001:smb user:/dev/null:/bin/false
```

Edit `/etc/group` and add a line for the new user “foo”.

```
root:x:0:
nogroup:x:65534:
daemon:x:1:
foo:x:1001:foo
```

**Note:** keep in mind that the user(s) and group(s) utilized by Samba need to have the proper permissions for their shares, i.e. they need write access in order to write via smb.

#### 2. Add samba password to user

`smbpasswd -a foo`

#### 3. Change samba config to accept users with null passwords

Edit `/etc/samba/smb.conf.template` and add `null passwords = yes`:

```
[global]
	netbios name = |NAME| 
	workgroup = |WORKGROUP|
	server string = |DESCRIPTION|
	syslog = 10
	encrypt passwords = true
	passdb backend = smbpasswd
	obey pam restrictions = yes
	socket options = TCP_NODELAY
	unix charset = ISO-8859-1
	local master = yes
	preferred master = yes
	os level = 20
	security = user
	null passwords = yes
	guest account = nobody
	invalid users = root
	smb passwd file = /etc/samba/smbpasswd
```

#### 4. Add a share

Then add a share to `/etc/config/samba`. Make shure that `guest ok` is set to `no`

```
config 'samba'
	option 'name' 'openwrt'
	option 'workgroup' 'WORKGROUP'
	option 'description' 'openwrt'
	option 'homes' '1'
 
config 'sambashare'
	option 'read_only' 'no'
	option 'create_mask' '0700'
	option 'dir_mask' '0700'
	option 'name' 'name-of-share'
	option 'path' '/path/of/share'
	option 'guest_ok' 'no'
```

This share should now be accessible by `\\ip-adress-openwrt\name-of-share` (windows, correct username and password are needed).

## Notes

If you use a trunk version and experience connection aborts take a look at this file `/etc/samba/samba.conf.template` and search for `reset on zero vc = yes`, remove this line or set it to `no`.

More information about this issue here: [https://dev.openwrt.org/ticket/9992](https://dev.openwrt.org/ticket/9992 "https://dev.openwrt.org/ticket/9992")

If your CPU is your samba bottleneck, disabling sendfile might help. See [http://www.linksysinfo.org/index.php?threads/speeding-up-the-samba-by-30.52240/](http://www.linksysinfo.org/index.php?threads%2Fspeeding-up-the-samba-by-30.52240%2F "http://www.linksysinfo.org/index.php?threads/speeding-up-the-samba-by-30.52240/")
