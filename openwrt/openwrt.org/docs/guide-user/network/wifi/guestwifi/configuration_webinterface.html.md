# Guest Wi-Fi using LuCI

Guest Wi-Fi refers to a separate wireless network that provides Internet access for guests and/or untrusted devices while keeping them isolated from the main network. This guide is based on the more comprehensive [Guest Wi-Fi basics](/docs/guide-user/network/wifi/guestwifi/guest-wlan "docs:guide-user:network:wifi:guestwifi:guest-wlan"), providing a more user-friendly approach through the LuCI web interface.

## 1. Network

Start by creating an empty bridge device. This will ensure that the guest interface is always up and running regardless of the state of the wireless interface(s) and it’s a must to avoid problems with the DHCP server if the guest network needs to use both radios.

Go to Network→Interfaces→Devices

[![](/_media/media/doc/recipes/devices_page.png)](/_detail/media/doc/recipes/devices_page.png?id=docs%3Aguide-user%3Anetwork%3Awifi%3Aguestwifi%3Aconfiguration_webinterface "media:doc:recipes:devices_page.png")

Click “Add Device Configuration...”.

[![](/_media/media/doc/recipes/br_guest_dev.png)](/_detail/media/doc/recipes/br_guest_dev.png?id=docs%3Aguide-user%3Anetwork%3Awifi%3Aguestwifi%3Aconfiguration_webinterface "media:doc:recipes:br_guest_dev.png")

Set the Device type to “Bridge device”, name it “br-guest” and check the “Bring up empty bridge” box.  
Do not specify any wired ports.  
Click “Save”.

[![](/_media/media/doc/recipes/br_gue_added.png)](/_detail/media/doc/recipes/br_gue_added.png?id=docs%3Aguide-user%3Anetwork%3Awifi%3Aguestwifi%3Aconfiguration_webinterface "media:doc:recipes:br_gue_added.png")

Click “Save &amp; Apply”.  
Go to the “Interfaces” tab to create the new guest interface.

[![](/_media/media/doc/recipes/interfaces.png)](/_detail/media/doc/recipes/interfaces.png?id=docs%3Aguide-user%3Anetwork%3Awifi%3Aguestwifi%3Aconfiguration_webinterface "media:doc:recipes:interfaces.png")

Click “Add new interface...”.

[![](/_media/media/doc/recipes/add_new_interface.png)](/_detail/media/doc/recipes/add_new_interface.png?id=docs%3Aguide-user%3Anetwork%3Awifi%3Aguestwifi%3Aconfiguration_webinterface "media:doc:recipes:add_new_interface.png")

Set the interface name, set the protocol to “Static address”, select the previously created bridge device and click “Create interface”.

[![](/_media/media/doc/recipes/guest_int_ip.png)](/_detail/media/doc/recipes/guest_int_ip.png?id=docs%3Aguide-user%3Anetwork%3Awifi%3Aguestwifi%3Aconfiguration_webinterface "media:doc:recipes:guest_int_ip.png")

Set an IP address in a subnet that does not overlap with the address space used by any existing interface.  
Select mask “255.255.255.0”.  
Go to “Firewall Settings”.

[![](/_media/media/doc/recipes/create_zone.png)](/_detail/media/doc/recipes/create_zone.png?id=docs%3Aguide-user%3Anetwork%3Awifi%3Aguestwifi%3Aconfiguration_webinterface "media:doc:recipes:create_zone.png")

Enter a name (guest) in the “-- custom --” field to create a new guest zone and **press ENTER**.  
The guest interface will be assigned to the newly created firewall zone.  
Go to “DHCP Server”.

[![](/_media/media/doc/recipes/dhcp1.png)](/_detail/media/doc/recipes/dhcp1.png?id=docs%3Aguide-user%3Anetwork%3Awifi%3Aguestwifi%3Aconfiguration_webinterface "media:doc:recipes:dhcp1.png")

Click “Set up DHCP Server”.

[![](/_media/media/doc/recipes/dhcp2.png)](/_detail/media/doc/recipes/dhcp2.png?id=docs%3Aguide-user%3Anetwork%3Awifi%3Aguestwifi%3Aconfiguration_webinterface "media:doc:recipes:dhcp2.png")

Leave the default settings.  
Click “Save”, then “Save &amp; Apply”.

[![](/_media/media/doc/recipes/guest_int_up.png)](/_detail/media/doc/recipes/guest_int_up.png?id=docs%3Aguide-user%3Anetwork%3Awifi%3Aguestwifi%3Aconfiguration_webinterface "media:doc:recipes:guest_int_up.png")

Verify that the guest interface is up.

## 2. Wireless

Go to Network→Wireless

[![](/_media/media/doc/recipes/add_wifi.png)](/_detail/media/doc/recipes/add_wifi.png?id=docs%3Aguide-user%3Anetwork%3Awifi%3Aguestwifi%3Aconfiguration_webinterface "media:doc:recipes:add_wifi.png")

Click the “Add” button to the right of the radio you will be using.

[![](/_media/media/doc/recipes/wifi_setup.png)](/_detail/media/doc/recipes/wifi_setup.png?id=docs%3Aguide-user%3Anetwork%3Awifi%3Aguestwifi%3Aconfiguration_webinterface "media:doc:recipes:wifi_setup.png")

In “Interface Configuration”, set the SSID and attach the wireless interface to the guest network.  
Click “Save”, then “Save &amp; Apply”.

[![](/_media/media/doc/recipes/wifi_up.png)](/_detail/media/doc/recipes/wifi_up.png?id=docs%3Aguide-user%3Anetwork%3Awifi%3Aguestwifi%3Aconfiguration_webinterface "media:doc:recipes:wifi_up.png")

## 3. Firewall

Go to Network→Firewall.

[![](/_media/media/doc/recipes/zones1.png)](/_detail/media/doc/recipes/zones1.png?id=docs%3Aguide-user%3Anetwork%3Awifi%3Aguestwifi%3Aconfiguration_webinterface "media:doc:recipes:zones1.png")

Make sure that the guest firewall zone was created during the creation of the interface and the default policies for the Input, Output and Forward chains look like on the screenshot.  
Click “Edit” next to the guest zone.

[![](/_media/media/doc/recipes/forw.png)](/_detail/media/doc/recipes/forw.png?id=docs%3Aguide-user%3Anetwork%3Awifi%3Aguestwifi%3Aconfiguration_webinterface "media:doc:recipes:forw.png")

Allow forward to the wan zone and click “Save”, then “Save &amp; Apply”.

[![](/_media/media/doc/recipes/zones2.png)](/_detail/media/doc/recipes/zones2.png?id=docs%3Aguide-user%3Anetwork%3Awifi%3Aguestwifi%3Aconfiguration_webinterface "media:doc:recipes:zones2.png")

Finally, create traffic rules accepting DNS and DHCP requests originating from the guest zone.

[![](/_media/media/doc/recipes/traff1.png)](/_detail/media/doc/recipes/traff1.png?id=docs%3Aguide-user%3Anetwork%3Awifi%3Aguestwifi%3Aconfiguration_webinterface "media:doc:recipes:traff1.png")

[![](/_media/media/doc/recipes/traff2.png)](/_detail/media/doc/recipes/traff2.png?id=docs%3Aguide-user%3Anetwork%3Awifi%3Aguestwifi%3Aconfiguration_webinterface "media:doc:recipes:traff2.png")

## 4. Troubleshooting

Your device is unable to connect to the guest-AP:

This might be caused the device doesn't get a IP address assigned by the DHCP-server. Please check that the DHCP-server on your OpenWrt-router is configured to listen to the “guest”-interface.

\* Go-to “Network → DHCP and DNS → (tab) Devices &amp; Ports”.

\* If “non-wildcard” is enabled, ensure that the “guest”-interface is added to “Listening interfaces”.
