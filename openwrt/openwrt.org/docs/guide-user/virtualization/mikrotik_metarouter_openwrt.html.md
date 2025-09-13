# OpenWrt running as metarouter on mikrotik routerOS

## Premises

Openwrt as metarouter is highly experimental but is also very promising, therefore if someone knows useful resources, please contribute! This should be valid for the entire openwrt wiki in general.

## Resources

### Discussion forums

One obvious resource is the mikrotik forum and related searches on it. For example with google `site:miktrotik.com openwrt metarouter`.

Discussion about patching the openwrt sources to get the metarouter image working: [http://forum.mikrotik.com/viewtopic.php?t=75849](http://forum.mikrotik.com/viewtopic.php?t=75849 "http://forum.mikrotik.com/viewtopic.php?t=75849")

### Articles

- [http://naberius.de/2015/01/10/openwrt-barrier-breaker-metarouter-instance-on-mikrotik-rb-2011/](http://naberius.de/2015/01/10/openwrt-barrier-breaker-metarouter-instance-on-mikrotik-rb-2011/ "http://naberius.de/2015/01/10/openwrt-barrier-breaker-metarouter-instance-on-mikrotik-rb-2011/")
- [metarouter](/docs/guide-user/virtualization/metarouter "docs:guide-user:virtualization:metarouter")

### Openwrt metarouter images and repositories

- A resource is provided by a user of the mikrotik forum, **liquidcz**, that is providing patched metarouter images with openwrt for mips and pppc architectures, here: [http://forum.mikrotik.com/viewtopic.php?p=414386#p414386](http://forum.mikrotik.com/viewtopic.php?p=414386#p414386 "http://forum.mikrotik.com/viewtopic.php?p=414386#p414386") . Thanks a ton to this guy.
- Mirror based on the liquicz's work: [http://download.bmsoft.de/mikrotik/12.09/metarouter/](http://download.bmsoft.de/mikrotik/12.09/metarouter/ "http://download.bmsoft.de/mikrotik/12.09/metarouter/")
- Repository for openwrt metarouter: [https://github.com/TheSkorm/openwrt-metarouter-cjdns](https://github.com/TheSkorm/openwrt-metarouter-cjdns "https://github.com/TheSkorm/openwrt-metarouter-cjdns")

#### Providing alternatives mirrors

The metarouter image is based on a 'proper patch' for building the openwrt sources, so everyone can build its own version. The point is that (a) publishing the compiled packages online is not for everyone (b) providing the right procedure to build a mips/ppc version of openwrt is not for everyone. Therefore providing mirror of already compiled packages or informations (for example in this wiki) is highly reccomended - as in every open source/community project.

##### Use alternative mirrors

Editing `/etc/opkg.conf` like

```
src/gz packages http://download.bmsoft.de/mikrotik/12.09/metarouter/mr-mips/packages
#src/gz packages http://openwrt.wk.cz/attitude_adjustment/mr-mips/packages
dest root /
dest ram /tmp
lists_dir ext /var/opkg-lists
option overlay_root /overlay
```

## Experiences

### Routerboard r493g , routerOS 6.27 , openwrt 12.09 mips compiled by liquidcz

- CPU usage when idle, checked by winbox and routerOS: Around 15%. Around 8% if winbox shows few information.
- Ping answers when idle, direct connection: around 3000 ms.
- mwan3 version 1.4-24 works.
- With 2 wan connections: each wan connection seems to achieve an quite stable average of 25 Mbit/s using mwan3 (100+ firewall rules shown by `iptables-save`), and the CPU stays on an average of 40%. Could be that the test setup was limiting the system somehow, maybe due to the overhead in processing the IRQ request, like: when the IRQ is processed natively one can send more data, while with the hypervisor one can send less data, but then it is strange that both the flow from 2 wan connections goes through one lan connection without problems.
- Openvpn connection able to send or receive (not made synchronous tests) 6.5 ~ 7 Mbit/s of data. used by a system that use a metarouter as gateway. Could be the same problem of the speed through wan connections, that is the IRQ processing is the bottleneck.
- The system can be shut down like a normal openwrt or the metarouter can be shut down (via 'disable') or started (via 'enable') forcefully. On the mikrotik terminal a way to disable/enable is: `metarouter disable <metarouter_name> ; ping count=2 127.0.0.1 ; metarouter enable <metarouter_name>`
- When the mikrotik (re)starts, if the metatarouter is enabled, it starts too, finishing the start procedure in 4-5 minutes.
- Long time '30s+' to restart single services (firewall, dropbear, etc...)
- Software reboot of the metarouter itself takes 4-5 minutes to show up the system again (except for ping, that replies way earlier. Note that the openwrt is almost a basic installation).
- 'Forced' reboot (disable-enable in the RouterOS) takes 4-5 minutes to be completed.
- Long term usage (+ 30 days) has to be tested.
- Rebooting/power outage tests has to be done.
- The 'console' management, using winbox, is way better through the terminal. New terminal → metarouter console &lt;metarouter\_name&gt; . But remember that openwrt offer one global console therefore opening two console is not possible, in that case try to go by ssh.
- It seems possible to assign a miximum of 7 interfaces out of 9, over 7 openwrt won't recognize the other interface.
