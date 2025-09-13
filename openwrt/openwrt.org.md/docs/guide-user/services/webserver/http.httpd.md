# BusyBox HTTP Daemon (httpd) webserver

[BusyBox](/docs/techref/busybox "docs:techref:busybox") is a toolbox with tiny replacements of essential Linux programs. One of them is a tiny HTTP server `httpd` (HTTP Daemon). Early versions of OpenWrt before Attitude Adjustment 12.0 release used the `httpd` server but then switched to own [uHTTPd](/docs/guide-user/services/webserver/http.uhttpd "docs:guide-user:services:webserver:http.uhttpd") which has a built-in Lua interpreter so can serve Luci faster.

For a long period before BusyBox v1.37 (Dec 2024) the Luci didn't worked with plain BB httpd. So now it should be possible to use it with the Luci. The BB httpd can be compiled with only basic features like CGI and ETag and will have only 8Kb against 32Kb of stock uhttpd.

## Features

It's is a single threaded daemon with most needed features:

- [ETag](https://en.wikipedia.org/wiki/HTTP_ETag "https://en.wikipedia.org/wiki/HTTP_ETag") to avoid re-downloading of files cached in browser
- [CGI](https://en.wikipedia.org/wiki/Common%20Gateway%20Interface "https://en.wikipedia.org/wiki/Common Gateway Interface") to execute server side request processing
- [Basic authentication](https://en.wikipedia.org/wiki/Basic_access_authentication "https://en.wikipedia.org/wiki/Basic_access_authentication") to limit access by a password
- Serving pre-compressed gzip files with [Content-Encoding: gzip](https://en.wikipedia.org/wiki/HTTP_compression "https://en.wikipedia.org/wiki/HTTP_compression")
- [Range requests](https://datatracker.ietf.org/doc/html/rfc7233 "https://datatracker.ietf.org/doc/html/rfc7233") to get only part of a file.
- ACL by IP to allow or deny access
- [Reverse proxy](https://en.wikipedia.org/wiki/Reverse%20proxy "https://en.wikipedia.org/wiki/Reverse proxy")
- Custom error pages e.g. 404.html

But it doesn't support Keep Alive, TLS (HTTPS), Virtual Hosting, FastCGI and many other features so it's often replaced in embedded systems with [Lighttpd](/docs/guide-user/services/webserver/lighttpd "docs:guide-user:services:webserver:lighttpd")

## Installation

There is no package called `httpd` that you can install with `opkg`. The `httpd` is part of BusyBox functionality. You could either compile BusyBox with this functionality included, or you could install a second BusyBox binary with this functionality included.

## Usage

From [https://busybox.net/downloads/BusyBox.html#httpd](https://busybox.net/downloads/BusyBox.html#httpd "https://busybox.net/downloads/BusyBox.html#httpd"):

```
httpd [-ifv[v]] [-c CONFFILE] [-p [IP:]PORT] [-u USER[:GRP]] [-r REALM] [-h HOME] or httpd -d/-e/-m STRING

Listen for incoming HTTP requests

Options:

        -i              Inetd mode
        -f              Do not daemonize
        -v[v]           Verbose
        -c FILE         Configuration file (default httpd.conf)
        -p [IP:]PORT    Bind to ip:port (default *:80)
        -u USER[:GRP]   Set uid/gid after binding to port
        -r REALM        Authentication Realm for Basic Authentication
        -h HOME         Home directory (default .)
        -m STRING       MD5 crypt STRING
        -e STRING       HTML encode STRING
        -d STRING       URL decode STRING
```

Note that multiple instances of httpd can be run, which would have different `.conf` files:

```
/usr/sbin/httpd -p 80 -h /www
/usr/sbin/httpd -p 8080 -h /www2 -c /etc/httpd2.conf
```

## Configuration

`httpd` may work without a configuration file. But by default it will try to read config from `/etc/httpd.conf`. There were also some brief uci support for this: [httpd](/docs/guide-user/base-system/httpd "docs:guide-user:base-system:httpd").

The `httpd` documented itself [directly in source code](https://git.busybox.net/busybox/tree/networking/httpd.c "https://git.busybox.net/busybox/tree/networking/httpd.c")

Example of config file:

[/etc/httpd.conf](/_export/code/docs/guide-user/services/webserver/http.httpd?codeblock=2 "Download Snippet")

```
H:/serverroot     # define the server root. It will override -h
# Allow/Deny part
#
# [aA]:from    ip address allow, * for wildcard, network subnet allow
# [dD]:from    ip address deny, * for wildcard, network subnet allow
#
# network subnet definition
#  172.20.                    address from 172.20.0.0/16
#  10.0.0.0/25                address from 10.0.0.0-10.0.0.127
#  10.0.0.0/255.255.255.128   address that previous set
#
#  The Deny/Allow IP logic:
#
#  - Default is to allow all.  No addresses are denied unless
#         denied with a D: rule.
#  - Order of Deny/Allow rules is significant
#  - Deny rules take precedence over allow rules.
#  - If a deny all rule (D:*) is used it acts as a catch-all for unmatched
#       addresses.
#  - Specification of Allow all (A:*) is a no-op
#
# Example:
#   1. Allow only specified addresses
#     A:172.20          # Allow any address that begins with 172.20.
#     A:10.10.          # Allow any address that begins with 10.10.
#     A:127.0.0.1       # Allow local loopback connections
#     D:*               # Deny from other IP connections
#
#   2. Only deny specified addresses
#     D:1.2.3.        # deny from 1.2.3.0 - 1.2.3.255
#     D:2.3.4.        # deny from 2.3.4.0 - 2.3.4.255
#     A:*             # (optional line added for clarity)
#
# Note:
# A:*
# D:*
# Mean deny ALL !!!!
#

A:*

#
# Authentication part
#
# /path:user:pass     username/password
#
# password may be clear text or MD5 cript
#
# Example :
# /cgi-bin:admin:FOO
#
# MD5 crypt password :
# httpd -m "_password_"
# Example :
# httpd -m "astro"  =>  $1$$e6xMPuPW0w8dESCuffefU.
# /work:toor:$1$$e6xMPuPW0w8dESCuffefU.
#

#
# MIME type part
#
# .ext:mime/type   new mime type not compiled into httpd
#
# Example :
# .ipk:application/octet-stream
#
# MIME type compiled into httpd
#
# .htm:text/html
# .html:text/html
# .jpg:image/jpeg
# .jpeg:image/jpeg
# .gif:image/gif
# .png:image/png
# .txt:text/plain
# .h:text/plain
# .c:text/plain
# .cc:text/plain
# .cpp:text/plain
# .css:text/css
# .wav:audio/wav
# .avi:video/x-msvideo
# .qt:video/quicktime
# .mov:video/quicktime
# .mpe:video/mpeg
# .mpeg:video/mpeg
# .mid:audio/midi
# .midi:audio/midi
# .mp3:audio/mpeg
#
# Default MIME type is application/octet-stream if extension isn't set

# Use Unicode for text files
.txt:text/plain;charset=utf-8
.md:text/plain;charset=utf-8
.htm:text/html;charset=utf-8
.html:text/html;charset=utf-8

# configure interpreters. 
*.php:/usr/bin/php-cgi
*.pl:/usr/bin/perl
*.rb:/usr/bin/ruby
*.erb:/usr/bin/eruby
*.py:/usr/bin/python
# The *.cgi often are Perl files but may be just a shell with shebang
#*.cgi:/usr/bin/perl
```

Example of BB httpd options and their analogues in Apache HTTPD:

BB httpd conf option Apache HTTPD conf option `I:default.htm` `DirectoryIndex default.htm` `H:/srv/www/` `DocumentRoot /srv/www/` `A:192.168.11.1` `Allow from 192.168.11.1` `D:*` `Deny from all` `E401:401.html` `ErrorDocument 401 /401.html` `P:/blog:wp/` `ProxyPass /blog:http://wp/` `.webp:image/webp` `AddType image/webp webp` `*.py:/usr/bin/python` `AddHandler mod_python .py` (the mod\_python must be enabled) `/cgi-bin:admin:SECRET` `AuthType Basic`, `AuthUserFile /etc/.htpasswd` (you'll need to create a separate file)

## CGI scripts

`httpd` expects it's CGI script files to be in the subdirectory `cgi-bin` under main web directory set by options `-h` (default is `/www`, so `/www/cgi-bin`). The CGI script files must also have permission to be executed (min mode 700). If directory URL is given, no `index.html` is found and CGI support is enabled, then `cgi-bin/index.cgi` will be executed.

BusyBox sources contains two useful CGI programs:

- [httpd\_indexcgi.c](https://git.busybox.net/busybox/tree/networking/httpd_indexcgi.c "https://git.busybox.net/busybox/tree/networking/httpd_indexcgi.c") generates a directory listing i.e. list of files. Other Web Servers has this as built-in feature but for BB http this is delegated to a CGI program.
- [httpd\_ssi.c](https://git.busybox.net/busybox/tree/networking/httpd_ssi.c "https://git.busybox.net/busybox/tree/networking/httpd_ssi.c") processes [Server Side Includes](https://en.wikipedia.org/wiki/Server%20Side%20Includes "https://en.wikipedia.org/wiki/Server Side Includes")

Use `httpd_helpers.sh` to compile them. Also there is and example of shell script to process File Upload [httpd\_post\_upload.cgi](https://git.busybox.net/busybox/tree/networking/httpd_post_upload.cgi "https://git.busybox.net/busybox/tree/networking/httpd_post_upload.cgi")

Check more [CGI shell samples](https://gist.github.com/stokito/a9a2732ffc7982978a16e40e8d063c8f "https://gist.github.com/stokito/a9a2732ffc7982978a16e40e8d063c8f").

### CGI Variables

Standard set of Common Gateway Interface environment variables are described in [RFC3875](https://datatracker.ietf.org/doc/html/rfc3875 "https://datatracker.ietf.org/doc/html/rfc3875"). For example:

```
CONTENT_TYPE=application/x-www-form-urlencoded
CONTENT_LENGTH=128
REQUEST_METHOD=POST
REQUEST_URI=/cgi-bin/printenvs
QUERY_STRING=param1=12345&param2=&param3=some%20text
REMOTE_USER=[http basic auth username]
HTTP_HOST: "example.com"
HTTP_USER_AGENT: "Chrome"
HTTP_ACCEPT: "*/*"
HTTP_REFERER=http://192.168.1.1/index1.html
REMOTE_ADDR=192.168.1.180
REMOTE_PORT=2292
SERVER_PORT=80
PATH=/bin:/sbin:/usr/bin:/usr/sbin
PATH_INFO=
PWD=/www/cgi-bin
SCRIPT_NAME=/cgi-bin/printenvs
SERVER_PROTOCOL=HTTP/1.0
GATEWAY_INTERFACE=CGI/1.1
SERVER_SOFTWARE=busybox httpd/1.30.1
```

Example of CGI script that prints them:

[/cgi-bin/printenvs](/_export/code/docs/guide-user/services/webserver/http.httpd?codeblock=4 "Download Snippet")

```
#!/bin/sh
echo "Content-Type: text/html"
echo ""
echo "Environment variables:"
env
```

Environment variables are set up and the script is invoked with pipes for stdin/stdout.

All request headers are available with HTTP prefix e.g. Host header will be passed in HTTP\_HOST env.

### HTTPS

BB httpd doesn't support TLS but you may try to use [stunnel](https://www.stunnel.org/index.html "https://www.stunnel.org/index.html").

### Reverse Proxy

BB httpd has a very basic reverse proxy support but it's not compiled by default. Use `FEATURE_HTTPD_PROXY` to enable it.

This option allows you to define URLs that will be forwarded to another HTTP server (the HTTPS is not supported). To setup add the following line to the configuration file:

```
P:/old/path:[http://]hostname[:port]/new/path
```

Then a request to `/old/path` will be forwarded to `http://hostname[:port]/new/path`.

### Serve gzipped files

For every file that should be served gzipped, add a matching `[FILENAME].gz`. The `.gz` file will be server instead of the original file so you may remove the original file.

### See also

\* [Using the busybox HTTP server](http://wiki.chumby.com/index.php?title=Using_the_busybox_HTTP_server "http://wiki.chumby.com/index.php?title=Using_the_busybox_HTTP_server") * [docker-static-website](https://github.com/forksss/docker-static-website "https://github.com/forksss/docker-static-website") a Docker image to run the BusyBox httpd
