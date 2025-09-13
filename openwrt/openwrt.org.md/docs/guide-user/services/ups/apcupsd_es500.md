# APC BackUps ES-500 - Linksys EA3500 - LuCI graphs

This describes how to connect an APC BackUps ES-500 via the USB port on a Linksys EA3500 router. This includes collecting the data, and displaying graphs. This page is closely related to [APC SmartUps SU-700 - Linksys EA3500 - LuCI graphs](/docs/guide-user/services/ups/apcupsd_su700 "docs:guide-user:services:ups:apcupsd_su700"), which is worth reviewing as well, especially if you run into difficulties.

Note that the collected data will be lost after a reboot of the router. To save the data, you need to put it on an external device, like a USB flash drive. Connecting both the UPS and a flash drive to a USB hub, which is then connected to the router, works fine for me.

- Plug in UPS, and connect the cable from the UPS to the router USB port. This is a custom cable that comes with the UPS.
- in the router command line or LuCI web pages, install packages: apcupsd, collectd-mod-apcups and kmod-usb-hid
- for command line, the commands are:
  
  ```
  opkg update
  opkg install kmod-usb-hid
  opkg install apcupsd
  opkg install collectd-mod-apcups
  ```
- On the router command line, verify that the USB HID driver is installed and working with command and response:
  
  ```
  # ls -la /dev/usb
  crw-------    1 root     root      180,  96 Jul 13 14:34 hiddev0
  ```
- If you don't see a line for hiddev#, then something is wrong with the install of kmod-usb-hid.
- Resolve this, before proceeding.

<!--THE END-->

- The next step is to customize the apcupsd config file.
- Details of the options can be found at [http://www.apcupsd.org/manual/manual.html](http://www.apcupsd.org/manual/manual.html "http://www.apcupsd.org/manual/manual.html"), in the section “Configuration Directive Reference”.
- On the router command line, go to the /etc/apcupsd directory, and edit it
  
  ```
  # cd /etc/apcupsd
  # vi
  ```
- use the dd command to delete all the lines in the file
- use the i command to set the VI editor into “insert” mode.
- Copy and paste this text into the editor:
  
  ```
  ## apcupsd.conf v1.1 ##
  UPSNAME myups
  UPSCABLE usb
  UPSTYPE usb
  DEVICE /dev/usb/hid/hiddev[0-15]
  LOCKFILE /var/lock
  ONBATTERYDELAY 6
  BATTERYLEVEL 5
  MINUTES 3
  TIMEOUT 0
  ANNOY 300
  ANNOYDELAY 60
  NOLOGON disable
  KILLDELAY 0
  NETSERVER on
  NISIP 0.0.0.0
  NISPORT 3551
  EVENTSFILE /var/log/apcupsd.events
  # max kilobytes
  EVENTSFILEMAX 10
  UPSCLASS standalone
  UPSMODE disable
  # ===== Configuration statements to control apcupsd system logging ========
  # Time interval in seconds between writing the STATUS file; 0 disables
  STATTIME 0
  # Location of STATUS file (written to only if STATTIME is non-zero)
  STATFILE /var/log/apcupsd.status
  LOGSTATS off
  # Time interval in seconds between writing the DATA records to
  # the log file. 0 disables.
  DATATIME 0
  ```
- type :wq into the editor, to write the new apcupsd.conf, and quit the edit session
- restart the apcupsd deamon process:
  
  ```
   
  # /etc/init.d apcupsd restart
  ```
- Enter the apcaccess command into the command line, and you should get output like this:
  
  ```
  # apcaccess
  root@g70outside:~# apcaccess 
  APC      : 001,034,0829
  DATE     : 2017-07-15 12:29:26 -0700  
  HOSTNAME : myrouter
  VERSION  : 3.14.14 (31 May 2016) unknown
  UPSNAME  : myups
  CABLE    : USB Cable
  DRIVER   : USB UPS Driver
  UPSMODE  : Stand Alone
  STARTTIME: 2017-07-13 14:34:46 -0700  
  MODEL    : Back-UPS ES 500 
  STATUS   : ONLINE 
  ...
  ```
- Note the STATUS : ONLINE
- If you don't have “ONLINE”, then something is wrong
- Restart the LuCI statistics data collection:
  
  ```
  # /etc/init.d/luci_statistics restart
  ```
- In the router web interface, go to Statistics, Graphs, APC UPS
- You should see the graphs, with data starting on the right side.
- If not, wait a minute, refresh your browser and you should start to see data being written.

## Troubleshooting

If you don't have APC UPS graphs at this point, here are some things to check:

- There should be a tab for APC UPS on the General Plugins page at:
  
  ```
  http://192.168.1.1:88/cgi-bin/luci/admin/statistics/collectd/general
  ```

<!--THE END-->

- /var/etc/collectd.conf should have a section for apcups:
  
  ```
  LoadPlugin apcups
   <Plugin apcups>
    Host localhost
    Port "3551"
   </Plugin>
  ```
  
  If it does not, you can regenerate /var/etc/collectd.conf with this command:
  
  ```
  /usr/bin/stat-genconfig > /var/etc/collectd.conf
  ```

<!--THE END-->

- If you still don't have APC UPS graphs, you may not have the patches that added luci-statistics support for the apcups plugin: [https://github.com/openwrt/luci/pull/1227](https://github.com/openwrt/luci/pull/1227 "https://github.com/openwrt/luci/pull/1227"). The best fix for this is to upgrade to a version that does.
