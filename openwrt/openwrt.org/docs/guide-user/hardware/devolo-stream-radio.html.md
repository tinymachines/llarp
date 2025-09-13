# Devolo Streaming Radio

The purpose of this howto is to convert a [Devolo dLAN USB Extender](https://oldwiki.archive.openwrt.org/toh/devolo/dlan-usb-extender "https://oldwiki.archive.openwrt.org/toh/devolo/dlan-usb-extender") device into a standalone internet streaming radios music player.

We'll need the Devolo dLAN USB Extender, an USB audiostick, and a Devolo power line for ethernet connectivity. The audio output of the USB audiostick can be connected to:

- Headphones
- Self-powered loudspeakers
- Sound input at our AV equipment.

## Features

Since the dLAN USB Extender isn't powerful enough (only 16 MB RAM) to just install packages in a generic firmware, we must build our own firmware stripped as much as possible without stuff we don't really need.

- Without dropbear, we'll use telnet instead (this is just a streaming radio, there is no need to use an ultra-secure connection)
- Without syslog, there is no need to log any system messages.
- Only with kernel modules for usb audio, alsa support and USB HID support. Built in the kernel itself for faster loading.
- **mpd** for playing music, and **mpc** for controlling the daemon → [http://www.musicpd.org/](http://www.musicpd.org/ "http://www.musicpd.org/")
  
  - version 0.13.2 since it's more responsive for powerless devices
  - built only with mp3 audio support
  - built with alsa output, it behaves better than OSS
- **triggerhappy** for external control using the HID buttons at the USB audiostick
- **lircd** for using a IR remote, more comfortable control over our internet radio
- **alsa-utils**
- **nano** for editing configuration files
- and other minor changes in the firmware

### No Display

We won't have any display to show current playing info, but do we really need it? NO. You can use an [mpd client](http://mpd.wikia.com/wiki/Clients "http://mpd.wikia.com/wiki/Clients") to show this info. Or better just use ssmtp to send a mail with our current playing info. I've made a simple script located at:  
*/etc/streamradio/mailsend.sh*  
It can be launched either with a HID button press or else with a infrared remote.

### IR remote controled

We can control our streaming radio with a infrared remote. No special hardware required, just any spare remote (don't you have dozens from broken hardware?), and a simple circuit connected to the microphone input. More details at  
[lirc audio-alsa](/docs/guide-user/hardware/lirc-audio_alsa "docs:guide-user:hardware:lirc-audio_alsa")  
However we'll use an improved circuit. With a low band pass filter to minimize power supply disturbances. Also we will put the 100 nF capacitor before the voltage divider, not after:

[![image](/_media/media/doc/howtos/lirc_alsa.png?w=400&tok=f14c4c "image")](/_detail/media/doc/howtos/lirc_alsa.png?id=docs%3Aguide-user%3Ahardware%3Adevolo-stream-radio "media:doc:howtos:lirc_alsa.png")

One drawback for keeping it simple is the power supply. We can just modify our USB audiostick isolating one minijack contact and bridging it to the +5V usb power supply.

[![](/_media/media/doc/howtos/lirc_alsa-audiostick.jpg?w=400&tok=1ab239)](/_detail/media/doc/howtos/lirc_alsa-audiostick.jpg?id=docs%3Aguide-user%3Ahardware%3Adevolo-stream-radio "media:doc:howtos:lirc_alsa-audiostick.jpg")

The circuit then can be wired with a minijack cable. We need a little case for the circuit with the IR module receiver, an ADSL microfilter case is perfect for this purpose (you have for sure tons of them from ISPs).

[![](/_media/media/doc/howtos/lirc_alsa-case1.jpg?w=400&tok=81446a)](/_detail/media/doc/howtos/lirc_alsa-case1.jpg?id=docs%3Aguide-user%3Ahardware%3Adevolo-stream-radio "media:doc:howtos:lirc_alsa-case1.jpg")

## Custom Firmware

Here the custom firmware

→ [openwrt-devolo-stream\_radio-AA\_mod.tar.gz](https://docs.google.com/uc?export=download&id=0B-EMoBe-_OdBeUJWdmtJRXhHcU0 "https://docs.google.com/uc?export=download&id=0B-EMoBe-_OdBeUJWdmtJRXhHcU0")

The idea is to provide a simple firmware, just plug'n play.

- Install the firmware as described in [Devolo dLAN USB Extender](https://oldwiki.archive.openwrt.org/toh/devolo/dlan-usb-extender "https://oldwiki.archive.openwrt.org/toh/devolo/dlan-usb-extender")
- Associate both the Devolo USB extender and Devolo the power line (must be connected to a router with DHCP server and internet connectivity). Just use the button at both devices.
- Power off the Devolo USB extender, plug your USB audio stick, and wait. Once associated with the Power line, it starts playing music automatically from a preinstaled playlist with 11 internet stations.

Demo video

### Configuration

We may want to configure some things in our fresh installed firmware. We need to login via telnet, but probably you don't know the address since the Devolo USB extender got it from a DHCP server, but you can guess it. This firmware has a LAN alias with a static IP

*192.168.10.10*

You can use it for login if you can't manage to use its dynamic IP. Why this rare IP? just for avoiding conflict with regular IPs used commonly by the ISPs routers such as 192.168.1.1.

#### mpd

This is the music player daemon. You shouln't need to configure anything else than the radiostations list. The list is located at  
*/etc/streamradio/playlists/radiostations.m3u*

Look for some interesting radiostations. Choose only mp3 streams.

[vtuner.com](http://vtuner.com/setupapp/guide/asp/BrowseStations/startpage.asp "http://vtuner.com/setupapp/guide/asp/BrowseStations/startpage.asp")

and add them to radiostations.m3u

The mpd configuration file is at  
*/etc/mpd.conf*

#### USB audiostick buttons

They are used to control **mpd**.

- Next radiostation
- Volume UP
- Volume DOWN
- Stop mpd
- Play mpd

Additionally can be configured to send mails with useful info. The configuration file is located at  
*/etc/triggerhappy/triggers.d/audiostick.conf*

#### ssmtp

Our mail sender. Can be used with a gmail account (pop3 enabled). This account is used to send mails to any other account. Can be configured editing the file:  
*/etc/ssmtp/ssmtp.conf*

#### lirc

This is the infrared daemon receiver. Has been built with the audio\_alsa driver. It uses the microphone input for receiving signals from a remote. As described in [lirc audio-alsa](/docs/guide-user/hardware/lirc-audio_alsa "docs:guide-user:hardware:lirc-audio_alsa"). Here we need to configure two files.

- The codes for our remote  
  */etc/lircd.conf*
- The commands associated with our remote  
  */etc/streamradio/lircrc*

#### rc.local

Once the system is fully loaded, it executes custom commands. We use it to start lircd, load playlist, play and so on.  
*/etc/rc.local*

#### Custom scripts

There are two scripts for sending mails with useful info at /etc/streamradio/

- mailsend.sh used to send a mail with the current playing info:
  
  ```
  #!/bin/sh
  killall -s STOP lircd
  mpc --format "From: Devolo streaming radio <yoursenderaccount@gmail.com>\nSubject: song info \n\n Theme:\n\n [[%artist% - ]%title%] \n\n\n\n\n\n\n\n Playing from:\n %file% \n %name%"|head -n 15|ssmtp receiver@anymail.com
  killall -s CONT lircd
  ```
- my\_local\_ip.sh used to send a mail with your IP info (static and dynamic):
  
  ```
  #!/bin/sh
  killall -s STOP lircd
  my_dhcp=`ifstatus lan |grep -m1 \"address\" |sed -e 's/[^[:digit:]|.]//g'`
  my_static=`ifstatus lan2 |grep -m1 \"address\" |sed -e 's/[^[:digit:]|.]//g'`
  echo "From: Devolo streaming radio <yoursenderaccount@gmail.com>
  Subject: my local IP
  My dynamic IP is
  $my_dhcp
   
  My static IP is
  $my_static"|ssmtp receiver@anymail.com
  killall -s CONT lircd
  ```

We need to modify yoursenderaccount@gmail.com and receiver@anymail.com

## Build root

Here the complete modified build root used to build the custom firmware

→ [openwrt-devolo-build\_root-mod\_AA.tar.gz](https://docs.google.com/uc?export=download&id=0B-EMoBe-_OdBVTI1TVo1U0Uxbkk "https://docs.google.com/uc?export=download&id=0B-EMoBe-_OdBVTI1TVo1U0Uxbkk")

Details about mods ←TODO
