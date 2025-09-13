# E-MailRelay

E-MailRelay is an e-mail store-and-forward message transfer agent and proxy server. E-MailRelay does three things: it stores any incoming e-mail messages that it receives, it forwards e-mail messages on to another remote e-mail server, and it serves up stored e-mail messages to local e-mail reader programs. More technically, it acts as a SMTP storage daemon, a SMTP forwarding agent, and a POP3 server.

E-MailRelay does not do routing of individual messages; it is not a routing MTA. It forwards all e-mail messages to a pre-configured SMTP server, regardless of any message addressing or DNS redirects.

Package [emailrelay](https://openwrt.org/packages/pkgdata/emailrelay "https://openwrt.org/packages/pkgdata/emailrelay") takes up to 1.4mb space and installs following files:

```
/usr/bin/emailrelay
/usr/bin/emailrelay-filter-copy
/usr/bin/emailrelay-passwd
/usr/bin/emailrelay-submit
/etc/config/emailrelay
/etc/emailrelay.auth
```

Its uci configuration is located in `/etc/config/emailrelay`. The config starts *emailrelay* command with options that are described in [manual](https://emailrelay.sourceforge.net/ "https://emailrelay.sourceforge.net/"). You can also use plain config file `/etc/emailrelay.conf`. See full sample [emailrelay.conf](https://sourceforge.net/p/emailrelay/code/HEAD/tree/trunk/etc/emailrelay.conf.in "https://sourceforge.net/p/emailrelay/code/HEAD/tree/trunk/etc/emailrelay.conf.in").

## Sections

The default emailrelay config file contains *server*, *proxy* and *cmdline* sections.

The possible options are listed in the table below.

Name Type Required Default Description `enabled` boolean yes *0* Listen SMTP `mode` string yes *server*, *proxy*, *client* or *cmdline* Mode: *--as-server* or *--as-proxy*. The *cmdline* means append *extra\_cmdline* `smarthost` string yes *(none)* For *proxy* mode specify the SMTP to forward emails. The option for *--as-proxy &lt;host:port&gt;* `port` integer yes *25* Port to listen incoming emails. `remote_clients` boolean yes *0* To allow connections from anywhere. By default only local allowed. Check your firewall to avoid spam. See *--remote-clients* `dnsbl` list no *(none)* List of DNSBL servers that are used to reject SMTP connections from blocked addresses. See *--dnsbl* `address_verifier` string no *(none)* Runs the specified external program to verify a message recipient's e-mail address. See *--address-verifier* `domain` string no *(none)* Specifies the network name that is used in SMTP `EHLO`. The default is derived from a DNS lookup of the local hostname. See *--domain* `anonymous` boolean no *0* Disables the server's SMTP VRFY command. See *--anonymous* `server_tls` boolean no *0* For *server* and *proxy* mode. See *--server-tls* Doesn't work in v2.1, see [fix](https://github.com/openwrt/packages/pull/18536 "https://github.com/openwrt/packages/pull/18536") `server_tls_required` boolean no *0* Makes the TLS mandatory for incoming SMTP and POP connections. See *--server-tls-required* `server_tls_key` string no *(none)* Path to private key PEM file. See *--server-tls-certificate* `server_tls_certificate` string no *(none)* Path to certificate PEM file. See *--server-tls-certificate* `server_tls_verify` string no *(none)* Path to trusted CAs. Verify remote SMTP and POP clients certificates against the trusted CA certificates. See *--server-tls-verify* `server_auth` string no *(none)* For *server* and *proxy* mode. See *--server-auth* and /etc/emailrelay.auth `filter` list no *(none)* Filter program whenever a mail message is stored. See *--filter* `client_tls` boolean no *0* For *proxy* mode. See *--client-tls* `client_tls_required` boolean no *0* Makes the use of TLS mandatory for outgoing SMTP connections. The SMTP `STARTTLS` command will be used before mail messages are sent out. See *--client-tls-required* `client_tls_key` string no *(none)* Path to TLS private key PEM file when acting as a SMTP client. See *--client-tls-certificate* `client_tls_certificate` string no *(none)* Path to TLS certificate file when acting as a SMTP client. See *--client-tls-certificate* `client_tls_verify` string no *(none)* Enables verification of the remote SMTP server's certificate against any of the trusted CA certificates in the specified file or directory. See *--client-tls-verify* `client_auth` string no *(none)* For *proxy* mode. See *--client-auth* and `/etc/emailrelay.auth` `smtp_client_interface` list no *(none)* The IP network address to be used to bind the local end of outgoing SMTP connections. See *--client-interface* `client_filter` list no *(none)* Filter program whenever a mail message is forwarded. See *--client-filter* `pop` boolean no *0* Enable POP server. See *--pop* `pop_port` integer no *110* Port for incoming POP connections. See *--pop-port* `pop_auth` string no *(none)* A file containing POP account details. See *--pop-auth* and `/etc/emailrelay.auth` `pop_by_name` boolean no *0* Makes spool directory to be the sub-directory with the same name as the user-id used for POP authentication. See *--pop-by-name* `pop_server_interface` list no *(none)* The IP network address to for POP connections. See *--interface* `spool_dir` string no */var/spool/emailrelay* The directory used for holding mail messages that have been received but not yet forwarded. See *--spool-dir* `delivery_dir` string no */var/spool/emailrelay/in* The base directory for mailboxes when delivering messages that have local recipients. See *--delivery-dir* `extra_cmdline` string no *(none)* Extra command line options. See [https://emailrelay.sourceforge.net/#reference\_md\_Reference](https://emailrelay.sourceforge.net/#reference_md_Reference "https://emailrelay.sourceforge.net/#reference_md_Reference") for command line reference

### Server

A minimal `server` declaration:

```
config emailrelay 'server'
        option enabled '0'
        option mode 'server'
        option port '25'
        option remote_clients '0'
```

### Proxy

A minimal `proxy` declaration:

```
config emailrelay 'proxy'
        option enabled '0'
        option mode 'proxy'
        option smarthost '192.0.2.1:25'
        option port '25'
        option remote_clients '0'
```

### Plain commands

A minimal `cmdline` declaration:

```
config emailrelay 'cmdline'
        option enabled '0'
        option mode 'cmdline'
        # specify all arguments that should be passed to emailrelay here
        # see https://emailrelay.sourceforge.net/#reference_md_Reference for command line reference
        option extra_cmdline '--some-other --cmdline-options'
```

## Useful options

### Configure TLS

[Obtain a TLS cert](/docs/guide-user/services/tls/certs "docs:guide-user:services:tls:certs") Then configure `server_tls` option and put private key and then after a comma a fullchain.

### Mail storage location

By default mails are stored into `/var/spool/emailrelay`. On the OpenWrt the entire `/var/` directory is tmpfs stored in RAM memory and will be lost on a router reboot. So you need to change it to store them into some USB disk. To do this you have to create a folder e.g. `/mnt/usb_disk/spool/` and configure emailrelay to use it by setting:

```
option extra_cmdline '--spool-dir /mnt/usb_disk/spool/' 
```

In next versions of the emailrelay package you'll have a separate UCI option `spool_dir`

Also if you are using the “POP by name” option then you need to create a subfolders for each account

### Reading email with POP

If you are using email client (MUA) like Thunderbird, Outlook then you can fetch received mails by enabling POP protocol.

`option extra_cmdline '--pop --pop-auth=/etc/pop.auth`'. Also you must allow an access so set `option remote_clients='1`'. Then you must create the `/etc/pop.auth` file as described in [https://emailrelay.sourceforge.net/index.html#userguide\_md\_Running\_as\_a\_POP\_server](https://emailrelay.sourceforge.net/index.html#userguide_md_Running_as_a_POP_server "https://emailrelay.sourceforge.net/index.html#userguide_md_Running_as_a_POP_server"). Please note that if you are going to read emails from internet then you have to configure TLS for security. See below how to open a port for internet.

## Open ports for internet in Firewall

This is a very bad idea for security and don't do this unless you know what are you doing. Add to `/etc/config/firewall`:

```
config rule
        option name 'Allow-WAN-SMTP'
        option target 'ACCEPT'
        option src 'wan'
        option proto 'tcp'
        option dest_port '25'
config rule
        option name 'Allow-WAN-SMTP-Submission'
        option target 'ACCEPT'
        option src 'wan'
        option proto 'tcp'
        option dest_port '587'  
config rule
        option name 'Allow-WAN-POP'
        option target 'ACCEPT'
        option src 'wan'
        option proto 'tcp'
        option dest_port '110'
```

You can add these rules with command line:

```
uci add firewall rule
uci set firewall.wan_https_turris_rule=rule
uci set firewall.wan_https_turris_rule.name='Allow-WAN-SMTP'
uci set firewall.wan_https_turris_rule.src='wan'
uci set firewall.wan_https_turris_rule.proto='tcp'
uci set firewall.wan_https_turris_rule.dest_port='25'
uci set firewall.wan_https_turris_rule.target='ACCEPT'

uci add firewall rule
uci set firewall.wan_https_turris_rule=rule
uci set firewall.wan_https_turris_rule.name='Allow-WAN-SMTP-Submission'
uci set firewall.wan_https_turris_rule.src='wan'
uci set firewall.wan_https_turris_rule.proto='tcp'
uci set firewall.wan_https_turris_rule.dest_port='587'
uci set firewall.wan_https_turris_rule.target='ACCEPT'


uci add firewall rule
uci set firewall.wan_https_turris_rule=rule
uci set firewall.wan_https_turris_rule.name='Allow-WAN-POP'
uci set firewall.wan_https_turris_rule.src='wan'
uci set firewall.wan_https_turris_rule.proto='tcp'
uci set firewall.wan_https_turris_rule.dest_port='110'
uci set firewall.wan_https_turris_rule.target='ACCEPT'

uci commit firewall
service firewall restart
```
