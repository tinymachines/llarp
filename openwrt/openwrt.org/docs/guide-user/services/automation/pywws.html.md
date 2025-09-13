# pywws Python Weather Station HowTo

*“pywws is a collection of Python modules to read, store and process data from popular USB wireless weather stations such as Elecsa AstroTouch 6975, Watson W-8681, WH-1080PC, WH1080, WH1081, WH3080 etc”*

## intro

This is a guide on installing pywws and its dependencies from source (where necessary) without pip (python package manager) or the full python package to save space.

There is excellent official documentation here that describes how to do it with pip (easiest) if you have the space (perhaps via [Rootfs on External Storage (extroot)](/docs/guide-user/additional-software/extroot_configuration "docs:guide-user:additional-software:extroot_configuration")): [http://pywws.readthedocs.org/en/latest/index.html](http://pywws.readthedocs.org/en/latest/index.html "http://pywws.readthedocs.org/en/latest/index.html")

I have a WH1080 into a [Lenovo Y1 v1](/toh/lenovo/y1 "toh:lenovo:y1") running openwrt 15.05 with 16mb total flash which leaves about 10Mb after flashing, **You will require about 5mb free to do all this.**

Here is my underground weather station page: [http://www.wunderground.com/personal-weather-station/dashboard?ID=INEWSOUT968](http://www.wunderground.com/personal-weather-station/dashboard?ID=INEWSOUT968 "http://www.wunderground.com/personal-weather-station/dashboard?ID=INEWSOUT968")

## system packages

These are required:

```
 libusb-1.0, zoneinfo-core, ca-certificates
 
```

These will make things easier, such as sftp with filezilla, wget downloading source and unpacking it via ssh:

```
  tar, wget, openssh-sftp-server, unzip
 
```

Once done create a symlink for your timezone, (needed by python tzlocal)

```
  ln -s /usr/share/zoneinfo/GMT+10 /etc/localtime
```

## python packages

You will need these openwrt python packages (and what ever dependencies they come with) to compile and install pywws and it's dependencies.  
Some of these can be removed after everything is installed, to make more space if needed, the biggest one ive tested as removable is python-distutils  
More details on openwrt python can be found here: [Python](/docs/guide-user/services/python "docs:guide-user:services:python")

```
python-base python-codecs python-ctypes python-distutils python-email python-light python-logging python-openssl python-unittest python-xml
```

## pywws and python source dependencies

The following python modules will be downloaded as source, compiled and installed to avoid needing pip, after success with each one you can delete the unpacked and downloaded source files if you need the room.

### setuptools

[https://pypi.python.org/pypi/setuptools#unix-wget](https://pypi.python.org/pypi/setuptools#unix-wget "https://pypi.python.org/pypi/setuptools#unix-wget")  
Installing this from source instead of the python-setuptools package saves installing it's dependency python (full)  
To install grap the install script, [https://bootstrap.pypa.io/ez\_setup.py](https://bootstrap.pypa.io/ez_setup.py "https://bootstrap.pypa.io/ez_setup.py") and:

```
  python ez_setup.py
```

### tzlocal

[https://github.com/regebro/tzlocal](https://github.com/regebro/tzlocal "https://github.com/regebro/tzlocal") (download and unpack)

```
 python setup.py install
```

### python-libusb1

[https://github.com/vpelletier/python-libusb1](https://github.com/vpelletier/python-libusb1 "https://github.com/vpelletier/python-libusb1") (download and unpack)

```
 python setup.py install
```

### pywws

[https://github.com/jim-easterbrook/pywws](https://github.com/jim-easterbrook/pywws "https://github.com/jim-easterbrook/pywws") (download and unpack)

```
 python setup.py install
 
```

## pywws setup and running

Your now ready to run, and can proceed setup from here: [http://pywws.readthedocs.org/en/latest/guides/getstarted.html#test-the-weather-station-connection](http://pywws.readthedocs.org/en/latest/guides/getstarted.html#test-the-weather-station-connection "http://pywws.readthedocs.org/en/latest/guides/getstarted.html#test-the-weather-station-connection")

Further into it you may want to use cron, who's jobs can be set in Luci System→Scheduled Tasks, and enabled: [https://wiki.openwrt.org/doc/howto/cron#activating\_cron](https://wiki.openwrt.org/doc/howto/cron#activating_cron "https://wiki.openwrt.org/doc/howto/cron#activating_cron")

```
 service cron start
 service cron enable
```

## comments

A thread about this guide at the 'forum' for pywws: [https://groups.google.com/d/topic/pywws/aNi2dE9J8OM/discussion](https://groups.google.com/d/topic/pywws/aNi2dE9J8OM/discussion "https://groups.google.com/d/topic/pywws/aNi2dE9J8OM/discussion")

## syncing data to a remote host

Say you want to sync your collected data to a remote web server for backup or further processing here's how i did it.  
My main reason was that gnuplot is no longer in the 15.05 package feeds and i didnt really want it and the images taking up space on the router anyway, so i figured do it remotely.

Firstly you need to setup a key pair that lets scp/ssh connect to a remote server without password:

```
 dropbearkey -t rsa -f .ssh/id_dropbear
```

When done it will print your new public key, copy and past it all to your server users .ssh/authorized\_keys file:

```
 ssh-rsa AAAAB3NzaC1ychaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaangedkDHJ8CZy5Dey+l7C2tS357e+Xtgs+INv5DZ user@OpenWrt
 Fingerprint: md5 d9:be:27:echaaaaaaaangedb:95:80:f0:de:6f
 
```

Then the command (that you can put in cron) to sync your data files will be :

```
 scp -i .ssh/id_dropbear  ~/weather/ -r user@host:/destination/
```

Run it from the command line atleast once to test it works.  
I then installed another instance of pywws on the remote server with gnuplot to process the data.
