# Network Traffic Monitor with vnStat

vnStat is a console-based network traffic monitor for Linux and BSD that keeps a log of network traffic for the selected interface(s). It uses the network interface statistics provided by the kernel as information source. This means that vnStat won't actually be sniffing any traffic and also ensures light use of system resources. [As it says on their website](http://humdi.net/vnstat/ "http://humdi.net/vnstat/")

## Installing

### Base

```
opkg update
opkg install vnstat
```

### LuCI Webgui Integration (optional)

```
opkg update
opkg install vnstati luci-app-vnstat
```

If you want language translation for the LuCI Webgui Integration then install the following:

```
opkg update
opkg install luci-i18n-vnstat-(YOUR_COUNTRY_CODE)
```

If you dont know which language codes are available you can search it with the following command:

```
opkg list | grep luci-i18n-vnstat-*
```

An example to Install German Translation for LuCI Webgui:

```
opkg update
opkg install luci-i18n-vnstat-de
```

## Configuring

The only configuring it really needs is to tell it what interface(s) to monitor, and some method of updating the database such as a cronjob. You might want to backup your database file. The vnstati package comes with a 'restore' and init.d script that downloads the backup from a webserver upon reboot. Its up to you to chose how to backup/restore the data( via HTTP/FTP/SSH/ETC)

### Setup

![](/_media/meta/icons/tango/dialog-information.png) **This step is required for vnStat to function.**

The common choice for monitoring is your WAN interface.

First, you have to find out which is your WAN Interface:

```
. /lib/functions/network.sh; if network_get_device if_wan wan; then
echo "Your WAN Interface is: $if_wan"; else echo "Cant find a active WAN Connection, please activate it"; fi
```

![:!:](/lib/images/smileys/exclaim.svg) The interface must be active for the above command to work. See ticket [19116](https://dev.openwrt.org/ticket/19116 "https://dev.openwrt.org/ticket/19116").

If you have an already activated WAN connection, you will get the following output, for example:

Your WAN Interface is: pppoe-wan. Now edit */etc/vnstat.conf* with your favourite editor and change the following two Lines:

```
Interface "pppoe-wan"
MaxBandwidth 1000
```

“Interface” is your WAN Interface you found out above and “MaxBandwidth” is the max possible bandwidth (in mbit) speed.

![:!:](/lib/images/smileys/exclaim.svg) MaxBandwidth must have the correct value, otherwise you will get wrong statistics from vnstat.

![:!:](/lib/images/smileys/exclaim.svg) MaxBandwidth means: How fast is your WAN Interface at most. *MaxBandwidth 1000 = 1000 Mbit* and *MaxBandwidth 100 = 100 Mbit* ! It has nothing to do with your Internet speed !

Then edit or create */etc/config/vnstat* and change (or add) the following lines:

```
config vnstat
        list interface 'pppoe-wan'
```

**Please Note:** “pppoe-wan” is your WAN Interface you found out above !

Now you have to create the Database with this command:

```
vnstat -u -i pppoe-wan
```

**Hint:** vnStat normally uses “IEC prefixes” (MiB, GiB and so on). If you want old binary prefixes (MB, GB) change the following in */etc/vnstat.conf* : `UnitMode 1`.

### Database Updating

![](/_media/meta/icons/tango/dialog-information.png) **This step is required for vnStat to function.** The package doesn't setup database updating at all. Its up to you to configure when vnStat will update. Use the daemon or a cron job.

#### Using included daemon:

Edit */etc/vnstat.conf* and search for “UpdateInterval”. Change “UpdateInterval” to the following: `UpdateInterval 300`.

UpdateInterval tells the daemon to update the Database every 300 seconds (5 minutes). If you want another Interval you can change it for your needs.

Run these commands to enable the daemon. This will also auto start the daemon if you reboot your device:

```
/etc/init.d/vnstat enable
/etc/init.d/vnstat start
```

![](/_media/meta/icons/tango/dialog-error.png) **`/etc/config/vnstat`** is the database restore config, *not the vnstatd config.* vnstatd config is also located at **`/etc/vnstat.conf`**

This same init.d script will automatically download a database backup if you configured `/etc/config/vnstat` corrrectly. Useful for recovering db after a router reboot. Down side is that there is no implemented upload method using the uci config. You will need to write a script that cron will run to do all the uploading, so why not use the same protocol for downloading too? I suggest rsync, ftp, or scp.

#### Using a cronjob

Update the crontab:

```
cat << "EOF" >> /etc/crontabs/root
*/5 * * * * vnstat -u
EOF
/etc/init.d/cron restart
```

![](/_media/meta/icons/tango/dialog-error.png) **I don't recommend using crontab to update the vnStat Database.**  
Because if you update the Database with cron you will get weird statistics like: 16777216.00 TiB in one day.

See: [https://bugzilla.redhat.com/show\_bug.cgi?id=711383](https://bugzilla.redhat.com/show_bug.cgi?id=711383 "https://bugzilla.redhat.com/show_bug.cgi?id=711383")

### Image Generation

You can install webif and it will generate images. But thats not lightweight so RealOpty developed scripts based off webif code that will generate the images without webif.

You might want to setup a crontab to execute this script every 15 min.

I always output the images to the tmpfs so it dont always write to flash.

```
#!/bin/sh
# vnstati image generation script.
# Source: http://code.google.com/p/x-wrt/source/browse/trunk/package/webif/files/www/cgi-bin/webif/graphs-vnstat.sh
 
WWW_D=/tmp/www/vnstat # output images to here
LIB_D=/var/lib/vnstat # db location
BIN=/usr/bin/vnstati  # which vnstati
 
outputs="s h d t m"   # what images to generate
 
# Sanity checks
[ -d "$WWW_D" ] || mkdir -p "$WWW_D" # make the folder if it dont exist.
 
# You might want to setup a link if it dont exist.
# [ -L /www/vnstat ] || ln -sf /www/vnstat /tmp/www/
 
# End of config changes
interfaces="$(ls -1 $LIB_D)"
 
if [ -z "$interfaces" ]; then
    echo "No database found, nothing to do."
    echo "A new database can be created with the following command: "
    echo "    vnstat -u -i eth0"
    exit 0
else
    for interface in $interfaces; do
        for output in $outputs; do
            $BIN -${output} -i $interface -o $WWW_D/vnstat_${interface}_${output}.png
        done
    done
fi
 
exit 1
```

### Sample HTML

```
<META HTTP-EQUIV="refresh" CONTENT="300">
<html>
  <head>
    <title>Traffic of Interface eth1</title>
  </head>
  <body>
    <h2>Traffic of Interface eth1</h2>
    <table>
        <tbody>
            <tr>
                <td>
                    <img src="vnstat_eth1_s.png" alt="eth1 Summary" />
                </td>
                <td>
 
                    <img src="vnstat_eth1_h.png" alt="eth1 Hourly" />
                </td>
            </tr>
            <tr>
                <td valign="top">
                    <img src="vnstat_eth1_d.png" alt="eth1 Daily" />
                </td>
                <td valign="top">
                    <img src="vnstat_eth1_t.png" alt="eth1 Top 10" />
                    <br />
                    <img src="vnstat_eth1_m.png" alt="eth1 Monthly" />
                </td>
            </tr>
        </tbody>
    </table>
  </body>
</html>
```

### Persistent stats

vnStat stores stats to /var/lib/vnstat by default and information will not persist across restarts. This means that one might want to relocate the database directory to other forms of persistent storage like your device's flash or external thumb drives.

By default, vnStat is configured to write to the directory in volatile memory every 30 minutes. Both the directory and the interval can be adjusted in vnStat's configuration. However, keep in mind that frequent writes to flash memory will deteriorate and potentially damage flash memory. Changing the directory to write to flash memory without changing the interval will result in around 17500 write operations each year, a number that could potentially cause problems.

Additionally, the database may not persist across firmware flashes.

#### Method 1

To store the database on the thumb drive, ensure that [usb-drives](/docs/guide-user/storage/usb-drives "docs:guide-user:storage:usb-drives") is working. Then, edit DatabaseDir in /etc/vnstat.conf to point to your flash drive, you may also want to modify SaveInterval to a larger value (the default 30min is still a good value) to minimise writes to flash.

#### Method 2

This method automatically backs up the vnStat database to flash memory as **/etc/vnstat\_backup.tar.gz** on router shutdown and restores it on startup. Note that this cannot work when the router unexpectedly loses power (unplugging, turning off a hardware power switch, power outage). You can use a cronjob to backup in regular intervals while the router is running.

##### Script

```
cat << "EOF" > /etc/init.d/vnstat_backup
#!/bin/sh /etc/rc.common
 
EXTRA_COMMANDS="backup restore"
EXTRA_HELP=<<EOI
        backup  Backup vnstat database
        restore Restore vnstat database
EOI
 
START=98
STOP=10
 
vnstat_option() {
	sed -ne "s/^[[:space:]]*$1[[:space:]]*['\"]\([^'\"]*\)['\"].*/\1/p" /etc/vnstat.conf
}
 
BACKUP_FILE=/etc/vnstat_backup.tar.gz
LOGGER_TAG=vnstat_backup
VNSTAT_DIR="$(vnstat_option DatabaseDir)"
 
backup_database() {
	if [ ! -d $VNSTAT_DIR ]; then
		logger -t $LOGGER_TAG -p err "cannot backup, data directory $VNSTAT_DIR does not exist (yet)"
	else
		logger -t $LOGGER_TAG -p info "backing up database"
		/bin/tar -zcf $BACKUP_FILE -C $VNSTAT_DIR .
	fi
}
 
restore_database() {
	if [ ! -f $BACKUP_FILE ]; then
		logger -t $LOGGER_TAG -p err "cannot restore, backup file does not exist (yet)"
	else
		logger -t $LOGGER_TAG -p info 'restoring database'
		[ ! -d $VNSTAT_DIR ] && mkdir $VNSTAT_DIR
		/bin/tar -xzf $BACKUP_FILE -C $VNSTAT_DIR
	fi
}
 
start() {
	restore_database
}
 
stop() {
	backup_database
}
 
backup() {
	backup_database
}
 
restore() {
	restore_database
}
EOF
chmod +x /etc/init.d/vnstat_backup
/etc/init.d/vnstat_backup enable
```

And for good measure, create an initial backup:

```
/etc/init.d/vnstat_backup backup
```

##### Add for cron and for init

The below commands will add a cronjob entry that triggers a backup every 6 hours every day, if necessary adjust to an interval you feel comfortable with:

```
cat << "EOF" >> /etc/crontabs/root
0 */6 * * * /etc/init.d/vnstat_backup backup
EOF
/etc/init.d/cron restart
```
