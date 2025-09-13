# p910nd Print Server

[p910nd](http://man.cx/p910nd "http://man.cx/p910nd") is a small printer daemon intended for diskless platforms that does not spool to disk but passes the job directly to the printer. Normally a lpr daemon on a spooling host connects to it with a TCP connection on port 910n (where n=0, 1, or 2 for lp0, 1 and 2 respectively). p910nd is particularly useful for diskless platforms. Common Unix Printing System (CUPS) supports this protocol, it's called the AppSocket protocol and has the scheme

```
socket://remotehost:PORT
```

Windows and Mac Os X (via CUPS) also support this protocol. In mac OS Printer settings, the protocol is called `HP Jetdirect - Socket`. Before starting, ensure you do not also have node\_exporter scrape endpoints running on port 9100. If you do, adjust this guide to start with port 9101.

In this guide I show you how to enable printing support for HP M1120 and Canon MP480 printer.

## Install software on LEDE device

- SSH into device, e.g. `ssh 192.168.1.1`
- Enter `root` as username and supply with password
- Update OpenWrt software packages:
  
  ```
  opkg update
  ```
- Install Kernel modules for USB Printer support:
  
  ```
  opkg install kmod-usb-printer
  ```
- Install printer server:
  
  ```
  opkg install p910nd luci-app-p910nd
  ```

## Configure print server p910nd

1. Check if your printer is recognized:
   
   ```
   root@OpenWrt:~# ls /dev/usb/lp*
   /dev/usb/lp0
   ```
2. We can continue with configuring in **Services** → **p910nd - Printer server**:  
   [![](/_media/media/docs/howto/p910nd_01.png?w=600&tok=ce6b2e)](/_detail/media/docs/howto/p910nd_01.png?id=docs%3Aguide-user%3Aservices%3Aprint_server%3Ap910ndprinterserver "media:docs:howto:p910nd_01.png")  
   The screenshot speaks for itself: Check *enable*, set *Device* address and check/uncheck *Bidirectional mode*. Bidirectional mode depends on your router. On my HP printer I leave it enabled, on my Canon I must disable, else printing is not working.
3. Consider leaving the interface *unspecified* so it listens on all IPv4 interfaces (on 0.0.0.0, alas no IPv6 support).
4. You can add additional printers, but don't forget to set address of the new printer and set another port:  
   [![](/_media/media/docs/howto/p910nd_02.png?w=600&tok=81d4d1)](/_detail/media/docs/howto/p910nd_02.png?id=docs%3Aguide-user%3Aservices%3Aprint_server%3Ap910ndprinterserver "media:docs:howto:p910nd_02.png")

You should also open a port in the [firewall](/packages/index/network---firewall "packages:index:network---firewall") for each printer configured. Once the above is done, it might be necessary to restart the print server with:

```
/etc/init.d/p910nd restart
```

## Configure clients

### Windows

First, install drivers for your printer.

1. Add a local printer:  
   [![](/_media/media/docs/howto/p910nd_03.png?w=600&tok=56c929)](/_detail/media/docs/howto/p910nd_03.png?id=docs%3Aguide-user%3Aservices%3Aprint_server%3Ap910ndprinterserver "media:docs:howto:p910nd_03.png")
2. Create a new Standard TCP/IP port for the printer:  
   [![](/_media/media/docs/howto/p910nd_04.png?w=600&tok=01edab)](/_detail/media/docs/howto/p910nd_04.png?id=docs%3Aguide-user%3Aservices%3Aprint_server%3Ap910ndprinterserver "media:docs:howto:p910nd_04.png")
3. Enter IP Address for the printer: e.g.: 192.168.1.1  
   [![](/_media/media/docs/howto/p910nd_05.png?w=600&tok=a7c0b3)](/_detail/media/docs/howto/p910nd_05.png?id=docs%3Aguide-user%3Aservices%3Aprint_server%3Ap910ndprinterserver "media:docs:howto:p910nd_05.png")
4. Specify additional information for the connection:  
   [![](/_media/media/docs/howto/p910nd_06.png?w=600&tok=d7eb07)](/_detail/media/docs/howto/p910nd_06.png?id=docs%3Aguide-user%3Aservices%3Aprint_server%3Ap910ndprinterserver "media:docs:howto:p910nd_06.png")
5. Choose “Raw” protocol and set port number. e.g.: 9100  
   [![](/_media/media/docs/howto/p910nd_07.png?w=600&tok=a2feda)](/_detail/media/docs/howto/p910nd_07.png?id=docs%3Aguide-user%3Aservices%3Aprint_server%3Ap910ndprinterserver "media:docs:howto:p910nd_07.png")
6. Pick a suitable printer driver:  
   [![](/_media/media/docs/howto/p910nd_08.png?w=600&tok=d5c959)](/_detail/media/docs/howto/p910nd_08.png?id=docs%3Aguide-user%3Aservices%3Aprint_server%3Ap910ndprinterserver "media:docs:howto:p910nd_08.png")
7. You may try to print a test page to the printer.

### Mac OS X Sierra

First, try configure your printer via System Preferences:

1. Printers → + (Add Printer) → IP tab:  
   [![](/_media/media/docs/howto/p910nd_09.png?w=600&tok=4d019b)](/_detail/media/docs/howto/p910nd_09.png?id=docs%3Aguide-user%3Aservices%3Aprint_server%3Ap910ndprinterserver "media:docs:howto:p910nd_09.png")
   
   ```
   Address: 192.168.1.1:9101 or socket://192.168.1.1:9101
   Protocol: HP Jetdirect - Socket
   Name: any name
   Use: Select Software... and select your printer.
   ```
2. Done. Try with a test print.

This method has worked for me with a HP M1120 printer, but it failed with a Canon MP480 (Error: unable to communicate with printer) and Brother HL-1110. So I added manually.

### Manual method

1. Open Terminal and enable CUPS Web Interface: paste in 'cupsctl WebInterface=yes' and click enter.  
   [![](/_media/media/docs/howto/p910nd_10.png?w=600&tok=2bd899)](/_detail/media/docs/howto/p910nd_10.png?id=docs%3Aguide-user%3Aservices%3Aprint_server%3Ap910ndprinterserver "media:docs:howto:p910nd_10.png")
2. Now you should be able to go to [http://localhost:631/](http://localhost:631/ "http://localhost:631/"):  
   [![](/_media/media/docs/howto/p910nd_11.png?w=600&tok=cb630a)](/_detail/media/docs/howto/p910nd_11.png?id=docs%3Aguide-user%3Aservices%3Aprint_server%3Ap910ndprinterserver "media:docs:howto:p910nd_11.png")
3. Click on **Adding Printers and Classes** in the center and on Add Printer. Log in with your system username/password. Select AppSocket/HP JetDirect and click on Continue.  
   [![](/_media/media/docs/howto/p910nd_12.png?w=600&tok=056f73)](/_detail/media/docs/howto/p910nd_12.png?id=docs%3Aguide-user%3Aservices%3Aprint_server%3Ap910ndprinterserver "media:docs:howto:p910nd_12.png")
4. In the Connection field type
   
   ```
   socket://yourLEDEipaddress:9100
   ```
   
   (where yourLEDEipaddress is the IP address of your router and PORT is what you configured earlier). Click on Continue.  
   [![](/_media/media/docs/howto/p910nd_13.png?w=600&tok=be6f2f)](/_detail/media/docs/howto/p910nd_13.png?id=docs%3Aguide-user%3Aservices%3Aprint_server%3Ap910ndprinterserver "media:docs:howto:p910nd_13.png")
5. On the next page type any printer name and click on Continue:  
   [![](/_media/media/docs/howto/p910nd_14.png?w=600&tok=d62130)](/_detail/media/docs/howto/p910nd_14.png?id=docs%3Aguide-user%3Aservices%3Aprint_server%3Ap910ndprinterserver "media:docs:howto:p910nd_14.png")
6. On the final page select your printer's manufacturer and model. Finally, click on Add Printer.  
   [![](/_media/media/docs/howto/p910nd_15.png?w=600&tok=5f8070)](/_detail/media/docs/howto/p910nd_15.png?id=docs%3Aguide-user%3Aservices%3Aprint_server%3Ap910ndprinterserver "media:docs:howto:p910nd_15.png")
7. You are done, try it with a test print.

For LEDE 17.01.x, p910nd printing should work straight away after completing above steps. For OpenWRT 18.06.x, you may need to power cycle the router after installing the p910nd packages. For 21.02.x, things should work straight away.

### Debugging

Okay, your printer is connected to the router, `lsusb -v` shows the device connected, and you have a `/dev/usb/lp0` also. You send data to the printer, but nothing happens. Connecting your computer directly to the printer works fine. Some forum posts note that you may need to send the printer firmware to the printer after power-on. In my printer's case, an [HP LaserJet 1018](https://www.openprinting.org/printer/HP/HP-LaserJet_1018 "https://www.openprinting.org/printer/HP/HP-LaserJet_1018"), it was necessary. GitHub might also have The dl file [for LaserJet 1018](https://github.com/inveneo/hub-linux-ubuntu/blob/master/install/overlay/usr/share/foo2zjs/firmware/sihp1018.dl "https://github.com/inveneo/hub-linux-ubuntu/blob/master/install/overlay/usr/share/foo2zjs/firmware/sihp1018.dl")

My printer wakes up with: `cat sihp1018.dl > /dev/usb/lp0`

Some users opted to run a script to automate this. On 21.02 - make a script `/etc/hotplug.d/usb/30-hplj1018`, `chmod +x /etc/hotplug.d/usb/30-hplj1018` and enjoy. See [hotplug for info to verify subsystems, and variables below.](/docs/guide-user/base-system/hotplug "docs:guide-user:base-system:hotplug")

[/etc/hotplug.d/usb/30-hplj1018](/_export/code/docs/guide-user/services/print_server/p910ndprinterserver?codeblock=8 "Download Snippet")

```
#!/bin/sh
 
set -e
 
# change this to the location where you put the .dl file:
FIRMWARE="/root/hplj1018.dl"
DEVICE=$(uci get p910nd.@p910nd[0].device)
LOGFILE=/var/log/hp
PROD_ID="3f0/4117/100"
DEV_TYPE="usb_device"
 
daemon_restart() {
    echo "$(date) : (Re)Starting print daemon" >> $LOGFILE
    /etc/init.d/p910nd restart
}
daemon_stop() {
    echo "$(date) : Stopping print daemon" >> $LOGFILE
    /etc/init.d/p910nd stop
}
send_firmware() {
    echo "$(date) : Sending firmware to printer" >> $LOGFILE
    cat $FIRMWARE > $DEVICE
    echo "$(date) : done." >> $LOGFILE
}
 
 
if [ "$PRODUCT" = "${PROD_ID}" ]; then
    case "$ACTION" in
        add)
            sleep 1
            # Check whether dev is character type
            if [ -c $DEVICE ]; then
                # Check whether the hotplug devtype is usb_device
                if [ "$DEVTYPE" = "${DEV_TYPE}" ]; then
                    send_firmware
                    daemon_restart
                fi
            fi
            ;;
        remove)
            daemon_stop
            ;;
        #Also available:
        bind)
            ;;
    esac
fi
```
