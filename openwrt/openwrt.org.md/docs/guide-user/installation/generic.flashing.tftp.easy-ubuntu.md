# Installing OpenWrt with TFTP from a Linux computer

### Audience

This guide is targeted towards relative beginners that have a Linux device.

### Requirements

This simple guide for flashing via TFTP requires you have the following tools:

**Computer:** Most Linux desktop or laptop computers with an ethernet port (or can use a USB to Ethernet adapter) **Router:** Any router or device which can be installed using TFTP ( [TFTP Installation Setup](/docs/guide-user/installation/generic.flashing.tftp "docs:guide-user:installation:generic.flashing.tftp")) **Knowledge:** Minimal knowledge of how to open and run commands in a terminal

You will also want to collect the following information:

\* What is your distribution based on?

- X/L/K/Ubuntu, ElementaryOS, Kali, Finnix: Debian (you use the \`apt\` and \`apt-get\` command to install packages)
- Fedora/CentOS/Red Hat: Red Hat (you use the \`yum\` command to install packages)
- Manjaro, Arch: Arch Linux (you use the \`pacman\` command to install commands)

\* What is your ethernet port's device name?

- Run \`ip link\` in a terminal, looking for devices beginning with \`e\`.

### Overview

There are three basic steps:

\- Network Setup

\- tftpd setup

\- Triggering TFTP on the router

### Network Setup

You will want to install the following package:

\- \`network-manager\`: to make consistently configuring your network easier. (This integrates with the network configuration present on most desktop devices)

From your TFTP installation guide, find which address the router expects to request an image from - for example, 192.168.1.20 - then use the \`nmtui\` command to configure it:

Edit a connection → Add → Ethernet: - Profile name 'Static Address for TFTP' - Device '(the name of the ethernet port you found earlier, e.g. enp0s25)' - IPv4 CONFIGURATION:

1. Manual
2. Show:
   
   1. Addresses '192.168.1.20/24' (the /24 is a subnet mask - can only talk to everyone who has the same first 24 bits in the address field)

\- ... now go all the way down and hit '&lt;OK&gt;'

If you would like to test this earlier, try hooking up your laptop or computer via ethernet cable to a router or switch, and selecting the 'Static Address for TFTP' connection; then run \`ip address\` in a terminal to verify that your address automatically comes up correctly.

### tftpd setup

You will want to install the following package:

\- tftpd-hpa: to provide a service which automatically responds to TFTP requests for files

Once this is installed, a directory named \`/var/lib/tftpboot/\` should be created (under Debian/Ubuntu and many other distros the directory is: \`/srv/tftp\`). This is where you will place files for \`tftpd-hpa\` to serve up. (If it's not created: try \`dpkg -L\` on Ubuntu or similar to find where it was created.

Copy the files you intend to send to the router under \`/var/lib/tftpboot/\`. You may need to use sudo to do this.

Start tftpd-hpa service by running the following command:

```
sudo systemctl start tftpd-hpa
```

Or restart the tftpd-hpa service if needed:

```
sudo systemctl restart tftpd-hpa
```

You should get no output. You can validate that the server is “active” via the following command:

```
sudo systemctl status tftpd-hpa
```

*Hint:* if this fails to start, you likely have another process which is listening on port 69, thereby blocking \`tftpd-hpa\` from doing so. To check, run:

```
sudo netstat -tupena | grep :69
```

```
  hurricos@myhost:~$ sudo netstat -tupena | grep :69
  udp        0      0 0.0.0.0:69              0.0.0.0:*                           0          1786355    11349/inetd      
  udp6       0      0 :::69                   :::*                                0          1786356    11349/inetd     
```

You will want to stop the process (in this case, \`inetd\`) which is using this port. In this case, you could use \`sudo systemctl stop inetd\`.

### Triggering TFTP

Now, you will plug your router to-be-flashed into your laptop, and follow your guide in order to trigger the router to request TFTP. In the cases where you are using a serial cable to control your router, you are usually using the uBoot console to tell the router to boot from the network -- for example, on the [Meraki MR16](/toh/meraki/mr16 "toh:meraki:mr16").

### Debugging issues

If you are not able to get the router to boot, there are a few things you can check:

\- Are you actually receiving a TFTP/BOOTP packet from the router?

1. You can check this by running \`sudo tcpdump -i &lt;ethernet device&gt; port 69\`

\- Are your files named correctly?

1. TFTP requests will be responded to with files named exactly as they are found under \`/var/lib/tftpboot/\`.
