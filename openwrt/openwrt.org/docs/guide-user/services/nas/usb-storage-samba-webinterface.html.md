# Share USB hard-drive with Samba using LuCI

USB ports are found on most routers, especially those with USB 3.0 ports can provide fast file sharing performance. A popular usage scenario is connecting a USB storage device like a flash or hard drive to share the content on your LAN. This recipe will guide you through how this can easily be set-up using the Luci web-interface.

## Install dependencies

You will find detailed walkthrough on [Samba](/docs/guide-user/services/nas/cifs.server "docs:guide-user:services:nas:cifs.server") which includes info on USB drivers, filesystems, and settings. At a minimum, you will need to install the packages:

- block-mount
- kmod-usb3
- kmod-usb-storage-uas
- luci-app-samba4

## Mount your USB drive

Whether you have USB flash, SSD, or HDD. Simply plug it in the USB port, and it should show be automatically detected by OpenWrt (if you SSH into the router you will typically find a new entry /dev/sda for the device, and /dev/sda1 for it's first partition). Now go to the **Mount Points** tab under System in Luci. You will find your USB storage device listed already as show below. Provided you have the filesystem installed all you need is to tick **Enable** and then **Save &amp; Apply**. ![:!:](/lib/images/smileys/exclaim.svg) Mount Points is only visible if dependencies are already installed:

[![The partition(s) on your USB device is already listed in Luci.](/_media/media/doc/recipes/usb-storage-samba-webinterface-mountpoint.png "The partition(s) on your USB device is already listed in Luci.")](/_detail/media/doc/recipes/usb-storage-samba-webinterface-mountpoint.png?id=docs%3Aguide-user%3Aservices%3Anas%3Ausb-storage-samba-webinterface "media:doc:recipes:usb-storage-samba-webinterface-mountpoint.png")

In my case I used the btrfs filesystem due to its advanced features. In this case you will need to change the file system. Choose **Edit**, and you will be able to revise like this:

[![Choose among installed file systems to match the formatting of your drive](/_media/media/doc/recipes/usb-storage-samba-webinterface-btrfsmount.png "Choose among installed file systems to match the formatting of your drive")](/_detail/media/doc/recipes/usb-storage-samba-webinterface-btrfsmount.png?id=docs%3Aguide-user%3Aservices%3Anas%3Ausb-storage-samba-webinterface "media:doc:recipes:usb-storage-samba-webinterface-btrfsmount.png")

## Share the drive on your local network

We will only show how to do simply sharing here. Samba supports advanced access policies, but this recipe is meant for the most common use case. Please consult [Samba advanced](/docs/guide-user/services/nas/samba "docs:guide-user:services:nas:samba") for more policy settings.

Open Luci, under **Services** choose the **Network Shares** tab. Here you will need to fill in the name of your shared folder as it will appear on you network. In our example we called it *Share*. You will also need to fill in the mount point from above, we used the default */home*. You will also need to tick **Allow guests** (otherwise setting up user access control is necessary). Tick Read-Only if you only want to have read access for clients, we allowed write access here:

[![Simple Samba set-up with read/write access for all clients on local network.](/_media/media/doc/recipes/usb-storage-samba-webinterface-guest.png "Simple Samba set-up with read/write access for all clients on local network.")](/_detail/media/doc/recipes/usb-storage-samba-webinterface-guest.png?id=docs%3Aguide-user%3Aservices%3Anas%3Ausb-storage-samba-webinterface "media:doc:recipes:usb-storage-samba-webinterface-guest.png")
