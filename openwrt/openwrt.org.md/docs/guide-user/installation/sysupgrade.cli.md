# Upgrading OpenWrt firmware using CLI

![:!:](/lib/images/smileys/exclaim.svg) **For experienced users only!**

- This HOWTO will upgrade an existing OpenWrt firmware to a new version from the SSH command line.
- A lot of information in this wiki page duplicates content of [generic OpenWrt OS upgrade procedure](/docs/guide-user/installation/generic.sysupgrade "docs:guide-user:installation:generic.sysupgrade").
- Non-experienced users are strongly advised to [Upgrading OpenWrt firmware using LuCI](/docs/guide-quick-start/sysupgrade.luci "docs:guide-quick-start:sysupgrade.luci") instead.
- If you need some configuration options changed for the first boot, for example you need Wi-Fi enabled after flashing, follow [this guide](/docs/guide-user/installation/flashing_openwrt_with_wifi_enabled_on_first_boot "docs:guide-user:installation:flashing_openwrt_with_wifi_enabled_on_first_boot").

## Back up OpenWrt configuration

Follow [Backup and restore](/docs/guide-user/troubleshooting/backup_restore "docs:guide-user:troubleshooting:backup_restore"), or skip this section if you do not want to preserve existing configuration.

## Download and verify the OpenWrt firmware upgrade image

Download and use only OpenWrt firmware images ending in **“-sysupgrade.bin”** for command line upgrades.  
For x86 systems there is no “sysupgrade” image, just be sure the new firmware image has the same family of filesystem as your old one.

![:!:](/lib/images/smileys/exclaim.svg) Note: upgrade files must be placed in /tmp, as the sysupgrade procedure unmounts flash storage during the upgrade process. If the upgrade file is not in **/tmp**, sysupgrade will NOT perform any upgrade and only reboot the system.

Download the desired upgrade file to your OpenWrt's `/tmp` directory and [verify firmware checksum](/docs/guide-quick-start/verify_firmware_checksum "docs:guide-quick-start:verify_firmware_checksum"). `/tmp` directory is stored in the device RAM:

1. Check free memory is available: Run `free`. Proceed, if “free Mem” is the size of your firmware file + some extra mem (at least twice the size of your firmware file is perfect).
2. Set the following variables to the download address of your OpenWrt firmware file (you must customize the URL!). You'll find a link to the file “sha256sums” in the Supplementary Files section of the download page for the architecture of your router, beneath the Image Files section:
3. ```
   DOWNLOAD_LINK="http://URLOFFIRMWAREBIN"; SHA256SUMS="http://URLOFSHA256"
   ```
4. Download and check the firmware checksum with:
   
   ```
   cd /tmp;wget $DOWNLOAD_LINK;wget $SHA256SUMS;sha256sum -c sha256sums 2>/dev/null|grep OK
   ```
5. In the screen output, look for the correct checksum verification:
   
   ```
   FILE_NAME: OK
   ```
6. Do not continue, if the checksum verification mismatches!

**Troubleshooting:**

- If you **cant use 'wget'** (e.g. because you want to transfer firmware from your PC to your OpenWrt device)
  
  - you can use **scp**: `scp openwrt-ar71xx-tl-wr1043nd-v1-squashfs-sysupgrade.bin root@192.168.1.1:/tmp` (Ensure you have set a non-null password for your device root account to properly use scp.)
  - you can use **ssh**: `ssh root@192.168.1.1 “cat > /tmp/openwrt-ar71xx-tl-wr1043nd-v1-squashfs-sysupgrade.bin” < openwrt-ar71xx-tl-wr1043nd-v1-squashfs-sysupgrade.bin` (Also ensure you have set a non-null password for your device root account.)
  - you can also use **nc/netcat**:
    
    1. On your Linux PC run: `cat [specified firmware].bin | pv -b | nc -l -p 3333`
    2. On your OpenWrt device run (Assuming 192.168.1.111 is the IP of your Linux PC): `nc 192.168.1.111 3333 > /tmp/[specified firmware].bin`
- If the **checksum mismatches**: Redo the firmware download, if the mismatch remains, ask for help in the ["Installing and Using OpenWrt" Forum](https://forum.openwrt.org/c/installation "https://forum.openwrt.org/c/installation")
- If **low on RAM** see: [CLI - Low Memory Workarounds](/docs/guide-user/installation/sysupgrade.cli#low_memory_workaroundstmp_is_too_small_to_hold_the_downloaded_file "docs:guide-user:installation:sysupgrade.cli")

### Command-line instructions

OpenWrt provides [sysupgrade](/docs/techref/sysupgrade "docs:techref:sysupgrade") utility for firmware upgrade procedure.

[Verify](/docs/guide-quick-start/verify_firmware_checksum "docs:guide-quick-start:verify_firmware_checksum") firmware image checksum. Verify the router has enough free RAM. Upload the firmware from local PC. Flash the firmware.

```
# Check the free RAM 
free
 
# Upload firmware
scp firmware_image.bin root@openwrt.lan:/tmp
 
# Flash firmware
sysupgrade -v /tmp/firmware_image.bin
```

**Troubleshooting:**

- If you get the error `ash: /usr/libexec/sftp-server: not found` for the scp command, you are using an OpenSSH Release &gt;= 9 which defaults to using sftp which is not installed by default on OpenWRT. To fallback to the legacy scp/rcp, use the -O flag: `scp -O firmware_image.bin root@openwrt.lan:/tmp`.

#### If sysupgrade is not available.

```
# Flash firmware
mtd -r write /tmp/firmware_image.bin firmware
```

- The sysupgrade verbose-option should give some output similar to this. The list of configuration files saved will change depending on what packages you have installed and which files you have configured to be saved, as per above.

```
Saving config files...
etc/config/dhcp
etc/config/dropbear
etc/config/firewall
etc/config/luci
etc/config/network
etc/config/snmpd
etc/config/system
etc/config/ubootenv
etc/config/ucitrack
etc/config/uhttpd
etc/config/wireless
etc/dropbear/authorized_keys
etc/dropbear/dropbear_dss_host_key
etc/dropbear/dropbear_rsa_host_key
etc/firewall.user
etc/group
etc/hosts
etc/inittab
etc/passwd
etc/profile
etc/rc.local
etc/shadow
etc/shells
etc/sudoers
etc/sudoers.d/custom
etc/sysctl.conf
etc/sysupgrade.conf
killall: watchdog: no process killed
Sending TERM to remaining processes ... ubusd askfirst logd logread netifd odhcpd snmpd uhttpd ntpd dnsmasq
Sending KILL to remaining processes ... askfirst
Switching to ramdisk...
Performing system upgrade...
Unlocking firmware ...

Writing from <stdin> to firmware ...  [w]
Appending jffs2 data from /tmp/sysupgrade.tgz to firmware...TRX header not found
Error fixing up TRX header
Upgrade completed
Rebooting system...
```

Note: The “TRX header not found” and “Error fixing up TRX header” errors are not a problem as per OpenWrt developer jow's post at [https://dev.openwrt.org/ticket/8623](https://dev.openwrt.org/ticket/8623 "https://dev.openwrt.org/ticket/8623")

- Wait until the router comes back online
- After the automatic reboot, the system should come up the same configuration settings as before: the same network IP addresses, same SSH password, etc.
- Proceed to the “Additional configuration after an OpenWrt upgrade” section, below

**Troubleshooting**

- In case it does not help, try a [cold reset](https://en.wikipedia.org/wiki/Booting#Hard_reboot "https://en.wikipedia.org/wiki/Booting#Hard_reboot") (= interrupt the electrical current to the device, wait a couple of seconds and then connect it again). Be careful about `/etc/opkg.conf` as explained [here](https://dev.openwrt.org/ticket/13309 "https://dev.openwrt.org/ticket/13309"). For unknown reasons such a cold reset has often been reported to be necessary after a sysupgrade. This is very very bad in case you performed this remotely.

## Flash the new OpenWrt firmware

1. The firmware file is now in /tmp, so you can start the flashing process
2. Preferably have an assistant physically present at the location of the device, if you upgrade it from remote (as some devices may require a hard reset after the update)
3. Execute the following command to upgrade:
   
   ```
   sysupgrade -v /tmp/firmware_image.bin
   ```
4. You can add the \`-n\` option if you DO NOT want to preserve any old configuration files and configure upgraded device from clean state (network/system settings will be lost as well)
5. While the new firmware gets flashed, an output similar to the following will be shown:
   
   ```
   Saving config files...
   etc/config/dhcp
   ...
   etc/config/wireless
   etc/dropbear/authorized_keys
   ...
   etc/sysupgrade.conf
   killall: watchdog: no process killed
   Sending TERM to remaining processes ... ubusd askfirst logd logread netifd odhcpd snmpd uhttpd ntpd dnsmasq
   Sending KILL to remaining processes ... askfirst
   Switching to ramdisk...
   Performing system upgrade...
   Unlocking firmware ...
   Writing from <stdin> to firmware ...  [w]
   Appending jffs2 data from /tmp/sysupgrade.tgz to firmware...TRX header not found
   Error fixing up TRX header
   Upgrade completed
   Rebooting system...
   ```
6. Ignore the “TRX header not found” and “Error fixing up TRX header” errors. These errors are not relevant according to [https://dev.openwrt.org/ticket/8623](https://dev.openwrt.org/ticket/8623 "https://dev.openwrt.org/ticket/8623")
7. Wait until the router comes back online. The system should come up the same configuration settings as before (same network IP addresses, same SSH password, etc.)

**Troubleshooting:**

- **does not reboot automatically or remains unresponsive**: Wait 5 minutes, then do a hard reset: Turn it off, wait 2-3 seconds and turn it back on (or pull the power plug and plug it back in).  
  ![:!:](/lib/images/smileys/exclaim.svg) Doing this while the device is still updating might softbrick it and require serial or even jtag connection to recover it. Such a cold restart has been reported to be required often after a sysupgrade by command line.
- **OPKG issues**: if after flashing you have issues with package installation or because opkg.conf has outdated data, read [https://dev.openwrt.org/ticket/13309](https://dev.openwrt.org/ticket/13309 "https://dev.openwrt.org/ticket/13309")
- **'sysupgrade' not available** on your OpenWrt device, you can use 'mtd' instead to flash the firmware: `mtd -r write /tmp/openwrt-ar71xx-generic-wzr-hp-ag300h-squashfs-sysupgrade.bin firmware`

## Post-upgrade steps

- Verify the new OS version: The simpler way to see if the firmware was actually upgraded. In SSH, the login banner states the release information like version and so on.
- If you used extroot, then see [this how-to](https://wiki.mbirth.de/know-how/software/openwrt/sysupgrade-with-extroot.html "https://wiki.mbirth.de/know-how/software/openwrt/sysupgrade-with-extroot.html") about restoring it.
- Check for any [upgradable packages](/docs/guide-user/additional-software/opkg#upgrading_packages "docs:guide-user:additional-software:opkg"). After the firmware update, it is good to check for any updated packages released after the base OS firmware image was built.
- Reinstall user-installed packages. After a successful upgrade, you will need to reinstall all previously installed packages according to your notes. Package configuration files should have been preserved due to steps above, but not the actual packages themselves. If you used the scripts provided in the forum, this step might not be necessary.

### Comparing new package config options

See also: [Opkg extras](/docs/guide-user/advanced/opkg_extras "docs:guide-user:advanced:opkg_extras"), [UCI extras](/docs/guide-user/advanced/uci_extras "docs:guide-user:advanced:uci_extras")

The new package installations will have installed new, default versions of package configuration files. As your existing configuration files were already in place, opkg would have displayed a warning about this and saved the new configuration file versions under `*-opkg` filenames.

The new package-provided configuration files should be compared with your older customized files to merge in any new options or changes of syntax in these files. The `diff` tool is helpful for this.

```
# Install packages
opkg update
opkg install diffutils
 
# Find new configurations
find /etc -name "*-opkg"
 
# Compare UCI configurations
diff /etc/config/snmpd /etc/config/snmpd-opkg
 
# Manually merge changes to the current config and remove default config
vi /etc/config/snmpd
rm /etc/config/snmpd-opkg
 
# Or replace current config with the default one
mv /etc/config/snmpd-opkg /etc/config/snmpd
 
# Apply changes
/etc/init.d/snmpd restart
reboot
```

### Low memory workarounds: /tmp is too small to hold the downloaded file

If your device's /tmp filesystem is not large enough to store the OpenWrt upgrade image, this section provides tips to temporarily free up RAM.

First check memory usage with the `free` or `top` or `cat /proc/meminfo` commands; proceed if you have as much free RAM as the image is in size plus an some additional MiB of free memory.

```
# free
             total         used         free       shared      buffers
Mem:         29540        18124        **11416**         0         1248
-/+ buffers:              16876        12664
Swap:            0            0            0
```

In this example there are precisely 11416 KiB of RAM unused. All the rest 32768 - 11416 = 21352 KiB are used somehow and a portion of it can and will be made available by the kernel, if it be needed, the problem is, we do not know how much exactly that is. Make sure *enough* is available. Free space in /tmp also counts towards free memory. Therefore with:

```
# free
Mem:         13388        12636          752            0         1292
Swap:            0            0            0
Total:       13388        12636          752
 
# df
Filesystem           1K-blocks      Used Available Use% Mounted on
/dev/root                 2304      2304         0 100% /rom
tmpfs                     6696        60      6636   1% /tmp
tmpfs                      512         0       512   0% /dev
/dev/mtdblock3             576       288       288  50% /overlay
mini_fo:/overlay          2304      2304         0 100% /
```

One has actually 752+6636 KiB of free memory available.

- quickest and safest way to free up, some RAM is to delete the package lists:

```
rm -r /tmp/opkg-lists/
```

- drop caches:

```
sync && echo 3 > /proc/sys/vm/drop_caches
```

- prevent wireless drivers to be loaded at next boot and then reboot:

```
rm /etc/modules.d/*80211*
rm /etc/modules.d/*ath9k*
rm /etc/modules.d/b43*
reboot
```

The wireless drivers usually take up quite some amount of RAM and are not required if you are connected by wire. You can delete the relevant symlinks in `etc/modules.d` and reboot to free up the RAM.

#### Still no room in /tmp?

Use [netcat](http://man.cx/netcat%281%29 "http://man.cx/netcat%281%29") only if you really cannot free **enough RAM** with other means. Any network issues during the process are likely to brick your device.

#### Flash using ssh

```
# Linux PC
cat firmware_image.bin | ssh root@openwrt.lan mtd write - firmware
```

#### Flash using netcat

```
# Linux PC
nc -q 0 192.168.1.1 1234 < openwrt-ar71xx-tl-wr1043nd-v1-squashfs-sysupgrade.bin
 
# OpenWrt
nc -l -p 1234 | mtd write - firmware
```
