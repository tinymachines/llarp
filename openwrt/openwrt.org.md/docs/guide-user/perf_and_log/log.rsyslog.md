# rsyslog

The [rsyslog](https://www.rsyslog.com/ "https://www.rsyslog.com/") is a [Syslog](https://en.wikipedia.org/wiki/Syslog "https://en.wikipedia.org/wiki/Syslog") logging daemon.

#### Install

```
opkg install rsyslog
```

#### Route all or specific logs to a (central) rsyslog receiver

With the config file: /etc/rsyslog.conf

```
*.info;mail.none;authpriv.none;cron.none;kern.none  /var/log/messages
..
kern.*					  @192.168.1.119:514
```

If you add to the rsyslog receiver's /etc/rsyslog.conf e.g. this template:

```
$template DynamicFile,"/mnt/sda1/logs/%HOSTNAME%/forwarded-logs.log"
*.* -?DynamicFile
```

you get the messages separated from every sender in a own folder.

### rsyslog and Logz.io

You can support logging direct to a cloud ELK provider like Logz.io by adding a few lines to your `rsyslog.conf`.

Replace `codecodecode` with your unique Logz.io identifier, it's 32 characters. And will appear in help manuals when you're logged in, reference the guide [here](https://app.logz.io/#/dashboard/data-sources/rsyslog "https://app.logz.io/#/dashboard/data-sources/rsyslog").

```
$template logzFormatFileTagName,"[codecodecodecode] <%pri%>%protocol-version% %timestamp:::date-rfc3339% %HOSTNAME% %app-name% %procid% %msgid% [type=TYPE] %msg%\n"
*.* @@listener.logz.io:5000;logzFormatFileTagName
```

Confirm you have the right config with:

```
rsyslogd -N1
```
