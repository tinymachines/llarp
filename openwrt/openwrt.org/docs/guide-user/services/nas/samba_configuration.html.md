# Samba 3 (old version)

## Samba versions

OpenWrt supports both Samba3 and Samba4, however much of the guide below is based on the deprecated Samba3.

See the new doc page for [Samba4](/docs/guide-user/services/nas/cifs.server "docs:guide-user:services:nas:cifs.server").

## Samba server - Before you start

It's important before beginning samba setup that you get your disks sorted.

Installing filesystem support, mounting, basic os level permissions are all something Samba sits on top of.

Beginning the setup of the Samba server before mounting and verifying a working disk setup will make things much harder in the long run.

( ![FIXME](/lib/images/smileys/fixme.svg): Add links to various usb / filesystem setup guides )

see: [NTFS Tips](/docs/guide-user/storage/writable_ntfs "docs:guide-user:storage:writable_ntfs")

## 1. Mounting storage

see: [Setting up storage devices](/docs/guide-user/storage/usb-drives "docs:guide-user:storage:usb-drives")  
When done setting up your mount point, verify (e.g. with `ls /mnt` in the command line) that at least one mount point exists, before continuing.

## 2. Installing samba

To find out, if samba is already installed on your device, try to query the samba version:

```
smbd -V
```

or query opkg:

```
opkg list-installed | grep samba
```

if this fails, you have to install samba. To do so, first identify the samba version available for your installation:

```
opkg update
opkg list | grep samba
```

In our example the available version is “samba36”:

```
luci-app-samba - git-17.219.28675-9ee26ac-1 - Network Shares - Samba SMB/CIFS module
...
samba36-client - 3.6.25-6 - Samba 3.6 SMB/CIFS client
samba36-server - 3.6.25-6 - The Samba software suite is a collection of programs that implements the SMB protocol for UNIX systems, allowing 
```

Mandatory: Now install the samba server package:

```
opkg install samba36-server
```

Optional: if you need a command line samba client for debugging problems, also install:

```
opkg install samba36-client
```

Optional: If you want a simple LuCi GUI config for samba, also install:

```
opkg install luci-app-samba
```

## 3. Configuring the samba service: "config samba" section of /etc/config/samba

Usually you will not have to change defaults provided in this section. In some cases, you may want to adapt the “interface” parameter, in case the samba service should listen on different interfaces.

This config section determines values and options relevant to the overall operation of samba. The following table lists all available options, their default value and respectively a short characterization. See [smb.conf man page](http://www.samba.org/samba/docs/man/manpages-3/smb.conf.5.html#idp58030944 "http://www.samba.org/samba/docs/man/manpages-3/smb.conf.5.html#idp58030944") for further details. These are the default settings for the common options:

```
config 'samba'
	option 'name' 'OpenWrt'
	option 'workgroup' 'OpenWrt'
	option 'description' 'Samba on OpenWrt'
	option 'charset' 'UTF-8'
	option 'homes' '0'
	option 'interface' 'loopback lan'
```

Name Type RequiredDefault OptionDescription *name* string no hostname or OpenWrt Name of the Server *workgroup* string no hostname or OpenWrt Name of the Workgroup *description*string no Samba on hostname or OpenWrt Description of the Server *charset* string no UTF-8 Display charset &amp; unix charset *homes* booleanno 0 0, 1 Share the user directory *interface* string no loopback lan Interfaces samba should listen on.

## 4. Configuring a samba share: "config sambashare" section of /etc/config/samba

SAMBA will be reachable via NetBIOS by default. In this section you need to configure the disk folders you intend to make accessible to users in your LAN. Ensure that you have already have attached a USB harddisk to the USB-Port and *correctly* mounted a partition. You can choose to share the partition as a whole, or just individual directories on it. For each entry you need to create an individual config *sambashare* section.

In the following example, the SMB sharename **Sharename** is mapped to a connected drive that is mapped to **/mnt/sda3**.

```
config 'sambashare'
	option 'name' 'Sharename'
	option 'path' '/mnt/sda3'
	option 'create_mask' '0700'
	option 'dir_mask' '0700'
	option read_only 'no'
	...
```

- Run `ls /mnt` in the command line, if you need to debug/identify your available mount points.
- you may need to adapt “create mask” and “dir mask” in case vFAT/FAT32 or exFAT is used as file system on the external drive. It is recommended to try EXT4 first in case of problems.
- Set read\_only to yes, if you want to disable write access

Name Type RequiredDefault Option Description *name* string yes *(none)* Name of the SMB file share. Will be shown in the filebrowser of the client. *path* file pathyes *(none)* The complete path of the directory. [path](https://www.samba.org/samba/docs/man/manpages-3/smb.conf.5.html#PATH "https://www.samba.org/samba/docs/man/manpages-3/smb.conf.5.html#PATH") *users* string no guest account or from global template the samba-users allowed access to this entry; use *smbpasswd* to create a user-pwd combination! Several users can be specified, separated by a coma (ex : option *users* *root,nobody* ). Translated to [valid users](http://www.samba.org/samba/docs/man/manpages-3/smb.conf.5.html#VALIDUSERS "http://www.samba.org/samba/docs/man/manpages-3/smb.conf.5.html#VALIDUSERS") *read\_only* string no yes or from global template no, yesno allows for read/write, else only read access is granted; (for rw, you also need to mount fs rw!). [read only](http://www.samba.org/samba/docs/man/manpages-3/smb.conf.5.html#READONLY "http://www.samba.org/samba/docs/man/manpages-3/smb.conf.5.html#READONLY") *guest\_ok* string no no or from global template no, yesSpecifies if you need to login via samba-username and password to access this share. [guest ok](http://www.samba.org/samba/docs/man/manpages-3/smb.conf.5.html#GUESTOK "http://www.samba.org/samba/docs/man/manpages-3/smb.conf.5.html#GUESTOK"). *create\_mask*integer no 0744 or from global template chmod mask for files created (needs write access). [create mask](http://www.samba.org/samba/docs/man/manpages-3/smb.conf.5.html#CREATEMASK "http://www.samba.org/samba/docs/man/manpages-3/smb.conf.5.html#CREATEMASK") *dir\_mask* integer no 0755 or from global template chmod mask for directories created (need write access). [directory mask](http://www.samba.org/samba/docs/man/manpages-3/smb.conf.5.html#DIRECTORYMASK "http://www.samba.org/samba/docs/man/manpages-3/smb.conf.5.html#DIRECTORYMASK").

Each samba share can be configured at either share level access or user level access.

- At share level access all users on the network can access the share, and all files are shared with all users.
- At user level access a username and password are needed to access the share.

By default Samba is configured for user level access (this is also the recommended way).

### Samba share config when using "share level" access

To set share level access

- change *security = user* to *security = share* in */etc/samba/smb.conf.template*
- Decide for your self, if you want to set `option 'read_only' 'yes`' to `'no`', to enable unrestricted anonymous access including write permission.
- set *guest\_ok* to *yes* on the share

```
config 'sambashare'
        ...
	option 'read_only' 'yes'
	option 'guest_ok' 'yes'
```

### Samba share config when using "user level" access

Make sure that *guest ok* is set to *no* and allow your created user to access the fileshare with the option *users* by adding the usernames.  
If you want to add more than one user, use a comma separated list.  
In the following example we will allow **newuser** to access the share.

```
config 'sambashare'
        ...
	option guest_ok 'no'
	option users 'newuser'
```

## 5. Adding samba user(s)

To access a samba share with user level access there must be users added to the system by editing `/etc/passwd`.

Add a line for each required user. Choose a unique user id (the first number in the line) of 1000 or higher that does not exist yet. Set the group identification number (the second number) to '65534' (the same number as the user nobody). Copy the rest.

e.g. to create a user:

- user in this example will be called 'newuser'“ (this is the loginname you need to enter, when Windows pops up the authentication dialogue)
- with the unique system ID '1000'
- with the group id '65534' (which is the group identifier for 'nobody'= no special default group)
- '/var' just means the user will not need a special home folder on the system
- '/bin/false' means the user will not have a default shell program associated

```
root:0:0:root:/root:/bin/ash
nobody:*:65534:65534:nobody:/var:/bin/false
daemon:*:65534:65534:daemon:/var:/bin/false
newuser:*:1000:65534:newuser:/var:/bin/false
```

- keep in mind that the user(s) and group(s) utilized by Samba need to have the proper permissions for their shares, i.e. they need write access in order to write via smb.
- For seamless access from Windows Clients use the same username as for your login on your Client. If you use an Microsoft Account to login just use a random username without an @ in the name, “newuser” will work!
- regardless the filename (which is like this for historic Linux reasons), the actual user passwords are stored separately and will be added in the next step

For seamless access when using Microsoft Online accounts in Windows 8/10, edit */etc/samba/smb.conf.template* and add *username map = /etc/samba/username.map*:

```
[global]
[...]
	username map = /etc/samba/username.map
```

Then create */etc/samba/username.map* which links the Linux User loginname to your Microsoft Account loginname:

```
newuser = user@outlook.com
```

## 6. Adding a password for each samba user

samba does not rely on passwords stored in /etc/shadows. By adding the following, you will only enable users for SMB file share access. With these passwords, your users will not get SSH or LuCi access to your OpenWrt system (unless you give them another additional password in the file /etc/shadows)

```
smbpasswd -a newuser
```

- The passwords get stored in hashed form in the file: **/etc/samba/smbpasswd**.
- For seamless access from Windows Clients, preferrably use the same password as also used for your login on your Client. (This also applies to Microsoft Online Accounts)

## 7. Restarting samba

Reload samba by issueing the following command

```
service samba restart
```

## Optional config: /etc/samba/smb.conf.template

In addition to the UCI file (*/etc/config/samba*), modifications can be made to the */etc/samba/smb.conf.template* file.  
In usual default operation, this configuration can be left untouched.

e.g. to allow users with null password (can authenticate without providing a password), edit */etc/samba/smb.conf.template* and add *null passwords = yes*:

## Troubleshooting

- Windows clients: When using exFAT or vFAT(FAT32) as file system on OpenWrt side for samba, you may experience the Windows error message 0x8007003b on Windows clients &gt;= Win8. This error seems especially to occur when trying to copy large files (&gt; 3.5 GB) to the OpenWrt SMB share, even though e.g. exFAT is said to support files &gt; 4GB. The samba services on OpenWrt side may crash afterwards, requiring a OpenWrt device reboot. The last file copied before the crash usually will not have been copied correctly. A reliable workaround to avoid this error at all, is to use EXT4 on the external drive connected of the OpenWrt device.
- If write access is not possible
  
  - check that the mountpoint (e.g. `ls -l /mnt/sha3` has “rwx” bits set. `chmod` can be used to change that if in doubt.
  - check that the samba share is configured with **option read\_only 'no'**
  - it seems like if the samba share name equals the mountpoint name that that triggers a readonly mode. E.g. avoid naming your samba share “sha3” if your mountpoint is named ”/mnt/sha3“
- If there is not enough space on the destination.
  
  - Since *root file system* has limited storage (say 2MiB) and you are mount a storage at /mnt/sda1 (16 GB with 8GB free) and you mention **path under Shared Directories of Network Shares/Samba** in SMB configuration as /mnt then you will have 2MiB space only, but if you use /mnt/sda1 you have (16 GB with 8GB free) now enough space on the destination.
- If you have problems to access your shared directory via **Samba Win10 Client** and you get the error code **0x80004005**; you should be take a look into this solution [Microsoft-Forum: Viewing Network Error 0x80004005](https://answers.microsoft.com/en-us/windows/forum/all/viewing-network-error-0x80004005/2d017e34-a59e-4efd-93c8-db36a8ab1fa8 "https://answers.microsoft.com/en-us/windows/forum/all/viewing-network-error-0x80004005/2d017e34-a59e-4efd-93c8-db36a8ab1fa8")
  
  - *SMB 1.0/CIFS Client* should be enabled ...
  - `Press Windows key + R Type: optionalfeatures.exe Hit Enter Scroll down to SMB 1.0/CIFS File Sharing Support Tick the SMB 1.0/CIFS Client Untick SMB 1.0/CIFS Automatic Removal and Untick SMB 1.0/CIFS Server Click OK and restart if prompted.`
