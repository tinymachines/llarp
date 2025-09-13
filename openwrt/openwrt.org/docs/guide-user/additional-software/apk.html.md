# apk package manager

DO NOT USE `apk upgrade` to update your packages!

Doing so will sooner or later brick your device. Several library packages have as-yet unhandled ABI versioned names, which will cause a misconfiguration if you blindly upgrade them (`libubus`, `libustream` and many others).

The safe way to upgrade all packages is to use one of the ASU clients: LuCI Attended Sysupgrade, `owut` or Firmware Selector.

APK is the package manager originally developed by [Alpine Linux](https://alpinelinux.org/ "https://alpinelinux.org/") and used on OpenWrt development snapshots. Note it has nothing to do with Android or other systems that may use the same acronym.

Useful references:

- [OPKG to APK Cheatsheet](/docs/guide-user/additional-software/opkg-to-apk-cheatsheet "docs:guide-user:additional-software:opkg-to-apk-cheatsheet")
- [APK docs on Alpine](https://wiki.alpinelinux.org/wiki/Alpine_Package_Keeper "https://wiki.alpinelinux.org/wiki/Alpine_Package_Keeper")

![FIXME](/lib/images/smileys/fixme.svg) Needs some info about OpenWrt's apk version 3, whereas Alpine Linux still using apk version 2, so there internal/external differences etc.

## Invocation

## Package manipulation

## Informational commands

## Options

## Examples

### Basics

### Extras

### Upgrading packages

Executing the command

```
apk update
```

will update the package database from a list of repositories that you can view with the command

```
cat /etc/apk/repositories.d/distfeeds.list
```

In that file, lines starting with # are comments; the rest are URLs pointing to package databases, typically under [https://downloads.openwrt.org/snapshots/targets/](https://downloads.openwrt.org/snapshots/targets/ "https://downloads.openwrt.org/snapshots/targets/")

Once the database of available packages has been updated, you can execute the command

```
apk upgrade
```

to upgrade all installed packages that are not up to date.

## Configuration

### Adjust repositories

#### Local repositories

### Change architectures

### Proxy support

## Troubleshooting

### Out of space

### Local repository

## Non-standard installation destinations

## Known Issues

- `apk adbdump` produces non-standard YAML in certain edge cases. If you run into this, please report it [here](https://gitlab.alpinelinux.org/alpine/apk-tools/-/issues/10740 "https://gitlab.alpinelinux.org/alpine/apk-tools/-/issues/10740").
