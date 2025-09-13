# OpenWrt Starter FAQ

**All right, so I have successfully flashed OpenWrt on my device, what should I do next?**  
These are some ideas to get you started:

1. Set an initial password for the root account ([OpenWrt security hardening](/docs/guide-user/security/openwrt_security#setting_the_root_password "docs:guide-user:security:openwrt_security")).
2. Set up your device as a Wi-Fi access point ([Enabling a Wi-Fi access point on OpenWrt](/docs/guide-quick-start/basic_wifi "docs:guide-quick-start:basic_wifi")).
3. Get familiar with the troubleshooting and rescue options available ([Troubleshooting](/docs/guide-user/troubleshooting/start "docs:guide-user:troubleshooting:start")).
4. Browse the [User guide](/docs/guide-user/start "docs:guide-user:start") for further configuration and network setups you may be interested in.

**How do I access the web admin GUI on a default installation?**  
Open either `http://192.168.1.1` or `http://openwrt.lan` in a web browser.

**What is the default administrator username in OpenWrt?**  
`root`

**What is the initial password for the root user?**  
There is no initial password set for root. Please, refer to [OpenWrt security hardening](/docs/guide-user/security/openwrt_security#setting_the_root_password "docs:guide-user:security:openwrt_security").

**Can I reset the 'root' password, in case I have forgotten it?**  
Yes, you can. Refer to [Resetting a forgotten root password](/docs/guide-user/troubleshooting/root_password_reset "docs:guide-user:troubleshooting:root_password_reset").

**I seem to have messed up the OpenWrt device configuration, my device is no longer accessible. What can I do now?**  
Refer to [Failsafe and factory reset](/docs/guide-user/troubleshooting/failsafe_and_factory_reset "docs:guide-user:troubleshooting:failsafe_and_factory_reset").

**How can I enable SSL (HTTPS) for the admin web GUI?**  
Refer to [Accessing LuCI web interface securely](/docs/guide-user/luci/luci.secure "docs:guide-user:luci:luci.secure").

**Is there a text editor available on the command-line through SSH?**  
You can use either `vi` or `vim`, which are available on OpenWrt out of the box. The most important key shortcuts in these two text editors are:

&lt;Press ESC key&gt; → &lt;Type “:q!” and press ENTER&gt;Exit and close the file without saving. &lt;Press ESC key&gt; → &lt;Type “:wq” and press ENTER&gt;Save and close the file. &lt;Press ESC key&gt; → &lt;Press the “i” key&gt;Insert text at the current cursor position. &lt;Press ESC key&gt; → &lt;Press the “x” key&gt;Delete the character under the cursor. &lt;Press ESC key&gt; → &lt;Press the “d” key twice in a row&gt;Delete the whole current line. &lt;Press ESC key&gt; → &lt;Press the “o” key&gt; (lowercase letter)Open a new line below the cursor. &lt;Press ESC key&gt; → &lt;Press the “O” key&gt; (uppercase letter)Open a new line above the cursor. &lt;Press ESC key&gt; → &lt;Press the “u” key&gt;Undo the last edit.

**What tools can I use to administer OpenWrt from a Windows computer?**  
There are a number of tools described in [SSH access for newcomers](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration"), such as cmder, SmarTTY, PuTTY and WinSCP.

**I would like to customize OpenWrt, but am having difficulties finding the packages that I am interested in.**  
Remember to first run `opkg update` if you haven't since last OpenWrt reboot. OpenWrt will only store the retrieved package list in a temporary RAM filesystem, losing the list of updates on every reboot.

**Why is there both a “WAN” and a “WAN6” network interface on OpenWrt, and then a “LAN” interface but not its “LAN6” counterpart?**  
Both the WAN and the WAN6 network interfaces hold configuration data related to the upstream side of the network:

- The WAN interface is for IPv4 and has “DHCP client”.
- The WAN6 interface is for IPv6 and has “DHCPv6 client”.

On the other hand, the LAN interface is capable of holding configuration data of the downstream side of the network for both the IPv4 and the IPv6 protocols, so there is no need to have an extra LAN6 interface.

**Note:** there is a network interface as well as a firewall zone named “LAN”. Similarly, “WAN” is used both as a name for the IPv4 WAN interface and for a zone. Both the WAN and the WAN6 network interfaces belong to the same zone, named “WAN”. A “WAN6” zone does not exist.

**Why is there both a “Save &amp; Apply” and a “Save” button in LuCI?**  
You can do several different changes in different tabs, each time clicking “Save” without committing the changes. You can then use “Save &amp; Apply” to commit all of those changes in one transaction.

**What is the difference of total available, free and buffered memory shown in LuCI status overview?**

Memory typeDefinition Total availableFree + buffered. BufferedMemory that is temporarily in use to handle I/O operations. FreeReal amount of memory available to use.
