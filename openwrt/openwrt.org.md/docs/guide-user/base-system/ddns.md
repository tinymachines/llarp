# DDNS client configuration

See also: [DDNS client documentation](/docs/guide-user/services/ddns/client "docs:guide-user:services:ddns:client")

- Due to functional extensions not all settings are supported in all OpenWrt releases.
- You find notes in description about supported release if not available in all releases.
- Keep in mind, that *ddns-scripts* are designed to support ONE host or IP protocol version per section.
- Including BB 14.07 *ddns-scripts* only support update of IPv4 addresses.
- Starting ddns-scripts 2.7.6 (trunk) option naming will change for better functional grouping.
- Updating ddns-scripts to newer versions will do the renaming inside existing config files during update automatically.
- Additionally some options will be also [available globally](/docs/guide-user/base-system/ddns#section_ddns "docs:guide-user:base-system:ddns") so they need not be defined for every service section.
- Options defined inside service section overwrite global section settings.

The file `/etc/config/ddns` holds the configuration for *ddns-scripts* package.

## Example

You find the newest version of full documented [ddns.sample\_config](https://github.com/openwrt/packages/tree/master/net/ddns-scripts/samples/ "https://github.com/openwrt/packages/tree/master/net/ddns-scripts/samples/") at GitHub.  
Using all defaults the minimum settings are:

### for IPv4 address

```
config service "myddns_ipv4"
	option service_name	"example.org"
	option domain		"yourhost.example.org"
	option username		"your_username"
	option password		"your_password"
	option interface	"wan"
	option ip_source	"network"
	option ip_network	"wan"
```

### for IPv6 address

![:!:](/lib/images/smileys/exclaim.svg) **Supported since CC 15.05**

```
config service "myddns_ipv6"
	option use_ipv6		"1"
	option service_name	"example.org"
	option domain		"yourhost.example.org"
	option username		"your_username"
	option password		"your_password"
	option interface	"wan6"
	option ip_source	"network"
	option ip_network	"wan6"
```

## Sections

### Section "service"

![:!:](/lib/images/smileys/exclaim.svg) **You need to define a “service” section for every DDNS provider and Host you want to feed.**  
**![:!:](/lib/images/smileys/exclaim.svg) Same if you want to feed IPv4- and IPv6-address to your DDNS provider.** (Since CC 15.05)

Name  
(old) Name  
(new) Type Required Default Description `enabled` boolean yes '0' disable(0) / enable(1) this service section. `interface` network name yes *(none)* The DDNS scripts use the Linux hotplug events system. When this specified network interface comes up, a related ifup hotplug event will cause DDNS script to start to monitor (and update) the external IP address of . Select the WAN interface that will have the external IP address to use in the DDNS registration. `use_ipv6` boolean no '0' **Including BB 14.07** no support of IPv6 protocol.  
**Since CC 15.05** decide if you want to update/send your current IPv4(0) or IPv6(1) address. `service_name` string yes(\*) *(none)* Which DDNS online service do you use?  
Choose one from `/usr/lib/ddns/services` file.  
**Since CC 15.05** if `option use_ipv6` is enabled(1) choose a service from `/usr/lib/ddns/services_ipv6` file.  
The latest versions can be downloaded from [Github.com](https://github.com/openwrt/packages/tree/master/net/ddns-scripts/files "https://github.com/openwrt/packages/tree/master/net/ddns-scripts/files")  
***(\*) If your DDNS provider is not listed there, remove this option and use `'option update_url`' or since CC 15.05 `'option update_script`' instead.*** `update_url` string yes(\*) *(none)* Have a look at DDNS providers configuration help. Use the their URL here.  
***(\*) Remove this option, if `'option service_name`' is set.*** `update_script` string no *(none)* **Since CC 15.05** `/path/to/update_script.sh`  
If your DDNS provider doesn't work with ddns-scripts, because there are additional parameters or other special thinks to be done, then you could write your own script to send updates to your DDNS provider.  
Have a look into [update\_sample.sh](https://github.com/openwrt/packages/tree/master/net/ddns-scripts/samples "https://github.com/openwrt/packages/tree/master/net/ddns-scripts/samples")  
![:!:](/lib/images/smileys/exclaim.svg) Remove `'option service_name`' and use either this option **OR** `'option update_url`'. `domain` string yes *(none)* The DNS name / Hostname to update  
*(this name must already be registered with the DDNS provider)*  
![:!:](/lib/images/smileys/exclaim.svg) **If your DDNS provider don't need this information being send for update, put it in anyway. `ddns-scripts` use it to compare local IP with registered IP.**  
![:!:](/lib/images/smileys/exclaim.svg) **Since DD** `ddns-scripts` use `'option lookup_host`' (see below) to detect your registered IP.  
So this option can be used for special multihost update configurations supported by some providers. `username` string yes(\*) *(none)* Username of your DDNS providers account  
Have a look at DDNS providers help, because some providers are using different information as “username” for DDNS updates (i.e. hostname).  
Look at [DDNS client](/docs/guide-user/services/ddns/client "docs:guide-user:services:ddns:client") for additional information.  
***(\*)If your DDNS provider don't need this information being send for update, put in an “X” instead.*** `password` string yes(\*) *(none)* Password of your DDNS providers account  
Have a look at DDNS providers help, because some providers are using different information as “password” for DDNS updates (i.e. tokenid). e.g. for afraid.org, put your 25 character random TOKEN here in the password field.  
Look at [DDNS client](/docs/guide-user/services/ddns/client "docs:guide-user:services:ddns:client") for additional information.  
***(\*)If your DDNS provider don't need this information being send for update, put in an “X” instead.*** `use_https` boolean no '0' disable(0) / enable(1) the use of HTTPS for secure communication with your DDNS provider.  
*Some providers having problems, when not sending updates via HTTPS.*  
**You must NOT specify 'http“s”:', simply use 'http:' in `update_url` above, if used.**  
![:!:](/lib/images/smileys/exclaim.svg) Needs “Wget” or “cURL” package being installed.  
Look at [DDNS client](/docs/guide-user/services/ddns/client "docs:guide-user:services:ddns:client") for additional information. `cacert` string no(\*) *(none)* `/path/to/certificates` directory or `/path/to/certificate.crt` file.  
Package “ca-certificates” installs certificates to `/etc/ssl/certs` directory.  
Look at [DDNS client](/docs/guide-user/services/ddns/client "docs:guide-user:services:ddns:client") for additional information.  
***(\*)required, if `option use_https` set to '1'** (enabled)*  
**since CC 15.05** a value **'IGNORE'** is supported.  
![:!:](/lib/images/smileys/exclaim.svg) This uses secure http for transfer, but do not verify the DDNS providers server certificate. **(insecure)** `ip_source` string yes 'network' Defines the source to determine you local IP send to the DDNS provider.  
Valid values are:  
\- 'network' uses/needs `'option ip_network`'  
\- 'web' uses/needs `'option ip_url`'  
\- 'interface' uses/needs `'option ip_interface`'  
\- 'script' uses/needs `'option ip_script`'  
See details below. `ip_network` string no(\*) 'wan' Specify a network from your `/etc/config/network` file (e.g. “wan”) with the “ip\_network” option. If you specify “wan”, you will send update with whatever the IP for your wan is.  
***(\*)required, if `option ip_source` set to 'network'*** `ip_url` string no(\*) *(none)* Detects the current local IP from specified webside that response with the IP address of calling host. If you are behind a firewall/NAT this is the best option since none of the local networks or interfaces will have the external IP.  
The correct URL might depend on the DDNS provider being used. Check with the DDNS providers's documentation to determine, if they offer this feature and, if so, what the correct URL is.  
Sample: [http://checkip.dyndns.org/](http://checkip.dyndns.org/ "http://checkip.dyndns.org/") or [http://checkipv6.dyndns.org/](http://checkipv6.dyndns.org/ "http://checkipv6.dyndns.org/")  
***(\*)required, if value of `option ip_source` set to 'web'*** `ip_interface` string no(\*) *(none)* Specify a locally installed physical (hardware) interfaces (e.g. 'eth1') to detect your current IP address, independent from network they configured to.  
***(\*)required, if value of `option ip_source` set to 'interface'*** `ip_script` string no(\*) *(none)* Useful, if you want to write your own script to detect your current local IP.  
Put in full path '/path/to/script.sh'.  
Have a look into [getlocalip\_sample.sh](https://github.com/openwrt/packages/tree/master/net/ddns-scripts/samples "https://github.com/openwrt/packages/tree/master/net/ddns-scripts/samples") and [Get IP from modem scripts collection](/docs/guide-user/network/wan/ddns.ipscript "docs:guide-user:network:wan:ddns.ipscript")  
![:!:](/lib/images/smileys/exclaim.svg) The script must be marked executable.  
***(\*)required, if value of `option ip_source` set to 'script'*** `check_interval` number no '10' Defines the time interval to check if local IP has changed.  
Accepted unit values: 'seconds' 'minutes' 'hours'.  
![:!:](/lib/images/smileys/exclaim.svg) *Checks below 5 minutes make no sense, because the DNS Servers in Internet needs about 5 minutes to sync.*  
*![:!:](/lib/images/smileys/exclaim.svg) either **both** options are set or not set.* `check_unit` string no 'minutes' `force_interval` number no '72' Force to send an update to service provider, if no IP change was detected. Consult DDNS providers documentation, if your DDNS entry might timeout.  
Accepted unit values: 'minutes' 'hours' 'days'  
![:!:](/lib/images/smileys/exclaim.svg) *Minimum needs to be greater or equal check interval (see above).*  
*![:!:](/lib/images/smileys/exclaim.svg) either **both** options are set or not set.*  
**since CC 15.05** a value **'0'** is supported. This will stop script execution after one successful update. `force_unit` string no 'hours' `retry_interval` number no '60' If error happen on detecting, sending or updating, the script will retry the relevant action.  
Here you define the time to wait before retry is started.  
Accepted unit values: 'seconds' 'minutes'  
![:!:](/lib/images/smileys/exclaim.svg) *either **both** options are set or not set.* `retry_unit` string no 'seconds' `retry_max_count` number no '0' **Since CC 15.05** (23→master, `retry_count` renamed to `retry_max_count`) Number of retries before the script terminates execution, when communication errors happen.  
![:!:](/lib/images/smileys/exclaim.svg) A setting of '0' will retry indefinitely. `use_syslog` boolean no '0' **Since BB 14.07** disable(0) / enable(1) logging events to syslog.  
**Since CC 15.05** Level of events logged to syslog:  
0 == disable  
1 == info, notice, warning, errors  
2 == notice, warning, errors  
3 == warning, errors  
4 == errors  
![:!:](/lib/images/smileys/exclaim.svg) Critical errors forcing ddns-scripts to stop are always logged to syslog. `use_logfile` boolean no '1' **Since CC 15.05** disable(0) / enable(1) logging to log file.  
You find the file per default in /var/log/ddns/\[sectionname].log  
The path can be modified for **all** log files in section `'ddns`' (see below) `dns_server` string no *(none)* **Since CC 15.05** Normally the current (in the internet) registered ip is detected using the local defined name lookup policies (i.e. /etc/resolve.conf etc.)  
Specify here a DNS server to be used instead of the defaults.  
You can use FQDN, hostname or IP address. `force_dnstcp` boolean no '0' **Since CC 15.05** disable(0) / enable(1) DNS requests via TCP protocol.  
By default every DNS call is made via UDP protocol. Some internet provider offer modems, caching UDP DNS requests. They redirect every request to external servers to local modem cache.  
To force the usage of TCP for DNS requests enable this option.  
![:!:](/lib/images/smileys/exclaim.svg) Needs BIND host package to be installed. `proxy` string no *(none)* **Since CC 15.05** If a Proxy is need to access HTTP/HTTPS pages on the WEB, it can be configured here also for sending updates to the DDNS provider.  
If you configured `option use_https '1`' above, you need to setup your HTTPS proxy here, otherwise your HTTP proxy.  
![:!:](/lib/images/smileys/exclaim.svg) You should not detect your current IP (`option ip_source 'web`' above) because this request is also send via the configured proxy.  
Syntax: \[user:password@]proxy:port ![:!:](/lib/images/smileys/exclaim.svg) port is required !  
IPv6 address must be in squared brackets '\[...]' `force_ipversion` boolean no '0' **Since CC 15.05** disable(0) / enable(1) this option.  
Normally the system decide by various settings mostly compiled into the software, if it prefers IPv4 or IPv6 communication. Some DDNS providers update their DDNS record by using the IP address you send the update from.  
Then you need to force the usage of the IP version you want to update or you want to force it for other reasons depending on your environment.  
![:!:](/lib/images/smileys/exclaim.svg) Needs Wget or cURL package and BIND host package to be installed ! `bind_network` string no *(none)* **Since CC 15.05** Network to use for communication when detecting IP and sending updates.  
![:!:](/lib/images/smileys/exclaim.svg) Needs Wget or cURL package to be installed !  
Wget will bind to the IP and cURL to physical interface of given network. `lookup_host` string yes *(none)* **Since DD** Option domain (see above) is no longer used to get the registered ip. Configure here the host you like to get registered ip for. This is useful if updating multiple hosts in one configuration section. `rec_id` string no *(none)* **Since DD** If this is set and the service is CloudFlare, updates the specified record (useful when there are multiple records for the same domain). Determined automatically when not set (but in case of multiple records for the same domain one will be arbitrarily chosen). `is_glue` boolean no '0' **Since DD** This option is mandatory if the ddns record is a glue record and the registered ip should be compared against the glue record. This option requires bind host and does only work if the dns\_server option is used. The dns\_server value has to be the dns server where the glue record is defined.

### Section "ddns"

**Supported since CC 15.05**  
![:!:](/lib/images/smileys/exclaim.svg) **It is NOT recommended for casual users to change this settings.**  
![:!:](/lib/images/smileys/exclaim.svg) Only section name “global” is supported  
![:!:](/lib/images/smileys/exclaim.svg) This settings are used by `ddns-scripts` and corresponding `luci-app-ddns`.

Name  
(old) Name  
(new) Values Required Default Description `allow_local_ip` `upd_privateip` boolean no '0' disallow(0) / allow(1) to send Private/Special IP's to the DDNS provider  
blocked IPv4: 0/8, 10/8, 100.64/10, 127/8, 169.254/16, 172.16/12, 192.168/16  
blocked IPv6: ::/32, f000::/4 `date_format` `ddns_dateformat` string no '%F %R' set date format to use for display date in logfiles and LuCI WebUI.  
For supported codes [look here](http://www.cplusplus.com/reference/ctime/strftime/ "http://www.cplusplus.com/reference/ctime/strftime/"). `run_dir` `ddns_rundir` string no '/var/run/ddns' Set directory to use for `'*.pid`' and `'*.update`' files.  
There are separate files for every running service section. `log_dir` `ddns_logdir` string no '/var/log/ddns' Set directory to use for `'*.log`' files.  
There are separate files for every running service section, if `option use_logfile` set to **'1'** (enable) (see above). `log_lines` `ddns_loglines` number no '250' Set number of lines stored in .log file before auto truncated. `use_curl` boolean no '0' If Wget and cURL package are installed, Wget is used for communication by default.  
Set to '1' will use cURL instead.

### Issues and known bugs

![:!:](/lib/images/smileys/exclaim.svg) Wget 1.x does not work correctly when using multiple WAN interfaces (like with with mwan). [Issue 8277](https://github.com/openwrt/packages/issues/8277 "https://github.com/openwrt/packages/issues/8277")

**Reason:** wget 1.x does not bind to an interface it can only change the IP address (bind-address)

**Fix:** use curl via use\_curl

(Untested) wget2 (not released as of March 2021) has bind-interface support

* * *

![:!:](/lib/images/smileys/exclaim.svg) Since somewhere June 2021 [OpenDNS](https://opendns.com "https://opendns.com") gives an error “***badauth***” when using *Wget 1.x* or *uclient-fetch* (the default for OpenWRT 21.02.0).

**Reason:** in order to work properly with [OpenDNS](https://opendns.com "https://opendns.com"), Wget 1.x requires the ***--auth-no-challenge*** option in its command line.

**Fix:** Install and use curl via ***use\_curl = 1*** option in the *Global* section
