# WireGuard extras

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

## Introduction

- This how-to describes the most common [WireGuard](https://en.wikipedia.org/wiki/WireGuard "https://en.wikipedia.org/wiki/WireGuard") tuning scenarios adapted for OpenWrt.
- Follow [WireGuard server](/docs/guide-user/services/vpn/wireguard/server "docs:guide-user:services:vpn:wireguard:server") for server setup and [WireGuard client](/docs/guide-user/services/vpn/wireguard/client "docs:guide-user:services:vpn:wireguard:client") for client setup.
- Follow [WireGuard protocol](/docs/guide-user/network/tunneling_interface_protocols#protocol_wireguard_wireguard_vpn "docs:guide-user:network:tunneling_interface_protocols") for server and client configuration.
- Follow [DDNS client](/docs/guide-user/services/ddns/client "docs:guide-user:services:ddns:client") to use own server with dynamic IP address.
- Follow [Random generator](/docs/guide-user/services/rng "docs:guide-user:services:rng") to overcome low entropy issues.

## Extras

### References

- [WireGuard for mobile/desktop/server](https://www.wireguard.com/install/ "https://www.wireguard.com/install/")
- [WireGuard documentation](https://www.wireguard.com/quickstart/ "https://www.wireguard.com/quickstart/")
- [WireGuard configuration examples](https://wiki.archlinux.org/index.php/WireGuard "https://wiki.archlinux.org/index.php/WireGuard")
- [Wireguard on Openwrt router setup (Protonvpn.com guide)](https://protonvpn.com/support/openwrt-wireguard "https://protonvpn.com/support/openwrt-wireguard")
- [Wireguard on Openwrt router setup (Mullvad.net guide)](https://mullvad.net/en/help/running-wireguard-router "https://mullvad.net/en/help/running-wireguard-router")
- [Wireguard on Openwrt router setup (Ivpn.net guide)](https://www.ivpn.net/setup/router/openwrt-wireguard/ "https://www.ivpn.net/setup/router/openwrt-wireguard/")

### Web interface

If you want to manage VPN settings and view VPN status using web interface. Install the necessary packages.

```
# Install packages
opkg update
opkg install luci-proto-wireguard qrencode
service rpcd restart
```

- Navigate to **LuCI → Network → Interfaces** to configure WireGuard.
- Navigate to **LuCI → Status → WireGuard** to view WireGuard status.

### Connection probe / VPN automation failover script

No current VPN providers have a Luci app for OpenWrt that acts like their OS-specific desktop, laptop &amp; mobile VPN clients. Those apps can dynamically pull VPN server info, and connect on an as-needed basis, to the closest/fastest VPN server, or other preferences you have [(example)](https://github.com/litepresence/NordVPN-Server-Switcher/blob/master/nordvpn.py "https://github.com/litepresence/NordVPN-Server-Switcher/blob/master/nordvpn.py"). When moving your VPN client connection from your individual devices to the router, you must initially make your own (wireguard) interface(s) on the router. ( ProtonVPN examples: [see here](https://protonvpn.com/support/openwrt-wireguard "https://protonvpn.com/support/openwrt-wireguard"), and [here](https://www.reddit.com/r/ProtonVPN/comments/zf5b79/were_testing_ipv6_on_our_servers_and_we_need_your/ "https://www.reddit.com/r/ProtonVPN/comments/zf5b79/were_testing_ipv6_on_our_servers_and_we_need_your/") ). However, since individual VPN servers can go down for maintenance, or have other issues, and you would otherwise lose the oversight, redundancy and error-checking provided by using a direct client-based app, one way to improve the conditions at the router, is to have a boot script periodically checking your VPN profile for connectivity. If the check fails, it either addresses the basic wan connectivity, if that failed, or if that is ok, it tries bringing up each VPN profile, one at a time. If none of them are able to connect, it logs that information so you can take corrective action.

**REQUIREMENTS and PREREQUISITES:**

- This script requires the **fping** package.
  
  - Extended functions require **bash**, per cake-autorate install guide.
  - Extended functions of CAKE-AUTORATE/SQM auto-management are disabled by default, requiring [OpenWRT SQM guide (luci-app-sqm)](/docs/guide-user/network/traffic-shaping/sqm#installation "docs:guide-user:network:traffic-shaping:sqm") and [cake-autorate](https://github.com/lynxthecat/cake-autorate/blob/master/INSTALLATION.md "https://github.com/lynxthecat/cake-autorate/blob/master/INSTALLATION.md"). Cake-Autorate provide automated adjustments for cell connection variability compensation-optimization, on top of SQM.
- This script is an upgraded version of the script [here](/toh/netgear/lbr20#qmiwwan04g_lte_monitoring_script "toh:netgear:lbr20"). For devices that have a cell modem, particularly Quectel cellular devices that seem to have firmware stability issues, which are also the cheapest cell devices and widely used in consumer hardware. This script augments the stability of the overall router operation.
- **Plain QMI** is supported. Not tested on other methods of WWAN device, e.g. MBIM or other. ModemManager auto-management's routines would interfere with this script, so you'd have to change the script accordingly. Quectel devices seem to have hard-lock issues after a few minutes of uptime, if the MTU (MBIM or ModemManager) is set, but plain QMI seems quite stable.
- **SQM can significantly increase router CPU requirements**
- Make sure your WWAN interface name (e.g. 'qmippp') and WWAN device name ('wwan0') is **the same** as the one in the script. Modify the script as necessary for WWANNAME &amp; WWANDEVICE variable settings.
- **IPv4 and IPv6: fping is testing both**, and will report failure if either fails. Therefore, [your VPN must support IPv4 &amp; IPv6](https://www.reddit.com/r/ProtonVPN/comments/zf5b79/were_testing_ipv6_on_our_servers_and_we_need_your/ "https://www.reddit.com/r/ProtonVPN/comments/zf5b79/were_testing_ipv6_on_our_servers_and_we_need_your/"), or you can modify the function in the script to only test what you have.
- **Set-up 4 VPN interfaces**
  
  - Make sure each VPN works, by itself. Here is a set-up guide: [Wireguard on OpenWrt guide](https://protonvpn.com/support/openwrt-wireguard "https://protonvpn.com/support/openwrt-wireguard"). **Uncheck 'Bring up on boot'** for each VPN interface.
  - Modify the variable declarations in the script to match those names.
  - **VPN=“0”** if you do not want VPN support with this script.
- **The boot wait time is set to 4 seconds for testing purposes from the shell.** The script will run-once, then exit (not loop). Set BOOTWAIT to 45 or more, when you have manually run this script and it works. Execute '/root/wan-watchdog.sh &amp;' and it will run in the background, then you can exit the shell. If you've modified the rc.local as described below, it will be called at next boot.

MISC:

- Some functions in wan-watchdog, are pulled from /lib/functions/network.sh.
- As with all scripts, when creating it at /root/wan-watchdog.sh, you must do a 'chmod +x /root/wan-watchdog.sh' to make it executable.

```
#!/bin/sh

#wan-watchdog.sh v.20250720
# Changelog: Newest comments at the top #
# Slight logging changes for clarification, some syntax updates, and timing issues (waiting longer for qmippp to come up)
# VPN=0 handling improvement/fixes.
# Enabled SQM and cake to run on the plain WWAN device, e.g. wwan0, if VPN=0.
# Cleaned up: the use of /lib/functions/network.sh
# Cleaned up: the bootwait logic. Funciontionally, the previous version of the script works fine, but it makes more sense to do it this way.
# Fixed the cake-autorate logic. Cake-autorate responds variously 'not running' or 'inactive' when it is not running (why?? who knows?).
# Added/changed/updated: clearing SQM interfaces after changing/starting VPN
# Added: Exporting CURRENTVPN value to file for use by cake-autorate.sh.
# Changed: write CURRENTVPN for use by outside scripts to /tmp not /root. It doesn't need to be /root / persistent between restarts.
# Added: logfile as variable instead of explicitly 
# Improved: FPING function to test IPv4 and IPv6 both, and issue a failure if either one fails.

# Setup: Call this script from rc.local with '/root/wan-watchdog.sh &'
# On cell-connected routers, what this is designed-for, your rc.local calls this script at startup:
#
# sleep 15
# service sysntpd restart # To make sure the time & date is set correctly on the router before this script runs.
# /root/wan-watchdog.sh &

log_file="/root/wan_watchdoglog.txt"

echo -e "\n" # new blank line
	if [ -f ${log_file} ]
		then 
		echo "Logfile check. Logfile ${log_file} exists, continuing..."
	elif ! [ -f ${log_file} ]
		then
		echo "Logfile ${log_file} does not exist... creating."
		echo "Logfile created on $(date)." > $log_file
	fi

# Ordinary: start-on-boot and loop, checking the connection, etc: Requires a value of '45' (seconds) or more.
# Testing mode: Less than 45 will cause this script to run 1 time then exit, and if there is a total wwan failure, it will echo to the screen 'reboot' but not actually reboot the router.
# The wait period gives your modem time to connect. Should be at least 45 seconds under ordinary circumstances.
BOOTWAIT="4"
# Usually 45-360 seconds. Initial waiting period before testing. Must be 45 or more to loop in an ordinary run.
# ATTENTION: If this value is less than xx (seconds, set below), this script will not loop back, nor reboot your router on total failure.
# Instead, this script will run 1 time, check if the wan connection (WWAN) is up, and, if you have set VPN to 1, it will check that too.
# This is done in case you reboot your router manually with the script in test mode, the script does not automatically keep running or go into a boot-loop.
	if [ $BOOTWAIT -ge 45 ] ; then # Test BOOTWAIT value if less/more than 60 to determine test run or normal run mode.
		echo "Watchdog script running in normal mode. $(date)." | tee -a "$log_file"
		TESTMODE="0"
	elif [ $BOOTWAIT -lt 45 ] ; then
		echo "Bootwait less than 45 seconds. Running in test Mode. $(date)" >> "$log_file"
		echo "Watchdog script running in test-mode, run once and exit."
		echo "Verbose responses to screen / not logged, and no reboot."
		TESTMODE="1"
	fi


LOOPWAIT="10" # How long to wait after a complete process of checking connectivity, to do it again.

DOYOULIKECAKE="0" # Set to 1 to enable the cake-autorate
# To add Cake-Autorate on top of SQM, for variable-speed internet uplinks (cellular, typically):
# 1. You must have SQM installed (luci-app-sqm).
# 2. Cake-autorotate must be already set-up according to: https://github.com/lynxthecat/cake-autorate/blob/master/INSTALLATION.md
# 3. Initially you must manually start each VPN profile, one at a time, and go to the Network->SQM QoS menu, and 'Enable this SQM Instance', set the DL/UL, and Queue Discipline to Cake/Layer-of-cake 
# 4. Do that with all 4 VPN instances individually.
# 5. Do it also with the plain wwan0 interface/device. Shut off all VPN's then configure Cake/layer-of-cake using the Luci SQM menu on it.
#	SQM will remember the configurations for each device: VPN's and raw wwan0. When it is restarted in this script, during testing
#	mode you will see errors for all the OTHER devices that are not active. That is normal.
# 6. Note: There are also some lines that need to be modified in /root/cake-autorate/config.primary.sh Cake-Autorate config, as follows:
#   Add:
#    read -r CAKEWAN < /tmp/currentvpn.txt
#   Change:
#    dl_if="ifb4${CAKEWAN}" # This will show up in current versions of cake-autorate's config.primary.sh as "dl_if=ifb-wan" instead of dl_if=ifb4wan. They should be changed as specified here.
#    ul_if="${CAKEWAN}"
# 6. After you manually get cake-autorate working, DISABLE the cake-autorate service from auto-start: 
#	Choose 'disabled' (from System->Startup) for cake-autorate. Instead, this script will manually start cake-autorate at the appropriate stage.

# Put here, your wwan/cell connection interface name & wwan device name:
WWANNAME="qmippp" # The WWAN Interface Name: used e.g. for the quectel modem restart portion of the script and detecting whether the wwan is working.
WWANDEVICE="wwan0" # The WWAN DEVICE: used for the cake/sqm portion of the script when VPN=0

# Define whether you want to use VPN's: 1 for yes 0 for no. You may, for whatever reason, not want to use VPN's on your router at some time, e.g. during testing.
# ATTENTION: Reminder when you set-up all your VPN profiles, to configure them to NOT 'Start on boot'. Let this script start them instead.
VPN="1"

# Put here the names of your VPN Interfaces (Luci->Network->Interfaces):
# ATTENTION: None of your VPN profiles (interfaces) should be set to 'Start at boot'. UNCHECK that. And manually test each one to make sure they work.
VPN1="protonvpn"
VPN2="protonvpn2"
VPN3="protonvpn3"
VPN4="protonvpn4"

WAITFOR="3"
# for debugging, when manually running. Sets the length of pause between actions taken in the script, to give you time to read onscreen msgs.
# 2-5 typically for debugging, 0-1 normally when not.

# include functions:
. /lib/functions/network.sh

# Below is the custom FPING function: (not from /lib/functions/network.sh, but made specifically for this script instead) 
check_fping() {
    # Run the fping command and check if it succeeds
#     if [ "$(fping --alive --interval=400 --count=5 --fast-reachable=1 --addr -4 fakewebsite.fake)" ] ; then
    if [ "$(fping --alive --interval=400 --count=5 --fast-reachable=1 --addr -4 cloudflare.com dns.google msn.com)" ] && [ "$(fping --alive --interval=400 --count=5 --fast-reachable=1 --addr -6 cloudflare.com dns.google msn.com)" ] ; then
        return 0  # Return success
    else
        return 1  # Return failure
    fi
}

########################### start ####################### 
echo -e "\n" # new blank line
echo "Waiting ${BOOTWAIT} seconds..."
sleep $BOOTWAIT # The startup delay must be first, to ensure the time and date recorded in the log is correct.

if [[ "$TESTMODE" == "1" ]] ; then
	echo "Wan-watchdog script startup in testing mode. Waiting ${BOOTWAIT} seconds before checking connectivity."
	echo "BOOTWAIT set to: ${BOOTWAIT}"
	echo "WAITFOR pause length set to: ${WAITFOR}"
	echo "Run once and exit. No log, no loop, and no reboot if total wan failure."
	echo "Increase the BOOTWAIT value for ordinary start-up."
elif [[ "$TESTMODE" == "0" ]] ; then
	echo "Wan-Watchdog script started / Router booted on $(date)"
fi


if [[ "$DOYOULIKECAKE" == "1" && "$VPN" == "1" ]]
	then
	# The next line addresses the automatically-applied fq_codel on the WWAN interface. Since we will be running cake-autorate inside the VPN usually, this should be removed/set to noqueue 
	echo "Cake-autorate selected ON. VPN turned ON. Therefore, removing default fq_codel from basic ${WWANDEVICE}/${WWANNAME} interface.."
	tc qdisc replace dev ${WWANDEVICE} root noqueue
fi

echo -e "\n" # new blank line
echo "Entering wan & vpn testing:"
network_flush_cache
network_find_wan NET_IF_NAME
network_find_wan6 NET6_IF_NAME
# ATTENTION: Look at the following output during testing, to determine if you correctly set WWANDEVICE & WWANNAME, assuming you are connected in a basic way to your default internet connection when you test-run this 
echo "WWANDEVICE device is set to ${WWANDEVICE}"
echo "WANNNAME interface is set to ${WWANNAME}"
echo "NET_IF_NAME reports as ${NET_IF_NAME}" # if NIN is null, then the WAN is not connected (usually during testing where WWANNAME has been manually stopped).
echo "NET6_IF_NAME reports as ${NET6_IF_NAME}" # same as above
# Ordinarily either NIN or N6IN must match WWANNAME, if the router is connected to the internet when you test-run this script, and you have no VPN profiles active.
# If neither NET or NET6 IF match WWANNAME, stop this script and correct the value for $WWANNAME stored at the top.
echo "Sleeping for ${WAITFOR} seconds..."
sleep $WAITFOR
# Connection Status: 0 Not connected-connection attempt failure, exit and reboot.
# Connection Status: 1 Unknown State, try to take corrective action
# Connection Status: 2 WWAN interface connected, fping success
# Connection Status: 3 WWAN & VPN connected, fping success
NEEDREBOOT="0" # Initialize
RELOADCAKE="0" # Initialize
CONNECTIONSTATUS="1" # Initialize
ACTIVEVPN="none" # Initialize the -active and tested- VPN profile, to 'none'.
sleep $WAITFOR

while [[ $CONNECTIONSTATUS -ge 1 ]]
do # While CONNECTION STATUS is 1 or greater, do the following loop:
	echo "Pinging a variety of well-known ipv4 and ipv6 addresses..."
	echo "1 success on ipv4 and 1 success on ipv6, is enough. All of them failing, multiple times, will cause corrective actions."
	# if1
	if check_fping ; then
		echo "Successful fping response. Further probing options - is VPN selected ON/OFF? Cake? Is VPN currently connected? etc"
		echo -e "\n" # new blank line
		# if2
		if [[ "$VPN" -eq "1" ]] ; then # If VPN selector is turned ON, try/test VPN connections 1 through 4.
			echo "VPN Option selector turned-on '1'. Getting current interface connection values..."
			network_flush_cache
			network_find_wan NET_IF_NAME
			network_find_wan NET6_IF_NAME
			echo "Current values for:"
			echo "NET_IF_NAME: ${NET_IF_NAME}"
			echo "NET6_IF_NAME: ${NET6_IF_NAME}"
			echo "WWANNAME interface: ${WWANNAME}"
			echo "WWANDEVICE device: ${WWANDEVICE}"
			echo "Checking if any VPN connections are currently up..."
			sleep $WAITFOR
			# if3
			if [[ "$NET_IF_NAME" == "$VPN1" ]] || [[ "$NET_IF_NAME" == "$VPN2" ]] || [[ "$NET_IF_NAME" == "$VPN3" ]] || [[ "$NET_IF_NAME" == "$VPN4" ]]; then
				echo "ACTIVEVPN is ${NET_IF_NAME}, is reported as up, and fping is successful!"
				echo "Basic WWAN Connection is up, and 1 out of 4 possible VPN profiles/interfaces are connected."
				echo "Setting value of ACTIVEVPN to ${NET_IF_NAME}.."
				ACTIVEVPN=$NET_IF_NAME
				echo "Setting CONNECTIONSTATUS to 3.."
				CONNECTIONSTATUS="3"
				sleep $WAITFOR
				# if4
				if [[ -f /tmp/currentvpn.txt ]] ; then 
					echo "/tmp/currentvpn.txt exists reading value into PREVIOUSVPN.."
					read -r PREVIOUSVPN < /tmp/currentvpn.txt
				else
					echo "/tmp/currentvpn.txt does not exist. Initializing PREVIOUSVPN to 'none'."
					PREVIOUSVPN="none"
				fi # fi4
				echo "Comparing ACTIVEVPN to PREVIOUSVPN:"
				echo "PREVIOUSVPN is: ${PREVIOUSVPN}.."
				# if5
				if [[ "$ACTIVEVPN" == "$PREVIOUSVPN" ]] ; then
					# If ACTIVEVPN matches PREVIOUSVPN in this loop or run, then do nothing and continue
					echo "Current VPN is the same as the previously-connected VPN profile, continuing..."
					VPNCHANGED="0"
					sleep $WAITFOR
				else # if the values do not match, then maybe the VPN has changed from previous, write the currentvpn to 'currentvpn.txt'
					echo "VPN has changed. Previous VPN was ${PREVIOUSVPN}. Current VPN is ${CURRENTVPN}" | tee -a "$log_file"
					echo "Writing changes to currentvpn.txt..."
					VPNCHANGED="1"
					echo "$ACTIVEVPN" > /tmp/currentvpn.txt # write the current vpn value to a file, e.g. to be used by the cake autorate script.
					sleep $WAITFOR
				fi # fi5 Finished sensing and reacting to a match or mismatch between ACTIVEVPN and PREVIOUSVPN
			# if3 elif
			elif [[ "$WWANNAME" == "$NET_IF_NAME" || "$NET6_IF_NAME" ]] ; then # When WWAN interface is up, & VPN selector is turned-on, but no VPN is up yet.
				echo "VPN not up yet; WWAN network interface is up. Trying to get a VPN connection up..." | tee -a "$log_file"
				sleep $WAITFOR
				echo "Trying $VPN1..."
				echo "ifup ${VPN1}"
				ifup $VPN1
				sleep 7 # wait for it to connect
				network_flush_cache
				network_find_wan NET_IF_NAME
				if [[ "$NET_IF_NAME" == "$VPN1" ]] && check_fping ; then
					ACTIVEVPN=$VPN1
					CONNECTIONSTATUS="3"
					echo "${VPN1} is up, and fping success!"
				else
					echo "Unable to connect to ${VPN1}... trying ${VPN2} profile..." | tee -a "$log_file"
					echo "ifdown ${VPN1}"
					ifdown $VPN1
					sleep $WAITFOR
					echo "ifup ${VPN2}"
					ifup $VPN2
					sleep 7
					network_flush_cache
					network_find_wan NET_IF_NAME
					if [[ "$NET_IF_NAME" == "$VPN2" ]] && check_fping ; then
						ACTIVEVPN=$VPN2
						CONNECTIONSTATUS="3"
						echo "${VPN2} is up and fping success!"
					else
						echo "Unable to connect to ${VPN2}, trying ${VPN3} profile..."
						echo "ifdown ${VPN2}"
						ifdown $VPN2
						sleep $WAITFOR
						echo "ifup ${VPN3}"
						ifup $VPN3
						sleep 7
						network_flush_cache
						network_find_wan NET_IF_NAME
						if [[ "$NET_IF_NAME" == "$VPN3" ]] && check_fping ; then
							ACTIVEVPN=$VPN3
							CONNECTIONSTATUS="3"
							echo "${VPN3} is up, and fping success!"
						else 
							echo "Unable to connect to ${VPN3}, trying ${VPN4} profile..."
							echo "ifdown ${VPN3}"
							ifdown $VPN3
							sleep $WAITFOR
							echo "ifup ${VPN4}"
							ifup $VPN4
							sleep 7
							network_flush_cache
							network_find_wan NET_IF_NAME
							if [[ "$NET_IF_NAME" == "$VPN4" ]] && check_fping ; then
								ACTIVEVPN=$VPN4
								CONNECTIONSTATUS="3"
								echo "${VPN4} is up and fping success!"
							else
								echo "Unable to start VPN4, or connect to any VPN profiles on $(date)" | tee -a "$log_file"
							fi # Finished VPN4 connect/all VPNx attempts
						fi # Finished VPN3 connect attempt
					fi # Finished VPN2 connect attempt
				fi # Finished VPN1 connect attempt
			else # something is wrong with the basic configuration of the script / interfaces mismatch
				echo "Whoops. Something went wrong!" | tee -a "$log_file"
				echo "Most likely this scripts VPN/WWAN variables are not matched to your router's interface names." | tee -a "$log_file"
				echo "Check that your script VPN/WWAN values match the actual interfaces. Exiting..." | tee -a "$log_file"
				break
			fi # Finished check if WWAN or any VPN connection is connected, and establishing required VPN connection if not active already.
		# Else if VPN Selector is set to 0 / no VPN, then
		elif [[ $VPN -eq 0 ]] ; then
			echo "VPN=${VPN}. VPN Selector is turned-off."
			echo "Checking to see if the current NET_IF_NAME or NET6_IF_NAME matches WWANNAME:"
			network_flush_cache
			network_find_wan NET_IF_NAME
			network_find_wan6 NET6_IF_NAME
			echo "Current values:"
			echo "NET_IF_NAME: ${NET_IF_NAME}"
			echo "NET6_IF_NAME: ${NET6_IF_NAME}"
			echo "WWANNAME interface: ${WWANNAME}"
			echo "WWANDEVICE device: ${WWANDEVICE}"
			if [[ "$WWANNAME" == "$NET_IF_NAME" || "$WWANNAME" == "$NET6_IF_NAME" ]] ; then
				echo "They do. Do nothing here/continue."
			else
				echo "They do not.."
				echo "Turning off VPN1-4 interfaces (ifdown), in case a VPN was started manually prior to this script run."
				# VPN may have been manually started prior to current script invocation.
				ifdown $VPN1
				ifdown $VPN2
				ifdown $VPN3
				ifdown $VPN4
				VPNCHANGED="1"
			fi			
			echo "No VPN active: Setting 'CONNECTIONSTATUS' = 2"
			CONNECTIONSTATUS="2"
			sleep $WAITFOR
		fi # finished for VPN 1/0 Selector check, establishing VPN connection, determining if active VPN has changed from prior VPN interface.

	else # No connectivity: initial or subsequent fping test, whether through VPN or qmippp selection.
		echo "No WAN or VPN connectivity: Fpings failed."
		if [[ $VPN -eq 1 ]] ; then # If VPN is selected, and basic connectivity is failing,
			echo "VPN Selector is ON, and yet WWAN/VPN is failing at initial fping test." | tee -a "$log_file"
			echo "This would ordinarily be the case, if you forcibly stopped your WWAN prior to running this script, to test." | tee -a "$log_file"
			echo "Script will now attempt to (re)connect WWAN ifdown/ifup..." | tee -a "$log_file"
		elif [[ $VPN -eq 0 ]] ; then
			echo "VPN Selector is turned-off in this script and there is no WAN connectivity." | tee -a "$log_file"
			echo "Script will attempt to (re)connect WWAN ifdown/up..." | tee -a "$log_file"
		fi
		CONNECTIONSTATUS="1" # reset to unknown
		echo "Attempting to fix connectivity..." | tee -a "$log_file"
		echo "Shutting down all VPN interfaces..." | tee -a "$log_file"
		ifdown $VPN1
		ifdown $VPN2
		ifdown $VPN3
		ifdown $VPN4
		ACTIVEVPN="none"
		sleep $WAITFOR
		echo "Attempting to restart ${WWANNAME} WWAN interface on $(date)." | tee -a "$log_file"
		echo "Turning off the ${WWANNAME} WWAN interface in ${WAITFOR} seconds.."
		sleep $WAITFOR
		echo "ifdown ${WWANNAME}"
		ifdown $WWANNAME
		echo "Wait 5 seconds then bringing up the ${WWANNAME} interface.."
		sleep 5 # Mandatory 5 seconds
		echo "ifup ${WWANNAME}"
		ifup $WWANNAME
		echo "Wait 60 seconds to give the modem time to reconnect..."
		sleep 60 # give the modem time to reconnect (takes at least 25 seconds for a typical QMI Quectel config. YMMV)
		if check_fping ; then
			CONNECTIONSTATUS="2"
			echo "SUCCESS: WWAN interface ${WWANNAME} restart worked, no need for reboot." | tee -a "$log_file"
			sleep $WAITFOR
			NEEDREBOOT="0"
		else
			echo "FAILURE: reboot required." | tee -a "$log_file"
			CONNECTIONSTATUS="0"
			NEEDREBOOT="1"
		fi # end of follow-up probe to see if WWAN interface restart worked...
	fi # End of initial fping test


	# Now let's start or restart, as needed, cake-autorate to run:
	# probably should check cake-autorate status and correct if necessary, here
	# Check if cake-autorate is running, and what it is currently using for it's 'ul_if' value:
	echo -e "\n" # new blank line
	echo "CAKECHECK / DOYOULIKECAKE portion of wan-watchdog.sh"
	echo "Detecting interface/SQM/Cake-Autorate and preference status's.."
	echo "CONNECTIONSTATUS is ${CONNECTIONSTATUS}"
	echo "service cake-autorate status:"
	service cake-autorate status
	echo "service sqm status:"
	service sqm status
	echo "VPNCHANGED/RELOADCAKE is ${VPNCHANGED}"
	echo "DOYOULIKECAKE is ${DOYOULIKECAKE}"
	sleep $WAITFOR
	echo -e "\n" # new blank line

	# if the VPN is selected (1), enabled (on) and running (working) (therefore connectionstatus=3), VPN has not changed from prior, and cake-autorate/sqm are already running:
	# The most typical state when the VPN is selected, and script is running in a loop the second, third etc times.
	if [[ "$CONNECTIONSTATUS" == "3" ]] && [[ "$(service cake-autorate status)" == "running" ]] && [[ "$(service sqm status)" == "active with no instances" ]] && [[ "$DOYOULIKECAKE" == "1" ]] && [[ "$VPNCHANGED" == "0" ]] ; then 
		echo "Connection Status is 3 -VPN ON & active-, SQM is running, Cake is running, Cake selector is enabled, VPN has NOT changed: Do nothing."
	# else if all of the above is true but the VPN has changed, and cake-autorate/sqm are already running, restart them:
	elif [[ "$CONNECTIONSTATUS" == "3" ]] && [[ "$(service cake-autorate status)" == "running" ]] && [[ "$(service sqm status)" == "active with no instances" ]] && [[ "$DOYOULIKECAKE" == "1" ]] && [[ "$VPNCHANGED" == "1" ]] ; then
		echo "Connection Status is 3 -VPN ON & Active-, SQM is running, Cake is running, Cake selector is enabled, VPN has changed: restart SQM/Cake-autorate" | tee -a "$log_file"
		echo "Stopping cake-autorate..."
		echo "service cake-autorate stop"
		service cake-autorate stop
		sleep $WAITFOR
		echo "Stopping SQM..."
		echo "service sqm stop"
		service sqm stop
		sleep $WAITFOR
		echo "service sqm start"
		service sqm start
		sleep $WAITFOR
		# Config.primary.sh in /root/cake-autorate/ will pull the current VPN connection /tmp/currentvpn.txt, and operate on that.
		echo "service cake-autorate start"
		service cake-autorate start
		VPNCHANGED="0"
		sleep $WAITFOR
	# else if the VPN has not changed, the VPN is active, but cake-autorate is not yet running (typically due to set to 'disabled' (from autostart) in System, Startup), then start it:
	elif [[ "$CONNECTIONSTATUS" == "3" ]] && [[ "$(service cake-autorate status)" == "not running" || "$(service cake-autorate status)" == "inactive" ]] && [[ "$DOYOULIKECAKE" == "1" ]] ; then
		echo "Cake is NOT running, VPN is ON & active, and cake selector in this script is enabled"
		echo "Stop SQM to verify that SQM is running on the current active VPN interface..."
		echo "service sqm restart"
		service sqm restart
		sleep $WAITFOR
		echo "service cake-autorate start"
		# Config.primary.sh in /root/cake-autorate/ will pull the current VPN connection /tmp/currentvpn.txt, and operate on that.
		service cake-autorate start
		# Initialize VPNCHANGED to 0, because regardless of whether it changed, cake-autorate was not running
		# This can also be the situation during testing sometimes, that VPNCHANGED=1 due to subsequent manual runs of the script.
		VPNCHANGED="0"
		sleep $WAITFOR
	# atypical: if script was halted/killed manually, a VPN was on, and VPN was changed to '0', then script was re-executed:
	elif [[ "$CONNECTIONSTATUS" == "2" ]] && [[ "$(service cake-autorate status)" == "running" ]] && [[ "$(service sqm status)" == "active with no instances" ]] && [[ "$DOYOULIKECAKE" == "1" ]] && [[ "$VPN" == "0" ]] && [[ "$VPNCHANGED" == "1" ]] ; then 
		echo "VPN active, but VPN selected OFF in script. Restarting SQM/Cake-Autorate to set to ${WWANDEVICE} / ${WWANNAME}:"
		echo "Connection Status is 2, SQM is running, Cake is running, Cake selector is enabled, but this script was probably killed, then re-run while there was a (previous) VPN running:"
		echo "Stopping cake-autorate, restart sqm, restart cake-autorate."
		echo "service cake-autorate stop"
		service cake-autorate stop
		echo "Restarting SQM to get SQM running on the current active WWAN interface..."
		echo "service sqm restart"
		service sqm restart
		sleep $WAITFOR
		echo "Writing WWANDEVICE to /tmp/currentvpn.txt for Cake-Autorate config.primary.sh to pick-up active interface"
		echo "${WWANDEVICE}" > /tmp/currentvpn.txt # write the current WWAN device (not interface!) to a file, to be used by the cake autorate script.
		sleep $WAITFOR
		echo "service cake-autorate start"
		# Config.primary.sh in /root/cake-autorate/ will pull the current VPN connection /tmp/currentvpn.txt, and operate on that.
		service cake-autorate start
		# Initialize VPNCHANGED to 0
		VPNCHANGED="0"
		sleep $WAITFOR
	# typical when script running in second, third etc loop and VPN selected OFF
	# else if VPN is selected OFF (0), Connection = 2 (good connection, no vpn), and cake selector is on, and running, do nothing:
	elif [[ "$CONNECTIONSTATUS" == "2" ]] && [[ "$(service cake-autorate status)" == "running" ]] && [[ "$(service sqm status)" == "active with no instances" ]] && [[ "$DOYOULIKECAKE" == "1" ]] && [[ "$VPN" == "0" ]] ; then 
		echo "VPN selected OFF, CAKE/SQM running.. No change in interfaces: Do Nothing."
		echo "Connection Status is 2 -VPN selected off, good basic ${WWANNAME} connection-, SQM is running, Cake is running, Cake selector is enabled: Do nothing."
	# typical on firstboot with VPN off:
	# else if VPN is selected OFF (0), connection = 2 (good connection), and cake selector is ON, but not running:
	elif [[ "$CONNECTIONSTATUS" == "2" ]] && [[ "$(service cake-autorate status)" == "not running" || "$(service cake-autorate status)" == "inactive" ]] && [[ "$DOYOULIKECAKE" == "1" ]] && [[ "$VPN" == "0" ]] ; then 
		echo "Connection status is 2, Cake is NOT running, VPN is turned OFF, and cake selector in this script is enabled"
		echo "Restarting SQM to verify that SQM is running on the current active WWAN interface..."
		echo "service sqm restart"
		service sqm restart
		sleep $WAITFOR
		echo "service cake-autorate start"
		echo "$WWANDEVICE" > /tmp/currentvpn.txt # write the current WWAN device (not interface!) to a file, to be used by the cake autorate script.
		sleep $WAITFOR
		# Config.primary.sh in /root/cake-autorate/ will pull the current VPN connection /tmp/currentvpn.txt, and operate on that.
		service cake-autorate start
		sleep $WAITFOR
	# typical when script has been stopped, CAKE selector has been turned off, and script is re-run		
	# else if cake-autorate is running, but cake selector is set to OFF, then shut down cake-autorate:
	elif [[ "$(service cake-autorate status)" == "running" ]] && [[ "$DOYOULIKECAKE" == "0" ]] ; then
		echo "Cake-autorate is running, but DOYOULIKECAKE is turned OFF (0). Turning off/stopping cake-autorate:"
		echo "service cake-autorate stop"
		service cake-autorate stop
		# This can be the case during manually running the script, or if you decided not to use cake-autorate for now, but forgot to disable it from startup
		# or it had been started previously but you don't want it running rn.
		sleep $WAITFOR
	elif [[ "$(service cake-autorate status)" == "not running" || "$(service cake-autorate status)" == "inactive" ]] && [[ "$DOYOULIKECAKE" == "0" ]] ; then
		echo "Cake-autorate selector DOYOULIKECAKE turned OFF. Cake not running. Do nothing."
		sleep $WAITFOR
	fi # Finished starting Cake-autorate for current connection, if selected, restarting, or terminating as necessary.

echo -e "\n" # new blank line
# Pause LOOPWAIT, or in testing-mode exit:
	if [ "$TESTMODE" == "0" ]
	then # now check to see if you should loop or break
		echo "Pausing ${LOOPWAIT} seconds and testing again..."			
		sleep $LOOPWAIT
	elif [ "$TESTMODE" == "1" ]
	then
		echo "Script in testing mode. BOOTWAIT value of ${BOOTWAIT} too low to loop. Exiting.."
		echo "Test run ended: $(date)" | tee -a "$log_file"
		break
	fi

echo -e "\n" # new blank line
done # When CONNECTION STATUS no longer 1 or greater, or break

if [[ "$TESTMODE" == "0" && $NEEDREBOOT -eq 1 ]]
	then # Test BOOTWAIT value if less/more than 60 to avoid loops.
	echo "Rebooting router in 5 seconds..." | tee -a "$log_file"
	sleep 5
	reboot
elif [[ "TESTMODE" == "1" && $NEEDREBOOT -eq 1 ]]
	then
	echo "Needs reboot, but script in testing mode... no auto-reboot. Exit." | tee -a "$log_file"
fi
```

### Dynamic connection

Preserve default route to restore WAN connectivity when VPN is disconnected.

```
# Preserve default route
uci set network.wan.metric="1024"
uci commit network
service network restart
```

### Dynamic address

Periodically re-resolve inactive peer hostnames for VPN peers with dynamic IP addresses.

```
# Periodically re-resolve inactive peers
cat << "EOF" >> /etc/crontabs/root
* * * * * /usr/bin/wireguard_watchdog
EOF
uci set system.@system[0].cronloglevel="9"
uci commit system
service cron restart
```

### Race conditions

Resolve the [race condition](https://forum.openwrt.org/t/problematic-wireguard-at-the-time/56435 "https://forum.openwrt.org/t/problematic-wireguard-at-the-time/56435") with sysntpd service when RTC is missing.

```
# Resolve race conditions
cat << "EOF" >> /etc/crontabs/root
* * * * * date -s 2030-01-01; service sysntpd restart
EOF
uci set system.@system[0].cronloglevel="9"
uci commit system
service cron restart
```

### Site-to-site

Implement plain routing between server side LAN and client side LAN assuming that:

- `192.168.1.0/24` - server side LAN
- `192.168.2.0/24` - client side LAN

Add route to client side LAN on VPN server.

```
uci set network.wgclient.route_allowed_ips="1"
uci add_list network.wgclient.allowed_ips="192.168.2.0/24"
uci commit network
service network restart
```

Add route to server side LAN on VPN client.

```
uci set network.wgserver.route_allowed_ips="1"
uci add_list network.wgserver.allowed_ips="192.168.1.0/24"
uci commit network
service network restart
```

Consider VPN network as private and assign VPN interface to LAN zone on VPN client.

```
uci del_list firewall.wan.network="vpn"
uci add_list firewall.lan.network="vpn"
uci commit firewall
service firewall restart
```

### IPv6 site-to-site

Provide IPv6 site-to-site connectivity assuming that:

- `fd00:0:0:1::/64` - server side LAN
- `fd00:0:0:2::/64` - client side LAN

Add route to client side LAN on VPN server.

```
uci set network.lan.ip6assign="64"
uci set network.lan.ip6hint="1"
uci set network.vpn.ip6prefix="fd00::/48"
uci add_list network.wgclient.allowed_ips="fd00:0:0:2::/64"
uci commit network
service network restart
```

Add route to server side LAN on VPN client.

```
uci set network.lan.ip6assign="64"
uci set network.lan.ip6hint="2"
uci set network.vpn.ip6prefix="fd00::/48"
uci add_list network.wgserver.allowed_ips="fd00:0:0:1::/64"
uci commit network
service network restart
```

### Default gateway

If you do not need to route all traffic to VPN. Disable gateway redirection on VPN client.

```
uci del_list network.wgserver.allowed_ips="0.0.0.0/0"
uci del_list network.wgserver.allowed_ips="::/0"
uci commit network
service network restart
```

If you want to disable automatic routes for allowed IPs.

```
uci -q delete network.wgserver.route_allowed_ips
uci commit network
service network restart
```

### Split gateway

If VPN gateway is separate from your LAN gateway. Implement plain routing between LAN and VPN networks assuming that:

- `192.168.1.0/24` - LAN network
- `192.168.1.2/24` - VPN gateway
- `192.168.9.0/24` - VPN network

Add port forwarding for VPN server on LAN gateway.

```
uci -q delete firewall.wg
uci set firewall.wg="redirect"
uci set firewall.wg.name="Redirect-WireGuard"
uci set firewall.wg.src="wan"
uci set firewall.wg.src_dport="51820"
uci set firewall.wg.dest="lan"
uci set firewall.wg.dest_ip="192.168.1.2"
uci set firewall.wg.family="ipv4"
uci set firewall.wg.proto="udp"
uci set firewall.wg.target="DNAT"
uci commit firewall
service firewall restart
```

Add route to VPN network via VPN gateway on LAN gateway.

```
uci -q delete network.vpn
uci set network.vpn="route"
uci set network.vpn.interface="lan"
uci set network.vpn.target="192.168.9.0/24"
uci set network.vpn.gateway="192.168.1.2"
uci commit network
service network restart
```

### IPv6 gateway

Set up [IPv6 tunnel broker](/docs/guide-user/network/ipv6/ipv6_henet "docs:guide-user:network:ipv6:ipv6_henet") or use [IPv6 NAT or NPT](/docs/guide-user/firewall/fw3_configurations/fw3_nat#ipv6_nat "docs:guide-user:firewall:fw3_configurations:fw3_nat") if necessary.

Disable [ISP prefix delegation](/docs/guide-user/network/ipv6/ipv6_extras#disabling_gua_prefix "docs:guide-user:network:ipv6:ipv6_extras") to prevent IPv6 leaks on VPN client.

### DNS over VPN

[Serve DNS](/docs/guide-user/base-system/dhcp_configuration#providing_dns_for_non-local_networks "docs:guide-user:base-system:dhcp_configuration") for VPN clients on OpenWrt server when using point-to-point topology.

Route DNS over VPN to prevent DNS leaks on VPN client.

[Replace peer DNS](/docs/guide-user/base-system/dhcp_configuration#upstream_dns_provider "docs:guide-user:base-system:dhcp_configuration") with public or VPN-specific DNS provider on OpenWrt client.

Modify the VPN connection using NetworkManager on Linux desktop client.

```
nmcli connection modify id VPN_CON \
ipv4.dns-search ~. ipv4.dns-priority -50 \
ipv6.dns-search ~. ipv6.dns-priority -50
```

### Kill switch

Prevent traffic leaks on OpenWrt client isolating VPN interface in a separate firewall zone.

```
uci -q delete firewall.vpn
uci set firewall.vpn="zone"
uci set firewall.vpn.name="vpn"
uci set firewall.vpn.input="REJECT"
uci set firewall.vpn.output="ACCEPT"
uci set firewall.vpn.forward="REJECT"
uci set firewall.vpn.masq="1"
uci set firewall.vpn.mtu_fix="1"
uci add_list firewall.vpn.network="vpn"
uci del_list firewall.wan.network="vpn"
uci -q delete firewall.@forwarding[0]
uci set firewall.lan_vpn="forwarding"
uci set firewall.lan_vpn.src="lan"
uci set firewall.lan_vpn.dest="vpn"
uci commit firewall
service firewall restart
```

### Multi-client

Set up multi-client VPN server. Generate client keys and profiles. Configure VPN peers.

```
# Configuration parameters
VPN_IDS="wgserver wgclient wglaptop wgmobile"
VPN_PKI="."
VPN_IF="vpn"
VPN_PORT="$(uci -q get network.${VPN_IF}.listen_port)"
read -r VPN_ADDR VPN_ADDR6 \
< <(uci -q get network.${VPN_IF}.addresses)
 
# Fetch server address
NET_FQDN="$(uci -q get ddns.@service[0].lookup_host)"
. /lib/functions/network.sh
network_flush_cache
network_find_wan NET_IF
network_get_ipaddr NET_ADDR "${NET_IF}"
if [ -n "${NET_FQDN}" ]
then VPN_SERV="${NET_FQDN}"
else VPN_SERV="${NET_ADDR}"
fi
 
# Generate client keys
umask go=
mkdir -p ${VPN_PKI}
for VPN_ID in ${VPN_IDS#* }
do
wg genkey \
| tee ${VPN_PKI}/${VPN_ID}.key \
| wg pubkey > ${VPN_PKI}/${VPN_ID}.pub
wg genpsk > ${VPN_PKI}/${VPN_ID}.psk
done
 
# Generate client profiles
VPN_SFX="1"
for VPN_ID in ${VPN_IDS#* }
do
let VPN_SFX++
cat << EOF > ${VPN_PKI}/${VPN_ID}.conf
[Interface]
PrivateKey = $(cat ${VPN_PKI}/${VPN_ID}.key)
Address = ${VPN_ADDR%.*}.${VPN_SFX}/24
Address = ${VPN_ADDR6%:*}:${VPN_SFX}/64
DNS = ${VPN_ADDR%/*}
DNS = ${VPN_ADDR6%/*}
[Peer]
PublicKey = $(cat ${VPN_PKI}/${VPN_IDS%% *}.pub)
PresharedKey = $(cat ${VPN_PKI}/${VPN_ID}.psk)
PersistentKeepalive = 25
Endpoint = ${VPN_SERV}:${VPN_PORT}
AllowedIPs = 0.0.0.0/0
AllowedIPs = ::/0
EOF
done
ls ${VPN_PKI}/*.conf
 
# Back up client profiles
cat << EOF >> /etc/sysupgrade.conf
$(pwd ${VPN_PKI})
EOF
 
# Add VPN peers
VPN_SFX="1"
for VPN_ID in ${VPN_IDS#* }
do
let VPN_SFX++
uci -q delete network.${VPN_ID}
uci set network.${VPN_ID}="wireguard_${VPN_IF}"
uci set network.${VPN_ID}.description="${VPN_ID}"
uci set network.${VPN_ID}.private_key="$(cat ${VPN_PKI}/${VPN_ID}.key)"
uci set network.${VPN_ID}.public_key="$(cat ${VPN_PKI}/${VPN_ID}.pub)"
uci set network.${VPN_ID}.preshared_key="$(cat ${VPN_PKI}/${VPN_ID}.psk)"
uci add_list network.${VPN_ID}.allowed_ips="${VPN_ADDR%.*}.${VPN_SFX}/32"
uci add_list network.${VPN_ID}.allowed_ips="${VPN_ADDR6%:*}:${VPN_SFX}/128"
done
uci commit network
service network restart
```

Perform OpenWrt [backup](/docs/guide-user/troubleshooting/backup_restore "docs:guide-user:troubleshooting:backup_restore"). Extract client profiles from the archive and import them to your clients.

### Automated

Automated VPN server installation and client profiles generation.

```
URL="https://openwrt.org/_export/code/docs/guide-user/services/vpn/wireguard/server"
cat << EOF > wireguard-server.sh
$(wget -U "" -O - "${URL}?codeblock=0")
$(wget -U "" -O - "${URL}?codeblock=1")
$(wget -U "" -O - "${URL}?codeblock=2")
$(wget -U "" -O - "${URL}?codeblock=3")
$(wget -U "" -O - "${URL}/../extras?codeblock=15")
EOF
sh wireguard-server.sh
```
