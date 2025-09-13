# Nginx webserver

[Nginx](http://wiki.nginx.org/ "http://wiki.nginx.org/") is a high-performance HTTP/S server with other functions as well. It is a perfect candidate to run on OpenWrt due to the performance and memory handling. **NB:** At this time (2020-07-21), the configuration described below is contained in the master, but not in the current release (19.07).

## Install

We can install Nginx with SSL (using libopenssl) by:

```
 opkg update && opkg install nginx-ssl 
```

Of course there will be port issues if we installed [LuCI](/docs/guide-user/luci/luci.essentials "docs:guide-user:luci:luci.essentials") before or after Nginx, since the standard LuCI package installs [uHTTPd](/docs/guide-user/services/webserver/uhttpd "docs:guide-user:services:webserver:uhttpd"), which also wants to claim port 80 (and port 443 for HTTPS). So configuring and/or portforwarding may be neccessary. There are ways to run [LuCI with Nginx](/docs/guide-user/luci/luci.essentials#configuration "docs:guide-user:luci:luci.essentials") but that is not coverd here. For a quick fix, just change the uhttpd port to something else in `/etc/config/uhttpd`.

## Configuration

The official Documentation contains a [Admin Guide](https://docs.nginx.com/nginx/admin-guide/ "https://docs.nginx.com/nginx/admin-guide/"). Here we will look at some often used configuration parts and how we handle them at OpenWrt. At different places there are references to the official [Technical Specs](https://docs.nginx.com/nginx/technical-specs/ "https://docs.nginx.com/nginx/technical-specs/") for further reading.

**tl;dr:** When starting Nginx by `/etc/init.d/nginx`, it creates its main configuration dynamically based on a minimal template and the [🡒UCI](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") configuration.

The UCI `/etc/config/nginx` contains initially:

`config server '_lan`' Default server for the LAN, which includes all `/etc/nginx/conf.d/*.locations`. `config server '_redirect2ssl`' Redirects inexistent URLs to HTTPS.

It enables also the `/etc/nginx/conf.d/` directory for further configuration:

`/etc/nginx/conf.d/$NAME.conf` Is included in the main configuration. It is prioritized over a UCI `config server '$NAME'`. `/etc/nginx/conf.d/$NAME.locations` Is include in the `_lan` server and can be re-used for others, too. `/etc/nginx/restrict_locally` Is include in the `_lan` server and allows only accesses from LAN.

Setup configuration (for a server `$NAME`):

`nginx-util [add_ssl|del_ssl] $NAME` Add/remove a self-signed certificate and corresponding directives. `uci set nginx.$NAME.access_log='logd openwrt`' Writes accesses to Openwrt’s [🡒logd](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials"). `uci set nginx.$NAME.error_log='logd'` Writes errors to Openwrt’s [🡒logd](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials"). `uci [set|add_list] nginx.$NAME.key='value'` Becomes a `key value;` directive if the *key* does not start with *uci\_*. `uci set nginx.$NAME=[disable|server]` Disable/enable inclusion in the dynamic conf. `uci set nginx.global.uci_enable=false` Use a custom `/etc/nginx/nginx.conf` rather than a dynamic conf.

### Basic

We modify the configuration by changing servers saved in the UCI configuration at `/etc/config/nginx` and/or by creating different configuration files in the `/etc/nginx/conf.d/` directory. These files use the file extensions `.locations` and `.conf` plus `.crt` and `.key` for SSL certificates and keys.[1)](#fn__1) For the new configuration to take effect, we must reload it by:

```
service nginx reload
```

For OpenWrt we use a special initial configuration, which is explained in the section [🡓OpenWrt’s Defaults](#openwrt_s_defaults "docs:guide-user:services:webserver:nginx ↵"). So, we can make a site available at a specific URL in the **LAN** by creating a `.locations` file in the directory `/etc/nginx/conf.d/`. Such a file consists just of some [location blocks](https://nginx.org/en/docs/http/ngx_http_core_module.html#location "https://nginx.org/en/docs/http/ngx_http_core_module.html#location"). Under the latter link, you can find also the official documentation for all available directives of the HTTP core of Nginx. Look for *location* in the Context list.

The following example provides a simple template, see at the end for different [🡓Locations for Apps](#locations_for_apps "docs:guide-user:services:webserver:nginx ↵")[2)](#fn__2):

[/etc/nginx/conf.d/example.locations](/_export/code/docs/guide-user/services/webserver/nginx?codeblock=2 "Download Snippet")

```
location /ex/am/ple {
	access_log off; # default: not logging accesses.
	# access_log /proc/self/fd/1 openwrt; # use logd (init forwards stdout).
	# error_log stderr; # default: logging to logd (init forwards stderr).
	error_log /dev/null; # disable error logging after config file is read.
	# (state path of a file for access_log/error_log to the file instead.)
	index index.html;
}
# location /eg/static { … }
```

All location blocks in all `.locations` files must use different URLs, since they are all included in the `_lan` server that is part of the [🡓OpenWrt’s Defaults](#openwrt_s_defaults "docs:guide-user:services:webserver:nginx ↵").[3)](#fn__3) We should use the root URL for other sites than LuCI only on **other** domain names, e.g., we could make a site available at [https://example.com/](https://example.com/ "https://example.com/"). In order to do that, we create [🡓New Server Parts](#new_server_parts "docs:guide-user:services:webserver:nginx ↵") for all domain names. We can also activate SSL thereby, see [🡓SSL Server Parts](#ssl_server_parts "docs:guide-user:services:webserver:nginx ↵"). We use such server parts also for publishing sites to the internet (WAN) instead of making them available just locally (in the LAN).

Via `/etc/nginx/conf.d/*.conf` files we can add directives to the *http* part of the configuration. If you would change the configuration `uci.conf.template` instead, it is not updated to new package's versions anymore. Although it is not recommended, you can also disable the whole UCI config and create your own `/etc/nginx/nginx.conf`; then invoke:

```
uci set nginx.global.uci_enable=false
```

### New Server Parts

For making the router reachable from the WAN at a registered domain name, it is not enough letting the [🡒firewall](/docs/guide-user/firewall/firewall_configuration "docs:guide-user:firewall:firewall_configuration") accept requests (typically on ports 80 and 443) and giving the name server the internet IP address of the router (maybe updated automatically by a [🡒DDNS Client](/docs/guide-user/services/ddns/client "docs:guide-user:services:ddns:client")).

We also need to set up virtual hosting for this domain name by creating an appropriate server section in `/etc/config/nginx` (or in a `/etc/nginx/conf.d/*.conf` file, which cannot be changed using UCI). All such parts are included in the main configuration of OpenWrt ([🡓OpenWrt’s Defaults](#openwrt_s_defaults "docs:guide-user:services:webserver:nginx ↵")).

In the server part, we state the domain as [server\_name](https://nginx.org/en/docs/http/ngx_http_core_module.html#server_name "https://nginx.org/en/docs/http/ngx_http_core_module.html#server_name"). The link points to the same document as for the location blocks in the [🡑Basic Configuration](#basic "docs:guide-user:services:webserver:nginx ↵"): the official documentation for all available directives of the HTTP core of Nginx. This time look for *server* in the Context list, too. The server part should also contain similar location blocks as [before.](#folded_6d82c449bef8284042dc7a474ea867cf_1) We can re-include a `.locations` file that is included in the server part for the LAN by default. Then the site is reachable under the same path at both domains, e.g. by [https://192.168.1.1/ex/am/ple](https://192.168.1.1/ex/am/ple "https://192.168.1.1/ex/am/ple") as well as by [https://example.com/ex/am/ple](https://example.com/ex/am/ple "https://example.com/ex/am/ple").

We can add directives to a server in the UCI configuration by invoking `uci [set|add_list] nginx.example_com.key=value`. If the *key* is not starting with *uci\_*, it becomes a `key value;` [directive.](#folded_6d82c449bef8284042dc7a474ea867cf_2) Although the UCI config does not support nesting like Nginx, we can add a whole block as *value*.

We cannot use dots in a *key* name other than in the *value*. In the following example we replace the dot in *example.com* by an underscore for the UCI name of the server, but not for Nginx's *server\_name*:

```
uci add nginx server &&
uci rename nginx.@server[-1]=example_com &&
uci add_list nginx.example_com.listen='80' &&
uci add_list nginx.example_com.listen='[::]:80' &&
uci set nginx.example_com.server_name='example.com' &&
uci add_list nginx.example_com.include='conf.d/example.com.locations'
# uci add_list nginx.example_com.location='/ { … }' # root location for this server.
```

We can disable respective re-enable this server again by:

```
uci set nginx.example_com=disable # respective: uci set nginx.example_com=server
```

These changes are made in the RAM (and can be used until a reboot), we can save them permanently by:

```
uci commit nginx
```

For creating a similar `/etc/nginx/conf.d/example.com.conf`, we can adopt the following:

[/etc/nginx/conf.d/example.com.conf](/_export/code/docs/guide-user/services/webserver/nginx?codeblock=7 "Download Snippet")

```
server {
	listen 80;
	listen [::]:80;
	server_name example.com;
	include 'conf.d/example.com.locations';
	# location / { … } # root location for this server.
}
```

[🡓OpenWrt’s Defaults](#openwrt_s_defaults "docs:guide-user:services:webserver:nginx ↵") include the UCI server `config server '_redirect2ssl'`. It acts as *default\_server* for HTTP and redirects requests for inexistent URLs to HTTPS. For making another domain name accessible to all addresses, the corresponding server part should listen on port *80* and contain the FQDN as *server\_name*, cf. the official documentation on [request\_processing](https://nginx.org/en/docs/http/request_processing.html "https://nginx.org/en/docs/http/request_processing.html").

Furthermore, there is a UCI server named `_lan`. It is the *default\_server* for HTTPS and allows connections from LAN only. It includes the file `/etc/nginx/restrict_locally` with appropriate *allow/deny* directives, cf. the official documentation on [limiting access](https://nginx.org/en/docs/http/ngx_http_access_module.html "https://nginx.org/en/docs/http/ngx_http_access_module.html").

### SSL Server Parts

For enabling HTTPS for a domain we need a SSL certificate as well as its key and add them by the directives *ssl\_certificate* respective *ssl\_certificate\_key* to the server part of the domain ([TLS SNI](https://nginx.org/en/docs/http/configuring_https_servers.html#sni "https://nginx.org/en/docs/http/configuring_https_servers.html#sni") is supported by default). The rest of the configuration is similar as for general [🡑New Server Parts](#new_server_parts "docs:guide-user:services:webserver:nginx ↵"). We only have to adjust the listen directives by adding the *ssl* parameter and changing the port from *80* to *443*.

The official documentation of the SSL module contains an [example](https://nginx.org/en/docs/http/ngx_http_ssl_module.html#example "https://nginx.org/en/docs/http/ngx_http_ssl_module.html#example") with some optimizations. We can extend an existing UCI server section similarly, e.g., for the above `config server 'example_com'` we invoke:

```
# Instead of 'del_list' the listen* entries, we could use '443 ssl' beforehand.
uci del_list nginx.example_com.listen='80' &&
uci del_list nginx.example_com.listen='[::]:80' &&
uci add_list nginx.example_com.listen='443 ssl' &&
uci add_list nginx.example_com.listen='[::]:443 ssl' &&
uci set nginx.example_com.ssl_certificate='/etc/nginx/conf.d/example.com.crt' &&
uci set nginx.example_com.ssl_certificate_key='/etc/nginx/conf.d/example.com.key' &&
uci set nginx.example_com.ssl_session_cache='shared:SSL:32k' &&
uci set nginx.example_com.ssl_session_timeout='64m' &&
uci commit nginx
```

For making the server in `/etc/nginx/conf.d/example.com.conf` available via SSL, we can make similar changes there.

The following command creates a **self-signed** SSL certificate and changes the corresponding configuration:

```
nginx-util add_ssl example.com
```

1. If a `conf.d/example.com.conf` file exists, it adds *ssl\_\** directives and changes the *listen* directives there. Else it does that similarly to the example above for a [selected UCI server.](#folded_6d82c449bef8284042dc7a474ea867cf_3) Hereby it searches the UCI config first for a server with the given name and then for a server whose *server\_name* contains the name. For *example.com* it is the latter as a UCI key cannot have dots.
2. It checks if there is a certificate with key for 'example.com' that is valid for at least 13 months or tries to create a self-signed one.
3. When cron is activated, it installs a cron job for renewing the self-signed certificate every year if needed, too. We can activate cron by:
   
   ```
   service cron enable && service cron start
   ```

This can be undone by invoking:

```
nginx-util del_ssl example.com
```

For using an SSL certificate and key that are managed otherwise, there is:

```
nginx-util add_ssl example.com "$MANAGER" "/absolute/path/to/crt" "/absolute/path/to/key"
```

It only adds *ssl\_\** directives and changes the *listen* directives in the appropriate configuration, but does not create or change the certificate or its key. This can be reverted by:

```
nginx-util del_ssl example.com "$MANAGER"
```

For example [uacme](https://github.com/ndilieto/uacme "https://github.com/ndilieto/uacme") or [acme.sh](https://github.com/Neilpang/acme.sh "https://github.com/Neilpang/acme.sh") can be used for creating an SSL certificate signed by Let’s Encrypt and changing the config [accordingly.](#folded_6d82c449bef8284042dc7a474ea867cf_4) They call `nginx-util add_ssl $FQDN acme $CRT $KEY` internally. We can install them by:

```
opkg update && opkg install uacme #or: acme #and for LuCI: luci-app-acme
```

See [TLS/SSL certificates for a server](/docs/guide-user/services/tls/certs "docs:guide-user:services:tls:certs")

[🡓OpenWrt’s Defaults](#openwrt_s_defaults "docs:guide-user:services:webserver:nginx ↵") include a UCI server for the LAN: `config server '_lan'`. It has *ssl\_\** directives prepared for a self-signed[4)](#fn__4) SSL certificate, which is created on the first start of Nginx. The server listens on all addresses, is the *default\_server* for HTTPS and allows connections from LAN only (by including the file `restrict_locally` with *allow/deny* directives, cf. the official documentation on [limiting access](https://nginx.org/en/docs/http/ngx_http_access_module.html "https://nginx.org/en/docs/http/ngx_http_access_module.html")).

For making another domain name accessible to all addresses, the corresponding SSL server part should listen on port *443* and contain the FQDN as *server\_name*, cf. the official documentation on [request\_processing](https://nginx.org/en/docs/http/request_processing.html "https://nginx.org/en/docs/http/request_processing.html").

Furthermore, there is also a UCI server named `_redirect2ssl`, which listens on all addresses, acts as *default\_server* for HTTP and redirects requests for inexistent URLs to HTTPS.

### OpenWrt’s Defaults

Since Nginx is compiled with these presets, we can pretend that the main configuration will always contain the following directives (though we can overwrite them):

```
pid "/var/run/nginx.pid";
lock_file "/var/lock/nginx.lock";
error_log "stderr";
proxy_temp_path "/var/lib/nginx/proxy";
client_body_temp_path "/var/lib/nginx/body";
fastcgi_temp_path "/var/lib/nginx/fastcgi";
```

When starting or reloading the Nginx service, the `/etc/init.d/nginx` script sets also the following directives (so we cannot change them in the used configuration file):

```
daemon off; # procd expects services to run in the foreground
```

Then, the init sript creates the main configuration `uci.conf` dynamically from the template:

[/etc/nginx/uci.conf.template](/_export/code/docs/guide-user/services/webserver/nginx?codeblock=17 "Download Snippet")

```
# Consider using UCI or creating files in /etc/nginx/conf.d/ for configuration.
# Parsing UCI configuration is skipped if uci set nginx.global.uci_enable=false
# For details see: https://openwrt.org/docs/guide-user/services/webserver/nginx
 
worker_processes auto;
 
user root;
 
events {}
 
http {
	access_log off;
	log_format openwrt
		'$request_method $scheme://$host$request_uri => $status'
		' (${body_bytes_sent}B in ${request_time}s) <- $http_referer';
 
	include mime.types;
	default_type application/octet-stream;
	sendfile on;
 
	client_max_body_size 128M;
	large_client_header_buffers 2 1k;
 
	gzip on;
	gzip_vary on;
	gzip_proxied any;
 
	root /www;
 
	#UCI_HTTP_CONFIG
	include conf.d/*.conf;
}
```

So, the access log is turned off by default and we can look at the error log by `logread`, as init.d script forwards stderr and stdout to the [🡒runtime log](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials"). We can set the *error\_log* and *access\_log* to files, where the log messages are forwarded to instead (after the configuration is read). And for redirecting the access log of a *server* or *location* to the logd, too, we insert the following directive in the corresponding block:

```
	access_log /proc/self/fd/1 openwrt;
```

If we setup a server through UCI, we can use the options *error\_log* and/or *access\_log* also with the special path ['logd'.](#folded_6d82c449bef8284042dc7a474ea867cf_5) When initializing the Nginx service, this special path is replaced by *stderr* respective */proc/self/fd/1* (which are forwarded to the runtime log).

For creating the configuration from the template shown above, Nginx’s init script replaces the comment `#UCI_HTTP_CONFIG` by all UCI servers. For each server section in the the UCI configuration, it basically copies all options into a Nginx *server { … }* part, in detail:

- Options starting with `uci_` are skipped. Currently there is only the `option uci_manage_ssl=…` in [usage.](#folded_6d82c449bef8284042dc7a474ea867cf_6) It is set to *'self-signed'* when invoking `nginx-util add_ssl $NAME`. Then the corresponding certificate is re-newed if it is about to expire. All those certificates are checked on the initialization of the Nginx service and if Cron is available, it is deployed for checking them annually, too.
- All other lists or options of the form `key='value'` are written one-to-one as `key value;` directives to the configuration file. Just the path *logd* has a special meaning for the logging directives (described in the previous paragraph).

The init.d script of Nginx uses the *nginx-util* for creating the configuration file [in RAM.](#folded_6d82c449bef8284042dc7a474ea867cf_7) The main configuration `/etc/nginx/uci.conf` is a symbolic link to this place (it is a dead link if the Nginx service is not running).

We could use a custom configuration created at `/etc/nginx/nginx.conf` instead of the dynamic configuration, too.[5)](#fn__5) This is not encouraged since you cannot setup servers using UCI anymore. Rather, we can put custom configuration parts to `.conf` files in the `/etc/nginx/conf.d/` directory. The main configuration pulls in all `conf.d/*.conf` files into the *http {…}* block behind the created UCI servers.

The initial UCI config is enabled and contains two server section:

[/etc/config/nginx](/_export/code/docs/guide-user/services/webserver/nginx?codeblock=20 "Download Snippet")

```
config main global
	option uci_enable 'true'
 
config server '_lan'
	list listen '443 ssl default_server'
	list listen '[::]:443 ssl default_server'
	option server_name '_lan'
	list include 'restrict_locally'
	list include 'conf.d/*.locations'
	option uci_manage_ssl 'self-signed'
	option ssl_certificate '/etc/nginx/conf.d/_lan.crt'
	option ssl_certificate_key '/etc/nginx/conf.d/_lan.key'
	option ssl_session_cache 'shared:SSL:32k'
	option ssl_session_timeout '64m'
	option access_log 'off; # logd openwrt'
 
config server '_redirect2ssl'
	list listen '80'
	list listen '[::]:80'
	option server_name '_redirect2ssl'
	option return '302 https://$host$request_uri'
```

While the LAN server is the *default\_server* for HTTPS, the server redirecting requests for an inexistent `server_name` from HTTP to HTTPS acts as *default\_server* if there is [no other](#folded_6d82c449bef8284042dc7a474ea867cf_8) ; it uses an invalid name for that, more in the official documentation on [request\_processing](https://nginx.org/en/docs/http/request_processing.html "https://nginx.org/en/docs/http/request_processing.html") .

The LAN server pulls in all `.locations` files from the directory `/etc/nginx/conf.d/`. We can install the location parts of different sites there (see [🡑Basic Configuration](#basic "docs:guide-user:services:webserver:nginx ↵")) and re-include them into other servers. This is needed especially for making them available to the WAN ([🡑New Server Parts](#new_server_parts "docs:guide-user:services:webserver:nginx ↵")). The LAN server listens for all addresses on port *443* and restricts the access to local addresses by including:

[/etc/nginx/restrict\_locally](/_export/code/docs/guide-user/services/webserver/nginx?codeblock=21 "Download Snippet")

```
	allow ::1;
	allow fc00::/7;
	allow fec0::/10;
	allow fe80::/10;
	allow 127.0.0.0/8;
	allow 10.0.0.0/8;
	allow 172.16.0.0/12;
	allow 192.168.0.0/16;
	allow 169.254.0.0/16;
	deny all;
```

When starting or reloading the Nginx service, the init.d looks which UCI servers have set `option uci_manage_ssl 'self-signed'`, e.g. the LAN server. For all those servers it checks if there is a certificate that is still valid for 13 months or (re-)creates a self-signed one. If there is any such server, it installs also a cron job that checks the corresponding certificates once a year. The option `uci_manage_ssl` is set to *'self-signed'* respectively removed from a UCI server named `example_com` by the following (see [🡑SSL Server Parts](#ssl_server_parts "docs:guide-user:services:webserver:nginx ↵"), too):

```
nginx-util add_ssl example_com # respectively: nginx-util del_ssl example_com
```

## Locations for Apps

For an overview see the official Admin Guide of Nginx on [Reverse Proxy](https://docs.nginx.com/nginx/admin-guide/web-server/reverse-proxy/ "https://docs.nginx.com/nginx/admin-guide/web-server/reverse-proxy/"). For logging look at the example in the [Basic Configuration](#basic "docs:guide-user:services:webserver:nginx ↵"), too. Remember to restart Nginx after changing its configuration by:

```
service nginx reload
```

### PHP with FastCGI

Install [PHP](https://www.php.net/manual/en/install.unix.commandline.php "https://www.php.net/manual/en/install.unix.commandline.php") using FastCGI:

```
 opkg update && opkg install php7-fastcgi
```

In the Nginx configuration we can include the file [fastcgi\_params](https://github.com/nginx/nginx/blob/master/conf/fastcgi_params "https://github.com/nginx/nginx/blob/master/conf/fastcgi_params"), which is installed by default. We create a `.location` file like the following, see [other packages using fastcgi\_pass](https://github.com/search?q=repo%3Aopenwrt%2Fpackages%20fastcgi_pass%0A%20extension%3Alocations%20extension%3Aconf&type=Code "https://github.com/search?q=repo%3Aopenwrt%2Fpackages+fastcgi_pass +extension%3Alocations+extension%3Aconf&type=Code") and Nginx's Wiki has a [PHP FastCGI Example](https://www.nginx.com/resources/wiki/start/topics/examples/phpfcgi/ "https://www.nginx.com/resources/wiki/start/topics/examples/phpfcgi/"), too:

[/etc/nginx/conf.d/php.locations](/_export/code/docs/guide-user/services/webserver/nginx?codeblock=25 "Download Snippet")

```
location ~ [^/]\.php$ {
    #error_log /dev/null;
    fastcgi_connect_timeout 300s;
    fastcgi_read_timeout 300s;
    fastcgi_send_timeout 300s;
    fastcgi_buffer_size 32k;
    fastcgi_buffers 4 32k;
    fastcgi_busy_buffers_size 32k;
    fastcgi_temp_file_write_size 32k;
    client_header_timeout 10s;
    client_body_timeout 10s;
    send_timeout 60s; # default, increase if experiencing a lot of timeouts.
    output_buffers 1 32k;
    fastcgi_index index.php;
    include fastcgi_params;
    fastcgi_param HTTP_PROXY ""; # Mitigate https://httpoxy.org/ vulnerability.
    if (-f ) {
            # Only throw it at PHP-FPM if file exists (prevents PHP exploits).
            fastcgi_pass    127.0.0.1:1026;  # or: unix:/var/run/php-fpm.sock;
    }
}
```

[/etc/php.ini](/_export/code/docs/guide-user/services/webserver/nginx?codeblock=26 "Download Snippet")

```
doc_root = "YOUR/DOCUMENT/ROOT"
cgi.force_redirect = 1
cgi.redirect_status_env = "yes";
```

### uWSGI

Install [uWSGI](https://uwsgi-docs.readthedocs.io/en/latest/ "https://uwsgi-docs.readthedocs.io/en/latest/") and needed plugins:

```
opkg update && opkg install uwsgi # and the plugin(s) used. 
```

In the Nginx configuration we can include the file [uwsgi\_params](https://github.com/nginx/nginx/blob/master/conf/uwsgi_params "https://github.com/nginx/nginx/blob/master/conf/uwsgi_params"), which is installed by default. We create a `.locations` file like the following, see also [other packages using uwsgi\_pass](https://github.com/search?q=repo%3Aopenwrt%2Fpackages%20uwsgi_pass%0A%20extension%3Alocations%20extension%3Aconf&type=Code "https://github.com/search?q=repo%3Aopenwrt%2Fpackages+uwsgi_pass +extension%3Alocations+extension%3Aconf&type=Code") and the [uWSGI documentation for Nginx](https://uwsgi-docs.readthedocs.io/en/latest/Nginx.html "https://uwsgi-docs.readthedocs.io/en/latest/Nginx.html"), too:

[/etc/nginx/conf.d/mysite.locations](/_export/code/docs/guide-user/services/webserver/nginx?codeblock=28 "Download Snippet")

```
location /mysite {
    # error_log /dev/null;
    include  /etc/nginx/uwsgi_params;
    uwsgi_pass unix:///var/run/mysite.socket;
    # for CGI (like in LuCI):
    # uwsgi_param SERVER_ADDR $server_addr;
    # uwsgi_modifier1 9;
}
```

For uWSGI, we create a configuration handling the application like the following, see [other packages using uWSGI](https://github.com/search?q=repo%3Aopenwrt%2Fpackages%20%5Buwsgi%5D%0A%20extension%3Aini&type=Code "https://github.com/search?q=repo%3Aopenwrt%2Fpackages+[uwsgi] +extension%3Aini&type=Code"), too:

[/etc/uwsgi/vassals/mysite.ini](/_export/code/docs/guide-user/services/webserver/nginx?codeblock=29 "Download Snippet")

```
[uwsgi]
strict = true

; adjust the needed plugins, path, name, user and socket for the application:
plugin = 
manage-script-name = true
chdir = /path/to/app
mount = /mysite=app
; or use cgi = /mysite=/path/or/executable
pidfile = /var/etc/mysite/master.pid
 
enable-threads = true
; threads = 3
thunder-lock = true
; post-buffering = 8192
; harakiri = 60
; lazy-apps = true
master = true
; idle = 600
; processes = 3
; cheaper-algo = spare
; cheaper = 1
; cheaper-initial = 1
; cheaper-step = 1

; plugin = syslog
; disable-logging only affects req-logger:
disable-logging = true
log-format=%(method) %(uri) => return %(status) (%(rsize) bytes in %(msecs) ms)
; req-logger = syslog:mysite_req

; logger = mysite syslog:mysite_main

; if-env = UWSGI_EMPEROR_FD
; the regular expression leaves for successful de/activation only one line each:
; log-route = mysite ^(?!... Starting uWSGI |compiled with version: |os: Linux|nodename: |machine: |clock source: |pcre jit |detected number of CPU cores: |current working directory: |writing pidfile to |detected binary path: |chdir.. to |your processes number limit is |your memory page size is |detected max file descriptor number: |lock engine: |thunder lock: |uwsgi socket |setgid.. to |setuid.. to |Python version: |Python main interpreter initialized at |python threads support |your server socket listen backlog is limited to |your mercy for graceful operations on workers is |mapped |... Operational MODE: |... uWSGI is running in multiple interpreter mode ...|spawned uWSGI worker |mounting |WSGI app |announcing my loyalty to the Emperor...|workers have been inactive for more than |SIGINT/SIGQUIT received...killing workers...|worker |goodbye to uWSGI.)
; end-if =
 
if-not-env = UWSGI_EMPEROR_FD
; log-route = mysite .*
vacuum = true
socket = /var/run/mysite.socket
; cheap = true
end-if =
 
chmod-socket = 660
chown-socket = user:nogroup
uid = user
gid = nogroup
```

## Extras

### DNS over TLS

To hide DNS requests from your ISP, you may use your own upstream DoT server, this typically constitutes a $5/month cloud virtual machine (VM) running nginx and working DNS for it's hostname. On this VM, setup nginx with Cloudflare TLS certificates and add this to nginx's configuration below the default http context and open port 853.

```
cat << "EOF" > /etc/nginx/nginx.conf
stream {
    # DNS upstream pool
    upstream dns {
        zone dns 64k;
        server 127.0.0.1:53;
    }
 
   # DoT server for decryption
   server {
        listen 853 ssl;
        ssl_certificate /etc/letsencrypt/live/dns.example.com/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/dns.example.com/privkey.pem;
        proxy_pass dns;
    }
}
EOF
```

[1)](#fnt__1)

We can disable a single configuration file in `/etc/nginx/conf.d/` by giving it another extension, e.g., by adding `.disabled`.

[2)](#fnt__2)

look for [other packages using a .locations file](https://github.com/search?utf8=%E2%9C%93&q=repo%3Aopenwrt%2Fpackages%0A%20extension%3Alocations&type=Code&ref=advsearch&l=&l= "https://github.com/search?utf8=%E2%9C%93&q=repo%3Aopenwrt%2Fpackages +extension%3Alocations&type=Code&ref=advsearch&l=&l="), too.

[3)](#fnt__3)

We reserve the `location /` for making LuCI available under the root URL, e.g. [192.168.1.1/](https://192.168.1.1/ "https://192.168.1.1/"). All other sites shouldn’t use the root `location /` without suffix.

[4)](#fnt__4)

Let’s Encrypt (and other CAs) cannot sign certificates of a **local** server.

[5)](#fnt__5)

For using a custom configuration at `/etc/nginx/nginx.conf`, we execute

```
uci set nginx.global.uci_enable='false' 
```

Then the rest of the UCI config is ignored and *init.d* will not create the main configuration dynamically from the template anymore. Invoking `nginx-util [add_ssl|del_ssl] $FQDN` will still try to change a server in `conf.d/$FQDN.conf` (this is less reliable than for a UCI config as it uses regular expressions, not a complete parser for the Nginx configuration).
