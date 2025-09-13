# Hotplug

Procd (the init system and process management daemon) executes scripts located in `/etc/hotplug.d` when certain events happen, like for example when an interface goes up or down, when a new storage drive is detected, or when a button is pressed. It can be very useful with PPPoE connection or in an unstable network, or to use hardware buttons.

This functionality emulates/extends what was done by the long retired Hotplug2 package.

## How it works

In the `/etc/hotplug.d` directory you will find some directories **block**, **iface**, **net** and **ntp**.

When the trigger event fires, Procd will execute all scripts in that trigger's directory, in alphabetical order. Which is why most scripts in there use a numeric prefix.

Directory Description **block** Block device events: device connected/disconnected **button** Buttons: not created by default, see [/etc/rc.button](/docs/guide-user/hardware/hardware.button "docs:guide-user:hardware:hardware.button") instead **dhcp** DHCP-related events **dsl** DSL modem events **firewall** Firewall-related events (not applicable to `fw4`) **iface** Interface events: LAN/WAN/etc. is connected/disconnected **neigh** Neighbor discovery **net** Network-related events **ntp** Time sync events: time step, time server stratum change **tftp** TFTP-related events **tty** TTY-related events, including but not limited to WWAN modems, but pointing directly to TTY interface **usb** USB devices like 3g-modem and tty* **usbmisc** Special USB peripherals like printers (scripts in this subsystem have fewer variables available)

See also:

- [Buttons, sound devices, serial and USB serial dongles](https://github.com/openwrt/openwrt/blob/master/package/system/procd/files/hotplug.json "https://github.com/openwrt/openwrt/blob/master/package/system/procd/files/hotplug.json")
- [DHCP, NDP, TFTP](https://github.com/openwrt/openwrt/blob/master/package/network/services/dnsmasq/files/dhcp-script.sh "https://github.com/openwrt/openwrt/blob/master/package/network/services/dnsmasq/files/dhcp-script.sh")
- [DHCP client scripts](/docs/guide-user/network/protocol.dhcp#dhcp_client_scripts "docs:guide-user:network:protocol.dhcp")

## Usage / Troubleshooting

Simply place your script(s) into the right hotplug.d directory, if there is none just create the right one.

Procd exposes a wealth of info when executes your scripts in `/etc/hotplug.d`, usually as environmental variables.

If you want to see what environmental variables it is providing, make a script like this:

```
cat << "EOF" > /etc/hotplug.d/iface/00-logger
logger -t hotplug $(env)
EOF
```

Then trigger the event connected to that directory, and then you can see what envs were passed by reading the output:

```
logread -e hotplug
```

## Event classes / Directories

### net

For scripts in **net** directory, these are the (relevant) environmental variables

Variable name Description ACTION “add” or “remove” noted DEVICENAME configured interface names (br-lan, wlan0, phy1-ap0 PATH Full path DEVPATH full device path (for example “/devices/pci0000:00/0000:00:0b.0/usb1/1-1/1-1:1.0/host7/target7:0:0/7:0:0:0/block/sdc/sdc1 ” DEVTYPE what the DEVICENAME are names of, ie. br-lan, phy1-ap0 INTERFACE configured interfaces as in DEVTYPE SEQNUM seqnum (a number) SUBSYSTEM always = “net” IFINDEX appears to be related to the configured interfaces. See \`ifconfig\`

### block

For scripts in **block** directory, these are the (relevant) environmental variables

Variable name Description ACTION For normal device (e.g: sda) it is either “add” or “remove”. Can be “change” if the device is dm-crypt (e.g: dm-0) DEVICENAME seems same as DEVNAME below DEVNAME Device or partition name (if I connect a drive I get a hotplug call with “sda” and another hotplug call with “sda1”) DEVPATH full device path (for example “/devices/pci0000:00/0000:00:0b.0/usb1/1-1/1-1:1.0/host7/target7:0:0/7:0:0:0/block/sdc/sdc1 ” DEVTYPE what the DEVNAME e DEVICENAME are names of, I've seen “partition” here when a device with a readable partition is inserted and a “disk” when that device is removed. MAJOR major device number MINOR minor device number SEQNUM seqnum (a number) SUBSYSTEM seems this is only “block”

### dsl

For scripts in **dsl** directory, these are the (relevant) environment variables

Variable name Description DSL\_NOTIFICATION\_TYPE `DSL_STATUS`, `DSL_INTERFACE_STATUS`, `DSL_DATARATE_STATUS_US`, `DSL_DATARATE_STATUS_DS` DSL\_LINE\_NUMBER `0`, `1` *

When DSL\_NOTIFICATION\_TYPE is `DSL_STATUS`, the following environment variables are set

Variable name Description DSL\_XTU\_STATUS `ADSL`, `VDSL` DSL\_TC\_LAYER\_STATUS `ATM`, `EFM` DSL\_EFM\_TC\_CONFIG\_US `NORMAL`, `PRE_EMPTION`, `UNKNOWN` DSL\_EFM\_TC\_CONFIG\_DS `NORMAL`, `UNKNOWN`

When DSL\_NOTIFICATION\_TYPE is `DSL_INTERFACE_STATUS`, the following environment variables are set

Variable name Description DSL\_INTERFACE\_STATUS `DOWN`, `READY`, `HANDSHAKE`, `TRAINING`, `UP` DSL\_BONDING\_STATUS `INACTIVE`, `ACTIVE` *

When DSL\_NOTIFICATION\_TYPE is `DSL_DATARATE_STATUS_US`, the following environment variables are set

Variable name Description DSL\_DATARATE\_US\_BC0 Upstream data rate in bit/s for Channel 0 DSL\_DATARATE\_US\_BC1 Upstream data rate in bit/s for Channel 1 *

When DSL\_NOTIFICATION\_TYPE is `DSL_DATARATE_STATUS_DS`, the following environment variables are set

Variable name Description DSL\_DATARATE\_DS\_BC0 Downstream data rate in bit/s for Channel 0 DSL\_DATARATE\_DS\_BC1 Downstream data rate in bit/s for Channel 1 *

NOTE: environment variables marked with an * are only available when channel bonding support is compiled in.

### iface

For scripts in **iface** directory, these are the (relevant) environmental variables

Variable name Description ACTION `ifdown`, `ifup`, `ifup-failed`, `ifupdate`, `free`, `reload`, `iflink`, `create` INTERFACE Name of the logical interface which went up or down (e.g. `wan` or `lan`) DEVICE Name of the physical device which went up or down (e.g. `eth0` or `br-lan` or `pppoe-wan`), when applicable

The meaning of most actions should be straightforward, the maybe-not-obvious ones are:

Value Description `ifup-failed` `ifdown` event happened while the interface was being brought up `free` the interface has been removed (inverse of `create`) `iflink` the interface reported the presence of a carrier

When ACTION is `ifupdate`, the following environment variables may be set

Variable name Description IFUPDATE\_ADDRESSES `1` if address changed since previous ifupdate event IFUPDATE\_ROUTES `1` if a route changed since previous ifupdate event IFUPDATE\_PREFIXES `1` if prefix changed since previous ifupdate event IFUPDATE\_DATA `1` if `ubus call network.interface.$INTERFACE set_data ...` (or equivalent) happened

### ntp

Variables based on busybox ntpd:

Variable name description ACTION step, stratum, unsync or periodic freq\_drift\_ppm ntp variables offset Time adjustment done stratum Quality (nr of servers to atomic clock) poll\_interval ntp variables

Even without NTP sync, you will receive a “periodic” hotplug event, with `stratum=16`, about every 11 minutes out of the box.

### tty

Variable name description ACTION add, remove, bind, unbind as above DEVICENAME eg “ttyUSB2” DEVNAME only for bind/unbind, eg, “ttyUSB2” DEVPATH eg, “/devices/platform/ahb/1b400000.usb/usb2/2-1/2-1:1.3/ttyUSB2” SEQNUM (action number since boot for this subsystem) eg 335 SUBSYSTEM Specific type of device, eg, “usb-serial” MAJOR eg 189 MINOR eg 1

### usb

Variable name description ACTION add, remove, bind, unbind as above DEVICENAME eg “1-1” DEVNAME eg, “bus/usb/001/002” DEVNUM eg 002 DEVPATH eg, “/devices/platform/ehci-platform/usb1/1-1” DEVTYPE eg “usb\_device” TYPE eg 9/0/1 PRODUCT the vendor/productcode/version, eg “424/2640/0” see lsusb SEQNUM (action number since boot for this subsystem) eg 335 BUSNUM eg 001 MAJOR eg 189 MINOR eg 1

### usbmisc

Variable name description ACTION add, remove as above DEVNAME eg, “bus/usb/001/002” DEVPATH eg, “/devices/platform/ehci-platform/usb1/1-1” DEVICENAME eg “1-1” SEQNUM (action number since boot for this subsystem) eg 335 MAJOR eg 189 MINOR eg 1

## Examples

```
cat << "EOF" > /etc/hotplug.d/iface/99-my-action
[ "${ACTION}" = "ifup" ] && {
    logger -t hotplug "Device: ${DEVICE} / Action: ${ACTION}"
} 
EOF
```

Every time an interface goes up then the if/fi statement will be executed.

### Symlink instead of rename a device

An other script to create a symlink instead of renaming the device.

```
cat << "EOF" > /etc/hotplug.d/usb/20-cp210x
CP210_PRODID='10c4/ea60/100'
SYMLINK="my_link"
 
set -eu
 
if [ "${DEVTYPE:-}" = 'usb_interface' ] && \
   [ "${PRODUCT:-}" = "${CP210_PRODID}" ]; then
	if [ "${ACTION:-}" = 'bind' ]; then
		if [ -L "/dev/${SYMLINK}" ]; then
			logger -t hotplug "Symlink '/dev/${SYMLINK}' already exists"
			exit 0
		fi
 
		DEVICE_NAME="$(find /sys${DEVPATH:-} -maxdepth 1 -type d -iname 'ttyUSB*' -exec basename {} \;)"
		if [ -z "${DEVICE_NAME}" ]; then
			logger -t hotplug 'Warning: DEVICE_NAME is empty'
			exit 0
		fi
 
		logger -t hotplug "Device name of cp210 is '${DEVICE_NAME}'"
		ln -s "/dev/${DEVICE_NAME}" "/dev/${SYMLINK}"
		logger -t hotplug "Symlink from '/dev/${DEVICE_NAME}' to '/dev/${SYMLINK}' created"
	fi
 
 
	if [ "${ACTION:-}" = 'unbind' ]; then
		rm "/dev/${SYMLINK}"
		logger -t hotplug "Symlink '/dev/${SYMLINK}' removed"
	fi
fi
EOF
```

### Start ser2net upon hotplug

Similarly, it is also possible to start \`ser2net\` to make the serial port remotely available

```
cat << "EOF" > /etc/hotplug.d/usb/20-cp210x-ser2net
CP210_PRODID='10c4/ea60/100'                                                                                                                                                          
SER2NET_PID='/var/run/ser2net.pid'                                                                                                                                                    
SER2NET_PORT=18888                                                                                                                                                                    
SER2NET_BAUDRATE=115200                                                                                                                                                               
SER2NET_FLOWRATE='software'                                                                                                                                                           
SER2NET_RADIO='znp'                                                                                                                                                                   
SER2NET_OPTS="${SER2NET_BAUDRATE} NONE 1STOPBIT 8DATABITS -RTSCTS -LOCAL NOBREAK"                                                                                                     
 
set -eu                                                                                                                                                                               
 
if [ "${DEVTYPE:-}" = 'usb_interface' ] && \                                                                                                                                          
   [ "${PRODUCT:-}" = "${CP210_PRODID}" ]; then                                                                                                                                       
        if [ "${ACTION:-}" = 'bind' ]; then                                                                                                                                           
                if [ -s "${SER2NET_PID}" ]; then                                                                                                                                      
                        logger -t hotplug "Warning: ser2net already running as pid: $(cat "${SER2NET_PID}") via ${SER2NET_PID}"                                                       
                        exit 0                                                                                                                                                        
                fi                                                                                                                                                                    
 
                DEVICE_NAME="$(find "/sys${DEVPATH:-}" -maxdepth 1 -type d -iname 'ttyUSB*' -exec basename {} \;)"                                                                    
                if [ -z "${DEVICE_NAME}" ]; then                                                                                                                                      
                        logger -t hotplug 'Warning: DEVICE_NAME is empty'                                                                                                             
                        exit 0                                                                                                                                                        
                fi                                                                                                                                                                    
                logger -t hotplug "Device name of cp210 is '${DEVICE_NAME}'"                                                                                                          
 
                ser2net -C "${SER2NET_PORT}:raw:100:/dev/${DEVICE_NAME}:${SER2NET_OPTS}" -P "${SER2NET_PID}"                                                                          
                if [ -d '/etc/avahi/services' ]; then                                                                                                                                 
                        {                                                                                                                                                             
                                printf '<service-group>\n\n'                                                                                                                          
                                printf '  <name replace-wildcards="yes">%%h</name>\n\n'                                                                                  
                                printf '  <service>\n'                                                                                                                                
                                printf '    <type>_ser2net_zigbee-gateway._tcp</type>\n'                                                                                               
                                printf '    <port>%d</port>\n' "${SER2NET_PORT}"                                                                                                      
                                printf '    <txt-record>baudrate=%d</txt-record>\n' "${SER2NET_BAUDRATE:-115200}"                                                                     
                                printf '    <txt-record>flow-control=%s</txt-record>\n' "${SER2NET_FLOWRATE:-software}"                                                               
                                printf '    <txt-record>radio=%s</txt-record>\n' "${SER2NET_RADIO:-znp}"                                                                              
                                printf '  </service>\n\n'                                                                                                                             
                                printf '</service-group>\n'                                                                                                                           
                        } > '/etc/avahi/services/ser2net.service'                                                                                                                     
                fi                                                                                                                                                                    
 
                logger -t hotplug "Started ser2net on '/dev/${DEVICE_NAME}'"                                                                                                          
        fi                                                                                                                                                                            
 
        if [ "${ACTION:-}" = 'unbind' ]; then                                                                                                                                         
                logger -t hotplug "Attempting to stop ser2net with pid: $(cat "${SER2NET_PID}")"                                                                                      
                kill -3 "$(cat "${SER2NET_PID}")"                                                                                                                                     
                if [ -s '/etc/avahi/services/ser2net.service' ]; then                                                                                                                 
                        rm '/etc/avahi/services/ser2net.service'                                                                                                                      
                fi                                                                                                                                                                    
                if [ ! -s "${SER2NET_PID}" ]; then                                                                                                                                    
                        logger -t hotplug 'Failed'                                                                                                                                    
                        exit 0                                                                                                                                                        
                fi                                                                                                                                                                    
        fi                                                                                                                                                                            
fi     
EOF
```

> *Note:* The above example demonstrates how to also integrate avahi which leads to an auto-discoverable serial port over the network. In this example a Zigbee device would have been connected to the serial port.

### Script that detects whether plugged usb device is bluetooth or not

```
cat << "EOF" > /etc/hotplug.d/usb/20-bt_test
BT_PRODID="a12/1/"
BT_PRODID_HOT="${PRODUCT::6}"
 
#logger -t hotplug "PRODUCT ID is ${BT_PRODID_HOT}"
 
if [ "${BT_PRODID_HOT}" = "${BT_PRODID}" ]; then
    if [ "${ACTION}" = "add" ]; then
        logger -t hotplug "bluetooth device has been plugged in!"
        if [ "${BSBTID_NEW}" = "${BSBTID_OLD}" ]; then
            logger -t hotplug "bluetooth device hasn't changed"
        else
            logger -t hotplug "bluetooth device has changed"
        fi
    fi
    if [ "${ACTION}" = "remove" ]; then
        logger -t hotplug "bluetooth device has been removed!"
    fi
else
    logger -t hotplug "USB device is not bluetooth"
fi
EOF
```

### Auto start mjpg-streamer when an usb camera is plugged in

```
cat << "EOF" > /etc/hotplug.d/usb/20-mjpg_start
case "${ACTION}" in
    add)
            # start process
        service mjpg-streamer start
            ;;
    remove)
            # stop process
        service mjpg-streamer stop
            ;;
esac
EOF
```

### Custom automount script for XFS

```
cat << "EOF" > /etc/hotplug.d/block/xfs_automount
# if a new block device is connected
if [ "${ACTION}" = "add" ]; then
    # getting device UUID
    detected_uuid="$(xfs_admin -u /dev/${DEVICENAME} | awk '{print $3}')"
    # deciding mountpoint for known UUID
    mountpoint=""
    case "${detected_uuid}" in
        6a5d7c5c-c9d0-41cc-8f19-78d97f839c05)
            mountpoint="/path/to/first/mountpoint"
            ;;
        02880b1f-0c67-46b6-9b05-5535680ccc89)
            mountpoint="/path/to/second/mountpoint"
            ;;
    esac
 
    # if we have a known UUID we have a mountpoint so we can mount it
    if [ "${mountpoint}" != "" ]; then 
        mount /dev/${DEVICENAME} ${mountpoint}
    fi
fi
# unmounting happens automatically at device disconnection anyway so no logic for that
EOF
```

### Coldplug

You may have noticed that the udev and eudev were removed in the openwrt 18.0.* release. Don't worry, because you still can make things work. You can use hotplug scripts as coldplug. Pay attention to the ACTION environment variable, at boot 'bind' actions are executed. So, just add this option to hotplug and run accordingly.

In my case I used this:

```
mkdir -p /etc/hotplug.d/usb
cat << "EOF" > /etc/hotplug.d/usb/22-symlinks
# Description: Action executed on boot (bind) and with the system on the fly
if [ "${ACTION}" = "bind" ]; then
  case "${PRODUCT}" in
    1bc7*) # Telit HE910 3g modules product id prefix
      DEVICE_NAME="$(ls /sys/${DEVPATH} | grep tty)"
      DEVICE_TTY="$(ls /sys/${DEVPATH}/tty/)"
      # Module Telit HE910-* connected to minipciexpress slot MAIN
      if [ "${DEVICENAME}" = "1-1.3:1.0" ]; then
        ln -s /dev/${DEVICE_TTY} /dev/ttyMODULO1_DIAL
        logger -t hotplug "Symlink from /dev/${DEVICE_TTY} to /dev/ttyMODULO1_DIAL created"
      elif [ "${DEVICENAME}" = "1-1.3:1.6" ]; then
        ln -s /dev/${DEVICE_TTY} /dev/ttyMODULO1_DATA
        logger -t hotplug "Symlink from /dev/${DEVICE_TTY} to /dev/ttyMODULO1_DATA created"
      # Module Telit HE910-* connected to minipciexpress slot SECONDARY
      elif [ "${DEVICENAME}" = "1-1.2:1.0" ]; then
        ln -s /dev/${DEVICE_TTY} /dev/ttyMODULO2_DIAL
        logger -t hotplug "Symlink from /dev/${DEVICE_TTY} to /dev/ttyMODULO2_DIAL created"
      elif [ "${DEVICENAME}" = "1-1.2:1.6" ]; then
        ln -s /dev/${DEVICE_TTY} /dev/ttyMODULO2_DATA
        logger -t hotplug "Symlink from /dev/${DEVICE_TTY} to /dev/ttyMODULO2_DATA created"
      fi
    ;;
  esac
fi
# Action to remove the symlinks
if [ "${ACTION}" = "remove" ]; then
  case "${PRODUCT}" in
    1bc7*)  # Telit HE910 3g modules product id prefix
     # Module Telit HE910-* connected to minipciexpress slot MAIN
      if [ "${DEVICENAME}" = "1-1.3:1.0" ]; then
        rm /dev/ttyMODULO1_DIAL
        logger -t hotplug "Symlink /dev/ttyMODULO1_DIAL removed"
      elif [ "${DEVICENAME}" = "1-1.3:1.6" ]; then
        rm /dev/ttyMODULO1_DATA
        logger -t hotplug "Symlink /dev/ttyMODULO1_DATA removed"
      # Module Telit HE910-* connected to minipciexpress slot SECONDARY
      elif [ "${DEVICENAME}" = "1-1.2:1.0" ]; then
        rm /dev/ttyMODULO2_DIAL
        logger -t hotplug "Symlink /dev/ttyMODULO2_DIAL removed"
      elif [ "${DEVICENAME}" = "1-1.2:1.6" ]; then
        rm /dev/ttyMODULO2_DATA
        logger -t hotplug "Symlink /dev/ttyMODULO2_DATA removed"
      fi
    ;;
  esac
fi
EOF
```

### Log DSL status changes

If you have a DSL modem you can add logging of DSL status changes and connection data rates.

This can be helpful if your DSL connection is affected by Seamless Rate Adaptation (SRA) or Dynamic Line Management (DLM) events; for SRA events data rate changes will be logged, while for DLM events connection status changes will be logged as the modem is forced to retrain and then the new data rates will be logged.

```
cat << "EOF" > /etc/hotplug.d/dsl/20-dsl_status
case "${DSL_NOTIFICATION_TYPE}" in
(DSL_INTERFACE_STATUS)
  logger -p daemon.notice -t dsl-notify "${DSL_XTU_STATUS} link status: ${DSL_INTERFACE_STATUS}" ;;
(DSL_DATARATE_STATUS_US)
  logger -p daemon.notice -t dsl-notify "DSL upstream actual data rate: ${DSL_DATARATE_US_BC0}" ;;
(DSL_DATARATE_STATUS_DS)
  logger -p daemon.notice -t dsl-notify "DSL downstream actual data rate: ${DSL_DATARATE_DS_BC0}" ;;
esac
EOF
```

This script assumes that channel bonding is not compiled in to the DSL support.

### Utilize wireless USB adapter

Restart Wi-Fi when plugging in a wireless USB adapter.

```
mkdir -p /etc/hotplug.d/usb
cat << "EOF" > /etc/hotplug.d/usb/20-rtl8188su
if [ "${PRODUCT}" = "bda/8171/200" ] \
&& [ "${ACTION}" = "add" ]
then wifi
fi
EOF
```

The above code matches the following device.

```
# lsusb -v
	idVendor	0x0bda Realtek Semiconductor Corp.
	idProduct	0x8171 RTL8188SU 802.11n WLAN Adapter
	bcdDevice	2.00
```

### Get specific IP address

Assuming your ISP provides a dynamic IP address. Reconnect until you get the one matching a specific regexp. Delay for 10 seconds between reconnects. Set up [Hotplug extras](/docs/guide-user/advanced/hotplug_extras "docs:guide-user:advanced:hotplug_extras") to trigger the script upon connecting WAN interface.

```
mkdir -p /etc/hotplug.d/online
cat << "EOF" > /etc/hotplug.d/online/10-wan-ipaddr
. /lib/functions/network.sh
network_flush_cache
network_find_wan WAN_IF
network_get_ipaddr WAN_ADDR "${WAN_IF}"
if [ "${WAN_IF}" != "${INTERFACE}" ]
then exit 0
fi
case ${WAN_ADDR} in
(??.???.*) exit 0 ;;
esac
sleep 10
ifup ${INTERFACE}
EOF
```

### Rename interfaces by MAC address

Assuming pre-configured upstream interfaces `wana` and `wanb`. Set up persistent interface names by MAC address.

```
cat << "EOF" > /etc/hotplug.d/iface/00-dev-rename
dev_rename() {
local DEV_CONF="${1}"
local DEV_MAC DEV_NAME DEV_ONAME
config_get DEV_MAC "${DEV_CONF}" mac
config_get DEV_NAME "${DEV_CONF}" name
DEV_ONAME="$(grep -l -e "${DEV_MAC}" \
$(find /sys/class/net/*/device/uevent \
| sed -e "s|/device/uevent$|/address|") \
| awk -F '/' '{print $5}')"
if [ -n "${DEV_MAC}" ] \
&& [ "${DEV_ONAME}" != "${DEV_NAME}" ]
then ip link set "${DEV_ONAME}" name "${DEV_NAME}"
fi
}
. /lib/functions.sh
config_load network
config_foreach dev_rename device
EOF
 
while read -r DEV_NAME DEV_MAC
do
uci set network.${DEV_NAME}.device="${DEV_NAME}"
uci set network.${DEV_NAME}6.device="${DEV_NAME}"
uci -q delete network.${DEV_NAME}_dev
uci set network.${DEV_NAME}_dev="device"
uci set network.${DEV_NAME}_dev.mac="${DEV_MAC}"
uci set network.${DEV_NAME}_dev.name="${DEV_NAME}"
done << EOI
wana 11:22:33:44:55:66
wanb aa:bb:cc:dd:ee:ff
EOI
uci commit network
service network restart
```

### Create deterministic/persistent links to USB-serial devices

Resulting links will be placed in /dev/serial/by-id and /dev/serial/by-path, with a name structure closely resembling links created by udev, but not fully exact.

```
set -o pipefail
[ "${ACTION}" = "bind" -o "${ACTION}" = "unbind" ] || exit 0
[ "${SUBSYSTEM}" = "usb-serial" ] || exit 0
[ -n "${DEVICENAME}" -a -n "${DEVPATH}" ] || exit 1
 
if [ "${ACTION}" = "bind" ]; then
        subsystem="$(basename $(readlink /sys${DEVPATH}/../subsystem))"
 
        [ "$subsystem" = "usb" ] || exit 0
 
        replace_whitespace="s/^[ \t]*|[ \t]*$//g; s/[ \t]+/_/g"
        manufacturer="$(cat /sys${DEVPATH}/../../manufacturer | sed -E "${replace_whitespace}")" || manufacturer="$(cat /sys${DEVPATH}/../../idVendor)"
        product="$(cat /sys${DEVPATH}/../../product | sed -E "${replace_whitespace}")" || product="$(cat /sys${DEVPATH}/../../idProduct)"
        serial="$(cat /sys${DEVPATH}/../../serial | sed -E "${replace_whitespace}")"
        interface="$(cat /sys${DEVPATH}/../bInterfaceNumber)"
        port="$(cat /sys${DEVPATH}/port_number)"
 
        replace_chars="s/[^0-9A-Za-z#+.:=@-]/_/g"
        id_link=$(echo "${subsystem}"-"${manufacturer}"_"${product}${serial:+_}${serial}"-if"${interface}${port:+-port}${port}" | sed "${replace_chars}")
        path_link=$(echo "${DEVPATH}${port:+-port}${port}" | sed "s%/devices/%%; s%/${DEVICENAME}%%g; ${replace_chars}")
 
        mkdir -p /dev/serial/by-id /dev/serial/by-path
        ln -sf "/dev/${DEVICENAME}" "/dev/serial/by-id/${id_link}"
        ln -sf "/dev/${DEVICENAME}" "/dev/serial/by-path/${path_link}"
elif [ "${ACTION}" = "unbind" ]; then
        for link in $(find /dev/serial -type l); do
                [ -L ${link} -a "$(readlink ${link})" = "/dev/$DEVICENAME" ] && rm ${link}
        done
fi
```

[(Source)](https://gist.github.com/Leo-PL/b5ee737e49b34c1551dba6c182707c8e "https://gist.github.com/Leo-PL/b5ee737e49b34c1551dba6c182707c8e")
