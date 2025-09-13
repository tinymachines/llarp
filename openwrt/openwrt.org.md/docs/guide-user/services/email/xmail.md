# XMail mail server

The XMail package was available only up to 14.07. Since there was no active maintainer for this package, it was dropped in 15.05.  
If you want to use XMail under OpenWrt/LEDE &gt;/=17.01, you have to compile it yourself. There is a fork that may still work [https://github.com/GerHobbelt/xmail](https://github.com/GerHobbelt/xmail "https://github.com/GerHobbelt/xmail")

Installed xmail, it will put executables in /usr/bin and MailRoot in /tmp  
I copied MailRoot to my stick  
cd /tmp  
cp -rp MailRoot /www/  
I created the start script XMail in /etc/init.d/ with the following - you should edit XMAIL\_ROOT variable

```
#!/bin/sh
# example file to build /etc/init.d/ scripts.
# Written by Miquel van Smoorenburg <miquels@cistron.nl>.
# Modified by Davide Libenzi <davidel@xmailserver.org>
#
# Version: 1.8  03-Mar-1998  miquels@cistron.nl
#
 
XMAIL_ROOT=/www/MailRoot
XMAIL_CMD_LINE="-SX 1 -Qn 1 -Yt 1 -Ln 1 -PX 1 -CX 1 -Pl -Sl -Ql -Ll -Yl -Yi 600"
DAEMON=/usr/bin/XMail
NAME=XMail
DESC="XMail server"
echo $DAEMON
test -f $DAEMON || exit 0
 
set -e
ulimit -c 10000
 
start_xmail() {
MAIL_ROOT=$XMAIL_ROOT
export MAIL_ROOT
MAIL_CMD_LINE=$XMAIL_CMD_LINE
export MAIL_CMD_LINE
$DAEMON
while [ ! -f /var/run/$NAME.pid ]
do
  sleep 1
done
}
 
stop_xmail() {
if [ -f /var/run/$NAME.pid ]
then
  echo `date` > $XMAIL_ROOT/.shutdown
  kill `cat /var/run/$NAME.pid`
  sleep 1
  #while [ -f $XMAIL_ROOT/.shutdown ]
  #do
  # sleep 1
  #done
fi
}
 
 
case "$1" in
start)
  echo -n "Starting $DESC: "
  start_xmail
  echo "$NAME.[" `cat /var/run/$NAME.pid` "]"
;;
stop)
  echo -n "Stopping $DESC: "
  stop_xmail
  echo "$NAME."
;;
restart|force-reload)
  echo -n "Restarting $DESC: "
  stop_xmail
  sleep 1
  start_xmail
  echo "$NAME.[" `cat /var/run/$NAME.pid` "]"
;;
*)
  N=/opt/etc/init.d/Xmail
  echo "Usage: $N {start|stop|restart|force-reload}" > &2
  exit 1
;;
esac
exit 0
```

create MailRoot/ctrlaccounts.tab  
cd &lt;MailRoot directory&gt;  
XMCrypt &lt;The password you like for admin account&gt;  
vi ctrlaccounts.tab and insert one line with the username&lt;tab&gt;output from above line  
start Xmail with /etc/init.d/Xmail start - first time will take some time because Xmail will create a spool structure in MailRoot/spool directory  
sendmail there comes with Xmail need MAIL\_ROOT variable so i did the following  
mv /usr/bin/sendmail /www/MailRoot/bin/sendmail.org

created /www/MailRoot/bin/sendmail.xmail.sh with the following:

```
#!/bin/sh
export DEFAULT_DOMAIN="domain.org"
if [ -z $MAIL_ROOT ]; then
      export MAIL_ROOT=/www/MailRoot
fi
$PWD/sendmail.org $*
```

chmod +x /www/MailRoot/bin/sendmail.xmail.sh  
ln -s /www/MailRoot/sendmail.xmail.sh /usr/bin/sendmail  
you should now me able to use sendmail the normal way  
eg. sendmail -s xxx@yyy.zzz  
enter some text and press ctrl D  
I order to configure Xmail with domains and users i advice you to install phpxmail 1.5, find it here [http://phpxmail.sourceforge.net/](http://phpxmail.sourceforge.net/ "http://phpxmail.sourceforge.net/")  
If you want Webmail i recommend [http://www.telaen.org/](http://www.telaen.org/ "http://www.telaen.org/"), but use sendmail when you configure it as smtp access will take a little time if you configure the spam filter,  
If you want outlook skin I have this working on OpenWrt  
[http://tdah.us/index.php?option=com\_docman&amp;task=cat\_view&amp;gid=13&amp;Itemid=27](http://tdah.us/index.php?option=com_docman&task=cat_view&gid=13&Itemid=27 "http://tdah.us/index.php?option=com_docman&task=cat_view&gid=13&Itemid=27")

taken from forum [https://forum.openwrt.org/viewtopic.php?pid=57808#p57808](https://forum.openwrt.org/viewtopic.php?pid=57808#p57808 "https://forum.openwrt.org/viewtopic.php?pid=57808#p57808")  
credits to Margate
