## Get a free HTTPS certificate from LetsEncrypt for OpenWrt with ACME.sh

For HTTPS you need a [TLS certificate](/docs/guide-user/services/tls/certs "docs:guide-user:services:tls:certs"). By default the OpenWrt generates one (self-signed). You can open the Luci by the HTTPS URL. But your browser will complain that the certificate is self made and we can't know if the cert was't forged by an attacker in the middle.

You can generate (“issue”) a TLS certificate on a device and ask a Certificate Authority (CA) to sign it so that browsers will accept it without a warning. The [LetsEncrypt](https://LetsEncrypt.org "https://LetsEncrypt.org") and [ZeroSSL](https://ZeroSSL.com "https://ZeroSSL.com") are two CAs that allows to do that for free and automatically by using ACME verification protocol. You'll need an ACME client i.e. the `acme.sh` installed and configured that will do the work to issue certificate and renew it after 3 months. The acme.sh uses the ZeroSSL by default [starting from v3.0 Aug 2021](https://github.com/acmesh-official/acme.sh/wiki/Change-default-CA-to-ZeroSSL "https://github.com/acmesh-official/acme.sh/wiki/Change-default-CA-to-ZeroSSL") but the OpenWrt package didn't followed the change and still uses the LetsEncrypt by default.

### Before starting

You must understand [ACME Challenge Validation Types](https://letsencrypt.org/docs/challenge-types/ "https://letsencrypt.org/docs/challenge-types/"). In short the CA (i.e. LetsEncrypt, ZeroSSL) needs to ensure that you own the domain for which you trying to issue a certificate. So the CA generates a “challenge” random token that should ether

- Added as a `TXT` record to a domain via the DNS provider API. This validation called `DNS-01` challenge.
- Putted into a special folder on a web server accessible from outside by URL like `http://YOUR_DOMAIN/.well-known/acme-challenge/TOKEN`. This validation called `HTTP-01` challenge.

Then the CA will check that the token is accessible and thus confirms that you do have a control over the server.

If you are using a [DDNS dynamic DNS](/packages/pkgdata/ddns-scripts "packages:pkgdata:ddns-scripts") then you for sure better to use the `DNS-01` because you already have credentials on a device to update the DNS records.

If you making your router public or you are going to use a `HTTP-01` challenge validation via `Webroot` or `Standalone` validation method, then you need to [allow access from the internet](/docs/guide-user/luci/luci.secure#allow_access_from_internet "docs:guide-user:luci:luci.secure"). The ACME protocol needs for the HTTP port 80 for a challenge validation but for a `Webroot` you better to enable a Redirect to HTTPS so the 443 port needs to be open too.

If you are want to have a valid cert for a domain without opening an access to a wild internet then the only option for you is a DNS challenge validation. But not all DNS providers have an API to do this, or you have to specify a password from a full admin panel which is not acceptable from security perspective.

### ACME clients

There are few ACME clients available on OpenWrt: `acme.sh`, `uacme`, `certbot`. Currently the acme.sh is best supported and the `acme` package will install it.

Since version 4.0.0 (Aug 2022) the `acme` package was reorganized and now we have a few packages:

- `acme-common` that provide the UCI config in the `/etc/config/acme`
- `acme-acmesh` that contains the acme.sh script
- `acme-acmesh-dnsapi` that contains additional `acme.sh` scripts to use DNS validation.

There was a [PR](https://github.com/openwrt/packages/pull/10792 "https://github.com/openwrt/packages/pull/10792") to add `acme-uacme` package but it was lack of interest and staled. In future we may have more acme clients integrated.

The `acme` package now is empty and it become a transitional virtual package that installs the `acme-common` and `acme-acmesh`.

The `acme` v4 also had a breaking change. Auto deployment of cert to Luci was removed. Now you must configure certs manually, you may try the `luci-app-uhttpd` to set a path to a cert. Old options like `update_uhttpd` and `update_nginx` are gone.

### Using GUI

The Luci admin panel has apps that can be installed to extend GUI with additional configuration pages. The `luci-app-acme` provides a GUI to configure issuing of certificates.

Open LUCI dashboard then in main menu go to [System -&gt; Software](http://192.168.1.1/cgi-bin/luci/admin/system/opkg "http://192.168.1.1/cgi-bin/luci/admin/system/opkg"). Then click on “Update lists...” to load list of available packages. Type into the “Filter” search fields the package name `luci-app-acme` and press Enter. Click on install button. As a dependency it will install `acme` that itself will install `acme-common` and `acme-acmesh` packages. If you are going to use DNS validation please also install the `acme-acmesh-dnsapi`.

To configure in LUCI in the main menu open [Services -&gt; ACME certs](http://192.168.1.1/cgi-bin/luci/admin/services/acme "http://192.168.1.1/cgi-bin/luci/admin/services/acme").

Basic configuration:

- “Account email”: put your email to receive expiry notices when your certificate is coming up for renewal.
- You'll see a two pre-configured but disabled EXAMPLE domains. But we'll make a new one for ourselves.
- At bottom find a field for a new domain config, type your domain but with underscores e.g. `example_com` and click on “Add”.
- A new config section will be added. Now let's edit it.
- Click on the “Enabled” checkbox.
- “Domain names”: add your domain `example.com`. If you need a wildcard cert then also add `*.example.com` (needs for DNS challenge).
- Switch to “Challenge Validation” tab and select “Validation method”:
  
  - If your web server is public then select “Webroot”. The default webroot path is `/var/run/acme/challenge/`. See details below.
  - If you wish to get a wildcard cert e.g. `*.example.com` or you don't have a public webserver then the only option is the “DNS” validation and you must configure DNS API.
  - If you don't have any webserver or the it's not accessible from internet then you can may use the “Standalone” mode.
- Click on “Save and Apply”.

In a minute the cert should be generated. You can check logs in [Status -&gt; System Log](http://192.168.1.1/cgi-bin/luci/admin/status/syslog "http://192.168.1.1/cgi-bin/luci/admin/status/syslog").

If any error occurred fix it and restart the acme service to trigger issuing. Go to [System -&gt; Startup](http://192.168.1.1/cgi-bin/luci/admin/system/startup "http://192.168.1.1/cgi-bin/luci/admin/system/startup"), find the acme service and click of “Restart”.

### By using command line

For experienced users this may be more preferable than GUI.

Step 1: Install packages Use a command line and type `opkg install acme`. If you want to use DNS-based certificate verification, also install the DNS provider hooks: `opkg install acme-acmesh-dnsapi`

Step 2: Configure the acme.sh Edit `/etc/config/acme` to configure your personal email, domain name and validation method. For the Webroot challenge validation use `option validation_method 'webroot`'.

If you have `acme-common` version older that 1.4 (May 2024) then you may have to create a symlink before:

```
mkdir /www/.well-known/
ln -s /var/run/acme/challenge/ /www/.well-known/acme-challenge
```

See next section with details.

For the DNS challenge validation use `option validation_method 'dns`'.

For example if you use the DuckDNS.org DDNS provider and wish to have a wildcard certificate `*.example.duckdns.org` then install the `acme-acmesh-dnsapi` package and configure the acme like:

```
config acme
        option account_email 'youremail@example.com'

config cert 'example_duckdns_wildcard'
        option enabled '1'
        option validation_method 'dns'
        option dns 'dns_duckdns'
        list credentials 'DuckDNS_Token="YOUR_TOKEN"'
        list domains 'example.duckdns.org'
        list domains '*.example.duckdns.org'
```

See [Acme.sh DNS API: DuckDNS.org](https://github.com/acmesh-official/acme.sh/wiki/dnsapi#dns_duckdns "https://github.com/acmesh-official/acme.sh/wiki/dnsapi#dns_duckdns") for details.

Step 3: Issue your certificate by restarting the acme service with `/etc/init.d/acme restart`. This may take for some time. You can read logs with `logread -e acme`. In case of problems please try to enable the `debug 1` option that will print more details.

### Webroot

When the `webroot` validation is used the acme client stores challenge files to a folder (called “webroot”) that is accessible from internet and the Certificate Authority (e.g. LetsEncrypt, ZeroSSL) checks it the files the site by a URL `http://example.com/.well-known/acme-challenge/`. This allows for CA to ensure that you have an access to the domain settings.

The acme.sh has a an option `-w` to specify a path to the webroot folder and the UCI config at `/etc/config/acme` allowed to specify it too. The problem is that if you have to always change to a place where your website files are located e.g. `/www/.well-known/acme-challenge/`. Creating files on a disk may eventually ruin the NAND flash but also the folder may be actually read only.

Since version 4.0.0 (Aug 2022) the `acme` switched to always use the same `/var/run/acme/challenge/` folder for webroot. The folder is in memory and it's path is always the same so the `webroot` config option is not needed anymore and was deprecated.

Instead you can create a symlink:

```
mkdir /www/.well-known/
ln -s /var/run/acme/challenge/ /www/.well-known/acme-challenge
```

Now test if it's accessible from internet:

```
mkdir -p /var/run/acme/challenge/
echo Hi > /var/run/acme/challenge/README.txt
# open in browser or execute the wget
wget -qO - http://example.com/.well-known/acme-challenge/README.txt
```

Since `acme-common` v1.4 (May 2024) the default symlink is automatically created on installation. But you may have other http document roots so please create the symlink yourself.

I hope that eventually OpenWrt web servers will serve the folder `/var/run/acme/challenge/` under `/.well-known/acme-challenge/` URL path by default. So no any additional symlinks will be needed.

### Using of the generated certificates

After that you can find the certificates in a folder at `/etc/ssl/acme/` e.g.:

- `/etc/ssl/acme/*.example.com.key` the TLS private key. **Never share it!**
- `/etc/ssl/acme/*.example.com.fullchain.crt` the TLS certificate and chain of CA that signed it.

Detailed certificate configs are stored in `/etc/acme/`.

You can use them in [uhttpd](/docs/guide-user/services/webserver/uhttpd#https_enable_and_certificate_settings_and_creation "docs:guide-user:services:webserver:uhttpd"), [lighttpd](/docs/guide-user/services/webserver/lighttpd "docs:guide-user:services:webserver:lighttpd"), [nginx](/docs/guide-user/services/webserver/nginx "docs:guide-user:services:webserver:nginx"), [EmailRelay](/docs/guide-user/services/email/emailrelay "docs:guide-user:services:email:emailrelay") and any other server that you want to configure with TLS.

### Standalone Mode Validation

The standalone mode is intended to be used if you don't have a webserver (e.g. mail only) or it's not publicly accessible from internet. It will start a `socat` that will imitate a temporary web-server to return a the file with a random value of ACME challenge to the CA (e.g. LetsEncrypt) so that they can ensure that you really own the server and the domain. That server needs to be publicly accessible, so you may have to forward the external public WAN port 80 to it. However, that server listens on port 80 by default, which might clash with `uhttpd` which by default listens 80 port on all interfaces and IPs. You can [change the listening port](https://forum.archive.openwrt.org/viewtopic.php?id=65090&p=1 "https://forum.archive.openwrt.org/viewtopic.php?id=65090&p=1") to something like 8080, by editing the value of `Le_HTTPPort` in `/usr/lib/acme/acme.sh`, or by passing it the `--httpport` argument. Then you must forward WAN port 80 (external port remains the same) to device port 8080. See [Accessing LuCI web interface securely](/docs/guide-user/luci/luci.secure "docs:guide-user:luci:luci.secure") for more details about port changing.

### Hooks

When a certificate issued or renewed the OpenWrt acme calls hotplug hooks in the `/etc/hotplug.d/acme/` with an $`ACTION` correspondingly `issued` or `renewed`. Then it also sends a [UBUS](/docs/techref/ubus "docs:techref:ubus") event `acme.issue` and `acme.renew`.

The uhttpd, nginx, haproxy are listening for the UBUS event `acme.renew` and performing a service reload on a cert renewal. So no any additional deployment hooks are needed. Just specify a correct path to a cert.

But the reloading is triggered only on a renewal. So you need to issue a cert, then configure a path to it in uhttpd/nginx/haproxy config and then restart a service.

But other web webservers like Apache and Lighttpd don't have such a reload trigger.

You may try to add a hotplug script yourself:

Create a file `/etc/hotplug.d/acme/00-apache` with the content:

[/etc/hotplug.d/acme/00-apache](/_export/code/docs/guide-user/services/tls/acmesh?codeblock=4 "Download Snippet")

```
if [ "$ACTION" = "renewed" ]; then
	/etc/init.d/apache reload
fi
```

**NOTE**: Calling the `/etc/init.d/apache reload` directly in the acme hotplug script can inadvertently start a stopped instance.

### UCI config options

Name Type Required Default Description `account_email` string yes Email address to associate with account key. If a certificate wasn't renewed in time then you'll receive a notice at 20 days before expiry. `debug` boolean no *0* Set *1* to enable debug logging `state_dir` string no `/etc/ssl/acme` Deprecated, now is unchangeable. The ACME.sh state folder where account data is stored. The generated certificates will be symlinked to `/etc/ssl/acme/`

Name Type Required Default Description `enabled` boolean no *1* Enabled issuing of certs for the domains `staging` boolean no *0* Get certificate from the LetsEncrypt staging server (use for testing; the certificate won't be valid). `domains` list yes Domain names to include in the certificate. The first name will be the subject name, subsequent names will be alt names. `validation_method` string yes Challenge validation mode: *dns*, *webroot* or *standalone*. Standalone mode will use the built-in webserver of acme.sh to issue a certificate. Webroot mode will use an existing webserver to issue a certificate. DNS mode will allow you to use the DNS API of your DNS provider to issue a certificate. `dns` string yes for *dns* mode DNS API name. See [acme.sh wiki: DNS API](https://github.com/acmesh-official/acme.sh/wiki/dnsapi "https://github.com/acmesh-official/acme.sh/wiki/dnsapi") for the list of available APIs. In DNS mode, the domain name does not have to resolve to the router IP. DNS mode is also the only mode that supports wildcard certificates. Using this mode requires the acme-dnsapi package to be installed. `dns_wait` integer no Seconds to wait for a DNS record to be updated and then continue. See [acme.sh wiki: dnssleep](https://github.com/acmesh-official/acme.sh/wiki/dnssleep "https://github.com/acmesh-official/acme.sh/wiki/dnssleep") `credentials` list yes for *dns* mode The credentials for the DNS API mode selected above. See [acme.sh wiki: DNS API](https://github.com/acmesh-official/acme.sh/wiki/dnsapi "https://github.com/acmesh-official/acme.sh/wiki/dnsapi") for the credentials required by each API. Add multiple entries here in `KEY=VAL` shell variable format to supply multiple credential variables. `calias` string no Challenge Alias. The challenge alias to use for ALL domains. See [acme.sh wiki: DNS Alias Mode](https://github.com/acmesh-official/acme.sh/wiki/DNS-alias-mode "https://github.com/acmesh-official/acme.sh/wiki/DNS-alias-mode") for the details of this process. LUCI only supports one challenge alias per certificate. `dalias` string no Domain Alias. The domain alias to use for ALL domains. See [acme.sh wiki: DNS Alias Mode](https://github.com/acmesh-official/acme.sh/wiki/DNS-alias-mode "https://github.com/acmesh-official/acme.sh/wiki/DNS-alias-mode") for the details of this process. LUCI only supports one challenge domain per certificate. `webroot` string no `/var/run/acme/challenge` **Deprecated.** Use the default folder and remove the option. Webserver root directory. Set this to the webserver document root to run Acme in `webroot` mode. The web server must be accessible from the internet on port 80. `key_type` string no *ec256* Key size (and type) for the generated certificate. `rsa2048`, `rsa3072`, `rsa4096`, `ec256`, `ec384` `keylength` string no **Deprecated**. Use the `key_type` instead. The RSA key length in bits. `acme_server` string no *letsencrypt* A custom CA ACME server directory URL. See [acme.sh wiki: servers](https://github.com/acmesh-official/acme.sh/wiki/Server "https://github.com/acmesh-official/acme.sh/wiki/Server"). `standalone` boolean no *0* **Deprecated.** Use `option validation_method 'standalone`' instead. `days` integer no *60* Days until renewal `update_uhttp` boolean no *0* **Removed in acme v4.0.0**. After issuing a cert configure the uhttpd UCI main section (i.e. Luci) to use the new cert. I.e. set UCI `uhttpd.main.key` and `uhttpd.main.cert`. Then reload the uhttpd service. Update the uhttpd config with this certificate once issued (only select this for one certificate). It's also available the `luci-app-uhttpd` to configure uhttpd form the LuCI interface. `update_nginx` boolean no *0* **Removed in acme v4.0.0**. After issuing a cert configure the Nginx to use the new cert. I.e. call the `nginx-util add_ssl`. Then reload the nginx service. Update the nginx config with this certificate once issued (only select this for one certificate). Nginx must support ssl, if not it won't start as it needs to be compiled with ssl support to use cert options `update_haproxy` boolean no *0* **Removed in acme v4.0.0**. After issuing a cert configure the HAProxy to use the new cert. I.e. change the `bind` option in the `haproxy.cfg`. Then reload the haproxy service. `user_setup` path no *none* **Removed in acme v4.0.0**. User-provided setup script `user_cleanup` path no *none* **Removed in acme v4.0.0**. User-provided cleanup script

### acme.sh command

The `acme-acmesh` package installs the full acme.sh script to `/usr/lib/acme/client/acme.sh` so you can call it directly without UCI config e.g.:

```
mkdir /www/.well-known/
ln -s /var/run/acme/challenge/ /www/.well-known/acme-challenge
/usr/lib/acme/client/acme.sh --issue -d example.com -w /var/run/acme/challenge/
```

See more samples in the [acme.sh wiki: How to issue a cert](https://github.com/acmesh-official/acme.sh/wiki/How-to-issue-a-cert "https://github.com/acmesh-official/acme.sh/wiki/How-to-issue-a-cert")

Before the `acme` v4 the path was `/usr/lib/acme/acme.sh`.

### See also

- [ACME.sh on OpenWrt Support forum topic](https://forum.openwrt.org/t/letsencrypt-acme-sh-and-luci-app-acme-support-topic/196821 "https://forum.openwrt.org/t/letsencrypt-acme-sh-and-luci-app-acme-support-topic/196821") - feel free to ask questions here
- [LetsEncrypt forum](https://community.letsencrypt.org/ "https://community.letsencrypt.org/") use for the LetsEncrypt related questions.
- [Acme.sh Wiki: How to run on OpenWrt](https://github.com/acmesh-official/acme.sh/wiki/How-to-run-on-OpenWrt "https://github.com/acmesh-official/acme.sh/wiki/How-to-run-on-OpenWrt") also describes how to configure uhttpd and firewall.
- [Acme.sh DNS API: Part 1](https://github.com/acmesh-official/acme.sh/wiki/dnsapi "https://github.com/acmesh-official/acme.sh/wiki/dnsapi")
- [Acme.sh DNS API: Part 2](https://github.com/acmesh-official/acme.sh/wiki/dnsapi2 "https://github.com/acmesh-official/acme.sh/wiki/dnsapi2")
- [Arch Wiki: ACME.sh](https://wiki.archlinux.org/title/Acme.sh "https://wiki.archlinux.org/title/Acme.sh")
- [Acme.sh: How to issue a cert](https://github.com/acmesh-official/acme.sh/wiki/How-to-issue-a-cert "https://github.com/acmesh-official/acme.sh/wiki/How-to-issue-a-cert") using the acme.sh command directly
- [openwrt DDNS, acme commands](https://blog.gainskills.top/2021/09/15/openwrt-ddns-cert/ "https://blog.gainskills.top/2021/09/15/openwrt-ddns-cert/")
- [Dynu.com OpenWRT ACME.sh](https://forum.openwrt.org/t/dynu-openwrt-acme-lets-encrypt/110758 "https://forum.openwrt.org/t/dynu-openwrt-acme-lets-encrypt/110758")
- [acme: use the hotplug system](https://github.com/openwrt/packages/pull/17721 "https://github.com/openwrt/packages/pull/17721") a PR with v4 that changed how the `acme` works in OpenWrt.
- Sources: [acme-common](https://github.com/openwrt/packages/tree/master/net/acme-common "https://github.com/openwrt/packages/tree/master/net/acme-common"), [acme-acmesh](https://github.com/openwrt/packages/tree/master/net/acme-acmesh "https://github.com/openwrt/packages/tree/master/net/acme-acmesh")
