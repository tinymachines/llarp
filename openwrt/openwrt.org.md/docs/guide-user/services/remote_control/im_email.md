# Remote control OpenWrt device via instant messengers (Telegram, XMPP) and EMail

A device can send notifications and receive commands directly to you.

## EMail

To send an email see [SMTP clients](/docs/guide-user/services/email/smtp.client "docs:guide-user:services:email:smtp.client"). Receiving email can be done with `postfix` or [E-MailRelay](/docs/guide-user/services/email/emailrelay "docs:guide-user:services:email:emailrelay") and custom scripts. But email server is problematic to set up on a router because of many limitations: it needs for a static IP, ISP often blocks the SMTP port, spam and DDoS problems.

## Telegram

This is the most used option. The Telegram has an [advanced Bots API](https://core.telegram.org/bots "https://core.telegram.org/bots") with easy access via simple HTTP API with a long pooling.

The [alexwbaule/telegramopenwrt](https://github.com/alexwbaule/telegramopenwrt "https://github.com/alexwbaule/telegramopenwrt") is a TG bot based on the `curl` and supports many commands:

- cam\_movie: Record 25 seconds of a camIP and send it.
- cam\_mv: Move the camera around.
- cam\_shot: Get a Pic from the camera.
- cam\_vdo: Get a 25 seconds record from a camIP.
- chromego\_add: Include to a user in chromego, a word to be used in permissions (block url/YouTube channel/etc).
- chromego\_del: Remove a word from a user in chromego to be used in permissions (block url/YouTube channel/etc).
- chromego\_list: List all permissions in chromego (block url/YouTube channel/etc).
- fw\_add: Block a hostname using a deny rule in firewall, if append time to command will block from 23:00 to 8:00
- fw\_delete: Remove a hostname from a deny firewall rule, if hostname is empty, will remove all rules created by this bot.
- fw\_disable: Disable a firewall rule.
- fw\_enable: Enable a firewall rule.
- fw\_list: List all fw rules.
- fwr\_disable: Disable a redirect firewall rule.
- fwr\_enable: Enable a redirect firewall rule.
- fwr\_list: List all redirect fw rules.
- fw\_unblock: Remove a hostname from a deny firewall rule, if hostname is empty, will remove all rules created by this bot.
- get\_ip: Get WAN IPAddress.
- get\_mac: Get the Organization that own the MacAddr.
- get\_ping: Ping an address or host, return Up or Down.
- get\_uptime: Return the uptime from this Device.
- hst\_list: Get hosts in the dhcp Leases. If a hostname is present, search only for this hostname.
- ignoredmac\_add: Add a new macaddress to the allowlist and avoid being notified about it.
- ignoredmac\_list: Shows the list of ignored mac addresses that will not be notified by the bot.
- interface\_down: Shutdown an interface by name.
- interface\_restart: Restart an interface by name.
- interfaces\_list: Get interfaces configuration.
- interface\_up: Start up an interface by name.
- lights: Turn On or Off house Lights.
- msg\_tv: Send Message to Samsung TV
- netstat: Prints netstat table in ESTABLISHED, CLOSED and TIME\_WAIT State.
- opkg\_install: Install a package from opkg.
- opkg\_update: Update list of packages available.
- ping\_udp: Create a UDP packet to puncture a hole through a NAT firewall of your ISP
- proc\_list: List all process in execution
- proc\_restart: Restart a process in init.d
- proc\_start: Start a process in init.d
- proc\_stop: Stop a process in init.d
- proxy\_disable: Disable HTTP and HTTPS or HTTP or HTTPS proxy.
- proxy\_enable: Enable HTTP and HTTPS or HTTP or HTTPS proxy.
- proxy\_list: List proxy rules that is enabled.
- reboot: Reboot the router.
- start: This menu help!
- swports\_list: Switch ports list with states.
- wifi\_disable: Disable a wireless device radio.
- wifi\_enable: Enable a wireless device radio.
- wifi\_list: List all wireless devices.
- wifi\_restart: Restart a wireless device radio.
- wll\_list: Get a Wi-Fi clients list that is connected to this device

## XMPP

The XMPP (Jabber) is badly supported but used. You can install the [Prosody XMPP server](/docs/guide-user/services/xmpp.server "docs:guide-user:services:xmpp.server") and use it as client too with a little Lua scripting. The [sendxmpp](https://sendxmpp.hostname.sk/ "https://sendxmpp.hostname.sk/") is a perl-script to send xmpp, similar to what sendmail does for email. To send and receive messages over HTTP API with `wget` or `curl` you may install REST API plugin on the XMPP server ([mod\_http\_rest](https://modules.prosody.im/mod_http_rest "https://modules.prosody.im/mod_http_rest") for Prosody). The [XEP-0124 BOSH](https://xmpp.org/extensions/xep-0124.html "https://xmpp.org/extensions/xep-0124.html") probably can be used.

- [xmppcd](https://github.com/stanson-ch/xmppcd "https://github.com/stanson-ch/xmppcd") Small XMPP client daemon
- [Reddit: Send a xmpp message from router](https://www.reddit.com/r/openwrt/comments/11auq9n/send_a_xmpp_message_from_router/ "https://www.reddit.com/r/openwrt/comments/11auq9n/send_a_xmpp_message_from_router/")

## UnifiedPush

[UnifiedPush](https://unifiedpush.org/ "https://unifiedpush.org/") is an open specification and tools that lets the user choose how push notifications are delivered. Different apps supports it:

- [ntfy.sh](https://docs.ntfy.sh/ "https://docs.ntfy.sh/") (pronounced “notify”) is an HTTP-based publish-subscriber notification service. It allows you to send notifications to your phone or desktop via scripts from any computer, and/or using a REST API. It has apps for Android and iOS.
- The same but I want to use Google for some reason: [gCompat-UP Distrib (Android)](https://unifiedpush.org/users/distributors/fcm/ "https://unifiedpush.org/users/distributors/fcm/")
- I have a Nextcloud server: [NextPush (Android)](https://unifiedpush.org/users/distributors/nextpush/ "https://unifiedpush.org/users/distributors/nextpush/")
- I use Conversations XMPP client: [Conversations (Android)](https://unifiedpush.org/users/distributors/conversations/ "https://unifiedpush.org/users/distributors/conversations/")

### Send push notification via ntfy.sh

Example of a script to send a notification via the [ntfy.sh](https://docs.ntfy.sh/ "https://docs.ntfy.sh/") into the [example](https://ntfy.sh/example "https://ntfy.sh/example") queue (you should create your own private queue):

```
NTFY_QUEUE="example"
NEW_CLIENT_IP="192.168.1.42"
MSG="Someone joined network
 
A new client with IP $NEW_CLIENT_IP joined.
Please check if it's not an intruder."
 
wget -q -O - "ntfy.sh/$NTFY_QUEUE" \
  --header "Priority: urgent" \
  --header "Tags: ghost" \
  --header "Click: http://192.168.1.1/" \
  --header "Actions: http, Open Luci, https://192.168.1.1/cgi-bin/ntfy-action.cgi?block=$NEW_CLIENT_IP, clear=true" \
  --header "Email: root@OpenWrt" \
  --post-data="$MSG"
```

**NOTE:** the `--header` option was added to the `uclient-fetch` on Jul 2024 so if you wish to use extended properties you'll need to install the `wget-ssl` package.

### See also

[WebDAV Push](https://github.com/bitfireAT/webdav-push/ "https://github.com/bitfireAT/webdav-push/")
