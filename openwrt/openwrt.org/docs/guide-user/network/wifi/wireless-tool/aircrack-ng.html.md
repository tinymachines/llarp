# Aircrack

Aircrack is a suite of tools that enables wireless traffic monitoring and penetration/security testing. The official page is [Aircrack](http://www.aircrack-ng.org "http://www.aircrack-ng.org")

## Requirements

- An OpenWrt device that supports monitor and client mode
- aircrack package
- External storage (recommend at least 1GB)

## Installation

Aircrack can easily be installed using the OpenWrt repository already configured by default. See [packages](/packages/start "packages:start") if you need help managing your configured repositories.

Install aircrack by typing:

```
opkg update
opkg install aircrack-ng
```

### Command Line Wireless Tools

Modern releases already have the **iw** and **iwinfo** commands available. Older releases may need a different package such as `wl` (Prism) or kmod-madwifi or wireless-tools (Atheros/MadWIFI).

## Configuration

Now that Aircrack is installed and ready to start capturing traffic, you have to tell your router to listen to all traffic and not just traffic of its own. This is called “monitor mode.” To be able to change channels and sniff on all channels, you must have the router in client mode: [clientmode](/doc/howto/clientmode "doc:howto:clientmode")

### Modern OpenWrt Releases

```
iw dev
```

Another handy command to see which radio you have (for dual-band devices) is

```
iw phy phy0 info
```

Now create the monitor mode device

```
iw phy phy0 interface add mon0 type monitor
```

```
iw dev
```

You should see a mon0 interface.

```
ifconfig mon0 up
```

This enables the device for use.

### Older OpenWrt Releases

Users with a Broadcom chipset need to use the `wl` utility:

```
wl monitor 1
ifup prism0
```

Users with an Atheros chipset need to use `wlanconfig`:

```
wlanconfig ath1 create wlandev wifi0 wlanmode monitor
```

MadWIFI allows you you have virtual interfaces, provided they are on the same channel. This is why ath1 is specified. All Atheros chipset cards have a wifi device, and each device can have multiple ath devices.

## Start Capturing

Begin by changing into the directory that you want to store the dump file in. This is most likely the directory that is either a CIFS or NFS or USB or whatever external storage mount. The dump files can get large, and to capture a useful amount of data you will need more storage than what comes stock on these routers. Another reason and advantage for storing the dump file on another computer is so the processing of the dumpfile can be done in parallel with capturing.

Once you are in the directory that you want to store the dump file in, run the following commands:

```
airodump-ng --ivs --write testcapture --beacons mon0
```

What the above command does is:

- --ivs - Only capture IVS
- --write testcapture - Output to a file testcapture-01.ivs (postfix is added automatically)
- --beacons - Include beacons seen
- mon0 - Use device `mon0`

We want to only write the IVs found because they are the packets that can be used to crack the wireless encryption.

After the command is run the Aircrack program starts to display information about the surrounding networks to the user. The user will see the ESSIDs of the surrounding networks and how many packets those networks are sending.

During capture, the user can run the `aircrack-ng` program on the capture file using a computer with access to the storage (i.e. network share). Using this method, both airodump-ng and aircrack-ng can be run in parallel, without interfering with each other.

Once you have enough packets logged just hit

```
CTRL+C
```

to quit airodump.

## Notes

- If you get stuck on something, there are lots of good resources at the official aircrack [website](http://www.aircrack-ng.org "http://www.aircrack-ng.org")
- Aircrack discussion forums are [here](http://tinyshell.be/aircrackng/forum/ "http://tinyshell.be/aircrackng/forum/")
- You can also join the channel #aircrack-ng on Freenode IRC (irc.freenode.net)
