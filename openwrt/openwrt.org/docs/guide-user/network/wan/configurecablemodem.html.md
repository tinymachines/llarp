# How to configure Motorola cable modems (DOCSIS)

Most cable tv companies (e.g. Unitymedia, KabelBW and Kabel Deutschland in Germany) provide internet access as well as telephony services (Voice over Cable abbr. VoC) via their tv cables. After a technician upgraded your cable tv connection to be able to process uplink communication the technician will install a so call cable modem such as the “Motorola SBV5121E” which is very common for customers of Unitymedia in Germany.

The standard these modems work on is called “Data Over Cable Service Interface Specification” (DOCSIS).

##### Configuring OpenWrt for Usage with Motorola SBV modems

The motorola cable modems processes all necessary actions to allow access to the telephony and IP services. It provides a DHCP service which provides the system connected on its ethernet port with the public IP address. With OpenWrt 10.03 Backfire it is not necessary to configure the WAN port as it by default uses DHCP.

Your “/etc/config/network” file should look like this in the WAN section:

```
#### WAN configuration
config interface        wan
        option ifname   "eth0.1"
        option proto    dhcp
```

Additionally the device may be connected through the USB port to an OpenWrt router. If the connection to the USB port of your router does not show a further network interface you may have to install kmod-usb-net-rndis and its dependencies.

##### Accessing the Motorola cable modem

It can be sometimes helpful to check the status and signal strength of the Motorola modem. For this the modem itself can be access by its IP address which is 192.168.100.1. After entering that IP address in your browser you'll see a login screen requiring you to enter a username and a password. Type “admin” as username and “motorola” as password and the modem will show you all its details.

##### Troubleshooting

If your WAN interface is unable to obtain an IP address via DHCP reboot your cable modem first and try again. It is quite common that the cable modem does not recognize a newly attached device with a different MAC address. Keep this in mind for later occasions since this issue is quite unexpected and may take you long to figure out.

Mistakes often made with Motorola SBV modems is that accidentially the “StandBy” button on top of the modem itself has been pressed by removing dirt or dust from the modem. If pressed it puts the modem in stand by mode which makes it unusable. Press the standby button again to set it to active mode.

Also when your connection is slow or you often get disconnected make sure that the signal strength of your modem is at least at 37dB. Lower rates can cause connectivity problems. You can check the signal rate by accessing the modem in the way described above.
