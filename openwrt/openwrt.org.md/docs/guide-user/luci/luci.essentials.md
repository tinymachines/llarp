# LuCI essentials

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

## Introduction

While OpenWrt can be managed completely using SSH and the terminal, LuCI provides a web interface for many administration tasks. OpenWrt stable releases have LuCI preinstalled. However it is not included with snapshots and may be installed easily as described below. Also for low-memory devices, such as those with 4MB Flash and/or 32MB RAM, the full install may fail because of lacking sufficient Flash memory so you will have to [build your own image](/docs/guide-user/additional-software/imagebuilder "docs:guide-user:additional-software:imagebuilder") with LuCI included. More info on this can be obtained [here](/docs/guide-user/additional-software/saving_space "docs:guide-user:additional-software:saving_space").

## Instructions

### 1. Basic installation

#### Using Firmware-selector

==== 2. Adding HTTP based Luci access ====

- Go to [https://firmware-selector.openwrt.org/?version=SNAPSHOT](https://firmware-selector.openwrt.org/?version=SNAPSHOT "https://firmware-selector.openwrt.org/?version=SNAPSHOT"), and type in your device.
- Click on the tiny arrow next to “Customize installed packages and/or first boot script”
- Scroll down and click the “REQUEST BUILD” button
- Download the generated SYSUPGRADE image

==== 3. Replacing HTTP with HTTPS access ====

- Use the same URL as before, and click the arrow.
- Put a **-** in front of luci and add luci-ssl to the list of packages.
- Generate the image as before.

==== 4. Native language support ====

- If you know the name of your language package, simply add it to the list of packages, as above.

Transfer the image to the router and perform a sysupgrade, as described in [sysupgrade.cli](/docs/guide-user/installation/sysupgrade.cli "docs:guide-user:installation:sysupgrade.cli").

#### For stable releases up to 24.10

```
opkg update
opkg install luci
```

Now you can open LuCI interface.

==== 2. Providing encryption ====

Install the required packages.

```
opkg update
opkg install luci-ssl
/etc/init.d/uhttpd restart
```

Force LuCI to redirect to HTTPS.

```
uci set uhttpd.main.redirect_https=1
uci commit uhttpd
service uhttpd reload
```

==== 3. Native language support ====

LuCI uses English by default. You can search and install additional packages for native language support.

```
opkg update
opkg list luci-i18n-\*
opkg install luci-i18n-hungarian
```

You can also install multiple language packs and switch between them in the LuCI settings.

LuCI is being actively [translated](https://github.com/openwrt/luci/wiki/i18n "https://github.com/openwrt/luci/wiki/i18n") into many languages by volunteers.

==== 4. Additional web applications ====

Search and install `luci-app-*` packages if you want to configure services via LuCI.

```
opkg update
opkg list luci-app-\*
```

#### For releases newer than 24.10, and snapshots

```
apk update
apk add luci
```

Now you can open LuCI interface.

==== 2. Providing encryption ====

Install the required packages.

```
apk update
apk add luci-ssl
/etc/init.d/uhttpd restart
```

Force LuCI to redirect to HTTPS.

```
uci set uhttpd.main.redirect_https=1
uci commit uhttpd
service uhttpd reload
```

==== 3. Native language support ====

LuCI uses English by default. You can search and install additional packages for native language support.

```
apk update
apk search luci-i18n-\*
apk add luci-i18n-hungarian
```

You can also install multiple language packs and switch between them in the LuCI settings.

LuCI is being actively [translated](https://github.com/openwrt/luci/wiki/i18n "https://github.com/openwrt/luci/wiki/i18n") into many languages by volunteers.

==== 4. Additional web applications ====

Search and install `luci-app-*` packages if you want to configure services via LuCI.

```
apk update
apk search luci-app-\*
```

### 5. Alternative ports

Use alternative ports:

- HTTP - 8080/TCP
- HTTPS - 8443/TCP

```
uci -q delete uhttpd.main.listen_http
uci add_list uhttpd.main.listen_http="0.0.0.0:8080"
uci add_list uhttpd.main.listen_http="[::]:8080"
uci -q delete uhttpd.main.listen_https
uci add_list uhttpd.main.listen_https="0.0.0.0:8443"
uci add_list uhttpd.main.listen_https="[::]:8443"
uci commit uhttpd
/etc/init.d/uhttpd restart
```

## Extras

### Details

LuCI by default comes with the bootstrap theme. There are additional themes available or you can create your own if you wish via [luci.themes](/docs/guide-user/luci/luci.themes "docs:guide-user:luci:luci.themes").

LuCI is installed as a 'meta package' which installs several other packages by having these defined as a dependency. Notably, it installs the [uHTTPd](/docs/guide-user/services/webserver/http.uhttpd "docs:guide-user:services:webserver:http.uhttpd") web server, configured for use with LuCI.

In case you want to use uHTTPd, there is little configuration necessary as uHTTPd is configured with CGI to make LuCI work with the Lua interpreter. By default this is organised as follows. By default `/www` is the standard document root. Thus, by requesting this docroot (by pointing your browser to the devices IP address) an index file such as `index.html` is searched for (per uHTTPd settings). The file `/www/index.html` (installed with LuCI) is prepared such that when requested, it redirects you to `/cgi-bin/luci`, which is the default CGI gateway for LuCI. This is just a script, which basically calls Lua at `/usr/bin/lua`. uhttpd is configured by default to load pages as CGI in the `/cgi-bin` path, and thus starts serving these pages with the `/cgi-bin/luci` script.

It is also possible to run LuCI with Lua as an embedded process. uhttpd supports this; see the corresponding section of the [uHTTPd Web Server Configuration](/docs/guide-user/services/webserver/uhttpd#embedded_lua "docs:guide-user:services:webserver:uhttpd") article on the UCI configuration of uhttpd.

### Configuration

- `/etc/config/uhttpd`
- `/etc/config/luci`

### LuCI on other web servers

[webserver](/docs/guide-user/services/webserver/start "docs:guide-user:services:webserver:start")

#### LuCI on lighttpd

[luci.on.lighttpd](/docs/guide-user/luci/luci.on.lighttpd "docs:guide-user:luci:luci.on.lighttpd")

#### LuCI on nginx

For routers without significant space constraints running on snapshots/master or v19 or later, it is possible to install using nginx. LuCI on nginx is currently supported by using uwsgi as plain-cgi interpreter. You need to install one of this 2 variants of the LuCI meta-package:

- [luci-nginx](/packages/pkgdata/luci-nginx "packages:pkgdata:luci-nginx") - Autoinstall nginx, uwsgi-cgi and the default config file to make luci work on nginx.
- [luci-ssl-nginx](/packages/pkgdata/luci-ssl-nginx "packages:pkgdata:luci-ssl-nginx") - Autoinstall nginx-ssl, uwsgi-cgi and the default config file to make luci wok on nginx.

It does also create a self-signed certificate for nginx and redirect http traffic to https by default. Note that even when using nginx, exposing the LuCI interface to the Internet or guest networks is not recommended.

Currently LuCI on nginx is fully supported (maybe only in master snapshots for now, as of 16-Feb-2019). If any problem is found, report them to the [support forum](https://forum.openwrt.org/t/luci-on-nginx-compile/14580 "https://forum.openwrt.org/t/luci-on-nginx-compile/14580").

#### LuCI on BusyBox httpd

If you have a very limited space then you can compile OpenWRT image with [BusyBox httpd](/docs/guide-user/services/webserver/http.httpd "docs:guide-user:services:webserver:http.httpd") instead of uhttpd. LUCI works fine but you'll need some manual configuration. Also this setup is not widely used and tested. If any problem is found, report them to the [support forum](https://forum.openwrt.org/t/luci-on-busybox-httpd/84418 "https://forum.openwrt.org/t/luci-on-busybox-httpd/84418").

### Offline installation

Download the following packages from the [package repository](https://downloads.openwrt.org/releases/18.06.2/targets/ar71xx/generic/packages/ "https://downloads.openwrt.org/releases/18.06.2/targets/ar71xx/generic/packages/") using your platform and release version:

#### Basic

- [liblua](/packages/pkgdata/liblua5.1.5 "packages:pkgdata:liblua5.1.5")
- [libubus](/packages/pkgdata/libubus20220601 "packages:pkgdata:libubus20220601")
- [libubus-lua](/packages/pkgdata/libubus-lua "packages:pkgdata:libubus-lua")
- [libuci-lua](/packages/pkgdata/libuci-lua "packages:pkgdata:libuci-lua")
- [lua](/packages/pkgdata/lua "packages:pkgdata:lua")
- [luci-base](/packages/pkgdata/luci-base "packages:pkgdata:luci-base")
- [luci-lib-ip](/packages/pkgdata/luci-lib-ip "packages:pkgdata:luci-lib-ip")
- [luci-lib-jsonc](/packages/pkgdata/luci-lib-jsonc "packages:pkgdata:luci-lib-jsonc")
- [luci-lib-nixio](/packages/pkgdata/luci-lib-nixio "packages:pkgdata:luci-lib-nixio")
- [luci-mod-admin-full](/packages/pkgdata/luci-mod-admin-full "packages:pkgdata:luci-mod-admin-full")
- [luci-theme-bootstrap](/packages/pkgdata/luci-theme-bootstrap "packages:pkgdata:luci-theme-bootstrap")
- [rpcd](/packages/pkgdata/rpcd "packages:pkgdata:rpcd")
- [uhttpd](/packages/pkgdata/uhttpd "packages:pkgdata:uhttpd")

#### Extended

- [luci](/packages/pkgdata/luci "packages:pkgdata:luci")
- [luci-app-firewall](/packages/pkgdata/luci-app-firewall "packages:pkgdata:luci-app-firewall")
- [luci-app-opkg](/packages/pkgdata/luci-app-opkg "packages:pkgdata:luci-app-opkg")
- [luci-proto-ipv6](/packages/pkgdata/luci-proto-ipv6 "packages:pkgdata:luci-proto-ipv6")
- [luci-proto-ppp](/packages/pkgdata/luci-proto-ppp "packages:pkgdata:luci-proto-ppp")

Transfer the downloaded packages to your router onto the RAM disk and install them.

```
# Upload packages to the router
ssh root@openwrt.lan mkdir -p /tmp/luci-offline
scp *.ipk root@openwrt.lan:/tmp/luci-offline
 
# Install packages
ssh root@openwrt.lan opkg install /tmp/luci-offline/*.ipk
 
# Clean up
ssh root@openwrt.lan rm -f -R /tmp/luci-offline
```

Or use this script bellow. Note, the script assumes you have internet access through the router where you are installing LuCI. If you do not, then you will need to either manually download required `.ipk` packages, or run the script in two parts. First part till the last `done` statement to be executed when connected to the internet:

```
cat << "EOF" > opkg-offline-luci.sh
#!/bin/sh
 
# Exit on error
set -e
 
# Configuration parameters
OWRT_USER="root"
OWRT_HOST="openwrt.lan"
OWRT_TEMP="/tmp/luci-offline"
OWRT_PKGS="libiwinfo20210430 libiwinfo-lua liblua5.1.5 \
liblucihttp0 liblucihttp-lua libubus20220601 libubus-lua \
libuci-lua lua luci-base luci-lib-ip luci-lib-jsonc \
luci-lib-nixio luci-mod-admin-full luci-mod-network \
luci-mod-status luci-mod-system luci-theme-bootstrap \
rpcd uhttpd"
 
# Fetch OpenWrt release
eval $(ssh "${OWRT_USER}@${OWRT_HOST}" cat /etc/os-release)
 
# Fetch LuCI packages
REPO_LOCAL="file://${1:-${OWRT_TEMP}}/"
REPO_URL="https://downloads.${HOME_URL#*//}"
case "${VERSION_ID}" in
(snapshot) REPO_DIR="downloads/snapshots" ;;
(*) REPO_DIR="downloads/releases/${VERSION_ID}" ;;
esac
REPO_CORE="${REPO_DIR}/targets/${OPENWRT_BOARD}"
REPO_PKGS="${REPO_DIR}/packages/${OPENWRT_ARCH}"
for REPO_DIR in "${REPO_CORE}" "${REPO_PKGS}"
do mkdir -p "${REPO_LOCAL#*//}${REPO_DIR#*/}"
rsync -n --bwlimit="8M" --del -r -t -v \
--include="*/" --include-from="-" --exclude="*" \
"${REPO_URL/https/rsync}${REPO_DIR}/" \
"${REPO_LOCAL#*//}${REPO_DIR#*/}/" << EOI
$(echo "${OWRT_PKGS// /$'\n'}" \
| sed -e "s|^|/**/|;s|$|_*.ipk|")
EOI
done
 
# Upload packages to OpenWrt
ssh "${OWRT_USER}@${OWRT_HOST}" "mkdir -p ${OWRT_TEMP}"
find "${OWRT_TEMP}" -name "*.ipk" -exec scp "{}" "${OWRT_USER}@${OWRT_HOST}:${OWRT_TEMP}" ";"
ssh "${OWRT_USER}@${OWRT_HOST}" "opkg install ${OWRT_TEMP}/*.ipk"
ssh "${OWRT_USER}@${OWRT_HOST}" "rm -f -R ${OWRT_TEMP}"
rm -f -R "${OWRT_TEMP}"
EOF
chmod +x opkg-offline-luci.sh
./opkg-offline-luci.sh
```

See also: [Local repository](/docs/guide-user/additional-software/opkg#local_repository "docs:guide-user:additional-software:opkg")

### References

- [LuCI is developed at GitHub](https://github.com/openwrt/luci "https://github.com/openwrt/luci")
- [LuCI issue tracker](https://github.com/openwrt/luci/issues "https://github.com/openwrt/luci/issues")
- [LuCI documentation wiki](https://github.com/openwrt/luci/wiki "https://github.com/openwrt/luci/wiki")
- [Secure access to LuCI via SSH tunnel](/docs/guide-user/luci/luci.secure "docs:guide-user:luci:luci.secure")
- [LuCI technical reference](/docs/techref/luci "docs:techref:luci")
- [LuCI Themes and how to change them](/docs/guide-user/luci/luci.themes "docs:guide-user:luci:luci.themes")
