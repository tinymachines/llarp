# Transmission configuration

There are several implementations of the [bittorrent](/docs/guide-user/services/downloading_and_filesharing/bittorrent "docs:guide-user:services:downloading_and_filesharing:bittorrent") peer-to-peer file sharing protocol. Transmission is only one of them. After installation (`opkg install transmission-daemon`) there should be a config file in the uci directory.

A few more details about configuration file (/etc/config/transmission) can be found [here](https://github.com/transmission/transmission/wiki/Editing-Configuration-Files "https://github.com/transmission/transmission/wiki/Editing-Configuration-Files").

You'll probably need to set up USB support and format your drives for storage first, see the articles [here](/docs/guide-user/storage/usb-drives "docs:guide-user:storage:usb-drives") and [here](/docs/guide-user/storage/start "docs:guide-user:storage:start").

Proxy support was deprecated on version 1.4 and there is no plan to implement it [1)](#fn__1) [2)](#fn__2). You can use [OpenVPN](/docs/guide-user/services/vpn/openvpn/server "docs:guide-user:services:vpn:openvpn:server") as a global solution.

## Install

Component Description `transmission-daemon` A daemon that runs in the background and is designed to not have any form of visual interface, consult [transmission](http://man.cx/transmission "http://man.cx/transmission"). `transmission-cli` To control the transmission daemon via [CLI (Command-line interface)](https://en.wikipedia.org/wiki/Command-line%20interface "https://en.wikipedia.org/wiki/Command-line interface") on the server, consult [transmissioncli](http://man.cx/transmissioncli "http://man.cx/transmissioncli"). `transmission-web` To control the transmission daemon over [HTTP (Hypertext Transfer Protocol)](https://en.wikipedia.org/wiki/Hypertext%20Transfer%20Protocol "https://en.wikipedia.org/wiki/Hypertext Transfer Protocol") from a remote host machine with a web browser. `transmission-remote` To control the transmission daemon over the transmission JSON-[RPC (Remote Procedure Call)](https://en.wikipedia.org/wiki/Remote%20procedure%20call "https://en.wikipedia.org/wiki/Remote procedure call") from a remote host machine with a GUI program, e.g. [transmission-gtk](http://packages.debian.org/testing/transmission-gtk "http://packages.debian.org/testing/transmission-gtk")/[transmission-qt](http://packages.debian.org/testing/transmission-qt "http://packages.debian.org/testing/transmission-qt") or a [python-transmissionrpc](http://packages.debian.org/testing/python-transmissionrpc "http://packages.debian.org/testing/python-transmissionrpc") or [https://sourceforge.net/projects/transgui/](https://sourceforge.net/projects/transgui/ "https://sourceforge.net/projects/transgui/") for OS other then Debian. `luci-app-transmission` [LuCi](/docs/guide-user/luci/start "docs:guide-user:luci:start") web app for configuring the transmission daemon

```
opkg update
opkg install transmission-daemon
opkg install transmission-cli
opkg install transmission-web
opkg install transmission-remote
opkg install luci-app-transmission
```

## Basic setup

To enable Transmission:

```
uci set transmission.@transmission[0].enabled="1"
uci commit transmission
service transmission restart
```

It is recommended to install *luci-app-transmission* to facilitate the configuration via LuCi web interface:

```
opkg install luci-app-transmission
```

### Frontend interfaces

- **Web user interface**: if you wish to use the web server, besides installing the package (see above), you might need to whitelist your IP address (if it is not in 192.168.1.0/24) via `option rpc_whitelist '127.0.0.1,192.168.1.*,your_ip_address`' in the transmission configuration. By default, the server listens on port 9091, eg: `http://192.168.1.1:9091`. See [Web Interface](#web_interface "docs:guide-user:services:downloading_and_filesharing:transmission ↵")  
  [![](/_media/media/doc/transmission-webgui.png?w=400&tok=569514)](/_media/media/doc/transmission-webgui.png "media:doc:transmission-webgui.png")

<!--THE END-->

- **Desktop remote interface**: to control transmission remotely via RPC, install [Transmission Remote GUI](https://github.com/transmission-remote-gui/transgui "https://github.com/transmission-remote-gui/transgui") on your desktop and set it up just like the webserver above. The RPC interface uses the same port as the web interface.  
  [![](/_media/media/doc/transmission-transgui.png?w=400&tok=7b798e)](/_media/media/doc/transmission-transgui.png "media:doc:transmission-transgui.png")

## Advanced setup

To access to all the config options edit the file `/etc/config/transmission`.

You'll probably want to change the config\_dir, download\_dir, and incomplete\_dir variables to point to locations on external storage.

```
config transmission
        option enable 1
        option config_dir '/etc/transmission'
        option alt_speed_down 50
        option alt_speed_enabled false
        option alt_speed_time_begin  540
        option alt_speed_time_day 127
        option alt_speed_time_enabled false
        option alt_speed_time_end 1020
        option alt_speed_up 50
        option bind_address_ipv4 '0.0.0.0'
        option bind_address_ipv6 '::'
        option blocklist_enabled false
        option dht_enabled true
        option download_dir '/mnt/sda4/'
        option encryption 1
        option incomplete_dir '/mnt/sda4/incomplete'
        option incomplete_dir_enabled false
        option lazy_bitfield_enabled true
        option lpd_enabled false
        option message_level 2
        option open_file_limit 32
        option peer_limit_global 240
        option peer_limit_per_torrent 60
        option peer_port 51413
        option peer_port_random_high 65535
        option peer_port_random_low 49152
        option peer_port_random_on_start false
        option peer_socket_tos 0
        option pex_enabled true
        option port_forwarding_enabled false
        option preallocation 1
        option ratio_limit 2.0000
        option ratio_limit_enabled false
        option rename_partial_files true
        option rpc_authentication_required false
        option rpc_bind_address '0.0.0.0'
        option rpc_enabled true
        option rpc_password ''
        option rpc_port 9091
        option rpc_username ''
        option rpc_whitelist '127.0.0.1,192.168.1.*'
        option rpc_whitelist_enabled true
        option script_torrent_done_enabled false
        option script_torrent_done_filename ''
        option speed_limit_down 100
        option speed_limit_down_enabled false
        option speed_limit_up 40
        option speed_limit_up_enabled true
        option start_added_torrents false
        option trash_original_torrent_files false
        option umask 18
        option upload_slots_per_torrent 14
        option watch_dir_enabled false
        option watch_dir ''
```

Extra details can be found [here](https://github.com/transmission/transmission/wiki/Editing-Configuration-Files "https://github.com/transmission/transmission/wiki/Editing-Configuration-Files").

Name Type Required Default Option Description `config_dir` path Where the configuration files are `bind_address_ipv4` IP Address `bind_address_ipv6` IPv6 Address `mem_percentage` integer Maximum percentage of virtual memory it can use `cache-size-mb` integer 2 \[2, ] The cache is used to help batch disk IO together, so increasing the cache size can be used to reduce the number of disk reads and writes. Recomended value (in MB): **RAM/8** `nice` integer 10 \[-20, 19] Set the scheduling priority of the spawned process. [init.d service parameters](/docs/guide-developer/procd-init-scripts#service_parameters "docs:guide-developer:procd-init-scripts") `config_overwrite` boolean 1 \[0, 1] Overwrite the config file in *config\_dir* with contents in this file (/etc/config/transmission) `download_dir` path Where to store you downloaded files `incomplete_dir_enabled` boolean Whether to store incomplete files somewhere else `incomplete_dir` path Where to store files untill they are finished `dht_enabled` boolean Whether to enable dht (distributed hash tables) `blocklist_enabled` boolean Whether to make use of the blocklist defined in *config\_dir* `encryption` integer Whether to use encrypted connections only (allow encryption: 0, prefer encryption: 1, require encryption: 2) `pex_enabled` boolean `speed_limit_down_enabled` boolean Whether transmission should limit its download speed `speed_limit_down` integer in KByte/s `speed_limit_up_enabled` boolean Whether transmission should limit its download speed `speed_limit_up` integer in KByte/s `alt_speed_enabled` boolean Whether transmission should use two speed limit settings `alt_speed_down` integer in KByte/s `alt_speed_up` integer in KByte/s `alt_speed_time_enabled` boolean Whether to switch between the two speed-setting on a time table `alt_speed_time_day` 7-bit bitmask, 0000001=sunday, 1000000=saturday `alt_speed_time_begin` default = 540, in minutes from midnight, 9am `alt_speed_time_end` default = 1020, in minutes from midnight, 5pm `upload_slots_per_torrent` how many peers can download a torrent at a time `open_file_limit` integer remember the low system memory `peer_limit_global` integer the max number of peers globaly `peer_limit_per_torrent` integer the max number of peers with connection per torrent `peer_port` integer the fixed port transmission listens to incomming connections `peer_port_random_high` integer highest port of the port range `peer_port_random_low` integer lowest port of the port range `peer_port_random_on_start` boolean whether to use random ports instead of a fixed one from the beginning `peer_socket_tos` boolean whether `type of service` is enabled `port_forwarding_enabled` boolean `preallocation` boolean whether to fill the space for chunks not yet downloaded with “0” (helps avoiding fragmentation) `ratio_limit_enabled` boolean whether to use a limit ratio `ratio_limit` integer automaticaly stop seeding a torrent when it reaches this ratio (with a GUI you can enable this for every torrent separately) `rename_partial_files` boolean `rpc_enabled` boolean Whether transmission-daemon should be remote controlled by a GUI on a host machine `rpc_bind_address` IP Address the address on which transmission-daemon listens to rpcs `rpc_port` IP Port the port on which transmission-daemon listens to rpcs `rpc_authentication_required` boolean whether rpc needs authentication `rpc_username` string user name `rpc_password` string password `rpc_whitelist_enabled` boolean whether to make use of the whitelist `rpc_whitelist` IP Addresses the IPs of the hosts allowed `watch_dir_enabled` boolean Whether to check a directory for new torrents put there. Leave this disabled It requres inotify enabled in kernel to works, which is not enabled by default in openwrt. `watch_dir` path Path to the directory `script_torrent_done_enabled` boolean `script_torrent_done_filename` `start_added_torrents` boolean `trash_original_torrent_files` `umask` integer Sets file mode creation mask. The mask should be in base 10 due to the json markup language used by Transmission. For instance, the standard umask octal notation `022` is written as `18`. If you want to save downloaded torrents to be world-writable (equivalent to `chmod 777` or `chmod a+rwx`) set this value to `0`. `lazy_bitfield_enabled` boolean `lpd_enabled` boolean `message_level` integer `proxy_enabled` boolean Deprecated on 1.4 whether to use a proxy `proxy` IP address Deprecated on 1.4 IP adress of the proxy `proxy_port` integer Deprecated on 1.4 IP port of the proxy `proxy_type` integer Deprecated on 1.4 Type of the proxy (http: 0, socks4: 1, socks5: 2) `proxy_auth_enabled` boolean Deprecated on 1.4 Whether proxy needs authentication `proxy_auth_username` string Deprecated on 1.4 username for the proxy `proxy_auth_password` string Deprecated on 1.4 password for the proxy

[Reference](https://github.com/transmission/transmission/wiki/Editing-Configuration-Files "https://github.com/transmission/transmission/wiki/Editing-Configuration-Files")

## Web Interface

Install the package transmission-web:

```
opkg install transmission-web
```

To open the web interface just click on the button at the Luci configuration screen:

[![](/_media/media/docs/tranmission-web-open.png?w=600&tok=f90076)](/_detail/media/docs/tranmission-web-open.png?id=docs%3Aguide-user%3Aservices%3Adownloading_and_filesharing%3Atransmission "media:docs:tranmission-web-open.png")

You can use the default web interface, but it is minimalist and lacks some useful functions. Fortunatelly there are alternatives for replacing the default web interface.

### Transmission Web Control

Transmission Web Control is a fully featured Web interface, see [https://github.com/ronggang/transmission-web-control/wiki](https://github.com/ronggang/transmission-web-control/wiki "https://github.com/ronggang/transmission-web-control/wiki")

To install this new web interface:

1. Stop the daemon:
   
   ```
   service transmission stop
   ```
2. Install wget-ssl:
   
   ```
   opkg update
   opkg install wget-ssl
   ```
3. Download the install script:
   
   ```
   cd /tmp
   wget https://github.com/ronggang/transmission-web-control/raw/master/release/install-tr-control.sh --no-check-certificate
   ```
4. Execute the install script:
   
   ```
   chmod +x /tmp/install-tr-control.sh
   sh /tmp/install-tr-control.sh
   ```
5. A menu is shown, choose 1:
   
   ```
           Welcome to the Transmission Web Control Installation Script.
           Official help documentation: https://github.com/ronggang/transmission-web-control/wiki 
           Installation script version: 1.2.3
   
           1. Install the latest release.
           2. Install the specified version.
           3. Revert to the official UI.
           4. Re-download the installation script.
           5. Check if Transmission is started.
           6. Input the Transmission Web directory.
           9. Installing from 'master' Repository.
           ===================
           0. Exit the installation;
   
           Please enter the corresponding number: 1
   ```
6. Start the daemon:
   
   ```
   service transmission start
   ```
7. Done, now you can open the web interface, e.g: `http://192.168.1.1:9091/transmission/web/`

This is the aspect of the new web interface:

[![](/_media/media/doc/tranmission-web-control.png?w=600&tok=32ef16)](/_detail/media/doc/tranmission-web-control.png?id=docs%3Aguide-user%3Aservices%3Adownloading_and_filesharing%3Atransmission "media:doc:tranmission-web-control.png")

## Notes

- Transmission performs much better when [swap](/docs/guide-user/storage/fstab#addingswappartitions "docs:guide-user:storage:fstab") is mounted.
- ```
  # settings.json is created with root permissions by default. It can cause an error:
  # Error: Unable to save resume file: No such file or directory
  # root     root          1818 Dec 27 21:00 settings.json
   
  # this command can help:
  chown transmission:transmission settings.json
   
  #Also you can prevent this error if you set correct permissions for the download directory... Make sure that transmission is the owner of every path that is set in /etc/config/transmission 
  chown -R transmission:transmission /transmission/
  ```
- If you experience a **network throughput drop** in your device after installing Transmission, this is likely caused by the settings at `/etc/sysctl.d/20-transmission.conf`
  
  ```
  # Transmission requests large buffers by default
  net.core.rmem_max = 4194304
  net.core.wmem_max = 1048576
   
  # Some firewalls block SYN packets that are too small
  net.ipv4.tcp_adv_win_scale = 4
  ```
  
  Adjust these parameters or just delete this file and reboot OpenWrt.

## Example

A video demonstration of how Transmission 2.84 can be installed on OpenWrt 14.07 Barrier Breaker: [https://www.youtube.com/watch?v=\_R1Kcpy4pj4](https://www.youtube.com/watch?v=_R1Kcpy4pj4 "https://www.youtube.com/watch?v=_R1Kcpy4pj4") (video removed)

## Scripts

### Add Trackers

A script ([GitHub oilervoss](https://github.com/oilervoss/transmission "https://github.com/oilervoss/transmission")) for adding alternative trackers to the selected torrents filtered by its name or number. The public trackers are retrieved from a dynamical list ([ngosang](https://github.com/ngosang/trackerslist "https://github.com/ngosang/trackerslist")). If the list is offline, it will use a static one.

```
# Show current Torrents
./addtracker
 
# Add public trackers to the Torrents of numbers $somenumber and $othernumber
./addtracker $somenumber $othernumber
 
# Add public trackers to the Torrents found with $anyword or $otherword in the name (case insensitive)
./addtracker $anyword $otherword
 
# Add public trackers to all torrents
./addtracker .
```

## How to activate the external 'done' script on OpenWRT

Since OpenWRT 24.10.x the transmission start to use the 'ujail' process system  
which wrapping/isolating process hierarchy for security  
that not allow any unpermitted(not whitelisted) operation as the docker system's concept.

So that, under the circumstances,  
the external 'done' script treated as 'unknown &amp; unsecure script which potentially danger'.

To avoid this restrict security matter,  
and even want to use own custom shell script,  
need to follow below steps.

***(Be aware, by following below steps at your own risk destorying security protection.***  
***It's totally breaking multi level protection hierarchy that permission, system call filtering, access control that well prepared security.)***

0\. Before performing below steps, you must setup the correct user:group ownership and permissions on the folders where the script needs access to.  
If you don't do this, the script will not be able to run the commands. Troubleshooting will be a lot harder, since you won't know if it is due to the permissions that don't work, or if it is due to issues in the following steps.  
Easiest way to allow the configured external 'done' script after a torrent is done, set the permissions like this to all directories where you reference to in the script:

```
chown -R root:transmission /xxxxx
chmod -R g+rw /xxxxx
```

This is the default user and group configured within the Transmission config file. If you changed that there, apply that accordingly in the example above.

1\. Edit

```
/etc/seccomp/transmission-daemon.json
```

so that the transmission process will not be killed when the script runs. By default, when the script runs, Transmission will crash. The following change in the json, will fix the crash. \\\\Changing the very first line as this

```
"defaultAction": "SCMP_ACT_LOG"
```

.

2\. Open up

```
/etc/init.d/transmission
```

to edit(nano, vim what ever you want).  
To allow access the external 'done' script, you need to specify/add the 'ujail'([Syntax](/docs/guide-developer/procd-init-scripts#service_jails "docs:guide-developer:procd-init-scripts")) in the script by following steps.

3\. Around the line number 78 or somewhere(where around the line

```
local seccomp_path
```

) you need to add below.

```
local script_torrent_done_filename
config_get script_torrent_done_filename "$cfg" 'script_torrent_done_filename' '$config_dir/done.sh'
```

4\. After adding above the step three,  
Go to line number around 174  
where right after the line

```
procd_add_jail_mount_rw "$config_dir/stats.json"
```

5\. From now, add whatever folder and files which you need as below syntax(study 'ujail'([Syntax](/docs/guide-developer/procd-init-scripts#service_jails "docs:guide-developer:procd-init-scripts"))).  
This step below is one of example.

```
procd_add_jail_mount_rw "/tmp"
procd_add_jail_mount "/bin"
procd_add_jail_mount "/usr/bin"
procd_add_jail_mount "/usr/lib"
procd_add_jail_mount "/usr/lib/sudo"
procd_add_jail_mount "/etc"
procd_add_jail_mount_rw "/var/run/some_script.lock"
procd_add_jail_mount_rw "$config_dir/settings.json"
procd_add_jail_mount "$script_torrent_done_filename"
procd_add_jail_mount_rw "/dev/null"
procd_add_jail_mount "/etc/config"
```

You will need to find what directory actually need to access by checking

```
logread
```

.  
The log will tell you what program access denied and where. Start a torrent, check the log and again repeat. you will find all of set where you need to access.  
If cannot see appropriate logs, set the transmission log level in the transmission config/web ui.

```
Message level : 'Debug'
```

would be right.

6\. Do

```
service transmission restart
```

. (service transmission Reload not working. some of variable not even flushed.)

7\. Enjoy.

[1)](#fnt__1)

[https://github.com/transmission/transmission/wiki/Editing-Configuration-Files#14x-and-older](https://github.com/transmission/transmission/wiki/Editing-Configuration-Files#14x-and-older "https://github.com/transmission/transmission/wiki/Editing-Configuration-Files#14x-and-older")

[2)](#fnt__2)

[https://github.com/transmission/transmission/issues/344](https://github.com/transmission/transmission/issues/344 "https://github.com/transmission/transmission/issues/344")
