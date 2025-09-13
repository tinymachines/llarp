# APC SmartUps SU-700 - Linksys EA3500 - LuCI graphs

This describes how to connect an APC SmartUps SU-700 via USB on a Linksys EA3500 router. This includes collecting the data, and displaying graphs.

- Plug in UPS
- Connect a 940-0024 serial cable to the UPS (I'm using a 940-0024c. Other 'smart' cables may work as well. See: [http://www.apcupsd.org/manual/manual.html#cables](http://www.apcupsd.org/manual/manual.html#cables "http://www.apcupsd.org/manual/manual.html#cables"))
- Connect other end of the cable to a serial-to-usb converter
  
  - Some converters work, some don't. A cable from eBay called “USB to RS232 Serial 9 Pin DB9 PIN PL2303 Cable Adapter” did not end up working for me, due to Linux driver issues. I ended up using a [https://www.iogear.com/product/GUC232A](https://www.iogear.com/product/GUC232A "https://www.iogear.com/product/GUC232A").
- Connect the serial-to-usb converter to the router USB port (or a USB hub, if you need multiple things plugged into the port).

<!--THE END-->

- In the router command line or LuCI web pages, install packages: apcupsd, collectd-mod-apcups, and kmod-usb-serial-pl2303
- For the command line, the commands are:
  
  ```
  opkg update
  opkg install kmod-usb-serial-pl2303
  opkg install apcupsd
  opkg install collectd-mod-apcups
  ```
- On the router command line, verify that the USB driver is installed and working with command and response:
  
  ```
  # ls -la /dev/ttyUSB*
  crw-------    1 root     root      188,   0 Dec  1 00:29 /dev/ttyUSB0
  ```
- If you don't see a serial port then something is wrong with the driver for the serial-to-usb converter.
- Resolve this, before proceeding.

<!--THE END-->

- The next step is to customize the apcupsd config file. Details of the options can be found at [http://www.apcupsd.org/manual/manual.html](http://www.apcupsd.org/manual/manual.html "http://www.apcupsd.org/manual/manual.html") , in the section “Configuration Directive Reference”.
- On the router command line, go to the /etc/apcupsd directory, and edit the config file:
  
  ```
  # cd /etc/apcupsd
  # vi apcupsd.conf
  ```
- use the dd command to delete all the lines in the file
- use the i command to set the VI editor into “insert” mode.
- Copy and paste this text into the editor:
  
  ```
  ## apcupsd.conf v1.1 ##
  UPSNAME APC700
  UPSCABLE smart
  UPSTYPE apcsmart
  DEVICE /dev/ttyUSB0
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
  #   the log file. 0 disables.
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
  APC      : 001,034,0829
  DATE     : 2017-12-01 18:11:01 -0700  
  HOSTNAME : myrouter
  VERSION  : 3.14.14 (31 May 2016) unknown
  UPSNAME  : APC700
  CABLE    : Custom Cable Smart
  DRIVER   : APC Smart UPS (any)
  UPSMODE  : Stand Alone
  STARTTIME: 2017-12-01 18:10:11 -0700  
  MODEL    : Smart-UPS 700 RM
  STATUS   : ONLINE 
  ...
  ```
- Note the STATUS : ONLINE . If you don't have “ONLINE”, then something is wrong

<!--THE END-->

- Reboot the router.

<!--THE END-->

- In the router web interface, go to Statistics, Graphs, APC UPS
- You should see the graphs, with data starting on the right side.
- If not, wait a minute, refresh your browser and you should start to see data being written.

## Saving the data across Reboots

- By default the collected data will be lost after a reboot of the router. To save the data, you need to put it on an external device, like a USB flash drive. Connecting both the UPS and a flash drive to a USB hub, which is then connected to the router, works fine for me.
- To put the data on an external device, go to Statistics / Setup / Output plugins / RRDTool ([http://192.168.1.1/cgi-bin/luci/admin/statistics/collectd/output/rrdtool](http://192.168.1.1/cgi-bin/luci/admin/statistics/collectd/output/rrdtool "http://192.168.1.1/cgi-bin/luci/admin/statistics/collectd/output/rrdtool")), and change the Storage directory to wherever you want to store your data.

## Troubleshooting

If you don't have APC UPS graphs at this point, here are some things to check:

1. Change the data collection interval to 10 seconds. This is a workaround for the issue reported in: [https://github.com/collectd/collectd/issues/617](https://github.com/collectd/collectd/issues/617 "https://github.com/collectd/collectd/issues/617").
   
   - Go to Statistics / Setup /
   - Change the Data collection interval to 10 seconds
2. Verify that serial communication to the UPS is working - On a PC
   
   - attach usb converter to PC
   - startup minicom (or equivalent): minicom -D /dev/ttyUSB0
   - ctrl-a, ctrl-z, P,
   - change port configuration to 2400,8,n,1
   - ctrl-a, ctrl-z, O, Serial Port Setup
   - change port configuration to hardware / software flow control: none
   - type the uppercase letter: Y , and expect the reply SM
     
     ```
     Y
     SM
     ```
   - Note: serial APC UPS commands are documented at: [http://networkupstools.org/protocols/apcsmart.html](http://networkupstools.org/protocols/apcsmart.html "http://networkupstools.org/protocols/apcsmart.html") )
3. Verify that serial communication to the UPS is working - On the Router
   
   - Detach the usb converter from PC , attach to router
   - Install minicom on the router.
   - Use the same minicom commands to verify communication with the router.
   - type the uppercase letter: Y , and expect the reply SM
     
     ```
     Y
     SM
     ```
4. There should be a tab for APC UPS on the General Plugins page at:
   
   ```
   http://192.168.1.1/cgi-bin/luci/admin/statistics/collectd/general
   ```
   
   If not, you may not have the patches that added luci-statistics support for the apcups plugin: [https://github.com/openwrt/luci/pull/1227](https://github.com/openwrt/luci/pull/1227 "https://github.com/openwrt/luci/pull/1227"). The best fix for this is to upgrade to a version that does.
5. /var/etc/collectd.conf should have a section for apcups:
   
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
