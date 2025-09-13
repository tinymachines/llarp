# Opkg package manager

Like most Linux distributions (or mobile device operating systems like say Android or iOS), the functionality of the system can be upgraded rather significantly by downloading and installing pre-made packages from package repositories (local or on the Internet).

The `opkg` utility is the lightweight package manager used for this job. Opkg is a fork of `ipkg`, the package manager used in NSLU2's [Optware](https://web.archive.org/web/20200919214711if_/http://www2.nslu2-linux.org/wiki/pmwiki.php?pagename=Optware%2FHomePage "https://web.archive.org/web/20200919214711if_/http://www2.nslu2-linux.org/wiki/pmwiki.php?pagename=Optware/HomePage")(archive link), which is designed to add software to stock firmware of embedded devices.

Opkg is a full package manager for the root file system, including kernel modules and drivers, while ipkg is just a way to add software to a separate directory (e.g. `/opt`).

Opkg is sometimes called *Entware*, as it is also the package manager used by the [Entware repository](https://github.com/Entware/Entware/wiki "https://github.com/Entware/Entware/wiki") for embedded devices (itself a fork of OpenWrt's community packages repository).

The package manager `opkg` attempts to resolve dependencies with packages in the repositories - if this fails, it will report an error and abort the installation of that package.

Missing dependencies with third-party packages are probably available from the source of the package.  
To ignore dependency errors, pass the `--force-depends` flag.

![:!:](/lib/images/smileys/exclaim.svg) If you are using a snapshot / trunk / bleeding edge version, installing packages may fail if the package in the repository is for a newer kernel version than the kernel version you have.  
In this case, you will get the error message *“Cannot satisfy the following dependencies for…”*.  
For such usage of OpenWrt firmware, it's warmly recommended to use the [Image Builder](/docs/guide-user/additional-software/imagebuilder "docs:guide-user:additional-software:imagebuilder") to make a flashable image containing all packages you need.

![:!:](/lib/images/smileys/exclaim.svg) When on trunk/snapshot, kernel and kmod packages are flagged as *hold*, the `opkg upgrade` command won't attempt to update them.

## Invocation

```
# opkg
opkg must have one sub-command argument:
usage: opkg [options...] sub-command [arguments...]
where sub-command is one of:
```

You can use [glob patterns](https://en.wikipedia.org/wiki/Glob_%28programming%29 "https://en.wikipedia.org/wiki/Glob_(programming)").

## Package manipulation

`update` Update list of available packages  
This simply retrieves a file like this one: [example](https://downloads.lede-project.org/snapshots/packages/aarch64_armv8-a/base/Packages "https://downloads.lede-project.org/snapshots/packages/aarch64_armv8-a/base/Packages"), for your installation and stores it on your [RAM partition](https://en.wikipedia.org/wiki/tmpfs "https://en.wikipedia.org/wiki/tmpfs") under `/tmp/opkg-lists`. As of LEDE 17.01, after the opkg upgrade, this folder occupies about 450 KiB of space. OPKG needs the content of this folder in order to install or upgrade packages or to print info about them. You can safely delete the contents of this folder anytime to free up some RAM (its content is also lost on reboot), don't forget to run `opkg update` again before you install a new package. `upgrade <pkgs>` Upgrade packages  
To upgrade a group of packages, run `opkg upgrade packagename1 packagename2`.  
A list of upgradeable packages can be obtained with the `opkg list-upgradable` command.  
\------------  
![:!:](/lib/images/smileys/exclaim.svg) Since OpenWrt firmware stores the base system in a compressed read-only partition, any update to base system packages will be written in the read-write partition and therefore use more space than it would if it was just overwriting the older version in the compressed base system partition. It's recommended to check the available space in internal flash memory and the space requirements for updates of base system packages.  
Upgrading packages you installed should not have this issue as they are already in the read-write partition so the new one will overwrite the older one, although checking before upgrading never hurts.  
As a general rule of thumb, devices that have 8 MiB or more total flash size and no user-installed packages should not have space issues when updating base packages, and of course devices set up for [Extroot](/docs/guide-user/additional-software/extroot_configuration "docs:guide-user:additional-software:extroot_configuration") won't have any space issue.  
To check for free space, write `df -h /` from SSH or go in Software page in Luci webinterface (System submenu -→ Software) to see how much space is left in the internal storage.  
Check the size of packages you want to update by writing `opkg info package-name` in SSH or by checking the package size listed in the table in Software page, or you can check the [Table of Packages](/packages/start "packages:start") here in the wiki. While the “size” in opkg is the size of package in a compressed archive, the jffs2 or ubifs read-write partition will use the same compression algorithm on the installed files, so it should have similar size when installed.  
![:!:](/lib/images/smileys/exclaim.svg) The package repositories in the development snapshots are updated by the build bots to new versions very often, so it's very likely you won't be able to upgrade some packages due to broken dependencies with kernel or kernel-related packages. In that case, it's recommended to use the [Image Builder](/docs/guide-user/additional-software/imagebuilder "docs:guide-user:additional-software:imagebuilder") and make a new firmware image with all packages you need and flash that instead of upgrading through opkg. `install <pkgs|url>` Install package(s)  
Examples:

```
opkg install hiawatha
opkg install http://downloads.openwrt.org/snapshots/trunk/ar71xx/packages/hiawatha_7.7-2_ar71xx.ipk
opkg install /tmp/hiawatha_7.7-2_ar71xx.ipk
```

If you are installing a package to 'replace' a busybox applet, you may need to invalidate your shell's command hash table entry in order to use the new command. To do this, either log out and back in again, or use `hash -r`.

`configure <pkgs>` Configure unpacked package(s) `remove <pkgs|globp>` Remove package(s) `flag <flag> <pkgs>` Flag one or multiple package(s). Only one flag per invocation is allowed. Available flags:  
hold • noprune • user • ok • installed • unpacked

## Informational commands

`list [pkg|globp]` List available packages

```
Package name - Version - Description
```

The Description can contain line breaks, so using merely grep is inapt since grep is line-based.

`list-installed` List installed packages `list-upgradable` List installed and upgradable packages `list-changed-conffiles` List user modified configuration files `files <pkg>` List files belonging to &lt;pkg&gt;. The package has to be already installed for this to work. Example:

```
opkg files asterisk18
Package asterisk18 (1.8.4.4-1) is installed on root and has the following files:
/usr/lib/asterisk/modules/res_rtp_multicast.so
/usr/lib/asterisk/modules/codec_ulaw.so
/etc/asterisk/features.conf
/usr/lib/asterisk/modules/format_wav_gsm.so
/usr/lib/asterisk/modules/app_macro.so
/usr/lib/asterisk/modules/chan_sip.so
/usr/lib/asterisk/modules/app_dial.so
/usr/lib/asterisk/modules/app_playback.so
/usr/lib/asterisk/modules/format_gsm.so
/usr/lib/asterisk/modules/func_callerid.so
/usr/lib/asterisk/modules/func_timeout.so
/etc/asterisk/asterisk.conf
/etc/asterisk/modules.conf
/usr/lib/asterisk/modules/format_wav.so
/etc/asterisk/extensions.conf
/etc/init.d/asterisk
/etc/asterisk/manager.conf
/usr/lib/asterisk/modules/res_rtp_asterisk.so
/etc/asterisk/logger.conf
/etc/asterisk/rtp.conf
/usr/lib/asterisk/modules/codec_gsm.so
/etc/asterisk/indications.conf
/usr/lib/asterisk/modules/func_strings.so
/usr/lib/asterisk/modules/app_echo.so
/usr/lib/asterisk/modules/format_pcm.so
/etc/asterisk/sip_notify.conf
/etc/asterisk/sip.conf
/etc/default/asterisk
/usr/sbin/asterisk
/usr/lib/asterisk/modules/pbx_config.so
/usr/lib/asterisk/modules/func_logic.so
```

`search <file|globp>` List package providing &lt;file&gt; `info [pkg|globp]` Display all info for &lt;pkg&gt;

```
Package: horst
Version: 2.0-rc1-2
Depends: libncurses
Provides:
Status: install user installed
Section: net
Architecture: ar71xx
Maintainer: Bruno Randolf <br1@einfach.org>
MD5Sum: 378cea9894ec971c419876e822666a6a
Size: 19224
Filename: horst_2.0-rc1-2_ar71xx.ipk
Source: feeds/packages/net/horst
Description: [horst] is a scanning and analysis tool for 802.11 wireless networks and
 especially IBSS (ad-hoc) mode and mesh networks (OLSR).
```

**Note 1:** The *Size* is the size of the gzip compressed tar archive. At installation package gets un-tared and decompressed, but then again JFFS2 uses compression itself.  
**Note 2:** Since the compression of JFFS2 is transparent, commands like `ls` will always report the size of the uncompressed file.

`status [pkg|globp]` Display all status for &lt;pkg&gt; `download <pkg>` Download &lt;pkg&gt; to current directory `compare-versions <v1> <op> <v2>` Compare versions `v1` and `v2` using the operators `<=`, `<`, `>`, `>=`, `=`, `<<` or `>>` `print-architecture` List installable package architectures `whatdepends [-A] [pkgname|pat]+` This only works for installed packages. So if you would like to know how much storage a package and all of its dependencies would need, at the moment, you will have to piece this information together with the `info`-option. `whatdependsrec [-A] [pkgname|pat]+` This only works for installed packages. So if you would like to know how much storage a package and all of its dependencies would need, at the moment, you will have to piece this information together with the `info`-option. `whatprovides [-A] [pkgname|pat]+` `whatconflicts [-A] [pkgname|pat]+` `whatreplaces [-A] [pkgname|pat]+`

## Options

Option Long Description `-A` Query all packages not just those installed `-V[<level>]` `--verbosity[=<level>]` Set verbosity level to &lt;level&gt;. Available verbosity levels:  
0 errors only  
1 normal messages (default)  
2 informative messages  
3 debug  
4 debug level 2 `-f <conf_file>` `--conf <conf_file>` Use &lt;conf\_file&gt; as the opkg configuration file. Default is `/etc/opkg.conf` `--cache <directory>` Use a package cache `-d <dest_name>` `--dest <dest_name>` Use &lt;dest\_name&gt; as the the root directory for package installation, removal, upgrading. &lt;dest\_name&gt; should be a defined dest name from the configuration file, (but can also be a directory name in a pinch). `-o <dir>` `--offline-root <dir>` Use &lt;dir&gt; as the root directory for offline installation of packages. `--add-arch <arch>:<prio>` Register architecture with given priority `--add-dest <name>:<path>` Register destination with given path Force Options `--force-depends` Install/remove despite failed dependencies `--force-maintainer` Overwrite preexisting config files `--force-reinstall` Reinstall package(s) `--force-overwrite` Overwrite files from other package(s) `--force-downgrade` Allow opkg to downgrade packages `--force-space` Disable free space checks `--force-checksum` Ignore checksum mismatches `--force-postinstall` Run postinstall scripts even in offline mode `--noaction` No action -- test only `--download-only` No action -- download only `--nodeps` Do not follow dependencies `--force-removal-of-dependent-packages` Remove package and all dependencies `--autoremove` Remove packages that were installed automatically to satisfy dependencies `-t` `--tmp-dir` Specify tmp-dir.

## Examples

### Basics

```
# Install a package
opkg update
opkg install <package>
 
# List packages
opkg list
 
# Display package information
opkg info <package>
```

### Extras

You can make use of [glob patterns](https://en.wikipedia.org/wiki/Glob_%28programming%29 "https://en.wikipedia.org/wiki/Glob_(programming)") directly and also write a little [shell script](https://en.wikipedia.org/wiki/Shell%20script "https://en.wikipedia.org/wiki/Shell script") to use [regular expressions](https://en.wikipedia.org/wiki/Regular%20expression "https://en.wikipedia.org/wiki/Regular expression") and otherwise further process information. Use a [pipeline](https://en.wikipedia.org/wiki/Pipeline_%28Unix%29 "https://en.wikipedia.org/wiki/Pipeline_(Unix)") and [grep](http://man.cx/grep%281%29 "http://man.cx/grep%281%29"), or [awk](http://man.cx/awk%281%29 "http://man.cx/awk%281%29"), or [sed](http://man.cx/sed%281%29 "http://man.cx/sed%281%29") to filter that output:

```
opkg list | grep -e <pattern1> -e <pattern2>
opkg list | awk -e '/<pattern>/{print $0}'
opkg info kmod-nf-\* | awk -e '/length/{print $0}'
opkg list-installed | awk -e '{print $1}' | tr '\n' ' '
for pkg in <package1> <package2> <package3>; do opkg info ${pkg}; done
opkg depends dropbear
```

### Upgrading packages

Mass upgrade of all packages is [strongly discouraged](/meta/infobox/upgrade_packages_warning "meta:infobox:upgrade_packages_warning"). The chance of soft-bricking your device is significant, so be fully prepared to perform a [recovery and factory reset in failsafe mode](/docs/guide-user/troubleshooting/failsafe_and_factory_reset "docs:guide-user:troubleshooting:failsafe_and_factory_reset"). Proceed at your own risk.

```
# Upgrade all installed packages
opkg list-upgradable | cut -f 1 -d ' ' | xargs opkg upgrade
```

## Configuration

The main configuration file is `/etc/opkg.conf`. It could look like this:

```
dest root /
dest ram /tmp
lists_dir ext /var/opkg-lists
option overlay_root /overlay
```

As you can see, it sets default folders:

- default root directory (default `/` )
- default ram disk (default `/tmp` )
- default folder to store package lists (default `/var/opkg-lists`, still a ram disk)
- what is the overlay directory (default `/overlay`)

Most of these options must be left to default, or have no real reason to be changed.

You might want to change the `lists_dir ext /var/opkg-lists` to `lists_dir ext /path/on/disk` if your device has 32 MiB or less of RAM and [you expanded your firmware's storage space in an external drive](/docs/guide-user/additional-software/extroot_configuration "docs:guide-user:additional-software:extroot_configuration"), so you can use opkg without causing Out Of Memory errors.

This file is accessible and can be modified from Luci Web interface too, Click on **Services** then on **Software**. Click on **Configuration** tab.

### Adjust repositories

Feeds are set in `/etc/opkg/distfeeds.conf`:

```
src/gz reboot_core http://downloads.lede-project.org/snapshots/targets/ramips/mt7620/packages
src/gz reboot_base http://downloads.lede-project.org/snapshots/packages/mipsel_24kc/base
src/gz reboot_telephony http://downloads.lede-project.org/snapshots/packages/mipsel_24kc/telephony
src/gz reboot_packages http://downloads.lede-project.org/snapshots/packages/mipsel_24kc/packages
src/gz reboot_routing http://downloads.lede-project.org/snapshots/packages/mipsel_24kc/routing
src/gz reboot_luci http://downloads.lede-project.org/snapshots/packages/mipsel_24kc/luci
```

There is also another file for custom feeds called `/etc/opkg/customfeeds.conf`:

```
# add your custom package feeds here
#
# src/gz example_feed_name http://www.example.com/path/to/files
```

Both files are accessible and can be modified from Luci Web interface too, Click on **Services** then on **Software**. Click on **Configuration** tab, then scroll down.

#### Local repositories

You can configure opkg to fetch the packages locally:

```
src/gz local file:///path/to/packagesDirectory
```

OpenWrt uses multiple repositories, where every repository requires a unique identifier. It is logical to use their original names, e.g.:

```
...
src/gz base file:///path/to/packages/directory/packages/base
src/gz luci file:///path/to/packages/directory/packages/luci
src/gz packages file:///path/to/packages/directory/packages/packages
src/gz oldpackages file:///path/to/packages/directory/packages/oldpackages
... etc ...
```

### Change architectures

OpenWrt is using package architectures. Many devices pull packages from the same pool.

The following paragraph requires proofreading and likely some modification to be adapted for the current OpenWrt status.

By default, opkg only allows packages with the architecture `all` (= architecture independent) and the architecture of the installed target. In order to download and install packages for a foreign target architecture, the list of allowed architectures can be overridden in `/etc/opkg.conf` with the use of `arch` options:

```
arch all 100
arch brcm4716 200
arch brcm47xx 300
```

This example would allow installing `brcm47xx` packages (compiled to run on `brcm47xx` family of SoC/devices) on the `brcm4716` (a specific SoC) target. The number specifies a priority index which is used by `opkg` to determine which package to prefer in case it is available in multiple architectures.

### Proxy support

OpenWrt 21.02:

```
# Configure profile
mkdir -p /etc/profile.d
cat << "EOF" > /etc/profile.d/custom.sh
export https_proxy=http://proxy.example.org:8080/
EOF
. /etc/profile
 
# Workaround
sed -i -e "s/https/http/" /etc/opkg/distfeeds.conf
```

To use `opkg` through a proxy, add the following to `/etc/opkg.conf`:

```
option http_proxy http://proxy.example.org:8080/
option ftp_proxy ftp://proxy.example.org:2121/
```

Use the options below to authenticate against the proxy server:

```
option proxy_user xxxx
option proxy_passwd xxxx
```

Alternatively, a username and password may be provided as part of the URL if busybox wget is installed:

```
option http_proxy http://username:password@proxy.example.org:8080/
option ftp_proxy http://username:password@proxy.example.org:2121/
```

![:!:](/lib/images/smileys/exclaim.svg) Authentication currently fails when using uclient-fetch as wget due to `Proxy-Authorization` not yet being implemented.

If you are running apt-cacher-ng and want to use that for OpenWRT, you may experience problems downloading .sig files through apt-cacher-ng. In that case put the following line in your `acng.conf` file:

```
VfilePatternEx: |\.sig$
```

## Troubleshooting

### Verbose opkg update

```
# Save the script
cat << "EOF" > opkg-update.sh
#!/bin/sh
rm -f -R /tmp/opkg-lists
mkdir -p /tmp/opkg-lists
while read TYPE REPO URL
do
wget -O /tmp/opkg-lists/"${REPO}".gz "${URL}"/Packages.gz
wget -O /tmp/opkg-lists/"${REPO}".sig "${URL}"/Packages.sig
gunzip -k /tmp/opkg-lists/"${REPO}".gz
usign -V -P /etc/opkg/keys -m /tmp/opkg-lists/"${REPO}" 2>&1 \
| grep -e "^OK$" \
&& mv -f /tmp/opkg-lists/"${REPO}".gz /tmp/opkg-lists/"${REPO}"
done < /etc/opkg/distfeeds.conf
EOF
chmod +x opkg-update.sh
 
# Run the script
./opkg-update.sh
```

### Out of space

Remove partly installed packages and their dependencies if *opkg* runs out of space during a transaction.

```
# Save the script
cat << "EOF" > opkg-rm-pkg-deps.sh
#!/bin/sh
opkg update
URL="$(opkg --force-space --noaction install "${@}" \
| sed -n -e "/^Downloading\s*/s///p")"
rm -f /usr/lib/opkg/lock
for URL in ${URL}
do FILE="$(wget -q -O - "${URL}" \
| tar -O -x -z ./data.tar.gz \
| tar -t -z \
| sort -r \
| sed -e "s|^\.|/overlay/upper|")"
for FILE in ${FILE}
do if [ -f "${FILE}" ]
then rm -f "${FILE}"
elif [ -d "${FILE}" ]
then rmdir "${FILE}"
fi
done
done
EOF
chmod +x opkg-rm-pkg-deps.sh
```

```
# Run the script
./opkg-rm-pkg-deps.sh package_name
 
# Reboot to make the free space visible
reboot
```

### Local repository

There may be use cases where having a package repository on the device itself is advantageous:

- Unreliable WANs, where the connectivity upstream of the device to a remote repository goes down for an unacceptable period of time.
- Bandwidth Caps, where the connectivity upstream of the device to a remote repository has a limited amount of data that can be fetched before the connectivity is throttled or goes down until the next period where the cap resets.
- A repository with customization; built from source, which isn't available from remote repositories.
- The device acts as a reference device for other systems, to ensure that the package versions across the devices local to the network remain consistent.

Set up a local repository for your target. Assuming about 2-3 GB of free space is available.

```
# Install packages
opkg update
opkg install rsync
 
# Save the script
cat << "EOF" > local-repo-sync.sh
#!/bin/sh
. /etc/os-release
REPO_LOCAL="file://${1:-/${ID}}/"
REPO_URL="rsync://rsync.${HOME_URL#*//}"
case "${VERSION_ID}" in
(snapshot) REPO_DIR="downloads/snapshots" ;;
(*) REPO_DIR="downloads/releases/${VERSION_ID}" ;;
esac
REPO_CORE="${REPO_DIR}/targets/${OPENWRT_BOARD}"
REPO_PKGS="${REPO_DIR}/packages/${OPENWRT_ARCH}"
for REPO_DIR in "${REPO_CORE}" "${REPO_PKGS}"
do mkdir -p "${REPO_LOCAL#*//}${REPO_DIR#*/}"
rsync --bwlimit="8M" --del -r -t -v \
"${REPO_URL}${REPO_DIR}/" \
"${REPO_LOCAL#*//}${REPO_DIR#*/}/"
done
EOF
chmod +x local-repo-sync.sh
 
# Run the script
./local-repo-sync.sh /openwrt
 
# Configure Opkg to use local repo
. /etc/os-release
REPO_LOCAL="file:///${ID}/"
REPO_URL="https://downloads.${HOME_URL#*//}"
sed -i -e "s|${REPO_URL}|${REPO_LOCAL}|" /etc/opkg/distfeeds.conf
 
# Share the repository on the LAN
ln -f -s ${REPO_LOCAL#*//} /www/${ID}
 
# Configure Opkg on the clients
. /etc/os-release
REPO_LOCAL="http://192.168.1.1/${ID}/"
REPO_URL="https://downloads.${HOME_URL#*//}"
sed -i -e "s|${REPO_URL}|${REPO_LOCAL}|" /etc/opkg/distfeeds.conf
```

See also: [How to mirror](/downloads#how_to_mirror "downloads")

## Non-standard installation destinations

Due to its history (fork of ipkg), opkg can specify a destination different than root for package installation, but since most packages don't support this natively, it's more a curiosity than actually useful.

The recommended way to have more space to install your packages is [Extroot](/docs/guide-user/additional-software/extroot_configuration "docs:guide-user:additional-software:extroot_configuration")

This solution will NOT work out-of-the-box in most cases, OpenWrt packages are designed to be installed in root filesystem and may need additional symlinks or modifications to work at all under the changed path!

The default `/etc/opkg.conf` actually contains three destinations:

```
dest root /
dest ram /tmp
dest mnt /mnt
```

The format of destination lines is simply the keyword dest, followed by a name for this destination (this can be anything), followed by a filesystem location. Any destination that has been thus configured can then be specified on the opkg command line like this:

```
opkg -d destination_name install somepackage
```

The *dest* argument must refer to one of the defined destinations in `/etc/opkg.conf`, e.g. `-d ram` to install packages to `/tmp/`.

If you want to install kernel modules on any other destination than root, you might want to read this first: [https://dev.openwrt.org/ticket/10739](https://dev.openwrt.org/ticket/10739 "https://dev.openwrt.org/ticket/10739")
