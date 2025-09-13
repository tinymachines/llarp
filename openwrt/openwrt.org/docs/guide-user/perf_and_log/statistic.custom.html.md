# Logging custom statistics

You're already [gathering statistics with luci-app-statistics](/docs/guide-user/luci/luci_app_statistics "docs:guide-user:luci:luci_app_statistics") but you'd like to graph something under LuCI for which there is no `collectd-mod-*` in OpenWrt.

You could write custom `cron` jobs which gather data, parse it and call `rrdupdate` manually on existing \*.rrd files (instructions welcome!).

Another solution: use `collectd-mod-exec` and just a little glue. You'll need to be able to write a script (or modify the example) that can collect your data (without being launched as root!), and to write a simple chunk of Lua telling LuCI how to render your data. You'll probably want to do this over SSH.

Steps:

- `opkg install collectd-mod-exec`
- Write your script (example below), set it executable, test it out and place it somewhere persistent.
- In LuCI, add your script under Statistics→Setup→General plugins→Exec, and save&amp;apply.
- After a few seconds, check that `collectd` has created an RRD under `/var/rrd/yourhostname/exec-foo/datatype_bar.rrd`.
- Create `/usr/lib/lua/luci/statistics/rrdtool/definitions/exec.lua` and tell LuCI about titles, data types and colours.
- Visit Statistics→Graphs→General→Exec and try rendering your data.
- Consider adding `/usr/lib/lua/luci/statistics/rrdtool/definitions/exec.lua` to `/etc/sysupgrade.conf` so it survives upgrades.

## The script

Pick an existing type of data from `/usr/share/collectd/types.db` that fits your data. Not all will be supported in LuCI, including new ones you add (improvements to these instructions welcome).

Suppose the thing you want to log is the temperature of your router. There's already a type `temperature`. Your script needs to periodically print a line in the [collectd plain text protocol](https://collectd.org/wiki/index.php/Plain_text_protocol#PUTVAL "https://collectd.org/wiki/index.php/Plain_text_protocol#PUTVAL") in which some parts are fixed and others are chosen by you:

```
PUTVAL "<yourhostname>/exec-<instance>/<datatype>[-name]" [interval=X] <time>:<Y>
```

e.g.

```
PUTVAL "phobos/exec-environmental/temperature-cpu" interval=30 N:88.4
```

- `<yourhostname>` is usually just taken from the `COLLECTD_HOSTNAME` environment variable.
- `exec-<instance>` is the `collectd` plugin type (`exec`) plus a dash and whatever name you like for the instance (probably the name of the specific thing or category of things being monitored).
- `<datatype>[-name]` is the `collectd` data type from `/usr/share/collectd/types.db`, optionally followed by an underscore plus whatever name you like for the thing being measured. (You might have `temperature-external` and `humidity-internal` also produced by the same script.)
- `interval=X` is for scripts that deliver one reading (or set of readings) and exit each time they're invoked. It tells `collectd` there won't be a new reading ready until at least `X` seconds later, and not launch it again any sooner than that (launching frequently can load the system). It wouldn't make sense for this to be smaller than the interval you configured for all your graphs under Statistics→Setup→Collectd Settings, which is available to the script in the `COLLECTD_INTERVAL` environment variable.
- `<time>:<Y>` is the sample time and sample value.
  
  - for `<time>`, `N` means “now” and (unless your data is delayed) is usually what you want, although you can give a full seconds-since-the-epoch number.
  - `<Y>` is the reading. Simple cases like temperature only have one reading and no limits. Other types use other formats and may have tighter constraints and/or multiple readings at a time. Some allow `U` for unknown when there is no sensible data (e.g. what's the round-trip time of a ping if you never got a reply?). See the [collectd documentation](https://collectd.org/wiki/index.php/Plain_text_protocol#PUTVAL "https://collectd.org/wiki/index.php/Plain_text_protocol#PUTVAL") for more possibilities.

An example that stays running (so no `interval=X`) delivering made-up temperature readings `COLLECTD_INTERVAL` seconds apart:

```
#!/bin/sh

# COLLECTD_INTERVAL may have trailing decimal places, but sleep rejects floating point.
INTERVAL=$(printf %.0f $COLLECTD_INTERVAL)

while true; do
  val=$(awk 'BEGIN { srand(); printf("%.1f", rand()*60); }')
  echo "PUTVAL \"$COLLECTD_HOSTNAME/exec-test/temperature\" N:$val"
  sleep $INTERVAL
done
```

You don't have to use `sh`. `bash`, Lua or even `python-light` might make sense for more complex data collection/on more powerful hardware.

## Permissions issues

Remember to test it as the user it'll run as, because [collectd's exec plugin disallows root privileges](https://collectd.org/wiki/index.php/Plugin:Exec "https://collectd.org/wiki/index.php/Plugin:Exec"). If there's no way to avoid collecting the data with privileges, consider:

- Having a process with the necessary privileges deliver readings via a UNIX or network socket; consider `collectd-mod-unixsock` (not just for output like its description suggests --- speaks the same plain text protocol) or `collectd-mod-network`. Perhaps one day soon OpenWrt will support [file-based capabilities](https://archive.is/qX7Rl#selection-307.0-309.181 "https://archive.is/qX7Rl#selection-307.0-309.181").
- Using `sudo` to regain that privilege in a controlled manner. An [example from collectd](http://git.verplant.org/?p=collectd.git%3Ba%3Dblob%3Bhb%3Dmaster%3Bf%3Dcontrib%2Fexec-smartctl "http://git.verplant.org/?p=collectd.git;a=blob;hb=master;f=contrib/exec-smartctl") includes a config snippet.

## Rendering

Put this in `/usr/lib/lua/luci/statistics/rrdtool/definitions/exec.lua`, adapted to your data types. Take inspiration from the other definitions under `/usr/lib/lua/luci/statistics/rrdtool/definitions/`.

```
module("luci.statistics.rrdtool.definitions.exec", package.seeall)

function rrdargs(graph, plugin, plugin_instance)
    -- For $HOSTNAME/exec-foo-bar/temperature_baz-quux.rrd, plugin will be
    -- "exec" and plugin_instance will be "foo-bar".  I guess graph will be
    -- "baz-quux"?  We may also be ignoring a fourth argument, dtype.
    if "test" == plugin_instance then
        return {
            title = "%H: Made up temperature",
            vlabel = "celsius",
            -- vlabel = "farenheit",
            data = {
                types = { "temperature" },
                options = {
                    temperature = {
                        -- Convert to farenheit. See /usr/lib/lua/luci/statistics/rrdtool.lua and rrdgraph_rpn manpage.
                        -- transform_rpn = "1.8,*,32,+",
                        title  = "made up",
                        color  = "ff0000"
                    }
                }
            }
        }
    end
end
```

For the latest OpenWrt versions, please save the below to `/www/luci-static/resources/statistics/rrdtool/definitions/exec.js` instead. \[[https://github.com/openwrt/luci/issues/3719\]](https://github.com/openwrt/luci/issues/3719%5D "https://github.com/openwrt/luci/issues/3719]")

```
'use strict';

return L.Class.extend({
  title: _('Exec'),
  
  rrdargs: function(graph, host, plugin, plugin_instance, dtype) {
    if (plugin_instance == 'test') {
      return {
        title: "%H: Made up temperature",
        vlabel: "celsius",
        data: {
          types: [ "temperature" ],
          options: {
            temperature: {
               title  = "made up",
               color  = "ff0000" 
            },
          }
        }
      };			
    }
  }
});
```

If you make changes to the definition after first creating it, you must clear luci's cache with `rm -rf /tmp/luci-indexcache /tmp/luci-modulecache/` for the changes to take effect.

*Credit to [Alex](http://flux242.blogspot.co.uk/2011/01/collectd-mod-exec-part-1.html "http://flux242.blogspot.co.uk/2011/01/collectd-mod-exec-part-1.html") for documenting this.*
