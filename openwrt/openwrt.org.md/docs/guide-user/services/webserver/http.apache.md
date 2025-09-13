# Apache HTTP Server

Apache is one of the most popular web servers in the FOSS world. First, I strongly recommend that you install the apache server on an external drive width swapfile, especially if you need to use mysql. If you do not have the external drive and the swapfile installed, please look first below. You can copy text, and width right mouse click copy the contents to your PuTTY terminal.

## Installation

Installing apache with `opkg` is very simple:

```
opkg update
opkg install apache
```

or alternatively install it to the external drive: (see below)

```
opkg -dest usb install apache
```

In case you manually mounted the hard drive, restart the drive, to make necessary links:

```
/etc/init.d/hdd stop
/etc/init.d/hdd start
```

## Configuration

Edit `/etc/apache/httpd.conf` to change the configuration according to your needs.

Sometimes you need to uncomment a line (=remove the `#` character at the beginning of the line) to activate the respective config option.

Search for “Listen 12.34.56.78:80” and replace with your router's IP address and a port different then 80, because 80 is most likely already used by the OpenWrt GUI (LuCI).

`Listen 192.168.1.1:81`

Search for “ServerName” and do the same:

`ServerName YourServer:81`

where YourServer is [FQDN](https://en.wikipedia.org/wiki/FQDN "https://en.wikipedia.org/wiki/FQDN") of your server name like [www.something99.com](http://www.something99.com "http://www.something99.com")

Connect to [http://192.168.1.1:81](http://192.168.1.1:81 "http://192.168.1.1:81") in your browser to see if your configuration works. Place your web server shared documents under `/usr/share/htdocs`.

## External drive and the swapfile install

Since the *Apache HTTP Server* is quite a big memory hog, we recommend to use it only in conjunction with additional storage. Please follow these guides to get that started:

- [usb.overview](/docs/guide-user/hardware/usb.overview "docs:guide-user:hardware:usb.overview")
  
  - [usb-installing](/docs/guide-user/storage/usb-installing "docs:guide-user:storage:usb-installing")
  - [usb-drives](/docs/guide-user/storage/usb-drives "docs:guide-user:storage:usb-drives")
  - `/etc/config/fstab`

## Configuring Apache and PHP5

To install PHP see →[php](/docs/guide-user/services/webserver/php "docs:guide-user:services:webserver:php")

Edit

```
vi /etc/php.ini
```

Search for “doc\_root” and “extension=gd.so”. Do not specify the doc\_root, and uncomment the extension=gd.so.

`doc_root = extension=gd.so`

Configure Apache again:

```
vi /etc/apache/httpd.conf
```

NOTE: This is a rather unsafe configuration. If you use this, you are putting yourself at risk. ([http://insecurety.net/?p=912](http://insecurety.net/?p=912 "http://insecurety.net/?p=912"))

Search for the portion of Your Apache configuration file which has the ScriptAlias section. Add the line from below immediately after the ScriptAlias line for “cgi-bin”. Make sure that the line goes before the closing &lt;/IfModule&gt; for that &lt;IfModule alias\_module&gt; section.

`ScriptAlias /php/ “/usr/bin/”`

Search for the “AddType” comment block, and add the AddType line below. You can find the AddType lines in the &lt;IfModule mime\_module&gt; section. Add the following line just before the closing &lt;/IfModule&gt; for that section.

`AddType application/x-httpd-php .php`

Add this line to the end of that file:

`Action application/x-httpd-php “/php/php-cgi”`

Search for this section:

`<Directory “/usr/share/cgi-bin”> AllowOverride None Options None Order allow,deny Allow from all </Directory>`

Add the following lines immediately after the section you just found.

`<Directory “/usr/bin”> AllowOverride None Options none Order allow,deny Allow from all </Directory>`

**`NOTE:`** The `/usr/bin` directory contains far more than just `php-cgi`. On a public server it could be wise to move `php-cgi` to its own directory and then configure Apache to use that separate directory instead!

### Configuring the default Index Page

Search for “DirectoryIndex index.html” and change to:

`DirectoryIndex index.php index.html`

Restart the Apache Web Server

```
apachectl restart
```

## Test PHP

Create `/usr/share/htdocs/index.php` with the following content:

`<?php phpinfo(); ?>`

Open your browser and access the file [http://192.168.1.1:81/index.php](http://192.168.1.1:81/index.php "http://192.168.1.1:81/index.php")

# Troubleshooting

When apache accept TCP connection, but not send respon. In log is: \[notice] child pid 19745 exit signal Segmentation fault (11)

It's necessary to set lower debug level: LogLevel error

[Original solution](https://dev.openwrt.org/ticket/10273 "https://dev.openwrt.org/ticket/10273")

# Start on boot

Normally apache will not start on boot, I believe its deliberate so that it wont conflict with the default (uHTTPd) web-server, *you will need to add a file to '/etc/init.d/', probably naming it apache and setting it for execution (chmod +x),* the file itself is rather simple :

`#!/bin/sh /etc/rc.common # Example script # Copyright (C) 2007 OpenWrt.org START=60 STOP=15 start() { echo launch apache # commands to launch application apachectl start } restart() { echo re-start apache # commands to launch application apachectl restart } stop() { echo stop apache # commands to kill application apachectl stop }`

once in place, you can issue the command **'/etc/init.d/apache enable'** to spawn the server @ boot
