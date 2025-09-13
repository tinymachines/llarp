# DC overview

DC (Direct Connect) and [ADC (Advanced Direct Connect)](https://en.wikipedia.org/wiki/Advanced%20Direct%20Connect "https://en.wikipedia.org/wiki/Advanced Direct Connect") are both [Communications protocol](https://en.wikipedia.org/wiki/Communications%20protocol "https://en.wikipedia.org/wiki/Communications protocol")s.

- Official specifications for the DC protocol were never released, but there is a lot of FOSS utilizing the protocol; see here: [WP](https://en.wikipedia.org/wiki/Direct_Connect_%28file_sharing%29#Protocol "https://en.wikipedia.org/wiki/Direct_Connect_(file_sharing)#Protocol"), here: [ptokax wiki](http://wiki.ptokax.ch/doku.php/misc/dcprotocol/intro "http://wiki.ptokax.ch/doku.php/misc/dcprotocol/intro"), or ...
- For the ADC protocol there are official specifications at: [http://adc.sourceforge.net/ADC.html](http://adc.sourceforge.net/ADC.html "http://adc.sourceforge.net/ADC.html")
- The Wikipedia maintains an [overview](https://en.wikipedia.org/wiki/Comparison_of_NMDC_Software "https://en.wikipedia.org/wiki/Comparison_of_NMDC_Software") over available software for server (called hubs) and clients supporting the DC/ADC protocols

## From Repository

Here you find HowTos to help you install and configure them on OpenWrt:

- [dc.opendchub](/doc/howto/dc.opendchub "doc:howto:dc.opendchub") `opendchub` is a Unix/Linux version of the hub software for the Direct Connect network written in C
- [dc.uHub](/doc/hotwo/dc.uhub "doc:hotwo:dc.uhub") `uhub` is a high performance peer-to-peer hub for the ADC network written in C published under the GPLv3 with IPv6 support
- [PtokaX 0.5.0.1](/ru/doc/howto/ptokax_0.5.0.1 "ru:doc:howto:ptokax_0.5.0.1") Установка PtokaX 0.5.0.1 для LEDE (DCBEELINEKZ)

## From Sources

Unless the maintainers provide precompiled binaries (compiled against uCLibC for the [Instruction set](https://en.wikipedia.org/wiki/Instruction%20set "https://en.wikipedia.org/wiki/Instruction set") of your device), you need to [crosscompile](/docs/guide-developer/toolchain/crosscompile "docs:guide-developer:toolchain:crosscompile") the sources yourself:

- [dc.ptokax](/doc/hotwo/dc.ptokax "doc:hotwo:dc.ptokax") [http://www.ptokax.org/](http://www.ptokax.org/ "http://www.ptokax.org/")
- [dc.verlihub](/doc/hotwo/dc.verlihub "doc:hotwo:dc.verlihub") [http://www.verlihub-project.org/doku.php?id=start](http://www.verlihub-project.org/doku.php?id=start "http://www.verlihub-project.org/doku.php?id=start")
- [dc.flexhub](/doc/howto/dc.flexhub "doc:howto:dc.flexhub") [http://www.flexhub.org/forum/](http://www.flexhub.org/forum/ "http://www.flexhub.org/forum/")

...

## Install and Configure OpenDCHub (quickNdirty)

- install opendchub
  
  ```
  opkg update
  opkg install opendchub
  ```
- now execute
  
  ```
  opendchub
  ```
  
  and answer the questions. The default port is 411
- to view the options of opendchub execute
  
  ```
  opendchub -h
  ```
- edit `/root/.opendchub/config` and set *hub\_hostname* to the hostname of your router
- to see if everything works well, start opendchub in debug mode:
  
  ```
  opendchub -d
  ```
- for normal mode, execute
  
  ```
  opendchub
  ```
- Optionally add an entry to your `/etc/rc.local` to start opendchub when the router boots.
