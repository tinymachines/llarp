# uHTTPd Web Server Configuration

The `/etc/config/uhttpd` configuration is provided by the [uhttpd](/docs/guide-user/services/webserver/http.uhttpd "docs:guide-user:services:webserver:http.uhttpd") web server package. This file defines the behavior of the server and default values for certificates generated for SSL operation. uhttpd supports multiple instances (i.e. multiple listen ports, each with its own document root and other features) as well as cgi, php7, perl and lua.

## Sections

There are two sections defined, the section of type `uhttpd` contains general server settings while the `cert` one defines the default values for SSL certificates.

For information on sections and UCI configuration see [The UCI System](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci")

### Server Settings

A minimal `uhttpd` config section must consist of at least the document root and HTTP listen options:

```
config 'uhttpd' 'main'
        option 'listen_http' '80'
        option 'home'        '/www'
```

The options defined for this section are outlined below.

Name Type Required Default Description `listen_http` list of port or address:port pairs yes, if `'listen_https`' is not given *(none)* Specifies the ports and addresses to listen on for plain HTTP access. If only a port number is given, the server will attempt to serve both IPv4 and IPv6 requests. Use `0.0.0.0:80` to bind at port 80 only on IPv4 interfaces or `[::]:80` to serve only IPv6. To run on multiple addresses, specifying each, you can list one address (or address:port) per line. You can use DNS or even [DynDNS](/docs/guide-user/services/ddns/client "docs:guide-user:services:ddns:client") domain instead of IP but note that this is not any kind of virtual hosting `listen_https` list of port or address:port pairs yes, if `'listen_http`' is not given *(none)* Specifies the ports and addresses to listen on for encrypted HTTPS access. The format is the same as for `listen_http`. **Read below for extra details** `home` directory path yes `/www` Defines the server document root `cert` file path yes if `listen_https` is given, else no `/etc/uhttpd.crt` ASN.1/DER or PEM certificate used to serve HTTPS connections. If you want to you use an intermediate certificate you concatenate it to one file (PEM only!). Some PEM formats may require the luci-ssl-openssl package. `key` file path yes if `listen_https` is given, else no `/etc/uhttpd.key` ASN.1/DER or PEM private key used to serve HTTPS connections. Some PEM formats may require the luci-ssl-openssl package. `cgi_prefix` string no `/cgi-bin` Defines the prefix for CGI scripts, relative to the document root. CGI support is disabled if this option is missing `lua_prefix` string no *(none)* Defines the prefix for dispatching requests to the embedded Lua interpreter, relative to the document root. Lua support is disabled if this option is missing `lua_handler` file path yes if `lua_prefix` is given, else no *(none)* Lua handler script used to initialize the Lua runtime on server start `script_timeout` integer no `60` Maximum wait time for CGI or Lua requests in seconds. Requested executables are terminated if no output was generated until the timeout expired `network_timeout` integer no `30` Maximum wait time for network activity. Requested executables are terminated and connection is shut down if no network activity occured for the specified number of seconds `realm` string no *local hostname* Basic authentication realm when prompting the client for credentials (HTTP 400) `config` file path no `/etc/httpd.conf` Config file in Busybox httpd format for additional settings (currently only used to specify Basic Auth areas) `index_file` file name no `index.html`, `index.htm,` `default.html`, `default.htm` Index file to use for directories, e.g. add index.php when using php `index_page` file name no `index.html` Index file to use for directories, e.g. add index.php when using php (last, 20131015, replace index\_file ?) should be noted: list index\_page “index.html index.htm default.html default.htm index.php” `error_page` string no *(none)* Virtual URL of file or CGI script to handle 404 request. Must begin with '/' `no_symlinks` boolean no `0` Do not follow symbolic links if enabled `no_dirlists` boolean no `0` Do not generate directory listings if enabled `rfc1918_filter` boolean no `1` Reject requests from [RFC1918](https://en.wikipedia.org/wiki/Private_network "https://en.wikipedia.org/wiki/Private_network") IP addresses directed to the servers public IPs. This is a DNS rebinding countermeasure. `http_keepalive` integer no `20` connection reuse. Some bugs have been seen, you *may* wish to disable this by setting to `0` (BB or later only) `max_requests` integer no `3` Maximum number of concurrent requests. If this number is exceeded, further requests are queued until the number of running requests drops below the limit again. `max_connections` integer no `100` Maximum number of concurrent connections. If this number is exceeded, further TCP connection attempts are queued until the number of active connections drops below the limit again. `ubus_prefix` string no *(none)* URL prefix for [UBUS via JSON-RPC handler](/docs/techref/ubus#access_to_ubus_over_http "docs:techref:ubus") e.g. `/ubus`. If not specified then UBUS is not enabled. `ubus_socket` file no *(none)* Override ubus socket path `ubus_noauth` boolean no `0` Do not authenticate JSON-RPC requests against UBUS session api `ubus_cors` boolean no `0` Enable CORS HTTP headers on JSON-RPC api

Multiple sections if the type `uhttpd` may exist - the init script will launch one webserver instance per section.

As specified in the [The UCI System](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") documentation, each of the `uhttpd` sections must be named differently.

```
config 'uhttpd' 'main'
        option 'listen_http' '80'
        option 'home'        '/www'
 
config 'uhttpd' 'other'
        option 'listen_http' '8080'
        option 'home'        '/www/other'
```

### HTTPS Enable and Certificate Settings and Creation

In order to speak HTTPS/TLS, uhttpd needs one of several [cryptographic libraries](/docs/guide-user/services/tls/libs "docs:guide-user:services:tls:libs"). Such `libuhttpd-...` packages can be installed via opkg, e.g. `libuhttpd-mbedtls`, `libuhttpd-openssl` or `libuhttpd-wolfssl`.

In the server configuration, the `listen_https` option needs to be defined as explained above.

uhttpd requires an X.509 certificate and a private key. You can create and copy them manually to the place specified in the configuration.

There is an alternative: In this case (as of 10.03.1) you'll need to install the `luci-ssl` meta-package which in turn will pull also the `px5g` script. With this utility the init script will generate the appropriate self signed certificate and key files when the server is started for the first time, either by reboot or by manual restart.

The `/etc/config/uhttpd` file contains in the end a section detailing the certificate and key files creation parameters:

Name Type Required Default Description `days` integer no `730` Validity time of the generated certificates in days `bits` integer no `2048` Size of the generated RSA key in bits `country` string no `ZZ` ISO country code of the certificate issuer `state` string no `Somewhere` State of the certificate issuer `location` string no `Unknown` Location/city of the certificate issuer `commonname` string no `OpenWrt` Common name covered by the certificate `organization` string no *“OpenWrt” followed by random string* Organization name covered by the certificate

Those will be needed only once, at the next restart.

If you are hosting the website to internet you may want to [obtain LetsEncrypt certificates](/docs/guide-user/services/tls/certs "docs:guide-user:services:tls:certs").

## Basic Authentication (httpd.conf)

For backward compatibility reasons, *uhttpd* uses the old *Busybox httpd* config file `/etc/httpd.conf` to define authentication areas and the associated usernames and passwords. This configuration file is **not** in UCI format and usually shipped or generated by external packages like `webif` (X-Wrt).

Authentication realms are defined in the format `prefix:username:password` with one entry per line followed by a newline.

- `prefix` is the URL part covered by the realm, e.g. `/cgi-bin` to request basic auth for any CGI program
- `username` specifies the username a client has to login with
- `password` defines the secret password required to authenticate

The password can be either in plain text format, [crypt(1) MD5](https://en.wikipedia.org/wiki/Crypt_%28Unix%29 "https://en.wikipedia.org/wiki/Crypt_(Unix)") encoded or in the form `$p$user` where `user` refers to an account in `/etc/shadow` or `/etc/passwd`.

A plain text password can be converted to MD5 encoding by using the `-m` switch of the *uhttpd* executable:

```
# uhttpd -m secret
$1$$ysVNzQc4CTMkp5daOdZ.3/
```

If the `$p$...` format is used, *uhttpd* will compare the client provided password against the one stored in the `shadow` or `passwd` database.

Example:

[/etc/httpd.conf](/_export/code/docs/guide-user/services/webserver/uhttpd?codeblock=3 "Download Snippet")

```
/dashboard/:admin:$1$$ysVNzQc4CTMkp5daOdZ.3/
/:root:$p$root
/:alice:P@$$w0rd
```

- Here the `/dashboard/` path is protected but allowed for user `admin` with the password `secret` that is hashed with crypt(1) MD5.
- The root path `/` is allowd to the user `root` and it's password will be taken from `/etc/passwd`
- Also the `/` path is allowed for the user `alice` and shes password is `P@$$w0rd` which is not hashed and stored in clear text.

## URL decoding

Like *Busybox HTTPd*, the URL decoding of strings on the command line is supported through the `-d` switch:

```
root@OpenWrt:/# uhttpd -d "An%20URL%20encoded%20String%21%0a"
An URL encoded String!
```

## Using PHP7

A minimal php7 installation includes:

- php7
- php7-cgi

In `/etc/php.ini` ensure that the doc\_root is empty if you are using multiple uhttpd instances (each on its own port). This enables the uhttpd `home` variable to work for you.

Ensure that you uncomment the extension interpreter line for PHP in the main section of the uHTTPd config file:

```
list interpreter ".php=/usr/bin/php-cgi"
```

## Securing uHTTPd

By default, uHTTPd is bind to `0.0.0.0` which also includes the WAN port of your router. To bind uHTTPd to the LAN port only you have to change the `listen_http` and `listen_https` options to your LAN IP address.

To get your current LAN IP address run this command:

```
# uci get network.lan.ipaddr
192.168.1.1
```

Then edit `/etc/config/uhttpd` and bind `listen_http` to specific `192.168.1.1` IP instead of `0.0.0.0` and comment out IPv6 bindings:

```
config uhttpd main
        # HTTP listen addresses, multiple allowed
        list listen_http        192.168.1.1:80
#       list listen_http        [::]:80
 
        # HTTPS listen addresses, multiple allowed
        list listen_https       192.168.1.1:443
#       list listen_https       [::]:443
```

See [Accessing LuCI web interface securely](/docs/guide-user/luci/luci.secure "docs:guide-user:luci:luci.secure") for more details.

## Embedded Lua

uHTTPd supports running Lua in-process, which can speed up Lua CGI scripts. Also LuCI works fine with the embedded Lua interpreter. See the next subsection for instructions on how to set it up.

Here is an example using a test file `test.lua` to show it works:

[/root/test.lua](/_export/code/docs/guide-user/services/webserver/uhttpd?codeblock=8 "Download Snippet")

```
function handle_request(env)
        uhttpd.send("Status: 200 OK\r\n")
        uhttpd.send("Content-Type: text/plain\r\n\r\n")
        uhttpd.send("Hello world.\n")
end
```

Now to test it install the `uhttpd-mod-lua` plugin and configure it:

```
opkg install uhttpd-mod-lua
uci set uhttpd.main.lua_prefix=/lua
uci set uhttpd.main.lua_handler=/root/test.lua
/etc/init.d/uhttpd restart
wget -qO- http://127.0.0.1/lua/
# Hello world.
```

### LuCI with embedded Lua interpreter

You need to install `uhttpd-mod-lua` and `luci-sgi-uhttpd` to get it to work:

```
opkg install uhttpd-mod-lua luci-sgi-uhttpd
```

Since Chaos Calmer 15.05, the `luci-sgi-uhttpd` package is not needed. The appropriate files are included in `luci-base`.

Then uncomment the following lines in `/etc/config/uhttpd` (or add them if you don't have them):

```
        option lua_prefix       /luci
        option lua_handler      /usr/lib/lua/luci/sgi/uhttpd.lua
```

Then restart the server:

```
/etc/init.d/uhttpd restart
```

One thing remains to be done. By default `/www/index.html` redirects you to `/cgi-bin/luci` which is the default CGI gateway for LuCI. The config above puts LuCI through embedded interpreter under `/luci` (`lua_prefix` is what causes it) so you have to change that in `/www/index.html`. The path appears there twice (one for the `meta` tag which does the redirect and one for the anchor). You can also copy/paste the code below if you don't want to meddle with it on your own.

```
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="refresh" content="0; URL=/luci" />
</head>
<body style="background-color: black">
<a style="color: white; text-decoration: none" href="/luci">LuCI - Lua Configuration Interface</a>
</body>
</html>
```

Also remember to flush the browser's cache if you relied on the redirection because otherwise it will probably keep redirecting you to `/cgi-bin/luci` until the cache expires by itself.
