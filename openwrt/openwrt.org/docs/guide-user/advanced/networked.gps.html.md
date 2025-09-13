# Sharing raw NMEA GPS data over the network with multiple clients

While there are programs like `gpsd` in the OpenWrt repository for interfacing with GPS receivers, sometimes you may be limited to a program that can only parse raw [NMEA 0183](https://en.wikipedia.org/wiki/NMEA%200183 "https://en.wikipedia.org/wiki/NMEA 0183") data over a serial port. This article will show you how to share your GPS receiver's raw NMEA sentences with one of these outdated programs, such as [Microsoft MapPoint](https://en.wikipedia.org/wiki/Microsoft%20MapPoint "https://en.wikipedia.org/wiki/Microsoft MapPoint").

For single users, the use of the `ser2net`-package already contained in the OpenWrt repository may prove more useful for this application. We are specifically talking about sharing the data in read-only mode with multiple clients.

## Preparation

You'll need an OpenWrt device with a compatible serial, UART, or USB port that allows for communication with your GPS receiver. It's helpful to have a use for raw NMEA data as well, otherwise you wouldn't be reading this.

### Required Packages

- **`netcat`** (Busybox's nc will not listen on ports)
- **`coreutils-stty`** (Setting speed on serial ports)

### Client PC

For your client machine, you'll need a virtual serial port software. Perle has no cost software to do this on virtually every operating system and can be found here: [TruePort](http://www.perle.com/supportfiles/Trueport.shtml "http://www.perle.com/supportfiles/Trueport.shtml").

## Configuration

### GPS Receiver Configuration

GPS receivers have a whole handful of sentences they provide, however all of the location data is contained within the [GPGGA](http://aprs.gids.nl/nmea/#gga "http://aprs.gids.nl/nmea/#gga") string. You need to know and/or configure the frequency of this string (once a second, twice a second...) and if possible disable the other sentences. Garmin provides software to do this with their units available at their website.

You can also test the frequency of your unit by running this, assuming your unit is at /dev/ttyS0:

```
stty -F /dev/ttyS0 4800 sane
cat /dev/ttyS0
```

Run this for a period of time (10 seconds?) and count the number of GPGGA strings, divide by the seconds and you'll have your frequency.

### Server configuration

This requires at least three shell scripts; one to read raw data, one to clean the data, and one additional script for every client that you want to connect.

The first script reads the raw GPS data to a file in /tmp:

`/root/gpspullraw.sh`

```
#!/bin/sh

stty -F /dev/ttyS0 4800 sane
cat /dev/ttyS0 > /tmp/gpsdata-raw.txt
```

This file cannot be fed directly into netcat because our software wants CRLF and this only provides LF. Therefore, we have to clean this data into something that other machines will like. Assuming our GPS is only providing GPGGA sentences at a frequency of once per second, the following code will work:

`/root/gpscleanraw.sh`

```
#!/bin/sh
## make sure raw data is being collected
while [ ! -e /tmp/gpsdata-raw.txt ]
do
  sleep 1
done

while true
do
  tail -n5 /tmp/gpsdata-raw.txt | grep -v "^$" | tail -n1 | tr '\n' '\r' >> /tmp/gpsdata-clean.txt
  echo -n -e '\n' >> /tmp/gpsdata-clean.txt
  sleep 1
done
```

If your GPS is outputting more than GPGGA, increase the count on the first tail so that it includes the last GPGGA sentence and add a grep GPGGA in there. If you're getting GPGGA twice a second instead of once, increase the second tail count to 2 so that it doesn't miss any. If you're getting it every other second, increase your sleep count. There's no need to repeat sentences and we don't want to miss any.

Finally, we need to make this data available to outside users. This is done with a netcat loop. Pick arbitrary TCP port numbers to serve the data on; I am using 2001, 2002...

`/root/gps2001.sh`

```
#!/bin/sh
## wait for data to become available
while [ ! -e /tmp/gpsdata-clean.txt ]
do
  sleep 1
done

while true
do
  /usr/bin/tail -f /tmp/gpsdata-clean.txt | netcat -l -p 2001
done
```

The loop is necessary because netcat exits when the socket is closed. Also, this version of netcat does not have the ability to continue listening after a connection is made, which is why I recommend creating an instance of the above script for every client you intend on connecting, on different port numbers. I did not take precautions about what address netcat binds to, and if you're concerned about someone randomly connecting in and seeing where you are located, then please edit this page to reflect proper address binding.

Finally, after making your scripts executable, make them start on boot:

`/etc/rc.local` (add these lines before 'exit 0')

```
/root/gpspullraw.sh &
/root/gpscleanraw.sh &
/root/gps2001.sh &
```

### Client Configuration

This procedure was created on Windows 7 x64, though I'm relatively confident it is identical across platforms.

1. Install the [TruePort](http://www.perle.com/downloads/truePort.shtml "http://www.perle.com/downloads/truePort.shtml") software.
2. Add a TruePort adapter with the Management Tool and link it to your OpenWrt IP address.
3. Within the Management Tool, edit your port, and click Settings on the Configuration tab.
4. Select your port, and change it to “Initiate connection to device server” port 2001 (or other chosen one)
5. On the advanced tab, uncheck “Send keepalive packets”
6. In the device manager, open the properties on the port, change your baud rate to 4800.
7. Finally, also in the device manager, clicked advanced on the port settings and check the box for “Use FIFO Buffers.”

You should now have a serial port spitting out GPS data from your OpenWrt box! Let your mapping program know.

## Troubleshooting

- Make sure your baud rate is configured properly. 4800 is used in this example.
- Ensure you can 'cat /dev/ttyS0' and see NMEA.
  
  - If no data appears, you may have TX and RX switched; try it with a Null Modem cable instead
  - TTL is not Serial; look up how to interface if you're trying a UART port.
- Telnet to your router on port 2001, and see if you can see the data.
- Use PuTTY to open your new serial port and confirm you see the data.

## Notes

- This fills a file in `/tmp` and may crash when you run out of ramdisk. I designed this for an implementation that wouldn't stay on for more than a couple of days at a time. In case you need to truncate and restart your scripts after some time, use `etc/crontabs/root`.
- This is untested with USB receivers or ones that operate at different baud rates. YMMV but please update this page if you try it out.
- \[[http://esr.ibiblio.org/?p=801](http://esr.ibiblio.org/?p=801 "http://esr.ibiblio.org/?p=801") Why NMEA 0183 sucks, and what to do about it]
