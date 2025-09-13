# Log into your router running OpenWrt

We've installed OpenWrt but now is time to get our router configured. Visit your router's administration page. No matter what the address was before, OpenWrt simplifies this by setting the administration address to be [http://192.168.1.1/](http://192.168.1.1/ "http://192.168.1.1/"). At that page you should see a login page: (correct as of Barrier Breaker)

[![](/_media/media/doc/walkthrough-login-screen-1.png?w=1000&tok=3157a6)](/_detail/media/doc/walkthrough-login-screen-1.png?id=docs%3Aguide-quick-start%3Awalkthrough_login "media:doc:walkthrough-login-screen-1.png")

As you'll see, there's a notification that “root” user's password is not set. root is the username of the main administrative user on OpenWrt. We'll need to set that after we login. Log in with the username of **root** and leave the password field empty.

*Note: If you cannot log in when the “No password set!” message is on-screen, even when the password field is blank, it could be a cookie problem. (Especially common with OpenWrt 21.02.) See [https://github.com/openwrt/luci/issues/5104#issuecomment-855692620](https://github.com/openwrt/luci/issues/5104#issuecomment-855692620 "https://github.com/openwrt/luci/issues/5104#issuecomment-855692620") for a possible workaround.*

*Note: If you have installed a “tiny” build or a “snapshot” build, LuCI web interface will likely not be present and you will need to [use ssh to log in](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration") as `root@192.168.1.1` (telnet is no longer supported by OpenWrt-project builds)*

*Note: If the configuration of your router prior to flashing was somewhat exotic (e.g. router previously at 192.168.17.1), your PC (or whatever) might struggle to reconnect. If in doubt, consider simply rebooting the PC, or any other way to reset the connection.*

## Status page

Once you've logged in, you'll see the main status page. From here you can get a high-level view of your routers status. We'll go through some of the information viewable on this page.

[![](/_media/media/doc/walkthrough-status-screen-2.png?w=1000&tok=f0ed39)](/_detail/media/doc/walkthrough-status-screen-2.png?id=docs%3Aguide-quick-start%3Awalkthrough_login "media:doc:walkthrough-status-screen-2.png")

In the first screen shot, you can see some basic system information like the version of OpenWrt and the web interface packages of OpenWrt, which is named LuCI. Additionally, you can see the uptime for the router since last reboot, the current clock time on the router and how much of the router's processor is used (“load”). Let's scroll down a little.

[![](/_media/media/doc/walkthrough-status-screen-3.png?w=1000&tok=4c2adb)](/_detail/media/doc/walkthrough-status-screen-3.png?id=docs%3Aguide-quick-start%3Awalkthrough_login "media:doc:walkthrough-status-screen-3.png")

In the second screenshot, you see the router's memory usage. As services are started on the router, the “total available memory” will go down. In the case of the screenshot, there's lot of memory still available. If the amount is very low, the router could slow down and behave erratically. In that case, one would need to stop and disable services on the router. That's beyond the scope of this walkthrough but it's important to know.

Next we'll see the Network section. The Network section shows information about the network interface of the router, particularly as it applies to IP addresses. Additionally, you'll see the transmission speed of data going through those interfaces. At the end of the network section, you'll see how many network connections are going through the router compared to the maximum supported by the router.

[![](/_media/media/doc/walkthrough-status-screen-4.png?w=1000&tok=dc6f51)](/_detail/media/doc/walkthrough-status-screen-4.png?id=docs%3Aguide-quick-start%3Awalkthrough_login "media:doc:walkthrough-status-screen-4.png")

In this final screen shot, you'll see the DHCP leases computers on the router. Without getting into details, DHCP leases represent temporary IP addresses that the router will give out to client computers. Lastly there is information about the wireless networks for your router. You may have a different number than in this screen shot depending on your router model but all of them will be disabled for initial security purposes. Don't worry, we'll turn them on in just little bit.

Now that we have a sense of the information on the status page, we need to fix that lack of a root password. We can do that by scrolling back up to the top of the page and clicking “Go to password configuration...” in the box titled “No password set!”

## Set up root password

Before we actually do anything else, we need to set the root password. As we mentioned, root is the username of the administrative user in OpenWrt. Since this is an extremely powerful account, we need to provide a strong password that you'll remember. Once you have a new password, type it into the “password” field and then repeat it into the “confirmation” field. Make sure to remember this password; when you log into the router again, you'll need this password.

[![](/_media/media/doc/walkthrough-password-config-5.png?w=1000&tok=aa2a78)](/_detail/media/doc/walkthrough-password-config-5.png?id=docs%3Aguide-quick-start%3Awalkthrough_login "media:doc:walkthrough-password-config-5.png")

While not absolutely necessary, it's useful to set up SSH access with Dropbear. Without getting into detail SSH, allows you to login via a command line. In some rare situations, you may need to login to the diagnose problems without visiting the web administration. In that case you would use SSH so it's important to have that setup. Fortunately, the default settings allow that so we won't have to change anything.

[![](/_media/media/doc/walkthrough-password-screen-setup-dropbear-6.png?w=1000&tok=d3a9fe)](/_detail/media/doc/walkthrough-password-screen-setup-dropbear-6.png?id=docs%3Aguide-quick-start%3Awalkthrough_login "media:doc:walkthrough-password-screen-setup-dropbear-6.png")

Lastly, we click “Save &amp; Apply” to finalize our changes on this page.

[![](/_media/media/doc/walkthrough-password-save-and-apply-7.png?w=1000&tok=11301a)](/_detail/media/doc/walkthrough-password-save-and-apply-7.png?id=docs%3Aguide-quick-start%3Awalkthrough_login "media:doc:walkthrough-password-save-and-apply-7.png")

Now that we've set our root password, we only have to turn on and secure our Wi-Fi networks and we'll be done.

[**Next step: Secure and Turn On Wi-Fi -&gt;**](/docs/guide-quick-start/walkthrough_wifi "docs:guide-quick-start:walkthrough_wifi")

If you don't have/need Wi-Fi you can skip to the last step:

[**Last step: Internet connectivity, troubleshooting and what to do next -&gt;**](/docs/guide-quick-start/checks_and_troubleshooting "docs:guide-quick-start:checks_and_troubleshooting")
