# daloRADIUS management system

This page covers installation of DaloRADIUS and extending it. All this should be done on an extroot as it will take too much space for most routers and in the case of mysql poses the risk of wearing down your flash! Warning: all this has been commited from memory!

## Basics

### Prerequisites

- You need to have a freeradius server up and running.  
  Unfortunately, this is not documented on this wiki yet, but relatively straightforward. This howto expects that you have one already up and running.
- You should have configured your Wifi to use your radius server.  
  For this, see [wpa\_enterprise\_access\_point](/docs/guide-user/network/wifi/basic#wpa_enterprise_access_point "docs:guide-user:network:wifi:basic"). Don't forget, that you will need wpad instead of wpad-mini for enterprise WPA!
- It might be a good idea to have [LuCI running on Lighthttpd](/doc/howto/luci.on.lighttpd "doc:howto:luci.on.lighttpd")

### Required Packages

#### Server (OpenWrt)

- **`lighttpd`** as webserver
- **`lighttpd-mod-fastcgi`** to run php5
- **`php5-fastcgi`**
- **`php-pear-db`** prerequisite for daloradius
- **`php5-mod-session`** prerequisite for daloradius
- **`php5-mod-gd`** prerequisite for daloradius
- **`php5-mod-mysql`** prerequisite for daloradius
- **`mysql-server`** prerequisite for daloradius
- **`freeradius2-mod-sql-mysql`** to connect freeradius to your DB
- **`samba36-server`** if you want to use the NT-Hash authentification described below

## Installation

### Packages

```
opkg install lighttpd lighttpd-mod-fastcgi php5-fastcgi php-pear-db php5-mod-session php5-mod-gd php5-mod-mysql mysql-server freeradius2-mod-sql-mysql
```

### Download &amp; unpack daloradius

Download daloradius-XXX.tar.gz from [http://sourceforge.net/projects/daloradius/files/latest/download](http://sourceforge.net/projects/daloradius/files/latest/download "http://sourceforge.net/projects/daloradius/files/latest/download")

```
gunzip daloradius-XXX.tar.gz
tar xzvf daloradius-XXX.tar
mv daloradius-XXX /www/daloradius
```

### Necessary configuration

#### lighttpd

In `/etc/lighttpd/lighttpd.conf` (note that bin-path differs from the default in this file!):

```
#### fastcgi module
## read fastcgi.txt for more info
fastcgi.server = (
        ".php" => (
                "localhost" => (
                        "socket" => "/tmp/php-fastcgi.socket",
                        "bin-path" => "/usr/bin/php-fcgi"
                )
        )
)
```

#### php

Create a file `/etc/php5/pear.ini` or edit your `/etc/php.ini`

```
include_path = ".:/usr/lib/php/"
```

#### mysql

Set a `datadir` in `/etc/my.cnf`

```
datadir         = /data/mysql/
```

and run

```
mysql_install_db --force
```

Create a DB 'radius' and a user by the same name. Insert your password.

```
cat <<EOF | mysql -u root
CREATE DATABASE radius CHARACTER SET utf8;
GRANT ALL ON radius.* TO 'username'@'127.0.0.1' IDENTIFIED BY 'password' WITH GRANT OPTION;
EOF
```

#### daloradius

Fill database

```
mysl -u root radius < /www/daloradius/contrib/db/fr2-mysql-daloradius-and-freeradius.sql
```

edit `/www/daloradius/library/daloradius.conf.php` to your needs - at LEAST the CONFIG\_DB\_HOST (change to 127.0.0.1 so that user above matches), CONFIG\_DB\_PORT, CONFIG\_DB\_USER and CONFIG\_DB\_PASS.

#### freeradius

- The freeradius-mod-sql-mysql package is missing the `$INCLUDE sql/${database}/dialup.conf` file. google it, download it and put it in the right place on your machine.
- Add your credentials to the `/etc/freeradius/sql.conf`
- Uncomment the sql module in `/etc/freeradius/sites/default`

### done

Daloradius should be available now at `http://openwrt.lan/daloradius/index.php` - have fun!

## NT-Hashes

Quite probably, you are going to use MSCHAPv2, and probably you don't wanna store cleartext passwords. Which means, you'll have to use NT-Hashes.

To get NT-Hashes, you need the smbencrypt tool. This is not available for openwrt, but smbpasswd is and uses the same algorithm. This script serves as a workaround (ugly!):

```
#!/bin/bash
PWD=$1
DUMMYUSER="smbencrypt_dummy"
 
# if there is no user $DUMMYUSER, we have to add it to /etc/passwd using the nobody group
grep -q smbencrypt_dummy /etc/passwd || echo "$DUMMYUSER:*:65533:65534:dummy_user_for_fake_smbencrypt:/var:/bin/false" >> /etc/passwd
 
# add entry to /etc/samba/smbpasswd
cat <<EOF | smbpasswd -s -a $DUMMYUSER
$1
$1
EOF
 
# get entry
NTHASH=`grep $DUMMYUSER /etc/samba/smbpasswd | cut -d':' -f4`
 
# remove $DUMMYUSER from /etc/samba/smbpasswd
smbpasswd -x $DUMMYUSER
 
#remove $DUMMYUSER from /etc/passwd
sed -i "/$DUMMYUSER/d" /etc/passwd
 
# output results
cat <<EOF
LM Hash                            NT Hash
--------------------------------   --------------------------------
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX   $NTHASH
EOF
```

To be able to enter such an NT-Hash in Daloradius, add to `/www/daloradius/mng-new.php` after line 618:

```
                        <option value='NT-Password'>NT-Password</option>
```

note that at this state you still have to enter your calculated NT-Hash in the password text field!

If you want daloradius to calculate your NT-Hash for you if you select NT-Password, you have to add the following code to `/www/daloradius/mng-new.php` after line 438 (don't forget to copy the above script to /bin/smbencrypt!):

```
// or calculate an NT hash
                                        } elseif ($passwordtype=="NT-Password"){
                                                $dbPassword = "'".shell_exec("smbencrypt '".escapeshellcmd($dbPassword)."' | tail -n1 | sed 's/^X* *//'")."'";
                                        }
```

## Final warning

From what I've seen so far, daloradius is cool - but the code looks to me like it's prone to all kinds of injections. As it is an interface that should ony accessed by the administrator (you!): put it behind an HTTP auth - see `lighttpd_mod_auth`
