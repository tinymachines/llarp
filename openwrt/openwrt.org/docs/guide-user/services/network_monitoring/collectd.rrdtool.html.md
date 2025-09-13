- Install all needed packages
  
  - opkg install collectd collectd-mod-cpu collectd-mod-disk collectd-mod-iptables collectd-mod-load collectd-mod-memory collectd-mod-ping collectd-mod-rrdtool collectd-mod-uptime rrdtool uhttpd nano # 1.6 MB of space needed

<!--THE END-->

- Configure collectd.conf file
  
  - nano /etc/collectd.conf

<!--THE END-->

- Enable and start collectd service
  
  - /etc/init.d/collectd enable
  - /etc/init.d/collectd start

<!--THE END-->

- Enable uhttpd web server
  
  - /etc/init.d/uhttpd enable
  - /etc/init.d/uhttpd start

<!--THE END-->

- Enable traffic monitoring
  
  - echo “iptables -N traffic” &gt;&gt; /etc/rc.local
  - echo “iptables -I FORWARD -j traffic” &gt;&gt; /etc/rc.local
