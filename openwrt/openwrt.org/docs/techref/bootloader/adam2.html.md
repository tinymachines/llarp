# ADAM2

[Adam2](http://wikibin.org/articles/adam2.html "http://wikibin.org/articles/adam2.html") was written by Texas Instruments and is/was used only with their [AR7](/docs/techref/hardware/soc/soc.ar7 "docs:techref:hardware:soc:soc.ar7")-SoC. Some sources seem to be available but **there is no FOSS license**! With the available sources you may be able to do stuff, but actually you have no permission to do it!

ADAM2 has two successors: [EVA](/docs/techref/bootloader/eva "docs:techref:bootloader:eva"), done by AVM when they switched from Kernel 2.4 to Kernel 2.6 and PSPboot. The official successor is [pspboot](/docs/techref/bootloader/pspboot "docs:techref:bootloader:pspboot").

- [Freetz site (Mainly only in German)](https://freetz.org/wiki/help/howtos/development/adam2 "https://freetz.org/wiki/help/howtos/development/adam2") - [Google Translated to English](https://translate.google.com/translate?hl=en&sl=de&u=https%3A%2F%2Ffreetz.org%2Fwiki%2Fhelp%2Fhowtos%2Fdevelopment%2Fadam2&prev=search "https://translate.google.com/translate?hl=en&sl=de&u=https://freetz.org/wiki/help/howtos/development/adam2&prev=search")
- [http://www.enotes.com/topic/Adam2](http://www.enotes.com/topic/Adam2 "http://www.enotes.com/topic/Adam2")
- [http://www.seattlewireless.net/ADAM2](http://www.seattlewireless.net/ADAM2 "http://www.seattlewireless.net/ADAM2")
- [Installing OpenWrt over FTP (generic)](/docs/guide-user/installation/generic.flashing.ftp "docs:guide-user:installation:generic.flashing.ftp")
- [D-Link DSL-5xxT and DSL-G6xxT - ADAM2 Installation Guide](/toh/d-link/dsl-5xxt-6xxt-adam2 "toh:d-link:dsl-5xxt-6xxt-adam2")

## Loading an executable to RAM

[Adam2](https://en.wikipedia.org/wiki/Adam2 "https://en.wikipedia.org/wiki/Adam2") supports loading an executable into RAM and executing it. In order to do so:

- convert your executable to the SREC format
- use srec2bin to convert the SREC file into the ADAM2 binary format

You can then upload your binary using the following procedure:

```
ftp> open 192.168.2.1
Connected to 192.168.2.1.
220 ADAM2 FTP Server ready.
Name (192.168.2.1:florian): adam2
331 Password required for adam2.
Password:
230 User adam2 successfully logged in.
Remote system type is UNIX.
ftp> bi
200 Type set to I.
ftp> quote "MEDIA SDRAM"
200 Media set to SDRAM.
ftp> put vmlinux.bin
local: vmlinux.bin remote: vmlinux.bin
200 Port command successful.
150 Opening BINARY mode data connection for file transfer.
226 Transfer complete.
7838718 bytes sent in 6.70 secs (1142.2 kB/s)
ftp> close
```
