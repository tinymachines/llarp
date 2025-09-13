# DLNA Media Server

Based on the official DLNA standard, this service streams pictures, videos and music of a given media folder to DLNA-capable entertainment devices on the same network (e.g. modern Smart-TVs)

- The DLNA service is based on an up to date version of [Minidlna (Readymedia)](https://sourceforge.net/projects/minidlna "https://sourceforge.net/projects/minidlna").
- A LuCi web admin GUI package is available, to be found in the Luci “Services” menu, if installed

**Device requirements:**

- Device flash size: &gt;8MB or using extroot recommended (The package and its dependencies take about 3-3.5 MB of total flash space)
- Device memory size: &gt;=64MB RAM recommended (older OpenWrt documentations claim it may run with 32MB as well)

**Possible usage limitations:**  
As LEDE devices usually do not have multimedia-CPUs, it may be recommended, to disable index picture creation on small scale LEDE devices, to avoid doing (J/M)PEG decoding on the device CPU. The streaming itself takes very little to no CPU-cycles on the LEDE device, as the media file decoding is not handled by DLNA on the LEDE device, but by the receiving device.

## Config file location and documentation

- LEDE config file location: `/etc/config/minidlna`
- External link to extensive Ubuntu documentation: [minidlna.conf](http://manpages.ubuntu.com/manpages/cosmic/en/man5/minidlna.conf.5.html "http://manpages.ubuntu.com/manpages/cosmic/en/man5/minidlna.conf.5.html")
- More reading and useful commands: [MiniDLNA Ubuntu community](https://help.ubuntu.com/community/MiniDLNA "https://help.ubuntu.com/community/MiniDLNA")

## Installation

```
opkg update
opkg install minidlna
opkg install luci-app-minidlna
```

- A SmartTV to access the DLNA service has to be in the same network, as SmartTVs automatically issue broadcast messages from time to time, to find DLNA data providers in the same network (if the SmartTV supports DLNA).
- The files available for streaming by this DLNA service will then be visible in the TV specific media browser / TV source selector for viewing.
- It depends on the supported media types of the SmartTV software, whether the SmartTV can decode and show the media files
