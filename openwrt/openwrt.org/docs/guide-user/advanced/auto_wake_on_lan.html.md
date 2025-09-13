# Auto Wake On LAN script for hosts

At the very least, users should consider putting the LOGFILE on `/tmp/` rather than on flash. OpenWrt also does not serve HTML pages in the same way as DD-WRT.

Note also problems with rebooting a router running this script described at [https://forum.openwrt.org/t/cant-reboot-while-sleep-script-wol/](https://forum.openwrt.org/t/cant-reboot-while-sleep-script-wol/ "https://forum.openwrt.org/t/cant-reboot-while-sleep-script-wol/")

* * *

Hi guys, I found on [https://www.dd-wrt.com/wiki/index.php/Useful\_Scripts#Web\_Server\_Wake-up](https://www.dd-wrt.com/wiki/index.php/Useful_Scripts#Web_Server_Wake-up "https://www.dd-wrt.com/wiki/index.php/Useful_Scripts#Web_Server_Wake-up") this useful script for wake up a host by request.  
I use it to wake up my NAS if my Kodi or PC want anything from it.

Requirements:

- Firmware Version: OpenWrt Barrier Breaker 14.07 / LuCI Trunk (0.12+svn-r10530)
- Kernel Version: 3.10.49

## Script settings

Required to change Variables Default value Description optional INTERVAL 5 repeat the script every N second not required OLD empty should be empty optional PORT 80 it the port who looks the script optional NUMP 3 the retries, before the script gave up yes TARGET 192.168.1.1 the wake up device yes INTERFACE br-lan here you can type in a broadcast address or a interface, i like more interface yes MAC 00:00:00:00:00:00 the target mac adress not required WOL /usr/bin/etherwake the program and path for wol optional LOGFILE “/www/wol/index.html” the log output folder, in this case for the url &lt;ROUTER-IP&gt;/wol/index.html optional LOGPROG “logread” i will read the logs from LOGREAD, but you can also read from “dmesg” or something else

## Instructions

### 1. Preparation

Install the required packages.

```
opkg update
opkg install etherwake
```

### 2. Auto WoL script

Saving the script.

```
cat << "EOF" > /bin/autowol.sh
#!/bin/sh
#Enable JFFS2 and place script in /jffs/ then run on startup in web interface.
#You can check the log from http://192.168.1.1/user/wol.html
 
#debugging
#set -xv
 
INTERVAL=5
NUMP=3
OLD=""
PORT=80
TARGET=192.168.1.1
INTERFACE=br-lan
MAC=00:00:00:00:00:00
WOL=/usr/bin/etherwake
LOGFILE="/www/wol/index.html"
LOGPROG="logread" # default: dmesg
 
echo "<meta http-equiv=\"refresh\" content=\"10\">" > $LOGFILE
echo "AUTO WOL Script started at" `date` "<br>" >> $LOGFILE
 
wake_up () {
	PORT=$1
	TARGET=$2
	BROADCAST=$3
	MAC=$4
	NEW=`$LOGPROG | awk '/WOL_LOG/ && /DST='"$TARGET"'/ && /DPT='"$PORT"'/ {print }' | tail -1`
	SRC=`$LOGPROG | awk -F'[=| ]' '/WOL_LOG/ && /DST='"$TARGET"'/ && /DPT='"$PORT"'/ {print }' | tail -1`
	LINE=`$LOGPROG | awk '/WOL_LOG/ && /DST='"$TARGET"'/ && /DPT='"$PORT"'/'`
	if [ "$NEW" != "" -a "$NEW" != "$OLD" ]; then
		if ping -qc $NUMP $TARGET >/dev/null; then
			echo "NOWAKE $TARGET was accessed by $SRC and is already alive at" `date` "<br>">> $LOGFILE
		else
			echo "WAKE $SRC causes wake on lan at" `date` "<br>">> $LOGFILE
			$WOL -i $BROADCAST $MAC >> $LOGFILE
			echo "<br>" >> $LOGFILE
			sleep 5
		fi
		OLD=$NEW
	fi
}
 
while sleep $INTERVAL; do
wake_up $PORT $TARGET $INTERFACE $MAC;
done
EOF
chmod +x /bin/autowol.sh
```

Pro Tip: Don't copy the code above as it causes a bunch of errors due to a stray CRLF character at the end of each line. Instead just download a copy of the file [here](https://drive.google.com/file/d/0Bx6d-VNCJvgBb1VFMTQxUTc1d2M/view "https://drive.google.com/file/d/0Bx6d-VNCJvgBb1VFMTQxUTc1d2M/view"), and save yourself a day of troubleshooting!

### 3. Autostart

First autostart, if the script is ok.

Go to **System → Startup → Local Startup** and type in:

```
/bin/autowol.sh
```

## Troubleshooting

Enable debug output:

```
sh -x -v /bin/autowol.sh
```

Check the log file: [http://192.168.1.1/wol/](http://192.168.1.1/wol/ "http://192.168.1.1/wol/")

Go to **Network → Firewall → Custom Rules** and add this rule:

```
iptables -I FORWARD 1 -p tcp -d 192.168.1.1 -m limit --limit 1/min -j LOG --log-prefix "WOL_LOG:  " --log-level 7
```
