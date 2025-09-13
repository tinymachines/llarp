# Direct Connect and Advanced Direct Connect

[Direct Connect (file sharing)](https://en.wikipedia.org/wiki/Direct%20Connect%20%28file%20sharing%29 "https://en.wikipedia.org/wiki/Direct Connect (file sharing)") and [Advanced Direct Connect](https://en.wikipedia.org/wiki/Advanced%20Direct%20Connect "https://en.wikipedia.org/wiki/Advanced Direct Connect") are both communication protocols.

## Hub Software

Name Version Size Description Direct Connect protocol opendchub 0.8.2-1 45800 Open DC hub is a Unix/Linux version of the hub software for the Direct Connect network libopenssl 1.0.0d-1 592211 The OpenSSL Project is a collaborative effort to develop a robust, commercial-grade, full-featured, and Open Source toolkit implementing the Secure Sockets Layer (SSL v2/v3) and Transport Layer Security (TLS v1) protocols as well as a full-strength general purpose cryptography library.  
This package contains the OpenSSL shared libraries, needed by other programs. zlib 1.2.5-1 40447 Library implementing the deflate compression method libpthread 0.9.32-73 29572 POSIX thread library Advanced Direct Connect protocol uhub 0.2.8-1 44.462 uhub is a high performance peer-to-peer hub for the ADC network. Its low memory footprint allows it to handle several thousand users on high-end servers, or a small private hub on embedded hardware. libevent 1.4.14b-1 41255 The libevent API provides a mechanism to execute a callback function when a specific event occurs on a file descriptor or after a timeout has been reached. Furthermore, libevent also support callbacks due to signals or regular timeouts.  
libevent is meant to replace the event loop found in event driven network servers. An application just needs to call event\_dispatch() and then add or remove events dynamically without having to change the event loop.

### OpenDCHub Administration

→ [http://wireless.subsignal.org/index.php?title=Opendchub\_Administration](http://wireless.subsignal.org/index.php?title=Opendchub_Administration "http://wireless.subsignal.org/index.php?title=Opendchub_Administration")

Administration of the Hub´s via `telnet`:

```
telnet <IP address> <Port> (//default: 53696//)
$adminpass <password>| 
```

jetzt ist man eingeloggt und kann Befehle eintippen (immer mit “$” beginnend und “|” endend)

#### Begrüssungstext ändern

\* in das Verzeichnis:

```
cd /root/.opendchub     wechseln
vi motd                 öffnen
```

und Begrüssungstext ändern

#### Skripte hinzufügen

#### Befehlsliste

```
$commands|

Commands:
$adminpass 'password'|
Sends the administrations password. This has to be sent before any other
commands. This command does NOT work in chat for security reasons. A
user must be registered as an Op Admin before the user can use the
admin commands in chat.

$set 'variable' 'value'|
Sets a value in the config file. The config file is located in the
.opendchub directory, which is located in the root of your home directory.
The variables are explained in the config file. The program must be run
once first to create the config file.
The motd is placed in a file of it's own. To change the motd, use "!set motd".

$ban 'ip or hostname' 'time'|
Adds an entry to the banlist. The entry can be a subnet or a whole ip
address or a hostname. Hostnames may contain '*' as wildcard. The time is the
duration of the ban and can be 0 for permanent or a value followed by a
period (e.g. 10m). Accepted periods are s(seconds), m(minutes, h(hours) and
d(days).

$nickban 'nick' 'time'|
Adds an entry to the nick banlist. The time is the same as for the ban command

$allow 'ip or hostname'|
Adds an entry to the allowlist. This file works like the opposite of
banlist, i.e, the entries in this file are allowed to the hub.

$getbanlist|
Displays the banlist file.

$getnickbanlist|
Displays the nick banlist file.

$getallowlist|
Displays the allowlist file.

$unban 'ip or hostname'|
Removes an entry from the banlist file. The hostname/IP entry in the file must
be an exact match of the one provided in the command.

$unnickban 'nick'|
Removes an entry from the nick banlist file. The nick entry in the file must
be an exact match of the one provided in the command.

$unallow 'ip or hostname'|
Removes an entry from the allowlist file.

$addreguser 'nickname' 'password' 'op'|
Adds a user the the regfile. if 'op' is 1, the user is op, which allows user
to use the dedicated op commands, for example $Kick. If 'op' is 2, the user
also gets priviledges to administer the hub through the chat. If 'op is 0,
the user is an ordinary registered user with no special priviledges.

$getreglist|
Displays the reglist.

$removereguser 'nickname'|
Removes a user from the reglist.

$addlinkedhub 'hubip' 'port'|
Adds a hub to the linked hub list. The hub is linked with the hubs on this
list, wich makes it possible for users to search for file and connect to
users on other hubs. 'port' is the port on which the linked hub is run.

$getlinklist|
Displays the linked hubs file.

$removelinkedhub 'hubip' 'port'|
Removes a hub from the linked hub list.

$getconfig|
Displays the config file.

$getmotd|
Displays the motd file.

$quitprogram|
Terminates the program. Has the same effect as sending term signal to the
process, which also makes the hub shutting down cleanly.

$exit|
Disconnects from the hub.

$redirectall 'ip or hostname'|
Redirects all users to 'ip or hostname'.

$gethost 'nick'|
Displays the hostname of user with nickname 'nick'.

$getip 'nick'|
Displays the ip of user with nickname 'nick'.

$massmessage 'message'|
Sends a private message to all logged in users.

$reloadscripts|
Reloads the scripts in the script directory.

$addperm 'nick' 'permission'|
Adds the permission (one of BAN_ALLOW, USER_INFO, MASSMESSAGE, USER_ADMIN)
to the operator with nickname 'nick'.

$removeperm 'nick' 'permission'|
Removes the permission (one of BAN_ALLOW, USER_INFO, MASSMESSAGE, USER_ADMIN)
from the operator with nickname 'nick'.

$showperms 'nick'|
Shows the permissions (BAN_ALLOW, USER_INFO, MASSMESSAGE, USER_ADMIN)
currently granted to the operator with nickname 'nick'.

$commands|
Displays all available admin commands.

$GetNickList|
Returns a list of all users connected to the hub in the form:
$NickList 'user1'$$'user2'$$...'usern'$$||OpList 'op1'$$'op2'$$...'opn'||

$GetINFO 'nickname' Administrator|
Displays the user info of user with nick 'nickname'.

$To: 'nickname' From: Administrator $'message string'|
Sends a private message from administrator to user.

<Administrator> 'chat string'|
This is the only command that does not start with the '$'. It sends a
message to the public chat. Note that the nickname of the administrator is
"Administrator". It can't be changed.

$Kick 'nickname'|
Kicks the user with nick 'nickname'

$OpForceMove $Who:'nick':$Where:'host or ip'$Msg:'message'|
Redirects user with 'nick' to the hostname or ip and displays the
message 'message' to the redirected user. This is the only admin command
that is case sensitive.
```

## Client software

There is no DC or ADC client software available in the OpenWrt repositories yet!
