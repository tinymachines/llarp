# Attach functions to a push button

There several ways for controlling buttons in OpenWrt.

- [buttons using procd](#procd_buttons "docs:guide-user:hardware:hardware.button ↵")
- [Hotplug buttons](#hotplug_buttons "docs:guide-user:hardware:hardware.button ↵"), using the hotplug daemon or procd in compatibility mode (hotplug itself was phased out with r36003, circa 2013).
- [HID buttons](#hid_buttons "docs:guide-user:hardware:hardware.button ↵"), using */dev/input/event* with an application like triggerhappy.

![](/_media/meta/icons/tango/dialog-information.png) **Kernel configuration**  
If a target platform is known to support buttons, appropriate kernel modules are selected by default.  
If a platform is not known to support buttons, you are required to install various kernel modules yourself such as `diag`, `input-gpio-buttons`, `gpio-button-hotplug`, and others.  
However, installing various modules will not necessarily yield a successful result.

## procd buttons

Native button handling in procd is handled by scripts in `/etc/rc.button/*`.

These scripts receive the **same** environment as older style [hotplug](/docs/guide-user/base-system/hotplug "docs:guide-user:base-system:hotplug") buttons received.

Button Action Script Environment Script return value Press ACTION=“pressed” Seconds before “timeout” Held “timeout” seconds ACTION=“timeout” SEEN=“&lt;timeout secs&gt;” n/a Release ACTION=“released” SEEN=“&lt;seconds held&gt;” n/a

![:!:](/lib/images/smileys/exclaim.svg) “released” action is sent on release even if “timeout” has been sent.

Unfortunately, it is not particularly easy to know the name of the event that a hardware button will trigger. Buttons are mapped to Linux keys in each device’s specific Devicetree (.dts) file, which you can find in the OpenWrt source code repository.

Then the `gpio-button-hotplug` kernel module translates those key presses into events that you can act on. The most reliable way is to look in `/sys/firmware/devicetree/base/keys`, however the key codes you can find there are all in binary. You can do something like this:

```
find /sys/firmware/devicetree/base/keys -mindepth 1 -type d | while read -r f; do printf '%s: %s\n' $(basename $f) $(hexdump -s2 -e '2/1 "%02x""\n"' $f/linux,code); done
```

to list the buttons that your device has together with the hex values for the key codes they send, and then lookup those hex constants in the table below.

Please consider using these kernel codes when adding support for new devices, they're mapped by the `gpio-button-hotplug` kernel module:

Hex value Kernel code event `0100` BTN\_0 BTN\_0 `0101` BTN\_1 BTN\_1 `0102` BTN\_2 BTN\_2 `0103` BTN\_3 BTN\_3 `0104` BTN\_4 BTN\_4 `0105` BTN\_5 BTN\_5 `0106` BTN\_6 BTN\_6 `0107` BTN\_7 BTN\_7 `0108` BTN\_8 BTN\_8 `0109` BTN\_9 BTN\_9 KEY\_BRIGHTNESS\_ZERO brightness\_zero KEY\_CONFIG config KEY\_COPY copy KEY\_EJECTCD eject KEY\_HELP help `021e` KEY\_LIGHTS\_TOGGLE lights\_toggle KEY\_PHONE phone `0074` **KEY\_POWER** **power** `0164` **KEY\_POWER2** **reboot** `0198` **KEY\_RESTART** **reset** `00f7` **KEY\_RFKILL** **rfkill** KEY\_VIDEO video KEY\_VOLUMEDOWN volume\_down KEY\_VOLUMEUP volume\_up KEY\_WIMAX wwan `00ee` KEY\_WLAN wlan `0211` KEY\_WPS\_BUTTON wps

## Hotplug Buttons

![](/_media/meta/icons/tango/48px-outdated.svg.png) Note that after the introduction of **`procd`** into OpenWrt in [r37132](https://dev.openwrt.org/changeset/37132 "https://dev.openwrt.org/changeset/37132") the package `hotplug2` has been removed from the default packages. However at the time of writing, [r37336: procd: make old button hotplug rules work until all packages are migrated](https://dev.openwrt.org/changeset/37336 "https://dev.openwrt.org/changeset/37336") is still in effect. See also [procd.buttons](#procdbuttons "docs:guide-user:hardware:hardware.button ↵") ![FIXME](/lib/images/smileys/fixme.svg) Please read the articles [wifitoggle](/docs/guide-user/network/wifi/wifitoggle "docs:guide-user:network:wifi:wifitoggle"), [buttons](/toh/tp-link/tl-wr741nd#buttons "toh:tp-link:tl-wr741nd") and [nslu2.hardware.button](/toh/linksys/nslu2/nslu2.hardware.button "toh:linksys:nslu2:nslu2.hardware.button") and eventually merge them into this one article

### Preliminary steps

The first step is to find out the internal name of the button you want to use: some images use generic names such as `BTN_1`, `BTN_2`, others have more specific ones like `reset`, `wps`, etc. Run the following:

```
opkg update
opkg install kmod-button-hotplug
 
mkdir -p /etc/hotplug.d/button
 
cat << "EOF" > /etc/hotplug.d/button/buttons
logger "the button was ${BUTTON} and the action was ${ACTION}"
EOF
```

Now press the button you want to use, then run `logread`.

```
Jan 1 00:01:15 OpenWrt user.notice root: BTN_1
Jan 1 00:01:15 OpenWrt user.notice root: pressed
Jan 1 00:01:16 OpenWrt user.notice root: BTN_1
Jan 1 00:01:16 OpenWrt user.notice root: released
```

`BTN_1` is the name of the button you want to use. If you want or need to use another button, replace every instance of `BTN_1` in the rest of this document with the correct text. From now on, there are several possible approaches: the first uses the `00-button` script from the `atheros` target, the other a simpler shell script.

If you want to run programs from hotplug's scripts you need to be sure `PATH` and the like are initialized properly, scripts invoked by hotplug only have a default env. Especially if you install stuff into nonstandard locations like /opt/usr/bin.

```
source /etc/profile
```

### Using Atheros' 00-button + UCI

```
cat << "EOF" > /etc/hotplug.d/button/00-button
source /lib/functions.sh
 
do_button () {
    local button
    local action
    local handler
    local min
    local max
 
    config_get button "${1}" button
    config_get action "${1}" action
    config_get handler "${1}" handler
    config_get min "${1}" min
    config_get max "${1}" max
 
    [ "${ACTION}" = "${action}" -a "${BUTTON}" = "${button}" -a -n "${handler}" ] && {
        [ -z "${min}" -o -z "${max}" ] && eval ${handler}
        [ -n "${min}" -a -n "${max}" ] && {
            [ "${min}" -le "${SEEN}" -a "${max}" -ge "${SEEN}" ] && eval ${handler}
        }
    }
}
 
config_load system
config_foreach do_button button
EOF
 
uci add system button
uci set system.@button[-1].button="BTN_1"
uci set system.@button[-1].action="pressed"
uci set system.@button[-1].handler="logger BTN_1 pressed"
uci commit system 
```

`button` is the name as the button, `action` is the event (two values: `pressed` and `released`), handler contains the command line to be run when the event is detected (can be a script as well).

You may need to reboot the router the make the change effective (mine would work with the simple shell script just fine but wouldn't budge when using the 00-button script --- *Frex 2011/03/25 22:29*). If this works, you can change the handler to something more useful, and add more button handlers.

### Examples

**Example 1:** *Toggle Wi-Fi radio with a button press*

```
uci add system button
uci set system.@button[-1].button="wps"
uci set system.@button[-1].action="pressed"
uci set system.@button[-1].handler="uci set wireless.@wifi-device[0].disabled='1' && wifi"
uci commit system
```

**Example 2:** *Assign two different functions to the same button: short press VS long press. This relies on tracking the* released *event rather than the* pressed *event.*

```
uci add system button
uci set system.@button[-1].button="BTN_1"
uci set system.@button[-1].action="released"
uci set system.@button[-1].handler="logger timed pressed: 0-3s"
uci set system.@button[-1].min="0"
uci set system.@button[-1].max="3"
uci add system button
uci set system.@button[-1].button="BTN_1"
uci set system.@button[-1].action="released"
uci set system.@button[-1].handler="logger timed pressed: 8-10s"
uci set system.@button[-1].min="8"
uci set system.@button[-1].max="10"
uci commit system
```

**Example 3:** *Unmount USB storage using a long-ish press*

```
uci add system button
uci set system.@button[-1].button="BTN_1"
uci set system.@button[-1].action="released"
uci set system.@button[-1].handler="for i in \$(mount | awk '/dev\/sd[b-z]/{print \$1}'); do umount \${i}; done"
uci set system.@button[-1].min="5"
uci set system.@button[-1].max="10"
uci commit system
```

**Example 4:** *Restore defaults*

```
uci add system button
uci set system.@button[-1].button="reset"
uci set system.@button[-1].action="released"
uci set system.@button[-1].handler="firstboot && reboot"
uci set system.@button[-1].min="5"
uci set system.@button[-1].max="30"
uci commit system
```

**Example 5:** *Toggle Wi-Fi using a script*

```
uci add system button
uci set system.@button[-1].button="wps"
uci set system.@button[-1].action="released"
uci set system.@button[-1].handler="/usr/bin/wifionoff"
uci set system.@button[-1].min="0"
uci set system.@button[-1].max="3"
uci commit system
 
cat << "EOF" > /usr/bin/wifionoff
#!/bin/sh
[ "${BUTTON}" = "BTN_1" ] && [ "${ACTION}" = "pressed" ] && {
    SW="$(uci -q get wireless.@wifi-device[0].disabled)"
    [ "${SW}" = "1" ] \
        && uci set wireless.@wifi-device[0].disabled="0" \
        || uci set wireless.@wifi-device[0].disabled="1"
    wifi
}
EOF
chmod u+x /usr/bin/wifionoff
```

Another option for wifionoff is this script (doesn't store the state in uci, so it remains what is set in the configuration) You can also call this script e.g. from cron, to switch off your wifi at night.

```
cat << "EOF" > /usr/bin/wifionoff
#!/bin/sh
STATEFILE="/tmp/wifionoff.state"
 
if [ "${#}" -eq 1 ]; then
    case "${1}" in
        "up"|"on") GOAL="on" ;;
        "down"|"off") GOAL="off" ;;
    esac
else
    if [ -e "${STATEFILE}" ]; then
	GOAL="on"
    else
        # if the statefile doesn't exist, turn wifi off
        GOAL="off"
    fi
fi
 
if [ "${GOAL}" = "off" ]; then
    /sbin/wifi down
    touch "${STATEFILE}"
else
    /sbin/wifi up
    # file may not exist if we're given args
    rm "${STATEFILE}" 2> /dev/null || true
fi
EOF
chmod u+x /usr/bin/wifionoff
```

**Example 5-bis:** *Toggle only a Wireless Network using a script without disabling the entire Wi-Fi module*

This solution is heavily based on example 5. You need to figure out the name of your Wi-Fi Network configuration to make it work and replace the 3 occurrences of “default\_radio0” in the script by the name of your wireless network configuration (eg. “cfg033579”). “default\_radio0” is the configuration name of the initial default wireless network that existed “out of the box” (on the DIR-610-a1 at least).

One way to find out your Wireless Network configuration name in LuCi is to navigate to the “Wireless Overview” page (Network &gt; Wireless) and edit the wireless network configuration you need to toggle. For example, change temporarily the ESSID value and then click “SAVE” (and *NOT* “SAVE &amp; APPLY”). You will then see the button “UNSAVED CHANGES” in the upper right corner of the interface. Click on it and you should be able to find an entry such as “uci set wireless.cfg033579.ssid='My-Own-Wi-Fi-test'” where “cfg033579” stands for your configuration name that you need to change in the following script.

```
uci add system button
uci set system.@button[-1].button="wps"
uci set system.@button[-1].action="released"
uci set system.@button[-1].handler="/usr/bin/wifinetonoff"
uci set system.@button[-1].min="0"
uci set system.@button[-1].max="3"
uci commit system
 
cat << "EOF" > /usr/bin/wifinetonoff
#!/bin/sh
{
    SW="$(uci -q get wireless.default_radio0.disabled)"
    [ "${SW}" = "1" ] \
        && uci del wireless.default_radio0.disabled \
        || uci set wireless.default_radio0.disabled='1'
    wifi
}
EOF
chmod u+x /usr/bin/wifinetonoff
```

**Example 6:** *Set transmission-daemon alt-speed, enable or disable.Short press will activate alt-speed or longer press will deactivate alt-speed and also turns on qss led about speed status on tl-wr1043nd*

Edit your alt-speed limits from transmission-daemon , *settings.json* file.To execute script, you need to install *transmission-remote* package from opkg.

```
uci add system button
uci set system.@button[-1].button="BTN_1"
uci set system.@button[-1].action="pressed"
uci set system.@button[-1].handler="transmission-remote -as"
uci add system button
uci set system.@button[-1].button="BTN_1"
uci set system.@button[-1].action="pressed"
uci set system.@button[-1].handler="echo 1 > /sys/class/leds/tl-wr1043nd:green:qss/brightness"
uci add system button
uci set system.@button[-1].button="BTN_1"
uci set system.@button[-1].action="released"
uci set system.@button[-1].handler="transmission-remote -AS"
uci set system.@button[-1].min="1"
uci set system.@button[-1].max="4"
uci add system button
uci set system.@button[-1].button="BTN_1"
uci set system.@button[-1].action="released"
uci set system.@button[-1].handler="echo 0 > /sys/class/leds/tl-wr1043nd:green:qss/brightness"
uci set system.@button[-1].min="1"
uci set system.@button[-1].max="4"
uci commit system
```

### TL-WR1043ND v1.x

If you decide to use the `wifitoggle` package, you will need to change a few things on the default configuration. The following will work and make the QSS led blink “slowly” when wifi is on:

```
uci add wifitoggle wifitoggle
uci set wifitoggle.@wifitoggle[0].led_enable_trigger="timer"
uci set wifitoggle.@wifitoggle[0].persistent="1"
uci set wifitoggle.@wifitoggle[0].button="BTN_1"
uci set wifitoggle.@wifitoggle[0].led_sysfs="tl-wr1043nd:green:qss"
uci set wifitoggle.@wifitoggle[0].led_enable_delayon="2000"
uci set wifitoggle.@wifitoggle[0].led_disable_default="1"
uci set wifitoggle.@wifitoggle[0].led_enable_delayoff="3000"
uci set wifitoggle.@wifitoggle[0].timer="0"
uci commit wifitoggle
```

![:!:](/lib/images/smileys/exclaim.svg) *You can probably get similar behaviour with [phy0tpt](/docs/guide-user/base-system/led_configuration#wifiactivity "docs:guide-user:base-system:led_configuration") trigger.*

## HID buttons

### triggerhappy

To manage the router buttons and also other **HID buttons** (i.e pad buttons or keys of an USB device) we can use an application like triggerhappy.

```
# Install packages
opkg update
opkg install triggerhappy kmod-hid
 
# List your available buttons
thd --dump /dev/input/event*
 
# Press your buttons
EV_KEY  KEY_WPS_BUTTON  1       /dev/input/event0
# KEY_WPS_BUTTON        1       command
EV_KEY  KEY_WPS_BUTTON  0       /dev/input/event0
# KEY_WPS_BUTTON        0       command
EV_KEY  KEY_VOLUMEDOWN  1       /dev/input/event1
# KEY_VOLUMEDOWN        1       command
EV_KEY  KEY_VOLUMEDOWN  0       /dev/input/event1
# KEY_VOLUMEDOWN        0       command
 
# Associate your buttons to commands or scripts
cat << "EOF" > /etc/triggerhappy/triggers.d/example.conf
KEY_WPS_BUTTON 1 /etc/mywifiscript.sh
KEY_VOLUMEUP 1 amixer -q set Speaker 3%+
KEY_VOLUMEDOWN 1 amixer -q set Speaker 3%-
EOF
 
# Restart services
service triggerhappy restart
```

Notes:

- triggerhappy repeats commands twice: see bug [https://dev.openwrt.org/ticket/14995](https://dev.openwrt.org/ticket/14995 "https://dev.openwrt.org/ticket/14995")
- kernel modules: **kmod-hid** and **kmod-hid-generic** both should be installed  
  The **kmod-hid-generic** and supposedly also **kmod-usb-hid** kernel module must be installed for buttons on USB devices such as USB sound cards to work in OpenWrt trunk. Only then the /dev/input/event0 node for the buttons was created on the DIR-505 router with attached USB sound card.

```
[   31.720000] input: C-Media USB Headphone Set   as /devices/platform/ehci-platform/usb1/1-1/1-1:1.3/input/input0
[   31.760000] hid-generic 0003:0D8C:000C.0001: input,hidraw0: USB HID v1.00 Device [C-Media USB Headphone Set  ] on usb-ehci-platform-1/input3
[   31.800000] usbcore: registered new interface driver usbhid
[   31.800000] usbhid: USB HID core driver
```

This is also noted in [https://dev.openwrt.org/ticket/12631](https://dev.openwrt.org/ticket/12631 "https://dev.openwrt.org/ticket/12631")

### cmdpad

Another simpler application to manage buttons.

## Sliding switches

Some routers, for example the [TP-Link TL-MR3020](/toh/tp-link/tl-mr3020 "toh:tp-link:tl-mr3020"), have a sliding switch with three positions. These are usually implemented using two GPIOs, meaning OpenWrt interprets a switch like this as two separate push buttons.

The `slide-switch` package (in the packages repo) monitors these push buttons and translates the button states into switch position presses and releases. Buttons scripts, in either procd or hotplug format, can be written for switch positions directly. See the package's [GitHub page](https://github.com/jefferyto/openwrt-slide-switch "https://github.com/jefferyto/openwrt-slide-switch") for more details.
