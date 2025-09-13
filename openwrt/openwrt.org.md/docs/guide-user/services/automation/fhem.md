# FHEM on OpenWrt

## Introduction

FHEM is a software, written in perl, which enables you to manage (eg. EVL) home automation devices over a Webinterface, with the Help of a radio transmitting USB Stick (CUL/CUN). As an alternative to USB Transmitters/Receivers LAN-devices can be used (CUNO/HM-CFG-LAN). I installed it on a Buffalo WZR-HP-AG300H, which has plenty of memory and storage. You might have to install it on an [external usb storage](/docs/guide-user/storage/usb-drives "docs:guide-user:storage:usb-drives") or make a swapfile on the usb drive.

## Installation

### Basic Packages

#### Update Packages List

First update your Sources.

```
opkg update
```

#### Required Packages

Get some required Packages to use the USB Port, the Serial to USB Tool (ser2net) and perl.

```
opkg install tar perl perlbase-autoloader perlbase-config perlbase-dynaloader perlbase-errno perlbase-essential perlbase-fcntl perlbase-file perlbase-io perlbase-math perlbase-posix perlbase-selectsaver perlbase-socket perlbase-symbol perlbase-tie perlbase-time perlbase-xsloader perlbase-mime perlbase-digest perlbase-scalar ser2net kmod-usb-serial kmod-usb-serial-ftdi kmod-usb-acm
```

#### Install FHEM

Load and install fhem. Replace the Version in the wget command, if you want to try another [fhem Version](http://fhem.de/fhem.html#Download "http://fhem.de/fhem.html#Download"). Unzip the archive. Copy the fhem.pl to /usr/sbin and the Rest to /usr/lib/fhem. The default config file that comes with the archive is best placed in /etc/config/fhem/fhem.cfg. At last we create a log directory for fhem in /var/log/fhem. Please bear in mind that /var/log is reset upon every reboot. Thus fhem will complain about missing log-files. This can be resolved by changing the log-path to something else for example external storage /mnt/sda1.

```
cd /tmp
wget http://fhem.de/fhem-5.5.tar.gz
tar xvfz fhem-5.5.tar.gz
cd fhem-5.5
cp fhem.pl /usr/sbin
mkdir -p /usr/lib/fhem
cp -R * /usr/lib/fhem
mkdir -p /etc/config/fhem
cp fhem.cfg /etc/config/fhem
mkdir -p /var/log/fhem
```

Configure the virtual serial Port in /etc/ser2net.conf

- You should find the device via lsusb and the Port in /dev (try eg. /dev/ttyUSB0)

Comment out all ports you don't need. Portnumber is the first one.

[/etc/ser2net.conf](/_export/code/docs/guide-user/services/automation/fhem?codeblock=3 "Download Snippet")

```
27073:raw:300:/dev/ttyACM0:115200 NONE 1STOPBIT 7DATABITS
```

### Edit the fhem configuration

Here an example file with my devices. You need to change the definition of the cul device according to your ser2net port. Please change the housecode from 1234 to something else :)

[/etc/config/fhem](/_export/code/docs/guide-user/services/automation/fhem?codeblock=4 "Download Snippet")

```
attr global modpath /usr/lib/fhem
attr global pidfilename /var/run/fhem.pid
attr global statefile /var/log/fhem/fhem.save
attr global logfile /var/log/fhem/fhem-%Y-%m.log
#attr global port 7072
define telnetPort telnet 7072
 
#The USB stick
#to try it without ser2net => define CUL CUL /dev/ttyUSB0@directio 1234
define CUL CUL 127.0.0.1:27073 4321
 
#Die Webinterfaces
define WEB FHEMWEB 8083 global # 8083 is the port for the default WebInterface
attr WEB room hidden
attr WEB stylesheetPrefix dark
 
define WEBS FHEMWEB 8084 global # 8084 is the port for the mobile WebInterface
attr WEBS room hidden
attr WEBS smallscreen 1
 
#Die Geraete
define ledlamp FS20 1234 56 # 1234 is the housecode which is set holding the button while plugging it in
attr ledlamp model fs20st
attr ledlamp room Wohnzimmer
 
# define <free device name> <predefineddevicename> <freedecimalhousecode> <devicenumber>
define lamp FS20 1234 57
# <attr> <name from define> <model> <modelidfix>
attr lamp model fs20di
attr lamp room Dorm
 
define heating FHT 2d22 # Is shown in decimal numbers on the device and must be given in hex eg. (1. 45 = 2d and 2nd: 34 = 22 )
#attr heating model fht80b
attr heating room Livingroom
```

### Autostart Scripts

#### FHEM autostart script

Create an autostart Script in /etc/init.d for fhem

```
#!/bin/sh /etc/rc.common
# FHEM Init Script
 
START=11
STOP=15
 
start() {
  if [ -f /var/log/fhem ]; then 
  mkdir -p /var/log/fhem
  fi
 
  /usr/sbin/fhem.pl /etc/config/fhem/fhem.cfg
}
stop(){
  echo "stopping fhem"
  kill -TERM $(cat /var/run/fhem.pid)
}
restart(){
  echo "restarting"
  kill -TERM $(cat /var/run/fhem.pid)
  /usr/sbin/fhem.pl /etc/config/fhem/fhem.cfg
}
```

Make the Script executeable:

```
chmod 755 /etc/init.d/fhem
```

Enable the autostart script via

```
/etc/init.d/fhem enable
```

#### ser2net autostart script

quite rudimentary...

[/etc/init.d/ser2net](/_export/code/docs/guide-user/services/automation/fhem?codeblock=8 "Download Snippet")

```
#!/bin/sh /etc/rc.common
# Ser2Net Init Script
 
START=10
STOP=15
 
start() {
   ser2net
}
 
stop(){
   killall ser2net
}
```

Make the Script executeable:

```
chmod 755 /etc/init.d/ser2net
```

Enable the autostart script via

```
/etc/init.d/ser2net enable
```

### Webinterface

Now you can use the commandline, but you've got no Webinterface. As perl brings it's own webserver you just have to place your preferred Webinterface in the folder `/usr/lib/fhem/FHEM` I got my 01\_FHEMWEB.pm via ubuntu repositories (apt-get install fhem) from where it installs to /usr/share/fhem/FHEM'')

Since version 5.3 there is a new Webserver included. You can define it according to the [fhem commandref](http://fhem.de/commandref.html#HTTPSRV "http://fhem.de/commandref.html#HTTPSRV") in your fhem.cfg

[/etc/config/fhem](/_export/code/docs/guide-user/services/automation/fhem?codeblock=11 "Download Snippet")

```
define <name> <infix> <directory> <friendlyname>
```

### Troubleshooting

![FIXME](/lib/images/smileys/fixme.svg) If autostart doesn't work, link the startup scripts to the appropriate runlevel

```
chmod 755 /etc/init.d/fhem
ln -s /etc/init.d/fhem /etc/rc.d/S99fhem
ln -s /etc/init.d/fhem /etc/rc.d/K1fhem
```

and give the appropriate access rights to the startup script files:

```
chmod 755 /etc/init.d/fhem && chmod 755 /etc/init.d/ser2net
```

## Resources

- \[0] [Google Groups - fhem-users (Gerhard Pfeffer)](https://groups.google.com/forum/#!msg/fhem-users/5hhg43UHlDs/ihV-6s0GCdoJ "https://groups.google.com/forum/#!msg/fhem-users/5hhg43UHlDs/ihV-6s0GCdoJ")
- \[1] [http://www.fhemwiki.de/wiki/OpenWRT](http://www.fhemwiki.de/wiki/OpenWRT "http://www.fhemwiki.de/wiki/OpenWRT")
