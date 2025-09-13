# System configuration /etc/config/system

The system UCI subsystem configuration file is located in `/etc/config/system`. The default settings are:

```
config system
	option hostname 'OpenWrt'
	option timezone 'UTC'
	option ttylogin '0'
	option log_size '64'
	option urandom_seed '0'
 
config timeserver 'ntp'
	option enabled '1'
	option enable_server '0'
	list server '0.openwrt.pool.ntp.org'
	list server '1.openwrt.pool.ntp.org'
	list server '2.openwrt.pool.ntp.org'
	list server '3.openwrt.pool.ntp.org'
```

## System section

The `system` section contains settings that apply to the most basic operation of the system, such as the hostname, the time zone, and how and where to write logging information to. These options can be set in the system section:

Name Type Required Default Description `hostname` string no `OpenWrt` The hostname for this system. Avoid points, even if they are within quotes. For example ' `my.hostname` ' will show only the ' `my` ' part `description` string no *(none)* A short, single-line description for this system. It should be suitable for human consumption in user interfaces, such as LuCI, selector UIs in remote administration applications, or remote UCI (over ubus RPC). `notes` string no *(none)* A multi-line, free-form text field about this system that can be used in any way the user wishes, e.g. to hold installation notes, or unit serial number and inventory number, location, etc. `buffersize` integer no kernel specific Size of the kernel message buffer. `conloglevel` integer no `7` Number between 1-8. The maximum log level for kernel messages to be logged to the console. Only messages with a level lower than this will be printed to the console. Higher level messages have lower log level number. Highest level messages are ones with log level 0. If you want more verbose messages in console put conloglevel to 8 if you want less messages lower conloglevel to 4 or even less. This option and similar parameters [may not be effective](https://forum.openwrt.org/t/logd-doesnt-honor-conloglevel-17-01-4-r3560-79f57e422d/8196 "https://forum.openwrt.org/t/logd-doesnt-honor-conloglevel-17-01-4-r3560-79f57e422d/8196") since 17.x and later. `cronloglevel` integer no `5` The minimum level for cron messages to be logged to syslog. `0` will print all debug messages, `8` will log command executions, and `9` or higher will only log error messages. `klogconloglevel` integer no `7` The maximum log level for kernel messages to be logged to the console. Only messages with a level lower than this will be printed to the console. Identical to `conloglevel` and will override it. `log_buffer_size` integer no *(none)* Size of the log buffer of the procd based system log, that is accessible via the `logread` command. Defaults to the value of `log_size` if unset. `log_file` string no no log file File to write log messages to (type `file`). The default is to not write a log in a file. The most often used location for a system log file is `/var/log/messages`. `log_hostname` string no *(none)* Hostname to send to remote syslog. If none is provided, the actual hostname is send. This feature is only present in 17.xx and later versions `log_ip` IP address no *(none)* IP address of a syslog server to which the log messages should be sent in addition to the local destination. `log_port` integer no `514` Port number of the remote syslog server specified with `log_ip`. `log_prefix` string no *(none)* Adds a prefix to all log messages send over network. `log_proto` string no `udp` Sets the protocol to use for the connection, either `tcp` or `udp`. `log_remote` bool no `1` Enables remote logging. `log_size` integer no `64` Size of the file based log buffer in KiB (see `log_file`). This value is used as the fallback value for `log_buffer_size` if the latter is not specified. `log_trailer_null` bool no `0` Use `\0` instead of `\n` as trailer when using TCP. `log_type` string no `circular` Either `circular` or `file`. The `circular` option is a fixed size queue in memory, while the file is a dynamically sized file, that can be in memory, or written to disk. **Note**: If `log_type` is set to file, then at some point when the log fills, the device may encounter an out-of-space condition. This is especially an issue for devices with limited onboard storage: in memory, or on flash. `ttylogin` bool no `0` Require authentication for local users to log in the system. Disabled by default. It applies to the access methods listed in `/etc/inittab`, such as keyboard and serial. `urandom_seed` string no `0` Path of the seed. Enables saving a new seed on each boot. `timezone` string no `UTC` *POSIX.1 time zone* string corresponding to the time zone in which date and time should be displayed by default. See [timezone database](https://github.com/openwrt/luci/blob/master/modules/luci-lua-runtime/luasrc/sys/zoneinfo/tzdata.lua "https://github.com/openwrt/luci/blob/master/modules/luci-lua-runtime/luasrc/sys/zoneinfo/tzdata.lua") for a mapping between IANA/Olson and POSIX.1 formats. (For London this corresponds to `GMT0BST,M3.5.0/1,M10.5.0`) `zonename` string no `UTC` *IANA/Olson time zone* string. If `zoneinfo-*` packages are present, possible values can be found by running `find /usr/share/zoneinfo`. See [timezone database](https://github.com/openwrt/luci/blob/master/modules/luci-lua-runtime/luasrc/sys/zoneinfo/tzdata.lua "https://github.com/openwrt/luci/blob/master/modules/luci-lua-runtime/luasrc/sys/zoneinfo/tzdata.lua") for a mapping between IANA/Olson and POSIX.1 formats. (For London this corresponds to `Europe/London`) `zram_comp_algo` string no `lzo` Compression algorithm to use for ZRAM, can be one of `lzo`, `lzo-rle`, `lz4`, `zstd` `zram_size_mb` integer no Ramsize in kB divided by 2048 Size of ZRAM in MB

## Extras

### Daylight saving time

Reload kernel timezone to properly apply [DST](https://en.wikipedia.org/wiki/Daylight_saving_time "https://en.wikipedia.org/wiki/Daylight_saving_time").

```
cat << "EOF" >> /etc/crontabs/root
0 0 * * * service system restart
EOF
uci set system.@system[0].cronloglevel="9"
uci commit system
service cron restart
```
