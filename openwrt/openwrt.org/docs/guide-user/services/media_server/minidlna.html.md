# MiniDLNA

MiniDLNA is a lightweight DLNA/UPnP media server. The MiniDNLA daemon serves media files (music, pictures, and video) to clients on a network.

### Installation

```
opkg update
opkg install minidlna
```

### Configuration

Edit one of the following files depending on your miniDLNA Version:

```
/etc/minidlna.conf
/etc/config/minidlna.conf
/tmp/minidlna.conf
```

```
#------------------------------------------------------#
# port for HTTP (descriptions, SOAP, media transfer) traffic
#------------------------------------------------------#
port=8200
 
#------------------------------------------------------#
# network interfaces to serve, comma delimited
#------------------------------------------------------#
network_interface=br-lan
 
#------------------------------------------------------#
# set this to the directory you want scanned.
# * if have multiple directories, you can have multiple media_dir= lines
# * if you want to restrict a media_dir to a specific content type, you
#   can prepend the type, followed by a comma, to the directory:
#   + "A" for audio  (eg. media_dir=A,/home/jmaggard/Music)
#   + "V" for video  (eg. media_dir=V,/home/jmaggard/Videos)
#   + "P" for images (eg. media_dir=P,/home/jmaggard/Pictures)
#------------------------------------------------------#
# Directory of media is depend on your storage
#------------------------------------------------------#
media_dir=A,/mnt/sda1/music
media_dir=P,/mnt/sda1/picture
media_dir=V,/mnt/sda1/video
#------------------------------------------------------#
# set this if you want to customize the name that shows up on your clients
#------------------------------------------------------#
friendly_name=My DLNA Server
 
#------------------------------------------------------#
# set this if you would like to specify the directory where you want MiniDLNA to store its database and album art cache
#------------------------------------------------------#
db_dir=/mnt/sda1/minidlna/db
 
#------------------------------------------------------#
# set this if you would like to specify the directory where you want MiniDLNA to store its log file
#------------------------------------------------------#
log_dir=/mnt/sda1/minidlna/log
 
#------------------------------------------------------#
# this should be a list of file names to check for when searching for album art
# note: names should be delimited with a forward slash ("/")
#------------------------------------------------------#
album_art_names=Cover.jpg/cover.jpg/AlbumArtSmall.jpg/albumartsmall.jpg/AlbumArt.jpg/albumart.jpg/Album.jpg/album.jpg/Folder.jpg/folder.jpg/Thumb.jpg/thumb.jpg
 
#------------------------------------------------------#
# set this to no to disable inotify monitoring to automatically discover new files
# note: the default is yes
#------------------------------------------------------#
inotify=yes
 
#------------------------------------------------------#
# set this to yes to enable support for streaming .jpg and .mp3 files to a TiVo supporting HMO
#------------------------------------------------------#
enable_tivo=no
 
#------------------------------------------------------#
# set this to strictly adhere to DLNA standards.
# * This will allow server-side downscaling of very large JPEG images,
#   which may hurt JPEG serving performance on (at least) Sony DLNA products.
#------------------------------------------------------#
strict_dlna=no
 
#------------------------------------------------------#
# default presentation url is http address on port 80
#------------------------------------------------------#
presentation_url=http://192.168.1.1:8200/
 
#------------------------------------------------------#
# notify interval in seconds. default is 895 seconds.
#------------------------------------------------------#
notify_interval=900
 
#------------------------------------------------------#
# serial and model number the daemon will report to clients
# in its XML description
#------------------------------------------------------#
serial=12345678
model_number=1
 
#------------------------------------------------------#
# specify the path to the MiniSSDPd socket
#------------------------------------------------------#
#minissdpdsocket=/var/run/minissdpd.sock
 
#------------------------------------------------------#
# use different container as root of the tree
# possible values:
#   + "." - use standard container (this is the default)
#   + "B" - "Browse Directory"
#   + "M" - "Music"
#   + "V" - "Video"
#   + "P" - "Pictures"
# if you specify "B" and client device is audio-only then "Music/Folders" will be used as root
#------------------------------------------------------#
#root_container=.
```

### Configuration (uci)

This describes the configuration options in `/etc/config/minidlna`.

![FIXME](/lib/images/smileys/fixme.svg) This is just an initial dump of all the options I found, I am not certain about any other options or their actual meaning!

![FIXME](/lib/images/smileys/fixme.svg) I just guessed the Type entries. --- *hcc23 2013/02/21 02:02*

Name Type Required Default Description `enabled` boolean ??? 0 `port` string ??? 8200 port for HTTP (descriptions, SOAP, media transfer) traffic `interface` string ??? br-lan network interfaces to serve; comma (`,`) delimited `friendly_name` string no (*none*) set this if you want to customize the name that shows up on your clients `db_dir` string no /var/run/minidlna set this if you would like to specify the directory where you want MiniDLNA to store its database and album art cache `log_dir` string no /var/log set this if you would like to specify the directory where you want MiniDLNA to store its log file `inotify` boolean no 1 set this to no to disable inotify monitoring to automatically discover new files `enable_tivo` boolean no 0 set this to yes to enable support for streaming .jpg and .mp3 files to a TiVo supporting HMO `strict_dlna` boolean ??? 0 strictly adhere to DLNA standards; This will allow server-side down-scaling of very large JPEG images, which may hurt JPEG serving performance on (at least) Sony DLNA products. `notify_interval` integer no 895 notify interval in seconds `serial` integer ??? 12345678 model number the daemon will report to clients in its XML description `model_number` integer ??? 1 model number the daemon will report to clients in its XML description `root_container` `.`,`B`,`M`,`V`,`P` no `.` container for the tree root; `.`: default, `B`:browse directory, `M`:music, `V`:video, `P`:pictures `media_dir` string ??? /mnt set this to the directory you want scanned;if have multiple directories, you can have multiple `media_dir` lines; if you want to restrict a media\_dir to a specific content type, you can prepend the type, followed by a comma, to the directory: `A` for audio (eg. `A,/home/jmaggard/Music`)`V` for video, `P` for pictures; if you specify `B` and client device is audio-only then “Music/Folders” will be used as root `album_art_names` string no Cover.jpg/  
cover.jpg/  
AlbumArtSmall.jpg/  
albumartsmall.jpg/  
AlbumArt.jpg/  
albumart.jpg/  
Album.jpg/  
album.jpg/  
Folder.jpg/  
folder.jpg a list of file names to check when searching for album art; `/` delimited `presentation_url` string ??? default presentation url is http address on port 80 `minisdpdsocket` string ??? specify the path to the MiniSSDPd socket

### Notes

MiniDLNA's inotify support may not work as expected when trying to watch on an overlayfs filesystem. In the case of extroot, e.g. you can watch on `/overlay/root/minidlna` instead of `/root/minidlna`.

### Reference:

- [Comparison of UPnP AV media servers](https://en.wikipedia.org/wiki/Comparison%20of%20UPnP%20AV%20media%20servers "https://en.wikipedia.org/wiki/Comparison of UPnP AV media servers")
- [https://wiki.archlinux.org/index.php/Minidlna](https://wiki.archlinux.org/index.php/Minidlna "https://wiki.archlinux.org/index.php/Minidlna")
- [http://wiki.ubuntuusers.de/MiniDLNA](http://wiki.ubuntuusers.de/MiniDLNA "http://wiki.ubuntuusers.de/MiniDLNA")
- The package has uci-support since [R31211](https://dev.openwrt.org/changeset/31211/packages "https://dev.openwrt.org/changeset/31211/packages").

## Example

A video demonstration of how MiniDLNA 1.1.3-1 in the repositories can be installed on OpenWrt 14.07 Barrier Breaker: [https://www.youtube.com/watch?v=-vU2zOw6ga0](https://www.youtube.com/watch?v=-vU2zOw6ga0 "https://www.youtube.com/watch?v=-vU2zOw6ga0")

## Tips

If you have a decent size music library, you will more than likely find building the minidlna database on your OpenWrt device extremely slow or impossible due to RAM constraints. The solution is to build the minidlna database on a Linux PC.

```
# Create a directory on your OpenWrt hard or flash drive to hold the minidlna log and database files
mkdir /mnt/hdd/minidlna
 
# Configure minidlna to put database and log file on the hard or flash drive connected to your OpenWrt device
uci set minidlna.@minidlna[0].option.inotify="0"
uci set minidlna.@minidlna[0].db_dir="/mnt/hdd/minidlna"
uci set minidlna.@minidlna[0].log_dir="/mnt/hdd/minidlna"
uci add_list minidlna.@minidlna[0].media_dir="A,/mnt/hdd/media"
uci commit minidlna
 
# Create a minidlna configuration file on the hard or flash drive connected to your OpenWrt device
cat << EOF > cp_minidlna_conf.sh
#!/bin/sh
 
source /lib/functions.sh
 
minidlna_cfg_append() {
	echo "$1" 
}
 
minidlna_cfg_addbool() {
	local cfg="$1"
	local key="$2"
	local def="$3"
	local val
 
	config_get_bool val "$cfg" "$key" "$def"
	[ "$val" -gt 0 ] && val="yes" || val="no"
	minidlna_cfg_append "$key=$val"
}
 
minidlna_cfg_addstr() {
	local cfg="$1"
	local key="$2"
	local def="$3"
	local val
 
	config_get val "$cfg" "$key" "$def"
	[ -n "$val" ] && minidlna_cfg_append "$key=$val"
}
 
minidlna_cfg_add_media_dir() {
	local val="$1"
 
	minidlna_cfg_append "media_dir=$val"
}
 
minidlna_create_config() {
	local cfg="$1"
	local port
	local interface
 
	config_get port "$cfg" port
	config_get interface "$cfg" interface
 
	[ -z "$interface" -o -t "$port" ] && return 1
 
	echo "# this file is generated automatically, don't edit" 
 
	minidlna_cfg_append "port=$port"
	minidlna_cfg_append "network_interface=$interface"
 
	minidlna_cfg_addstr "$cfg" friendly_name
	minidlna_cfg_addstr "$cfg" db_dir
	minidlna_cfg_addstr "$cfg" log_dir
	minidlna_cfg_addbool "$cfg" inotify "1"
	minidlna_cfg_addbool "$cfg" enable_tivo "0"
	minidlna_cfg_addbool "$cfg" strict_dlna "0"
	minidlna_cfg_addstr "$cfg" album_art_names
	minidlna_cfg_addstr "$cfg" presentation_url
	minidlna_cfg_addstr "$cfg" notify_interval "900"
	minidlna_cfg_addstr "$cfg" serial "12345678"
	minidlna_cfg_addstr "$cfg" model_number "1"
	minidlna_cfg_addstr "$cfg" minissdpsocket
	minidlna_cfg_addstr "$cfg" root_container "."
	config_list_foreach "$cfg" media_dir minidlna_cfg_add_media_dir
 
	return 0
}
 
config_load minidlna
 
minidlna_create_config config
EOF
 
chmod +x cp_minidlna_conf.sh
./cp_minidlna_conf.sh > /mnt/hdd/minidlna/minidlna.conf
 
# Remove the hard or flash drive from the OpenWrt device and connect it to your Linux PC
block umount
 
# Build the minidlna database on a Linux PC with http://sourceforge.net/projects/minidlna/files/minidlna/1.1.4/
minidlnad -d -R -v -f /mnt/hdd/minidlna/minidlna.conf
 
# Remove the hard or flash drive from your Linux PC and reconnect to your OpenWrt device
block mount
```

[![](/_media/meta/icons/tango/48px-dialog-warning.svg.png)](/_detail/meta/icons/tango/48px-dialog-warning.svg.png?id=docs%3Aguide-user%3Aservices%3Amedia_server%3Aminidlna "meta:icons:tango:48px-dialog-warning.svg.png") Ensure that the Linux PC portable hard or flash drive mount point is **exactly** the same as the OpenWrt hard or flash drive mount point. Otherwise, the OpenWrt minidlna will delete and rescan the database you generated on the PC since the paths don't match

This method has been tested with an Openwrt device with 32MB of RAM and a music library of over 11,000 songs. You may also want to add [swap](/docs/guide-user/storage/fstab#adding_swap_partitions "docs:guide-user:storage:fstab") if you are running low on memory.
