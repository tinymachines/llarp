# Statistical Data Overview

The easy-way: simply install `luci-app-statistics` and configure: [howto](/docs/guide-user/luci/luci_app_statistics "docs:guide-user:luci:luci_app_statistics").  
However, if you are bored, knock yourself out: dig deeper - instructions are below.

## Collect data

Executing some simple commands like `iptables -nL -v -x -t filter`, `tc -s qdisc show dev pppoe-dsl` or `tc filter show dev pppoe-dsl` will already output statistical data. Simple. But there are tools which collect such (and much more) data and [parse](https://en.wikipedia.org/wiki/Parsing "https://en.wikipedia.org/wiki/Parsing") it for storage or for other programs which draw pictures from the parsed data:

- [statistic.collectd](/docs/guide-user/perf_and_log/statistic.collectd "docs:guide-user:perf_and_log:statistic.collectd") is a daemon which monitors various system info through plugins and optionally outputs gathered data into \*.rrd files (rrd is only one of several options, it can send over network or export \*.csv files as well)
- [statistic.rrdcollect](/docs/guide-user/perf_and_log/statistic.rrdcollect "docs:guide-user:perf_and_log:statistic.rrdcollect") is a very simple data collector daemon which lets you define rules and patterns to extract numerical data from commands (like an iptables listing) or files (like /sys or /proc)
- [statistic.custom](/docs/guide-user/perf_and_log/statistic.custom "docs:guide-user:perf_and_log:statistic.custom") custom cronjobs which gather data and parse it and then call `rrdupdate` manually on existing \*.rrd files

<!--THE END-->

- [bwmon](/docs/guide-user/services/network_monitoring/bwmon "docs:guide-user:services:network_monitoring:bwmon") ![FIXME](/lib/images/smileys/fixme.svg) milk this article for the related content, leave stuff for testing current bandwidth there, move the rest

## Generate charts from data

Now from this statistical data we could make some tools create pretty pictures:

- [statistic.rrdtool](/docs/guide-user/perf_and_log/statistic.rrdtool "docs:guide-user:perf_and_log:statistic.rrdtool") [*http://oss.oetiker.ch/rrdtool/*](http://oss.oetiker.ch/rrdtool/ "http://oss.oetiker.ch/rrdtool/") provides the means to create, update, dump, examine and render \*.rrd files
- [charts.mrtg](/doc/howto/charts.mrtg "doc:howto:charts.mrtg") [*http://oss.oetiker.ch/mrtg/*](http://oss.oetiker.ch/mrtg/ "http://oss.oetiker.ch/mrtg/") is written in Perl, use rrdTool, which is written in C
- to create for bodacious pie charts like e.g. gargoyle [Gargoyle](http://www.gargoyle-router.com/wiki/lib/exe/detail.php?id=screenshots&media=screenshots%3A05_qosdist.jpg "http://www.gargoyle-router.com/wiki/lib/exe/detail.php?id=screenshots&media=screenshots:05_qosdist.jpg") you could utilize JavaScript, AJAX, etc.

**NOTE:** If you do not log exclusively your own traffic data, please mind **data privacy protection laws** to prevent you from going to jail or paying a fine. Usually it is alright to collect and display adequately anonymized data but nothing else without knowledge and consent of the persons concernd.

## Serve Pictures

- [statistics.chart.public](/docs/guide-user/luci/statistics.chart.public "docs:guide-user:luci:statistics.chart.public") if you're happy with the charts and with LuCI but just want to make the charts public (no authentication)
- [webserver](/docs/guide-user/services/webserver/start "docs:guide-user:services:webserver:start") pick a webserver, install and configure it
- [chart.http](/doc/howto/chart.http "doc:howto:chart.http") make rrdTool place the PNG-files in a directory, then make ? tinker a html-page which the webserver can serve
