# Bandwidthd

[http://bandwidthd.sourceforge.net/](http://bandwidthd.sourceforge.net/ "http://bandwidthd.sourceforge.net/") (openWRT older than 17)

[https://github.com/NethServer/bandwidthd](https://github.com/NethServer/bandwidthd "https://github.com/NethServer/bandwidthd") (openWRT 17 or higher)

**Note: bandwidthd in LEDE/OpenWRT 17.01 or higher tracks the SMTP data (ports 25, 465 and 587) while the version in the previous version of OpenWrt (Chaos Calmer and older) tracks the P2P data (Gnutella, eDonkey, etc.). All of the other data (FTP, UDP, TCP, etc.) is tracked the same way in all versions.**

**Bandwidthd is composed of 4 packages:**

1. **bandwidthd**: this package cannot save in a postgresql or sqlite database. This allows the router to generate bandwidth data that is accessible with a browser at [http://192.168.1.1/bandwidthd](http://192.168.1.1/bandwidthd "http://192.168.1.1/bandwidthd"). ***Use this package if you have no intention of storing the data on a postgresql or sqlite database.***
2. **bandwidthd-pgsql**: this package can do everything the bandwidthd package can do, but in addition it can save the data to a postgresql database that can reside on the router or on another server. This data can be analyzed by a series of PHP scripts and visualized with a browser. Note that the router, the posgresql database and the graphing of the data by PHP can be on three different systems, one for each task (i.e.: *collecting the data*, *storing the postgresql data* and *generating the graphs with PHP*). Note that postgresql does not have to be installed on the router if the postgresql data is not stored on the router. **NOTE: install only one of the package: bandwidthd, bandwidthd-pgsql or bandwidthd-sqlite.**
3. **bandwidthd-php**: This package contains the PHP files that are installed in /www/phphtdocs on the router. It is only required if the OpenWrt router serves as the web server to generate the graphs from the data on the postgresql database by pointing the browser to [http://192.168.1.1/phphtdocs](http://192.168.1.1/phphtdocs "http://192.168.1.1/phphtdocs"). **NOTE: if you installed bandwidthd-sqlite, do not install bandwidthd-php as bandwidthd-sqlite contains the required PHP files to graph the data.**
4. **bandwidthd-sqlite**. This package, in addition to do what the plain bandwidthd package can do, stores the data in a sqlite database on the router and graph the data using PHP. In a way, it is a combination of bandwidthd-pgsql and bandwidthd-php together, but using sqlite instead of postgresql. **NOTE: install only one of the package: bandwidthd, bandwidthd-pgsql or bandwidthd-sqlite.**

The availability of each package varies according to which version of OpenWrt/LEDE you have:

**bandwidthd**

- In Backfire (10.03 or 10.03.1) as a package.
- In Attitude Adjustment (12.09) as a package.
- In Barrier Breaker (14.07) in “oldpackages” as a package.
- In original Chaos Calmer (15.05) *it is not available as a precompiled package*: you have to compile it yourself and install it. See [https://wiki.openwrt.org/doc/howto/build](https://wiki.openwrt.org/doc/howto/build "https://wiki.openwrt.org/doc/howto/build") to have details on how to compile a package.
- As a package in 15.05.1 or higher.

**bandwidthd-pgsql**

- In the original Chaos Calmer (15.05) *it is not available as a precompiled package*: you have to compile it yourself and install it. See [https://wiki.openwrt.org/doc/howto/build](https://wiki.openwrt.org/doc/howto/build "https://wiki.openwrt.org/doc/howto/build") to have details on how to compile a package.
- In the minor fix release of Chaos Calmer (15.05.1) it is available as a package.
- As a package in 15.05.1 or higher.

**bandwidthd-php**

- Available in LEDE/OpenWRT 17.01 or higher as a package and uses php7 or php8. The PHP files found in these versions work fine with Chaos Calmer 15.05 or 15.05.1 with php5 (tested).

**bandwidthd-sqlite**

- Available in LEDE/OpenWRT 17.01 or higher.

## Installation

For the bandwidthd package:

```
opkg install bandwidthd uhttpd
/etc/init.d/uhttpd enable
/etc/init.d/uhttpd start
/etc/init.d/bandwidthd enable
/etc/init.d/bandwidthd start
```

For the bandwidthd-pgsql package (note: do not install uhttpd if you do not plan for the router to perform the graphs):

```
opkg install bandwidthd-pgsql uhttpd
/etc/init.d/uhttpd enable
/etc/init.d/uhttpd start
/etc/init.d/bandwidthd enable
/etc/init.d/bandwidthd start
```

With all dependencies it uses around 500 kB of storage space. If you have not changes the IP address of your router (192.168.1.1), then the web page with the bandwidthd data will be available at [http://192.168.1.1/bandwidthd](http://192.168.1.1/bandwidthd "http://192.168.1.1/bandwidthd"). If you have changed the IP address of your router, then edit the /etc/config/bandwidthd file to correct the address.

## Configuration

Packages **bandwidth**, **bandwidthd-pgsql** and **bandwidthd-sqlite** use basically the same configuration file: */etc/config/bandwidthd*

Each package installs the proper configuration file, and usually requires very little modifications, if any.

The options are the same for the 3 packages, with two additional for **bandwidthd-pgsql** and two others for **bandwidthd-sqlite**.

Here are the various options:

*option dev*: Device to listen on. The default is *br-lan*.

*option subnets*: Subnets to collect statistics on. Traffic that matches none of these subnets will be ignored. Syntax is either IP Subnet Mask or CIDR. Ex: *“10.0.0.0 255.0.0.0”*, *“192.168.0.0/16”* or *“172.16.0.0/12”*. The defaults is *“192.168.1.0/24”*.

*option skip\_intervals*: An interval is 2.5 minutes, this is how many intervals to skip before doing a graphing run. The default is *0*.

*option graph\_cutoff*: Graph cutoff is how many k must be transferred by an ip before we bother to graph it. The default is *1024*.

*option promiscuous*: Put interface in promiscuous mode to score to traffic that may not be routing through the host machine. The default is *true*.

*option output\_cdf*: Log data to cdf file *log.cdf*. All packages can log to cdf files. These are only useful if you are using the **bandwidthd** package as the other packages (**bandwidthd-pgsql** and **bandwidthd-sqlite**) can store the data in a database. These files are located on the root of the router (/). The cdf files can be read when bandwidthd is started (see the option recover\_cdf), which is useful if you reboot the router to recover the bandwidth data. The default is *false*.

*option recover\_cdf*: Read back the cdf file on startup. See the comments for *output\_cdf* above. The default is *false*.

*option filter*: Libpcap format filter string used to control what bandwidthd see's. Please always include “ip” in the string to avoid strange problems. The default is *ip*.

*option graph*: Draw Graphs - This default to true to graph the traffic bandwidthd is recording. Usually set this to false if you only want cdf output or you are using the database output option (**bandwidthd-pgsql** or **bandwidthd-sqlite**). Bandwidthd will use very little ram and cpu if this is set to false. The defaults is *true*.

*option meta\_refresh*: Set META REFRESH seconds (default 150, use 0 to disable). Default is *150*.

*option pgsql\_connect\_string*: Only used for **bandwidthd-pgsql**. Standard postgres connect string. The default is *“user = postgres dbname = bandwidthd host = 192.168.1.1”*.

*option sensor\_id*: Used for **bandwidthd-pgsql** and **bandwidthd-sqlite**. Arbitrary sensor name. It can be anything you want for **bandwidthd-pgsql** but it has to be *“default”* for **bandwidthd-sqlite**. Default is *“openwrt”* for **bandwidthd-pgsql**.

*option sqlite\_filename*: Only used for **bandwidthd-sqlite**. This is the sqlite database file. Default is *“/www/bandwidthd/stats.db”*.

The package **bandwidthd-php** uses another configuration file: */etc/config/bandwidthd-php*. Package **bandwidthd-sqlite** can also use the *bandwidthd-php* configuration file (**bandwidthd-sqlite** uses two configuration files: */etc/config/bandwidthd* and */etc/config/bandwith-php*).

**NOTE:** the **bandwidthd-sqlite** package does not provide the */etc/config/bandwidthd-php* file: it is not needed as the init file (*/etc/init.d/bandwidthd*) will provide the bandwidthd application the default graph sizes (900 and 256) and interval (INT\_DAILY) and the default sqlite database: */www/bandwidthd/stats.db*. Create a /etc/config/bandwidthd-php file for bandwidthd-sqlite if you need to change the default.

Here are the options of the */etc/config/bandwidthd-php* configuration file:

*option dflt\_width*: Widthd of the graphs generated. Default is *'900'*.

*option dflt\_height*: height of the graphs generated. Default is *'256'*.

*option dflt\_interval*: Defaultinterval for the graphs. The default is *'INT\_DAILY'*. Options are: *INT\_DAILY*, *INT\_WEEKLY*, *INT\_MONTHLY* and *INT\_YEARLY*.

*option host*: This is for the host that has the postgresql database. The default is *'127.0.0.1'* which is the router.

*option user*: This is the user owning the postgresql database. Default is *'postgres'*.

*option dbname*: This is the name of the postgresql database. Default is *'bandwidthd'*.

A */etc/config/bandwidthd-php* for **bandwidthd-sqlite** will have the same structure, but the options *host*, *user* and *dbname* are not needed and are replaced by the following:

*option sqlite\_dbname “/www/bandwidthd/stats.db”*

## Usage

By default, bandwidthd hosts its statistics at /bandwidthd. All packages (**bandwidthd**, **bandwidthd-pgsql** and **bandwidthd-sqlite**) are set by default to graph and if this is not the behaviour that you want, then change the *option graph* to *false* in the configuration file (*/etc/config/bandwidthd*) For example, if the OpenWRT router's IP address is 192.168.1.1, bandwidthd's stats would be available at [http://192.168.1.1/bandwidthd](http://192.168.1.1/bandwidthd "http://192.168.1.1/bandwidthd")

**bandwidthd-pgsql** can store in a postgresql database and PHP has to be used to generate the graphs that are available at [http://192.168.1.1/phphtdocs/index.php](http://192.168.1.1/phphtdocs/index.php "http://192.168.1.1/phphtdocs/index.php") (see below) (of course, change the IP address to the one of the web server hosting the PHP files (your router or whatever web server you are using to graph the data)).

## Storing bandwidthd stats in external permanent storage

The default bandwidthd installation loses your previous statistics on each reboot and you need more space to save those. To keep statistics it is needed to modify “/etc/config/bandwidthd”.

You need to change “option output\_cdf true” and “option recover\_cdf true” and “option sqlite\_filename 'file.db' ”

```
config bandwidthd
	option dev		br-lan
	option subnets		"192.168.1.0/24"
	option skip_intervals	0
	option graph_cutoff	1024
	option promiscuous	true
	option output_cdf	true
	option recover_cdf	true
	option filter		ip
	option graph		true
	option meta_refresh	150
        option SQLite_filename  "/path/to/file.db" # file gets created automatically and default path works pretty well
```

After modifying both of the files, restart the service. Afterwards, you will get a file and directory structure on your external mount like this:

```
root@openwrt:~# ls -la /mnt/usb/bandwidthd/
drwxr-xr-x    3 root     root         1024 Aug 25 12:21 .
drwxr-xr-x    6 root     root         1024 Aug 25 00:39 ..
-rw-r--r--    1 root     root          158 Aug 25 00:40 bandwidthd.conf
drwxr-xr-x    2 root     root         2048 Aug 25 00:40 htdocs
-rw-r--r--    1 root     root        50034 Aug 25 12:21 log.1.0.cdf
-rw-r--r--    1 root     root        22204 Aug 25 12:21 log.2.0.cdf
-rw-r--r--    1 root     root         6698 Aug 25 12:10 log.3.0.cdf
-rw-r--r--    1 root     root          529 Aug 25 00:39 log.4.0.cdf
```

## Storing bandwidthd stats in a postgresql database

Bandwidthd now has support for external databases: it is provided by the **bandwidthd-pgsql** package: *the **bandwidthd** package does not support this*. This system consists of 3 major parts, and each part can be on a different server:

1. **The bandwidthd binary** which acts as a sensor, recording traffic information and storing it in a database across the network or on the OpenWrt router. In this mode Bandwidthd uses very little ram and CPU. In addition, multiple sensors can record to the same database.
2. **The database system.** Currently Bandwidthd only supports Postgresql. Please note that the postgres-server package on OpenWrt is pretty big (the server and a blank database takes more than 15 MB) and unless you have at lot of memory in your router, you will not be able to install it!
3. **The webserver and php application.** The package **bandwidthd-php** provides the required file if these have to run on the OpenWrt router. In the “/www/phphtdocs” directory is a php application that reports on and graphs the contents of the database. This has been designed to be easy to customize. Everything is passed around on the urls, just tinker with it a little and you'll see how to generate custom graphs pretty easy.

Using Bandwidthd with a database has many advantages, such as much lower overhead, because graphs are only graphed on demand. And much more flexibility, SQL makes building new reports easy, and php+sql greatly improves the interactivity of the reports.

**It is strongly recommended to use the router only to collect the data and store it to another server running postgres.** That same server can also be running the web server and use PHP to generate the graphs, but generating the graphs can take a lot of CPU time for a router and the various packages (postgresql, php) uses a lot of memory space that most router do not have.

**INSTRUCTIONS**

As a prerequisite for these instructions, you must have Postgresql server installed and working for the database, as well as a web server that supports php for the web server that will generate the graphs. Consult [https://forum.openwrt.org/viewtopic.php?id=11812](https://forum.openwrt.org/viewtopic.php?id=11812 "https://forum.openwrt.org/viewtopic.php?id=11812") to have more information on installing postgresql on OpenWrt. For other OSes (Linux, NetBSD, Unix, etc.) consult the help on the respective OS.

***Database Setup:*** Note that the database can reside on a remote computer and does not have to be on the OpenWrt router. If not using the router for the database, the required files for the setup can be found at [http://bandwidthd.sourceforge.net/](http://bandwidthd.sourceforge.net/ "http://bandwidthd.sourceforge.net/").

1. Create a database for bandwidthd. You will need to create a user that can access the database remotely if you want remote sensors. In OpenWrt, log as the user postgres (su - postgres) and issue the command “createdb bandwidthd”, then go back to be the root user with “exit”.
2. Bandwidthd's schema is in “schema.postgresql” that can be found in /usr/share/postgresql (provided by the bandwidthd-pgsql package). “psql mydb username &lt; schema.postgresql” should load it and create the 2 tables and 4 indexes.

In addition, you should schedule bd\_pgsql\_purge.sh to run every so often. I recommend running it weekly. This script outputs sql statements that aggregate the older data points in your database in order to reduce the amount of data that needs to be slogged through in order to generate yearly, monthly, and weekly graphs.

Example to be run as the postgres user:

bd\_pgsql\_purge.sh | psql bandwidthd postgres

Will connect to the bandwidthd database on local host as the user postgres and summarize the data.

***Bandwidthd Setup:*** Here is the /etc/config/bandwidthd file in the **bandwidthd-pgsql** package:

```
config bandwidthd
        option dev      br-lan
        option subnets          "192.168.1.0/24"
        option skip_intervals   0
        option graph_cutoff     1024
        option promiscuous      true
        option output_cdf       false
        option recover_cdf      false
        option filter           ip
        option graph            true
        option meta_refresh     150
        option pgsql_connect_string    "user = postgres dbname = bandwidthd host = 192.168.1.1"
        option sensor_id       "openwrt"
```

The default configuration file may work, but chances are that you will have to modify it. Modify the following lines:

```
option graph false
   By default this is true so you can at least get some graph at http://192.168.1.1/bandwidthd even if the pgsql settings
   are not adequate.  If you plan to only use PHP to obtain your graphs, then set it at false.
option pgsql_connect_string    "user = postgres dbname = bandwidthd host = 192.168.1.1"
   Change the user variable to the proper username
   Change the dbname variable to the database name (by default it is bandwidthd)
   Change the host variable to the IP address (or the domain name) of the postghresql server
 option sensor_id "openwrt"
   Change the name to the name that you want for your sensor: the name you give is not really critical.
```

Simply start bandwidthd (/etc/init.d/bandwidthd start), and after a few minutes data should start appearing in your database. If not, check syslog (logread) for error messages. (see [https://wiki.openwrt.org/doc/howto/log.essentials](https://wiki.openwrt.org/doc/howto/log.essentials "https://wiki.openwrt.org/doc/howto/log.essentials") if you want more information on syslog in OpenWRT)

***Web Server Setup:*** Note that the web server can be on a remote web server and does not have to reside on the OpenWrt router. Consult [http://wiki.openwrt.org/doc/howto/php](http://wiki.openwrt.org/doc/howto/php "http://wiki.openwrt.org/doc/howto/php") for installation of PHP on OpenWrt. For other OSes (Linux, NetBSD, Unix, etc.) consult the help on the respective OS. You will also have to configure the web server to work with PHP. Running this on OpenWrt takes about 2 MB of storage space for the various packages.

1. Copy the contents of phphtdocs into your web tree somewhere: these files are available at [http://bandwidthd.sourceforge.net/](http://bandwidthd.sourceforge.net/ "http://bandwidthd.sourceforge.net/"), [https://github.com/NethServer/bandwidthd](https://github.com/NethServer/bandwidthd "https://github.com/NethServer/bandwidthd") or in the **bandwidthd-php** package: the package will install them automatically and puts then in /www/phphtdocs.
2. Edit the file bandwidthd-php in /etc/config to set your db connect string (*$db\_connect\_string = “host=192.168.1.1 user=postgres dbname=bandwidthd”*). The variables *host*, *user* and *dbname* have to be edited in order to connect to the database.
3. On OpenWrt, the following packages will be installed automatically: **libpcre**; **libxml2**; **php7**; **php7-cgi**; **php7-mod-pgsql** and **php7-mod-gd**. On another system, the corresponding packages should be installed. Note that it also works with php5 which to be used on Chaos Calmer as php7 is not available.
4. Starting at the end of 2021, **php8** maybe installed instead of **php7**.
5. With php5, a zoneinfo package should be installed (ex: **zoneinfo-northamerica** or **zoneinfo-europe**). This is required to set the date.timezone value in php.ini.
6. If you are not using the **bandwidthd-php** package from OpenWrt (i.e. you got the php files on the web at one of the links above), the file /etc/php.ini should be edited to have the following: **short\_open\_tag = On**: the reason is that the php files taken from [http://bandwidthd.sourceforge.net/](http://bandwidthd.sourceforge.net/ "http://bandwidthd.sourceforge.net/") or [https://github.com/NethServer/bandwidthd](https://github.com/NethServer/bandwidthd "https://github.com/NethServer/bandwidthd") have the php short tag (&lt;? ?&gt;) instead of the normal tag (&lt;?php ?&gt;). If you do not do it, then you will get a bunch of garbage on the screen. If you installed the **bandwidthd-php** package on your router, then this is not necessary to set the **short\_open\_tag =** at **On** as the tags in the php files have been corrected to have &lt;?php ?&gt;.
7. In the /etc/php.ini file a **date.timezone =** whould be present (ex:**date.timezone = “America/Montreal”**). *Without the **date.timezone** set to something valid, the graphs will not be drawn*.
8. In the /etc/php.ini file the **display\_errors** should be set to off as many variables are not defined. If you have **display\_errors = On** the web page will most probably not work.
9. If you are using uhttpd, the following two lines should be added to /etc/config/uhttpd: **list interpreter '.php=/usr/bin/php-cgi'** and **option index\_page 'index.php'**.

You should now be able to access the web application and see you graphs. All graphing is done by graph.php, all parameters are passed to it in it's url. You can create custom urls to pull custom graphs from your own index pages, or use the canned reporting system.
