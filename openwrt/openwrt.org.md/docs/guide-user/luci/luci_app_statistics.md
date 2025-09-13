# luci-app-statistics

OpenWrt includes real-time statistics however this does not store historical data for view by default. The luci-app-statistics package, based on collectd and rrdtool, will display historical graphs including ping, interface bandwidth utilization, cpu load, ram, disk, uptime, etc.

For more info see [statistical.data.overview](/docs/guide-user/perf_and_log/statistical.data.overview "docs:guide-user:perf_and_log:statistical.data.overview") and collectd [blog post](https://advanxer.com/2013/02/openwrt-monitoring-using-collectd/ "https://advanxer.com/2013/02/openwrt-monitoring-using-collectd/").

For other Bandwidth Monitoring tools, see [bwmon](/docs/guide-user/services/network_monitoring/bwmon "docs:guide-user:services:network_monitoring:bwmon") page.

## Installation

1\. Install package `luci-app-statistics`. If using SSH run: opkg update &amp;&amp; opkg install luci-app-statistics.

2\. Install desired plugins:

Several are suggested below, but many more exist. To see all the available collectd-modules, run: `opkg list | grep collectd-mod`

```
opkg install collectd-mod-ethstat collectd-mod-ipstatistics collectd-mod-irq collectd-mod-load collectd-mod-ping collectd-mod-powerdns collectd-mod-sqm collectd-mod-thermal collectd-mod-wireless
```

3\. Enable daemons

```
/etc/init.d/collectd enable
```

Note that `/tmp/rrd`, the directory that keeps statistics data, resides in RAM and consequently will be lost after a reboot. To prevent this, you can configure a persistent storage location or configure backups - see below.

## Configuration

### UCI

- View the config with `uci export luci_statistics`
- Edit `/etc/config/luci_statistics` to make changes

### LuCI

After installing the packages, a new menu appears in Statistics → Setup. All the installed collectd-modules will show here, but only some are enabled by default.

### Suggested settings

- **General Plugins tab:** Review the sub-tabs to choose which statistics to monitor
- **Network Plugins tab:** Select which interfaces to monitor
- **Output Plugins tab:**
  
  - *RRDtool sub-tab:* To protect flash-memory from wearing out, the default *Storage directory* is `/tmp/rrd`. All statistics data will be lost on reboot. Alternatives:
    
    - Configure backups for sysupgrade and orderly shutdown/reboot, by checking the *Backup RRD statistics* box, or by setting the UCI configuration variable: `uci set luci_statistics.collectd_rrdtool.backup=1`. The statistics are saved to flash-memory only at shutdown or sysupgrade time or when generating a backup archive. If your router crashes or suffers a power failure or other disorderly restart, the statistics history from the previous orderly shutdown will be restored during reboot. To create backups more frequently than shutdown/reboot/sysupgrade, create a cron job to run `service luci_statistics backup`. (Full details of the mechanism are explained at [https://github.com/openwrt/luci/tree/master/applications/luci-app-statistics#backups](https://github.com/openwrt/luci/tree/master/applications/luci-app-statistics#backups "https://github.com/openwrt/luci/tree/master/applications/luci-app-statistics#backups")).
    - Consider having an [automatic backup-restore script that runs when rebooting](https://github.com/sqrwf/openwrt-rrdbackup/ "https://github.com/sqrwf/openwrt-rrdbackup/")).
    - If you have a USB drive connected, set the *Storage directory* to a directory on that drive. Since pages are rendered by user 'nobody', the \*.rrd files, the storage directory and all its parent directories need to be world readable. See [https://forum.openwrt.org/t/trouble-with-luci-app-statistics-using-storage-directory-on-usb-drive/10683/4](https://forum.openwrt.org/t/trouble-with-luci-app-statistics-using-storage-directory-on-usb-drive/10683/4 "https://forum.openwrt.org/t/trouble-with-luci-app-statistics-using-storage-directory-on-usb-drive/10683/4").
    - Or use the *Network sub-tab* to send the statistics to another router/device that's acting as a collectd network listener.
  - *Network sub-tab:* collectd can either listen for other router's data, or send its data to other routers. The data collection interval must be the same in both devices in order to work properly.
