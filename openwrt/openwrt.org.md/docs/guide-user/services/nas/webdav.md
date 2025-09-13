# WebDAV Share

[WebDAV](https://en.wikipedia.org/wiki/WebDAV "https://en.wikipedia.org/wiki/WebDAV") is an HTTP based file transfer protocol. It's integrated into Windows, GNOME, KDE and many programs for backups, file sharing and media players.

It's installed as a plugin for a web server. Unfortunately OpenWrt's uhttpd doesn't support it. If you have enough space you can install [Lighttpd webserver](/docs/guide-user/services/webserver/lighttpd "docs:guide-user:services:webserver:lighttpd") and configure WebDAV share.

### WebDAV with Lighttpd

If don't have yet the Lighttpd install it:

```
opkg install lighttpd
```

If you didn't uninstalled the default `ughttpd` webserver you should change the Lighttpd port to avoid conflicts e.g. for the HTTP set to 2080 and for the HTTPS set port to 2443. In the `/etc/lighttpd/lighttpd.conf` by the `server.port = 2080`. For the TLS you better to create a separate file `/etc/lighttpd/conf.d/40-tls-enable_custom.conf`:

[/etc/lighttpd/conf.d/40-tls-enable\_custom.conf](/_export/code/docs/guide-user/services/nas/webdav?codeblock=1 "Download Snippet")

```
$SERVER["socket"] == ":2443" {
  ssl.engine = "enable"
}

$SERVER["socket"] == "[::]:2443" {
  ssl.engine = "enable"
}
```

If you already have the Lighttpd that is used by a firmware then update it and it's modules to avoid conflicts:

```
opkg update
opkg list-upgradable | cut -f 1 -d ' ' | grep lighttpd | xargs opkg upgrade
```

Install the Basic Auth and WebDAV modules:

```
opkg install lighttpd-mod-auth lighttpd-mod-authn_file lighttpd-mod-webdav
```

Assuming that USB drive is mounted to `/mnt/disk/` folder:

```
mkdir -p /mnt/disk/dav /var/lib/lighttpd
chown http:www-data /mnt/disk/dav /var/lib/lighttpd
cat << "EOF" > /etc/lighttpd/conf.d/99-disk.conf
$HTTP["url"] =~ "^/dav($|/)" {
  server.document-root := "/mnt/disk/"
  auth.backend = "plain"
  auth.backend.plain.userfile = "/etc/lighttpd/webdav.shadow"
  auth.require = (
    "/dav/" => ("method" => "basic", "realm" => "disk", "require" => "valid-user")
  )
  auth.cache = ("max-age" => "3600")
}
EOF
```

Now set a password:

```
echo "youruser:somesecret" > /etc/lighttpd/webdav.shadow
```

**Note:** your secret is not encoded and saved on router in clear text for a better performance. If a hacker get access to the file it can see your password. So don't put here a password that you are using anywhere else. Just generate a new one for example with the command:

```
< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32}; echo
```

And finally restart Lighttpd:

```
/etc/init.d/lighttpd restart
```

### Troubleshooting

If you got the error:

```
(../src/mod_webdav.c.1327) sqlite3_open() '/var/lib/lighttpd/webdav.db': unable to open database file
(../src/server.c.1943) Configuration of plugins failed. Going down.
```

Then you need to create the file manually with `touch /var/lib/lighttpd/webdav.db`.

To test configuration use `lighttpd -tt -f /etc/lighttpd/lighttpd.conf`.

### Test it

Open in a browser [http://192.168.1.1/dav/](http://192.168.1.1/dav/ "http://192.168.1.1/dav/") and you'll be prompted for credentials. After login you'll see a directory listing but this not yet a WebDAV, just an additional feature.

To connect to WebDAV see [Accessing WebDAV Server](https://www.webdavsystem.com/server/access/ "https://www.webdavsystem.com/server/access/").

A quick test can be done with a `curl` (replace the `youruser`):

```
curl -u youruser:pass -X PROPFIND -H 'Depth: 1' http://192.168.1.1/dav/
```

You must see a 207 status code and XML response with directory listing.

See more details and examples [WebDAV with curl](https://gist.github.com/stokito/cf82ce965718ce87f36b78f7501d7940 "https://gist.github.com/stokito/cf82ce965718ce87f36b78f7501d7940")

### Don't forget about encryption!

Please note that you must configure HTTPS if you are going to access your files from internet. You'll need to [get a TLS certificate](/docs/guide-user/services/tls/certs "docs:guide-user:services:tls:certs") and [configure lighttpd for HTTPS](https://redmine.lighttpd.net/projects/lighttpd/wiki/Docs_SSL "https://redmine.lighttpd.net/projects/lighttpd/wiki/Docs_SSL")

### Browser UI for the WebDAV share

As with usual HTTP you can see (GET) any file directly from a browser but you can't see a listing of files in a folder. That's because for a listing is used a PROPFIND method but not just GET. But you can install a [browser extension](https://github.com/stokito/webdav-browser-extension "https://github.com/stokito/webdav-browser-extension") or more advanced [app](https://chrome.google.com/webstore/detail/file-management-webdav/famepaffkmmhdefbapbadnniioekdppm "https://chrome.google.com/webstore/detail/file-management-webdav/famepaffkmmhdefbapbadnniioekdppm").

But a better is to install the small and nice UI [webdav-js](https://github.com/dom111/webdav-js "https://github.com/dom111/webdav-js"). Just create a file in dav folder's root \`/mnt/disk/dav/index.html\`

```
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>WebDAV</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/dom111/webdav-js/assets/css/style-min.css"/>
</head>
<body>
<script src="https://cdn.jsdelivr.net/gh/dom111/webdav-js/src/webdav-min.js"></script>
</body>
</html>
```

Then open [http://192.168.1.1/dav/](http://192.168.1.1/dav/ "http://192.168.1.1/dav/") and you'll see a simple file manager. Internally it performs all webdav operations with AJAX e.g. sends a PROPFIND to list files.

To set it up so you don't have to add this \`index.html\` to every directory, modify \`/etc/lighttpd/conf.d/99-disk.conf\` to add the last two lines to enable directory listing and use index.html on every directory.

```
$HTTP["url"] =~ "^/dav($|/)" {
  server.document-root := "/mnt/disk/"
  auth.backend = "plain"
  auth.backend.plain.userfile = "/etc/lighttpd/webdav.shadow"
  auth.require = (
    "/dav/" => ("method" => "basic", "realm" => "disk", "require" => "valid-user")
  )
  auth.cache = ("max-age" => "3600")
  
  # Enable directory listing to see folders
  dir-listing.activate = "enable"
  index-file.names = ( "index.html" )
} 
```

### Online apps and PWAs

You can also try an online apps that can connect directly to your WebDAV share to backup data. Some notable apps:

- [Diffuse](https://diffuse.sh/ "https://diffuse.sh/") a music player [Source code](https://github.com/icidasset/diffuse "https://github.com/icidasset/diffuse")
- [Supper Productivity](https://app.super-productivity.com/ "https://app.super-productivity.com/") a powerful TODO App. [Source code](https://github.com/johannesjo/super-productivity "https://github.com/johannesjo/super-productivity")
- [Buttercup](https://buttercup.pw/ "https://buttercup.pw/") a password manager as a browser extension.
- [KeeWeb](https://app.keeweb.info/ "https://app.keeweb.info/") a password manager as PWA

To allow online apps to connect with your WebDAV it need a CORS enabled. Here is an example [https://gist.github.com/stokito/0a6274106d407ba6d9fb776e7773445d](https://gist.github.com/stokito/0a6274106d407ba6d9fb776e7773445d "https://gist.github.com/stokito/0a6274106d407ba6d9fb776e7773445d")

### Useful Apps

Useful mobile apps that supports WebDAV sync:

- [Orgzly](https://www.orgzly.com/ "https://www.orgzly.com/") - Outliner for notes and to-do lists. [Source code](https://github.com/orgzly "https://github.com/orgzly")
- [CloudBeats](https://www.cloudbeatsapp.com/ "https://www.cloudbeatsapp.com/") - a music player. Proprietary.
- [EasySync](https://github.com/phpbg/easysync "https://github.com/phpbg/easysync") - two way synchronization of images, videos, audio and downloads.
- [FolderSync](https://play.google.com/store/apps/details?id=dk.tacit.android.foldersync.lite "https://play.google.com/store/apps/details?id=dk.tacit.android.foldersync.lite") - a backup and sync e.g. you can upload photos automatically. Proprietary.

### Links and docs

- [Module mod\_auth - Using authentication](https://redmine.lighttpd.net/projects/1/wiki/docs_modauth "https://redmine.lighttpd.net/projects/1/wiki/docs_modauth")
- [Module mod\_webdav - WebDAV](https://redmine.lighttpd.net/projects/1/wiki/Docs_ModWebDAV "https://redmine.lighttpd.net/projects/1/wiki/Docs_ModWebDAV")
- [Module mod\_secdownload - Secure and fast downloading](https://redmine.lighttpd.net/projects/1/wiki/Docs_ModSecDownload "https://redmine.lighttpd.net/projects/1/wiki/Docs_ModSecDownload")
- [Awesome WebDAV](https://github.com/webdavdevs/awesome-webdav "https://github.com/webdavdevs/awesome-webdav") a list of software that works with WebDAV.
- [WebDAV with Lighttpd on Turris Omnia (TurrisOS)](https://gist.github.com/stokito/77c42f8aff2dade91621c1051f73e58c "https://gist.github.com/stokito/77c42f8aff2dade91621c1051f73e58c")
- [openwrt-lighttpd-public](https://github.com/yurt-page/openwrt-lighttpd-public "https://github.com/yurt-page/openwrt-lighttpd-public") OpenWrt configuration for Lighttpd with WebDAV and autosharing

### ZeroConf autodiscovery

You can advertise a WebDAV share with [umdns](/docs/guide-developer/mdns "docs:guide-developer:mdns"). Then it will be seen in Network folder of a file manager in GNOME and KDE and can be [discovered from a Kodi media player](https://kodi.wiki/view/Avahi_Zeroconf "https://kodi.wiki/view/Avahi_Zeroconf").

Install the umdns package with `opkg install umdns` and create a service description file:

[/etc/umdns/lighttpd\_webdav.json](/_export/code/docs/guide-user/services/nas/webdav?codeblock=12 "Download Snippet")

```
{
  "lighttpd_webdav": {
    "service": "_webdav._tcp.local",
    "port": 80,
    "txt": [
      "path=/dav/",
      "u=media"
    ]
  }
}
```

The reload the umdns service with: `ubus call umdns reload` or `service umdns reload`.
