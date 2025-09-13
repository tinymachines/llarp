# Using OpenWrt to build a LAMP/WordPress server

**NOTE** The article is outdated, see the [Set up a LAMP webserver stack](/docs/guide-user/services/webserver/lamp "docs:guide-user:services:webserver:lamp") instead.

## Preamble/Scope

Pro web developers tend to rely on development servers, because no-one likes to expose a half-built site on the Internet. But if you work from home and build a site, say, every couple of months, it's hard to justify a dedicated server. Even a cheap old PC still takes up a lot of space. Much better to have a little box that you can stash in a drawer when it's not in use, right?

Well, getting a tiny devserver to behave like a commercial host is time consuming and can be expensive. Around 2010 I bought a SheevaPlug and committed several weeks of headscratching to the installation of a LAMP stack and WordPress, only to have the machine burn out within a week of commission.

Things have got better in the last decade and with OpenWrt and a so-called 'travel router' you can have a full-featured devserver with an outlay of less than $50 and a day or so of work. This how-to documents how I got WordPress running on a GL.inet MT300A I bought for £27 on Amazon. Much of my account references sources on this wiki and elsewhere. I will indicate the problems I encountered and how others might improve on my methods. I might have misremembered a few details and I'm afraid I don't know the Windows or Mac equivalents to the Linux commands given here. Sorry!

NOTE: My objective was to build a small, cheap router that I could plug into my home network as needed. I do NOT recommend following this route if you're hosting content to any third party. It goes without saying that you won't be putting sensitive information on the devserver and that you won't be running it outside a firewall.

## Hardware

I chose the MT300A in a blind purchase because of its low cost, small footprint and OpenWrt friendliness. Conclusion: it kinda works, with some bodging. I definitely wouldn't recommend trying to make the instructions below work with any of its predecessors, and other, better hardware may be available by the time you read this.

Power up the router as per manufacturer's instructions. I'd suggest connecting its LAN port to one of the spare ports on your broadband router, but of course that assumes that you've got a typical home/small office setup with a broadband router plugged straight into your phone line.

## Firmware

Launch a browser and type the IP address of your device (192.168.8.1 for an out-of-the-box MT300A). You can access it using the factory default password.

GL.inet recommend setting a new root password as soon as you connect. You're welcome to do so, but since you'll need to replace the firmware on the router there's little point. I used lede-17.01.4-ramips-mt7620-gl-mt300a-squashfs-sysupgrade.bin from this site and followed these instructions: [factory\_installation](/docs/guide-quick-start/factory_installation "docs:guide-quick-start:factory_installation")

The new firmware changes the default IP address from `192.168.8.1` to `192.168.1.1`. For access via OpenWrt's LuCI GUI, point your browser at the new address. Now's the time to set that new password!

NOTE: GL.inet state that you can use the reset button to return the device to factory defaults in the event of a meltdown, but that isn't strictly accurate. The reset button simply returns the installed firmware to its default state. Thus, once you've uploaded OpenWrt firmware, resetting the device will take you back to a clean OpenWrt install rather than factory settings.

## Software prerequisites?

There are loads of packages to install, so I'm not listing prerequisites. However, I will state at the outset that, since you'll need to use CLI/terminal programs, you might want to get up to speed on PuTTY and scp (secure copy). It's no fun wrestling with unfamiliar software on your own computer while trying to wrangle a remote machine.

## LAN

TCP/IP is widely documented but still causes confusion. A brutally quick account: your broadband router has a fixed IP address on the local network (LAN). It dynamically assigns IP addresses to the devices which connect to it. Your new router will need a fixed IP address so that you will be able to find it easily on the LAN, but that address has to align with the stuff the broadband router is doing.

To find exactly what the broadband router is up to, launch a terminal on your own computer and do:

`route -n`

The response will look like this:

```
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         192.168.1.254   0.0.0.0         UG    1024   0        0 wlan0
169.244.0.0     0.0.0.0         255.255.0.0     U     1000   0        0 wlan0
192.158.1.0     0.0.0.0         255.255.255.0   U     0      0        0 wlan0
```

Special bonus for UK readers: BT broadband routers mostly use the IP address 192.168.1.254. Either way, make a note of that gateway IP address.

Launch PuTTY from the terminal and start a new session with the ip address of the new router. Log in as 'root' using whatever password you set via LuCI. If the login is successful, you'll see an OpenWrt logo in text and a command prompt. Update the gateway address by typing a uci command:

```
uci set network.lan.gateway 192.168.1.254
```

Depending on setup you may also need to type:

```
uci set network.lan.dns 192.168.1.254
```

...then:

```
uci commit network
reboot
```

The new router \*should* now be set up for your existing LAN. Check by using OpenWrt's package manager to install nano, thus:

```
opkg update
opkg install nano
```

If you get errors, there is a network configuration problem. Google is your friend!

However, assuming you've got nano running, you'll be able to review all your network config options at one pass by doing:

`nano /etc/config/network`

BTW, when you've finished with nano, it will be faster to reload the network than to reboot the router:

`/etc/init.d/network reload`

## Extending the ROM

OpenWrt is tiny, and so are its numerous packages. This enables the system to operate from the meagre storage provided by the average router. The MT300A offers only 16Mb, but that's enough for a LAMP stack.

Unfortunately, it isn't enough for WordPress, which presently runs to about 20Mb.

A full solution to this problem is to dedicate an external USB stick to the router using a technique called overlaying, documented here: [extroot](/docs/guide-user/additional-software/extroot_configuration "docs:guide-user:additional-software:extroot_configuration")

NOTES: * I found that, after following these instructions, I still needed to access the LuCI GUI tool, select 'System/Mount Points', check the 'Enabled' option and reboot the new router to gain access to the extended storage. * I used extroot/overlay because I didn't want to wrangle multiple storage devices on the router. However, the technique has a downside: the USB stick can't easily be moved between devices, so you can't, for instance, re-plug it into your own machine to copy files. You might prefer to mount the USB stick on the router and access it as /dev/sda1 or whatever without bothering to overlay it. Useful pointers here: [https://snippets.khromov.se/installing-wordpress-on-a-tiny-wireless-router/](https://snippets.khromov.se/installing-wordpress-on-a-tiny-wireless-router/ "https://snippets.khromov.se/installing-wordpress-on-a-tiny-wireless-router/")

## Configuring the web server

You already have a working web server -- OpenWrt ships with uhttpd preinstalled. Result! The drawback is that uhttpd is tied up in providing the LuCI GUI.

The simplest way around this is to activate another instance of uhttpd on port 81 pointing to a distinct directory (where your dev website will live). This will slightly complicate the business of accessing your development site, but that's better than messing up LuCI. Instructions here: [lamp](/docs/guide-user/services/webserver/lamp "docs:guide-user:services:webserver:lamp") \[scroll down to 'Installing and configuring a web server/uHTTPd']

## Installing MySQL

I chose MySQL over SQLite. I imagine you'd get faster performance with the SQLite.

The MySQL install itself is pretty easy:

```
opkg update
opkg install mysql-server
```

## Installing PHP

PHP is available via opkg so you might think this would be easy. But you have to choose PHP5 or PHP7, and then you'll find that this is one of those times when OpenWrt's parsimonious approach to memory usage complicates matters -- the package is split across multiple components.

The following worked for me:

```
opkg update
opkg install php7 php7-cgi php7-cli php7-mod-gd php7-mod-hash php7-mod-json php7-mod-mbstring php7-modmysqli  php7-mod-opcache php7-mod-pdo php7-mod-pdo-mysql php7-mod-session
```

Use the configuration instructions here: [uhttpd](/docs/guide-user/services/webserver/uhttpd "docs:guide-user:services:webserver:uhttpd") \[scroll down to 'Using PHP5' section, still seems to apply.]

## Installing WordPress

You'll need to install WordPress the hard way.

Go to wordpress.org and download a copy of the latest version to your own machine. Unzip it and, while you're at it, rename 'wp-config-sample.php' to 'wp-config.php'.

Using Putty, make a new `wordpress` directory in `/srv/www` on the router:

```
cd /srv/www
mkdir wordpress
```

Now launch a terminal (not a PuTTY session!) and use scp to copy the unzipped archive to the new directory:

```
scp -r /home/[yermamaspc]/Downloads/wordpress/ root@192.168.1.1:/srv/www/wordpress/
```

## Tying it all together (but don't install PHPMyAdmin)

If you've run WordPress in a commercial environment, you've almost certainly used PHPMyAdmin to set up your MySQL databases. On OpenWrt, that's a bad move, since the available MySQL daemon isn't fully compatible with the latest PHP. Fortunately, manually configuring a suitable MySQL database is a piece of cake. Good instructions here: [websiteforstudents.com/creating-new-mysql-user-database-wordpress/](https://websiteforstudents.com/creating-new-mysql-user-database-wordpress/ "https://websiteforstudents.com/creating-new-mysql-user-database-wordpress/")

For our purposes I recommend standardizing thus: wordpress\_db / wordpress\_user / wordpress\_pw. Of course that's at your own risk. (You're not going to put your credit card details or Google password on there, are you?)

Once you've set up the MySQL database, you can run the WordPress installer script from:

`192.168.1.1:81/wordpress/`

From now on, you're on your own...
