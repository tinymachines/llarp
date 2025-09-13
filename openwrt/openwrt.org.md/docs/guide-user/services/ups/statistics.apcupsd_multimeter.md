# How to add data from a TP9605BT multimeter to apcupsd rrd and graphs.

**WARNING: All liability is yours: this procedure involves handling of potentially lethal electrical currents.**

This describes how to add Voltage Output data to the apcupsd RRD database.  
I did this because the APC BackUps ES-500 I have does not report a value I was interested in: “OUTPUTV - The voltage the UPS is supplying to your equipment” ( [http://www.apcupsd.org/manual/manual.pdf](http://www.apcupsd.org/manual/manual.pdf "http://www.apcupsd.org/manual/manual.pdf") ).

The plan was simple:

- Get a multimeter that could output voltage readings to my router.
- Add the readings to the apcupsd RRD database.
- Verify the readings appear in the appropriate graph.

I found a multimeter that worked and was cheap enough, the [Tekpower TP9605BT](http://amzn.to/2reiCzk "http://amzn.to/2reiCzk") ( This an affiliate link from Louis Rossmann's work with this meter at: [Multimeter Overlay in OBS](https://mailin.repair/blog/multimeter-overlay-in-obs-making-the-readings-show-on-screen-for-recordings "https://mailin.repair/blog/multimeter-overlay-in-obs-making-the-readings-show-on-screen-for-recordings") ).

The physical attachment of the multimeter involved:

- Connecting the meter's USB cable to the router USB, which further required a small USB hub.
- Experimenting until I found the correct button-press combination that put the meter into always-on mode.
  
  - The documentation had an incorrect sequence.
  - The correct sequence is: hold down the \[Range] button while turning on the meter.
- Switching to probes that would stay in a mains socket
- Cobbling up a 9 volt battery eliminator.
- Making sure I used the same circuit on the battery-backed-up side of the UPS for both the meter probes, and the battery eliminator. This minimizes the chances of a ground loop destroying the multimeter.

The next step was to establish communication between the meter and the router:

- opkg install kmod-usb-serial-ch341
- Make sure the communication worked.
- Write some code that periodically took a value from the meter, and dumped it in the apcupsd RRD database.

From looking at logread, I determined that the meter's port is on /dev/ttyUSB0. So, I did:

```
# cat /dev/ttyUSB0
```

and got some very reasonable results:

```
+1227 3)�

+1227 3)�
```

Now, came the analysis part. The “)?” characters tell us what range the meter is set to. This didn't matter to me in this application, because I already knew the settings.

- “+1227” are the numbers on the meter display.
- “3” is where to put the decimal point.
- So, “+1227 3)�” = 122.7 Volts AC.

Below is some code I whipped up. I'm sure it can be improved. Note that it has custom locations for the RRD files, and the port for the meter.

I added these lines to the crontabs/root:

```
# get AC Volts from the multimeter once every minute
*/1 * * * * /usr/share/bobvolts_TP9605BT_usb.sh
```

This runs the program every minute, and seems to work well when I look at the graph: [![](/_media/media/doc/howtos/statistics_apcups_multimeter_graph.png)](/_detail/media/doc/howtos/statistics_apcups_multimeter_graph.png?id=docs%3Aguide-user%3Aservices%3Aups%3Astatistics.apcupsd_multimeter "media:doc:howtos:statistics_apcups_multimeter_graph.png")

Now for some cleanup. Add this line to /etc/sysupgrade.conf, which preserves this new script across upgrades:

```
/usr/share/bobvolts_TP9605BT_usb.sh
```

And, here is the script, to add to /usr/share/bobvolts\_TP9605BT\_usb.sh:

```
##!/bin/bash

# bobvolts_TP9605BT_usb.sh, Copyright 2017 Bob Meizlik, license: CC Attribution-Noncommercial-Share Alike 3.0.
# All liability is yours: this code presumes handling of dangerous tools and electricity.
#
# Purpose:
# Collect and store AC Voltage Output readings, when your UPS does not. 
#
# Usage:
# Connect your meter appropriately, to the output AC of the UPS, and the (USB or RS232 or Bluetooth) of your computer or access point.
# Hold down RANGE button, and turn meter on, to defeat the auto-power-off timer.
# Set meter range to Volts, AC.
# Set meter to RS232 output (this enables, RS232, USB and Bluetooth)
# Install drivers 
# Set this script to run periodically, perhaps with a cron script, or a daemon.
#
# Code Process:
# Get AC Voltage readings from a TekPower TP9605BT multimeter, and 
# send them to the apcups, collectd RRD file meant for these readings.
# 
# get the latest voltage reading from a TekPower TP9605BT multimeter
# set to AC Volts range
# set to RS232 output
#
# We get 4 readings per second.
# each reading is 14 bytes long
# the lines look like this: 2b 31 32 31 38 20 33 29  20 20 80 20 0a 0a 2b 31  |+1218 3)  . ..+1|
# if we start in the middle of a line, ignore the line, and go to the next line, which is presumably complete.
# the x0a characters look like new lines in this processing, resulting in a data line that is 12 bytes long.
#
# Known issues:
# The input will hang, when there is no device at /dev/ttyUSB0.
# The input will hang, when the meter is turned off.

inputfile="/dev/ttyUSB0"

rrdfile="/mnt/share/tmp/mydigitemp.rrd"
rrdfile="/mnt/share/stats/rrd/g70outside/apcups/voltage-output.rrd"
# todo: get the rrdfile name from /etc/config/luci-statistics option DataDir '/mnt/share/stats/rrd'

# translate 0 to space, because the length is our checksum
dat=$(dd bs=1 count=50 if=$inputfile | tr \\000 \\040 )

line1=$(echo -en "$dat" | sed --quiet '1p')
line2=$(echo -en "$dat" | sed --quiet '2p')
line3=$(echo -en "$dat" | sed --quiet '3p')

line1len=${#line1} 
line2len=${#line2}
line3len=${#line3}

# todo, this would be nicer if it was a loop
if [ 12 -eq "$line1len" ]; then
   theline=$line1
else
   theline=$line3 
fi

# extract the data from the line, and convert it to a form that rrd can use.
set -- junk $theline
val=$2 # the value, like +1234

dec=`expr "$3" : '\([0-9]\)'` # the decimal place, like 3
decp1=`expr 1 + $dec`         # add 1 to get past the sign
theValue=${val:0:$decp1}.${val:$decp1} # put the value together with the decimal place

# generate and run a line like: rrdtool update .rrd $(date +%s):+122.5 
theSeconds=$(date +%s)
rrdcmd='rrdtool update '$rrdfile' ''N:'$theValue   
$rrdcmd
```
