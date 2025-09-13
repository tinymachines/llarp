# Webcam with the Linux UVC driver

See [USB Video Support](/docs/guide-user/hardware/video/usb.video "docs:guide-user:hardware:video:usb.video")

[USB video device class](https://en.wikipedia.org/wiki/USB%20video%20device%20class "https://en.wikipedia.org/wiki/USB video device class")

## Prerequisites

1. follow [usb-installing](/docs/guide-user/storage/usb-installing "docs:guide-user:storage:usb-installing")
2. follow [usb.video](/docs/guide-user/hardware/video/usb.video "docs:guide-user:hardware:video:usb.video")

Name Depends Size Description mjpg-streamer libpthread, libjpeg 33738 Streaming application for Linux-UVC compatible webcams

The package [motion](http://man.cx/motion "http://man.cx/motion") is not now available in the OpenWrt repositories. [http://www.lavrsen.dk/foswiki/bin/view/Motion/WebHome](http://www.lavrsen.dk/foswiki/bin/view/Motion/WebHome "http://www.lavrsen.dk/foswiki/bin/view/Motion/WebHome")

## Installation

```
opkg install kmod-video-uvc mjpg-streamer mjpg-streamer-input-http mjpg-streamer-input-uvc
```

## Configuration

→`/etc/config/mjpg-streamer`

Don't forget change option enabled '0' to '1'.

## Usage

- start on boot
  
  ```
  /etc/init.d/mjpg-streamer enable
  ```
- start `mjpg-streamer` right now
  
  ```
  /etc/init.d/mjpg-streamer start
  ```

**NOTE:** You will need to edit the mjpeg config to enable the mjpeg streamer. Manually edit the /etc/config/mjpeg-streamer file.

Now open the URL [http://192.168.1.1:8080/](http://192.168.1.1:8080/ "http://192.168.1.1:8080/") in the Firefox browser or VLC and watch the MJPEG stream (the default username/password is “openwrt”/“openwrt”). In other browsers, scripts, etc., you can use [http://192.168.1.1:8080?action=snapshot](http://192.168.1.1:8080?action=snapshot "http://192.168.1.1:8080?action=snapshot") for taking one image or [http://192.168.1.1:8080?action=stream](http://192.168.1.1:8080?action=stream "http://192.168.1.1:8080?action=stream") for stream of images.

## Performance

mjpeg-streamer fps, CPU load, memory usage, bandwidth at different resolutions:

- [USB HD camera module (vid=05a3, pid=9230)](https://forum.openwrt.org/viewtopic.php?pid=296414#p296414 "https://forum.openwrt.org/viewtopic.php?pid=296414#p296414")
- [Logitech HD Pro C920 (vid=046d, pid=082d)](https://forum.openwrt.org/viewtopic.php?pid=296534#p296534 "https://forum.openwrt.org/viewtopic.php?pid=296534#p296534")

## Embedding video stream into simple webpages

- Download a package located [here](http://mjpg-streamer.svn.sourceforge.net/viewvc/mjpg-streamer/mjpg-streamer/www/ "http://mjpg-streamer.svn.sourceforge.net/viewvc/mjpg-streamer/mjpg-streamer/www/") and unpack it into /www/webcam\_www directory.
- Edit /etc/init.d/mjpg-streamer - find this line in function start():

```
[ $enabled -gt 0 -a -c $device ] && sleep 3 && $SSD -S -m -p $PIDF -q -x $PROG -- --input "input_uvc.so --device $device --fps $fps --resolution $resolution" --output "output_http.so --port $port" &
```

and add *-w /www/webcam\_www* behind --output “output\_http.so. Now it should look like this:

```
[ $enabled -gt 0 -a -c $device ] && sleep 3 && $SSD -S -m -p $PIDF -q -x $PROG -- --input "input_uvc.so --device $device --fps $fps --resolution $resolution" --output "output_http.so -w /www/webcam_www --port $port" &
```

- Now restart mjpg-streamer and open the URL [http://192.168.1.1:8080/](http://192.168.1.1:8080/ "http://192.168.1.1:8080/") in your web browser.

## Controlling exposure, color balance, etc.

The opkg version of mjpg-streamer has no control options for the camera. If you want to control exposure, brightness and other options you'll need to install uvcdynctrl.

Install uvcdynctrl

```
opkg install uvcdynctrl
```

List available devices.

```
/usr/bin/uvcdynctrl -l
```

List available control options.

```
/usr/bin/uvcdynctrl -c

Listing available controls for device video0:
  Brightness
  Contrast
  Saturation
  Hue
  White Balance Temperature, Auto
  Gamma
  Power Line Frequency
  White Balance Temperature
  Sharpness
  Backlight Compensation

```

Create a configuration file based on the current running values.

```
/usr/bin/uvcdynctrl -W /etc/config/uvcdynctrl
```

Load a configuration file, which can be edited.

```
/usr/bin/uvcdynctrl -L /etc/config/uvcdynctrl
```

The above can be added to /etc/rc.local, via the GUI or command line to load settings required for your camera. I use the above to enable auto exposure and auto white balance which would otherwise be disabled from cold a start.

## Webcam Pan and Tilt Example with Microprocessor

Here is a writeup of using openWrt for a pan and tilt camera. The devices were NSLU2 for openWrt and Picaxe for microcontroller, but the idea is the same with arduino as micro and other openWrt devices:

[http://www.picaxeforum.co.uk/showthread.php?13705](http://www.picaxeforum.co.uk/showthread.php?13705 "http://www.picaxeforum.co.uk/showthread.php?13705")

Grey day today here in Nova Scotia, you can see at [http://www.lyzby.com/cam.html](http://www.lyzby.com/cam.html "http://www.lyzby.com/cam.html")

## Troubleshooting

If the control page doesn't contain any of the controls, edit the file /etc/init.d/mjpg-streamer and replace these lines

```
service_start /usr/bin/mjpg_streamer --input "input_uvc.so \
                --device $device --fps $fps --resolution $resolution" \           
                --output "output_http.so --www $www --port $port"
```

by (on a single line )

```
service_start /usr/bin/mjpg_streamer --input "input_uvc.so --device $device --fps $fps --resolution $resolution" --output "output_http.so --www $www --port $port"
```

The command `mjpg_streamer -h` give you usage information and examples.

If your webcam is an uvc supported by V4L but you cannot get an image (white page), you may check that webcam output is not YUV only like output below:

```
root@OpenWrt:~# v4l2-ctl -V
Format Video Capture:
        Width/Height  : 320/240
        Pixel Format  : 'YUYV'
        Field         : None
        Bytes per Line: 640
        Size Image    : 153600
        Colorspace    : SRGB
```

The package `uvc-streamer` is no longer in the OpenWrt repositories.

- [https://dev.openwrt.org/browser/packages/multimedia/uvc-streamer/files/uvc-streamer.init?rev=10127](https://dev.openwrt.org/browser/packages/multimedia/uvc-streamer/files/uvc-streamer.init?rev=10127 "https://dev.openwrt.org/browser/packages/multimedia/uvc-streamer/files/uvc-streamer.init?rev=10127")
- [https://dev.openwrt.org/changeset/17003/packages/multimedia/uvc-streamer/files/uvc-streamer.init](https://dev.openwrt.org/changeset/17003/packages/multimedia/uvc-streamer/files/uvc-streamer.init "https://dev.openwrt.org/changeset/17003/packages/multimedia/uvc-streamer/files/uvc-streamer.init")

## Link Dump

- [http://wiki.leipzig.freifunk.net/Diskussion:Backfire#quickcam\_pro\_5000](http://wiki.leipzig.freifunk.net/Diskussion:Backfire#quickcam_pro_5000 "http://wiki.leipzig.freifunk.net/Diskussion:Backfire#quickcam_pro_5000")
