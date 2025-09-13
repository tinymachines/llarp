# Wi-Fi toggle

![:!:](/lib/images/smileys/exclaim.svg) **There is a package called `wifitoggle` that does the same thing as the scripts below but is more advanced and has configuration. See [Wifi ON OFF buttons](/docs/guide-user/network/wifi/wifi_toggle "docs:guide-user:network:wifi:wifi_toggle")**

The scripts below allow the use of the SES button to enable or disable the wireless, this is achieved by adding a hotplug handler which reacts on button press events and a toggle script which enables or disabled the wireless depending on the current state.

Note: If you are using wireless encryption, nas and radius daemons will not be turned off during toggle and will continue to occupy CPU/memory. They should not consume too many resources with no client load though.

## Toggle script

### New script

![:!:](/lib/images/smileys/exclaim.svg) *This new revision aims to fix the issues previously noticed with the old script. It also uses the commands* `wifi up` *and* `wifi down` *that are supposed to be the right way to turn on or off the device.*

```
cat << "EOF" > /sbin/woggle
#!/bin/sh
 
device="wl0"
case $(uci get wireless.$device.disabled) in
    0)
        wifi down $device
        echo 0 > /proc/diag/led/ses_white
        echo 2 > /proc/diag/led/wlan
        echo 1 > /proc/diag/led/power
        uci set wireless.$device.disabled=1
 
        echo "Wifi disabled"
    ;;
    1)
        uci set wireless.$device.disabled=0
        wifi up $device
        echo 1 > /proc/diag/led/ses_white
 
        echo "Wifi enabled"
    ;;
esac
EOF
 
chmod +x /sbin/woggle
```

Don't forget to change the value of *device* according to your case.

### Old script

```
cat << "EOF" > /sbin/woggle-old
#!/bin/sh
 
case "$(uci get wireless.@wifi-device[0].disabled)" in
    1)
        uci set wireless.@wifi-device[0].disabled=0
        wifi
        echo 1 > /proc/diag/led/ses_white
    ;;
    *)
        uci set wireless.@wifi-device[0].disabled=1
        wifi
        echo 0 > /proc/diag/led/ses_white
        echo 2 > /proc/diag/led/wlan
    ;;
esac
EOF
 
chmod +x /sbin/woggle-old
```

## Hotplug handler

To get hotplug working, run the copy-pastethe code:

```
mkdir -p /etc/hotplug.d/button
cat << "EOF" > /etc/hotplug.d/button/01-radio-toggle
if [ "$BUTTON" = "ses" -a "$ACTION" = "pressed" ] ; then
        ( sleep 1; /sbin/woggle ) &
fi
EOF
```

Now, every time you want to turn the wireless on or off, you can press the button on the router, or you can issue a `woggle` command from the OpenWrt shell.
