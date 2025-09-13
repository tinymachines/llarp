# SoftEther VPN Client

## Introduction

- The guide was written for version 21.02 (current at time of writing). I experienced severe issues in 22.03, so your mileage on current-as-of-update might vary.
- This how-to describes the method for setting up the [SoftEther VPN](https://en.wikipedia.org/wiki/SoftEther%20VPN "https://en.wikipedia.org/wiki/SoftEther VPN") **client** on OpenWrt.
- Follow [SoftEther VPN server](/inbox/softether_vpn/server "inbox:softether_vpn:server") for server setup and [SoftEther VPN extras](/inbox/softether_vpn/extras "inbox:softether_vpn:extras") for additional tuning.
- This guide was in part adapted from kyson-lok at the [GL.iNnet forums](https://forum.gl-inet.com/t/installing-soft-ether-client/1956/12 "https://forum.gl-inet.com/t/installing-soft-ether-client/1956/12") and from [Anuradha Karunarathna](https://anuradha-15.medium.com/installation-guide-of-softether-vpn-client-on-linux-54a405a0ae2c "https://anuradha-15.medium.com/installation-guide-of-softether-vpn-client-on-linux-54a405a0ae2c") .
- The [SoftEther VPN Manual](https://www.softether.org/4-docs/1-manual "https://www.softether.org/4-docs/1-manual") is also a highly useful resource.
- The guide will use both LuCI and CLI; feel free to use LuCI-equivalent CLI commands where appropriate. CLI can alternatively be almost entirely avoided with access to a Windows PC and SoftEther's remote management tool.

## Goals

## Instructions

### 1. Install Packages

1. Log into LuCI
2. Go to “System” → “Software”
3. Click “Update lists...”
4. Filter the list for “softether”
5. Install “softethervpn5-libs”
6. Install “softethervpn5-client”
7. Install “luci-app-softether” (somewhat optional - very limited LuCI interface at this point)
8. Reboot the router

### 2. Configure SoftEther VPN Client

*Note: If you have a Windows PC, you can use the remote client manager (“Manage Remote Computer's SoftEther VPN Client” in Start) to set everything up via GUI after issuing the command “RemoteEnable” in command line client management. It is also possible to drop an existing configuration file into place via SCP.*

The guide here will show configuration with CLI/SSH, for which you issue the following command:

```
vpncmd
```

- The following prompt will appear:

```
By using vpncmd program, the following can be achieved. 
1. Management of VPN Server or VPN Bridge 
2. Management of VPN Client
3. Use of VPN Tools (certificate creation and Network Traffic Speed Test Tool)
Select 1, 2 or 3:
```

- Type “2” and confirm with “Enter”
- The following prompt will appear:

```
Specify the host name or IP address of the computer that the destination VPN Client is operating on. 
If nothing is input and Enter is pressed, connection will be made to localhost (this computer).
Hostname of IP Address of Destination: 
```

- Simply press “Enter” (since you want to manage localhost)
- The following prompt will appear:

```
Connected to VPN Client "localhost".
VPN Client>
```

- Create a VPN network device by issuing the following command (replacing &lt;devName&gt; with your name of choice)[1)](#fn__1)

```
NicCreate <devName>
```

- Configure the VPN connection by issuing the following command (replacing &lt;accountName&gt; with your name of choice)

```
AccountCreate <accountName>
```

- You will now be prompted for a number of connection parameters. Fill in the &lt;placeholders&gt; with the relevant information - these will depend on how you've configured your server, except for &lt;devName&gt; which you chose above.

```
Destination VPN Server Host Name and Port Number: <server address or IP>:<server port>
Destination Virtual Hub Name: <server virtual hub>
Connecting User Name: <user name>
Used Virtual Network Adapter Name: <devName>
```

- Issue the following command to finish configuration:

```
AccountPasswordSet <accountName>
```

- Follow the prompts to configure the user password for the VPN connection (again depending on how you configured your server; for standard configurations you want to choose “standard” at the last prompt)
- Exit the VPNcmd environment with Ctrl+C

### 3. Configure OpenWRT networking

1. Log into LuCI
2. *First, you need to set up a suitable interface:*
   
   01. Go to “Network” → “Interfaces”
   02. Click “Add new interface...”
   03. For “Name”, choose and enter an &lt;ifName&gt; (e.g. “VPN”)
   04. For “Protocol”, select “DHCP client”
   05. For “Device”, select the Ethernet adapter “vpn\_&lt;devName&gt;” (name chosen in part 2)
   06. Click “Create interface”
   07. Go to “Advanced Settings” tab
   08. Disable “Use default gateway”
   09. Disable “Delegate IPv6 prefixes”[2)](#fn__2)
   10. Go to “Firewall Settings” tab
   11. Select “wan” from the drop-down[3)](#fn__3)
   12. Click “Save”
   13. Click “Save &amp; Apply”
3. *The following block of steps were necessary on my setup to make things work, but that might be due to server-side issues*
   
   1. Go to “Devices” tab
   2. For “vpn\_&lt;devName&gt;”, click “Configure”
   3. Disable “Enable IPv6” checkbox
   4. Click “Save”
   5. Click “Save &amp; Apply”
4. *Lastly you just need to set up routing. My setup works well with specific static routes as shown here (i.e., VPN use only for specific connections); I haven't gotten it to work with VPN-as-default routing however.*
   
   1. Go to “Network” → “Static Routes”
   2. Click “Add...”
   3. For “Interface”, select &lt;ifName&gt; (created earlier)
   4. For “Target”, specify the remote IP you want VPN traffic routing for
   5. For “Netmask”, specify the remote IP range for the above address
   6. For “Gateway”, specify the VPN server gateway IP. This will depend on how you have set up the VPN-server-side DHCP (e.g. via Softether VPN server SecureNAT, in which case the default I believe is 192.168.30.1).
   7. Click “Save”
   8. Click “Save &amp; Apply”
5. Reboot the router

### 4. Starting/Stopping the VPN

*Note: If you have a Windows PC, you can again use the remote client manager (“Manage Remote Computer's SoftEther VPN Client” in Start) for these parts.*

The guide will again use CLI/SSH, for which you issue the following command:

```
vpncmd
```

- The following prompt will appear:

```
By using vpncmd program, the following can be achieved. 
1. Management of VPN Server or VPN Bridge 
2. Management of VPN Client
3. Use of VPN Tools (certificate creation and Network Traffic Speed Test Tool)
Select 1, 2 or 3:
```

- Type “2” and confirm with “Enter”
- The following prompt will appear:

```
Specify the host name or IP address of the computer that the destination VPN Client is operating on. 
If nothing is input and Enter is pressed, connection will be made to localhost (this computer).
Hostname of IP Address of Destination: 
```

- Simply press “Enter” (since you want to manage localhost)
- The following prompt will appear:

```
Connected to VPN Client "localhost".
VPN Client>
```

- **To start the VPN**, issue the following command (replacing &lt;accountName&gt; with your chosen one from step 2)

```
AccountConnect <accountName>
```

- **To stop the VPN**, issue the following command (replacing &lt;accountName&gt; with your chosen one from step 2)

```
AccountConnect <accountName>
```

- **To auto-start the VPN on boot**, issue the following command (replacing &lt;accountName&gt; with your chosen one from step 2)

```
AccountStartupSet <accountName>
```

- To later disable auto-start, issue the following command (replacing &lt;accountName&gt; with your chosen one from step 2)

```
AccountStartupRemove <accountName>
```

- Exit the VPNcmd environment with Ctrl+C

## Testing

*Note: traceroute doesn't work properly for me with the VPN running, unfortunately. However, you can confirm routing e.g. by setting up static routes for an IP geolocation server or similar and checking that way.*

## Troubleshooting

If you've installed the “luci-app-softether” package, you can check the connection status in LuCI under System → Softether. If you have a Windows PC, you can use the remote client manager for this. Or you can again use vpncmd (refer to the official documentation).

[1)](#fnt__1)

note that this is a SoftEther-level name; at system-level, the device name will automatically be prefixed with “vpn\_”

[2)](#fnt__2)

might be optional; unconfirmed

[3)](#fnt__3)

this will treat the VPN as part of the WAN zone to simplify firewall setup; if you need fine-tuned control, you can create a new zone with new rules
