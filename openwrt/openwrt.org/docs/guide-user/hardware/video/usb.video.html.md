# USB Video Support

The word “video” can refer to

1. a video card aka graphics card = graphic adapter
2. a video accelerator card = DE-/CODEC accelerator
3. a **video camera**. This page is all about OpenWrt support for **web cams** and **similar devices** (i.e. something with a video stream, e.g. a **TV card**)!

## Preparation

Please inform yourself upstream:

1. [http://linuxtv.org/wiki/index.php/Webcam\_Devices](http://linuxtv.org/wiki/index.php/Webcam_Devices "http://linuxtv.org/wiki/index.php/Webcam_Devices") teaches us, that there are four types of web cams:
   
   1. those that have *UVC support* →[Linux UVC driver and tools](http://www.ideasonboard.org/uvc/ "http://www.ideasonboard.org/uvc/")
   2. those that have *GSPCA support* →[http://linuxtv.org/wiki/index.php/Gspca](http://linuxtv.org/wiki/index.php/Gspca "http://linuxtv.org/wiki/index.php/Gspca")
   3. those that have *out-of-tree support*
   4. those that have *no Linux support*
2. Then there is the framework [Video4Linux](https://en.wikipedia.org/wiki/Video4Linux "https://en.wikipedia.org/wiki/Video4Linux") and a whole load of applications that work with V4L version 1 and/or version 2.
   
   1. [The Video4Linux2 API: an introduction](http://lwn.net/Articles/203924/ "http://lwn.net/Articles/203924/")
   2. [http://linuxtv.org/wiki/index.php/Main\_Page](http://linuxtv.org/wiki/index.php/Main_Page "http://linuxtv.org/wiki/index.php/Main_Page")
   3. [V4L2 API Specification](http://v4l2spec.bytesex.org/spec/ "http://v4l2spec.bytesex.org/spec/")

### Prerequisites

1. Follow [usb-installing](/docs/guide-user/storage/usb-installing "docs:guide-user:storage:usb-installing") to obtain basic USB support
2. Plug the USB webcam of your choice into the USB port of your OpenWrt router

### Required Packages

Name Depends Size Description Basic stuff kmod-video-core kmod-i2c-core 40159 Kernel modules for Video4Linux support kmod-video-pwc kmod-usb-core,  
kmod-video-core 30274 Kernel modules for supporting Philips USB based cameras. kmod-video-uvc kmod-usb-core,  
kmod-video-core,  
kmod-input-core 35971 Kernel modules for supporting [USB Video Class (UVC)](https://en.wikipedia.org/wiki/USB%20video%20device%20class "https://en.wikipedia.org/wiki/USB video device class") devices. →[**Linux UVC driver and tools**](http://www.ideasonboard.org/uvc/ "http://www.ideasonboard.org/uvc/") kmod-video-sn9c102 kmod-usb-core,  
kmod-video-core 32973 Kernel modules for supporting SN9C102 camera chips. kmod-video-cpia2 kmod-usb-core,  
kmod-video-core 20077 Kernel modules for supporting CPIA2 USB based cameras. [cpia2\_overview.txt](http://www.mjmwired.net/kernel/Documentation/video4linux/cpia2_overview.txt "http://www.mjmwired.net/kernel/Documentation/video4linux/cpia2_overview.txt") kmod-i2c-core -- 5076 Kernel modules for [I²C](https://en.wikipedia.org/wiki/I%C2%B2C "https://en.wikipedia.org/wiki/I²C") support GSPCA stuff kmod-video-gspca-core kmod-usb-core, kmod-video-core 14450 Kernel modules for supporting [GSPCA](http://www.linuxjournal.com/video/get-your-webcam-working-gspca "http://www.linuxjournal.com/video/get-your-webcam-working-gspca") based webcam devices. Note this is just the core of the driver, please additionally select the submodule that supports your webcam. [gspca.txt](http://www.mjmwired.net/kernel/Documentation/video4linux/gspca.txt "http://www.mjmwired.net/kernel/Documentation/video4linux/gspca.txt") kmod-video-gspca-ov519 kmod-video-gspca-core 19858 The OV519 USB Camera Driver (ov519) kernel module. kmod-video-gspca-t613 kmod-video-gspca-core 7556 The T613 (JPEG Compliance) USB Camera Driver (t613) kernel module. kmod-video-gspca-ov534 kmod-video-gspca-core 6753 The OV534 USB Camera Driver (ov534) kernel module. kmod-video-gspca-tv8532 kmod-video-gspca-core 3053 The TV8532 USB Camera Driver (tv8532) kernel module. kmod-video-gspca-conex kmod-video-gspca-core 6425 The Conexant Camera Driver (conex) kernel module. kmod-video-gspca-stk014 kmod-video-gspca-core 4680 The Syntek DV4000 (STK014) USB Camera Driver (stk014) kernel module. kmod-video-gspca-etoms kmod-video-gspca-core 5203 The Etoms USB Camera Driver (etoms) kernel module. kmod-video-gspca-mars kmod-video-gspca-core 4104 The Mars USB Camera Driver (mars) kernel module. kmod-video-gspca-sq905 kmod-video-gspca-core 3939 The SQ Technologies SQ905 based USB Camera Driver (sq905) kernel module. kmod-video-gspca-vc032x kmod-video-gspca-core 12230 The VC032X USB Camera Driver (vc032x) kernel module. kmod-video-gspca-sq905c kmod-video-gspca-core 3887 The SQ Technologies SQ905C based USB Camera Driver (sq905c) kernel module. kmod-video-gspca-stv06xx kmod-video-gspca-core 12879 The STV06XX USB Camera Driver (stv06xx) kernel module. kmod-video-gspca-finepix kmod-video-gspca-core 3473 The Fujifilm FinePix USB V4L2 driver (finepix) kernel module. kmod-video-gspca-mr97310a kmod-video-gspca-core 6477 The Mars-Semi MR97310A USB Camera Driver (mr97310a) kernel module. kmod-video-gspca-spca500 kmod-video-gspca-core 7110 The SPCA500 USB Camera Driver (spca500) kernel module. kmod-video-gspca-spca501 kmod-video-gspca-core 5085 The SPCA501 USB Camera Driver (spca501) kernel module. kmod-video-gspca-pac7311 kmod-video-gspca-core 4984 The Pixart PAC7311 USB Camera Driver (pac7311) kernel module. kmod-video-gspca-spca505 kmod-video-gspca-core 3924 The SPCA505 USB Camera Driver (spca505) kernel module. kmod-video-gspca-spca506 kmod-video-gspca-core 4604 The SPCA506 USB Camera Driver (spca506) kernel module. kmod-video-gspca-spca508 kmod-video-gspca-core 4752 The SPCA508 USB Camera Driver (spca508) kernel module. kmod-video-gspca-m5602 kmod-video-gspca-core 18579 The ALi USB m5602 Camera Driver (m5602) kernel module. kmod-video-gspca-zc3xx kmod-video-gspca-core 16235 The ZC3XX USB Camera Driver (zc3xx) kernel module. kmod-video-gspca-sonixb kmod-video-gspca-core 8014 The SONIX Bayer USB Camera Driver (sonixb) kernel module. kmod-video-gspca-sonixj kmod-video-gspca-core 13898 The SONIX JPEG USB Camera Driver (sonixj) kernel module. kmod-video-gspca-spca561 kmod-video-gspca-core 5648 The SPCA561 USB Camera Driver (spca561) kernel module. kmod-video-gspca-pac207 kmod-video-gspca-core 4490 The Pixart PAC207 USB Camera Driver (pac207) kernel module. kmod-video-gspca-sunplus kmod-video-gspca-core 8020 The SUNPLUS USB Camera Driver (sunplus) kernel module. kmod-video-gspca-sn9c20x kmod-video-gspca-core 12491 The SN9C20X USB Camera Driver (sn9c20x) kernel module.

## Installation

Install `kmod-video-uvc` or `kmod-video-gspca-core` + matching driver via [opkg](/docs/guide-user/additional-software/opkg "docs:guide-user:additional-software:opkg").

## Configuration

There's nothing to configure.

## Applications

Application can work directly with the driver, or with V4L1/V4L2.

- [iptv.mumudvb](/doc/howto/iptv.mumudvb "doc:howto:iptv.mumudvb")

Stuff fswebcam libgd, libpng, libjpeg, zlib 32649 fswebcam is a neat and simple webcam app. It captures images from a V4L1/V4L2 compatible device or file, averages them to reduce noise and draws a caption using the GD Graphics Library which also handles compressing the image to PNG or JPEG. The resulting image is saved to a file or sent to stdio where it can be piped to something like ncftpput or scp. mjpg-streamer libpthread, libjpeg 33738 Streaming application for Linux-UVC compatible webcams  
[Webcam with the Linux UVC driver](/docs/guide-user/hardware/video/webcam "docs:guide-user:hardware:video:webcam") motion libpthread, libjpeg -- [motion](http://man.cx/motion "http://man.cx/motion"), [http://sourceforge.net/projects/motion/](http://sourceforge.net/projects/motion/ "http://sourceforge.net/projects/motion/"), [http://www.lavrsen.dk/foswiki/bin/view/Motion/MotionGuide](http://www.lavrsen.dk/foswiki/bin/view/Motion/MotionGuide "http://www.lavrsen.dk/foswiki/bin/view/Motion/MotionGuide") GStreamer stuff libgstreamer glib2, libpthread, libxml2 320927 GStreamer open source multimedia framework This package contains the GStreamer core library. gst-mod-videomeasure libgstreamer 15779 This package contains the GStreamer videomeasure support plugin. gst-mod-videosignal libgstreamer 8156 This package contains the GStreamer videosignal support plugin. gst-mod-videotestsrc libgstreamer, liboil 17585 This package contains the GStreamer video test plugin. gst-mod-mpeg4videoparse libgstreamer 7536 This package contains the GStreamer mpeg4videoparse support plugin. gst-mod-mpegvideoparse libgstreamer 9305 This package contains the GStreamer mpegvideoparse support plugin. libgstvideo libgstreamer 10410 This package contains the GStreamer video library.

## Notes

- See also: [Gentoo-Wiki: Linux WebCam Support](http://en.gentoo-wiki.com/wiki/Webcam "http://en.gentoo-wiki.com/wiki/Webcam")
