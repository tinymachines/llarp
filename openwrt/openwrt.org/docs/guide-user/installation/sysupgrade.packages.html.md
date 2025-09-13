# Preserving OpenWrt packages

See also: [Attended Sysupgrade](/docs/guide-user/installation/attended.sysupgrade "docs:guide-user:installation:attended.sysupgrade"), [Opkg extras](/docs/guide-user/advanced/opkg_extras "docs:guide-user:advanced:opkg_extras"), [Hotplug extras](/docs/guide-user/advanced/hotplug_extras "docs:guide-user:advanced:hotplug_extras")

Manually removed/installed packages are not preserved by default during firmware upgrade. There are different solutions to this problem.

## Solutions

### Sysupgrade

Include user-installed packages in your backup with [sysupgrade](/docs/techref/sysupgrade "docs:techref:sysupgrade").

```
sysupgrade -k -b - \
| tar -O -z -x -f - etc/backup/installed_packages.txt \
| awk -e '/\s(overlay|unknown)$/{print $1}'
```

### Opkgscript by richb-hanover

Copy [opkgscript](https://github.com/richb-hanover/OpenWrtScripts/blob/master/opkgscript.sh "https://github.com/richb-hanover/OpenWrtScripts/blob/master/opkgscript.sh") to your router. Ideally in a directory which will be preserved after flashing so you don't have to copy it again. Make it executable:

```
chmod +x /path/to/the/opkgscript.sh
```

Create a snapshot of the installed packages:

```
/path/to/the/opkgscript.sh -v write
```

By default the script will save the list in /etc/config/opkg.installed, which is preserved over flashing. When you log back in after the upgrade configure the internet connectivity, run and wait until it finished with the installation:

```
/path/to/the/opkgscript.sh -v install
```

### Script by gsenna

[Default packages attitude 12.09rc2 tplink 1043nd](https://forum.openwrt.org/viewtopic.php?id=43480 "https://forum.openwrt.org/viewtopic.php?id=43480")

```
cat << "EOF" > /tmp/listuserpackages.sh
echo >&2 User-installed packages are the following:
sed -ne '/^Package:[[:blank:]]*/ {
    s///
    h
}
/user installed/ {
    g
    p
}' /usr/lib/opkg/status
EOF
chmod +x /tmp/listuserpackages.sh
/tmp/listuserpackages.sh
```

### Script by valentijn

This script will only output a list of user and default installed packages.

```
cat << "EOF" > /tmp/listuserpackages.awk
#!/usr/bin/awk -f
/^Package:/{PKG= $2}
/^Status: .*user installed/{print PKG}
EOF
chmod +x /tmp/listuserpackages.awk
/tmp/listuserpackages.awk /usr/lib/opkg/status
```

### Script by tboege

Shows every package installed after the rom was build (flash\_time), if no packages are depending on it. Packages, that are manually installed may be omitted, since one of the listed packages must depends of such a package, all manually installed packages will be installed, if the listed packages are installed.

```
cat << "EOF" > /tmp/listuserpackages.awk
#!/usr/bin/awk -f
BEGIN {
    ARGV[ARGC++] = "/usr/lib/opkg/status"
    cmd="opkg info busybox | grep '^Installed-Time: '"
    cmd | getline FLASH_TIME
    close(cmd)
    FLASH_TIME=substr(FLASH_TIME,17)
}
/^Package:/{PKG= $2}
/^Installed-Time:/{
    INSTALLED_TIME= $2
    # Find all packages installed after FLASH_TIME
    if ( INSTALLED_TIME > FLASH_TIME ) {
        cmd="opkg whatdepends " PKG " | wc -l"
        cmd | getline WHATDEPENDS
        close(cmd)
        # If nothing depends on the package, it is installed by user
        if ( WHATDEPENDS == 3 ) print PKG
    }
}
EOF
chmod +x /tmp/listuserpackages.awk
/tmp/listuserpackages.awk
```

### Script by mforkel and Rafciq

[Identify packages to be re-installed after system upgrade](https://forum.openwrt.org/viewtopic.php?id=42739 "https://forum.openwrt.org/viewtopic.php?id=42739")

### Legacy scripts

This command will list all packages related to any file in the whole file system that has changed from the default OpenWrt default version.

Note that the script may list several packages that are part of the default OpenWrt install and will have their changed configuration files automatically backed up and restored. In addition, packages installed as dependencies of other packages may show here. It is only important to note the names of packages that you directly installed manually. Any dependencies of these packages will automatically be reinstalled if required.

```
# OpenWrt 14.07 or earlier
find /overlay \
| while read -r FILE
do opkg search "${FILE#/overlay}"
done \
| sed -n -e "s/\s.*//p" \
| sort -u
 
# OpenWrt 15.05 or later
find /overlay/upper \
| while read -r FILE
do opkg search "${FILE#/overlay/upper}"
done \
| sed -n -e "s/\s.*//p" \
| sort -u
```
