# LED Configuration

The LED configuration is located in **system** uci subsystem, and written in the ***/etc/config/system*** file.

Basic led configuration is available via LuCI on the System &gt; LED Configuration page.

## Led section

The led section contains settings that apply to non-default leds.  
Default leds are usually power on, ethernet port activity, usb port activity, and wifi radio activity.

This is an example of leds on a tp-link router with usb port.

```
root@lede:/# uci show system | grep "system.led"
system.led_usb=led
system.led_usb.name='USB'
system.led_usb.sysfs='tp-link:green:usb'
system.led_usb.trigger='usbdev'
system.led_usb.interval='50'
system.led_usb.dev='1-1'
system.led_wlan=led
system.led_wlan.name='WLAN'
system.led_wlan.sysfs='tp-link:green:wlan'
system.led_wlan.trigger='phy0tpt'
```

```
root@lede:/# cat /etc/config/system
config led 'led_usb'
        option name 'USB'
        option sysfs 'tp-link:green:usb'
        option trigger 'usbdev'
        option interval '50'
        option dev '1-1'

config led 'led_wlan'
        option name 'WLAN'
        option sysfs 'tp-link:green:wlan'
        option trigger 'phy0tpt'
```

## How to add Leds to this section

All LEDs are represented by entries in the *sys* filesystem. You can check which LEDs are available in the ***/sys/class/leds*** directory.

The name of an entry typically consists of the name of the hardware providing the LED (the router model), the color of the LED, and it’s designation (usually the label on the case).  
Some LEDs can show different colors. In this case, you will find one entry per color.

```
root@lede:/# ls /sys/class/leds/
tp-link:green:qss     tp-link:green:usb
tp-link:green:system  tp-link:green:wlan
```

The LED can be controlled by various events in the system, which is selected by the *trigger* option. Depending on the trigger, additional options must be specified. First of all, you need to know which triggers are available for a led, to do that simply look at the *trigger* file of that led. Example:

```
root@lede:/# cat /sys/class/leds/tp-link:green:qss/trigger
[none] switch0 timer default-on netdev usbdev phy0rx phy0tx phy0assoc phy0radio phy0tpt 
```

If we wanted to (temporarily) assign a **default-on** trigger to the led, we would write

```
root@lede: echo "default-on" > /sys/class/leds/tp-link:green:qss/trigger
```

You can confirm that you changed this by using cat again, you will see it has changed and the selected trigger is highlighted.

```
root@lede:/# cat /sys/class/leds/tp-link:green:qss/trigger
none switch0 timer [default-on] netdev usbdev phy0rx phy0tx phy0assoc phy0radio phy0tpt 
```

Now, this change will be lost on reboot, if you want to make a permanent change, you need to add the trigger in uci configuration.

If you have already a section in uci configuration that shows the led you want to set up, you just need to add the trigger.

For example, if you want change the trigger assigned to tp-link:green:wlan into “default-on” and you already have a block of options for it like this when you write **uci show system | grep “system.led”** (you can have more or less, it may also not have a trigger already assigned).

```
system.led_wlan=led
system.led_wlan.name='WLAN'
system.led_wlan.sysfs='tp-link:green:wlan'
system.led_wlan.trigger='phy0tpt'
```

then you can write

```
uci set system.led_wlan.trigger='default-on'
uci commit
```

If you don't have any configuration for it, you can add it and the trigger by editing the following example text (that sets wps led as “default-on” and then copy-pasting it whole in the terminal window.

```
rule_name=$(uci add system led_wps) 
uci batch <<EOF set system.$rule_name.name='WPS'
set system.$rule_name.sysfs='tp-link:green:wps'
set system.$rule_name.trigger='default-on'
EOF
uci commit
```

You can confirm the changes by running `service led restart`.

## Led triggers

Now we explain in detail what each trigger does.

### None

The LED is always in default state. Unlisted LEDs are default OFF, so this is only useful to declare an LED to be always ON.

Name Type RequiredDefault Description *default*integerno 0 LED state before trigger: *0* means OFF and *1* means ON *sysfs* string yes *(none)*LED device name *trigger*string yes *(none)**none*

### Switch Connectivity

The LED is on if a link on one of the configured switch ports is established.

Name Type RequiredDefault Description *default* integerno 0 LED state before trigger: *0* means OFF and *1* means ON *sysfs* string yes *(none)*LED device name *port\_mask*integerno 0 Hexadecimal bit mask that encodes the regarded switch ports *speed\_mask*integer no *(none)*Hexadecimal bit mask that filters ethernet speeds *trigger* string yes *(none)**switch0*

Consider for example a `port_mask` of `0x1e`, which is `00011110` in binary. From right to left, this excludes CPU, includes four switch ports and sets the remaining bits to 0 to exclude further ports (e.g. because there are no more physical ports).

`speed_mask` assigns a bit for standard BASE-T speeds. With this it's possible to trigger an LED only on specific speeds, for example amber for 100mbps and green for gigabit.

Bit assignments for `speed_mask` are as follows:

- \[0] 0x01 - Unknown speed or cable/link problem
- \[1] 0x02 - 10BASE-T
- \[2] 0x04 - 100BASE-T
- \[3] 0x08 - 1000BASE-T
- bits 4-7 reserved for future expansion and dont do anything.

For example a `speed_mask` of `0x0C`, which is `00001100` in binary, will only trigger the LED when the speed is 100BASE-T or 1000BASE-T. We can then apply the inverse `0x03` (binary `00000011`) to another LED, effectively getting different colors/leds to flash depending on the connection speed.

### Timer

The LED blinks with the configured on/off frequency.  
If not installed already, install it with:

```
root@lede:/# opkg install kmod-ledtrig-timer
```

Name Type RequiredDefault Description *default* integerno 0 LED state before trigger: *0* means OFF and *1* means ON *delayoff*integeryes *(none)*How long (in milliseconds) the LED should be off. *delayon* integeryes *(none)*How long (in milliseconds) the LED should be on. *sysfs* string yes *(none)*LED device name *trigger* string yes *(none)**timer*

### Default-on

The LED is ON. Deprecated, use default=1 trigger=none instead. If not installed already, install it with:

```
root@lede:/# opkg install kmod-ledtrig-default-on 
```

Name Type RequiredDefault Description *default*integerno 0 LED state before trigger: *0* means OFF and *1* means ON *sysfs* string yes *(none)*LED device name *trigger*string yes *(none)**default-on*

### Heartbeat

The LED flashes to simulate actual heart beat *thump-thump-pause*. The frequency is in direct proportion to 1-minute average CPU load. If not installed already, install it with:

```
root@lede:/# opkg install kmod-ledtrig-heartbeat
```

Name Type RequiredDefault Description *default*integerno 0 LED state before trigger: *0* means OFF and *1* means ON *sysfs* string yes *(none)*LED device name *trigger*string yes *(none)**heartbeat*

### Flash Writes

The LED flashes as data is written to flash memory.

Name Type RequiredDefault Description *default*integerno 0 LED state before trigger: *0* means OFF and *1* means ON *sysfs* string yes *(none)*LED device name *trigger*string yes *(none)**nand-disk*

### Network Activity

The LED flashes with link status and/or send and receive activity on the configured interface. If not installed already, install it with:

```
root@lede:/# opkg install kmod-ledtrig-netdev
```

Name Type RequiredDefault Description *default*integerno 0 LED state before trigger: *0* means OFF and *1* means ON *dev* string yes *(none)*Name of the network interface which status should be reflected *mode* string yes *(none)*One or more of *link*, *tx*, or *rx*, seperated by spaces *sysfs* string yes *(none)*LED device name *trigger*string yes *(none)**netdev* *interval*integerno *(none)*The duration of the LED blink in milliseconds. For example: *50*

### WiFi Activity triggers

The LED flashes on events triggered in physical interface, rather than in software network interface. Besides *phy* triggers have more events, it also provides possibility of static LED setup in case you want to monitor your 2.4 GHz radio (*phy0* usually) and 5 GHz radio (*phy1* usually) separately. *netdev* can’t guarantee this distinguishing since *wlan0* may be referring to 2.4 GHz or 5 GHz radio based on current network setup.

Name Type RequiredDefault Description *default*integerno 0 LED state before trigger: *0* means OFF and *1* means ON *sysfs* string yes *(none)*LED device name *trigger*string yes *(none)**phy0rx*, *phy0tx*, *phy0assoc*, *phy0radio* or *phy0tpt*

- **phy0rx** - flashes on reception.
- **phy0tx** - flashes on transmission.
- **phy0assoc** - flashes on client association.
- **phy0radio** - (unknown, this option did nothing on my tl-wr1043nd)
- **phy0tpt** - flashes slowly and steadily on network activity.in comparison to energetic flashes of tx and rx modes

### USB Device

The LED turns ON if USB device is connected. If not installed already, install it with:

```
root@lede:/# opkg install kmod-ledtrig-usbdev 
```

Name Type RequiredDefault Description *default* integer no 0 LED state before trigger: *0* means OFF and *1* means ON *dev* string yes *(none)* Name of USB device to monitor (in this example *1-1*). *interval* integer yes *(none)* Interval in ms when device is active. *sysfs* string yes *(none)* LED device name *trigger* string yes *(none)* *usbdev -- **This may be `usbport` (March 2019)***

To find out device name use *logread* to search for it or list */sys/bus/usb/devices* (for this example, there would be */sys/bus/usb/devices/1-1* device).  
Within lets say */sys/bus/usb/devices/1-1*, you should have a **manufacturer** and **product** files, simply use `cat` to reveal their contents, which will help identify the device.

### GPIO

Allows LEDs to be controlled by gpio events. If not installed already, install it with:

```
root@lede:/# opkg install kmod-ledtrig-gpio
```

Name Type RequiredDefaultDescription *default*integerno 0 LED state before trigger: *0* means OFF and *1* means ON

### Net filter

Flash LEDs when a particular packets passing through your machine. If not installed already, install it with:

```
root@lede:/# opkg install kmod-ipt-led
```

[According to this, the package was named kmod-ledtrig-netfilter in older versions](https://git.lede-project.org/?p=source.git%3Ba%3Dcommit%3Bh%3D168adaefc29ca33f043a5f65bd560cf81daf0611 "https://git.lede-project.org/?p=source.git;a=commit;h=168adaefc29ca33f043a5f65bd560cf81daf0611")

For example to create an LED trigger for incoming SSH traffic:

```
root@lede:/# iptables -A INPUT -p tcp --dport 22 -j LED --led-trigger-id ssh --led-delay 1000
```

Then attach the new trigger to an LED on your system:

```
root@lede:/# echo netfilter-ssh > /sys/class/leds/<ledname>/trigger 
```

Name Type RequiredDefaultDescription *default*integerno 0 LED state before trigger: *0* means OFF and *1* means ON

## Examples

Please remember to change the *sysfs* option to LEDs that are actually present on your router.  
This can be done easily through LuCI. Following examples are from */etc/config/system* file:

### Heartbeat led

```
config 'led'
	option 'sysfs'		'wrt160nl:amber:wps'
	option 'trigger'	'heartbeat'
```

### WLAN led

```
config 'led' 'wlan_led'
	option 'name'           'WLAN'
	option 'sysfs'          'tl-wr1043nd:green:wlan'
	option 'trigger'        'netdev'
	option 'dev'            'wlan0'
	option 'mode'           'link tx rx'
```

### 3G led

This led lights up when an USB-dongle properly registers with the 3G/EDGE/GPRS network.

```
config 'led'
	option 'name'           '3G'
	option 'sysfs'          'asus:blue:3g'
	option 'trigger'        'netdev'
	option 'dev'            '3g-wan'
	option 'mode'           'link'
```

### Timer led - 500ms ON, 2000ms OFF

```
config 'led'
	option 'sysfs'		'wrt160nl:blue:wps'
	option 'trigger'	'timer'
	option 'delayon'	'500'
	option 'delayoff'	'2000'
```
