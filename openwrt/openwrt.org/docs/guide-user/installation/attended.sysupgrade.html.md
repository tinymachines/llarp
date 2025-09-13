# Upgrade using Attended Sysupgrade

The Attended SysUpgrade (ASU) facility allows an OpenWrt device to update to new firmware while preserving the packages and settings. This dramatically simplifies the upgrade process: just a couple clicks and a short wait lets you retrieve and install a new image built with all your previous packages.

ASU eliminates the need to make a list of packages you installed manually, or fuss with opkg just to upgrade your firmware.

Because it is initiated by a person who waits until it's complete, it's called “attended” sysupgrade. You can see Attended Sysupgrade in action in a video from OneMarcFifty at: [https://www.youtube.com/watch?v=FFTPA6GkJjg&amp;t=1034s](https://www.youtube.com/watch?v=FFTPA6GkJjg&t=1034s "https://www.youtube.com/watch?v=FFTPA6GkJjg&t=1034s")

There is both a LuCI (web page interface) and command-line package for Attended Sysupgrade.

## From LuCI web page

The [luci-app-attendedsysupgrade](/packages/pkgdata/luci-app-attendedsysupgrade "packages:pkgdata:luci-app-attendedsysupgrade") package provides a page in the router's web interface. It requests a new firmware image built with the current set of packages, waits until it's ready, then downloads and flashes the image. If “Keep Configuration” is checked in the GUI, the device preserves all the settings.

To install `luci-app-attendedsysupgrade`, go to **System → Software**, update the package list, and search for *luci-app-attendedsysupgrade*. Install it in the usual manner.

To upgrade your firmware:

- **Make a backup!** Go to **System → Backup/Flash firmware**. Click **Generate archive** *(Just do it. Every time...)*
- Go to **System → Attended Sysupgrade**. You'll see the main Attended Sysupgrade window
- Click **Search for sysupgrade** You will see choices for the firmware version that are available.
- Select the desired version from the dropdown, and click **Request Sysupgrade**
- There may be a wait as the server builds a custom image that includes all the packages that are currently installed.
- When that completes, you will see a window describing the new firmware:
  
  - If you wish to keep settings, check the box. Otherwise, settings will be erased and set to factory default.
  - Click **Install Sysupgrade** and the router will download the new image, flash it, and reboot.
  - You'll be running the new firmware, with all your packages and settings intact.

[![  ](/_media/media/doc/asu-main.png?w=400&tok=a7a7d2 "  ")](/_detail/media/doc/asu-main.png?id=docs%3Aguide-user%3Ainstallation%3Aattended.sysupgrade "media:doc:asu-main.png") This is the main window. Click **Search for sysupgrade**

[![  ](/_media/media/doc/asu-upgrade-choice.png?w=400&tok=7ced13 "  ")](/_detail/media/doc/asu-upgrade-choice.png?id=docs%3Aguide-user%3Ainstallation%3Aattended.sysupgrade "media:doc:asu-upgrade-choice.png") Choose one of the available releases and click **Request Sysupgrade**

[![  ](/_media/media/doc/asu-sysupgrade-ready.png?w=400&tok=27e976 "  ")](/_detail/media/doc/asu-sysupgrade-ready.png?id=docs%3Aguide-user%3Ainstallation%3Aattended.sysupgrade "media:doc:asu-sysupgrade-ready.png") Verify the parameters of the newly-generated image,  
choose Keep Settings (or not) and click **Install Sysupgrade**

## From the CLI

For OpenWrt 24.10 and later, including snapshots, [owut](/docs/guide-user/installation/sysupgrade.owut "docs:guide-user:installation:sysupgrade.owut") package performs the same process as the `luci-app-attendedsysupgrade` package, but is run from SSH/the command line instead of the web GUI.

If you are using an older version of OpenWrt, 23.05 or before, then the [auc](/packages/pkgdata/auc "packages:pkgdata:auc") package is available. For detail on `auc`, continue on this page; for more on `owut`, go to the [owut page](/docs/guide-user/installation/sysupgrade.owut "docs:guide-user:installation:sysupgrade.owut").

### auc

To install the `auc` package, ssh into the router and enter `opkg install auc` or in the web interface, go to **System → Software**, update the package list, and search for *auc*. Install it in the usual manner.

To upgrade your device firmware, first **Make A Backup** *(see first step above)* Then enter `auc` on the command line. The default is to get the next version. You can specify the following options on the command line.

```
root@openwrt.lan:~# auc --help
auc (0.2.4-8)
auc: Attended sysUpgrade CLI client
Usage: auc [-b <branch>] [-B <ver>] [-c] [-f] [-h] [-r] [-y]
 -b <branch>	use specific release branch
 -B <ver>	use specific release version
 -c		only check if system is up-to-date
 -f		use force
 -h		output help
 -n		dry-run (don't download or upgrade)
 -r		check only for release upgrades
 -F <fstype>	override filesystem type
 -y		don't wait for user confirmation

Please report issues to improve the server:
https://github.com/aparcar/asu/issues
```

Here are the details of each option.

Name Default Description `-b <branch>` installed branch Search for updates on this specific branch. The value is a string containing a release branch name, `19.07` or `23.05`, or the snapshot branch name, `SNAPSHOT`. `-B <ver>` newest version on current branch Search for updates for this specific release version. Must be on the branch specified with `-b` or an error will be reported. If the branch is `SNAPSHOT`, then the only valid value for `-B` is again `SNAPSHOT`, and specifying the value is redundant. `-c` false Perform all the steps to check if the system is up-to-date, then quit. If changes are found, then a list of the detected differences is shown, color coded so that you can see if packages are upgrading or downgrading with the target branch and version.

Since this is a completely non-destruction operation, running `auc -c` is a quick and safe way to see what changes have been released since your last sysupgrade. `-f` false Force an upgrade, even when there are no changes detected. `-n` false Perform a dry-run, by actually building the image, but then quit before download and install. Since the image is never downloaded, this is very much like `-c` in its local effect, but since it builds the image, you see all the error checking performed by the build server, too. `-r` false Check only for release upgrades. Like `-c`, but ignores any package changes. This is a quick way to see if there is a “dot” release on the branch currently installed. `-F <fstype>` current installed fstype, usually `squashfs` Build the image to override the current filesystem type. This is an advanced option, which can brick many devices, so use great care. On generic devices, like `x86` or `armsr`, you can switch between `squashfs` and `ext4` without issues. `-y` false Assume 'yes' for all the user confirmation prompts and run to completion.

### Example use

To use `auc` to check for new packages, or newer versions of the current branch, simply use the `-c` option. This is completely benign, as `auc` terminates after reporting what it sees without doing anything further. Using `-c` to experiment with the other options is a safe way to explore how `auc` works.

```
$ auc -c
auc/0.3.2-1
Server:    https://sysupgrade.openwrt.org
Running:   SNAPSHOT r24414-255d5c9bf8 on x86/64 (generic)
Available: SNAPSHOT r24414-255d5c9bf8
Requesting package lists...
 base-files: 1548-r24414-255d5c9bf8 -> 1549-r24427-c4fe1bfc65
 dnsmasq-full: 2.89-6 -> 2.89-7
```

By default, `auc` works on the branch currently installed on your device. The `-b` option can be used to change this behavior, so that you can upgrade or downgrade between release branches (like `19.07` or `23.05`) or snapshot (where you just literally use `snapshot` as the value). The `-B` option can be used to select a specific version within a branch, such as `22.03.1` or `23.05.0`.

This example detects that 23.05.2 is installed, and shows information related to downgrading to 22.03.4. As indicated by the warning, this is probably not a good idea as the jump in versions is “too far”, but you \*can* use `-B` to downgrade within a branch pretty safely.

```
$ auc -c -b 22.03 -B 22.03.4
auc/0.3.2-1
Server:    https://sysupgrade.openwrt.org
Running:   23.05.2 r23630-842932a63d on x86/64 (generic)
Available: 22.03.4 r20123-38ccc47687
WARNING: Downgrade to older branch may not work as expected!
Requesting package lists...
 kmod-usb-storage: 5.15.137-1 -> 5.10.176-1
 terminfo: 6.4-2 -> 6.3-2
 openssh-sftp-server: 9.5p1-1 -> 9.3p2-1
 libopenssl: 3.0.12-1 -> 1.1.1w-1
 luci-app-statistics: git-23.315.63824-5a81162 -> git-23.153.53801-38f5b55
...
```

## ASU Server

The ASU Server listens for image requests and, if valid, automatically generates them. It coordinates several OpenWrt ImageBuilders and caches the resulting images in a Redis database. If an image is cached, the server can provide it immediately without rebuilding.

The ASU Server provides an API to request custom firmware images with any selection of packages pre-installed. This avoids the need to set up a build environment, and makes it possible to create a custom firmware image even using a mobile device.

- The current production ASU Server is `sysupgrade.openwrt.org` It provides released versions, release candidates, and the current nightly snapshot.
- There is an development server at `asu.aparcar.org` that may or may not always be running
- chef.libremesh.org is an old server name that currently is a CNAME to asu.aparcar.org
- The [OpenWrt Firmware Selector](https://firmware-selector.openwrt.org/ "https://firmware-selector.openwrt.org/") is a client of the ASU server, as are the LuCI web page and `auc`.

ASU relies on significant updates over the last several years to the ImageBuilder, primarily by @aparcar. [Github repo](https://github.com/openwrt/asu "https://github.com/openwrt/asu")

### Sysupgrade with Extroot configuration

Note that if your device is configured for Extroot, then you will need to reboot twice after any type of sysupgrade. The external root filesystem does not remount after the first boot. There is no need to modify or recreate extroot settings, just reboot again and the configuration will work as before and continue to do so.
