# Ostiary Daemon (run a fixed set of commands remotely)

Ostiaryd is designed to allow you to run a fixed set of commands remotely, without giving everyone else access to the same commands.

The following are the key design goals:

- “First, do no harm.” It should not be possible to use the Ostiary system itself to damage the host it's running on. In particular, it's willing to accept false negatives (denying access to legitimate users) in order to prevent false positives (allowing access to invalid users).
- Insofar as possible, eliminate any possibility of bugs causing undesired operations. Buffer overflows, timing attacks, etc. should be impossible for an external attacker to execute. There's no point in installing security software if it makes you less secure.
- Be extremely modest in memory and CPU requirements. (eg. running on a Mac SE/30, a 16MHz 68030 machine) and connecting from a Palm Pilot (a 16MHz 68000 machine).
- Keep things simple. This is not an ssh replacement. Each successful challenge/response will result in executing a corresponding script.
- It is immune to replay attacks

This wiki is a quick summary of the author's documentation followed by openwrt specific usage instructions. For any technical info you may wish to view the author's site: [http://ingles.homeunix.net/software/ost/index.html](http://ingles.homeunix.net/software/ost/index.html "http://ingles.homeunix.net/software/ost/index.html") .

## How it works

The algorithm used is as follows:

1. Ostiaryd waits on a port for connections from remote machines. When one is received, ostiaryd checks to see if the ip address is locked out. (If compiled in, it will consult /etc/hosts.allow and hosts.deny, too.) If so, it drops the connection immediately.
2. If the address is not locked out, ostiaryd sends a seed value. Currently this is a SHA256 hash (32 bytes) of the the current time, plus either the output of random() or (if available) bytes from /dev/urandom, plus the process' PID.
3. The client takes the seed value and hashes it, HMAC-style, with the password the user provides.
4. Ostiaryd then reads the response (32 bytes), and closes the connection.
5. Now ostiaryd goes through a list of passwords, and hashes them (HMAC style) with the hash value it sent. It compares these new hashes with the response it received.
6. If it finds a match, the command corresponding to that password is run. (E.g., it could start up sshd so you could log in remotely.) The ip address of the client is given as an argument to the command.
7. If the hash does not match any of the listed hashes, the ip address that the bogus hash was sent from gets put on a list of bad addresses. If it exceeds the a defined limit of bad connections, that address is locked out and no further communication is accepted.
8. Now, ostiaryd sleeps a user-defined interval, at least one second.
9. Finally, it jumps back to step 1.

## How to get it

Grab it from the repository (Note, it has only been added to the master 'snapshot' builds, not versioned builds eg. '18.06', ensure your [opkg configuration](/docs/guide-user/additional-software/opkg "docs:guide-user:additional-software:opkg") includes the snapshot/packages/&lt;arch&gt;/packages path)

```
$ opkg update
$ opkg install ostiary
```

This package installs both the [ostiaryd](/docs/guide-user/services/remote_control/ostiary.server "docs:guide-user:services:remote_control:ostiary.server") service, and the [ostclient](/docs/guide-user/services/remote_control/ostiary.client "docs:guide-user:services:remote_control:ostiary.client") client. Both located in /usr/bin

## Service Configuration

The configuration file is installed by default at /etc/ostiary.cfg

At a minimum, you will need to set at least the following sections:

- PORT=????
- KILL=panicpassword
- ACTION=“secretpassword”,“/full/path/to/script”, “uid”, “gid”

(upto 8 ACTION scripts are allowed by default. More can be added but you would need to edit the header file ost.h and recompile. See author's site [here](http://ingles.homeunix.net/software/ost/install.html#use "http://ingles.homeunix.net/software/ost/install.html#use").)

Eg:

```
ACTION="SecretP@ssword","/path/to/script.sh","0","0"                      
```

**Be sure to always restart the ostiaryd daemon after making any changes!**

## Stopping and Starting ostiaryd

```
/etc/init.d/ostiaryd ARGUMENT
```

where ARGUMENT is one of “stop”, “start”, or “restart”.

## "Action" Scripts

Each “secret” passphrase you defined above needs a corresponding action script (i.e. one-to-one).

Actions scripts can invoke anything you could run from a command line, such as:

- Start/Stop a service
- Execute/kill a process/send a signal
- Add/remove a firewall rule (or [IPSET](/docs/guide-user/firewall/fw3_configurations/fw3_config_ipset "docs:guide-user:firewall:fw3_configurations:fw3_config_ipset") entry)

so long as the command is either fixed, or will only vary depending on your ostiary client IP.

If your scripts run successfully as root, but fail under Ostiary (test using [ostclient](/docs/guide-user/services/remote_control/ostiary.client "docs:guide-user:services:remote_control:ostiary.client")), ensure that you have set uid/gid to 0 for that action; or set appropriate filesystem permissions.

Note: By the author's [design](http://ingles.homeunix.net/software/ost/install.html#use "http://ingles.homeunix.net/software/ost/install.html#use"), you can't inline a shell command into the ACTION script definition. You need to put your command(s) into a separate file, make it executable, and then call the file using the syntax above. (I know, I wasted a couple of hours on this one...)

Remember to add your scripts' location to the folders kept during sysupgrade in [/etc/sysupgrade.conf](/docs/guide-user/base-system/notuci.config#etcsysupgradeconf "docs:guide-user:base-system:notuci.config")

## Clients

Clients for connecting to the ostiaryd service are listed below.

1. [ostclient](/docs/guide-user/services/remote_control/ostiary.client "docs:guide-user:services:remote_control:ostiary.client")
   
   - included in the package you just installed at /usr/bin/ostclient (It can be deleted if you dont need it or really need the 9kb space back... )
   - available in RPM and Debian packages, plus source [from the author's site](http://ingles.homeunix.net/software/ost/get.html#latest "http://ingles.homeunix.net/software/ost/get.html#latest")
2. [Andriod](http://ingles.homeunix.net/software/ost/latest/Ostiary.apk "http://ingles.homeunix.net/software/ost/latest/Ostiary.apk")
3. [iOS](http://itunes.apple.com/ye/app/ostiary/id463229304 "http://itunes.apple.com/ye/app/ostiary/id463229304")
4. [Windows](http://ingles.homeunix.net/software/ost/latest/winclient-4.0.zip "http://ingles.homeunix.net/software/ost/latest/winclient-4.0.zip")
5. [Java (generic)](http://ingles.homeunix.net/software/ost/get.html#latest "http://ingles.homeunix.net/software/ost/get.html#latest")
