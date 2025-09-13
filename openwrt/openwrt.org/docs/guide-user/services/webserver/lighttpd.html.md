# Lighttpd webserver

LuCI is the main web administration utility for OpenWrt. **By default LuCI uses [uHTTPd](/docs/guide-user/services/webserver/http.uhttpd "docs:guide-user:services:webserver:http.uhttpd")**.

Lighttpd is a highly-configurable, lightweight web server. See [lighttpd](https://en.wikipedia.org/wiki/lighttpd "https://en.wikipedia.org/wiki/lighttpd") and [https://www.lighttpd.net/](https://www.lighttpd.net/ "https://www.lighttpd.net/"). There are many modules available for lighttpd that can be installed and configured. For more information on the modules see [https://redmine.lighttpd.net/projects/lighttpd/wiki/docs](https://redmine.lighttpd.net/projects/lighttpd/wiki/docs "https://redmine.lighttpd.net/projects/lighttpd/wiki/docs"). This article explains how to get lighttpd working on OpenWrt.

Consult [luci.on.lighttpd](/docs/guide-user/luci/luci.on.lighttpd "docs:guide-user:luci:luci.on.lighttpd") to make lighttpd serve the LuCI web interface.

## Requirements

Execute

```
opkg list lighttpd*
```

to see what packages are available.

## Installation

Use [opkg](/docs/guide-user/additional-software/opkg "docs:guide-user:additional-software:opkg")

```
opkg update
opkg install lighttpd
```

## Configuration

Edit `/etc/lighttpd/lighttpd.conf`

### Basic Configuration

To get a basic server running make the following changes to `/etc/lighttpd/lighttpd.conf`:

*Server Root Directory*

```
server.document-root = "/www/"
```

where the `www` is the root directory of the web server.

*Enable Logging*

Uncomment (remove #) the following line so errors are written to the log:

```
server.errorlog = "/var/log/lighttpd/error.log"
```

*Set Server Port*

Uncomment the following line:

```
server.port = 8000
```

where 8000 is the port you want your webserver on.

### Advanced Configuration

- [Set up a LAMP stack on OpenWrt](/docs/guide-user/services/webserver/lamp "docs:guide-user:services:webserver:lamp")
- [WebDAV with Lighttpd on OpenWRT](/docs/guide-user/services/nas/webdav "docs:guide-user:services:nas:webdav")

## Configuring Lighttpd and PHP

1. First, follow [php](/docs/guide-user/services/webserver/php "docs:guide-user:services:webserver:php") to install a version of PHP
2. Second, follow [lighttpd1](/docs/guide-user/services/webserver/lamp#lighttpd1 "docs:guide-user:services:webserver:lamp") to configure lighttpd
3. Third, to get PHP running with Lighttpd you need to install the package `lighttpd-mod-cgi`

## Start on boot

To enable/disable start on boot:  
`/etc/init.d/lighttpd enable` this simply creates a symlink: `/etc/rc.d/S80lighttpd → /etc/init.d/lighttpd`  
`/etc/init.d/lighttpd disable` this removes the symlink again

To start the server:

```
/etc/init.d/lighttpd start
```

To stop the server:

```
/etc/init.d/lighttpd stop
```

## Firewall

To allow users on the WAN to access the server, make sure to configure the firewall in `/etc/config/firewall` and port forwarding settings.

```
config redirect
        option src              wan
        option src_dport        80
        option dest             lan
        option dest_ip          192.168.1.1
        option dest_port        8000
        option proto            tcp

config rule
        option src              wan
        option dest_port        8000
        option target           ACCEPT
        option proto            tcp
```

Restart the firewall with the following command: `/etc/init.d/firewall restart`

## Administration

**Add virtual hosts via mod\_simple\_vhost**

The goal is to run only one server on port 80. At the same time, this server should distinguish between different websites or directories. First, the Lighttpd server is configured as described. It must be ensured that the server works on port 80 (or any other port). In my example, the local domain suffix was specified with “h” (see dnsmasq configuration).

Now add the following entries to your file: `/etc/config/dhcp`

```
config domain
      option name 'luci'
      option ip '192.168.1.1'

config domain
      option name 'home'
      option ip '192.168.1.1'
```

Add Module `mod_simple_vhost` to your: `/etc/lighttpd/lighttpd.conf` `server.modules = ( “mod_simple_vhost”, )`

Create virtual host Configuration: `/etc/lighttpd/conf.d/IntraNet.conf`

```
$HTTP["host"] =~ "^luci.h(\:[0-9]*)?$" {
    dir-listing.activate = "disable"
    server.document-root = "/www/"
    $HTTP["url"] =~ "^/cgi-bin" {
        cgi.assign += ( "" => "" )
    }
}

$HTTP["host"] =~ "^home.h(\:[0-9]*)?$" {
    dir-listing.activate = "enable"
    server.document-root = "/www/Home/"
    url.redirect = ( "^/config/" => "/www/status-403.html",
                    "^/data/" => "/www/status-403.html",
                  )
}
```

Restarted dnsmasq and lighttpd: `/etc/init.d/dnsmasq restart; /etc/init.d/lighttpd restart;`

Via the address luci.h the configuration can now be called, and another website via home.h The IntraNet.conf can be extended with more virtual host names. Within virtual host you can configure host specific configurations.

You can also configure Internet Websites with this, like example.org or second.example.org

*Make sure that the browser cache is deleted, often a new presence did not work because there is still some old information in the cache.*

## Troubleshooting

*Incorrect Event Handler*

If you get the following error:

```
(server.c.1105) fdevent_init failed
```

you might need to set the event handler explicitly for your system. Add the following line to the configuration file:

```
server.event-handler = "poll"
```

See [https://redmine.lighttpd.net/projects/lighttpd/wiki/Server.event-handlerDetails](https://redmine.lighttpd.net/projects/lighttpd/wiki/Server.event-handlerDetails "https://redmine.lighttpd.net/projects/lighttpd/wiki/Server.event-handlerDetails")

## Notes

Note that lighttpd does not support `.htaccess` files as some web servers do to configure directory specific server settings. Instead, it uses a centrally configured system using `lighttpd.conf` to define all settings, using powerful matching functions. This still means that you have to manually set up directory settings. Especially for (opkg) packages that supply `.htaccess` files to define required settings. Allowing directory listings is one example that should be disabled or enabled as per the required security level.
