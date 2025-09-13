# For Developers: Activating EAD (Emergency Access Daemon) Before Running into Problems

Try to use [template\_howto](/meta/template_howto "meta:template_howto") or [template\_howtobuild](/meta/template_howtobuild "meta:template_howtobuild"), it may help you. --- *orca 2011/02/07 00:43*

### Introduction

The Emergency Access Daemon allows you to run arbitrary commands on your router in the chance that you don't have console access to it. This is, in fact, as powerful and dangerous as it sounds. **Most users will not want to enable this in their router**. This is primarily useful for people hacking on their router.

### Installation on Router

Installation of ead is as easy as:

`root@OpenWrt:/# opkg install ead`

This installs just the package, and makes no provision for it to autostart or even accept connections

### Building the ead-client package

To build the client, you have to download the ead-tree from trunk, and compile it on the target system. (the one which will be used as the client).

```
$ mkdir /usr/src/ead
$ cd /usr/src/ead
$ svn co svn://svn.openwrt.org/openwrt/trunk/package/ead/src/ . # you may also copy the files from a local checkout of the openwrt-trunk
$ make ead-client 
```

If the compile succeeds, you may copy the ead-client binary to a better location.

```
$ cp ead-client /usr/local/bin/
```

### Configuration

#### Create a user for ead to use on your router.

You do this by adding a line to /etc/passwd.

```
root@OpenWrt:/# cat /etc/passwd
root:!:0:0:root:/root:/bin/ash
nobody:*:65534:65534:nobody:/var:/bin/false
daemon:*:65534:65534:daemon:/var:/bin/false
ead:*:0:0:root:/root:/bin/ash
```

As you can see, I've added the ead user, with a password set to * for now.

#### Change the users password

```
root@OpenWrt:/# passwd ead
```

For this document, we're assuming that the ead password has been set to ead.

#### Test ead on router

```
root@OpenWrt:/# /sbin/ead -d eth1 -D OpenWrtEth1 -p /etc/passwd -B
```

In this case eth1 is the Switch-Interface. You may have to try other interfaces in your case.

#### Run ead-client on machine plugged into a switch port

`boatanchor ead $ ./ead-client 732e: OpenWrtEth1`

The 732e is the 'node' address, and the OpenWrtEth1 is the friendly name. Due to the way that ead works, you may have to try this multiple times. If the command outputs 'No devices found' then it was not able to find the ead daemon on your router.

Once you have the node address, try running a command

`boatanchor ead $ ./ead-client 732e ead:ead “echo foo > /tmp/ead-foo”`

and verify that it worked on the router

`root@OpenWrt:/# cat /tmp/ead-foo foo`

#### Create an ead init script and configuration

here is my example ead init.d script and it's corresponding configuration:

/etc/init.d/ead

```
#!/bin/sh /etc/rc.common
# Copyright (C) 2006 OpenWrt.org

START=98

ead_config() {
        local cfg="$1"
        local publiciface publicname 

        config_get publiciface "$cfg" publiciface
        config_get publicname "$cfg" publicname
        /sbin/ead -d "$publiciface" -D "$publicname" -p /etc/passwd -B
}

start() {
        config_load ead
        [ "$?" != "0" ] && {
                uci_set_default ead <<EOF
config ead 
        option publiciface eth1
        option publicname OpenWrtRecovery
EOF
                config_load ead
        }
        config_foreach ead_config 
}

stop() {
        killall ead
}
```

/etc/config/ead

```
config 'ead'
        option 'publiciface' 'eth1'
        option 'publicname' 'OpenWrtEadEth1'

config 'ead'
        option 'publiciface' 'eth0'
        option 'publicname' 'OpenWrtEadEth0' 
```

#### Enable init script to start by default

`root@OpenWrt:/# /etc/init.d/ead enable`

### Utility Script

Now, if you're like me, you want to actually SEE the output of commands. I use the following utility script to run the command on my router, dump the output onto the internal webserver, then wget the output and dump it to my local terminal

```
#!/bin/bash
eadString=`./ead-client`
HostName=`echo ${eadString#*:}`
HostString=`echo ${eadString%%:*}`
echo "$HostName found at $HostString"
Username=$1
Password=$2
IP=$3
Command=$4
sleep 3
echo "Running $Command"
eadTemp=`./ead-client $HostString $Username:$Password "$Command > /www/ead-out.txt"`
wget $IP/ead-out.txt -q -O - 
```

And I invoke it with:

```
boatanchor ead # bash ./ead-runner.sh ead ead 192.168.1.1 "echo foo"
OpenWrtEadEth1 found at 732e
Running echo foo
foo
```
