# SMTP clients

This page lists SMTP and SMTPS clients available on OpenWRT, that are able to send email to other email servers.

## Overview

The table shows all clients ported to OpenWrt:

Name Version Dependencies Size Features [BusyBox](/docs/techref/busybox "docs:techref:busybox") sendmail 1.33 *must be compiled* *libopenssl* 14KB SSL, smarthost only, sendmail-compatible, SMTP auth [msmtp](/packages/pkgdata/msmtp "packages:pkgdata:msmtp") 1.8 *libgnutls* 51KB SSL, smarthost only, sendmail-compatible, SMTP auth [msmtp-nossl](/packages/pkgdata/msmtp-nossl "packages:pkgdata:msmtp-nossl") 1.8 47KB smarthost only, sendmail-compatible, SMTP auth [mailsend](/packages/pkgdata/mailsend "packages:pkgdata:mailsend") 1.19 *libopenssl* 39KB SSL, smarthost only, no configuration required, MIME, attachements, IPv6, SMTP auth [mailsend-nossl](/packages/pkgdata/mailsend-nossl "packages:pkgdata:mailsend-nossl") 1.19 37KB smarthost only, no configuration required, MIME, attachements, IPv6, SMTP auth [ssmtp](/packages/pkgdata_owrt18_6/ssmtp "packages:pkgdata_owrt18_6:ssmtp") 2.64 *libopenssl* 11KB SSL support, smarthost only, SMTP auth. No longer available since OpenWRT 21 mini-sendmail *no package* 5KB smarthost only, no configuration required. No longer available since OpenWRT 17 [emailrelay](/packages/pkgdata/emailrelay "packages:pkgdata:emailrelay") 2.3 *libc* *libssp* *libopenssl* *libstdcpp* 350KB SMTP proxy and store-and-forward message transfer agent (MTA); can be used similar to postfix with mail queue in combination with msmtp and mutt. In v2.5 can deliver mail directly. See [emailrelay](/docs/guide-user/services/email/emailrelay "docs:guide-user:services:email:emailrelay") [XMail](/docs/guide-user/services/email/xmail "docs:guide-user:services:email:xmail") *no package* *libopenssl*

“smarthost only” means that the program is only capable to send email through a configured “smarthost”, that is, it cannot directly deliver to the destination SMTP server. E.g. it won't make a DNS lookup of the email address for MX record.

## Using msmtp

### Description

msmtp is an SMTP client. In the default mode, it transmits a mail to an SMTP server (for example at a free mail provider) which does the delivery. To use this program with your mail user agent (MUA), create a configuration file with your mail accounts and tell your MUA to call msmtp instead of /usr/sbin/sendmail.

Since msmtp understands standard sendmail options, it can be used in places where sendmail is expected (e.g. PHP code).

- [Official site](https://marlam.de/msmtp/ "https://marlam.de/msmtp/") - Sources and documentation
- [Arch Wiki](https://wiki.archlinux.org/title/Msmtp "https://wiki.archlinux.org/title/Msmtp")

### Installation

```
opkg install msmtp-mta
```

Installing `msmtp-mta` package will also create necessary `sendmail` symlink. If you do not need `sendmail` command (unlikely) then install only `msmtp` package.

### Configuration

For router configuration, you very likely do not want to receive emails to local mailboxes. Define aliases file `/etc/aliases.msmtp` to send all local mails to your admin email:

[/etc/aliases.msmtp](/_export/code/docs/guide-user/services/email/smtp.client?codeblock=1 "Download Snippet")

```
default: admin@example.com
```

Place your configuration in `/etc/msmtprc`. There is an existing `default` block in the included config file so if you want to call `msmtp` without specifying an account, then you need to rename the existing `default` block to something else.

Here is an example configuration using Gmail that works with 2FA and an app password:

[/etc/msmtprc](/_export/code/docs/guide-user/services/email/smtp.client?codeblock=2 "Download Snippet")

```
# A system wide configuration file.
# It defines a default account.
# This allows msmtp to be used like /usr/sbin/sendmail.
 
# Set default values.
defaults
aliases /etc/aliases.msmtp
syslog LOG_MAIL
 
# Gmail configuration that works with 2FA and an app password.
# Use TLS on port 465. On this port, TLS starts without STARTTLS.
account gmail
host smtp.gmail.com
port 465
auth on
tls on
tls_starttls off
from_full_name Apartment Router
from home.lab@gmail.com
user home.lab@gmail.com
password abcd efgh ijkl mnop
 
# Select the default account
account default : gmail
```

Now symlink `msmtp` to `sendmail` with `ln -s /usr/bin/msmtp /usr/sbin/sendmail` - this is not necessary if `msmtp-mta` was installed instead of `msmtp`.

Also you may configure env variables `EMAIL` for From address and `SMTPSERVER` to specify smarthost.

### Sending mail

```
echo -e "Subject: Test mail\n\nThis is a test \"message\"." | sendmail abcd
echo -e "Subject: Test mail\n\nThis is a test \"message\"." | sendmail -f "<something@your-domain.tld>" "<recipient@destination.tld>"
```

Note that the *sendmail* command (`/usr/sbin/sendmail`) is a symlink to `/usr/bin/msmtp`.

Use `logread` to check for the following log entry:

```
Mon Oct 14 23:35:55 2024 mail.info msmtp: host=smtp.gmail.com tls=on auth=on user=******@gmail.com from=******@gmail.com recipients=admin@example.com mailsize=181 smtpstatus=250 smtpmsg='250 2.0.0 OK  1728948955 b640f23e62c3d-c9d29717ba4su6358366z.33 - gsmtp' exitcode=EX_OK
```

## Using ssmtp

### Description

A secure, effective and simple way of getting mail off a system to your mail hub. It contains no suid-binaries or other dangerous things - no mail spool to poke around in, and no daemons running in the background. mail is simply forwarded to the configured mailhost. Extremely easy configuration.

[Official site](https://tracker.debian.org/pkg/ssmtp "https://tracker.debian.org/pkg/ssmtp")

### Installation

```
opkg install ssmtp
```

### Usage

ssmtp expects its two configuration files named `/etc/ssmtp/revaliases` and `/etc/ssmtp/ssmtp.conf`. Both are self-explaining:

[/etc/ssmtp/ssmtp.conf](/_export/code/docs/guide-user/services/email/smtp.client?codeblock=6 "Download Snippet")

```
root=arnold@gmx.net
mailhub=mail.gmx.net:465
rewriteDomain=gmx.net
hostname=gmx.net
FromLineOverride=YES
UseTLS=YES
#UseSTARTTLS=YES
```

[/etc/ssmtp/revaliases](/_export/code/docs/guide-user/services/email/smtp.client?codeblock=7 "Download Snippet")

```
# Format: local_account:outgoing_address:mailhub
root:arnold@gmx.net:mail.gmx.net:465
```

To use the program, with SMTP auth:

```
cat /etc/banner | ssmtp -vvv -auultranerd@universum.tb -ap123password456 someguy@gmx.net
```

## Using BusyBox sendmail

### Description

The BusyBox sendmail is a smallest possible implementation but it must be compiled. It works only in smarthost mode. TLS is not supported but can be used with `openssl s_client`.

- [Documentation](https://busybox.net/downloads/BusyBox.html#sendmail "https://busybox.net/downloads/BusyBox.html#sendmail")
- [Sources](https://git.busybox.net/busybox/tree/mailutils/sendmail.c "https://git.busybox.net/busybox/tree/mailutils/sendmail.c")

### Installation

Enable the applet during compilation in menuconfig: `BusyBox options`, `Mail` and `sendmail`. Additionally you may want to enable [makemime](https://busybox.net/downloads/BusyBox.html#makemime "https://busybox.net/downloads/BusyBox.html#makemime") applet that helps to send files with attachments.

### Usage

You need to configure `SMTPHOST` env variable with the smarthost SMTP server to use. Instead of the variable you may use an option `-S server[:port]` to specify the SMTP server.

You may also need `SMTP_ANTISPAM_DELAY` env to bypass the [Greylisting antispam](https://en.wikipedia.org/wiki/Greylisting_%28email%29 "https://en.wikipedia.org/wiki/Greylisting_(email)") if it enabled for submission.

Usage:

```
sendmail [-tv] [-f SENDER] [-amLOGIN 4<user_pass.txt | -auUSER -apPASS]
		[-w SECS] [-H 'PROG ARGS' | -S HOST] [RECIPIENT_EMAIL]...

Read email from stdin and send it
Standard options:
	-t		Read additional recipients from message body
	-f SENDER	For use in MAIL FROM:<sender>. Can be empty string
			Default: -auUSER, or username of current UID
	-o OPTIONS	Various options. -oi implied, others are ignored
	-i		-oi synonym, implied and ignored

Busybox specific options:
	-v		Verbose
	-w SECS		Network timeout
	-H 'PROG ARGS'	Run connection helper. Examples:
		openssl s_client -quiet -tls1 -starttls smtp -connect smtp.gmail.com:25
		openssl s_client -quiet -tls1 -connect smtp.gmail.com:465
			$SMTP_ANTISPAM_DELAY: seconds to wait after helper connect
	-S HOST[:PORT]	Server (default $SMTPHOST or 127.0.0.1)
	-amLOGIN	Log in using AUTH LOGIN
	-amPLAIN	or AUTH PLAIN
			(-amCRAM-MD5 not supported)
	-auUSER		Username for AUTH
	-apPASS 	Password for AUTH

If no -a options are given, authentication is not done.
If -amLOGIN is given but no -au/-ap, user/password is read from fd #4.
Other options are silently ignored; -oi is implied.
Use makemime to create emails with attachments.
```

## Using mailsend

### Description

Mailsend is a simple command line program to send mail via SMTP protocol.

Being quite lightweight and not requiring any configuration, `mailsend` is ideal for sending mails in shell scripts.

[https://github.com/muquit/mailsend](https://github.com/muquit/mailsend "https://github.com/muquit/mailsend") - Sources and issues

### Installation

Depending on whether you want SSL support or not (actually, the size of libopenssl will probably be the decisive factor), install one of the two versions:

```
opkg install mailsend
opkg install mailsend-nossl
```

### Usage

Simple usage:

```
mailsend -f root@openwrt -t foo@example.com -smtp smtp.example.com -sub "My subject" -msg-body /tmp/body
```

For advanced usage (MIME attachments, authentication, BCC, etc), see:

```
mailsend -h
mailsend -example
```

## Using mini-sendmail

### Description

mini\_sendmail reads its standard input up to an end-of-file and sends a copy of the message found there to all of the addresses listed. The message is sent by connecting to a local SMTP server. This means `mini_sendmail` can be used to send email from inside a chroot(2) area.

[Official site](https://acme.com/software/mini_sendmail/ "https://acme.com/software/mini_sendmail/")

### Installation and Configuration

```
opkg install mini-sendmail
```

On Chaos Calmer, the package is no longer available, but the version from Barrier Breaker still works (AA &amp; BB versions as installed below work in AA):

```
opkg install http://downloads.openwrt.org/barrier_breaker/14.07/ar71xx/generic/packages/oldpackages/mini-sendmail_1.3.6-4_ar71xx.ipk
```

### Example

```
mini_sendmail -ssmtp.mail.yahoo.com -p465 -t foo@example.com < input_file
 
usage: mini_sendmail [-f<name>] [-t] [-s<server>] [-p<port>] [-T<timeout>] [-v] [address ...]
```

Note that there must not be a space between the option and the value; e.g. “-p 465” is incorrect.

Several sample configurations found on the internet failed, but as of 160413, this worked

```
echo -e 'From: valid@email.com\r\nSubject: Test Subject\r\n\r\nTesting\r\n.' | mini_sendmail -fvalid@email.com -smail.brighthouse.com toAddr@gmail.com
```

smtp.gmail.com failed; omitting -f failed; omitting “From: ” resulted in transmission, but no sender shown.

This is a very small package if you can find an smtp server which works and you can configure the command so that the server accepts it.
