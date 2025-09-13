# Failsafe mode, factory reset, and recovery mode

OpenWrt offers several ways to “start over” with your router:

- [**Failsafe mode**](/docs/guide-user/troubleshooting/failsafe_and_factory_reset#failsafe_mode "docs:guide-user:troubleshooting:failsafe_and_factory_reset") is useful if you have lost control of your device, and it has become inaccessible, perhaps through a configuration error. It allows you to reboot the router into a basic operating state, retaining all your packages and (most) settings.
- [**Factory reset**](/docs/guide-user/troubleshooting/failsafe_and_factory_reset#factory_reset "docs:guide-user:troubleshooting:failsafe_and_factory_reset") erases all your packages and settings, returning the router to its initial state after installing OpenWrt.
- [**Recovery mode**](/docs/guide-user/troubleshooting/vendor_specific_rescue "docs:guide-user:troubleshooting:vendor_specific_rescue") allows you to install new firmware on a router that has become corrupted.

## Failsafe mode

OpenWrt allows you to boot into a **failsafe mode** that overrides its current configuration. If your device becomes inaccessible, e.g. after a configuration error, then failsafe mode is there to help you out. When you reboot in failsafe mode, the device starts up in a basic operating state, with a few hard coded defaults, and you can begin to fix the problem manually.

Failsafe mode can be triggered by pressing (almost any) button on the device shortly after powering it on during a pre-defined 2-4 second window. Each router is unique, but OpenWrt watches for a WPS, Reset, or other button press.

Failsafe mode **cannot**, however, fix more deeply rooted problems like faulty hardware or a broken kernel. It is similar to a reset, however with failsafe, you can access your device and restore settings if desired, whereas a reset would just wipe everything.

**Caveat:** Failsafe mode is only available if you have installed firmware from a Squashfs image, that includes the required read-only root partition, and all your later changes are in a separate /overlay partition &amp; directory. To verify whether your device has the SquashFS root partition, check for “squashfs” either in the OpenWrt image name or perform the following check on your device:

```
grep squash /proc/mounts
```

The terminal should return something similar to this:

```
/dev/root /rom squashfs ro,relatime 0 0
```

### Entering failsafe mode

Failsafe mode starts the router with the IP address 192.168.1.1, and disables DHCP and wireless connectivity. You will need to set your PC to a static address on the same subnet (e.g., 192.168.1.10) and connect via Ethernet. Sometimes you need to connect to a specific network port of your router to get connectivity. **Try the LAN1 port first.** DSA devices frequently enable [LAN1 only](https://forum.openwrt.org/t/adding-openwrt-support-for-xiaomi-ax3600/55049/9760 "https://forum.openwrt.org/t/adding-openwrt-support-for-xiaomi-ax3600/55049/9760").

On most routers, OpenWrt will blink an LED (usually “Power”) during the boot process. Early in the boot cycle, OpenWrt watches for a button press (any button) inside a specific four second window to indicate that it should enter failsafe mode. (Note: four seconds in 24.10 and later OpenWrt versions, but only two seconds on 23.05 and earlier versions.)

**To enter failsafe mode, follow one of the procedures listed below:**

**Simplest - recommended for most people: Power on the device, wait for a flashing LED and press a button.** This can be the WPS, Reset, or other button on the device.

The LEDs provide clues for timing the button press. Watch the LED blinking speeds immediately after powering up the router. Most routers show three different (power) LED blinking speeds during boot:

- A power-on sequence of lights that is specific to the device's bootloader
- Then a semi-rapid 5-per-second blinking rhythm during four seconds, while router waits for a button press
- Then either:
  
  - A really fast 10-per-second blink if failsafe mode was triggered. The device is listening on 192.168.1.1
  - A slower, 2.5-per-second blink continuing to the end of normal boot, if the failsafe was not triggered
- If you missed the timing and see the slower blink rate, just power off the device, wait a couple seconds, and try again.

**Alternate for expert users: Wait (with a packet sniffer) for a special broadcast packet and press a button.** The packet will be sent to destination address 192.168.1.255 port UDP 4919. The packet contains the text “*Please press button now to enter failsafe*”. So for example, in a terminal and using tcpdump, with the router connected to port eth0 of your computer, you would enter the command

```
tcpdump -Ani eth0 port 4919 and udp
```

**Alternate for expert users with serial connection: Watch for a boot message on the serial console and press a key (“f”) on the serial keyboard.** This requires that you have attached a serial cable to the device. The message shown in the console is “*Press the \[f] key and hit \[Enter] to enter failsafe mode*”

Usually, it is easiest to watch the LEDs. However, do consult the available documentation for your device, as there is no default button assigned as a reset button and not all procedures work on every device. Whichever trigger you use, the device will enter failsafe mode and you can access the command line with SSH (always possible) or a serial keyboard.

Note that modern OpenWrt always uses SSH for terminal connections.

### Fixing your settings

Once failsafe mode is triggered, the router will boot with a network address of 192.168.1.1/24, usually on the `eth0` network interface, with only essential services running. When in failsafe mode, the DHCP server will not be running. You must set your computer's ethernet port to use a static IP address in the 192.168.1.0/24 network (valid IPs are 192.168.1.2 - 192.168.1.254, subnet mask 255.255.255.0)

Using SSH or a serial connection, you can then mount the JFFS2 partition with the following command:

```
mount_root
```

After that, you can start looking around and fix what’s broken. The JFFS2 partition will be mounted to `/overlay`, as under normal operation.

You can also transfer files by using scp command/protocol from Linux or macOS, or by using [WinSCP](/docs/guide-quick-start/sshadministration#winscp "docs:guide-quick-start:sshadministration") from Windows.

Additional steps required for [Extroot](/docs/guide-user/additional-software/extroot_configuration "docs:guide-user:additional-software:extroot_configuration") setups:

```
# unplug external device
reboot
 
# plug external device
# mount external device, e.g.
block info
mount /dev/mmcblk0 /mnt
 
# fix the issue, e.g.
vi /mnt/upper/etc/config/network
 
# verify external device will be mounted automatically, e.g.
vi /overlay/upper/etc/config/fstab
reboot
```

Tipp: If you are not able to use `mount_root` and you get the message `jffs2 not ready yet, using temporary tmpfs overlay` . Please check your filesystem with `df -h` and when it is full (used 100%) the mount\_root command isn't working well and also a soft factory reset isn't working. In this case use

```
 mtd -r erase rootfs_data 
```

After this you can follow with [soft\_factory\_reset](/docs/guide-user/troubleshooting/failsafe_and_factory_reset#soft_factory_reset "docs:guide-user:troubleshooting:failsafe_and_factory_reset")

## Factory reset

A factory reset returns your router to the configuration it had just after flashing. This works on any install with a squashfs / overlayfs setup (the norm for most installations), since it is based on erasing and reformatting the overlayfs.

With a large NOR chip, it can take 3 to 5 minutes for the overlayfs to be formatted in the flash. During this time, changes cannot be saved.

**Caveat:**

- Factory reset depends on completing the boot process. If factory reset is not working, try with failsafe mode instead.
- x86 builds (made for PC/Server hardware) with an ext4 read-write rootfs cannot be reset this way.

### Reset button

On devices with a physical reset button, OpenWrt can be reset to default settings without serial or SSH access.

1. Power on the device and wait for the status led to stop flashing (or go into failsafe mode, as described above).
2. Press and hold the reset button for 10 seconds.
3. Release the reset button.

The device will do a hard factory reset (see below) and then reboot. This operation can be slow on some devices, so wait a few minutes before connecting again.

### Soft factory reset

If you want a clean slate, there’s no need to flash again; just enter the following commands. Your device's settings will be reset to defaults like when OpenWrt was first installed.

Issuing `firstboot` or `jffs2reset` (or `factoryreset` in main/master after Dec 2024) command will attempt to delete all files from the jffs2 overlay partition. Note that this “soft reset” is performed with file system actions, so in some cases it is not enough.

```
firstboot && reboot
```

Note: If the commands above (all on one line) don't work, try those commands on separate lines in the terminal.

Note: for most routers, `firstboot` actually just issues a `jffs2reset` command, so there is not much difference compared to the “hard reset” advice below.

Note: if you're issuing this command inside a bash script, remember to add the option -y to force firstboot:

```
firstboot -y && reboot
```

Here is a log of soft factory reset process in action, obtained via serial connection, during router startup**:**

- ```
  ...
  Press the [f] key and hit [enter] to enter failsafe mode
  Press the [1], [2], [3] or [4] key and hit [enter] to select the debug level
  f
  - failsafe -
  /etc/preinit: line 1: /sbin/mtk_failsafe.sh: not found
  /etc/preinit: line 1: dropbearkey: not found
  /etc/preinit: line 1: dropbear: not found
  
  BusyBox v1.25.1 () built-in shell (ash)
  
  ash: can't access tty; job control turned off
       _________
      /        /\      _    ___ ___  ___
     /  LE    /  \    | |  | __|   \| __|
    /    DE  /    \   | |__| _|| |) | _|
   /________/  LE  \  |____|___|___/|___|                      lede-project.org
   \        \   DE /
    \    LE  \    /  -----------------------------------------------------------
     \  DE    \  /    Reboot (17.01-SNAPSHOT, r0-e88ba24)
      \________\/    -----------------------------------------------------------
  
  ================= FAILSAFE MODE active ================
  special commands:
  * firstboot	     reset settings to factory defaults
  * mount_root	 mount root-partition with config files
  
  after mount_root:
  * passwd			 change root's password
  * /etc/config		    directory with config files
  
  for more help see:
  http://wiki.openwrt.org/doc/howto/generic.failsafe
  =======================================================
  
  admin@(none):/# firstboot && reboot
  [  102.942293] jffs2reset: This will erase all settings and remove any installed packages. Are you sure? [N/y]
  y
  [  117.606813] jffs2reset: /dev/mtdblock6 is not mounted
  [  117.612055] jffs2reset: /dev/mtdblock6 will be erased on next mount
  reboot
  admin@(none):/# [  119.810569] ===> rt_pci_shutdown()
  ...
  ```

Tips**:** after (a OpenWrt based) router reboots or starts, it goes thru the bootmenu (selection menu for boot options) within 1 to 2 seconds (or, within 1 second, after preset delay time has passed). The boot menu accepts Up/Down &amp; Enter buttons, so avoid those or any other buttons for that period of time. After that bootmenu stage, within 3 to 8 seconds later (depending on CPU speed, etc) the failsafe mode appears &amp; passes, so you have to press the “f” button within that time only for once (one time), then press Enter to enter into failsafe mode.

### Hard factory reset

#### Re-flashing the firmware

Re-flash or upgrade the firmware discarding the settings.

```
sysupgrade -n /path/to/firmware
```

OpenWrt preserves settings [by default](/docs/guide-quick-start/admingui_sysupgrade_keepsettings "docs:guide-quick-start:admingui_sysupgrade_keepsettings"), so you need to opt-out to achieve factory reset.

#### JFFS2 reset

Reset the JFFS2 partition.

```
umount /overlay && jffs2reset && reboot
```

Based on the mount status of the overlay, jffs2reset [selects](https://git.openwrt.org/?p=project%2Ffstools.git%3Ba%3Dblob%3Bf%3Djffs2reset.c%3Bh%3Ddbe049881f5%3Bhb%3DHEAD#l43 "https://git.openwrt.org/?p=project/fstools.git;a=blob;f=jffs2reset.c;h=dbe049881f5;hb=HEAD#l43") either a file-based delete operation or a partition mark-it-empty action to be re-created at boot.

Note: the `jffs2reset` command was renamed to `factoryreset` in December 2024.

#### F2FS reset

Reset the F2FS partition.

```
dd if=/dev/zero of=/dev/loop0 bs=1M; reboot
```
