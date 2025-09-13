# Samba

[Samba](https://www.samba.org/ "https://www.samba.org/") is a free open-source implementation of [SMB](https://en.wikipedia.org/wiki/Server%20Message%20Block "https://en.wikipedia.org/wiki/Server Message Block") that provides network file and print services for clients running Windows, Linux, and macOS. The version included in the OpenWrt [feeds](/docs/guide-developer/feeds "docs:guide-developer:feeds") is `samba4`. [Ksmbd](/docs/guide-user/services/nas/ksmbd "docs:guide-user:services:nas:ksmbd") is a kernel server alternative for SMBv3 protocol which has less features but may offer more performance.

## Prerequisites

To share a connected USB or eSATA drive (HDD, SSD, Flash) on your network first install the [USB](/docs/guide-user/storage/usb-drives-quickstart "docs:guide-user:storage:usb-drives-quickstart") drivers and filesystem your drive is formattted to. For NTFS also see [writable\_ntfs](/docs/guide-user/storage/writable_ntfs "docs:guide-user:storage:writable_ntfs"). If yours is not listed below there are many available, in LuCI filter System → Software for “kmod-fs”. Some common examples:

USB: `kmod-usb3 kmod-usb-storage-uas usbutils block-mount mount-utils`

Filesystems: `kmod-fs-ext4 kmod-fs-exfat kmod-fs-ntfs3`

Drive idle: `luci-app-hd-idle` and enable in LuCI → Services → HDD Idle for your mounted drives to idle in low power state. `hdparm` may also be used instead as per [usb-drives page](/docs/guide-user/storage/usb-drives#optionalidle_spindown_timeout_on_disks_for_nas_usage "docs:guide-user:storage:usb-drives").

Note that at least 128MB RAM is recommended. Less RAM would have issues, although adding 128-256MB swap might help.

## Installation

1\. Install `luci-app-samba4`. Any dependencies, such as samba4-server, are installed automatically.

- *Alternatively* install via SSH: `opkg update && opkg install luci-app-samba4`
- *Optional* check available version using `opkg list | grep -i samba`

2\. Configure Samba in LuCI on the Services → Network Shares page. It is recommended that you use LuCI for the initial configuration and only edit `/etc/samba/smb.conf.template` if needed via LuCI Edit Template tab, or from the shell. Basic LuCI configuration example is provided below:

- Interface: lan
- Workgroup: WORKGROUP
- Enable Extra Tuning: checked (uncheck if using Apple Time Machine)
- Shared Directories: click Add
- Name: name the shared folder
- Path: /mnt/sda1 (enter mount point for your external drive, click Path→ if you need to mount it)
- Browseable: checked
- Read-only: unchecked
- Force Root: checked (caution: use if your LAN is secure, otherwise set user accounts described in sections below and enter under 'Allowed users')
- Allow guests: checked (unless using a user account as described above)
- Create Mask: 0666
- Directory Mask: 0777
- Save and Apply

3\. Basic installation is complete. You can now read/write shares on your LAN. For example, access a share named 'storage' hosted on your router default IP in Windows File Explorer via: `\\192.168.1.1\storage\`.

4\. For automatic network discovery on Windows: `opkg install wsdd2`. Note this may need separate configuration.

Windows, Linux, and macOS include SMB support in their file browsers. Android (like OpenWrt is also Linux-based) can browse shares with apps like X-plore, or for media playback with VLC or Kodi. If your OS is missing support, simply install an app.

## Advanced usage

The basic configuration from the LuCI page described above should work well for most users. For further configuration keep reading and see `samba`.

After modifying any of the config files, restart the Samba server so that your changes take effect:

```
service samba4 restart
```

When Samba is restarted this way, the file `/etc/samba/smb.conf` is (re)created from to the uci configuration file and `/etc/samba/smb.conf.template`.

### Per user security

1. Create Samba user(s) by first manually adding entries to `/etc/passwd` and `/etc/group`
2. Use `smbpasswd -a username` to create and assign a password for samba for that user (note that command write them to `/etc/samba/smbpasswd`)

![:!:](/lib/images/smileys/exclaim.svg) Select a value for the uid/gid that is &gt;=1000 to avoid possible collisions with system reserved values of &lt;1000.

Example entry for `/etc/passwd`:

```
foo:x:1001:1001:smb user:/dev/null:/bin/false
```

Example entry for `/etc/group`:

```
foo:x:1001:foo
```

Set up shared directories permissions according to your needs using `chown` and `chmod`. Any unknown usernames used for authentication against Samba are mapped to a guest login silently by default.

### Custom configuration surpassing the UCI configuration

SMB is the built-in way to share network resources between computers running Windows, even in a professional environment. Thus Samba can be *very* complicated to configure, especially if using Active Directory! It is also not the protocol of choice to accomplish this task in a Linux or Mac environment. So, if for whatever reasons above configuration does not give you desired access to your shares, you can of course circumvent the uci system and hack the original Samba configuration files instead or in addition. There may be entries which do not have a counterpart in UCI and thus can only be configured that way. Just bear in mind, that the uci config will overwrite the values configured with it (but not the whole configuration) at every boot up! If you want configure Samba directly with `/etc/samba/smb.conf` instead of `/etc/config/samba`, it is possible to make changes to the smb.conf survive a reboot using the procedure below.

First, prevent OpenWrt from starting Samba at boot time, thus overwriting `/etc/samba/smb.conf` with the settings in the uci file `/etc/config/samba`:

```
service samba4 disable
```

Then add the following lines to /etc/rc.local to allow smbd and nmbd to start at boot time, using `/etc/samba/smb.conf` as the configuration file

```
smbd -D
nmbd -D
```

Now edit your `/etc/samba/smb.conf` all you like without worrying they will be lost the next time you reboot!

## Configuration as an Apple Time Machine Disk

The LuCI interface can be used to easily setup a share intended to be used as an Apple Time Machine Disk.

- Interface: lan (or whatever interface is to be used)
- Workgroup: WORKGROUP (or whatever name you wish)
- Enable Extra Tuning: unchecked (this as it introduces features that are incompatible with current versions of MacOSX).
- Force synchronous I/o: unchecked
- Enable macOS compatible shares: checked
- Allow legacy (insecure) protocols/authentication: unchecked
- Disable netbios: unchecked
- Shared Directories: click Add
- Name: enter a name for the shared folder (e.g. router name)
- Path: /mnt/sda1 (enter mount point for your drive, click Path→ if you still need to mount a drive)
- Browseable: checked
- Read-only: unchecked
- Force Root: checked (caution: use if your LAN is secure, otherwise set user accounts described in sections below and enter under 'Allowed users')
- Allow users: define a user, see [per\_user\_security](/docs/guide-user/services/nas/cifs.server#per_user_security "docs:guide-user:services:nas:cifs.server")
- Allow guests: unchecked
- Inherit owner: unchecked
- Create Mask: 0600
- Directory Mask: 0700
- Vfs objects: unchecked
- Apple Time-machine share: checked
- Time-machine size in GB: can be left blank or max size can be defined
- Save and Apply

Some guides suggest the need to create a service file for avahi. This is not needed on OpenWrt.

## Troubleshooting

1. Is Samba running? `ps aux` should show `smbd -D` and `nmbd -D`.
2. Is the partition you want to share mounted? In LuCI check System → Mount Points or `/etc/config/fstab`.
3. Does Samba have read/write access to the partition?
4. Is your Samba configuration complete?
5. Do you have the filesystem installed the mounted drive is using?
6. Does your firewall allow clients to access the service on your router?

### Check access to shares

Some hints in advance:

- If you installed all needed packages, configured Samba per UCI and it still does not work, have a look at the file /etc/samba/smb.conf.template.
- Change the entry *security* from `user` to `share`, restart the daemons and try accessing: In *windows explorer* type `\\router_ip` in the address bar.
- In *nautilus* or *dolphin* press &lt;CTRL&gt;+&lt;L&gt; and type `smb://router_ip/` into the address bar.

Instead of looking up the whole configuration step by step, you maybe want to have a look at [Samba.org: Example Network Configurations](http://samba.org/samba/docs/man/Samba-Guide/ExNetworks.html "http://samba.org/samba/docs/man/Samba-Guide/ExNetworks.html"). Chapter 1: No-Frills Samba Servers. Notice that you can already achieve a great deal of security by neatly setting up the [Firewall Documentation](/docs/guide-user/firewall/start "docs:guide-user:firewall:start").

### Start on boot

After installing the packages described in Installation, Samba will start on boot. This can be confirmed in the LuCI System → Startup page. If there is an issue, follow the same procedure as with most OpenWrt packages: The first command will create a symlink `/etc/rc.d/S60samba`, the second will only start samba right now.

```
service samba4 enable
service samba4 start
```

### Browsing shares fails

When Samba is configured, the shares are set browse-able, but they still don't appear when browsing the network, then it may be that `local master = yes` is missing from `/etc/samba/smb.conf.template`. Also check if `preferred master = yes` is in `/etc/samba/smb.conf.template`.

### Cannot write to a Samba share

If you cannot write to the share, Samba may not have the proper permissions to write to the shared folder.

Some have reported success by modifying the permissions and owner of the folder:

```
chmod -R 777 /mnt/sda1
chown -R nobody /mnt/sda1
```

If you are sharing a drive mounted wish fstab, you may need to modify **/etc/config/fstab** to include 'umask=000' in the options section.

```
config 'mount'
        option 'options' 'rw,umask=000'
        option 'enabled_fsck' '0'
        option 'enabled' '1'
        option 'device' '/dev/scsi/host0/bus0/target0/lun0/part1'
        option 'target' '/mnt/usbdisk'
        option 'fstype' 'vfat'
```

More info here: [https://forum.openwrt.org/viewtopic.php?id=26625](https://forum.openwrt.org/viewtopic.php?id=26625 "https://forum.openwrt.org/viewtopic.php?id=26625")

### International characters support

If you need to read/write files and folders with accented characters.

```
sed -i -e "/unix charset/s/ISO-8859-1/UTF-8/" /etc/samba/smb.conf.template
```

### Performance

Test results - many devices released over the late 2010s became fast enough to saturate gigabit LAN connections for Samba shares, thus testing on 2.5Gbps links are now a better check on device capability. Many things will affect performance including CPU and RAM speed, USB/eSATA bus implementation, drive type and filesystem, Samba/Ksmbd version, irqbalance settings, other running tasks, etc. A short list below is pulled from various [Forum](https://forum.openwrt.org/ "https://forum.openwrt.org/") posts:

1. WRT3200ACM (2016 device) - USB3 external drive, formatted NTFS, 1Gb LAN port, OpenWrt 23.05. Read: 100 MB/s, write: 105 MB/s.
2. GL-MT6000 (2023 device) - USB3 external drive, formatted exFAT, 1Gb LAN port, OpenWrt 24.10-snapshot. Read: 90 MB/s, write: 115 MB/s.
3. N100 (2023 device) - USB3 external drive, formatted exFAT, 1Gb LAN port, OpenWrt 24.10-snapshot. Read: 120 MB/s, write: 115 MB/s.

Firewall configuration - for slower devices throughput may improve by disabling netfilter conntrack for Samba if you use NAT:

```
uci -q delete firewall.samba_nsds_nt
uci set firewall.samba_nsds_nt="rule"
uci set firewall.samba_nsds_nt.name="NoTrack-Samba/NS/DS"
uci set firewall.samba_nsds_nt.src="lan"
uci set firewall.samba_nsds_nt.dest="lan"
uci set firewall.samba_nsds_nt.dest_port="137-138"
uci set firewall.samba_nsds_nt.proto="udp"
uci set firewall.samba_nsds_nt.target="NOTRACK"
uci -q delete firewall.samba_ss_nt
uci set firewall.samba_ss_nt="rule"
uci set firewall.samba_ss_nt.name="NoTrack-Samba/SS"
uci set firewall.samba_ss_nt.src="lan"
uci set firewall.samba_ss_nt.dest="lan"
uci set firewall.samba_ss_nt.dest_port="139"
uci set firewall.samba_ss_nt.proto="tcp"
uci set firewall.samba_ss_nt.target="NOTRACK"
uci -q delete firewall.samba_smb_nt
uci set firewall.samba_smb_nt="rule"
uci set firewall.samba_smb_nt.name="NoTrack-Samba/SMB"
uci set firewall.samba_smb_nt.src="lan"
uci set firewall.samba_smb_nt.dest="lan"
uci set firewall.samba_smb_nt.dest_port="445"
uci set firewall.samba_smb_nt.proto="tcp"
uci set firewall.samba_smb_nt.target="NOTRACK"
uci commit firewall
service firewall restart
```

### Remote Access

For remote access configure your firewall as per below. See [port explanation](https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers "https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers"). Use caution here, as you may eventually expose your network to security concerns. Samba and many other packages are not always updated to the latest [CVEs](https://en.wikipedia.org/wiki/Common_Vulnerabilities_and_Exposures "https://en.wikipedia.org/wiki/Common_Vulnerabilities_and_Exposures") between releases. This is not needed for LAN access to your shares, file sharing such as SMB and NAS are typically best used for LAN access for this reason.

```
uci -q delete firewall.samba_nsds
uci set firewall.samba_nsds="rule"
uci set firewall.samba_nsds.name="Allow-Samba/NS/DS"
uci set firewall.samba_nsds.src="lan"
uci set firewall.samba_nsds.dest_port="137-138"
uci set firewall.samba_nsds.proto="udp"
uci set firewall.samba_nsds.target="ACCEPT"
uci -q delete firewall.samba_ss
uci set firewall.samba_ss="rule"
uci set firewall.samba_ss.name="Allow-Samba/SS"
uci set firewall.samba_ss.src="lan"
uci set firewall.samba_ss.dest_port="139"
uci set firewall.samba_ss.proto="tcp"
uci set firewall.samba_ss.target="ACCEPT"
uci -q delete firewall.samba_smb
uci set firewall.samba_smb="rule"
uci set firewall.samba_smb.name="Allow-Samba/SMB"
uci set firewall.samba_smb.src="lan"
uci set firewall.samba_smb.dest_port="445"
uci set firewall.samba_smb.proto="tcp"
uci set firewall.samba_smb.target="ACCEPT"
uci commit firewall
service firewall restart
```

### Network discovery with Windows

Install [wsdd2](/packages/pkgdata/wsdd2 "packages:pkgdata:wsdd2"):

```
opkg update && opkg install wsdd2
```

### Network discovery with Apple

Apple Spotlight connections was resolved in 2023 versions of Samba4. Some older versions of macOS (e.g. Yosemite) have problems discovering SMB network shares broadcasted by each client over the LAN, you can set up a WINS server on your router which will help them out.

A WINS server is a central name server analogous to DNS but for a local network. This service will discover SMB shares then make them available over WINS. Macs will connect to WINS to receive the list of network shares, hopefully with more success than discovering network shares themselves.

Edit the UCI template (`/etc/samba/smb.conf.template`) instead of directly changing `/etc/samba/smb.conf` so as to maintain compatibility with UCI and LuCI.

Log into LuCI, go to Services &gt; Network Shares, go to the Edit Template tab, and add or change the following entries in the “\[global]” section in the template.

```
[global]
	domain master = yes
	local master = yes
	name resolve order = wins lmhosts hosts bcast
	os level = 99
	preferred master = yes
	wins support = yes
```

Save &amp; Apply the changes.

You can also configure dnsmasq to broadcast the WINS server address via DHCP:

```
uci add_list dhcp.lan.dhcp_option="44,$(uci get network.lan.ipaddr)"
uci commit dhcp
service dnsmasq restart
```

SMB network shares should appear in Network home a few minutes after rebooting the Mac.
