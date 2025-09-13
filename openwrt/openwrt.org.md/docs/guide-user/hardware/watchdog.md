# Hardware watchdog

While older versions of OpenWrt used the watchdog daemon from BusyBox, all new versions implement the watchdog daemon via procd, which is the init process (PID1). Therefore on modern OpenWrt, you will never see the watchdog process running.

## Supported hardware

Most embedded devices will have their hardware watchdog enabled in the default kernel configuration of their target, which means it will be built-in (no kmod to install, it's always available).

For x86 hardware you have some kmods to choose:

- AMD: [kmod-it87-wdt](/packages/pkgdata/kmod-it87-wdt "packages:pkgdata:kmod-it87-wdt"), [kmod-sp5100-tco](/packages/pkgdata/kmod-sp5100-tco "packages:pkgdata:kmod-sp5100-tco")
- Intel: [kmod-itco-wdt](/packages/pkgdata/kmod-itco-wdt "packages:pkgdata:kmod-itco-wdt")
- Generic: [kmod-w83627hf-wdt](/packages/pkgdata/kmod-w83627hf-wdt "packages:pkgdata:kmod-w83627hf-wdt")

There are also USB-based watchdogs, which will be discussed below in their own sub-section because they are not handled by procd in any way.

The procd watchdog code always uses the primary watchdog device `/dev/watchdog`. You can configure what watchdog that is (i.e. GSC Watchdog or SoC watchdog) by disabling all but the desired watchdog in the kernel configuration, or not installing watchdog kmods for x86 architecture.

## Controlling the watchdog

You can see the current configuration of the watchdog service via ubus:

```
# ubus call system watchdog
{
        "status": "running",
        "timeout": 30,
        "frequency": 5
}
```

If no watchdog is available, the status parameter is `offline`. This could also happen when the hardware watchdog driver is built as kmod, as procd tries to initialize the watchdog before loading kernel modules. In this case, it is possible to start the watchdog afterwards:

```
ubus call system watchdog '{ "stop": false }'
```

While there is no UCI configuration available for these options, you can change them in an rc script such as `/etc/rc.local`.

```
# Change timeout to 60s
ubus call system watchdog '{"timeout":60}'
 
# Change frequency to 1s
ubus call system watchdog '{"frequency":1}'
```

To bypass procd, enable the magicclose feature, stop the service and control the watchdog manually:

```
ubus call system watchdog '{"magicclose":true}'
ubus call system watchdog '{"stop":true}'
while :; do echo 1 > /dev/watchdog; sleep 5; done
```

Note that watchdog will cause a reset after it expires.

## USB watchdogs

USB-based watchdogs are basically a microcontroller over a USB-serial dongle, that will close/open contacts when they trigger. These contacts are usually on a header that can be connected to the Power and Reset switch of the board, or to a relay wired to interrupt the power supply to the device.

These are some photos of the device I am using:

[![](/_media/docs/guide-user/hardware/usb_watchdog.jpg?w=400&tok=2eb3b4)](/_media/docs/guide-user/hardware/usb_watchdog.jpg "docs:guide-user:hardware:usb_watchdog.jpg") [![](/_media/docs/guide-user/hardware/usb_watchdog2.jpg?w=400&tok=ed9dbd)](/_media/docs/guide-user/hardware/usb_watchdog2.jpg "docs:guide-user:hardware:usb_watchdog2.jpg")

This kind of task is trivially easy to also do with an Arduino or Attiny board and some relays.

Some USB-based watchdogs are not using a serial dongle, but show up as USB HID devices and I don't know what is their protocol.

This is a script that will generate a procd service to control one of such USB-serial watchdogs.

```
cat << "EOF" > /etc/usb_watchdog
#!/bin/sh
 
# Watchdog control script for USB-serial based watchdogs
 
# The command to run the watchdog 160 seconds is:
# echo -n -e "\x10" > /dev/ttyUSB0
# The "x10" is 16 in hexadecimal and will tell the watchdog to run for 160 seconds, setting a higher (or lower) time is possible,
# just write a different hexadecimal number, and adjust the number of seconds in the sleep command below.
# DO NOT use a too small time though or the system will not have enough time to fully reboot before the watchdog triggers again.
 
# First we are detecting what usb serial we need to use, to avoid sending commands to the wrong device, like LTE modems.
# The device I used appears like this in dmesg when I connect it:
# [11705.304457] usb 4-1: new full-speed USB device number 2 using uhci_hcd
# [11705.538687] ch341 4-1:1.0: ch341-uart converter detected
# [11705.549626] usb 4-1: ch341-uart converter now attached to ttyUSB0
# So I filter for ch341 serial chips.
 
usb_serial="$(dmesg | sed -n -e "/\sch341.*\stty/s/^.*\s//p")"
cmd="${1:-start}"
 
if [ -z "${usb_serial}" ]
then
    echo "no ch341 serial dongle detected, no watchdog available"
    exit 1
fi
 
case "${cmd}" in
 
(start)
echo "starting usb watchdog service"
 
while [ ! -f /tmp/stop_usb_watchdog ]
do
    echo -n -e "\x10" > /dev/"${usb_serial}"
    sleep 30
done
rm /tmp/stop_usb_watchdog
 
echo "stopping usb watchdog service"
;;
 
(stop)
touch /tmp/stop_usb_watchdog
;;
 
(install)
cat << "EOI" > /etc/init.d/usb_watchdog
#!/bin/sh /etc/rc.common
 
USE_PROCD=1
START=95
STOP=01
 
start_service() {
    procd_open_instance
    procd_set_param command /bin/sh /etc/usb_watchdog
    # If process dies sooner than respawn_threshold, it is considered crashed and after 5 retries the service is stopped
    procd_set_param respawn ${respawn_threshold:-3600} ${respawn_timeout:-5} ${respawn_retry:-5}
    procd_close_instance
}
 
stop_service() {
    /etc/usb_watchdog stop
}
EOI
 
cat << "EOI" > /lib/upgrade/keep.d/usb_watchdog
/etc/init.d/usb_watchdog
/etc/rc.d/
/etc/usb_watchdog
EOI
 
chmod +x /etc/init.d/usb_watchdog
/etc/init.d/usb_watchdog enable
/etc/init.d/usb_watchdog start
;;
 
(remove)
/etc/init.d/usb_watchdog disable
/etc/init.d/usb_watchdog stop
rm -f /etc/init.d/usb_watchdog
rm -f /etc/usb_watchdog
rm -f /lib/upgrade/keep.d/usb_watchdog
;;
 
esac
EOF
chmod +x /etc/usb_watchdog
/etc/usb_watchdog install
```

To install it, write the following commands in your device's command line interface:

```
wget -U "" -O usb-watchdog.sh "https://openwrt.org/_export/code/docs/guide-user/hardware/watchdog?codeblock=3"
. ./usb-watchdog.sh
```

You can then control it as normal for a procd service:

```
/etc/init.d/usb_watchdog
```

This script also writes the system configuration to survive a system upgrade, so you shouldn't need to reinstall it when you upgrade.
