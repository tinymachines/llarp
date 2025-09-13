## Setting up a build VM in VirtualBox

The OpenWrt build VM will run on a Debian OS in VirtualBox. You are required to have a 64-bit OS and at least 8 GB free disk space.

## Instructions

### 1. Get VirtualBox

This program will let you run a virtual Linux machine on your PC. Download the newest version from [virtualbox.org](https://www.virtualbox.org/ "https://www.virtualbox.org/") and install using default settings.

### 2. Get a Debian image

Download the newest VirtualBox (VDI) 64-bit Debian image (currently 12 Bookworm) from [osboxes.org](http://www.osboxes.org/debian/ "http://www.osboxes.org/debian/") and unpack it using 7zip. 7zip can be downloaded from [7-zip.org](http://www.7-zip.org/ "http://www.7-zip.org/").

### 3. Install the virtual machine

01. Start Oracle VM VirtualBox
02. Click New
03. Name: OpenWrtDev
04. Type: Linux
05. Version: Debian (64-bit). See [here](https://superuser.com/questions/866962/why-does-virtualbox-only-have-32-bit-option-no-64-bit-option-on-windows-7 "https://superuser.com/questions/866962/why-does-virtualbox-only-have-32-bit-option-no-64-bit-option-on-windows-7") if 64-bit is not available.
06. Hard Disk: Select “Use an existing virtual hard disk file” and choose the Debian .vdi file you just unpacked.
07. Click Create
08. Right click on the OpenWrtDev image and click Settings
09. Select General, Advanced, Shared Clipboard: Bidirectional
10. Select Shared Folders
11. Right click Machine Folders and select Add Shared Folder
12. Folder path: Click the down arrow, select Other and then the folder you want to share with the virtual Debian machine (for transferring the firmware).
13. Folder Name: Shared
14. Select Auto-mount

### 4. Initial Debian setup

1. Select the OpenWrtDev image and click Start
2. Wait for it to finish booting and click osboxes.org
3. Password: osboxes.org
4. Click Activities, type term in the search field and click terminal

The interface for changing the keyboard is a bit weird, but you can find the correct place like this:

1. Click Activites, type reg, click Region &amp; Language
2. Click + under Input Sources and then the vertical dots
3. Click Other, select the language and click Add. You can now delete English.

From now on, whenever you should be in the terminal to type a command the syntax will look like this:

```
ls -l
```

This means you should type `ls -l` and press enter (try it).

Follow up questions with obvious answers like typing the passsword (osboxes.org) og confirming with y will not be included specifically in this guide. Cut and paste will unfortunately not work at this moment.

```
su -
nano /etc/apt/sources.list
```

You are now editing the list of servers to get updates from.

- Delete the lines containing “deb cdrom”. Lines can be deleted with ctrl-k.
- From the last two lines, remove the leading # and space, and the -updates after bullseye. They should now look like this:

```
deb http://deb.debian.org/debian/ bullseye main contrib
deb-src http://deb.debian.org/debian/ bullseye main contrib
```

- Type ctrl-x and then y and then enter to save and exit.

```
su - 
apt update
apt dist-upgrade
apt install linux-headers-amd64 make sudo
reboot
```

Log in and open the terminal again when it has rebooted.

Click Devices (top line), select the last option (Install Guest Additions). The automatic install does not seem to work, so it doesn't matter if you select cancel or run.

```
su -
sh /media/cdrom/VBoxLinuxAdditions.run
```

Finally, allow osboxes to use sudo (takes effect next time osboxes logs in).

```
adduser osboxes sudo
```

After this you will need to start the machine again.

Now you can change to a higher resolution so you get a larger window if you like:

1. Click Activities, type disp in the search field.
2. Click Displays, VBX
3. Select a different resolution

Your virtual Debian machine should now be set up correctly for following the rest of the guide. Congratulations. As a bonus, you now have a fully functional Linux computer that you can use for anything, and with the added safety of running it as a virtual machine. If you let the resolution match your monitor and select View/Full-screen mode there is almost no difference from a standalone Linux computer.
