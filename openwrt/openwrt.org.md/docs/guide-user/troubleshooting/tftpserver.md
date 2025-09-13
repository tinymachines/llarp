## What is TFTP Recovery over Ethernet?

On most devices, the vendor provides a bootloader on a discreet partition that is untouched by firmware updates. In case of a failed flash process or a misconfiguration, the device's bootloader usually remains untouched and can therefore be used to reflash the firmware and recover the device.

There are two potential modes of operation:

**1. TFTP recovery client**

For many routers, the recovery process requires you to host the firmware image on a TFTP server on your computer. The device with the broken firmware then has to be started up in TFTP recovery mode. Some devices will then automatically pull the network-provided firmware file over TFTP network protocol to the bootloader, and hopefully recover with a successful emergency flash process.

Other devices do not have an automatic pull function and they need you to manually issue commands in recovery mode, to download the firmware via TFTP, and initiate the install.

**2. TFTP recovery server**

Some other routers, e.g. many Netgear routers, run a TFTP server in recovery mode, and you need to upload the firmware to the device using a TFTP client.

The below article mainly advises on the first mode of recovery, i.e. the router runs a TFTP client and you need to host the firmware image on a TFTP server.

## Is TFTP Recovery over Ethernet supported by my device?

TFTP recovery over Ethernet is not supported by every router model. TFTP recovery is based on a device- and vendor-specific boot loader that may or may not be present on your device. Check the OpenWrt device page for your precise model to find out, if your device has a boot loader supporting TFTP recovery. If your device supports it, then this recovery function will still be present in your device boot loader, after OpenWrt firmware has been flashed onto the device.

Note: ● Your device boot loader could alternatively have implemented TFTP recovery over [serial cable](/docs/techref/hardware/port.serial.cables "docs:techref:hardware:port.serial.cables"), which is not covered on this page. ● Your device could also have [other means of recovery](/docs/guide-user/troubleshooting/vendor_specific_rescue "docs:guide-user:troubleshooting:vendor_specific_rescue").

## Setting up TFTP Recovery

Information on using TFTP to install OpenWrt is also available here: [generic.flashing.tftp](/docs/guide-user/installation/generic.flashing.tftp "docs:guide-user:installation:generic.flashing.tftp").

The following procedure only describes how to set up a TFTP server over Ethernet for the TFTP recovery preparation process, it does not describe the device-specific flash recovery process. For the actual flash process you should consult the vendor provided documentation, the Internet, the OpenWrt Forum, or the OpenWrt device pages.

1. Download the desired OpenWrt (or stock) firmware image to the designated TFTP directory on your computer (and rename it if needed).
2. Set the IP address of your computer's Ethernet interface as described in the Device Page for your model.
3. Start the TFTP server on your computer.
4. Connect your computer and your device with Ethernet cable.
5. Power up the router and press a device-specific button to start firmware recovery, or access bootloader recovery options, and install recovery firmware over TFTP.
6. Stop the TFTP server on your computer.

### Setting up a TFTP server for TFTP Recovery

**Important Information!**  
TFTP server &amp; client tools (based on the [TFTP](https://en.wikipedia.org/wiki/wiki/Trivial_File_Transfer_Protocol "https://en.wikipedia.org/wiki/wiki/Trivial_File_Transfer_Protocol") protocol) employ no access controls while allowing light-weight file transfer between networked devices.  
Do not leave TFTP services running longer than needed and use a firewall to restrict access to the local subnet.

Access to TFTP-client (`tftp`) and TFTP-server (`tftpd`) tool/app must be made secure, from *(primarily)* hackers in internet *(and TFTP-server &amp; client both must also be kept securely isolated from harmful/ignorant internal users or from hijacked computers, inside your own LAN network)*. If necessary, create a separate subnet under a 2nd level router, then work / develop / troubleshoot under that separate subnet with network devices which will handle TFTP client/server protocols.

If your computer is also used as a desktop computer for general purpose or for other purpose than build/compile, then make sure TFTP-client &amp; TFTP-server, are both placed behind a firewall *(`frwl`)* system or rules[1](https://unix.stackexchange.com/questions/99270/ "https://unix.stackexchange.com/questions/99270/"), [2](https://www.cyberciti.biz/faq/install-configure-tftp-server-ubuntu-debian-howto/ "https://www.cyberciti.biz/faq/install-configure-tftp-server-ubuntu-debian-howto/"). Firewall rules should be:

- *(frwl rule # 1)* allow TFTP traffic (UDP 69) only when connections originate from a local LAN ip.address range and also end in the local LAN ip.address range
- *(frwl rule # 2)* TFTP traffic is Not-Allowed when it is from/to `127.0.0.1` or `lo`
- *(frwl rule # 3)* TFTP traffic is Not-Allowed when originated from Internet-ip-address *(aka: NON private-LAN ip-address ranges)*

And you must also make sure to do this: after your develop / troubleshooting etc work is done or when you pause to goto other work, then make sure the TFTP-server and TFTP-client both are completely disabled in your OS/distro : turn off TFTP-server service / process, disable TFTP-server startup script file, and **move** the TFTP-client (`tftp`) &amp; the TFTP-server (`tftpd`) executable / binary *(`bin`)* files out of all folders mentioned in your PATH variable, into a different folder (which is NOT in the PATH variable), and also move bin files out of the folder which is mentioned in startup-script *(if such is used)*.

**If you keep TFTP-server running or if you keep the TFTP-client tool available to run anytime, then abusive hackers can abuse/exploit it, to load harmful firmware and/or to change sensitive security settings inside your existing router firmware[1](https://nvd.nist.gov/vuln/detail/CVE-2020-26130 "https://nvd.nist.gov/vuln/detail/CVE-2020-26130"), [2](https://www.cvedetails.com/vulnerability-list.php?vendor_id=98&product_id=0&version_id=0&page=1&hasexp=0&opdos=0&opec=0&opov=0&opcsrf=0&opgpriv=0&opsqli=0&opxss=0&opdirt=0&opmemc=0&ophttprs=0&opbyp=0&opfileinc=0&opginf=0&cvssscoremin=0&cvssscoremax=0&year=0&cweid=0&order=1&trc=4 "https://www.cvedetails.com/vulnerability-list.php?vendor_id=98&product_id=0&version_id=0&page=1&hasexp=0&opdos=0&opec=0&opov=0&opcsrf=0&opgpriv=0&opsqli=0&opxss=0&opdirt=0&opmemc=0&ophttprs=0&opbyp=0&opfileinc=0&opginf=0&cvssscoremin=0&cvssscoremax=0&year=0&cweid=0&order=1&trc=4"), [3](https://www.cvedetails.com/vulnerability-list/vendor_id-7940/Tftp-server.html "https://www.cvedetails.com/vulnerability-list/vendor_id-7940/Tftp-server.html"), [4](https://www.cvedetails.com/vulnerability-list/vendor_id-1305/product_id-2282/Solarwinds-Tftp-Server.html "https://www.cvedetails.com/vulnerability-list/vendor_id-1305/product_id-2282/Solarwinds-Tftp-Server.html"), [5](https://www.cvedetails.com/vulnerability-list/vendor_id-16/product_id-1628/Cisco-Tftp-Server.html "https://www.cvedetails.com/vulnerability-list/vendor_id-16/product_id-1628/Cisco-Tftp-Server.html"), [6](https://nvd.nist.gov/vuln/detail/CVE-2019-0603 "https://nvd.nist.gov/vuln/detail/CVE-2019-0603"), etc.**

### Setting up a TFTP server on macOS

macOS provides a native tftpd server that runs the command line. However, it is not verified to work on recent versions (10.15.x). So alternative option-1 is: use `dnsmasq` instead. Alternative option-2 is: use MacPorts *(or other)* package-manager &amp; obtain tftpd server &amp; dnsmasq, more info is here: [buildroot.exigence.macosx](/docs/guide-developer/toolchain/buildroot.exigence.macosx "docs:guide-developer:toolchain:buildroot.exigence.macosx"). There are also GUI *(frontend/wrapper)* applications *(for CLI based tftp, tftpd tools)* that are available for users who prefer such, *(in example: `TftpServer.app`)*. There are also GUI based tftp &amp; tftpd app, *(in example: `PumpKIN.app`)*.

#### dnsmasq (on macOS):

Dnsmasq can be installed easily via [Homebrew](https://brew.sh "https://brew.sh") or [MacPorts](https://www.macports.org/ "https://www.macports.org/") and has the advantage of being able to offer a DHCP server if necessary.

● Launch it in this way (if you use Homebrew pkg-mngr):

```
 $ sudo /usr/local/opt/dnsmasq/sbin/dnsmasq -i enX -p 0 -z --enable-tftp --tftp-root /tmp 
```

● Launch it in this way (if you use MacPorts pkg-mngr):

```
 $ sudo /opt/local/sbin/dnsmasq -i enX -p 0 -z --enable-tftp --tftp-root /tmp 
```

Replace `enX` with the interface identifier of your Ethernet adapter (use `ifconfig` to find it out) and `/tmp` to the directory containing the image you want to serve. Don't forget to kill the process (e.g. using the `Activity Monitor`) before you want to start a new instance of `dnsmasq`.

#### macOS Command-Line Native tftpd:

For recent versions of macOS, the system-supplied `tftpd` is managed with `launchctl`. Users should be comfortable with command-line usage and `sudo` to take this approach. As confirmed on macOS Sierra 10.12.6 and macOS Mojave 10.14.2, the general steps involved are

● Configure your network interface for the proper server address for your device. Using System Preferences &gt; Network is perhaps the easiest. ● Connect your device to the network interface. ● Start `tftpd`

```
$ sudo cp path/to/file/to/serve.bin /private/tftpboot/the_name_the_device_is_looking_for.bin
$ sudo launchctl load -F /System/Library/LaunchDaemons/tftp.plist 
```

● Confirm `tfptd` is running by looking for the UDP listener on port 69

```
$ netstat -an | fgrep \*.69    
udp4       0      0  *.69                   *.*                               
```

● Activate your device's recovery/TFTP mode

- When done with `tftpd`, shut it down with
  
  ```
   $ sudo launchctl unload -F /System/Library/LaunchDaemons/tftp.plist 
  ```

#### TftpServer.app (on macOS):

As an example of a GUI wrapper (aka: frontend) based TFTP server, the `TftpServer.app` from [http://ww2.unime.it/flr/tftpserver/](http://ww2.unime.it/flr/tftpserver/ "http://ww2.unime.it/flr/tftpserver/") provides a pleasant GUI frontend / wrapper around macOS native command that makes the process less error prone. Info from older site on usage of this app is [here](https://web.archive.org/web/20200427215239/http://ww2.unime.it/flr/tftpserver/ "https://web.archive.org/web/20200427215239/http://ww2.unime.it/flr/tftpserver/").

- This procedure was tested with `TftpServer.app` v 3.4.1 on OSX 10.10.5 in December 2016.
- The v3.4.1 `TftpServer.dmg` file has SHA256: eb71d62da9c0dd6cdf54d604e87083e1a4e7084f8da4bc4e8c196da19e012583 &amp; size: 656,775 bytes, and the “TftpServer**.**app” has 731,378 bytes. DMG file contains APP file. We found mention of updated version v3.5.1 on author's older website via `Internet Archive Wayback Machine`, obtained on April 27, 2020[1](https://web.archive.org/web/20200427215239/http://ww2.unime.it/flr/tftpserver/ "https://web.archive.org/web/20200427215239/http://ww2.unime.it/flr/tftpserver/").
- Author's contact info: *fabrizio.larosa.nospam**@**unime5**.**it* (*remove the `.nospam` portion &amp; remove the `5`, to get author's actual email address*) or *fab.larosa.spamnotallowed**@**gmail1**.**com* (*remove the `.spamnotallowed` portion &amp; remove the `1`, to get author's actual email address*).

<!--THE END-->

01. Download `dmg` file from the URL[1](http://ww2.unime.it/flr/tftpserver/ "http://ww2.unime.it/flr/tftpserver/") mentioned above, and install the `TftpServer.app` inside that `dmg` file. Do not download this app or dmg file from any untrustworthy websites. Do not download unknown version or “new” versions, that is not-shared or not-mentioned by actual author.
02. Move the application to a convenient directory.
03. In the same directory, create another folder named 'tftpfiles'. This is the 'designated TFTP directory'. *TftpServer.app and tftpfiles will be in the same directory.*
04. Set the OSX IP address as specified in the Device Page's TFTP Recovery section.
05. Launch TftpServer.app. The window is shown here. *You should confirm that you see the desired file named in the window.*  
    :[![](/_media/media/tftpserver-osx.png?w=200&tok=faa3d8)](/_detail/media/tftpserver-osx.png?id=docs%3Aguide-user%3Atroubleshooting%3Atftpserver "media:tftpserver-osx.png")
06. Click “Start TFTP” (upper left). *You should see the “Server Status:” change to “Running”.*
07. Start your router and press the button. *The file will transfer.*
08. *Note:* TftpServer.app may give warnings about file permissions. Use the “Fix” buttons at the bottom of the window to set the permissions properly.
09. Click “Stop TFTP” or quit the application to stop the TFTP server.
10. Precautions : keep this app firewalled *(and allow only LAN based TFTP)*, or disable this app when you are done working with TFTP, or disable this app when you pause to goto other work. Do not keep this app continuously running.

#### PumpKIN.app (on macOS):

This app `PumpKIN.app` has GUI interface and also contains builtin TFTP server &amp; client functionalities, it can be obtained from [https://kin.klever.net/pumpkin/](https://kin.klever.net/pumpkin/ "https://kin.klever.net/pumpkin/") website. [Dnld](https://kin.klever.net/pumpkin/binaries/ "https://kin.klever.net/pumpkin/binaries/"), [Src](https://kin.klever.net/pumpkin/repository/ "https://kin.klever.net/pumpkin/repository/"), Tech description [here](https://kin.klever.net/pumpkin/description/ "https://kin.klever.net/pumpkin/description/"), Help file [here](https://kin.klever.net/pumpkin/help/ "https://kin.klever.net/pumpkin/help/").

- It is developed by Michael Krelin ( *hacker.nospam**@**klever5**.**net* , *remove the `.nospam` portion &amp; remove the `5`, to get author's actual contact info* ).
- The `pumpkin-0.0.1-osx.dmg` file has SHA256: 0f857db4ae91907946cfc050f72a17714524d3380fb1e8bc8cb25acfd5f83a67 &amp; size: 796,711 bytes, and the `PumpKIN.app` size: 876,994 bytes.
- Precautions : keep this app firewalled *(and allow only LAN based TFTP)*, or disable this app when you are done working with TFTP, or disable this app when you pause to goto other work. Do not keep this app continuously running.

#### Tools/Pkgs via Pkg-Mngr (on macOS):

macOS compatible *(3rd-party)* pkg-mngr *(package-manager)* info is displayed in [buildroot.exigence.macosx](/docs/guide-developer/toolchain/buildroot.exigence.macosx "docs:guide-developer:toolchain:buildroot.exigence.macosx") page, inside `Install Package Manager` section.

if you have MacPorts pkg-mngr, then run**:**

```
 $ sudo port install inetutils dnsmasq 
```

- the `inetutils` pkg includes `telnet`, `ftp`, `rsh`, `rlogin`, `tftp` client tools, and also includes corresponding daemons/servers, as bundle[1](https://ports.macports.org/search/?q=utils&name=on "https://ports.macports.org/search/?q=utils&name=on").

### Setting up a TFTP server on Windows

While there is a command line TFTP **client** feature in Windows, Microsoft has stopped shipping a tftp **server** for security reasons. A third party tftp server will therefore be required.

The built-in client tftp feature can be installed from an administrator cmd.exe command prompt as follows:

```
Dism /online /Enable-Feature /FeatureName:TFTP /All
```

(You can use the client to test if your TFTP server is working.)  
Regardless of which TFTP server below that you choose to use, you will need to open a local firewall rule to allow inbound client TFTP connections from the local subnet. For security reasons, only traffic from the local LAN subnet should be allowed. Start a cmd.exe prompt as admin then run:

```
netsh advfirewall firewall add rule name="TFTP" dir=in action=allow protocol=udp localport=69 remoteip=localsubnet interfacetype=lan profile=private,public
```

#### Tftpd64 (on Windows):

A simple and free TFTP application is **Tftpd64**, available [here](http://tftpd32.jounin.net/ "http://tftpd32.jounin.net/").

Download the portable version, and unzip it in a folder. You should see the manual, a license in a PDF file, a configuration file, and the application executable itself.

Place the file you want to send (the firmware file usually) in the same folder where you find the **Tftpd64** program file. The folder exposed through TFTP can be changed by clicking on Browse button, but in most situations you don't need to do that.

Configure your Ethernet port according to your device's own recovery method as detailed in [Rescue from failed firmware upgrade](/docs/guide-user/troubleshooting/vendor_specific_rescue "docs:guide-user:troubleshooting:vendor_specific_rescue"), note that in most cases you can't use that port to connect to the internet until you reconfigure it back like it was before.

This application might stop listening on the local UDP port at the very moment that you need it, i.e. when the router at the other end of the network connection restarts. To work around this issue, do one of the following:

- Disable [media sensing](https://docs.microsoft.com/en-us/troubleshoot/windows-server/networking/disable-media-sensing-feature-for-tcpip "https://docs.microsoft.com/en-us/troubleshoot/windows-server/networking/disable-media-sensing-feature-for-tcpip"):
  
  ```
  netsh interface ipv4 set global dhcpmediasense=disabled
  netsh interface ipv6 set global dhcpmediasense=disabled
  ```
- Use a switch between the TFTP host and the client router so that the network link of the Windows machine remains up while the router is rebooting.

Double-click on the **Tftpd64** program file and you should get a Windows Firewall popup asking you to grant access. Check both options, to allow **Tftpd64** to communicate over both home/work but *not* public networks. This is very important, if the Windows Firewall blocks your TFTP server you won't be able to access it from the device you want to recover.

Click on the drop-down menu called **Server Interfaces** and select your PC's Ethernet port.

Now the TFTP server is online and ready, and the file(s) in it can be accessed as normal.

#### Tiny PXE (on Windows):

[Tiny PXE](http://reboot.pro/files/file/303-tiny-pxe-server/ "http://reboot.pro/files/file/303-tiny-pxe-server/") seems to do the same as Tftpd64 plus BOOTP support (particularly useful for [MikroTik devices](/toh/mikrotik/common "toh:mikrotik:common")).

#### Solarwinds TFTP Server

A free TFTP server for Windows can be downloaded [here](https://www.solarwinds.com/free-tools/free-tftp-server "https://www.solarwinds.com/free-tools/free-tftp-server") (registration is required).

- The default install will use the directory `C:\TFTP-Root` - place your firmware file in this directory and rename it per the instructions for your specific device.
- Under File | Configure | Security, set “Send files” as the only permissible action.
- Change the local LAN IP address of your computer to the static IP that your router expects.
- Follow the procedure for your specific router to trigger its TFTP client to download the firmware image you are hosting.
- Watch the Solarwinds console to ensure that the router has downloaded the firmware file.

**Important: Stop the TFTP service and prevent it from auto-restarting as soon as you are done so your machine is not left in an insecure configuration:**

```
sc config "Solarwinds TFTP Server" start=demand
sc stop "Solarwinds TFTP Server"
```

### Setting up a TFTP server on Linux

#### dnsmasq (on Linux):

**dnsmasq** is pre-installed in most distributions.

Create directory where you want to put the recovery image file:

```
bash#  mkdir /srv/tftp 
```

Put an image file into your directory - actual name will vary:

```
bash#  cp ~/tp_recovery.bin /srv/tftp 
```

Run TFTP server:

```
bash#  dnsmasq --listen-address=0.0.0.0 --port=0 --enable-tftp --tftp-root=/srv/tftp --tftp-no-blocksize --user=root --group=root 
```

Check if your TFTP server is listening:

```
bash#  netstat -lunp | grep 69 
```

#### atftpd (on Linux):

You can also use **atftpd**:

Install atftpd from repository on Debian/Ubuntu/Mint:

```
bash#  apt install atftpd 
```

Install atftpd from repository on RedHat/Fedora/Centos:

```
bash#  yum install atftpd 
```

Create directory where you want to put the recovery image file:

```
bash#  mkdir /srv/tftp 
```

Put an image file into your directory - actual name will vary:

```
bash#  cp ~/tp_recovery.bin /srv/tftp 
```

Change the ownership of the folder and the file in it:

```
bash#  chown nobody:nogroup -R /srv/tftp 
```

Run TFTP server (run as daemon, do not fork, log events to stdout):

```
bash#  atftpd --daemon --no-fork --logfile - /srv/tftp 
```

Check if your TFTP server is listening:

```
bash#  netstat -lunp | grep 69 
```

Or if netstat is not available:

```
bash#  ss -lunp | grep 69 
```

- *If not set, you should try running TFTP server as superuser.*

#### Testing TFTP server (on Linux):

**Check that you can in fact pull the file from your TFTP server.** Preferably from another computer call your TFTP server IP: (*or if not possible, in same server call IP 127.0.0.1*):

```
bash#  tftp 192.168.0.66
tftp> get tp_recovery.bin
Received 8152633 bytes in 0.8 seconds
tftp> quit 
```

If you have received the file, congratulations, it's ready.

## Troubleshooting steps

TFTP file transfer doesn't work from local computer

- Check if your TFTP server is running and listening
- Check if TFTP folder is set up correctly (location, access rights)
- Check if firmware file is set up correctly (location, access rights)

TFTP file transfer works from local computer, but not from another computer:

- Check if network cable is connected properly
- Check if server IP is set correctly
- Check that you have opened up UDP 69 traffic from the local subnet in the host firewall.
- Restart the server if you have just changed the local host IP address.
- Run a packet sniffing tool like [Wireshark](https://www.wireshark.org/ "https://www.wireshark.org/"), while using “tftp” as the display filter.

TFTP file transfer works from another computer, but not from router:

- Check if server IP is set correctly (same as router is searching for)
- Check that the host running the TFTP server is using the specific fixed IP address and subnet mask that your router is expecting to use.
- Try using alternate cable, a crossover cable or alternate switch/speed
- Try connecting to an alternate port on the router / routers switch
- Pay attention to any output or verbosity from the router console or led activity if available
- Verify the arp cache on either host... server side is easier...
- Use arp -s to add a static mapping or arp -d to delete stale entries...
- Use a third host to simply ping the router, both with static addresses if possible
- Try an alternate server software, client software or TFTP transfer mode
- If you get some activity, timing can often yield results, power cycle the router and start the transfer earlier or later...
- Check that you have downloaded a firmware image that contains “tftp” in its filename, and that you have renamed this file to the specific OEM filename that your router is expecting.
