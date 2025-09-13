**Under Construction!**  
This page is currently under construction. You can edit the article to help completing it.

I know this is fairly simply laid out, but there was nothing here, and I just worked out how to get UCI and snmpd to play nice, so I figured i'd put -something- here..

Unlike other distro's, OpenWRT uses UCI (/etc/config/snmpd) to generate the /etc/snmp/snmpd.conf , so you cannot simply edit this file and restart snmpd.

I'm sure you can work out how to apply this to your own needs, but below is simply the syntax.

When you look in **/etc/config/snmpd** it looks like this

```
config 'exec'
        option 'name' 'filedescriptors'
        option 'prog' '/bin/cat'
        option 'args' '/proc/sys/fs/file-nr'
```

Which then produces in **/etc/snmp/snmpd.conf**

```
exec  filedescriptors /bin/cat /proc/sys/fs/file-nr
```

So you could manually edit the UCI file. Or you can use this syntax.

at any prompt type the following

```
uci add snmpd exec
uci set snmpd.@exec[-1].name=filedescriptors
uci set snmpd.@exec[-1].prog=/bin/cat
uci set snmpd.@exec[-1].args=/proc/sys/fs/file-nr
uci commit snmpd
```

This will add the changes to the bottom of the /etc/config/snmpd file.

So adapt that syntax as required for your own custom scripts or changes you are making to the snmpd file.

This is a very simply and basic wiki entry, feel free to change it, I just felt that after seeing this page blank and having to work it out for myself, if it can help someone else, its worth it!
