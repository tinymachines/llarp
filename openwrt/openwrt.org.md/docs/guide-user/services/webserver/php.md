# PHP

## Installation

1. List available php packages
   
   ```
   opkg update
   opkg list php*
   ```
2. Install php
   
   ```
   opkg install php7 php7-cgi
   ```

## Configuration

For configuration please see the wiki-page for the particular web server: [webserver](/docs/guide-user/services/webserver/start "docs:guide-user:services:webserver:start"), e.g.

- [Configuring Apache and PHP5](/docs/guide-user/services/webserver/http.apache#configuring_apache_and_php5 "docs:guide-user:services:webserver:http.apache")
- [Configuring Lighttpd and PHP5](/docs/guide-user/services/webserver/lighttpd#configuring_lighttpd_and_php5 "docs:guide-user:services:webserver:lighttpd")
- [Configuring Hiawatha and PHP5](/docs/guide-user/services/webserver/http.hiawatha#configuring_hiawatha_and_php5 "docs:guide-user:services:webserver:http.hiawatha")
- [Configuring Nginx and PHP5](/docs/guide-user/services/webserver/nginx#configuring_nginx_and_php5 "docs:guide-user:services:webserver:nginx")
- [Configuring uhttpd and PHP5](/docs/guide-user/services/webserver/uhttpd "docs:guide-user:services:webserver:uhttpd")
- or see [Configuring PHP](/docs/guide-user/services/webserver/lamp#configuring_php "docs:guide-user:services:webserver:lamp")

## Troubleshooting

If you encounter PHP errors, like undefined functions, you need take a look into the `php.ini` file. Search for the appropriate extension line(s), and uncomment them (remove the ; sign). If the problem persists, you probably need to install the appropriate extension too. If PHP runs out of memory, you can increase the amount of memory which the script can consume:

```
memory_limit = 8M       ; Maximum amount of memory a script may consume.
post_max_size = 8M
```

Do not specify more memory than is available, and remember that other processes need memory too. Please note, some things will probably never run on the router. Especially under Backfire 10.03. PHP compiled without the SimpleXML extension, and libxml is missing too. If they are necessary, you need to recompile your own PHP. Without this extensions, some software, like Joomla 1.6 will never run. If you do manage to achieve to run, serious software solutions will run extremely slow, and will consume too much memory.

## PHP Development Server

This section explains how to quickly setup a php test server for prototyping php web applications, using php's own internal web server.

A little known trick about php is that it has it's own built in web server.  
If you install the command line php binary, you can run a quick, no frills web server on OpenWrt for development work and prototyping.  
In no way should you expect a fully production ready web server from this method. php's internal web server is recommended for your own internal network testing and is not recommended as an alternative to a fully fledged http server daemon.  
With that said; complete the following steps to create a quick php development server inside of an OpenWrt instance:

Install the [php7-cgi](/packages/pkgdata/php7-cgi "packages:pkgdata:php7-cgi") package using [opkg](/docs/guide-user/additional-software/opkg "docs:guide-user:additional-software:opkg").

```
opkg update && opkg install php7-cli
```

*(This pulls in packages [libpcre](/packages/pkgdata/libpcre "packages:pkgdata:libpcre") [zlib](/packages/pkgdata/zlib "packages:pkgdata:zlib") [libxml2](/packages/pkgdata/libxml2 "packages:pkgdata:libxml2") [zoneinfo-core](/packages/pkgdata/zoneinfo-core "packages:pkgdata:zoneinfo-core") [php7](/packages/pkgdata/php7 "packages:pkgdata:php7") as part of the installation.)*

Optionally, now remove the package cache if you are low on memory space.

```
rm -r /tmp/opkg-lists/
```

Create a www directory (during testing, I skipped this normal step and just used the /root directory instead.)

```
mkdir /www
```

Use a text editor ([nano](/packages/pkgdata/nano "packages:pkgdata:nano") in this example) to create the file **index.php** inside of the **/www** directory (nano can be installed via [opkg](/docs/guide-user/additional-software/opkg "docs:guide-user:additional-software:opkg") if need be.)

```
nano /www/index.php
```

Add the text “**It works!**” into the file, save and close it.

Start the webserver from the command line.

```
php-cli -S 172.16.0.1:8080 -t /www
```

*(Replace **172.16.0.1:8080** with the ip address of your OpenWrt instance and the port number you want to use to access the server by.)*

Open a web browser and visit the address **http://172.16.0.1:8080** (or whatever you used instead) and you should see the text “**It works!**” on the page.

That's all there is to it.

Taking it further, you could optionally [create a startup script](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") which automates starting the server.  
To stop the server use the **ctrl + c** key combination.  
To spawn the server into a separate process and return command back to the console, add a double ampersand to the end of the command line options you use to start the server.

```
php-cli -S 172.16.0.1:8080 -t /www &&
```

The web server will then remain running until it's process is manually ended or the OpenWrt instance has been rebooted.
