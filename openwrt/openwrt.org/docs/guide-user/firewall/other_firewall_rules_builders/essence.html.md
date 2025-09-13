# Firewall Builder: Essence Reloaded

There is a Netfilter configuration tool written in Perl by one of the members of the Netfilter core team, József Kadlecsik. It's named “Essence Reloaded”, and is available at [git.kfki.hu](http://git.kfki.hu/ "http://git.kfki.hu/"). One can clone the repo with the `git clone git://git.kfki.hu/essence.git` command. Its main goal is to help people configuring Netfilter firewalls who are not used to it. This project is the resurrected version (released in 2014) of the old “Essence” utility. It is recommended for routers running OpenWrt.

You can read the documentation with `perldoc essence`.

On OpenWrt, install the following packages before trying it:

```
opkg install perl perlbase-filehandle perlbase-essential perlbase-io perlbase-symbol perlbase-selectsaver perlbase-xsloader perlbase-fcntl perlbase-file perlbase-data perlbase-bytes perlbase-getopt perlbase-config
```

This has not been tested; list update was in 2014. It is retained here for completeness.
