# SFTP server

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

## Introduction

- This how-to describes the method for setting up [SFTP](https://en.wikipedia.org/wiki/SSH_File_Transfer_Protocol "https://en.wikipedia.org/wiki/SSH_File_Transfer_Protocol") server on OpenWrt.
- It relies on [Dropbear](/docs/guide-user/base-system/dropbear "docs:guide-user:base-system:dropbear") and [openssh-sftp-server](/packages/pkgdata/openssh-sftp-server "packages:pkgdata:openssh-sftp-server") for secure authentication and file transfer.
- You can use any suitable [SFTP client](/docs/guide-user/services/nas/sftp.server#popular_clients "docs:guide-user:services:nas:sftp.server") running natively on your OS.

## Goals

- Transfer files to/from the router.
- Secure file transfer operations.
- Support OS specific clients.

## Instructions

The SSH File Transfer (SFTP) is a file transfer protocol that works over SSH. It's like SCP but has more features. For a basic usage the low level SCP may be enough but if you need, for example, to mount drive then use the SFTP.

The vanilla OpenWrt out of the box has a small [Dropbear](/docs/guide-user/base-system/dropbear "docs:guide-user:base-system:dropbear") SSH server. But it doesn't support the SFTP and you need to install `openssh-sftp-server` package. The package comes from another OpenSSH server which is bigger but has more features and default on desktop systems like Ubuntu. Many [routers with OpenWrt as a stock firmware](/docs/guide-user/installation/openwrt-as-stock-firmware "docs:guide-user:installation:openwrt-as-stock-firmware") use it out of the box and the `openssh-sftp-server` is installed too. So for this routers you really don't need anything to do and just start using it.

But if not then install the required package:

```
opkg update
opkg install openssh-sftp-server
```

## Testing

Enter the following URL in your SFTP client.

```
sftp://root@openwrt.lan/
```

### Clients

- Windows: [WinSCP](/docs/guide-quick-start/sshadministration#winscp "docs:guide-quick-start:sshadministration") - an advanced GUI client. `Proprietary`
- Windows: [FAR Manager](https://www.farmanager.com/ "https://www.farmanager.com/") - an advanced Norton Commander like file manager. Supports a plain SCP too. `Proprietary`
- Linux, macOS, FreeBSD: [far2l](https://github.com/elfmz/far2l "https://github.com/elfmz/far2l") - an open source version of the FAR. `GPL-2`
- Linux, macOS, FreeBSD: [Midnight Commander](https://midnight-commander.org/ "https://midnight-commander.org/") - a Norton Commander like file manager. Supports a plain SCP too. `GPL-3`
- Linux: [GNOME Files](https://en.wikipedia.org/wiki/GNOME_Files "https://en.wikipedia.org/wiki/GNOME_Files") or [KDE Konqueror](https://apps.kde.org/ru/konqueror/ "https://apps.kde.org/ru/konqueror/"). `GPL-2`
- Linux: [GNOME Déjà Dup](https://wiki.gnome.org/Apps/DejaDup/Details "https://wiki.gnome.org/Apps/DejaDup/Details") - a backup and sync tool. `GPL-3`
- Windows, macOS, Linux, FreeBSD: [rclone](https://rclone.org/ "https://rclone.org/") - a command-line program to manage files on cloud storage. `MIT`
- Linux: [SSHFS client](/docs/guide-user/services/ssh/sshfs.client "docs:guide-user:services:ssh:sshfs.client")
- macOS: [Cyberduck](https://cyberduck.io/ "https://cyberduck.io/") and [MountainDuck](https://mountainduck.io/ "https://mountainduck.io/"). `GPL-3`.
- Android: [X-plore File Manager](https://play.google.com/store/apps/details?id=com.lonelycatgames.Xplore "https://play.google.com/store/apps/details?id=com.lonelycatgames.Xplore")
- Android TV, RapberryPI: [KODI](https://kodi.tv "https://kodi.tv") - a media player for TV. You can put a USB drive to a router and watch your photos, video and audio without any additional software.
- [SFTP Client](https://www.sftp.net/clients "https://www.sftp.net/clients") list

## Troubleshooting

Collect and analyze the following information.

```
# Restart services
service log restart; service dropbear restart
 
# Log and status
logread -e dropbear; netstat -l -n -p | grep -e dropbear
 
# Runtime configuration
pgrep -f -a dropbear
 
# Persistent configuration
uci show dropbear
ls -l /etc/dropbear; cat /etc/dropbear/authorized_keys
ls -l $(opkg files openssh-sftp-server | grep -e ^/)
```

## Extras

### Service discovery

You may want to provide service discovery for clients supporting Bonjour/Zeroconf.

```
opkg update
opkg install announce
```

See also [umdns Multicast DNS Daemon](/docs/guide-developer/mdns "docs:guide-developer:mdns")
