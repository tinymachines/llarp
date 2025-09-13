# Port knocking server knockd

Knockd is a port knocking daemon, a program that listens for specific packets on specific ports, and will run a command when it hears the correct sequence. It is used to hide ports from public view for better privacy/security.

## Preparation

Read [http://www.portknocking.org/](http://www.portknocking.org/ "http://www.portknocking.org/") ([archive.org 20190710](https://web.archive.org/web/20190710115023/http://www.portknocking.org/ "https://web.archive.org/web/20190710115023/http://www.portknocking.org/")) for background on the process of port forwarding.

### Required Packages

#### Server (OpenWrt)

- **`knockd`**

#### Client (your PC)

Choice of port knocking is left to the reader, it can be a full application or even as simple as a few netcat commands in a shell script.

## Installation

[opkg](/docs/guide-user/additional-software/opkg "docs:guide-user:additional-software:opkg")

```
opkg install knockd
```

## Configuration

knockd is configured in /etc/knockd.conf

### Server configuration

Here is the default knockd configuration.

```
[options]
	logfile = /var/log/knockd.log

[openSSH]
	sequence    = 7000,8000,9000
	seq_timeout = 5
	command     = /usr/sbin/iptables -A INPUT -s %IP% -p tcp --dport 22 -j ACCEPT
	tcpflags    = syn

[closeSSH]
	sequence    = 9000,8000,7000
	seq_timeout = 5
	command     = /usr/sbin/iptables -D INPUT -s %IP% -p tcp --dport 22 -j ACCEPT
	tcpflags    = syn
```

knockd automatically replaces %IP% with the IP address of the client that sent the knock, so you can open the port only to the authorized client.

This controls access to port 22 on the router, but it's not compatible with OpenWRT's iptables setup, and I don't want to SSH into the router, I want to use it to enable port forwarding to an SSH server inside my network.

Using it to manage port forwards is a bit more complicated. It requires several iptables rules to be enabled. I made a script that puts all the necessary commands together:

```
#!/bin/sh

PORT=$1
SRC_IP=$2
DST_IP=$3
ACTION=$4
. /lib/functions/network.sh; network_get_ipaddr WAN_IP wan

iptables $ACTION nat_reflection_in -s 192.168.1.0/24 -d $WAN_IP/32 -p tcp -m tcp --dport $PORT -m comment --comment "wan" -j DNAT --to-destination $DST_IP:$PORT -t nat
iptables $ACTION nat_reflection_out -s 192.168.1.0/24 -d $DST_IP/32 -p tcp -m tcp --dport $PORT -m comment --comment "wan" -j SNAT --to-source 192.168.1.1 -t nat
iptables $ACTION zone_wan_prerouting -p tcp -m tcp -s $SRC_IP --dport $PORT -j DNAT --to-destination $DST_IP:$PORT -t nat
iptables $ACTION nat_reflection_fwd -s 192.168.1.0/24 -d $DST_IP/32 -p tcp -m tcp --dport $PORT -m comment --comment "wan" -j ACCEPT 
iptables $ACTION zone_wan_forward -d $DST_IP/32 -p tcp -m tcp --dport $PORT -j ACCEPT
```

The command can be used as follows, where xxx.xxx.xxx.xxx is the IP address of your ssh server you want to forward to and %IP% is the IP of the client you want to allow:

```
./forward.sh 22 %IP% xxx.xxx.xxx.xxx -I
```

to create a port forward

```
./forward.sh 22 %IP% xxx.xxx.xxx.xxx -D
```

to disable a port forward.

This script was developed for OpenWRT Attitude Adjustment. The iptables commands may be different in other versions due to changes in structure. To figure out the necessary commands I created a port forward using the web GUI and used the iptables-save command to list the iptables rules that each forward generates. I had to add -t nat to the end of some of them. Also, I can't guarantee that this is the preferred or most elegant solution, but it works for me.

I have created script that creates port forwards and port open using standard uci command. This creates rules that are visible in luci but do have somewhat cryptic names. For this you need to use uciknockd.sh and second knockd.conf sample.

### Client configuration

There are plenty of different port knocking clients available for all platforms, including Windows, Linux, OSX, and even Android.

## Examples

Here's an example knockd.conf using the forward.sh script:

```
[options]
	logfile = /var/log/knockd.log
	interface = eth1

[OpenPort]
	sequence    = 123,456,789
	seq_timeout = 5
	command     = /path/to/forward.sh 22 %IP% 192.168.1.99 -I
	cmd_timeout = 3600
	stop_command= /path/to/forward.sh 22 %IP% 192.168.1.99 -D
	tcpflags    = syn
	
[ClosePort]
	sequence    = 789,456,123
	seq_timeout = 5
	command     = /path/to/forward.sh 22 %IP% 192.168.1.99 -D
	tcpflags    = syn
```

And here's an example knockd.conf using the uciknockd.sh script (you will find it after this sample):

```
[options]
	logfile = /var/log/knockd.log
	interface = eth0.2

[openSSH]
	sequence    = 12345,34512,54321
	seq_timeout = 5
	command     = /etc/uciknockd.sh open-port KnockdSSH  %IP% 22
	tcpflags    = syn

[closeSSH]
	sequence    = 54321,12345,11123
	seq_timeout = 5
	command     = /etc/uciknockd.sh close-port KnockdSSH  %IP% 22
	tcpflags    = syn 

[openFORWARD]
        sequence    = 1455,3244,1000
        seq_timeout = 5
        command     = /etc/uciknockd.sh forward-port KnockdFW %IP% 81 192.168.1.99 80
        tcpflags    = syn


[closeFORWARD]
        sequence    = 3244,1455,1001
        seq_timeout = 5
        command     = /etc/uciknockd.sh remove-forward-port KnockdFW %IP% 81 
        tcpflags    = syn 
```

This script, uciknockd.sh, will create forwarding and port open rules in uci configuration so you will be able to see from luci which ports are open. If you trigger openSSH from ip 1.1.1.1 in luci you will have rule with name KnockdSSH\_1.1.1.1\_22, etc. CloseSSH rule deletes it from uci and iptables. uciknockd.sh and knockd.conf scripts should be placed in /etc directory. Don't forget to make uciknockd.sh executable *chmod 755 /etc/uciknockd.sh*.

```
#!/bin/sh 
# This is uciknockd.sh script, place it in /etc directory

. /lib/functions.sh

# callback for config_foreach
handle_delete()
{
  local config="$1"
  local option="$2"
  local value="$3"
  local optionVal=""
  config_get optionVal "$config" "$option"
  if [ "$optionVal" == "$value" ]; then
    uci delete firewall.$config
	return 1
  fi
}

# to delete firewall.@rule[x].name="test"
# delete_rule firewall rule name test
#
delete_rule()
{
  local config="$1"
  local section="$2"
  local name="$3"
  local value="$4"
  config_load $config
  config_foreach handle_delete $section $name $value
}

# Opening ports
# This example enables machines on the internet to use SSH to access your router. 
#
#config rule
#        option src              wan
#        option dest_port        22
#        option target           ACCEPT
#        option proto            tcp

open_port()
{
  local name=$1
  local src_ip=$2
  local dest_port=$3

  uci batch <<EOF
	add firewall rule
	set firewall.@rule[-1].name=$name
	set firewall.@rule[-1].src='wan'
	set firewall.@rule[-1].src_ip=$src_ip
	set firewall.@rule[-1].dest_port=$dest_port
	set firewall.@rule[-1].target='ACCEPT'
	set firewall.@rule[-1].proto='tcp'
EOF

  uci commit firewall
  /etc/init.d/firewall restart
}

close_port()
{
  local name=$1
  delete_rule firewall rule name $name

   uci commit firewall
  /etc/init.d/firewall restart
}
		
# Forwarding ports (Destination NAT/DNAT)
# This example forwards one arbitrary port that you define to a box running ssh. 
#
#config 'redirect'
#        option 'name' 'ssh'
#        option 'src' 'wan'
#        option 'proto' 'tcp udp'
#        option 'src_dport' '5555'
#        option 'dest_ip' '192.168.1.100'
#        option 'dest_port' '22'
#        option 'target' 'DNAT'
#        option 'dest' 'lan'

forward_port()
{
  local name=$1
  local src_ip=$2
  local src_dport=$3
  local dest_ip=$4
  local dest_port=$5

  uci batch <<EOF
	add firewall redirect
	set firewall.@redirect[-1].name=$name
	set firewall.@redirect[-1].src='wan'
	set firewall.@redirect[-1].src_ip=$src_ip
	set firewall.@redirect[-1].proto='tcp'
	set firewall.@redirect[-1].src_dport=$src_dport
	set firewall.@redirect[-1].dest_ip=$dest_ip
	set firewall.@redirect[-1].dest_port=$dest_port
	set firewall.@redirect[-1].target='DNAT'
	set firewall.@redirect[-1].dest='lan'
EOF

  uci commit firewall
  /etc/init.d/firewall restart
}

remove_forward_port()
{
  local name=$1
  delete_rule firewall redirect name $name
  uci commit firewall
  /etc/init.d/firewall restart
}
	
case "$1" in
open-port)
	#name=$1
	#src_ip=$2
	#dest_port=$3
	name="$2_$3_$4"
    open_port $name $3 $4
    ;;
close-port)
	name="$2_$3_$4"
    close_port $name $3 $4
    ;;
forward-port)
	#name=$1
	#src_ip=$2
	#src_dport=$3
	#dest_ip=$4
	#dest_port=$5
	name="$2_$3_$4"
    forward_port $name $3 $4 $5 $6
    ;;
remove-forward-port)
	name="$2_$3_$4"
    remove_forward_port $name $3 $4
    stop
    ;;
*)
    echo "Usage:"
    echo "  $0 open-port namePrefix src_ip dest_port"
    echo "  $0 close-port namePrefix src_ip dest_port"
    echo "  $0 forward-port namePrefix src_ip src_dport dest_ip dest_port"
    echo "  $0 remove-forward-port namePrefix src_ip src_dport"
    exit 1
esac

exit 0 
```

## Start on boot

You should be able to put the command knockd -d into /etc/rc.local using the webGUI (System tab → Startup tab → rc.local section).

Or create file /etc/init.d/knockd with following content:

```
#!/bin/sh /etc/rc.common
# This goes to /etc/init.d/
 
START=88
USE_PROCD=1
 
start_service() {        
	procd_open_instance
	procd_set_param command /usr/sbin/knockd -d
	procd_set_param respawn 
	procd_set_param file /etc/knockd.conf 
	procd_close_instance		
}
```

In some cases the respawn can result in multiple running instances. If that happens remove the line.

Make sure you enable service afterwards.

## Administration

TODO

## Troubleshooting

Check the knockd log at /var/log/knockd.log to see if you are knocking successfully, and to see what the command returns.

If you get something like this when running forward.sh:

```
Try `iptables -h' or 'iptables --help' for more information.
```

then you probably don't have the right commands in the script. Try creating a forward in the WebGUI with a distinctive port number (say 5555) and run

```
iptables-save | grep 5555
```

to find the right commands.

## Notes

OpenWrt 18.06.4 appears to lack the knock/knockd package describe above; however, there are efforts to provide this package for the v18.06 (and hopefully beyond). Links to those Github repos from those folks are as follows:

- [milaq/openwrt\_knockd](https://github.com/milaq/openwrt_knockd "https://github.com/milaq/openwrt_knockd")
- [superice119/openwrt\_knockd](https://github.com/superice119/openwrt_knockd "https://github.com/superice119/openwrt_knockd")
- [TDFKAOlli/openwrt\_knockd](https://github.com/TDFKAOlli/openwrt_knockd "https://github.com/TDFKAOlli/openwrt_knockd")
