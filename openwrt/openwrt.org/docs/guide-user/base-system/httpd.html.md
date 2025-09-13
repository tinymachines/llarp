# Web Server Configuration

This is **many** releases out of date. [uhttpd](/docs/guide-user/services/webserver/http.uhttpd "docs:guide-user:services:webserver:http.uhttpd") has been the default web server since at least Attitude Adjustment.

The `/etc/config/httpd` configuration file defines uci parameters for the [BusyBox web server](/docs/guide-user/services/webserver/http.httpd "docs:guide-user:services:webserver:http.httpd").

## Sections

The configuration file consists of a single section `httpd`.

### Httpd

This is the default configuration for this section:

```
config 'httpd'
        option 'port' '80'
        option 'home' '/www'
```

The `httpd` section contains these settings:

Name Type Required Default Description `c_file` string no `/etc/httpd.conf` Path to configuration file. `home` string no `/www` Path to the document root directory. `port` integer no `80` Port number the web server should listen on. `realm` string no *hostname* Authentication realm to be presented to clients when authentication is required. The default is the value of `system.@system[0].hostname`
