# Secure and turn on Wi-Fi

The last thing we'll want to do is turn on and secure our Wi-Fi networks. When you install a new copy of OpenWrt on a router, the Wi-Fi networks are disabled for security reasons until you have a chance to set Wi-Fi passwords. Let's do that now.

To get started let's go to the Wi-Fi configuration page. We can get to it by going to the “Network” menu on the top of the page and selecting the “Wi-Fi” or “Wireless” item.

[![](/_media/media/doc/walkthrough-wifi-1-1.png?w=750&h=750&tok=7b9df2)](/_detail/media/doc/walkthrough-wifi-1-1.png?id=docs%3Aguide-quick-start%3Awalkthrough_wifi "media:doc:walkthrough-wifi-1-1.png")

We're at the main Wi-Fi page. This page contains the information related to the physical radios in the router which handle Wi-Fi communication and the Wi-Fi networks associated with them. While it's possible for each physical radio to have multiple Wi-Fi networks set up, ours should only have a single network on each of them with an SSID of “OpenWrt”.

You might see a different number of radios on this page. Most routers have one or two radios but it depends on how the router is designed.

You'll notice the buttons next to each of the networks. These buttons allow us to enable the network, edit the network's settings or remove the network. In our case, we're going to want to edit the network settings. Click the “Edit” button on the top-most network on the page.

[![](/_media/media/doc/walkthrough-wifi-1-2.png?w=750&h=750&tok=4af360)](/_detail/media/doc/walkthrough-wifi-1-2.png?id=docs%3Aguide-quick-start%3Awalkthrough_wifi "media:doc:walkthrough-wifi-1-2.png")

We're at the configuration page for our Wi-Fi network. From this page, you can control advanced settings for the Wi-Fi network. Feel free to scan through the settings; they're pretty interesting if you want to learn more about how OpenWrt works. Most importantly for our purposes, we can set up the security for our Wi-Fi network. Additionally at the top you'll see some tabs. Each tab contains the settings for one of the Wi-Fi networks on the router. In our case, the first one should be selected.

Note: Care should be taken when selecting wireless channel, transmit power and selecting a regulatory location (Country Code) in the advanced tab. Defaults should be OK. You could change your channel to something your devices are unable to communicate on. Changing your regulatory domain could yield more channel availability, but setting this incorrectly could be an offense.

[![](/_media/media/doc/walkthrough-wifi-2-1.png?w=750&h=750&tok=10da0e)](/_detail/media/doc/walkthrough-wifi-2-1.png?id=docs%3Aguide-quick-start%3Awalkthrough_wifi "media:doc:walkthrough-wifi-2-1.png")

Let's set our Wi-Fi password now. The Wi-Fi password settings are in “Wireless Security” in the “Interface Configuration” section about halfway down the page. Click “Wireless Security”.

[![](/_media/media/doc/walkthrough-wifi-1-3.png?w=750&h=750&tok=4ea1a9)](/_detail/media/doc/walkthrough-wifi-1-3.png?id=docs%3Aguide-quick-start%3Awalkthrough_wifi "media:doc:walkthrough-wifi-1-3.png")

Next you should see a drop down box titled “Encryption”. We want to select “WPA2-PSK” in the drop down box.

[![](/_media/media/doc/walkthrough-wifi-1-4.png?w=750&h=750&tok=91f091)](/_detail/media/doc/walkthrough-wifi-1-4.png?id=docs%3Aguide-quick-start%3Awalkthrough_wifi "media:doc:walkthrough-wifi-1-4.png")

Once you select “WPA2-PSK”, two new form fields will pop up: “cipher” and “key”. We don't need to do anything with “cipher” so we'll leave that as “auto”. The field we really care about “key”. “Key” is the technical name for the password you'll use when connecting to your Wi-Fi network. We'll set that next.

[![](/_media/media/doc/walkthrough-wifi-1-5.png?w=750&h=750&tok=76c7bb)](/_detail/media/doc/walkthrough-wifi-1-5.png?id=docs%3Aguide-quick-start%3Awalkthrough_wifi "media:doc:walkthrough-wifi-1-5.png")

Once you've come up with a password, type it into the the “key” box. If you want to make sure you've typed the password correctly, press the green cycle icon next to the password box. Once you do so, you should be able to see the password you've typed.

Now that we've set our password, let's press the “Save &amp; Apply” button to finalize the changes on the router. You should be brought back to the top of the page. A set of notifications will update you on the changes being saved and tell you when the changes are done.

[![](/_media/media/doc/walkthrough-wifi-1-6.png?w=750&h=750&tok=c55093)](/_detail/media/doc/walkthrough-wifi-1-6.png?id=docs%3Aguide-quick-start%3Awalkthrough_wifi "media:doc:walkthrough-wifi-1-6.png")

Now that our Wi-Fi password has been set, it's time to turn on our Wi-Fi network! We'll do that by pressing the “Enable” button.

[![](/_media/media/doc/walkthrough-wifi-1-7.png?w=750&h=750&tok=517ea5)](/_detail/media/doc/walkthrough-wifi-1-7.png?id=docs%3Aguide-quick-start%3Awalkthrough_wifi "media:doc:walkthrough-wifi-1-7.png")

After about 15 seconds, the Wi-Fi status should no longer say disabled. Additionally, it should provide additional information about the Wi-Fi network. This information includes:

- Network name (SSID)
- The current connection quality for clients. If none are connected, it's normal for this to say 0%.
- Encryption method
- Wi-Fi channel
- Transfer speed. If no clients are connected, this will say 0.0. That's normal!

If you only have one wireless network on your router, you're done setting up networks. You'll know this because near the top of the page, you'll only have one tab for Wi-Fi networks. If you have more wireless networks, then you should go to each of them in turn and set them up using the same process. You can do that by clicking on the tab for each of the wireless networks as shown in the screenshot below.

For ease of use, I highly recommend using the same password for every network on your router. There's no real harm in this unless you have a set up that is quite different from the one described in this walkthrough.

[![](/_media/media/doc/walkthrough-wifi-1-8.png?w=750&h=750&tok=2a1f4d)](/_detail/media/doc/walkthrough-wifi-1-8.png?id=docs%3Aguide-quick-start%3Awalkthrough_wifi "media:doc:walkthrough-wifi-1-8.png")

Your Wi-Fi network is set up! You can connect to the Wi-Fi network “OpenWrt” with the proper key. You should have access to the internet. If you don't normally connect with a network cable to the device you've been using to set up your router, feel free to unplug that.

[**Last step: Internet connectivity, troubleshooting and what to do next -&gt;**](/docs/guide-quick-start/checks_and_troubleshooting "docs:guide-quick-start:checks_and_troubleshooting")
