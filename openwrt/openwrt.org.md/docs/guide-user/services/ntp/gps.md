# Stratum 1 NTP server using USB GPS

**The main question is:** How to feed GPS time to ntpd?

There is significant delay in the serial-to-usb and usb-to-data connection. This approach may be off by hundreds of milliseconds. Most GPS-sync is done through GPIO interrupts off the PPS output directly.

Please realize that connecting a consumer-grade (designed for location, not for time keeping) GPS unit over USB serial does not have the accuracy of “proper” GPS synchronization due to significant and inconsistent delays in the serial line itself, as well as in the USB system. Your notion of time will likely be delayed by tens of milliseconds if not hundreds of milliseconds. Any such-configured NTP server certainly can serve as a backup for local timekeeping when Internet connectivity is not available, ***but should never be advertised on the Internet as a Stratum 1 clock.***

Proper GPS synchronization uses a PPS output (or similar) from the device, fed directly into an interrupt-generating line, for example a GPIO or parallel port. A GPSDO (GPS Disciplined Oscillator) is typically used which locks a temperature-compensated oscillator to the GPS time and provides a stable, reliable reference.

Below you find examples for some devices users have successfully got to run with LEDE. Depending on your special USB GPS dongle, you have to follow the one or the other instruction. If you get some other GPS device to work, please add a short howto to this page.

## VK-172 USB GPS

- Source: [https://forum.openwrt.org/t/lede-as-stratum-1-ntp-server-using-usb-gps/1997](https://forum.openwrt.org/t/lede-as-stratum-1-ntp-server-using-usb-gps/1997 "https://forum.openwrt.org/t/lede-as-stratum-1-ntp-server-using-usb-gps/1997")
- Source: [https://forum.openwrt.org/viewtopic.php?id=61161](https://forum.openwrt.org/viewtopic.php?id=61161 "https://forum.openwrt.org/viewtopic.php?id=61161")
- See also [ntpd](/docs/ntpd "docs:ntpd")

**VK-172** is a widely available USB GPS dongle (as of 03/2017: amazon, ebay, banggood, aliexpress, ...), which is easy to handle in OpenWrt/LEDE.

**USBID:** `1546:01a7 U-Blox AG`

1. Install the following packages:
   
   - `kmod-usb-acm` # for vk-172 gps dongle
   - `gpsd` # supports various nmea/binary gps protocols
   - `gpsd-clients` # some clients for testing (cgps, gpspipe, ...)
   - `ntpd` # real ntpd to replace busybox
   - `ntp-utils` # ntpq needed for testing ntp
2. Plug in your USB GPS dongle
3. Check for presence of `/dev/ttyACM0`
   
   ```
   ls -l /dev/ttyACM0
   ```
4. Edit `/etc/config/gpsd` and set device to `/dev/ttyACM0`
   
   ```
   config gpsd core
       option device           "/dev/ttyACM0"
       option port             "2947"
       option listen_globally  "false"
       option enabled          "true"
   ```
   
   Set `listen_globally` to true to enable remote access to gpsd. If remote access is not desired, set to false.
5. edit `/etc/init.d/ntpd` and add the marked lines [1)](#fn__1):
   
   ```
   [...]
           emit "\n# No limits for local monitoring"
           emit "restrict 127.0.0.1"
           emit "restrict -6 ::1\n"
   
           emit "\n# GPS"                                <--- add this line
           emit "server 127.127.28.0 minpoll 4 prefer"   <--- add this line
           emit "fudge 127.127.28.0 refid GPS\n"         <--- add this line
   [...]
   ```
6. Disable sysntpd
   
   ```
   /etc/init.d/sysntpd stop
   /etc/init.d/sysntpd disable
   ```
7. Restart ntpd + gpsd
   
   ```
   killall -9 gpsd ntpd
   /etc/init.d/gpsd start && sleep 2 && /etc/init.d/ntpd start
   ```
8. Check gps function
   
   ```
   cgps -s -u m
   gpspipe -v -r /dev/ttyACM0
   ```
9. Check ntp function
   
   ```
   ntpq -p
   ```

See also

- [http://man.cx/xgps](http://man.cx/xgps "http://man.cx/xgps")
- [http://man.cx/gpsd(1)](http://man.cx/gpsd%281%29 "http://man.cx/gpsd(1)") (cgps, xgps manpage)
- [http://manpages.ubuntu.com/manpages/trusty/man1/gps.1.html](http://manpages.ubuntu.com/manpages/trusty/man1/gps.1.html "http://manpages.ubuntu.com/manpages/trusty/man1/gps.1.html")
- [http://www.catb.org/gpsd/troubleshooting.html](http://www.catb.org/gpsd/troubleshooting.html "http://www.catb.org/gpsd/troubleshooting.html")

## Globalsat USB GPS

Source: [https://forum.openwrt.org/t/lede-as-stratum-1-ntp-server-using-usb-gps/1997](https://forum.openwrt.org/t/lede-as-stratum-1-ntp-server-using-usb-gps/1997 "https://forum.openwrt.org/t/lede-as-stratum-1-ntp-server-using-usb-gps/1997")

**Globalsat BU-353** USB GPS receiver originally used the SiRF Star III chipset, now also available with the SiRF Star IV chipset which offers enhanced performance (BU-353-S4 variant). Both versions use the Prolific PL2303 serial/USB chipset. This howto was tested with the original version. It is a high-quality device, readily available (Ebay etc.) for around $30.

**USBID:** `067B:2303`

1. Install the following packages:
   
   ```
   opkg update
   opkg install kmod-usb-core kmod-usb2 kmod-usb-serial-pl2303
   opkg install ntpd ntp-utils ntpdate
   ```
2. Insert USB device, check for presence of: `/dev/ttyUSB0`
3. Edit `/etc/init.d/ntpd`, add:
   
   ```
   ln -sf /dev/ttyUSB0 /dev/gps0
   ```
4. Edit `/etc/ntp.conf`, uncomment:
   
   ```
   server 127.127.20.0 minpoll 4 prefer
   fudge 127.127.20.0 flag3 1 flag2 0
   ```
5. Stop and disable Busybox ntpd service:
   
   ```
   /etc/init.d/sysntpd stop
   /etc/init.d/sysntpd disable
   ```
6. Start and enable ISC ntpd service:
   
   ```
   /etc/init.d/ntpd start
   /etc/init.d/ntpd enable
   ```
7. Check proper function:
   
   ```
   root@c-fw:~# ntpq -p
        remote           refid      st t when poll reach   delay   offset  jitter
   ==============================================================================
   *GPS_NMEA(0)     .GPS.            0 l    5   16  377    0.000    2.541   5.297
   ```

This is just the basic setup, further work may be needed to tailor it for a specific environment, security considerations etc. etc.

[1)](#fnt__1)

[https://forum.openwrt.org/t/lede-as-stratum-1-ntp-server-using-usb-gps/1997/22?u=tmomas](https://forum.openwrt.org/t/lede-as-stratum-1-ntp-server-using-usb-gps/1997/22?u=tmomas "https://forum.openwrt.org/t/lede-as-stratum-1-ntp-server-using-usb-gps/1997/22?u=tmomas")
