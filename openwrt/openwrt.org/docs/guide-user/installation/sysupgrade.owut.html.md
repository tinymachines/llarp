# owut: OpenWrt Upgrade Tool

## Overview

`owut` is a tool that you run from the command line of your device to upgrade its OpenWrt firmware, while retaining custom packages and device configuration. In its simplest form, you just run `owut upgrade`, a few minutes later your device reboots and is running the latest version of OpenWrt with the most current package versions. When you need help with `owut`, check in at the [support thread on the forum](https://forum.openwrt.org/t/owut-openwrt-upgrade-tool/200035 "https://forum.openwrt.org/t/owut-openwrt-upgrade-tool/200035").

`owut` has many sub-commands and options to allow you to check firmware status, modify the list of installed packages and do other upgrade related tasks. Some examples are

- `owut check --verbose` - check latest build status with more detail (or less with `--quiet`)
- `owut versions` - list all the OpenWrt versions available on the upgrade server
- `owut download` - download an image without installing it
- `owut install` - verify and install an image you previously downloaded
- `owut list` - generate lists of installed package for use with [Firmware Selector](https://firmware-selector.openwrt.org/ "https://firmware-selector.openwrt.org/") or source builds

When generating an image using `download` or `upgrade` you can

- add packages to or remove packages from the build list
- include a custom `uci-defaults` script to be run at first boot

And on x86 miniPCs, ARM/RISC-V SBCs and similar devices, you can

- specify and retain a larger-than-default root filesystem size
- change the file system type at upgrade time

You can specify these options on the command line, or you can use the standard OpenWrt `config` system to store these values and avoid having to remember and retype them on every upgrade.

For a more detailed description of the overall OpenWrt upgrade process and alternatives to `owut`, see the [Attended Sysupgrade](/docs/guide-user/installation/attended.sysupgrade "docs:guide-user:installation:attended.sysupgrade") page.

## Installation and Upgrading owut

`owut` is a standard, optional OpenWrt package, available on all platforms supported by SNAPSHOT builds on the main branch, or release builds with version 24.10 and later.

```
opkg update  &&  opkg install owut # For 24.10 releases.
apk -U add owut                    # For main SNAPSHOT builds.
```

Unlike some packages, `owut` may be safely upgraded in-place. If you find that you need a feature or bug fix that is not in your current version of `owut`, you can upgrade as follows.

```
opkg update  &&  opkg upgrade owut # For 24.10 releases.
apk -U upgrade owut                # For main SNAPSHOT builds.
```

But note that there is usually no need to specifically upgrade `owut`, as once installed `owut` will be upgraded along with everything else whenever you do a full firmware upgrade.

If you have questions about installation or configuration, [post on the support forum thread](https://forum.openwrt.org/t/owut-openwrt-upgrade-tool/200035 "https://forum.openwrt.org/t/owut-openwrt-upgrade-tool/200035").

## Quick Start

If your goal is simply to upgrade your router's current firmware, staying on the same version (e.g., 24.10 or SNAPSHOT), then just use the `upgrade` command. If there are any problems uncovered by the various pre-build checks, or if an error is detected during the build, then the upgrade will abort with a message indicating the issue.

Your first step is always...

**Make a backup!**

- From LuCI, go to **System → Backup/Flash firmware**. Click **Generate archive**.
- From CLI use `sysupgrade --create-backup /tmp/backup.tar.gz` and use `scp` or some other tool to copy the file to a safe location (usually another host).

*Just do it. Every time...*

If `owut` finds that package downgrades, or no changes were made since your last upgrade, it will tell you this and stop. You can re-run the command with the `--force` option, which will proceed with the build and install, keeping all configuration. If you think you need `--force` but are not absolutely sure, you should [ask on the forum](https://forum.openwrt.org/t/owut-openwrt-upgrade-tool/200035 "https://forum.openwrt.org/t/owut-openwrt-upgrade-tool/200035").

Note that `owut` is currently available only on main SNAPSHOT or versions 24.x and later.

```
$ opkg update && opkg install owut # For 24.10 releases.
$ apk -U add owut                  # For main SNAPSHOT builds.

$ owut upgrade
owut - OpenWrt Upgrade Tool 2024.12.10~e38844ae-r1 (/usr/bin/owut)
ASU-Server     https://sysupgrade.openwrt.org
Upstream       https://downloads.openwrt.org
Target         x86/64
Profile        generic
Package-arch   x86_64
Root-FS-type   ext4
Sys-type       combined-efi
Version-from   24.10-SNAPSHOT r28242-1eff737906 (kernel 6.6.67)
Version-to     24.10-SNAPSHOT r28304-6dacba30a7 (kernel 6.6.69)
Build-FS-type  ext4
Build-at       2025-01-04T21:35:37Z (~66 hours ago)
Image-prefix   openwrt-24.10-snapshot-r28304-6dacba30a7-x86-64-generic
Image-URL      https://downloads.openwrt.org/releases/24.10-SNAPSHOT/targets/x86/64
Image-file     openwrt-24.10-snapshot-r28304-6dacba30a7-x86-64-generic-ext4-combined-efi.img.gz
Installed      284 packages
Top-level       83 packages
Default         43 packages
User-installed  51 packages (top-level only)

Package version changes:
  kmod-amazon-ena                6.6.67-r1                                  6.6.69-r1
  kmod-amd-xgbe                  6.6.67-r1                                  6.6.69-r1
...
  procd-ujail                    2024.12.17~fd01fb85-r1                     2024.12.22~42d39376-r1
  ubus                           2024.10.20~252a9b0c-r1                     2025.01.02~afa57cce-r1
  ubusd                          2024.10.20~252a9b0c-r1                     2025.01.02~afa57cce-r1
92 packages are out-of-date

Default package analysis:
  Default                        Provided-by
  dnsmasq                        dnsmasq-full
  kmod-dwmac-intel               not installed
  libustream-mbedtls             not installed
  nftables                       nftables-json

There are currently package build failures for 24.10-SNAPSHOT x86_64:
  Feed: telephony
    freeswitch                   Mon Jan  6 05:37:57 2025 - not installed
    freeswitch-mod-bcg729        Mon Jan  6 05:46:38 2025 - not installed
    freetdm                      Mon Jan  6 05:46:40 2025 - not installed
Failures don't affect this device, details at
  https://downloads.openwrt.org/releases/faillogs-24.10/x86_64/
  
WARNING: There are 2 missing default packages, confirm this is expected before proceeding
Request:
  Version 24.10-SNAPSHOT r28304-6dacba30a7 (kernel 6.6.69)
Request hash:
  fc626783b488e9a7e5a5914495a7ebbbf9fb079cff7abbf2a2165a25d02c8eb6
--
Status:   queued - 0 ahead of you
Progress:   0s total =   0s in queue +   0s in build
--
Status:   init
Progress:   1s total =   0s in queue +   1s in build
--
Status:   container_setup
Progress:  17s total =   0s in queue +  17s in build
--
Status:   validate_manifest
Progress: 101s total =   0s in queue + 101s in build
--
Status:   building_image
Progress: 185s total =   0s in queue + 185s in build
--
Status:   done
Progress: 187s total =   0s in queue + 187s in build

Build succeeded in 187s total =   0s in queue + 187s to build:
  version_number = 24.10-SNAPSHOT
  version_code   = r28304-6dacba30a7 (requested r28304-6dacba30a7)
  kernel_version = 6.6.69
  rootfs_size_mb = default
  init-script    = no-init-script

Image source: http://asu-dev.brain.lan:8000/store/fc626783b488e9a7e5a5914495a7ebbbf9fb079cff7abbf2a2165a25d02c8eb6/openwrt-24.10-snapshot-r28304-6dacba30a7-8e0b0deb02c0-x86-64-generic-ext4-combined-efi.img.gz
Image saved : /tmp/firmware.bin
Manifest    : /tmp/firmware-manifest.json
Verifying   : /tmp/firmware.bin (32751632 bytes) against /tmp/firmware.sha256sums
  Saved sha256 matches
  Tue Jan  7 07:54:20 PST 2025 upgrade: Image metadata not present
  Tue Jan  7 07:54:20 PST 2025 upgrade: Reading partition table from bootdisk...
  Tue Jan  7 07:54:20 PST 2025 upgrade: Extract boot sector from the image
  Tue Jan  7 07:54:21 PST 2025 upgrade: Reading partition table from image...
Checks complete, image is valid.
Installing /tmp/firmware.bin and rebooting...

... system reboots ...
```

## Usage

```
$ owut -h
owut - OpenWrt Upgrade Tool 2025.01.06~e623a900-r1 (/usr/bin/owut)
 
owut is an upgrade tool for OpenWrt.
 
Usage: owut COMMAND [-V VERSION_TO] [-R REV_CODE] [-v] [-q] [-k] [--force] [-a ADD] [-r REMOVE] [--ignored-defaults IGNORED_DEFAULTS] [-I INIT_SCRIPT] [-F FSTYPE] [-S ROOTFS_SIZE] [-i IMAGE] [-f FORMAT] [-p PRE_INSTALL] [-T POLL_INTERVAL]
  -h/--help            - Show this message and quit.
  --version            - Show the program version and terminate.
 
  COMMAND - Sub-command to execute, must be one of:
    check    - Collect all resources and report stats.
    list     - Show all the packages installed by user.
    blob     - Display the json blob for the ASU build request.
    download - Build, download and verify an image.
    verify   - Verify the downloaded image.
    install  - Install the specified local image.
    upgrade  - Build, download, verify and install an image.
    versions - Show available versions.
    dump     - Collect all resources and dump internal data structures.
 
  -V/--version-to VERSION_TO - Specify the target version, defaults to installed version.
  -R/--rev-code REV_CODE - Specify a 'version_code', literal 'none' allowed, defaults to latest build.
  -v/--verbose         - Print various diagnostics.  Repeat for even more output.
  -q/--quiet           - Reduce verbosity.  Repeat for total silence.
  -k/--keep            - Save all downloaded working files.
  --force              - Force a build even when there are downgrades or no changes.
  -a/--add ADD         - New packages to add to build list.
  -r/--remove REMOVE   - Installed packages to remove from build list.
  --ignored-defaults IGNORED_DEFAULTS - List of explicitly ignored default package names.
  --ignored-changes IGNORED_CHANGES - List of explicitly ignored package changes.
  -I/--init-script INIT_SCRIPT - Path to uci-defaults script to run on first boot ('-' use stdin).
  -F/--fstype FSTYPE   - Desired root file system type (squashfs, ext4, ubifs, jffs2).
  -S/--rootfs-size ROOTFS_SIZE - DANGER: See wiki before using!  Root file system size in MB (1-1024).
  -i/--image IMAGE     - Image name for download, verify, install and upgrade.
  -f/--format FORMAT   - Format for 'list' output (fs-user, fs-all, config).
  -p/--pre-install PRE_INSTALL - Script to exec just prior to launching final sysupgrade.
  -T/--poll-interval POLL_INTERVAL - Poll interval for build monitor, in milliseconds.
  --progress-size PROGRESS_SIZE - Response content-length above which we report download progress.
 
Full documentation
  https://openwrt.org/docs/guide-user/installation/sysupgrade.owut
 
Questions and discussion
  https://forum.openwrt.org/t/owut-openwrt-upgrade-tool/200035
 
Issues and bug reports
  https://github.com/efahl/owut/issues
```

## Sub-Commands

Sub-Command Description `check` Downloads all resource files, collects the metadata from the device and the resources, and displays a report on everything found. This includes available version upgrades on all packages, availability of installed packages, listing of all package build breakages, and so on. At the end of the report, you'll see an indication as to whether it is possible to upgrade or not. `list` This sub-command allows you to generate the list of packages installed on your device. This list is tailored for use with either the [OpenWrt Firmware Selector](https://firmware-selector.openwrt.org/ "https://firmware-selector.openwrt.org/") or for use with source builds. For more details, see the `--format` [option description](#list_formatting "docs:guide-user:installation:sysupgrade.owut ↵"), below. `blob` Display the json blob for the ASU build request. Mostly useful for debugging and satisfying your curiosity. `download` Build, download and `verify` an image. Used to create an image that you may then archive off-system, before subsequently `owut install`ing it. `verify` Verify the downloaded image. After you have `download`ed an image, `verify` can be used to make sure it corresponds to the downloaded checksums and is correct according to `sysupgrade`. `install` Install the specified image. Does another `verify`, then runs `sysupgrade` to install the image, results in a reboot. `upgrade` Build, download, verify and install an image. Short hand way to run all steps involved in upgrading the system, basically a `download` and `install` in one command. `versions` Show available versions according to what the ASU server knows. This may not be a complete list with respect to what is available on the build servers (aka `downloads.openwrt.org`), as the ASU server does not deal with archives and discourages use of out-of-date releases. `dump` Collect all resources and dump internal data structures. Again, like the `blob` sub-command, this is for debugging and curious users.

## Command Line Options

Option Default Description `-V/--version-to VERSION` newest version on current branch Search for updates for this version or branch. [Detailed description.](#selecting_a_version "docs:guide-user:installation:sysupgrade.owut ↵") `-R/--rev-code REV_CODE` - Optionally specify the build revision code. Rarely needed, if you think you need to use it, ask on the forum. `-v/--verbose` - Print various diagnostics and operational messages; repeat for even more output. `-q/--quiet` - Reduces verbosity and can be repeated for less output. `-k/--keep` false Save all downloaded working files, primarily for diagnostics and debugging. Look in `/tmp/` after using this option; turn on `-v` to watch as they are saved. `--force` false Force `download` or `upgrade` when there are package downgrades, or when there are no changes detected. [Detailed description.](#forcing_a_build "docs:guide-user:installation:sysupgrade.owut ↵") `-a/--add ADD` none List of new packages to add to build list. [Detailed description.](#about_adding_packages "docs:guide-user:installation:sysupgrade.owut ↵") `-r/--remove REMOVE` none List of installed packages to remove from build list. [Detailed description.](#about_removing_packages "docs:guide-user:installation:sysupgrade.owut ↵") `--ignored-defaults IGNORED_DEFAULTS` none List of explicitly ignored default package names. [Detailed description.](#about_ignoring_defaults "docs:guide-user:installation:sysupgrade.owut ↵") `--ignored-changes IGNORED_CHANGES` none A list of explicitly ignored package changes. Be sure to read the whole [package changes](#package_changes "docs:guide-user:installation:sysupgrade.owut ↵") section before using this. `-I/--init-script INIT_SCRIPT` none Path to uci-defaults script to run on first boot ('-' use stdin). [Detailed description.](#using_a_uci-defaults_script "docs:guide-user:installation:sysupgrade.owut ↵") `-F/--fstype FSTYPE` current Desired root file system type. May be one of `squashfs`, `ext4`, `ubifs` or `jffs2` depending on platform constraints. [Detailed description.](#changing_file_system_type "docs:guide-user:installation:sysupgrade.owut ↵") `-S/--rootfs-size ROOTFS_SIZE` current Root file system size in MB (1-1024). [Detailed description.](#expanding_root_file_system "docs:guide-user:installation:sysupgrade.owut ↵") `-i/--image IMAGE` `/tmp/firmware.bin` The image name used for the `download`, `verify`, `install` and `upgrade` sub-commands. `-f/--format FORMAT` `fs-user` Format for `list` output. Valid formats are `fs-user`, `fs-all` and `config`. [Detailed description.](#list_formatting "docs:guide-user:installation:sysupgrade.owut ↵") `-p/--pre-install PRE_INSTALL` none Path to a user-defined script that will be run after image verification and before the actual installation of the image. [Detailed description.](#pre-install_script "docs:guide-user:installation:sysupgrade.owut ↵") `-T/--poll-interval POLL_INTERVAL` 2000 Milliseconds to sleep between checks on build status when running the build. `--progress-size PROGRESS_SIZE` 0 Allows the user to display progress of each download by setting a threshold for response content-length above which download progress is shown [Detailed description.](#display_download_progress "docs:guide-user:installation:sysupgrade.owut ↵")

### Selecting a version

#### When you don't specify a version

When you do not explicitly specify a `--version-to` value, `owut` looks for the newest version of the installed branch and sets that as the target version.

For all examples, assume that latest on the `21.02` branch is the `21.02.7` release, and on `23.05` it's the `23.05.4` release.

Installed Version Target `21.02.2` `21.02.7` `23.05.0-rc1` `23.05.4` `23.05.3` `23.05.4` `23.05.4` `23.05.4`

The exception to this is if the installed version is a `SNAPSHOT`, either release or main, in which case, the version-to target remains at the installed version.

Installed Version Target `22.03-SNAPSHOT` `22.03-SNAPSHOT` `23.05-SNAPSHOT` `23.05-SNAPSHOT` `SNAPSHOT` `SNAPSHOT`

#### When you do specify a version

When you do specify `--version-to`, it must name a valid version or branch. If you provide an invalid value, `owut` will show you all the available versions (or you can do this manually with `owut versions`).

When you specify a full version, then the input is checked against the available versions and left untouched:

User specifies Target `--version-to 23.05.3` `23.05.3` `--version-to 23.05.0-rc2` `23.05.0-rc2` `--version-to 23.05-snapshot` `23.05-SNAPSHOT` `--version-to snapshot` `SNAPSHOT`

If you specify only a branch (i.e., a version number without the final “dot value”), then the version-to target is set to the latest release on that branch.

User specifies Target `--version-to 21.02` `21.02.7` `--version-to 23.05` `23.05.4` `--version-to SNAPSHOT` `SNAPSHOT`

Note that character case is not important in naming the version, `owut` converts internally to what the upgrade server requires. You can say `snapshot`, `SnapShot` or `SNAPSHOT` or `rc1` or `rC1` and `owut` knows what to do.

### Forcing a build

`owut`'s normal behavior is to avoid doing unneeded work by stopping a build request when no changes are found. The `--force` option is used to override this and do a re-build and re-install of the current system. This might be useful if you have inadvertently deleted packages or something similar, and can't easily figure out how to recover.

When `owut` detects downgrades in packages, it will indicate this by coloring the new version number red in the `Package version changes:` list and report the number of downgrades at the bottom of the list. This also causes `owut` to stop processing any `download` or `upgrade` in progress, unless you specify `--force` option.

### Adding and removing packages

The `--add` and `--remove` options allow you to add packages to or remove packages from the build list submitted by `owut` to the ASU build server. These options may only appear once on the command line; if you wish to add or remove more than one package, then separate the package names with commas or group them with quotes.

For example, if you wanted to upgrade and simultaneously switch to the full versions of `dnsmasq` and `tc`, you'd say this.

```
$ owut upgrade -r dnsmasq,tc-tiny -a "dnsmasq-full tc-full"
...
```

As of release 2025.01.06, the command line argument to both `--add` and `--remove` may be delimited by either commas or arbitrary white space including newlines (prior to that release, only commas are allowed). The primary purpose of this is to allow you to use a simple flat file of package names as the input source for the package list, as in this example.

```
$ cat additions
nmap
bind-dig
tcpdump
 
$ owut download --add "$(cat additions)"
...
```

#### About adding packages

1. If you add a package that is already installed, `owut` silently ignores this and carries on.
2. If you add a package that doesn't exist, hasn't been ported to your device or is currently unavailable, then `owut` reports an error and stops.

#### About removing packages

1. If you attempt to remove a package which is not installed, `owut` reports an error and stops.
2. If you remove one of the default packages for your device, `owut` will produce a warning, the package will be removed and `owut` will continue with your request. *Note that this may break things, either during the build or after installing on your device,* and you are responsible for ensuring that removal of the package is appropriate.
   
   ```
   $ owut check -r kmod-igb
   WARNING: package 'kmod-igb' is a default package, removal may have unknown side effects
   ...
   ```
3. If you attempt to remove a package that has dependents (that is a “non-top-level package” -- something that was installed as a requirement for another package), `owut` will warn you about this, the package will be removed from the build list and `owut` will proceed. Note that this typically *has no effect*, as the package will be pulled back in by the same top-level package that installed it in the first place.
   
   ```
   $ owut check -r kernel
   WARNING: package 'kernel' has dependents and removal will have no effect on the build
   ...
   ```

#### About ignoring defaults

If the `Default package analysis:` shows you default packages you have removed but wish to ignore, simply supply them as arguments to the `--ignored-defaults` option to suppress the warnings about missing defaults.

```
$ owut check
...
Default package analysis:
  Default                        Provided-by
  dnsmasq                        dnsmasq-full
  kmod-drm-i915                  not installed
  kmod-dwmac-intel               not installed
  nftables                       nftables-json
...
WARNING: There are 2 missing default packages, confirm this is expected before proceeding
```

Note that the packages are still listed in the analysis table, confirming your choice, but no warning message is shown.

```
$ owut check --ignored-defaults kmod-drm-i915,kmod-dwmac-intel
...
Default package analysis:
  Default                        Provided-by
  dnsmasq                        dnsmasq-full
  kmod-drm-i915                  user ignored
  kmod-dwmac-intel               user ignored
  nftables                       nftables-json
```

You can add these packages to the config file, eliminating the need to type them on the command line every time.

```
$ cat /etc/config/attendedsysupgrade
...
config owut 'owut'
        option verbosity      1
        option poll_interval  2000
        list   ignored_defaults "kmod-drm-i915"
        list   ignored_defaults "kmod-dwmac-intel"
```

Note that this is quite useful when dealing with packages such as `wpad-basic-mbedtls` and its many alternatives, as the package dependencies are such that `owut` and other ASU clients are unable to determine if the missing default has been replaced by something else or if it's truly missing. For example, if you simply replace the default with `wpad-mbedtls` (the “full” version), you'll see

```
Default package analysis:
  Default                      Provided-by
  nftables                     nftables-json
  wpad-basic-mbedtls           not installed

WARNING: There are 1 missing default packages, confirm this is expected before proceeding
```

When you see this, first verify that you have the proper replacement installed, then just add

```
        list   ignored_defaults 'wpad-basic-mbedtls'
```

to the `owut` section of `/etc/config/attendedsysupgrade` so that `owut` stops warning you.

```
Default package analysis:
  Default                      Provided-by
  nftables                     nftables-json
  wpad-basic-mbedtls           user ignored

It is safe to proceed with an upgrade
```

### Package Changes

The Attended Sysupgrade (ASU) server provides metadata about version upgrades that is utilized by various ASU clients (including the LuCI ASU app, `owut`, and `owut`'s predecessor `auc`). This metadata is contained in the [overview.json file](https://sysupgrade.openwrt.org/json/v1/overview.json "https://sysupgrade.openwrt.org/json/v1/overview.json"), where you can see information about each branch available via the server. For example, under `branches.SNAPSHOT.package_changes`, there is information regarding the transition from `firewall` to `firewall4`, which happened at revision 18611.

This table is used by `owut` to automatically replace packages during an upgrade across release boundaries (note that `owut` does not handle downgrades across these same boundaries; if you run into an issue because of this, [ask on the forum](https://forum.openwrt.org/t/owut-openwrt-upgrade-tool/200035 "https://forum.openwrt.org/t/owut-openwrt-upgrade-tool/200035")).

Using the `firewall` example, assume you have an old installation prior to revision 18611 (see below for how to determine your current revision) and that you are upgrading to a more recent one. When `owut` scans your installed packages, it will use the `package_changes` information as follows:

1. Is the package under consideration a `source` entry in the `package_changes` list for this branch?
2. If so, is the current revision less than or equal to the package change revision?
3. If so, then
   
   1. remove the current package;
   2. if the `target` is empty, we're done (the current package was deleted or merged into another one);
   3. otherwise, add the `target` package.

This makes splitting, merging, replacement and deletion of packages across an upgrade mostly seamless, and generally you won't need to worry about it.

Problems arise when

1. A package change is made in OpenWrt but it is not registered in the `package_changes` table. This is a bug and should be reported, either on the [forum](https://forum.openwrt.org/t/owut-openwrt-upgrade-tool/200035 "https://forum.openwrt.org/t/owut-openwrt-upgrade-tool/200035") or at [https://github.com/openwrt/asu/issues](https://github.com/openwrt/asu/issues "https://github.com/openwrt/asu/issues")
2. You actually require that one or more package change should not be applied.

For the latter, you can use the `--ignored-changes` option when running `owut` to suppress this behavior on a package-by-package basis. Again using the `firewall` example, you would specify that you wish to keep `firewall` as follows, receiving confirmation with an informational message.

```
$ owut upgrade --ignored-changes firewall
owut - OpenWrt Upgrade Tool 2025.03.14~52e7d44c-r1 (/root/bin/owut)
Ignoring package change firewall to firewall4
...
```

Note that the `--ignored-changes` option uses the same argument parsing as the `--add` and `--remove` options, i.e., a single string with package names separated by commas or whitespace (see those commands for more detail).

This can be made “permanent” by adding that option as a list element to the config file, which causes `owut` to use the data from the config instead of the command line:

```
$ uci add_list attendedsysupgrade.owut.ignored_changes='firewall'
$ uci commit attendedsysupgrade
$ uci show attendedsysupgrade
attendedsysupgrade.owut=owut
attendedsysupgrade.owut.verbosity='1'
attendedsysupgrade.owut.poll_interval='2000'
attendedsysupgrade.owut.ignored_changes='firewall'
```

##### Finding your current revision

You can determine your current revision using the following. It is the number between `r` and `-`, so in this example 28521. (Or if you already have `owut` installed, just run `owut check | grep Version-` and it will show both the installed version and the version to which you'd be upgrading.)

```
$ ubus call system board | jsonfilter -e '$.release.revision'
r28521-f3a210b742
```

### Using a uci-defaults script

**Do not put sensitive information in the `init-script` file.**

The text you provide in the `init-script` file is sent to the build server as part of the build configuration. This exposes it to potential disclosure as the build request traverses the internet. Once the build has completed, the file's contents are stored on the build server in the generated image, where anyone with knowledge of the build hash may download and access it.

If you are not familiar with `uci-defaults` (aka “first boot scripts”), you can read up here: [UCI defaults](/docs/guide-developer/uci-defaults "docs:guide-developer:uci-defaults"). The underlying mechanism that implements `owut` (and `auc` and LuCI Attended Sysupgrade and Firmware Selector) builds is the Image Builder, so its description may also be useful: [Image builder - Custom files](/docs/guide-user/additional-software/imagebuilder#custom_files "docs:guide-user:additional-software:imagebuilder").

The `--init-script` option allows you to specify the name of a file containing a `uci-defaults` script, which is to be executed at first boot. The ASU server takes your init-script source and places it in the image in `/etc/uci-defaults/99-asu-defaults` (there is no means to change this name). On immutable file systems (say `squashfs`), this also results in the file being stored in `/rom/etc/uci-defaults/99-asu-defaults`, which comes into play with LuCI Attended Sysupgrade.

Here's a comparison of `owut` with how other upgrade tools implement this functionality.

- `auc` does not implement this ability (but [the patch](https://github.com/openwrt/packages/pull/22144 "https://github.com/openwrt/packages/pull/22144") exists).
- Firmware Selector behaves identically to `owut` with its `Script to run on first boot (uci-defaults)` input field.
- LuCI Attended Sysupgrade implements this by looking for `/rom/etc/uci-defaults/99-asu-defaults` and then relays the contents of that file implicitly. LuCI ASU's shortcoming is that it doesn't allow you to delete or change what's already there. `owut` makes this explicit, if you want the script included in your new image, then you must specify it when you request a build.

The terms used in the following two scenarios (comprising seven use cases) are:

- “mutable system” - A device using a read-write file system for its main storage. Typically in OpenWrt, this is an `ext4` file system.
  
  ```
  $ mount | grep '(ro'
  ... no output ...
  ```
- “immutable system” - A device which has a read-only partition mounted on `/rom`, where the original system image is stored. Usually, but not always, this is a `squashfs` file system.
  
  ```
  $ mount | grep '(ro'
  /dev/root on /rom type squashfs (ro,relatime,errors=continue)
  ```
- “asu-defaults” - The file `/rom/etc/uci-defaults/99-asu-defaults`, which only exists on devices with an immutable file system and whose images have been built by the ASU build server.

On an immutable system, there are five cases to consider:

1. An asu-defaults file does not exist and you don't need or want one:
   
   ```
   owut upgrade
   ```
2. An asu-defaults file exists and you want to keep it unchanged:
   
   ```
   owut upgrade --init-script /rom/etc/uci-defaults/99-asu-defaults
   ```
3. An asu-defaults file exists and you want to modify it:
   
   ```
   cp /rom/etc/uci-defaults/99-asu-defaults my-modified-init-script.sh
   vi my-modified-init-script.sh  # Change it.
   owut upgrade --init-script my-modified-init-script.sh
   ```
4. An asu-defaults file does not exist but you want to add one:
   
   ```
   vi my-new-init-script.sh
   owut upgrade --init-script my-new-init-script.sh
   ```
5. An asu-defaults file exists and you want to delete it from build:
   
   ```
   owut upgrade  # Just ignore the warning.
   ```

On a mutable system, since there is no `/rom/etc/uci-defaults`, you only have two choices:

1. You don't want to create an asu-defaults file in your build:
   
   ```
   owut upgrade
   ```
2. You do want to create one:
   
   ```
   owut upgrade --init-script my-init-script.sh
   ```

Note that for all of the above cases, if you do use asu-defaults, then you are responsible for keeping a backup. For best practices, see the [persistent defaults example](#persistent_uci-defaults "docs:guide-user:installation:sysupgrade.owut ↵").

### Changing file system type

On rare occasion, it might be desirable to change the file system type of an installation. Usually this is done on devices with expandable file systems, x86, RISC-V and ARM SBCs, where the storage device is not fixed size FLASH memory (in fact, if you try to change the file system type on an all-in-one, FLASH-based device, the build will almost always fail).

But, say for example, you have an x86 with an SSD and want to switch from the current `squashfs` to use `ext4`. Simply upgrade with the desired file system, and upon reboot you'll be running the targeted file system.

```
$ owut upgrade --fstype ext4
...
Target         x86/64
Profile        generic
Package-arch   x86_64
Root-FS-type   squashfs                   <<< Installed
Version-from   SNAPSHOT r26504-d4acd05218 (kernel 6.6.32)
Version-to     SNAPSHOT r26733-2b6772c82c (kernel 6.6.34)
Build-FS-type  ext4                       <<<  Requested
...
```

### Expanding root file system

Changing your root file system size often causes `owut`'s final installation performed by `sysupgrade` to lose your configuration, so be prepared to recover with a backup. Note that if you lose `/etc/config/network`, the LAN IP of the device may change, so think about how you'll attach to the device before you proceed.

This has been observed repeatedly on x86 installation, but ARM-based devices sometimes “just work” without wiping the configuration; you'll have to experiment and find out (when you do, please [report both successes and failures on this thread](https://forum.openwrt.org/t/owut-openwrt-upgrade-tool/200035/551 "https://forum.openwrt.org/t/owut-openwrt-upgrade-tool/200035/551") so we can determine which targets need work to overcome this issue).

As of about 2025-05-31 (LuCI build 25.151), the LuCI Attended Sysupgrade app is aware of the `rootfs_size` setting in the `owut` config, and applies it during build requests.

The `--rootfs-size` option allows those devices with expandable file systems (again, typically x86, RISC-V and ARM SBCs) to specify the size of the root file system. The default value varies depending on target, but is often 104 MB and the `--rootfs-size` option allow you to increase that up to 1024 MB (see note below), thus allowing more or bigger packages to be installed.

Best practice is to define this value in the config so that:

1. You avoid typing it on the command line every time you upgrade;
2. You don't forget and resize back to 104MB, losing your config or failing the upgrade.

Example commands to set the value to 256 MB, modify the value to suit:

```
$ uci set attendedsysupgrade.owut=owut
$ uci set attendedsysupgrade.owut.rootfs_size=256
$ uci commit
$ uci show attendedsysupgrade.owut
attendedsysupgrade.owut=owut
attendedsysupgrade.owut.rootfs_size='256'
```

Note that the maximum value allowed for `rootfs_size` is a function of the ASU server. For example, max rootfs partition size on OpenWrt is 1024 MB. You should verify the value by looking on the various sysupgrade servers, it will be listed as the `Maximum requested root filesystem size:` under the Server Configuration section at the bottom of the page.

- [OpenWrt Sysupgrade Server](https://sysupgrade.openwrt.org/ "https://sysupgrade.openwrt.org/") - 1024 MB as of 2025-08-15
- [LibreMesh Sysupgrade Server](https://sysupgrade.antennine.org "https://sysupgrade.antennine.org") - 1024 MB as of 2025-08-15
- [ImmortalWrt Sysupgrade Server](https://sysupgrade.kyarucloud.moe "https://sysupgrade.kyarucloud.moe") - 4096 MB as of 2025-08-15

### List formatting

The owut list command uses the `--format` option that takes one of the following values.

- `fs-user` - (the default) produces a package list for use by the Firmware Selector that contains only the top-level, user-installed package modifications. You'd copy and paste this *after* the default list in the FS 'Installed Packages' field.
- `fs-all` - produces a package list for FS containing all top-level packages, which you'd paste *over* the values in the FS 'Installed Packages' field.
- `config` - produces a build `.config` snippet of user-installed, top-level packages that you can use when doing source builds. Each output line looks like `CONFIG_PACKAGE_collectd-mod-thermal=y`.

The `fs-*` options generate lists in the Image Builder syntax, where mentioning a package name adds it to the list, and prefixing a package name with a dash removes it.

For example, if you have installed `dnsmasq-full`, then the default `dnsmasq` basic package must be removed. That would look like this (trimmed down for clarity):

```
$ owut list
... dnsmasq-full ... -dnsmasq ...
```

There are several packages provided by the defaults that are named using a generic package name, and actually provided by something with a different name, `nftables` is a prominent one (it is provided by either `nftables-json` or `nftables-nojson`, there is no `nftables` package). `owut` appears to be removing it, but it really is just saying, “use the default, whatever that is”. In the following example, we see only the `-nftables` removal, but not default package `nftables-json` as it will be added implicitly.

```
$ opkg whatprovides nftables  # Or 'apk list --providers nftables'
What provides nftables
    nftables-json
 
$ owut list
... -nftables ...
```

This can happen for other files that appear to be “deleted from nowhere” due to dependencies. As an example of this, if you are using `luci-ssl-openssl`, then the list output will contain `-libustream-mbedtls` which would otherwise be added by defaults resulting in an “impossible package selection” error.

You'll often see other evidence of these mappings when using `check` in the default package analysis results:

```
$ owut check
...
Default package analysis:
  Default                        Provided-by
  dnsmasq                        dnsmasq-full
  kmod-dwmac-intel               not installed
  nftables                       nftables-json
...
```

### Pre-install Script

TIP

For the most up-to-date examples, see the latest version of the pre-install script in the [github source](https://github.com/efahl/owut/blob/main/files/pre-install.sh "https://github.com/efahl/owut/blob/main/files/pre-install.sh").

`owut` has a hook between image verification and image install, allowing you to do automatic backups, archiving of build artifacts or any other final modifications to the system prior to the installation. Use the `--pre-install /path/to/script` option from the command line. Once you're satisfied with how your script work, best practice is to add `option pre_install '/path/to/script`' to the `owut` section of the config file.

The standard installation of `owut` provides several examples in `/etc/owut.d/pre-install.sh`. If you come up with other interesting uses, please share them.

#### Note 1 - Backup

Note that the directory `/etc/owut.d/` is part of the standard sysupgrade backup, so any files you store there will become part of system backups and persist across upgrades (assuming you “keep config”). You can check this with `sysupgrade -l | grep owut.d`, which should show all the files in that directory.

The example script mentioned in the above tip uses `/etc/owut.d/` as the destination for archives for this reason.

#### Note 2 - Execution environment

When the pre-install script is executed, it is spawned with a minimal environment. You cannot count on `HOME` or other environment variables being carried in from the context in which `owut` was started. The only variable you can rely on is `PATH`, which will point to all the usual system locations. This means that testing your script outside `owut` should be performed using an empty environment, as shown here:

```
env -i  PATH=/usr/sbin:/usr/bin:/sbin:/bin  /path/to/your/pre-install-script
```

If you need to run processes that are out of your control, but require specific variables, you must define then in your pre-install script explicitly. Also, if you use scripts or executables that are not in the standard system locations, you'll need to specify them by their full path (or extend `PATH`).

```
#!/bin/sh
 
export HOME=/root
export USER=root
 
/root/bin/helper.sh  # Run my helper script from ~/bin.
 
...
```

### Display download progress

If your ISP provides you with very low bandwidth, this can make downloading the image appear as if `owut` has locked up. If that happens to you, add `--progress-size 1000` to the `owut` command line, which will display progress of each download when its response length is over 1000 bytes.

The default of `0` means no progress status is shown, but any value greater than `0` will display progress for downloads over that size. This allows you to show progress for large files, but not be bothered by smaller ones; using a small size will show all downloads.

You can determine the best size for your use by experimentation, then set your desired value as the dynamic default in the config, so you don't need to supply it on the command line, as follows. As usual, supplying a value on the command line supercedes the value in the config file.

```
$ uci set attendedsysupgrade.owut.progress_size=25000
$ uci commit
```

## Configuration

Note that although you can store any of the command line options in the config file, doing so with certain options may be confusing. Use your discretion when setting defaults: as an example, setting `option force true` is probably not a good idea.

Any of the command line options may be stored in the `owut` section of `/etc/config/attendedsysupgrade`. For example, if you are using `--rootfs-size 256` on the command line on every upgrade, you could edit the config and add that option as follows:

```
config server 'server'
        option url 'https://sysupgrade.openwrt.org'

config owut 'owut'
       option rootfs_size 256
```

Note that the dashes in the command line “long” option names are turned into underscores in the config option name, but beyond that the syntax is pretty much identical.

There is one exception to the naming convention, command line `--verbose` and `--quiet` both map to `verbosity` in the config file. The config file value for `verbosity` is an integer; every mention of `-v` on the command line simply increments it, and `-q` decrements it: `option verbosity 1`, then `owut check -v -v -q -v` results in an output verbosity of 3 (i.e., more output than you ever thought possible).

A convenient way to see what the default values are and to verify that any changes you made to the config file are correct is to `owut dump` and examine the `options` section of the output.

```
$ owut dump | head -20
{
"version": "owut/2025.01.06~e623a900-r1",
"options": {
  "command": "dump",
  "version_to": null,
  "rev_code": null,
  "verbosity": 1,
  "keep": false,
  "force": false,
  "add": null,
  "remove": null,
  "init_script": null,
  "fstype": null,
  "rootfs_size": 256,
  "image": "/tmp/firmware.bin",
  "format": null,
  "pre_install": "/etc/owut.d/pre-install.sh",
  "poll_interval": 10000,
  "device": null
},
```

### Configuration Examples

#### Stay on a given release

You can force the default for the `--version-to` by setting this option in the config. Note that this is redundant with `owut`'s default behavior (see the details of [Selecting a version](#selecting_a_version "docs:guide-user:installation:sysupgrade.owut ↵"), above).

```
config owut 'owut'
        option version_to '24.10'
```

#### Setting root file system size

Before you set this one, please read about [expanding the root file system](#expanding_root_file_system "docs:guide-user:installation:sysupgrade.owut ↵"), above, as this may not apply to your device.

For devices with expandable storage, typically x86, RISC-V and ARM SBCs, you may find it useful to expand the root file system size thus allowing you to easily install a larger number of packages or store more persistent data.

```
config owut 'owut'
        option rootfs_size 512
```

#### Persistent uci-defaults

If you've used custom `uci-defaults`, you are probably aware that the scripts are deleted from `/etc/uci-defaults/` on first boot. For an immutable installation, typically using a `squashfs` file system, you can view and recover your custom script from `/rom/etc/uci-defaults/`, but on an `ext4` file system, there is no `rom` partition, and the files are gone forever.

`owut` addresses this issue by allowing you to place your script on a persistent location, and then setting up the config file so that it becomes part of the installed image\*.

1. Create your init-script in a persistent location.
   
   ```
   $ mkdir /etc/owut.d/
   $ echo "# My first boot script." > /etc/owut.d/custom-init.sh
   ```
2. Make sure it is carried over in all `sysupgrade` backups.
   
   ```
   # The /etc/owut.d/ directory is part of standard backups, lets make sure...
   $ sysupgrade -l | grep custom
   /etc/owut.d/custom-init.sh
   ```
3. Configure `owut` to include the script into your builds.
   
   ```
   $ uci set attendedsysupgrade.owut=owut
   $ uci set attendedsysupgrade.owut.init_script=/etc/owut.d/custom-init.sh
   $ uci commit
   $ uci show attendedsysupgrade.owut
   attendedsysupgrade.owut=owut
   attendedsysupgrade.owut.init_script='/etc/owut.d/custom-init.sh'
   ```
4. Verify that everything is set up properly. Your script should appear in the json as the `defaults` entry.
   
   ```
   $ owut blob
   {
     "client": "owut/%%VERSION%%",
     "target": "x86/64",
     "profile": "generic",
     "version": "SNAPSHOT",
     "version_code": "r26773-85d9fd6f0e",
     "filesystem": "ext4",
     "diff_packages": true,
     "packages": [
       "base-files",
       "btop",
       "busybox",
       ... a bunch more packages ...
       "ucode-mod-uloop",
       "urandom-seed",
       "urngd"
     ],
     "defaults": "# My first boot script.\n"
   }
   ```

\* - As of June 2024, you can also accomplish this latter part by creating an image with the [OpenWrt Firmware Selector](https://firmware-selector.openwrt.org/ "https://firmware-selector.openwrt.org/"), manually pasting the script into its `Script to run on first boot (uci-defaults)` field.

## FAQ

Q: There's no option in `owut` to upgrade *without* keeping the config. I can do it with `auc -n`, why not `owut`?

A: This is (or should be) a rare thing to do, so it is intentionally made difficult with `owut`. The solution is to simply use `owut` to create the image and then run `sysupgrade` stating your desire to throw away the configuration. Leaving it thus makes sure you really mean to do this, as it is highly destructive.

```
$ owut download
...
$ sysupgrade -n /tmp/firmware.bin
```

* * *

Q: I have a big miniPC as my router. Why can't I create an image with `--rootfs-size 120000` and use all of my 128 GB drive?

A: The upper bound is dictated to be 1024 MB by the ASU server for practical reasons. The way the partitions are created on some devices requires that the full-sized image be created and then compressed, which takes a *lot* of RAM, disk and time.

As a test, I did a few imagebuilder runs with rootfs partitions ranging from the default (for x86) of 104 MB up to 20000 MB to see how long they would take.

ROOTFS\_PARTSIZE= real user img size 104 26s 18s 12M 512 48s 25s 13M 1024 74s 33s 13M 10000 11m47s 4m36s 32M 20000 28m15s 13m9s 32M

Those last two rows should make fairly clear why increasing the upper limit is infeasible, until such time as the build process is reworked to reduce the time required to create larger images.

Note: the above tests were all run on an AMD R9 7950x 5.8GHz CPU with 64GB CL6000 RAM and PCIe 4 SSD, which is generally 3x faster than the ASU server hardware, so these numbers are *well* below what you'd see if using ASU server.

You can run your own build timing tests by [downloading](https://downloads.openwrt.org "https://downloads.openwrt.org") and installing an imagebuilder, running `make info` to select a profile, then running the following.

```
profile=generic  # Set this to your desired profile from 'make info'.
for size in 104 256 512 1024 2048 4096 10240; do
    printf "Part size: %s" "$size"
    time /usr/bin/make image PROFILE=$profile ROOTFS_PARTSIZE=$size 2&>1 | grep -i error
done
```

## References

- `owut` - [github source](https://github.com/efahl/owut "https://github.com/efahl/owut"), [OpenWrt packaging](https://github.com/openwrt/packages/tree/master/utils/owut "https://github.com/openwrt/packages/tree/master/utils/owut")
- ASU server - [github source](https://github.com/openwrt/asu "https://github.com/openwrt/asu"), [API documentation](https://sysupgrade.openwrt.org/ui/ "https://sysupgrade.openwrt.org/ui/")
- `auc` - [wiki page](/docs/guide-user/installation/attended.sysupgrade#from_the_cli "docs:guide-user:installation:attended.sysupgrade"), see [final commit](https://github.com/openwrt/packages/commit/3a998e10218c318511b41739f276e572c1ede967 "https://github.com/openwrt/packages/commit/3a998e10218c318511b41739f276e572c1ede967") removing `auc` from the package feed
- LuCI Attended Sysupgrade - [wiki page](/docs/guide-user/installation/attended.sysupgrade#from_luci_web_page "docs:guide-user:installation:attended.sysupgrade"), [github source](https://github.com/openwrt/luci/tree/master/applications/luci-app-attendedsysupgrade "https://github.com/openwrt/luci/tree/master/applications/luci-app-attendedsysupgrade")
- Firmware Selector - [github source](https://github.com/openwrt/firmware-selector-openwrt-org "https://github.com/openwrt/firmware-selector-openwrt-org"), [build site](https://firmware-selector.openwrt.org/ "https://firmware-selector.openwrt.org/")
- Docker container builds - [github source](https://github.com/openwrt/docker "https://github.com/openwrt/docker")
- OpenWrt buildbots - [github source](https://github.com/openwrt/buildbot "https://github.com/openwrt/buildbot")
- Downloads site - [OpenWrt build artifacts and release archive](https://downloads.openwrt.org/ "https://downloads.openwrt.org/")
- Dashboards - [OpenWrt buildbot dashboards](https://buildbot.staging.openwrt.org/ "https://buildbot.staging.openwrt.org/")
- `ucode` - [Reference Manual](https://ucode.mein.io/ "https://ucode.mein.io/")
- `ucode-mod-uclient` - [github source](https://github.com/openwrt/uclient/blob/master/ucode.c "https://github.com/openwrt/uclient/blob/master/ucode.c")
