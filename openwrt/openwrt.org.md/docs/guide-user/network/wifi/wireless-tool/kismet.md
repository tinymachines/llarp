# Kismet

## Introduktion

[Kismet (software)](https://en.wikipedia.org/wiki/Kismet%20%28software%29 "https://en.wikipedia.org/wiki/Kismet (software)") is an Layer2 IEEE 802.11 network detector and [sniffer](https://en.wikipedia.org/wiki/Packet%20analyzer "https://en.wikipedia.org/wiki/Packet analyzer"). It can be utilized as [Intrusion detection system](https://en.wikipedia.org/wiki/Intrusion%20detection%20system "https://en.wikipedia.org/wiki/Intrusion detection system"). Kismet works with WNICs in *monitor mode*, which means it works completely passive! Kismet is split into three separate modules:

Package Version Dependencies Size Description kismet-drone 2010-07-R1-1 uclibcxx, libnl-tiny, libpcap, libpcre 199.510 This package contains the kismet remote sniffing and monitoring drone. The drone is a small program which gets the raw data from the wireless card itself. kismet-server 2010-07-R1-1 uclibcxx, libnl-tiny, libpcap, libpcre 352.618 This package contains the kismet server. The server is the piece if software that sits in the middle of the drone and the client. kismet-client 2010-07-R1-1 uclibcxx, libnl-tiny, libncurses 300.376 An 802.11 layer2 wireless network detector, sniffer, and intrusion detection system. This package contains the kismet text interface client. The client is the user interface to display the results on your screen.

It is possible and due to limited resources prudent to split the work amongst your OpenWrt-enabled router and a host machine running some Linux distribution!

**`Note1:`** `kismet-drone` from OpenWrt repos does not support channel hopping to search through all of the wireless channels! A small script has to be ran to manually do the channel hopping.  
**`Note2:`** Also, not all wireless drivers support the reporting of the received signal strength. So the client may not display the correct signal strength.  
**`Note3:`** It is not possible to see management frames in monitor mode! Try [wireless](/docs/guide-developer/debugging#wireless "docs:guide-developer:debugging") instead.

## Installation

### The Drone on OpenWrt

[opkg](/docs/guide-user/additional-software/opkg "docs:guide-user:additional-software:opkg")

```
opkg update
opkg install kismet-drone
```

### The Server + The Client on host machine

```
sudo apt-get update
sudo apt-get install kismet
```

[http://packages.debian.org/search?suite=squeeze&amp;arch=any&amp;searchon=names&amp;keywords=kismet](http://packages.debian.org/search?suite=squeeze&arch=any&searchon=names&keywords=kismet "http://packages.debian.org/search?suite=squeeze&arch=any&searchon=names&keywords=kismet")

If the version available in your distro's repositories does work with the one in the OpenWrt repos, you may need to install a matching one manually:

```
mkdir ~/kismet
cd ~/kismet
wget http://www.kismetwireless.net/code/kismet-2011-03-R2.tar.gz
tar -zxvf kismet-2011-03-R2.tar.gz
cd <kismet dir>
./configure
make
make install
```

## Configuration

### The Drone on OpenWrt

```
vi /etc/kismet_drone.conf
```

Change the line

`allowedhosts=127.0.0.1`

to

`allowedhosts=<address of desktop box>`

(You could also allow access to all the machines on your local network by doing 'allowedhosts=a.b.c.0/24' where a.b.c are the first three octets of your networks ip address. This would also make it possible for more than one machine at a time to connect to the drone and display the results.)

Next, change the line

`source=wrt54g,eth2,Kismet-Drone`

to

`source=wrt54g,prism0,Kismet-Drone`

(I have read that this line should be different if running another version of the hardware - this works with v2.2 of the wrt54g).

### The Server on Debian

- File: `/etc/kismet.conf` **or** File: `/usr/local/etc/kismet.conf`

**`Note:`** I found that the config files were in `/etc/kismet` when installing using apt-get, but they were in `/usr/local/etc` when installing from source.]

First, you need to make a kismet user for the server to run as.

```
 adduser kismet
```

...and fill in the blanks. Then you need to edit the `/usr/local/etc/kismet.conf` file and change

`suiduser=your_user_here`

to

`suiduser=kismet`

Set the wireless source by changing

`source=none,none,addme`

to

`source=kismet_drone,<wrt ip address>:3501,wrt54g`

I found that kismet couldn't write its log files to the default directory, so changed the line

`logtemplate=%n-%d-%i.%l`

to

`logtemplate=%h/%n-%d-%i.%l`

so that the log files get saved in the kismet users directory (`/home/kismet`).

### The Client on Debian

- File: `/etc/kismet.conf` **or** File: `/usr/local/etc/kismet.conf`

## Execution

### On OpenWrt

1. put your WNIC into *Monitor mode*:
   
   1. cfg80211 drivers:
      
      ```
      iw bla bla bla
      ```
   2. Atherors proprietary:
      
      ```
      bla bla
      ```
   3. Broadcom proprietary:
      
      ```
      wl ap 0
      wl disassoc
      wl passive 1
      wl promisc 1
      wl channel <channel number>
      ```
2. start `kismet-drone`:
   
   ```
   ./kismet_drone -f kismet_drone.conf
   ```

### On host machine

1. First you will need to start the server in the background
   
   ```
   /usr/local/bin/kismet_server &
   ```
2. and then start the GUI client:
   
   ```
   /usr/local/bin/kismet_client
   ```

## Troubleshooting

## References

- [Project Website](http://www.kismetwireless.net/documentation.shtm "http://www.kismetwireless.net/documentation.shtm")
- [http://www.renderlab.net/projects/wrt54g/openwrt.html](http://www.renderlab.net/projects/wrt54g/openwrt.html "http://www.renderlab.net/projects/wrt54g/openwrt.html")
- [http://www.supertechguy.com/help/security/kismet-drone](http://www.supertechguy.com/help/security/kismet-drone "http://www.supertechguy.com/help/security/kismet-drone")
