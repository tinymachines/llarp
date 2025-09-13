# USB mode switch

It's common for 3G/4G USB modems or *dongles* (and some smartphones) to initially appear as a virtual CD-ROM drive offering drivers and utilities to use them on Windows/Mac, so some action is typically needed to switch them to a proper working mode.  
Some USB modems may also need to be switched to another *composition* in order to expose different interfaces.

The [usb-modeswitch](/packages/pkgdata/usb-modeswitch "packages:pkgdata:usb-modeswitch") package includes `usbmode` tool with json-based configuration in contrast to a standard Linux `usb_modeswitch` binary, and a Procd service running to automatically switch USB devices once they are plugged in.

The `/etc/usb-mode.json` configuration file looks partially like shown below:

```
{
	"messages" : [
		"555342431234567800000000000006d0000000000000000000000000000000",
		"5553424312345678000000000000061b004600000000000000000000000000"
],
	"devices" : {
		"03f0:002a": {
			"*": {
				"t_class": 7,
				"msg": [ 0 ],
				"response": true
			}
		},
		"0408:f000": {
			"*": {
				"t_vendor": 1032,
				"t_product": [ 53257 ],
				"msg": [ 1 ]
			}
		}
	}
}
```

`03f0:002a` is a *default vendor* and *product* in hexadecimal notation, as it appears in `lsusb` output or in kernel usb debug, while “msg” is a reference to a specific control message in the “messages” array at the beginning of the file. These messages acting as commands, that will either tell the device to eject the *media* (virtual CD-ROM, etc.) or to switch into another working mode or *composition*. `t_vendor` is a *target vendor* in decimal notation, `t_product` is a *target product* in decimal notation. If you want to know more, look at the content of `/etc/usb-mode.json` file.

In the example above `usbmode` will send a control *message* `555342431234567800000000000006d0000000000000000000000000000000` to USB device with the vendor id `03f0` and product id `002a`. After *modeswitching* this device will stay with the same vendor id and product id, but with target device class number of 7.

Similarly, if USB device with the vendor id and the product id of `0408:f000` is connected to the system, the tool will send a *message* `5553424312345678000000000000061b004600000000000000000000000000` to this device. After *modeswitching* the USB device will change its vendor id and product id to `1032:53257` (in decimal format), that can be converted to hexadecimal as `0408:D009`. Windows *Calculator* application in programmer's mode can be used to perform such conversion. Once *modeswitched* the device should appear in `lsusb` output as `0408:D009`.

Note: the json configuration file is generated automatically from `usb_modeswitch` data files during build process using perl script named `convert-modeswitch.pl`. For diagnostics purposes you can create your own `usb-mode-custom.json` with defined message and devices part and launch the commands:

```
usbmode -l
usbmode -s -v -c /path/to/usb-mode-custom.json
```

Converting the standard usb-modeswitch file to json format can be done in a simple way. The standard usb-modeswitch file (0408:f000) content:

```
# Yota Router (Quanta 1QDLZZZ0ST2)
TargetVendor=0x0408
TargetProduct=0xd009
MessageContent="5553424312345678000000000000061b004600000000000000000000000000"
```

Target vendor (0x0408) is converted to decimal notation to set *t\_vendor* value (1032) and target product (0xd009) is converted to decimal notation to set *t\_product* (53257). There is only one line present in “messages”, so the message index - “msg” - is zero (0). The resulting `usb-mode-custom.json` should look as follows:

```
{
	"messages" : [
		"5553424312345678000000000000061b004600000000000000000000000000"
],
	"devices" : {
		"0408:f000": {
			"*": {
				"t_vendor": 1032,
				"t_product": [ 53257 ],
				"msg": [ 0 ]
			}
		}
	}
}
```

Based on this example, you can create your own `usb-mode-custom.json` file to perform *modeswitching* on unsupported devices for diagnostic purposes.

Also see this thread about [3g/4g USB dongle not showing up](https://forum.openwrt.org/t/3g-4g-usb-dongle-not-showing-up/33926 "https://forum.openwrt.org/t/3g-4g-usb-dongle-not-showing-up/33926") where you can see another example of troubleshooting and creating a new setup for usb-modeswitch.

### sdparm method

This tool is no longer available in OpenWrt, but the same approach can be used to compare configurations pre- and post-switching with `usb-modeswitch`.

This method uses `sdparm` to issue SCSI eject command to the emulated CDROM device. This is enough to put some modems into modem mode (tested on Ovation MC935D).

Before you start, make a note of your modem's Vendor and Product IDs:

```
# cat /proc/bus/usb/devices
...
P:  Vendor=1410 ProdID=5020 Rev= 0.00
S:  Manufacturer=Novatel Wireless, Inc.
...
```

First, find out your device address - in this example it's going to be `sg0`. Then issue the following:

```
sdparm --eject /dev/sg0
```

Then, check for changes of your Product ID:

```
# cat /proc/bus/usb/devices
...
P:  Vendor=1410 ProdID=7001 Rev= 0.00
S:  Manufacturer=Novatel Wireless, Inc.
S:  Product=Qualcomm Configuration
...
I:* If#= 0 Alt= 0 #EPs= 3 Cls=ff(vend.) Sub=ff Prot=ff Driver=(none)
...
```
