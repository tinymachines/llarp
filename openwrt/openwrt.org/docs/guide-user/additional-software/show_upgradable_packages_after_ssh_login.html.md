# Show available package upgrades after SSH login

Blindly upgrading packages (manually or via script) can lead you into all sorts of trouble.

Just because there is an updated version of a given package does not mean it should be installed or that it will function properly. Ensure yourself **before** doing upgrade that it would be safe. Almost for sure [avoid upgrading core packages](https://forum.openwrt.org/t/upgrade-the-packages-on-snapshot/53158/2?u=tmomas "https://forum.openwrt.org/t/upgrade-the-packages-on-snapshot/53158/2?u=tmomas").

* * *

There are two ways to manage and install packages in OpenWrt: with the LuCI web interface (System &gt; Software), and via the command line interface (CLI). Both methods invoke the same [opkg](https://openwrt.org/docs/guide-user/additional-software/opkg "https://openwrt.org/docs/guide-user/additional-software/opkg") command. As of OpenWrt 19.07.0, the LuCI interface now has an 'Updates' tab with a listing of packages that have available upgrades. The LuCI `Upgrade...` button performs the same `opkg upgrade` command that is discussed in this article. **The same warnings apply to upgrading packages using LuCI and the CLI.**

* * *

Generally speaking, **the use of `opkg upgrade` is very highly discouraged**. It should be avoided in almost all circumstances. In particular, bulk upgrading is very likely to result in major problems, but even upgrading individual packages may cause issues. It is also important to stress that this is distinctly different from the `sysupgrade` path for upgrading OpenWrt releases (major versions as well as maintenance upgrades). `opkg upgrade` will not update the OpenWrt version. Only `sysupgrade` can do that. The two are not equivalent.

Unlike the “big distros” of Linux, OpenWrt is optimized to run on systems with limited resources. This includes the opkg package manager, which does not have built-in ABI (Application Binary Interface) compatibility and kernel version dependencies verification. Although sometimes there may be no issues, there is no guarantee and the upgrade can result in various types of incompatibilities that can range from minor to severe, and it may be very difficult to troubleshoot. In addition, the `opkg upgrade` process will consume flash storage space. Since it does not (and cannot) overwrite the original (stored in ROM), it must store the upgraded packages in the r/w overlay.

In the vast majority of cases, any security patches of significant importance/risk will be rapidly released in an official stable maintenance release to be upgraded using the `sysupgrade` system. This is the recommended method for keeping up-to-date.

Those looking to be on the bleeding edge can consider using the snapshot releases, but should be mindful of the differences between stable and snapshot. Or, alternatively, build a custom image with the desired updated packages included in that image. The remaining users who still want to use `opkg upgrade` should only do so with *selected individual packages* (do not bulk update, and do not blindly update) and they should be aware that **problems may occur that could necessitate a complete reset-to-defaults to resolve**.

If you're already having issues, or wish to “undo” the upgraded packages: create a backup (optional; can be restored after the reset is complete) and then perform a reset to defaults (`firstboot`).

**If you do choose to upgrade packages, especially with a script,** you have been warned. Don't complain on the forum, and be ready to deal with the consequences, troubleshooting, and resolution yourself.

## See also

- [Video: How to upgrade OpenWrt?](https://www.youtube.com/watch?v=FFTPA6GkJjg "https://www.youtube.com/watch?v=FFTPA6GkJjg")
- [Upgrading OpenWrt firmware using LuCI and CLI](/docs/guide-user/installation/generic.sysupgrade "docs:guide-user:installation:generic.sysupgrade")

If you would like a simple way to view packages with available upgrades when you login via ssh (this will have no effect when you login to LuCI), you can achieve this with two simple steps:

1. Create a user profile script that checks the package list for upgradable packages
2. Schedule “opkg update” with crontab to keep the package lists up-to-date,

Or simply integrate the update check in the user profile script so everything is run on login.

When this is running, you will see the following when you login via ssh:

```
  _______                     ________        __
 |       |.-----.-----.-----.|  |  |  |.----.|  |_
 |   -   ||  _  |  -__|     ||  |  |  ||   _||   _|
 |_______||   __|_____|__|__||________||__|  |____|
          |__| W I R E L E S S   F R E E D O M
 -----------------------------------------------------
 OpenWrt 18.06.1, r7258-5eb055306f
 -----------------------------------------------------

151 packages are installed.
4 packages can be upgraded.

root@OpenWrt:~#
```

You may then choose to upgrade one or several packages, or all packages in one command.

## Create user profile script

To create the user profile script, you need to be logged-in as root via SSH. This example uses nano as the text editor (since it is a bit easier to use as the system default text editor `vim`), but you can of course create the script with the editor of your choice.

```
nano ~/.profile
```

```
#!/bin/sh

opkgInstalled="$(opkg list-installed 2> /dev/null | wc -l)" #silencing error output
opkgUpgradable="$(opkg list-upgradable 2> /dev/null | wc -l)" #silencing error output

echo "$opkgInstalled packages are installed." && echo "$opkgUpgradable packages can be upgraded." && echo
```

## Automate package updates

For the above script to work, the package lists must be available and up-to-date at login time. Updating the packages list can be automated in three ways:

1. in regular intervalls → crontab
2. at each startup / booting → startup script
3. on login → using the same profile script

### via crontab

![:!:](/lib/images/smileys/exclaim.svg) Keep in mind that this will occupy precious RAM space on low memory devices (16+32MB). See the third method for a low-ram-friendly script.

Schedule crontab to “opkg update” once per week, either via LuCI or via commandline.

- via LuCI: Add below lines via *LuCi &gt; System &gt; Scheduled Tasks*
- via command line: `crontab -e` → add below lines

```
1 0 * * 0 /bin/opkg update # Update list of available packages every Sunday 00:01
# crontab and fstab must end with the last line a space or comment
```

You can change the interval as you like, but keep in mind that every interval below 24h is a waste of resources, since release packages do not get compiled that often.

### via startup script

![:!:](/lib/images/smileys/exclaim.svg) This method only works if you frequently reboot your hardware. Keep in mind that this will occupy precious RAM space on low memory devices (16+32MB). See the third method for a low-ram-friendly script.

If you prefer to run “opkg list” only once at startup, rather than in regular intervals as shown above, you can do so by means of the startup script `rc.local`.

- via LuCI: Add below lines via *LuCi &gt; System &gt; Startup &gt; Local Startup*
- via commandline: edit `etc/rc.local` and add below lines

```
/bin/opkg update # Update list of available packages
exit 0
```

Now everytime you login with Dropbear (SSH) you will see the number of total packages installed and how many packages can be upgraded.

### via the same profile script

You can place the updating commands in the same profile file, as that script is executed each time the user logs in with ssh or serial console.

The main drawback is that the user will have to wait a few seconds for the update to finish before they can start writing commands, which if all goes well is just a few seconds. It will be quite a bit more if there is no internet access, as opkg will take a while to figure out that there is no internet connection. So a check for internet connectivity is included. If no internet is detected the update is skipped.  
For the sake of being low-RAM friendly, there is a check that deletes automatically the package lists if the device has less then 32 MiB of free RAM.

This is the whole .profile script:

```
nano ~/.profile
```

```
#!/bin/sh

if wget -q --spider https://openwrt.org/; then  # if OpenWrt website/wiki is available we update
  echo "You are connected to the internet. Checking for updates, please wait..." && echo
  opkg update > /dev/null 2>&1 #silenced standard output and error output

  opkgInstalled="$(opkg list-installed 2> /dev/null | wc -l)" #silencing error output
  opkgUpgradable="$(opkg list-upgradable 2> /dev/null | wc -l)" #silencing error output

  echo "$opkgInstalled packages are installed." && echo "$opkgUpgradable packages can be upgraded." && echo
  
  memLimit=32000 # in bytes
  if [ "$(grep MemFree /proc/meminfo | awk '{print$2}')" -lt $memLimit ]; then
    for opkg_package_lists in /var/opkg-lists/*
    do
      if [ -f "$opkg_package_lists" ]; then #prevent error if opkg update fails
        rm -r /var/opkg-lists/*
        echo "Warning: Memory limit $memLimit bytes. Removed downloaded package lists to save memory."
        echo #only remove when free RAM is less than set memory limit (default 32 MiB)
      fi
    done
  fi
  else
  echo "You are not connected to the internet. Unable to check for updates." && echo
fi
```

### Preserving your script on firmware upgrade

By default, firmware upgrade procedure does not back up `/root/.profile` so we need to add it to the list of custom files to back up.

```
echo  '/root/.profile #my profile with update script '  >> /etc/sysupgrade.conf
```

Other files created or modified by this tutorial (chrontabs and /etc/rc.local) are already in the whitelist of files preserved.

For more information, please check the [Upgrading OpenWrt from the Command Line](/docs/guide-user/installation/sysupgrade.cli "docs:guide-user:installation:sysupgrade.cli")

## Upgrading OpenWrt packages in one command

`opkg upgrade package_name` allow upgrading one package. To upgrade all packages, follow [check\_for\_any\_upgradable\_packages](/docs/guide-user/installation/generic.sysupgrade#check_for_any_upgradable_packages "docs:guide-user:installation:generic.sysupgrade").

Note that package upgrades are processed without order and be sure to have sufficient space on your device. Automating OpenWrt package upgrades is strongly discouraged, unless you manage a central repository and push upgrades from there.

### Closing thoughts

If you have a better way of doing this, please update this user guide. You can also add the above script to “/etc/profile” which is the system default, but you are better off keeping that untouched as to prevent issues.

Enjoy!
