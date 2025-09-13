# Bluetooth presence detection

Using a bluetooth USB dongle for a presence detection system to activate a relay by using a GPIO (or doing anything else), when a bluetooth device is detected, for example your phone.

**Note:** The script simply scans for any bluetooth device in range, so there is no need of pairing or trusting the device you want to detect.

prerequisites:

```
opkg install kmod-btusb kmod-bluetooth bluez-libs bluez-utils kmod-usb-core kmod-usb-uhci kmod-usb2 usbutils
```

start bluetooth:

```
service dbus start
service bluetoothd start
/usr/bin/hciconfig hci0 up
```

**Note:** To enable bluetooth at boot put the above three lines in the `/etc/rc.local` file

To scan for remote devices and to discover your device MAC Address, put your device in “discoverable mode” and use the following command:

```
hcitool scan
```

In my case the desired MAC Address is 30:21:15:13:9C:29

**Note:** The device should remain in “discoverable mode”, if you do not want to let your device discoverable, you need to pair it and trust it.

to pair and trust your device do the following:

```
 bluetoothctl pair 30:21:15:13:9C:29
 bluetoothctl trust 30:21:15:13:9C:29
```

to check if the device has been paired:

```
bluetoothctl paired-devices
```

**Example:**

```
root@OpenWrt:~# bluetoothctl paired-devices
Device 38:2D:E8:49:C1:87 Galaxy J5
Device 30:21:15:13:9C:29 BT-888
```

The script: **nano /root/check\_presence\_bt.sh**

```
#!/bin/sh
# Bluetooth Presence Detection
# By Lovisolo P.M. - parknat12@yahoo.com
# my OpenWrt, Raspberry and Linux, personal forum: http://forum.49v.com
#
while :
do
# scan for bluetooth devices and put the result into a variable:
c=$(/usr/bin/hcitool scan)
#
# check for a specific MAC ADDRESS presence:
if [ `echo $c | grep -c "30:21:15:13:9C:29" ` -gt 0 ]
then
/bin/echo 'Device detected, relay is ON'
/bin/echo 1 > /sys/class/gpio/gpio1/value # you may need to change this depending on your router
# you may add here a command or a script to be executed when the device is available
else
/bin/echo 'Device is off or out of range, relay is OFF'
/bin/echo 0 > /sys/class/gpio/gpio1/value # you may need to change this depending on your router
# you may add here a command or a script to be executed when the device is unavailable
fi
done
# eof
```

give the right permissions to the script:

```
chmod 755 /root/check_presence_bt.sh
```

test it:

```
/bin/sh /root/check_presence_bt.sh
```

to launch the scan every minute, edit crontab:

```
nano /etc/crontabs/root
```

and insert the following:

```
*/1 * * * * /bin/sh /root/check_presence_bt.sh
```
