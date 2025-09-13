# uShare configuration

There are several implementations of the UPnP protocol. The uShare server is one of the best candidates for use with a PlayStation 3 or Xbox 360 for sharing music or video.

## Install

```
opkg update
opkg install ushare
```

## Sections

There is only one section `ushare` defined for the configuration in `/etc/config/ushare`.

### uShare

Example entry to have a functional UPnP server working with a PlayStation 3.

```
config 'ushare'
        option 'content_directories' '/mnt/usb-drive,/mnt/fileserver'
        option 'disable_telnet'      '1'
        option 'disable_webif'       '0'
        option 'options'             '-p 8010 -d'
```

The following options are defined for the `ushare` section:

Name Type Required Default CLI option Description `enabled` boolean no `1` *n/a* Disable the uShare instance if set to `0` `username` string no `nobody` *n/a* Specifies the user account uShare is running with `servername` string no `OpenWrt` `-n` Specifies the network name of the UPnP server `interface` string no `br-lan` `-i` Specifies the interfaces uShare is listening on `content_directories` list of directory paths yes `/tmp` `-c` Comma separated (!) list of directories to share `disable_telnet` boolean no `0` `-t` Disables Telnet access to uShare if set to `1` `disable_webif` boolean no `0` `-w` Disables HTTP access to uShare if set to `1` `options` string no *none* *n/a* Additional command line args passed to uShare

Additional useful command line args for use with `options` are listed below.

CLI option Description `-d` Use DLNA compliant profile (PlayStation3 needs this sometimes) `-x` Use Xbox 360 compliant profile `-p port` Serve HTTP on given port `-q port` Serve Telnet on given port

See also uShare command line args [full list](http://ushare.geexbox.org/#Usage "http://ushare.geexbox.org/#Usage").
