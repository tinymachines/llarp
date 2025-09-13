# ksmbd

[KSMBD](https://docs.kernel.org/next/filesystems/smb/ksmbd.html "https://docs.kernel.org/next/filesystems/smb/ksmbd.html") is a server which implements SMB3 protocol in kernel space for sharing files over your network. It can be used as a [Samba](/docs/guide-user/services/nas/cifs.server "docs:guide-user:services:nas:cifs.server") alternative.

## Installation

To use ksmbd with [LuCI](/docs/guide-user/luci/start "docs:guide-user:luci:start") install `luci-app-ksmbd` which will automatically install the server and dependencies. To use ksmbd only on the command line install `ksmbd-server` and `ksmbd-tools`.

If you are sharing a USB or eSATA drive be sure to install your appropriate drivers and filesystem as outlined on the Samba [prerequisites](/docs/guide-user/services/nas/cifs.server#prerequisites "docs:guide-user:services:nas:cifs.server") section.

## Configuration

In LuCI, go to Services → Network Shares. Here you can assign an interface, name the shares, set a path to drive folder (e.g. /mnt/sda1), set allowed users, etc.

For command line, the UCI configuration file is located at `/etc/config/ksmbd`. Some options are hardcoded in the `/etc/ksmbd/ksmb.conf.template`.

### Example

This example assumes you have a [block device](/docs/guide-user/storage/fstab "docs:guide-user:storage:fstab") attached on `/mnt/sda1` (typical Linux/OpenWrt mount points).  
Multiple devices and shares may be added by providing a `config share` section with a name and mount location for each.

To access storage anonymously over the LAN using the `nobody/nogroup` user, first assign ownership for all files and directories at these mounting points to that user:

```
chown -R nobody:nogroup /mnt/sda1
```

To access a shared storage over the LAN using a **username** and **password**, login via SSH and use the `ksmbd.adduser` command. The file `/etc/ksmbd/ksmbdpwd.db` will be created.

Be sure to enter that username in the Allowed users box in the LuCI Services → Network Shares page.

```
root@OpenWrt:~# ksmbd.adduser --help
Usage: ksmbd.adduser [-v] [-P PWDDB] [-c CONF] [-a | -u | -d] [-p PWD] USER

If neither `-a', `-u', nor `-d' is given, either add or update USER.
USER must be UTF-8 and [1, 48) bytes.
USER cannot contain colon (`:').

  -a, --add             add USER to user database
  -u, --update          update USER in user database
  -d, --delete          delete USER from user database
  -p, --password=PWD    use PWD as user password instead of prompting;
                        PWD must be UTF-8 and [0, 129) bytes
  -P, --pwddb=PWDDB     use PWDDB as user database instead of
                        `/etc/ksmbd/ksmbdpwd.db'
  -C, --config=CONF     use CONF as configuration file instead of
                        `/etc/ksmbd/ksmbd.conf'
  -v, --verbose         be verbose
  -V, --version         output version information and exit
  -h, --help            display this help and exit

See ksmbd.adduser(8) for more details.
```

Configure shares in LuCI → Services → Network Shares or by editing `/etc/config/ksmbd`:

```
config globals
	option workgroup 'WORKGROUP'
	option description 'Ksmbd on OpenWrt'
	option interface 'lan'

config share
	option name 'ssd'
	option path '/mnt/sda1'
	option read_only 'no'
	option guest_ok 'yes'
	option create_mask '0666'
	option dir_mask '0777'
```

or the above config will look similar to this when allowed users have been added

```
config globals
	option workgroup 'WORKGROUP'
	option description 'Ksmbd on your_router_name'

config share
	option name 'router-USB1'
	option path '/mnt/sda1'
	option read_only 'no'
	option guest_ok 'no'
	option create_mask '0666'
	option dir_mask '0777'
	option users 'user1'
```

On devices with sufficient RAM (&gt;256MB) performance can be improved, increase or comment out the preset buffer limits in LuCI → Services → Network Shares → Edit Template. Save and apply.  
As of [commit 25519](https://github.com/openwrt/packages/pull/25519 "https://github.com/openwrt/packages/pull/25519") these values are now adjusted automatically when running main snapshot builds.  
For versions 24.10 and below you can edit the template and simply comment out the 5 lines accordingly.

```
	#smb2 max read = 512K
	#smb2 max write = 512K
	#smb2 max trans = 512K

	32 ~ 64MB RAM, set the value to 64K
	64 ~ 128MB, set it to 128KB
	128 ~ 256MB, set it to 1MB
	More than 256MB leave default size to 4MB

	With 64MB and 128MB it is better also to disable the read/write cache
	#cache read buffers = no
	#cache write buffers = no
```

## Global section

The `globals` section contains share-independent options.

Name Type Required Default Description `workgroup` string no `WORKGROUP` Workgroup name `description` string no `Ksmbd on OpenWrt` Server description `allow_legacy_protocols` boolean no `0` Enables support for **insecure** versions of SMB3 protocol

## Share sections

Name Type Required Default Description `name` string yes *(none)* Share name that will be displayed in a file browser `path` string yes *(none)* Directory path `comment` string no *(none)* `users` string no *(none)* `create_mask` number no *(none)* `chmod` mask for created files `dir_mask` number no *(none)* `chmod` mask for created directories `browseable` string no *(none)* `read_only` string no *(none)* `writeable` string no *(none)* `guest_ok` string no *(none)* `force_root` boolean no *(none)* `write_list` string no *(none)* `read_list` string no *(none)* `users` string no *(none)* `hide_dot_files` string no *(none)* `veto_files` string no *(none)* `inherit_owner` string no *(none)* `force_create_mode` string no *(none)* `force_directory_mode` string no *(none)*
