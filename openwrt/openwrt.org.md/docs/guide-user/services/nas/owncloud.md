# ownCloud or NextCloud

ownCloud/Nextcloud is very heavy and requires devices with relatively powerful processors, while it will run well even on weak PC and servers, it is too heavy for low-power devices like a router or a NAS.

It's recommended to have at least a dualcore ARMv7 processor if you are not running OpenWrt on PC/server hardware.

I've installed ownCloud on an TP-Link [TL-WR2543ND](/toh/tp-link/tl-wr2543nd "toh:tp-link:tl-wr2543nd"), using lighttpd and sorry, it's dead slow! ![:-(](/lib/images/smileys/sad.svg)

--- *unknown*

I've also installed it on a more powerful TP\_Link [TL-WDR3500](/toh/tp-link/tl-wdr3500_v1 "toh:tp-link:tl-wdr3500_v1") but it's still very slow, 4-5 secs per page...

--- *motherjoker 2014/06/05 15:41*

Internally both NextCloud and ownCloud are using a WebDAV protocol with some extensions for basic file operations and Web UI to it. For a better performance you can use just pure WebDAV [webdav](/docs/guide-user/services/nas/webdav "docs:guide-user:services:nas:webdav")

## Get USB-support

ownCloud is around 30 MB and you will like to store your data somewhere. So best both is done on some external storage because small routers don't have that much. Have a look in the OpenWrt-Wiki at usb.essentials \[1] and usb.storage\[2], and figure out what USB-mode your device is using (ohci or uhci) and know what filesystem is on your storage (here: ext4).

You have to run an update of the package-lists before you can install any software

```
opkg update
```

Install USB-support (this is for USB 2.0, see usb.essentials for USB 1.1 support)

```
opkg install kmod-usb2
insmod ehci-hcd
```

If you see messages like “unresolved symbol usb\_calc\_bus\_time” try loading usbcore and then try ehci-hcd again:

```
insmod usbcore
insmod ehci-hcd
```

Install USB-storage support

```
opkg install kmod-usb-storage kmod-usb-storage-extras block-mount kmod-fs-ext4 kmod-scsi-generic
```

Create a mount-point like this

```
mkdir /mnt/sda1
```

Figure out which device is your USB-stick/drive and mount it. It helps to list /dev with the USB-device and without - in this case its /dev/sda1.

```
mount -t ext4 /dev/sda1 /mnt/sda1 -o rw,sync
```

Get fstab to auto-mount the usb-stick on startup, otherwise your webserver won't come up and you have to start it after mounting manually. ( ![FIXME](/lib/images/smileys/fixme.svg) Insert how-to here) Even if auto-mounting on startup works, it probably ends too late when the webserver tries to start. To make sure the webserver is up after booting, insert this line into /etc/rc.local before “exit 0”:

```
/etc/init.d/lighttpd start
```

## If &lt;= 8MB flash: Get extroot

If your device has only 8 MB of flash-memory (or even less), it is too small to get all the dependencies on it. You'll need to put the operating-system on the USB-device as well. Have a look at [extroot\_configuration](/docs/guide-user/additional-software/extroot_configuration "docs:guide-user:additional-software:extroot_configuration") and follow the instructions for trunk. The flavour “New external overlay variant (pivot overlay)” worked for me on a TP-Link WR1043ND quite well. Remember to use both steps while “Duplicate Data”: pivot overlay and pivot root.

## Install &amp; configure webserver

ownCloud can't be installed on uhttpd (default web server on OpenWrt). You need to install and configure lighttpd.

I had trouble moving Luci from uhttpd to lighttpd so I recommend keeping uhttpd running for Luci on a different port and assign port 80 to lighttpd for ownCloud.

### Change uhttpd port

Edit `/etc/config/uhttpd` file and change http port to 81 and https port to 8443:

```
config uhttpd main
  list listen_http  0.0.0.0:81
  list listen_http  [::]:81
```

```
  list listen_https  0.0.0.0:8443
  list listen_https  [::]:8443
```

Restart uhhtpd.

```
/etc/init.d/uhttpd restart
```

You should be able to reach luci under e.g. [http://192.168.1.1:81](http://192.168.1.1:81 "http://192.168.1.1:81")

### Install lighttpd

Install [Lighttpd webserver](/docs/guide-user/services/webserver/lighttpd "docs:guide-user:services:webserver:lighttpd") packages:

```
opkg install lighttpd lighttpd-mod-cgi lighttpd-mod-fastcgi lighttpd-mod-access
```

Now configure lighttpd for ownCloud. Edit the config-file `/etc/lighttpd/lighttpd.conf`

Set www-root for ownCloud:

```
server.document-root = "/www/owncloud"
```

see errors on syslog:

```
server.error-log-use-syslog = "enable"
```

Uncomment the mod\_cgi and add modules:

```
server.modules = (
	"mod_access",
        "mod_cgi"
)
```

Assign port 80 for the ownCloud Server:

```
server.port = 80
```

Add these lines to secure the access to the data according to ownCloud WebServer-notes\[3], beware that in this example the ownCloud-folder is our www-root

```
$HTTP["url"] =~ "^/data/" {
	url.access-deny = ("")
}
```

```
$HTTP["url"] =~ "^($|/)" {
	dir-listing.activate = "disable"
}
```

Start the server:

```
/etc/init.d/lighttpd start
```

Enable server for next boots:

```
/etc/init.d/lighttpd enable
```

## Install &amp; configure PHP

Get the dirty part: php and sqlite. I am not sure if really all of these packages are necessary, but it seems so:

```
opkg install php7 php7-cgi php7-fastcgi php7-mod-json php7-mod-session php7-mod-zip libsqlite3 zoneinfo-core php7-mod-pdo php7-mod-pdo-sqlite php7-mod-ctype php7-mod-mbstring php7-mod-gd sqlite3-cli php7-mod-sqlite3 php7-mod-curl curl php7-mod-xml php7-mod-simplexml php7-mod-hash php7-mod-dom php7-mod-iconv php7-mod-xmlwriter php7-mod-xmlreader php7-mod-intl
```

Those packages are also suggested:

```
opkg install php7-mod-mcrypt php7-mod-openssl php7-mod-fileinfo php7-mod-exif
```

Configure /etc/php.ini to our needs and change the doc\_root to our www-root:

```
;open_basedir=
```

```
error_log = syslog
```

```
doc_root =
cgi.fix_pathinfo=1
```

```
memory_limit = 32M
```

Check that the extensions are enabled:

/etc/php5/&lt;extension&gt;.ini should contains extension=&lt;extension&gt;.ini

Play around with memory\_limit, I reduced the value form 8MB to 4MB ... but maybe 50MB might be better with 64MB RAM.

Run php:

```
/etc/init.d/php7-fastcgi enable
/etc/init.d/php7-fastcgi start
```

### activate PHP in lighttpd.conf

Uncomment to enable the fastcgi and access module

```
server.modules = (
	"mod_access",
	"mod_fastcgi",
	"mod_cgi"
)
```

Add “index.php” to the list of index-file.names:

```
index-file.names = ( "index.php", "index.html", "default.html", "index.htm", "default.htm" )
```

```
static-file.exclude-extensions = (".php, ".pl", ".fcgi")
```

Include php by using fast-cgi (gample against max-procs for performance):

```
fastcgi.server = (
	".php" => ((
		"bin-path" => "/usr/bin/php-fcgi",
		"socket" => "/tmp/php.socket",
		"max-procs" => 1
	))
)
```

Only if you are using normal cgi mode for PHP, you'll need the following line

```
cgi.assign = (".php" => "/usr/bin/php-cgi")
```

Restart the webserver with

```
/etc/init.d/lighttpd restart
```

Now point your browser to [http://yourhost/index.php](http://yourhost/index.php "http://yourhost/index.php") (first create a helpful content to this file) and see if this manual missed something. If so, please contact the author (see details below) or get an account for this wiki and fix the how-to yourself.

## Get SSL (optional)

Probably you want to run lighttpd with SSL/https to get your traffic crypted. These instructions are taken from \[4]. For generating a key you need to install libopenssl and the openssl-util

```
opkg install libopenssl openssl-util
```

Now you can create a folder for your key like this

```
mkdir /etc/lighttpd/ssl/YOURDOMAIN -p
```

Within that you can create your key with the following command. You will be asked to provide some information for the certificate.

```
openssl req -new -x509 -keyout server.pem -out server.pem -days 365 -nodes
```

Make the file only accessable to root

```
chmod 0600 /etc/lighttpd/ssl/YOURDOMAIN
chmod 0600 /etc/lighttpd/ssl/YOURDOMAIN/server.pem
```

Now we can uncomment the lines for SSL in lighttp.conf and modify the path to the server.pem:

```
ssl.engine = "enable"                             
ssl.pemfile = "/etc/lighttpd/ssl/YOURDOMAIN/server.pem"
```

Restart the webserver afterwards - don't wonder if it isn't anymore reachable via http:

```
/etc/init.d/lighttpd restart
```

## MySQL Installation (Optional)

ownCloud is installed with SQLite by default. However SQLite is only good for testing and lightweight single user setups. It has no client synchronisation support, so other devices will not be able to synchronise with the data stored in an ownCloud SQLite database. MariaDB is the ownCloud recommended database.

Install the recommended MySQL/MariaDB database:

```
opkg update
opkg install mysql-server mariadb-client-extra php7-mod-pdo-mysql
```

Configure the database server:

```
sed -i 's,^datadir.*,datadir         = "/srv/mysql",g' /etc/my.cnf
sed -i 's,^tmpdir.*,tmpdir          = "/tmp",g' /etc/my.cnf

mkdir -p /srv/mysql
mysql_install_db --force
```

Start MySQL:

```
/etc/init.d/mysqld start
/etc/init.d/mysqld enable
```

Set password for root user:

```
mysqladmin -u root password 'password'
```

Connect to MySQL database:

```
mysql -uroot -p
```

Create user for web server and set its password:

```
CREATE USER 'http'@'localhost' IDENTIFIED BY 'password';
```

Create database for ownCloud and set privileges:

```
CREATE DATABASE IF NOT EXISTS owncloud;
GRANT ALL PRIVILEGES ON owncloud.* TO 'http'@'localhost' IDENTIFIED BY 'password';
FLUSH PRIVILEGES;
```

For more information, please refer to the documentation: [https://doc.owncloud.org/server/10.4/admin\_manual/installation/installation\_wizard.html#post-installation-steps-label](https://doc.owncloud.org/server/10.4/admin_manual/installation/installation_wizard.html#post-installation-steps-label "https://doc.owncloud.org/server/10.4/admin_manual/installation/installation_wizard.html#post-installation-steps-label").

## Unleash ownCloud

Download and unpack the newest revision:

```
cd /tmp
wget https://download.owncloud.org/community/owncloud-X.X.X.tar.bz2
opkg update
opkg install tar
cd /www
tar -xjf /tmp/owncloud-X.X.X.tar.bz2
```

Now you should cleanup:

```
rm /tmp/owncloud-X.X.X.tar.bz2
opkg remove --autoremove tar
```

You have to configure the rights of the /www/owncloud in addition.

```
chown -R root:root /www/owncloud
chmod 770 -R /mnt/sda1/owncloud/data
```

```
cd /mnt/sda1
mkdir owncloud
cd owncloud
mkdir data
chown -hR http /mnt/sda1/owncloud
chmod 770 -R /mnt/sda1/owncloud
```

create the following folder after installation and change its permissions:

```
cd /www/owncloud
mkdir apps-external
chmod 777 apps-external
```

Open your Website [http://192.168.1.1/](http://192.168.1.1/ "http://192.168.1.1/") and configure your first steps, then wait for a loooonnnnngggg time and you'll see the result.

## Enable Background Jobs

ownCloud requires background jobs like database cleanup. For best performance, it is recommended to enable background jobs.

Enable Cron job:

```
opkg install sudo
crontab -u http -e
* * * * * /usr/bin/php-cli /www/owncloud/occ system:cron
```

For more information, please refer to the documentation: [https://doc.owncloud.com/server/admin\_manual/configuration/server/background\_jobs\_configuration.html](https://doc.owncloud.com/server/admin_manual/configuration/server/background_jobs_configuration.html "https://doc.owncloud.com/server/admin_manual/configuration/server/background_jobs_configuration.html").

## ownCloud on alternative destination

If you don't want to set up a extroot, you can install ownCloud on a different location [Opkg Package Manager - Non-standard Installation Destinations](/docs/guide-user/additional-software/opkg#non-standard_installation_destinations "docs:guide-user:additional-software:opkg")

Install php on another location, then

`ln -s /opt/etc/php.ini /etc/php.ini ln -s /opt/etc/php7 /etc/php7`

If you still get errors related timezones and calls to undefined functions:

`opkg -dest usb install zoneinfo-core zoneinfo-[your region] ln -s /opt/usr/lib/php /usr/lib/php ln -s /opt/usr/share/zoneinfo/ /usr/share/zoneinfo/`

## Written by

Page was initiated by wetterfrosch

- Mail: wetter\_ät\_netzpolitik.org
- Jabber: wetterfrosch\_ät\_jabber.berlin.ccc.de
- Diaspora: wetter\_ät\_diaspora.subsignal.org
- Twitter: @wetterfrosch

but a lot of modifications are done by others...

## Resources

- \[0] [http://downloads.openwrt.org/snapshots/](http://downloads.openwrt.org/snapshots/ "http://downloads.openwrt.org/snapshots/")
- \[1] [Installing and troubleshooting USB Drivers](/docs/guide-user/storage/usb-installing "docs:guide-user:storage:usb-installing")
- \[2] [Using storage devices](/docs/guide-user/storage/usb-drives "docs:guide-user:storage:usb-drives")
- \[3] [http://owncloud.org/support/webserver-notes/](http://owncloud.org/support/webserver-notes/ "http://owncloud.org/support/webserver-notes/")
- \[4] [http://www.cyberciti.biz/tips/howto-lighttpd-create-self-signed-ssl-certificates.html](http://www.cyberciti.biz/tips/howto-lighttpd-create-self-signed-ssl-certificates.html "http://www.cyberciti.biz/tips/howto-lighttpd-create-self-signed-ssl-certificates.html")
- \[5] [http://www.gizfun.com/content/install-owncloud-your-openwrt-router-3-steps](http://www.gizfun.com/content/install-owncloud-your-openwrt-router-3-steps "http://www.gizfun.com/content/install-owncloud-your-openwrt-router-3-steps")
