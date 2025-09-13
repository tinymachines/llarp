# opkg to apk cheat sheet

This is a cheat sheet which aims to help with a seamless transition from the previous [opkg](/docs/guide-user/additional-software/opkg "docs:guide-user:additional-software:opkg") package manager to the new [apk](/docs/guide-user/additional-software/apk "docs:guide-user:additional-software:apk").

DO NOT USE `apk upgrade` to update your packages!

Doing so will sooner or later brick your device. Several library packages have as-yet unhandled ABI versioned names, which will cause a misconfiguration if you blindly upgrade them (`libubus`, `libustream` and many others).

The safe way to upgrade all packages is to use one of the ASU clients: LuCI Attended Sysupgrade, `owut` or Firmware Selector.

### General information

Just as with `opkg`, most commands allow an optional package name pattern (denoted `[P]` in commands below). And, like `opkg`, the patterns are file globs, e.g., `*dns*` matches every package with `dns` somewhere in its name.

Command Description `apk -h` Show commands and summaries `apk subcmd -h` Help specific to “subcmd” (called “applets” in the `apk-tools` documentation) `apk update` Force update of local indexes, same as in `opkg` `apk adbdump file` Dump the contents of an APK v3 file, which includes package index files (usually named `packages.adb`) and package files (i.e., `*.apk`)

### Add and remove packages

apk opkg Description `apk update` `opkg update` Refresh the package feeds `apk add pkg` `opkg install pkg` Install package `pkg` `apk del pkg` `opkg remove pkg` Uninstall package `pkg`

Adding is substantially the same with both package managers. One difference is that `apk` wants you to provide valid signatures for all packages, while `opkg` ignores this on local ones, so if you're installing a non-standard (self-built) package, use the `--allow-untrusted` option:

```
$ apk add ./owut_2024.07.01~189b2721-r1.apk
ERROR: ./owut_2024.07.01~189b2721-r1.apk: UNTRUSTED signature

$ apk add --allow-untrusted ./owut_2024.07.01~189b2721-r1.apk
OK: 2313 MiB in 569 packages
```

#### Interesting variants

The `--update-cache` option of `apk` allows you to perform an `update` at the same time you do the `add`, so you can now replace the traditional chained `opkg` commands with a single `apk` one.

```
opkg update && opkg install dnsmasq-full
```

becomes

```
apk --update-cache add dnsmasq-full
```

The `--simulate` option allows you to do a dry run of a command, to see its effect before you actually execute it.

```
$ apk del --simulate nmap
(1/1) Purging nmap (7.95-r1)
OK: 47 MiB in 288 packages
```

#### Default repositories handling

The `apk` is by default configured to update the package repositories defined in `/etc/apk/repositories.d/` when `apk add` is used for the first time. This might be unwanted in some off-line (or air-gapped) scenarios, where `apk` is going to reach possibly remote package repositories to update its local package database before allowing to install the local package.

```
$ apk add ./owut_2024.07.01~189b2721-r1.apk 
fetch https://downloads.openwrt.org/snapshots/targets/x86/64/packages/packages.adb
Failed to send request: Operation not permitted
WARNING: updating and opening https://downloads.openwrt.org/snapshots/targets/x86/64/packages/packages.adb: network error (check Internet connection and firewall)
...snip...
OK: 2313 MiB in 569 packages
```

If you don't want that default behavior, you can disable it with `--repositories-file /dev/null` option

```
$ apk add --repositories-file /dev/null ./owut_2024.07.01~189b2721-r1.apk
...snip...
OK: 2313 MiB in 569 packages
```

If you want this a permanent, simply remove `/etc/apk/repositories.d`, thus running `mv /etc/apk/repositories.d /etc/apk/repositories.d-disabled`.

### Commands for list of packages

To reiterate, `[P]` is a file glob in the following.

apk opkg Description `apk list` `opkg list` Show everything available `apk list P` `opkg list P` Show matches for `P`, or if you prefer regex then pipe through `grep` `apk list --installed [P]` `opkg list-installed` Show all installed or those matching `P` `apk list --upgradeable [P]` `opkg list-upgradable` Show upgradeable packages `apk list --providers [P]` `opkg -A whatprovides P` Show all packages that provide `P`

**Interesting variants**

- `apk list --installed --manifest` - produces a simple list of “package-name version” pairs that are easily parsed with `awk` or `sed`
- `apk info` - *without any parameters* lists only the installed package names, so no parsing needed
- `apk list --orphaned` - shows any dependencies that may have been orphaned, i.e., packages that have no declared top-level dependents. This may indicate that they are left over from an error in removing another package, but it may show packages that are required, but simply have incorrect dependencies. If you wish to remove an orphaned package, first make absolutely sure that it is not required for your system to function correctly.

#### Comparative examples of package listings

Show all candidates via `opkg`:

```
$ opkg -A whatprovides dnsmasq  
What provides dnsmasq
    dnsmasq-dhcpv6
    dnsmasq
    dnsmasq-full
```

Show all candidates via `apk`:

```
$ apk list --providers dnsmasq
<dnsmasq> dnsmasq-2.90-r3 x86_64 {feeds/base/package/network/services/dnsmasq} (GPL-2.0)
<dnsmasq> dnsmasq-dhcpv6-2.90-r3 x86_64 {feeds/base/package/network/services/dnsmasq} (GPL-2.0)
<dnsmasq> dnsmasq-full-2.90-r3 x86_64 {feeds/base/package/network/services/dnsmasq} (GPL-2.0) [installed]
```

Show the installed provider for `dnsmasq` package via `opkg`:

```
$ opkg whatprovides dnsmasq
What provides dnsmasq
    dnsmasq-full
```

Show the installed provider for `dnsmasq` package via `apk`:

```
$ apk list --installed --providers dnsmasq
<dnsmasq> dnsmasq-full-2.90-r3 x86_64 {feeds/base/package/network/services/dnsmasq} (GPL-2.0) [installed]
```

### Package Info

apk opkg Description `apk info` no equivalent Show only installed package names `apk info P` `opkg info P` Show summary information for the package `P` `apk info --all P` no equivalent Show extensive information `apk info --contents P` `opkg files P` Show files contained in the package `apk info --who-owns <file>` `opkg search <file>` Find the package that installed the `<file>` `apk info --depends P` `opkg depends P` Show all packages that P depends upon `apk info --rdepends P` `opkg whatdepends P` Show all packages that depend upon P

### Other operations

apk opkg Description `apk extract --allow-untrusted P` `tar -xvf P` Extract contents of the package
