# Make luci-app-statistics graphs public

according to this issue [https://github.com/openwrt/luci/issues/4375](https://github.com/openwrt/luci/issues/4375 "https://github.com/openwrt/luci/issues/4375")

this feature was removed

You've [configured luci-app-statistics](/docs/guide-user/luci/luci_app_statistics "docs:guide-user:luci:luci_app_statistics") to your liking and now you want to share the charts.

One way is to serve them via LuCI but without authentication:

1. create `/usr/lib/lua/luci/controller/public_stats.lua` with the following content:
   
   ```
   module("luci.controller.public_stats", package.seeall)
   
   function index()
       assign({"graph"}, {"admin", "statistics", "graph"}, nil)
   end
   ```
2. wipe out some caches that are now stale: `rm -rf /tmp/luci-indexcache /tmp/luci-modulecache/`
3. log out from LuCI if you're still logged in
4. visit [http://192.168.1.1/cgi-bin/luci/graph](http://192.168.1.1/cgi-bin/luci/graph "http://192.168.1.1/cgi-bin/luci/graph")
5. add `/usr/lib/lua/luci/controller/public_stats.lua` to `/etc/sysupgrade.conf` so it survives upgrades

“Graph” will now appear in the page footer, including on the login page, so you shouldn't need a custom index.

Another way might be to use a `collectd` network output plugin and log the data to a more powerful remote host running something like Cacti.

*(Thanks to jow for these instructions.)*
