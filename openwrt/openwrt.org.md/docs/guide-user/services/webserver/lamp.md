# Set up a LAMP webserver stack

Read here: [LAMP (software bundle)](https://en.wikipedia.org/wiki/LAMP%20%28software%20bundle%29 "https://en.wikipedia.org/wiki/LAMP (software bundle)") about the concept. This guide provides step by step instructions for installing a full featured LAMP stack on OpenWrt.

Service Examples Description [Web server](/docs/guide-user/services/webserver/start "docs:guide-user:services:webserver:start") [uHTTPd](/docs/guide-user/services/webserver/http.uhttpd "docs:guide-user:services:webserver:http.uhttpd") OpenWrt's in-house server, used by default for the WebUI LuCI [Lighttpd](/docs/guide-user/services/webserver/lighttpd "docs:guide-user:services:webserver:lighttpd") Lightweight and flexible, many addons [Apache](/docs/guide-user/services/webserver/http.apache "docs:guide-user:services:webserver:http.apache") Powerful and widely used [Nginx](/docs/guide-user/services/webserver/nginx "docs:guide-user:services:webserver:nginx") Aimed at good performance, low memory [Database server](/doc/howto/database.overview "doc:howto:database.overview") [MySQL](/doc/howto/database.mysql "doc:howto:database.mysql") Widely used SQL server [PostgreSQL](/doc/howto/database.postgresql "doc:howto:database.postgresql") Another popular SQL server [SQLite](/doc/howto/database.sqlite "doc:howto:database.sqlite") Easy to use SQL *library* for low powered devices, runs within process [Scripting language](/doc/howto/scripting.overview "doc:howto:scripting.overview") [php](/docs/guide-user/services/webserver/php "docs:guide-user:services:webserver:php") Specially designed for making websites [perl](/doc/howto/perl "doc:howto:perl") Flexible high level general purpose language [python](/doc/howto/python "doc:howto:python") Another high level scripting language

## Basic System Configuration

This article is a collection of examples of the configuration and integration of web servers, database servers and scripting languages, i.e. LAMP. For each example we assume to be creating a web page with `/srv/www/` as the document root and assume an otherwise standard OpenWrt configuration. Note that it currently has a lot of overlap with the main articles for the respective services. ![FIXME](/lib/images/smileys/fixme.svg) It should be made more to the point and only about installing and especially integrating these services.

## Installing and configuring a web server

You might already have a web server for the [Web UI](/docs/guide-user/luci/webinterface.overview "docs:guide-user:luci:webinterface.overview") installed and running. Choose any of the available WebServer for this purpose: [webserver](/docs/guide-user/services/webserver/start "docs:guide-user:services:webserver:start"). If the web server is not in the [OpenWrt packet repository](/packages/start "packages:start"), you could always [crosscompile](/docs/guide-developer/toolchain/crosscompile "docs:guide-developer:toolchain:crosscompile") it from source.

### uHTTPd

→ [http.uhttpd](/docs/guide-user/services/webserver/http.uhttpd "docs:guide-user:services:webserver:http.uhttpd") is an in-house web server under BSD-license. [LuCI WebUI](/docs/guide-user/luci/luci.essentials "docs:guide-user:luci:luci.essentials") already uses this. If uHTTPd is not already installed you can install it with:

```
opkg update
opkg install uhttpd
```

The default image runs a WebUI for OpenWrt on port 80 (HTTP) and port 443 (HTTPS). For our PHP5 enabled uHTTPd web server we start a new uHTTPd instance on a different port. We use port 81 here.

```
uci set uhttpd.llmp=uhttpd
uci set uhttpd.llmp.listen_http=81
uci set uhttpd.llmp.home=/srv/www
uci commit uhttpd
```

Create a directory for our web server content

```
mkdir -p $(uci get uhttpd.llmp.home)
```

If uHTTPd was already installed and running restart it now with

```
/etc/init.d/uhttpd restart
```

If you installed uHTTPd via opkg start the web server manually and also at boot by enabling the init script

```
/etc/init.d/uhttpd start
/etc/init.d/uhttpd enable
```

Further configuration can also be performed manually, e.g. to enable php. [uhttpd](/docs/guide-user/services/webserver/uhttpd "docs:guide-user:services:webserver:uhttpd")

### Lighttpd

→ [lighttpd](/docs/guide-user/services/webserver/lighttpd "docs:guide-user:services:webserver:lighttpd") is a lightweight and very flexible web server with lots of additional modules available.

```
opkg update
opkg install lighttpd lighttpd-mod-cgi
```

Edit `/etc/lighttpd/lighttpd.conf` and change a few settings:

Enable CGI:

```
server.modules = (
       "mod_cgi"
)
```

Set the document root and the port for our example:

```
server.document-root = "/srv/www/"
server.port = 81
```

Edit `/etc/php.ini` and set the document root here as well (or leave it empty, in which case it allows PHP serving anywhere outside the docroot):

```
doc_root = "/srv/www"
```

Create a directory for our web server content:

```
mkdir -p /srv/www
```

Start the server manually and also at boot by enabling the init script

```
/etc/init.d/lighttpd start
/etc/init.d/lighttpd enable
```

### Nginx

→ [nginx](/docs/guide-user/services/webserver/nginx "docs:guide-user:services:webserver:nginx") is nice as well.

### Apache

→ [http.apache](/docs/guide-user/services/webserver/http.apache "docs:guide-user:services:webserver:http.apache") is nice as well.

### Testing the web server

Create a little test web page, e.g. `/srv/www/index.html`:

```
echo "<P>Hello, this web server runs on OpenWrt!!</P>" > /srv/www/index.html
```

Point your browser to the routers IP address and the port the web server is listening on (e. g. [http://192.168.1.1:81/index.html](http://192.168.1.1:81/index.html "http://192.168.1.1:81/index.html"))

## Installing and Configuring PHP

See →[php](/docs/guide-user/services/webserver/php "docs:guide-user:services:webserver:php") to install a version of PHP. The remainder of this section assumes you have a proper PHP install.

### uHTTPd

[php](/docs/guide-user/services/webserver/http.uhttpd#php "docs:guide-user:services:webserver:http.uhttpd")

```
uci add_list uhttpd.llmp.interpreter=".php=/usr/bin/php-cgi"
uci set uhttpd.llmp.index_page="index.html index.htm default.html default.htm index.php"
uci commit uhttpd
```

```
sed -i 's,doc_root.*,doc_root = "",g' /etc/php.ini
```

```
sed -i 's,;short_open_tag = Off,short_open_tag = On,g' /etc/php.ini
```

Restart uHTTPd now with

```
/etc/init.d/uhttpd restart
```

Further configuration can also be performed manually, e.g. to enable php. [uhttpd](/docs/guide-user/services/webserver/uhttpd "docs:guide-user:services:webserver:uhttpd")

### Lighttpd

[php](/docs/guide-user/services/webserver/lighttpd#php "docs:guide-user:services:webserver:lighttpd")

In `/etc/lighttpd/lighttpd.conf` set the following to activate PHP for files with `.php` extension.

`cgi.assign = ( ".php" => "/usr/bin/php-cgi" )`

Add index.php to the default file names, such that it loads it automatically if present.

`index-file.names = ( “index.html”, “default.html”, “index.htm”, “default.htm”, “index.php” )`

Set the proper document root

`doc_root = “/srv/www”`

Restart lighttpd:

```
/etc/init.d/lighttpd restart
```

### Apache

[Configuring Apache and PHP5](/docs/guide-user/services/webserver/http.apache#configuring_apache_and_php5 "docs:guide-user:services:webserver:http.apache")

### Nginx

[php](/docs/guide-user/services/webserver/nginx#php "docs:guide-user:services:webserver:nginx")

### Testing PHP

We are using the phpinfo() function for a first test.

```
echo "<?php phpinfo(); ?>" > /srv/www/index.php
```

Point your browser to the routers IP address and the port the web server is listening on (e. g. [http://192.168.1.1:81/index.php](http://192.168.1.1:81/index.php "http://192.168.1.1:81/index.php"))

If you get a blank page you can run your script with `php-cgi` from the router's shell to see if there are any errors

```
php-cgi /srv/www/index.php
```

## Installing and configuring a database server

[database.overview](/doc/howto/database.overview "doc:howto:database.overview")

### MySQL

[database.mysql](/doc/howto/database.mysql "doc:howto:database.mysql")

```
opkg update
opkg install libpthread libncurses libreadline mysql-server

sed -i 's,^datadir.*,datadir         = "/srv/mysql",g' /etc/my.cnf
sed -i 's,^tmpdir.*,tmpdir          = "/tmp",g' /etc/my.cnf

mkdir -p /srv/mysql
mysql_install_db --force

/etc/init.d/mysqld start
/etc/init.d/mysqld enable

mysqladmin -u root password 'new-password'
```

To enable MySQL in PHP install

```
opkg update
opkg install php5-mod-mysql
```

and load the `mysql.so` module in `/etc/php.ini`

```
sed -i 's,;extension=mysql.so,extension=mysql.so,g' /etc/php.ini
```

[https://forum.openwrt.org/viewtopic.php?pid=145009#p145009](https://forum.openwrt.org/viewtopic.php?pid=145009#p145009 "https://forum.openwrt.org/viewtopic.php?pid=145009#p145009")

To use the MySQLi module in PHP install

```
opkg update
opkg install php5-mod-mysqli
```

and load the `mysqli.so` module in `/etc/php.ini`

```
sed -i 's,;extension=mysqli.so,extension=mysqli.so,g' /etc/php.ini
```

Besides, in /etc/php.ini, duplicate the block named \[MySQL] to \[MySQLi] and rename all “mysql.”-options to “mysqli.”. To access a local MySQL server via socket, modify the value of “mysqli.default\_socket” (which can be found in /etc/my.cnf):

```
mysqli.default_socket = /var/run/mysqld.sock
```

For **MySQL** to work with **PHP**, you must also configure the ***php.ini*** (vi /etc/php.ini) file, under the \[MySQL] section.

- Here is an example:

```
[MySQL]
mysql.allow_local_infile = On
mysql.allow_persistent = On
mysql.cache_size = 2000
mysql.max_persistent = -1
mysql.max_links = -1
mysql.default_port = 3306
mysql.default_socket = /tmp/run/mysqld.sock
mysql.default_host = 127.0.0.1
mysql.default_user = root
mysql.default_password = MySuperSecretPassword
mysql.connect_timeout = 60
mysql.trace_mode = Off
```

### PostgreSQL

[database.postgresql](/doc/howto/database.postgresql "doc:howto:database.postgresql")

## Administering

### CLI

### WebUI

## Troubleshooting

## Notes
