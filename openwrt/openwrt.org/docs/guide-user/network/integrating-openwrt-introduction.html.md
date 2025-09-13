# Integrating an OpenWrt network device in your network

If you want to have an OpenWrt-powered network infrastructure, there are good chances you will need to reconfigure (or replace) the device the ISP gave you to access Internet. In case you wonder what an ISP is, it's the company you pay for your Internet access.

The main reason is that daisy-chaining routers is not a good idea. Depending on the type of Internet access equipment you have or have been given by your ISP, you may encounter a situation known as double NAT, which isn't good.  
While double NAT doesn't generally have any ill effects on run-of-the-mill network connectivity -- Web browsing, e-mail, IM, and so forth -- it can be a major impediment when you need remote access to devices on your network, preventing you from connecting to your OpenWrt device's webinterface, ssh, VPN, ftp, http, Nextcloud, Seafile, and whatever else service you might want to install on your devices to be accessible from outside of your own local network.  
Double NAT also screws up communication between devices connected to the upstream device (the device provided by the ISP) and the downstream device (the OpenWrt router).

## What is NAT

In a typical home network, you are allotted a single public IP address by your ISP, and this address gets issued to your router when you plug it into the ISP-provided gateway device (e.g. a cable or DSL modem). The router's Wide Area Network (WAN) port gets the public IP address, and PCs and other devices that are connected to LAN ports (or via Wi-Fi) become part of a private network, usually in the 192.168.x.x address range. NAT manages the connectivity between the public Internet and your private network, and either UPnP or manual port forwarding ensures that incoming connections from the Internet (i.e. remote access requests) find their way through NAT to the appropriate private network PC or other device.

## What is Double NAT

When NAT is being performed not just on your router but also on another device that's connected upstream (on its WAN port/interface, usually), you've got double NAT. In this case, the public/private network boundary doesn't exist on your router -- it's on the other device, which means that both the WAN and LAN sides of your router are private networks.  
Any UPnP and/or port forwarding you enable on your OpenWrt router is pointless, because incoming remote access requests never make it that far -- they arrive at the public IP address on the upstream device, where they're promptly discarded. Double NATing will also have a performance impact on bandwidth and latency because more processing is required by the network device to relay traffic.

## Upstream NAT

If the double NAT is happening in your own network, you can usually fix it or at least sidestep it. But many ISPs use NAT within their network infrastructure so they don't waste public IP addresses, in this case the only way to fix it is to call them and ask (and pay) for a public IP. It's usually affordable.

To check for double NAT on your upstream network, log into your ISP device and look up the IP address of its WAN port. If you see an address in the 10.x.x.x, 172.16.x.x or 192.168.x.x range (these are private IP ranges according to IPv4 standards) it means that the device your router's WAN port connects to is doing NAT, and hence, you're dealing with double NAT.

Also, another way is to look at the IP address of its WAN port, and connect to a site that tells you your public IP address like for example [whatismyipaddress.com](http://whatismyipaddress.com/ "http://whatismyipaddress.com/"), and if the two IP addresses differ... yeah you guessed it, your ISP is using NAT.

For Linux users, there are also CLI commands to run that can provide what is the WAN IP address of the router you can then compare to the IP shown by the websites. [From here](https://www.cyberciti.biz/faq/how-to-find-my-public-ip-address-from-command-line-on-a-linux/ "https://www.cyberciti.biz/faq/how-to-find-my-public-ip-address-from-command-line-on-a-linux/")

`dig +short myip.opendns.com @resolver1.opendns.com`

* * *

Based on [this external Article](http://www.practicallynetworked.com/networking/fixing_double_nat.htm "http://www.practicallynetworked.com/networking/fixing_double_nat.htm") by Joe Moran
