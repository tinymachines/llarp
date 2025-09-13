# Privoxy

[Privoxy](https://en.wikipedia.org/wiki/Privoxy "https://en.wikipedia.org/wiki/Privoxy") is a non-caching web proxy with advanced filtering capabilities for enhancing privacy, modifying web page data and HTTP headers, controlling access, and removing ads and other obnoxious Internet junk. Privoxy has a flexible configuration and can be customized to suit individual needs and tastes. It has application for both stand-alone systems and multi-user networks.

- [http://www.privoxy.org/](http://www.privoxy.org/ "http://www.privoxy.org/")

## Installation

Use [*opkg*](/docs/guide-user/additional-software/opkg "docs:guide-user:additional-software:opkg") to install the *privoxy* package.

```
opkg update
opkg install privoxy
vi /etc/config/privoxy
/etc/init.d/privoxy enable
/etc/init.d/privoxy start
```

![:!:](/lib/images/smileys/exclaim.svg) Since OpenWrt Chaos Calmer (trunk) there is also available a corresponding LuCI application to support setting of Privoxy configuration via Web-GUI.  
![:!:](/lib/images/smileys/exclaim.svg) Require Privoxy v3.0.22 package

## Configuration

Change the listen-address in `/etc/config/privoxy` to your router ip address such as `listen-address 192.168.1.1:8118`. You need change default setting `permit-access 192.168.1.0/24` to something else if you use a different subnet.

Last you need start up the proxy server with command `/etc/init.d/privoxy start`.  
To have it start on boot, enable the init script with `/etc/init.d/privoxy enable`.

You'll need to add the proxy information to your internet browser to use it.

![:!:](/lib/images/smileys/exclaim.svg) Since OpenWrt Chaos Calmer (trunk) / **Privoxy v3.0.22** the `/etc/privoxy/config` file is no longer used ![:!:](/lib/images/smileys/exclaim.svg)  
The configuration was moved to the UCI configuration `/etc/config/privoxy`.  
All Privoxy configuration variables are still supported.

Due to UCI does not support variables names with “-” this needs to be replaced by “\_”  
**Sample:** privoxy “listen-address” must be UCI “listen\_address”

If you add entries please use:  
\* **option** for options with one parameter (option confdir)  
\* **list** for options with multiple parameters (list listen\_address)  
\* special handling for debug option: privoxy option “debug 1024” must be UCI “option debug\_1024 '1' “  
Please see sample below

## Example

Below is an example of the `/etc/privoxy/config` file (deprecated--see below for current version)

```
confdir                      /etc/privoxy
logdir                       /var/log
filterfile                   default.filter
logfile                      privoxy
actionsfile                  match-all.action  # Actions that are applied to all sites and maybe overruled later on.
actionsfile                  default.action    # Main actions file
listen-address               192.168.1.1:8118
toggle                       0
enable-remote-toggle         1
enable-remote-http-toggle    0
enable-edit-actions          1
enforce-blocks               0
buffer-limit                 4096
forwarded-connect-retries    0
accept-intercepted-requests  0
allow-cgi-request-crunching  0
split-large-forms            0
keep-alive-timeout           300
socket-timeout               300
permit-access                192.168.1.0/24
debug                        1     # show each GET/POST/CONNECT request
#debug                       4096  # or Startup banner and warnings
#debug                       8192  # or Errors - *we highly recommended enabling this*
#admin-address               privoxy-admin@example.com
#proxy-info-url              http://www.example.com/proxy-service.html
```

Below is an example of the current `/etc/config/privoxy` file used **since Privoxy v3.0.22**

```
config	privoxy	'privoxy'
	option	confdir		'/etc/privoxy'
	option	logdir		'/var/log'
	option	logfile		'privoxy.log'
	list	filterfile	'default.filter'
#	list	filterfile	'user.filter'
	list	actionsfile	'match-all.action'
	list	actionsfile	'default.action'
#	list	actionsfile	'user.action'
#	list	listen_address	'127.0.0.1:8118'
	list	listen_address	'192.168.1.1:8118'
	option	toggle		'0'
	option	enable_remote_toggle	'1'
	option	enable_remote_http_toggle	'0'
	option	enable_edit_actions	'1'
	option	enforce_blocks		'0'
	option	buffer_limit		'4096'
	option	forwarded_connect_retries	'0'
	option	accept_intercepted_requests	'0'
	option	allow_cgi_request_crunching	'0'
	option	split_large_forms	'0'
	option	keep_alive_timeout	'300'
	option	socket_timeout		'300'
	list	permit_access		'192.168.1.0/24'
	option	debug_1		'0'
	option	debug_512	'1'
	option	debug_1024	'0'
	option	debug_4096	'1'
	option	debug_8192	'1'
```
