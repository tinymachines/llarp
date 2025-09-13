# CrowdSec

This wiki page is currently a work in progress and information is currently in the process of being transferred from the community forum.

Main Website: [https://crowdsec.net/](https://crowdsec.net/ "https://crowdsec.net/")  
Documentation : [https://doc.crowdsec.net/](https://doc.crowdsec.net/ "https://doc.crowdsec.net/")  
Release info: [https://github.com/crowdsecurity/crowdsec/releases](https://github.com/crowdsecurity/crowdsec/releases "https://github.com/crowdsecurity/crowdsec/releases")  
OpenWrt Forum thread: [https://forum.openwrt.org/t/crowdsec-packages-for-openwrt/102648](https://forum.openwrt.org/t/crowdsec-packages-for-openwrt/102648 "https://forum.openwrt.org/t/crowdsec-packages-for-openwrt/102648")  
CrowdSec Forum thread: [https://discourse.crowdsec.net/t/crowdsec-package-for-openwrt/225](https://discourse.crowdsec.net/t/crowdsec-package-for-openwrt/225 "https://discourse.crowdsec.net/t/crowdsec-package-for-openwrt/225")  
CrowdSec Web-console: [https://app.crowdsec.net/product-tour](https://app.crowdsec.net/product-tour "https://app.crowdsec.net/product-tour") CrowdSec has already made some tutorials on their blog: [https://crowdsec.net/blog/](https://crowdsec.net/blog/ "https://crowdsec.net/blog/")

Crowdsec is an open-source and lightweight software that allows you to detect peers with malevolent behaviors and block them from accessing your systems at various level (infrastructural, system, application).

To achieve this, CrowdSec reads logs from different sources (files, streams ...) to parse, normalize and enrich them before matching them to threats patterns called scenarios.

- Package [crowdsec](/packages/pkgdata/crowdsec "packages:pkgdata:crowdsec") Main program bundle.
- Package [crowdsec-firewall-bouncer](/packages/pkgdata/crowdsec-firewall-bouncer "packages:pkgdata:crowdsec-firewall-bouncer") - will fetch new and old decisions from a CrowdSec API to add them in a blacklist used by supported firewalls.

## Installation

![:!:](/lib/images/smileys/exclaim.svg) For installing the crowdsec-firewall-bouncer, installation of the crowdsec main package is not required. The bouncer just needs a 'local Crowdsec API' to connect to.

The CrowdSec main package requires ~60MB of space, thus you may want to run your CrowdSec installation on a dedicated device in your network (maybe a Raspberry Pi) and only install the firewall bouncer on the OpenWrt device.

### Crowdsec main package

```
opkg install crowdsec
```

As OpenWrt does not have systemctl but initd you must use

```
/etc/init.d/crowdsec reload
```

or

```
service crowdsec reload
```

to reload crowdsec.

Follow crowdsec [documentation](https://doc.crowdsec.net/docs/getting_started/crowdsec_tour "https://doc.crowdsec.net/docs/getting_started/crowdsec_tour") now it is installed.

![:!:](/lib/images/smileys/exclaim.svg) Keep in mind that the crowdsec package is only in charge of the “detection”, and won't block anything on its own. You need to deploy a bouncer to “apply” decisions.

#### Check status

You can read the main log at /var/log/crowdsec.log

### Crowdsec firewall bouncer

You can install a [bouncer](https://doc.crowdsec.net/docs/bouncers/intro "https://doc.crowdsec.net/docs/bouncers/intro") like this :

```
opkg install crowdsec-firewall-bouncer
```

![:!:](/lib/images/smileys/exclaim.svg) After installation and before you can use the CrowdSec firewall bouncer you need to configure it first.

You can list available bouncers with:

```
cscli bouncers list
```

if the list is empty, you need to add the new bouncer (change the bouncer name to a more appropriate):

```
cscli bouncers add TestBouncer
```

Sample output:

```
API key for 'TestBouncer':

   HNoB4ifqBMa0Ytryy5EtyjEj6Q+/Aw09KRaJMew5iiU

Please keep this key since you will not be able to retrieve it!
```

Use the above API key in /etc/config/crowdsec.

As OpenWrt does not have systemctl but initd you must use

```
/etc/init.d/crowdsec-firewall-bouncer reload
```

or

```
service crowdsec-firewall-bouncer reload
```

to reload the bouncer (e.g. after config change).

#### Configuration

The configuration of the crowdsec-firewall-bouncer is a uci configuration file and found in /etc/config/crowdsec.

```
config bouncer
	option enabled '0'
	option ipv4 '1'
	option ipv6 '1'
	option api_url 'http://localhost:8080/'
	option api_key ''
	option deny_action 'drop'
	option deny_log '0'
	option log_prefix 'crowdsec: '
	option log_level 'info'
	option filter_input '1'
	option filter_forward '1'
	list interface 'eth1'
```

Name Type Default Option Description `enabled` boolean `0` required ![:!:](/lib/images/smileys/exclaim.svg) Enable the crowdsec firewall bouncer. After first installation this value is 0 as api\_url and api\_key are required for the bouncer to function. `ipv4` boolean `1` optional Enable filtering on Ipv4 addresses. `ipv6` boolean `1` optional Enable filtering on Ipv6 addresses. `api_url` url `http://localhost:8080/` required The url of the Crowdsec local API for the bouncer to connect to. `api_key` string required The api key for the bouncer as generated when the bouncer is registered to the Crowdsec local API. `deny_action` string `drop` optional The nftables deny action for blocked ips. Can be drop or reject. `deny_log` boolean `0` optional Enables logging of blocked ips to system log. `log_prefix` string `crowdsec:` optional The prefix for the log messages of blocked ips in system log. `log_level` string `info` optional The log level for the bouncer's log (/var/log/crowdsec-firewall-bouncer.log) `filter_input` boolean `1` optional Enables the filtering of the input chain. Useful in case of services running on the OpenWrt device itself. `filter_forward` boolean `1` optional Enables the filtering of the forward chain. Useful in case of services running on devices in your network. `interface` string `eth1` required The interface name of the wan interface. This is a list option and can be used multiple times to apply blocking on other interfaces like additional wan or vpn interfaces.

#### Check status

You can read the firewall bouncer log at /var/log/crowdsec-firewall-bouncer.log

You can test the crowdsec-firewall-bouncer configuration status with the following command:

```
cs-firewall-bouncer -t -c /tmp/etc/crowdsec/bouncers/crowdsec-firewall-bouncer.yaml
```

then you'll must see a line like this one in the log:

```
cat /var/log/crowdsec-firewall-bouncer.log
```

```
time="15-01-2022 08:20:30" level=info msg="config is valid"
```

To check the bouncers status, use the main crowdsec client tool, cscli. If you haven't installed Crowdsec main package on your OpenWrt device you can do so on any other device (preferrably the local API) you have Crowdsec cscli installed.

cscli default output:

```
cscli is the main command to interact with your crowdsec service, scenarios & db.
It is meant to allow you to manage bans, parsers/scenarios/etc, api and generally manage you crowdsec setup.

Usage:
  cscli [command]

Available Commands:
  alerts        Manage alerts
  bouncers      Manage bouncers [requires local API]
  capi          Manage interaction with Central API (CAPI)
  collections   Manage collections from hub
  completion    Generate completion script
  config        Allows to view current config
  console       Manage interaction with Crowdsec console (https://app.crowdsec.net)
  dashboard     Manage your metabase dashboard container [requires local API]
  decisions     Manage decisions
  explain       Explain log pipeline
  help          Help about any command
  hub           Manage Hub
  hubtest       Run functional tests on hub configurations
  lapi          Manage interaction with Local API (LAPI)
  machines      Manage local API machines [requires local API]
  metrics       Display crowdsec prometheus metrics.
  parsers       Install/Remove/Upgrade/Inspect parser(s) from hub
  postoverflows Install/Remove/Upgrade/Inspect postoverflow(s) from hub
  scenarios     Install/Remove/Upgrade/Inspect scenario(s) from hub
  simulation    Manage simulation status of scenarios
  version       Display version and exit.

Flags:
  -c, --config string   path to crowdsec config file (default "/etc/crowdsec/config.yaml")
  -o, --output string   Output format : human, json, raw.
      --debug           Set logging to debug.
      --info            Set logging to info.
      --warning         Set logging to warning.
      --error           Set logging to error.
      --trace           Set logging to trace.
  -h, --help            help for cscli

Use "cscli [command] --help" for more information about a command.
```

```
cscli bouncers list
```

a sample working output will be:

```
---------------------------------------------------------------------------------------------------------------------------------------
 NAME                                IP ADDRESS  VALID  LAST API PULL              TYPE                       VERSION                  
---------------------------------------------------------------------------------------------------------------------------------------
 crowdsec-firewall-bouncer-LK1HD1Vx  127.0.0.1   ✔️      2022-01-15T08:28:02+01:00  crowdsec-firewall-bouncer  v0.0.21-openwrt-0.0.21-1 
---------------------------------------------------------------------------------------------------------------------------------------
```

You can view your global status health:

```
cscli metrics
```

Sample output:

```
INFO[17-10-2021 10:36:19 AM] Local Api Metrics:                           
+----------------------+--------+--------+
|        ROUTE         | METHOD |  HITS  |
+----------------------+--------+--------+
| /v1/alerts           | GET    |      3 |
| /v1/decisions/stream | GET    | 108456 |
| /v1/watchers/login   | POST   |      6 |
+----------------------+--------+--------+
INFO[17-10-2021 10:36:19 AM] Local Api Machines Metrics:                  
+--------------------------------------------------+------------+--------+------+
|                     MACHINE                      |   ROUTE    | METHOD | HITS |
+--------------------------------------------------+------------+--------+------+
| db3e872e345f48848d0d85ab5c529947GWkbyXJtyNnJziiS | /v1/alerts | GET    |    3 |
+--------------------------------------------------+------------+--------+------+
INFO[17-10-2021 10:36:19 AM] Local Api Bouncers Metrics:                  
+------------------------------+----------------------+--------+--------+
|           BOUNCER            |        ROUTE         | METHOD |  HITS  |
+------------------------------+----------------------+--------+--------+
| cs-firewall-bouncer-LeCzIx9V | /v1/decisions/stream | GET    | 108456 |
+------------------------------+----------------------+--------+--------+
```

You can verify the process is up wit default system command like ps:

```
ps | grep crowdsec
```

```
cscli decisions list
```

sample output:

```
+-------+----------+------------------+--------------------------------------+--------+---------+------------------+--------+--------------------+----------+
|  ID   |  SOURCE  |   SCOPE:VALUE    |                REASON                | ACTION | COUNTRY |        AS        | EVENTS |     EXPIRATION     | ALERT ID |
+-------+----------+------------------+--------------------------------------+--------+---------+------------------+--------+--------------------+----------+
| 15136 | crowdsec | Ip:37.173.175.13 | crowdsecurity/http-crawl-non_statics | ban    | FR      |  Free Mobile SAS |     57 | 2h47m27.230010039s |      215 |
+-------+----------+------------------+--------------------------------------+--------+---------+------------------+--------+--------------------+----------+
```

You can manage banned ip with

```
cscli decision
```

. Check the actually banned IPs list:

```
cscli decisions list
No active decisions
```

Manually add an IP to the ban list:

```
cscli decisions add --ip 37.172.100.86 --duration 1h
INFO[26-07-2021 08:40:29 AM] Decision successfully added                  
```

Check the banned IP list:

```
cscli decisions list
+------+--------+------------------+----------------------------------------------------+--------+---------+----+--------+-----------------+----------+
|  ID  | SOURCE |   SCOPE:VALUE    |                       REASON                       | ACTION | COUNTRY | AS | EVENTS |   EXPIRATION    | ALERT ID |
+------+--------+------------------+----------------------------------------------------+--------+---------+----+--------+-----------------+----------+
| 4203 | cscli  | Ip:37.172.100.86 | manual 'ban' from                                  | ban    |         |    |      1 | 59m55.64019484s |       55 |
|      |        |                  | '50c75c1635bd4935b1be5d95ae5f860epTkK2cAbb6nzI1fJ' |        |         |    |        |                 |          |
+------+--------+------------------+----------------------------------------------------+--------+---------+----+--------+-----------------+----------+
```

## Check nftables status

If you use nftables, you can use specific commands like:

```
nft list tables
```

```
nft list table crowdsec
```

```
nft list chains
```

```
nft list ruleset
```

cscli can also be used to check these alerts with:

```
cscli alerts list
```

sample output:

```
+------+------------------------------+----------------------+---------+----+-----------+--------------------------------+
|  ID  |            VALUE             |        REASON        | COUNTRY | AS | DECISIONS |           CREATED AT           |
+------+------------------------------+----------------------+---------+----+-----------+--------------------------------+
| 1051 | crowdsec/community-blocklist | update : +728/-0 IPs |         |    | ban:728   | 2021-10-17 09:20:26 +0200      |
|      |                              |                      |         |    |           | +0200                          |
| 1050 | crowdsec/community-blocklist | update : +727/-0 IPs |         |    | ban:1     | 2021-10-17 07:20:26 +0200      |
|      |                              |                      |         |    |           | +0200                          |
```

## Notification Plugins

REFS:

\- [https://docs.crowdsec.net/docs/notification\_plugins/intro](https://docs.crowdsec.net/docs/notification_plugins/intro "https://docs.crowdsec.net/docs/notification_plugins/intro")

\- [https://doc.crowdsec.net/docs/notification\_plugins/email](https://doc.crowdsec.net/docs/notification_plugins/email "https://doc.crowdsec.net/docs/notification_plugins/email")

To enable email notifications plugins, you must uncomment the following section

```
#notifications:
# - email_default
```

in

```
/etc/crowdsec/profiles.yaml
```

and modify:

```
/etc/crowdsec/notifications/email.yaml
```

with:

```
smtp_host: smtp.admin.net # eg value smtp.gmail.com
smtp_username: login@admin.net #Replace this with your actual username
smtp_password: theSECRETpassword #Replace this with your actual password
smtp_port: 587 # Common values are any of [25, 465, 587, 2525]
auth_type: login # Valid choices are either of "none", "crammd5", "login", "plain" 
sender_email: postmaster@admin.net # eg: foo@gmail.com
email_subject: CrowdSec Notification
receiver_emails: 
 - me@admin.net
  # - email1@gmail.com
  # - email2@gmail.com
encryption_type: ssltls # eg valid choices are either "ssltls" or "none"
```

You must restart the CrowdSec service to enable the modifications with the command:

```
service crowdsec restart
```

You can list configured notification plugins with

```
cscli notifications list
```

And send a test email with

```
cscli notifications test email_default
```

## HUB

To update the hub components available use the command:

```
cscli hub update
```

To view the local used list of components use the command:

```
cscli hub list
```

sample output:

```
INFO[06-02-2022 10:16:20 PM] Loaded 41 collecs, 47 parsers, 57 scenarios, 3 post-overflow parsers 
POSTOVERFLOWS
--------------------------------------
 NAME  📦 STATUS  VERSION  LOCAL PATH 
--------------------------------------
--------------------------------------
PARSERS
----------------------------------------------------------------------------------------------------------------------------
 NAME                                    📦 STATUS   VERSION  LOCAL PATH                                                    
----------------------------------------------------------------------------------------------------------------------------
 crowdsecurity/sshd-logs                 ✔️  enabled  1.7      /etc/crowdsec/parsers/s01-parse/sshd-logs.yaml                
 crowdsecurity/iptables-logs             ✔️  enabled  0.2      /etc/crowdsec/parsers/s01-parse/iptables-logs.yaml            
 crowdsecurity/whitelists                ✔️  enabled  0.2      /etc/crowdsec/parsers/s02-enrich/whitelists.yaml              
 crowdsecurity/geoip-enrich              ✔️  enabled  0.2      /etc/crowdsec/parsers/s02-enrich/geoip-enrich.yaml            
 crowdsecurity/http-logs                 ✔️  enabled  0.7      /etc/crowdsec/parsers/s02-enrich/http-logs.yaml               
 crowdsecurity/syslog-logs               ✔️  enabled  0.8      /etc/crowdsec/parsers/s00-raw/syslog-logs.yaml                
 crowdsecurity/nextcloud-logs            ✔️  enabled  0.1      /etc/crowdsec/parsers/s01-parse/nextcloud-logs.yaml           
 crowdsecurity/dateparse-enrich          ✔️  enabled  0.2      /etc/crowdsec/parsers/s02-enrich/dateparse-enrich.yaml        
 crowdsecurity/nginx-proxy-manager-logs  ✔️  enabled  0.1      /etc/crowdsec/parsers/s01-parse/nginx-proxy-manager-logs.yaml 
----------------------------------------------------------------------------------------------------------------------------
COLLECTIONS
------------------------------------------------------------------------------------------------------------
 NAME                               📦 STATUS   VERSION  LOCAL PATH                                         
------------------------------------------------------------------------------------------------------------
 crowdsecurity/iptables             ✔️  enabled  0.1      /etc/crowdsec/collections/iptables.yaml            
 crowdsecurity/linux                ✔️  enabled  0.2      /etc/crowdsec/collections/linux.yaml               
 crowdsecurity/base-http-scenarios  ✔️  enabled  0.5      /etc/crowdsec/collections/base-http-scenarios.yaml 
 crowdsecurity/nextcloud            ✔️  enabled  0.2      /etc/crowdsec/collections/nextcloud.yaml           
 crowdsecurity/nginx-proxy-manager  ✔️  enabled  0.1      /etc/crowdsec/collections/nginx-proxy-manager.yaml 
 crowdsecurity/sshd                 ✔️  enabled  0.2      /etc/crowdsec/collections/sshd.yaml                
------------------------------------------------------------------------------------------------------------
SCENARIOS
--------------------------------------------------------------------------------------------------------------------------
 NAME                                       📦 STATUS   VERSION  LOCAL PATH                                               
--------------------------------------------------------------------------------------------------------------------------
 crowdsecurity/http-open-proxy              ✔️  enabled  0.2      /etc/crowdsec/scenarios/http-open-proxy.yaml             
 ltsich/http-w00tw00t                       ✔️  enabled  0.1      /etc/crowdsec/scenarios/http-w00tw00t.yaml               
 crowdsecurity/http-crawl-non_statics       ✔️  enabled  0.2      /etc/crowdsec/scenarios/http-crawl-non_statics.yaml      
 crowdsecurity/iptables-scan-multi_ports    ✔️  enabled  0.1      /etc/crowdsec/scenarios/iptables-scan-multi_ports.yaml   
 crowdsecurity/http-sensitive-files         ✔️  enabled  0.2      /etc/crowdsec/scenarios/http-sensitive-files.yaml        
 crowdsecurity/http-generic-bf              ✔️  enabled  0.1      /etc/crowdsec/scenarios/http-generic-bf.yaml             
 crowdsecurity/ssh-slow-bf                  ✔️  enabled  0.2      /etc/crowdsec/scenarios/ssh-slow-bf.yaml                 
 crowdsecurity/http-backdoors-attempts      ✔️  enabled  0.2      /etc/crowdsec/scenarios/http-backdoors-attempts.yaml     
 crowdsecurity/nextcloud-bf                 ✔️  enabled  0.1      /etc/crowdsec/scenarios/nextcloud-bf.yaml                
 crowdsecurity/ssh-bf                       ✔️  enabled  0.1      /etc/crowdsec/scenarios/ssh-bf.yaml                      
 crowdsecurity/http-path-traversal-probing  ✔️  enabled  0.2      /etc/crowdsec/scenarios/http-path-traversal-probing.yaml 
 crowdsecurity/http-bad-user-agent          ✔️  enabled  0.4      /etc/crowdsec/scenarios/http-bad-user-agent.yaml         
 crowdsecurity/http-probing                 ✔️  enabled  0.2      /etc/crowdsec/scenarios/http-probing.yaml                
 crowdsecurity/http-xss-probing             ✔️  enabled  0.2      /etc/crowdsec/scenarios/http-xss-probing.yaml            
 crowdsecurity/http-sqli-probing            ✔️  enabled  0.2      /etc/crowdsec/scenarios/http-sqli-probing.yaml           
--------------------------------------------------------------------------------------------------------------------------
```

To view the server list of available components from the CrowdSec hub, use the command:

```
cscli hub list -a
```

### Collections

#### NectCloud

REFS: - [https://hub.crowdsec.net/author/crowdsecurity/collections/nextcloud](https://hub.crowdsec.net/author/crowdsecurity/collections/nextcloud "https://hub.crowdsec.net/author/crowdsecurity/collections/nextcloud")  
\- [https://hub.crowdsec.net/author/crowdsecurity/configurations/nextcloud-logs](https://hub.crowdsec.net/author/crowdsecurity/configurations/nextcloud-logs "https://hub.crowdsec.net/author/crowdsecurity/configurations/nextcloud-logs")  
\- [https://hub.crowdsec.net/author/crowdsecurity/configurations/nextcloud-bf](https://hub.crowdsec.net/author/crowdsecurity/configurations/nextcloud-bf "https://hub.crowdsec.net/author/crowdsecurity/configurations/nextcloud-bf")  
\- [https://docs.nextcloud.com/server/stable/admin\_manual/configuration\_server/config\_sample\_php\_parameters.html?highlight=loglevel#logging](https://docs.nextcloud.com/server/stable/admin_manual/configuration_server/config_sample_php_parameters.html?highlight=loglevel#logging "https://docs.nextcloud.com/server/stable/admin_manual/configuration_server/config_sample_php_parameters.html?highlight=loglevel#logging")  
\- [https://github.com/crowdsecurity/hub/blob/master/parsers/s01-parse/crowdsecurity/nextcloud-logs.yaml](https://github.com/crowdsecurity/hub/blob/master/parsers/s01-parse/crowdsecurity/nextcloud-logs.yaml "https://github.com/crowdsecurity/hub/blob/master/parsers/s01-parse/crowdsecurity/nextcloud-logs.yaml")

install the nextcloud community collection from the CrowdSec HUB with the command:

```
cscli collections install crowdsecurity/nextcloud
```

Then add the default path of your nextcloud.log file to the CrowdSec acquis.yaml config file:

```
/etc/crowdsec/acquis.yaml
```

```
---
filenames:
# - /var/www/nextcloud/data/nextcloud.log
# Dockerized NextCloud
  - /srv/docker/volumes/nc_gnextcloud_data/_data/nextcloud.log
labels:
  type: Nextcloud
```

You must restart the CrowdSec service to enable the modifications with the command:

```
service crowdsec restart
```

#### Nginx Proxy Manager

REFS: - [https://hub.crowdsec.net/author/crowdsecurity/collections/nginx-proxy-manager](https://hub.crowdsec.net/author/crowdsecurity/collections/nginx-proxy-manager "https://hub.crowdsec.net/author/crowdsecurity/collections/nginx-proxy-manager")

install the nextcloud community collection from the CrowdSec HUB with the command:

```
cscli collections install crowdsecurity/nginx-proxy-manager
```

Then add the default path of your nextcloud.log file to the CrowdSec acquis.yaml config file:

```
/etc/crowdsec/acquis.yaml
```

```
---
filenames:
#  - ~/data/logs/*.log
# Dockerized NGINX PROXY MANAGER
  - /srv/NGINX/data/nginx-proxy-manager/logs/*.log
labels:
  type: nginx-proxy-manager
```

You must restart the CrowdSec service to enable the modifications with the command:

```
service crowdsec restart
```

## Tweaks &amp; Good to know

### version

Call version to check the binary version installed;

```
cscli version
```

```
2022/02/07 09:45:21 version: v1.3.0-openwrt-1.3.0-4
2022/02/07 09:45:21 Codename: alphaga
2022/02/07 09:45:21 BuildDate: 2022-02-06_20:54:43
2022/02/07 09:45:21 GoVersion: 1.17.6
2022/02/07 09:45:21 Constraint_parser: >= 1.0, <= 2.0
2022/02/07 09:45:21 Constraint_scenario: >= 1.0, < 3.0
2022/02/07 09:45:21 Constraint_api: v1
2022/02/07 09:45:21 Constraint_acquis: >= 1.0, < 2.0
```

### metrics

Call metrics to check the health and status;

```
cscli metrics
```

Sample output:

```
INFO[07-02-2022 09:45:23 AM] Buckets Metrics:                             
+--------------------------------------+---------------+-----------+--------------+--------+---------+
|                BUCKET                | CURRENT COUNT | OVERFLOWS | INSTANCIATED | POURED | EXPIRED |
+--------------------------------------+---------------+-----------+--------------+--------+---------+
| crowdsecurity/http-bad-user-agent    | -             |         1 |            5 |      6 |       4 |
| crowdsecurity/http-crawl-non_statics | -             | -         |           24 |     47 |      24 |
| crowdsecurity/http-probing           | -             |         2 |           19 |     44 |      17 |
| crowdsecurity/http-sensitive-files   | -             | -         |            1 |      1 |       1 |
+--------------------------------------+---------------+-----------+--------------+--------+---------+
INFO[07-02-2022 09:45:23 AM] Acquisition Metrics:                         
+-----------------------------------------------------------------------+------------+--------------+----------------+------------------------+
|                                SOURCE                                 | LINES READ | LINES PARSED | LINES UNPARSED | LINES POURED TO BUCKET |
+-----------------------------------------------------------------------+------------+--------------+----------------+------------------------+
| file:/srv/NGINX/data/nginx-proxy-manager/logs/default-host_access.log |         39 |           37 |              2 |                     67 |
| file:/srv/NGINX/data/nginx-proxy-manager/logs/fallback_access.log     |         40 |           28 |             12 |                     31 |
| file:/srv/NGINX/data/nginx-proxy-manager/logs/proxy-host-1_access.log |          3 | -            |              3 | -                      |
| file:/srv/docker/volumes/nc_gnextcloud_data/_data/nextcloud.log       |       4390 | -            |           4390 | -                      |
+-----------------------------------------------------------------------+------------+--------------+----------------+------------------------+
INFO[07-02-2022 09:45:23 AM] Parser Metrics:                              
+----------------------------------------------+------+--------+----------+
|                   PARSERS                    | HITS | PARSED | UNPARSED |
+----------------------------------------------+------+--------+----------+
| child-crowdsecurity/http-logs                |  195 |    114 |       81 |
| child-crowdsecurity/nextcloud-logs           | 8780 | -      |     8780 |
| child-crowdsecurity/nginx-proxy-manager-logs |  153 |     65 |       88 |
| crowdsecurity/dateparse-enrich               |   65 |     65 | -        |
| crowdsecurity/geoip-enrich                   |   65 |     65 | -        |
| crowdsecurity/http-logs                      |   65 |     44 |       21 |
| crowdsecurity/nextcloud-logs                 | 4390 | -      |     4390 |
| crowdsecurity/nginx-proxy-manager-logs       |   82 |     65 |       17 |
| crowdsecurity/non-syslog                     | 4472 |   4472 | -        |
| crowdsecurity/whitelists                     |   65 |     65 | -        |
+----------------------------------------------+------+--------+----------+
INFO[07-02-2022 09:45:23 AM] Local Api Metrics:                           
+----------------------+--------+------+
|        ROUTE         | METHOD | HITS |
+----------------------+--------+------+
| /v1/alerts           | GET    |    1 |
| /v1/alerts           | POST   |    2 |
| /v1/decisions/stream | GET    | 4150 |
| /v1/watchers/login   | POST   |    5 |
+----------------------+--------+------+
INFO[07-02-2022 09:45:23 AM] Local Api Machines Metrics:                  
+----------+------------+--------+------+
| MACHINE  |   ROUTE    | METHOD | HITS |
+----------+------------+--------+------+
| STARGATE | /v1/alerts | POST   |    2 |
| STARGATE | /v1/alerts | GET    |    1 |
+----------+------------+--------+------+
INFO[07-02-2022 09:45:23 AM] Local Api Bouncers Metrics:                  
+---------------------------+----------------------+--------+------+
|          BOUNCER          |        ROUTE         | METHOD | HITS |
+---------------------------+----------------------+--------+------+
| crowdsec-firewall-bouncer | /v1/decisions/stream | GET    | 4150 |
+---------------------------+----------------------+--------+------+
```

### Alerts

#### Alerts Clean All

If needed, you can reset all blacklisted IPs with the following command:

```
cscli alerts delete --all
```

#### Alerts history list

Alerts listing;

```
cscli alerts list
```

Sample output:

```
+----+-----------------------------------+-----------------------------------+---------+--------------------------------+-----------+--------------------------------+
| ID |               VALUE               |              REASON               | COUNTRY |               AS               | DECISIONS |           CREATED AT           |
+----+-----------------------------------+-----------------------------------+---------+--------------------------------+-----------+--------------------------------+
| 19 | crowdsecurity/community-blocklist | update : +8933/-0 IPs             |         |                                | ban:8933  | 2022-02-07 07:11:45 +0000 UTC  |
| 18 | crowdsecurity/community-blocklist | update : +8909/-0 IPs             |         |                                | ban:19    | 2022-02-07 05:11:45 +0000 UTC  |
| 17 | Ip:144.76.38.10                   | crowdsecurity/http-bad-user-agent | DE      | 24940 Hetzner Online GmbH      | ban:1     | 2022-02-07 03:17:55.4087026    |
|    |                                   |                                   |         |                                |           | +0000 UTC                      |
| 16 | crowdsecurity/community-blocklist | update : +8851/-0 IPs             |         |                                | ban:9     | 2022-02-07 03:11:45 +0000 UTC  |
| 15 | Ip:122.152.199.105                | crowdsecurity/http-probing        | CN      | 45090 Shenzhen Tencent         | ban:1     | 2022-02-07 01:21:12.57294468   |
|    |                                   |                                   |         | Computer Systems Company       |           | +0000 UTC                      |
|    |                                   |                                   |         | Limited                        |           |                                |
| 14 | crowdsecurity/community-blocklist | update : +8811/-0 IPs             |         |                                | ban:12    | 2022-02-07 01:11:45 +0000 UTC  |
| 13 | crowdsecurity/community-blocklist | update : +8758/-0 IPs             |         |                                | ban:9     | 2022-02-06 23:11:45 +0000 UTC  |
| 12 | crowdsecurity/community-blocklist | update : +8600/-0 IPs             |         |                                | ban:21    | 2022-02-06 19:52:17 +0000 UTC  |
| 11 | crowdsecurity/community-blocklist | update : +8427/-0 IPs             |         |                                | ban:42    | 2022-02-06 12:35:44 +0000 UTC  |
| 10 | crowdsecurity/community-blocklist | update : +8407/-0 IPs             |         |                                | ban:10    | 2022-02-06 10:35:43 +0000 UTC  |
|  9 | crowdsecurity/community-blocklist | update : +8379/-0 IPs             |         |                                | ban:12    | 2022-02-06 08:35:45 +0000 UTC  |
|  8 | crowdsecurity/community-blocklist | update : +8354/-0 IPs             |         |                                | ban:8     | 2022-02-06 06:35:44 +0000 UTC  |
|  7 | crowdsecurity/community-blocklist | update : +8327/-0 IPs             |         |                                | ban:6     | 2022-02-06 04:35:43 +0000 UTC  |
|  6 | crowdsecurity/community-blocklist | update : +8295/-0 IPs             |         |                                | ban:12    | 2022-02-06 02:35:43 +0000 UTC  |
|  5 | crowdsecurity/community-blocklist | update : +8275/-0 IPs             |         |                                | ban:7     | 2022-02-06 00:35:44 +0000 UTC  |
|  4 | crowdsecurity/community-blocklist | update : +8252/-0 IPs             |         |                                | ban:17    | 2022-02-05 22:35:47 +0000 UTC  |
|  3 | crowdsecurity/community-blocklist | update : +8206/-0 IPs             |         |                                | ban:7     | 2022-02-05 20:34:47 +0000 UTC  |
|  2 | crowdsecurity/community-blocklist | update : +8182/-0 IPs             |         |                                | ban:2     | 2022-02-05 19:01:14 +0000 UTC  |
|  1 | crowdsecurity/community-blocklist | update : +6488/-0 IPs             |         |                                | ban:9     | 2022-02-05 16:55:48 +0000 UTC  |
+----+-----------------------------------+-----------------------------------+---------+--------------------------------+-----------+--------------------------------+
```

#### Alerts inspect item

```
cscli alerts inspect 15
```

```
################################################################################################

 - ID         : 15
 - Date       : 2022-02-07T01:21:19Z
 - Machine    : STARGATE
 - Simulation : false
 - Reason     : crowdsecurity/http-probing
 - Events Count : 11
 - Scope:Value: Ip:122.152.199.105
 - Country    : CN
 - AS         : Shenzhen Tencent Computer Systems Company Limited
 - Begin      : 2022-02-07 01:21:12.57294468 +0000 UTC
 - End        : 2022-02-07 01:21:17.285319 +0000 UTC
```

```
cscli alerts inspect 17
```

```
################################################################################################

 - ID         : 17
 - Date       : 2022-02-07T03:18:02Z
 - Machine    : STARGATE
 - Simulation : false
 - Reason     : crowdsecurity/http-bad-user-agent
 - Events Count : 2
 - Scope:Value: Ip:144.76.38.10
 - Country    : DE
 - AS         : Hetzner Online GmbH
 - Begin      : 2022-02-07 03:17:55.4087026 +0000 UTC
 - End        : 2022-02-07 03:18:00.62557932 +0000 UTC
```

### Configs

#### show

```
cscli config show
```

Sample output:

```
Global:
   - Configuration Folder   : /etc/crowdsec
   - Data Folder            : /srv/crowdsec/data
   - Hub Folder             : /etc/crowdsec/hub
   - Simulation File        : /etc/crowdsec/simulation.yaml
   - Log Folder             : /var/log/
   - Log level              : info
   - Log Media              : file
Crowdsec:
  - Acquisition File        : /etc/crowdsec/acquis.yaml
  - Parsers routines        : 1
cscli:
  - Output                  : human
  - Hub Branch              : 
  - Hub Folder              : /etc/crowdsec/hub
Local API Server:
  - Listen URL              : 127.0.0.1:9999
  - Profile File            : /etc/crowdsec/profiles.yaml
  - Database:
      - Type                : sqlite
      - Path                : /srv/crowdsec/data/crowdsec.db
      - Flush age           : 7d
      - Flush size          : 5000
```

#### backup

```
cscli config backup /srv/crowdsec/backup/202202071120
```

Sample output:

```
cscli config backup /srv/crowdsec/backup/202202071120
INFO[07-02-2022 11:17:37 AM] Starting configuration backup                
INFO[07-02-2022 11:17:37 AM] Saved simulation to /srv/crowdsec/backup/202202071120/simulation.yaml 
INFO[07-02-2022 11:17:37 AM] Saved default yaml to /srv/crowdsec/backup/202202071120/config.yaml 
INFO[07-02-2022 11:17:37 AM] Saved online API credentials to /srv/crowdsec/backup/202202071120/online_api_credentials.yaml 
INFO[07-02-2022 11:17:37 AM] Saved local API credentials to /srv/crowdsec/backup/202202071120/local_api_credentials.yaml 
INFO[07-02-2022 11:17:37 AM] Saved profiles to /srv/crowdsec/backup/202202071120/profiles.yaml 
INFO[07-02-2022 11:17:37 AM] saving, version:0.2, up-to-date:true          file=crowdsecurity/geoip-enrich type=parsers
INFO[07-02-2022 11:17:37 AM] saving, version:0.2, up-to-date:true          file=crowdsecurity/dateparse-enrich type=parsers
INFO[07-02-2022 11:17:37 AM] saving, version:0.1, up-to-date:true          file=crowdsecurity/nginx-proxy-manager-logs type=parsers
INFO[07-02-2022 11:17:37 AM] saving, version:0.8, up-to-date:true          file=crowdsecurity/syslog-logs type=parsers
INFO[07-02-2022 11:17:37 AM] saving, version:1.7, up-to-date:true          file=crowdsecurity/sshd-logs type=parsers
INFO[07-02-2022 11:17:37 AM] saving, version:0.7, up-to-date:true          file=crowdsecurity/http-logs type=parsers
INFO[07-02-2022 11:17:37 AM] saving, version:0.2, up-to-date:true          file=crowdsecurity/iptables-logs type=parsers
INFO[07-02-2022 11:17:37 AM] saving, version:0.2, up-to-date:true          file=crowdsecurity/whitelists type=parsers
INFO[07-02-2022 11:17:37 AM] saving, version:0.1, up-to-date:true          file=crowdsecurity/nextcloud-logs type=parsers
INFO[07-02-2022 11:17:37 AM] Wrote 9 entries for parsers to /srv/crowdsec/backup/202202071120/parsers//upstream-parsers.json  file=crowdsecurity/tcpdump-logs type=parsers
INFO[07-02-2022 11:17:37 AM] Wrote 0 entries for postoverflows to /srv/crowdsec/backup/202202071120/postoverflows//upstream-postoverflows.json  file=crowdsecurity/seo-bots-whitelist type=postoverflows
INFO[07-02-2022 11:17:37 AM] saving, version:0.1, up-to-date:true          file=crowdsecurity/iptables-scan-multi_ports type=scenarios
INFO[07-02-2022 11:17:37 AM] saving, version:0.4, up-to-date:true          file=crowdsecurity/http-bad-user-agent type=scenarios
INFO[07-02-2022 11:17:37 AM] saving, version:0.2, up-to-date:true          file=crowdsecurity/ssh-slow-bf type=scenarios
INFO[07-02-2022 11:17:37 AM] saving, version:0.2, up-to-date:true          file=crowdsecurity/http-backdoors-attempts type=scenarios
INFO[07-02-2022 11:17:37 AM] saving, version:0.2, up-to-date:true          file=crowdsecurity/http-open-proxy type=scenarios
INFO[07-02-2022 11:17:37 AM] saving, version:0.1, up-to-date:true          file=crowdsecurity/ssh-bf type=scenarios
INFO[07-02-2022 11:17:38 AM] saving, version:0.1, up-to-date:true          file=crowdsecurity/http-generic-bf type=scenarios
INFO[07-02-2022 11:17:38 AM] saving, version:0.2, up-to-date:true          file=crowdsecurity/http-sensitive-files type=scenarios
INFO[07-02-2022 11:17:38 AM] saving, version:0.1, up-to-date:true          file=crowdsecurity/nextcloud-bf type=scenarios
INFO[07-02-2022 11:17:38 AM] saving, version:0.1, up-to-date:true          file=ltsich/http-w00tw00t type=scenarios
INFO[07-02-2022 11:17:38 AM] saving, version:0.2, up-to-date:true          file=crowdsecurity/http-xss-probing type=scenarios
INFO[07-02-2022 11:17:38 AM] saving, version:0.2, up-to-date:true          file=crowdsecurity/http-probing type=scenarios
INFO[07-02-2022 11:17:38 AM] saving, version:0.2, up-to-date:true          file=crowdsecurity/http-path-traversal-probing type=scenarios
INFO[07-02-2022 11:17:38 AM] saving, version:0.2, up-to-date:true          file=crowdsecurity/http-sqli-probing type=scenarios
INFO[07-02-2022 11:17:38 AM] saving, version:0.2, up-to-date:true          file=crowdsecurity/http-crawl-non_statics type=scenarios
INFO[07-02-2022 11:17:38 AM] Wrote 15 entries for scenarios to /srv/crowdsec/backup/202202071120/scenarios//upstream-scenarios.json  file=crowdsecurity/thinkphp-cve-2018-20062 type=scenarios
INFO[07-02-2022 11:17:38 AM] saving, version:0.2, up-to-date:true          file=crowdsecurity/sshd type=collections
INFO[07-02-2022 11:17:38 AM] saving, version:0.1, up-to-date:true          file=crowdsecurity/nginx-proxy-manager type=collections
INFO[07-02-2022 11:17:38 AM] saving, version:0.1, up-to-date:true          file=crowdsecurity/iptables type=collections
INFO[07-02-2022 11:17:38 AM] saving, version:0.2, up-to-date:true          file=crowdsecurity/nextcloud type=collections
INFO[07-02-2022 11:17:38 AM] saving, version:0.5, up-to-date:true          file=crowdsecurity/base-http-scenarios type=collections
INFO[07-02-2022 11:17:38 AM] saving, version:0.2, up-to-date:true          file=crowdsecurity/linux type=collections
INFO[07-02-2022 11:17:38 AM] Wrote 6 entries for collections to /srv/crowdsec/backup/202202071120/collections//upstream-collections.json  file=crowdsecurity/wordpress type=collections
```

## AddOns

### External tools

#### cs\_scripts.sh

A new external script for CrowdSec specific actions was added in

```
/usr/lib/crowdsec/scripts/cs_script.sh
```

You can load it with: &lt;/code&gt; . /usr/lib/crowdsec/scripts/cs\_script.sh &lt;/code&gt;

Then, internal function can be called like;

```
cs_hub
```

sample output:

```
INFO[07-02-2022 08:39:16 AM] Wrote new 277818 bytes index to /etc/crowdsec/hub/.index.json 
WARN[07-02-2022 08:39:17 AM] crowdsecurity/syslog-logs : overwrite        
WARN[07-02-2022 08:39:17 AM] crowdsecurity/geoip-enrich : overwrite       
WARN[07-02-2022 08:39:17 AM] crowdsecurity/dateparse-enrich : overwrite   
WARN[07-02-2022 08:39:17 AM] crowdsecurity/sshd-logs : overwrite          
WARN[07-02-2022 08:39:17 AM] crowdsecurity/ssh-bf : overwrite             
WARN[07-02-2022 08:39:17 AM] crowdsecurity/ssh-slow-bf : overwrite        
WARN[07-02-2022 08:39:17 AM] crowdsecurity/sshd : overwrite               
WARN[07-02-2022 08:39:17 AM] crowdsecurity/sshd : overwrite               
WARN[07-02-2022 08:39:18 AM] crowdsecurity/linux : overwrite              
INFO[07-02-2022 08:39:18 AM] /etc/crowdsec/collections/sshd.yaml already exists. 
INFO[07-02-2022 08:39:18 AM] /etc/crowdsec/collections/linux.yaml already exists. 
INFO[07-02-2022 08:39:18 AM] Enabled crowdsecurity/linux                  
INFO[07-02-2022 08:39:18 AM] Run 'sudo systemctl reload crowdsec' for the new configuration to be effective. 
WARN[07-02-2022 08:39:18 AM] crowdsecurity/iptables-logs : overwrite      
WARN[07-02-2022 08:39:18 AM] crowdsecurity/iptables-scan-multi_ports : overwrite 
WARN[07-02-2022 08:39:18 AM] crowdsecurity/iptables : overwrite           
INFO[07-02-2022 08:39:18 AM] /etc/crowdsec/collections/iptables.yaml already exists. 
INFO[07-02-2022 08:39:18 AM] Enabled crowdsecurity/iptables               
INFO[07-02-2022 08:39:18 AM] Run 'sudo systemctl reload crowdsec' for the new configuration to be effective. 
WARN[07-02-2022 08:39:19 AM] crowdsecurity/whitelists : overwrite         
INFO[07-02-2022 08:39:19 AM] Enabled crowdsecurity/whitelists             
INFO[07-02-2022 08:39:19 AM] Run 'sudo systemctl reload crowdsec' for the new configuration to be effective. 
INFO[07-02-2022 08:39:20 AM] Upgrading collections                        
INFO[07-02-2022 08:39:20 AM] crowdsecurity/base-http-scenarios : up-to-date 
INFO[07-02-2022 08:39:20 AM] crowdsecurity/nginx-proxy-manager : up-to-date 
INFO[07-02-2022 08:39:20 AM] crowdsecurity/linux : up-to-date             
INFO[07-02-2022 08:39:20 AM] crowdsecurity/nextcloud : up-to-date         
INFO[07-02-2022 08:39:20 AM] crowdsecurity/iptables : up-to-date          
INFO[07-02-2022 08:39:20 AM] crowdsecurity/sshd : up-to-date              
INFO[07-02-2022 08:39:20 AM] All collections are already up-to-date       
INFO[07-02-2022 08:39:20 AM] Upgrading parsers                            
INFO[07-02-2022 08:39:20 AM] crowdsecurity/nextcloud-logs : up-to-date    
INFO[07-02-2022 08:39:20 AM] crowdsecurity/nginx-proxy-manager-logs : up-to-date 
INFO[07-02-2022 08:39:20 AM] crowdsecurity/http-logs : up-to-date         
INFO[07-02-2022 08:39:20 AM] crowdsecurity/iptables-logs : up-to-date     
INFO[07-02-2022 08:39:20 AM] crowdsecurity/geoip-enrich : up-to-date      
INFO[07-02-2022 08:39:20 AM] crowdsecurity/sshd-logs : up-to-date         
INFO[07-02-2022 08:39:20 AM] crowdsecurity/whitelists : up-to-date        
INFO[07-02-2022 08:39:20 AM] crowdsecurity/dateparse-enrich : up-to-date  
INFO[07-02-2022 08:39:20 AM] crowdsecurity/syslog-logs : up-to-date       
INFO[07-02-2022 08:39:20 AM] All parsers are already up-to-date           
INFO[07-02-2022 08:39:20 AM] Upgrading scenarios                          
INFO[07-02-2022 08:39:20 AM] crowdsecurity/http-open-proxy : up-to-date   
INFO[07-02-2022 08:39:20 AM] crowdsecurity/ssh-bf : up-to-date            
INFO[07-02-2022 08:39:20 AM] ltsich/http-w00tw00t : up-to-date            
INFO[07-02-2022 08:39:20 AM] crowdsecurity/nextcloud-bf : up-to-date      
INFO[07-02-2022 08:39:20 AM] crowdsecurity/http-xss-probing : up-to-date  
INFO[07-02-2022 08:39:20 AM] crowdsecurity/http-probing : up-to-date      
INFO[07-02-2022 08:39:20 AM] crowdsecurity/http-path-traversal-probing : up-to-date 
INFO[07-02-2022 08:39:20 AM] crowdsecurity/http-generic-bf : up-to-date   
INFO[07-02-2022 08:39:20 AM] crowdsecurity/http-sqli-probing : up-to-date 
INFO[07-02-2022 08:39:20 AM] crowdsecurity/iptables-scan-multi_ports : up-to-date 
INFO[07-02-2022 08:39:20 AM] crowdsecurity/http-bad-user-agent : up-to-date 
INFO[07-02-2022 08:39:20 AM] crowdsecurity/http-crawl-non_statics : up-to-date 
INFO[07-02-2022 08:39:20 AM] crowdsecurity/http-sensitive-files : up-to-date 
INFO[07-02-2022 08:39:20 AM] crowdsecurity/ssh-slow-bf : up-to-date       
INFO[07-02-2022 08:39:20 AM] crowdsecurity/http-backdoors-attempts : up-to-date 
INFO[07-02-2022 08:39:20 AM] All scenarios are already up-to-date         
INFO[07-02-2022 08:39:20 AM] Upgrading postoverflows                      
INFO[07-02-2022 08:39:20 AM] No postoverflows installed, nothing to upgrade 
```

This tool will be extended for automating usability...  
actually, it contains these functions:

```
cs_prepare # to check the necessary directories...
cs_init # to prepare the config file with modified settings...
cs_register # to check the LAPI and CAPI registering status and register the local host...
cs_hub # to update hub, install collections from hub, and upgrade from hub...
```

#### Web Console

*TODO*
