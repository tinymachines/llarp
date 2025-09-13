![FIXME](/lib/images/smileys/fixme.svg) This **mostly** applies to traditional SysV-style initscripts, See [procd-init-scripts](/docs/guide-developer/procd-init-scripts "docs:guide-developer:procd-init-scripts") as well for procd-style initscripts

# Init Scripts

[Init](https://en.wikipedia.org/wiki/Init "https://en.wikipedia.org/wiki/Init") scripts configure the [daemons](https://en.wikipedia.org/wiki/Daemon_%28computing%29 "https://en.wikipedia.org/wiki/Daemon_(computing)") of the Linux system. Init scripts are run to start required processes as part of the [boot process](/docs/techref/process.boot "docs:techref:process.boot"). In OpenWrt init is implemented with init.d. The init process that calls the scripts at boot time is provided by [Busybox](/docs/techref/process.boot#busybox_init "docs:techref:process.boot"). This article explains how init.d scripts work and how to create them. Note that this is mostly equivalent to other init.d implementations and in-depth documentation can be found elsewhere. You could also take a look at the set of [shell functions in /etc/rc.common](https://git.openwrt.org/?p=openwrt%2Fopenwrt.git%3Ba%3Dblob%3Bf%3Dpackage%2Fbase-files%2Ffiles%2Fetc%2Frc.common%3Bhb%3DHEAD "https://git.openwrt.org/?p=openwrt/openwrt.git;a=blob;f=package/base-files/files/etc/rc.common;hb=HEAD") to see how the building blocks of the init scripts are implemented.

## Example Init Script

Init scripts are explained best by example. Suppose we have a daemon we want to handle by init.d. We create a file `/etc/init.d/example`, which as a bare minimum looks as follows:

Code

```
#!/bin/sh /etc/rc.common
# Example script
# Copyright (C) 2007 OpenWrt.org
 
START=10
STOP=15
 
start() {        
        echo start
        # commands to launch application
}                 
 
stop() {          
        echo stop
        # commands to kill application 
}
```

This init script is just a shell script. The first line is a [shebang line](https://en.wikipedia.org/wiki/Shebang_%28Unix%29 "https://en.wikipedia.org/wiki/Shebang_(Unix)") that uses `/etc/rc.common` as a wrapper to provide its main and default functionality and to check the script prior to execution.

![:!:](/lib/images/smileys/exclaim.svg) Look inside `rc.common` to understand its functionality.

By this `rc.common` template, the available commands for an init scripts are as follows:

```
      start   Start the service
      stop    Stop the service
      restart Restart the service
      reload  Reload configuration files (or restart if that fails)
      enable  Enable service autostart
      disable Disable service autostart
```

All these arguments can be passed to the script when run. For example, to restart the service call it with `restart`:

Shell Output

```
root@OpenWrt:/# /etc/init.d/example restart
```

The script's necessary `start()` and `stop()` functions determine the core steps necessary to start and stop this service.

- **start()** - these commands will be run when it is called with 'start' as its parameter.
- **stop()** - these commands will be run when it is called with 'stop' as its parameter.

The `START=` and `STOP=` lines determine at which point in the [init sequence](/docs/techref/process.boot#init "docs:techref:process.boot") this script gets executed. At boot time `init.d` just starts executing scripts it finds in `/etc/rc.d` according to their file names. The init scripts can be placed here as symbolic links to the `init.d` scripts in `/etc/init.d/`. Using [the enable and disable commands](#enable_and_disable "docs:techref:initscripts ↵") this is done automatically. In this case:

- `START=10` - this means the file will be symlinked as /etc/rc.d/S10example - in other words, it will start after the init scripts with START=9 and below, but before START=11 and above.
- `STOP=15` - this means the file will be symlinked as /etc/rc.d/K15example - this means it will be stopped after the init scripts with STOP=14 and below, but before STOP=16 and above. This is optional.

![:!:](/lib/images/smileys/exclaim.svg) If multiple init scripts have the same start value, the call order is determined by the alphabetical order of the init script's names.

![:!:](/lib/images/smileys/exclaim.svg) Don't forget to make sure the script has execution permission, by running `chmod +x /etc/init.d/example`.

![:!:](/lib/images/smileys/exclaim.svg) START and STOP values should fall in the range 1-99 as they are run alphabetically meaning 100 would execute after 10.

![:!:](/lib/images/smileys/exclaim.svg) OpenWrt will run the initscript **in the host system during build** (currently using actions “enable” or “disable”), and it must correctly deal with that special case without undue side-effects. Refer to the “enable and disable” section below for more on this pitfall.

### Other functions

The `rc.common` script defines other functions that you can override if you need to, eg:

- `boot()` - called once each time the system starts up. By default this function calls `start $@`, so if your service has a “one-off” component (eg. turn on some hardware) and an ongoing component (eg. use the hardware), you will almost certainly want to call `start “$@”` at the end of your own `boot()` function too. If there is no ongoing component, you can leave it out.
- `shutdown()` - called once each time the system is shut down (whether for reboot or poweroff). Like the `boot()` function, this function calls `stop` by default (note no arguments), so if your service has an ongoing component like above, and a one-off shutdown command (eg. turn off some hardware), you will want to call `stop` first, and then your one-off command.

These functions can be called by procd init scripts too.

For example:

Code

```
boot() {
  echo "Turning on extra comms device"
  # This is a made up command to illustrate the point
  comms2_power --on
  start "$@"
}

start() {
  # Service that uses the device we turned on in boot()
  my_service
}

shutdown() {
  # The service is finished, so turn off the hardware
  stop
  echo "Turning off extra comms device"
  comms2_power --off
}
```

### Custom commands

You can add your own custom commands by using the EXTRA\_COMMANDS variable, and provide help for those commands with the EXTRA\_HELP variable, then adding sections for each of your custom commands:

Code

```
EXTRA_COMMANDS="custom"
EXTRA_HELP="        custom  Help for the custom command"
 
custom() {
        echo "custom command"
        # do your custom stuff
}
```

If you run the script with this code added, with no parameters, this is what you'll see:

Shell Output

```
root@OpenWrt:/# /etc/init.d/example
Syntax: /etc/init.d/example [command]

Available commands:
        start   Start the service
        stop    Stop the service
        restart Restart the service
        reload  Reload configuration files (or restart if that fails)
        enable  Enable service autostart
        disable Disable service autostart
        custom  Help for the custom command
```

If you have multiple custom commands to add, you can add help text for each of them:

Code

```
EXTRA_COMMANDS="custom1 custom2 custom3"
EXTRA_HELP=<<EOF
        custom1 Help for the custom1 command
        custom2 Help for the custom2 command
        custom3 Help for the custom3 command
EOF
 
custom1 () {
        echo "custom1"
        # do the stuff for custom1
}
custom2 () {
        echo "custom2"
        # do the stuff for custom2
}
custom3 () {
        echo "custom3"
        # do the stuff for custom3
}
```

## Enable and disable

In order to automatically start the init script on boot, it must be installed into /etc/rc.d/ (see above). On recent versions of OpenWrt, the build system will attempt to “enable” and/or “disable” initscripts during package install and removal by itself (refer to default\_postinst() and default\_prerm() in /lib/functions.sh from package base-files -- this thing is utterly undocumented, including how to AVOID the automatic behavior where unwanted), and it will “enable” the initscripts on packages \*included* in the ROM images during build, see below.

![:!:](/lib/images/smileys/exclaim.svg) WARNING ![:!:](/lib/images/smileys/exclaim.svg) OpenWrt initscripts **will be run** while building OpenWrt images (when installing packages in what will become a ROM image) in the **host system** (right now, for actions “*enable*” and “*disable*”). **They must not fail, or have undesired side-effects in that situation.** When being run by the build system, environment variable **${IPKG\_INSTROOT}** will be set to the working directory being used. On the “target system”, that environment variable will be empty/unset. Refer to “/lib/functions.sh” and also to “/etc/rc.common” in package “base-files” for the nasty details.

Invoke the “enable” command to run the initscript on boot:

Shell Output

```
root@OpenWrt:/# /etc/init.d/example enable
```

This will create one or more symlinks in `/etc/rc.d/` which automatically execute at boot time (see [Boot process](/docs/techref/process.boot "docs:techref:process.boot"))) and shutdown. This makes the application behave as a system service, by starting when the device boots and stopping at shutdown, as configured in the init.d script.

To disable the script, use the “disable” command:

Shell Output

```
root@OpenWrt:/# /etc/init.d/example disable
```

which is configured to remove the symlinks again.

The current state can be queried with the “enabled” command:

Shell Output

```
root@OpenWrt:/# /etc/init.d/example enabled && echo on
on
```

![FIXME](/lib/images/smileys/fixme.svg) Many useful daemons are included in the official binaries, but they are not enabled by default. For example, the `cron` daemon is not activated by default, thus only editing the `crontab` won't do anything. You have to either start the daemon with `/etc/init.d/cron start` or enable it with `/etc/init.d/cron enable`. You can `disable`, `stop` and `restart` most of those daemons, too. -- This might not be true anymore!

To query the state of all init scripts, you can use the command below:

Shell Output

```
for F in /etc/init.d/* ; do $F enabled && echo $F on || echo $F **disabled**; done
```

```
root@OW2:~# for F in /etc/init.d/* ; do $F enabled && echo $F on || echo $F **disabled**; done
/etc/init.d/boot on
/etc/init.d/collectd on
...
/etc/init.d/led on
/etc/init.d/log on
/etc/init.d/luci_statistics on
/etc/init.d/miniupnpd **disabled**
/etc/init.d/network on
/etc/init.d/odhcpd on
...
```
