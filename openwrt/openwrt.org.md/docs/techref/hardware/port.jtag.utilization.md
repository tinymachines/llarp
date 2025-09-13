# JTAG utilization

JTAG stands for [Joint Test Action Group](https://en.wikipedia.org/wiki/Joint%20Test%20Action%20Group "https://en.wikipedia.org/wiki/Joint Test Action Group"), which is an [IEEE](https://en.wikipedia.org/wiki/Institute%20of%20Electrical%20and%20Electronics%20Engineers "https://en.wikipedia.org/wiki/Institute of Electrical and Electronics Engineers") work group defining an electrical interface for [integrated circuit](/docs/techref/hardware/ic "docs:techref:hardware:ic") ***testing*** and ***programming***.

- → [port.jtag](/docs/techref/hardware/port.jtag "docs:techref:hardware:port.jtag") (this article)
  
  - → [port.jtag.cables](/docs/techref/hardware/port.jtag.cables "docs:techref:hardware:port.jtag.cables") (homemade cables)
  - → [port.jtag.cable.buffered](/docs/techref/hardware/port.jtag.cable.buffered "docs:techref:hardware:port.jtag.cable.buffered")
  - → [port.jtag.cable.unbuffered](/docs/techref/hardware/port.jtag.cable.unbuffered "docs:techref:hardware:port.jtag.cable.unbuffered")
- → [port.jtag.utilization](/docs/techref/hardware/port.jtag.utilization "docs:techref:hardware:port.jtag.utilization")/instruction/usage (in addition to the YouTube Videos ![;-)](/lib/images/smileys/wink.svg)
  
  - → [generic.debrick](/docs/guide-user/troubleshooting/generic.debrick "docs:guide-user:troubleshooting:generic.debrick") there is content on utilizing JTAG (link to it or from it, don't leave double content!)
  - → [jtag](/toh/davolink/dv-201amr#jtag "toh:davolink:dv-201amr") there is content on utilizing JTAG (link to it or from it, don't leave double content! unless specific)

## Tutorials

**Cleanup Required!**  
This page or section needs cleanup. You can edit this page to fix wiki markup, redundant content or outdated information.

⇒ Find better Videos or make one yourself!

- [YouTube JTAG](http://www.youtube.com/results?search_query=JTAG%20-xbox&aq=f "http://www.youtube.com/results?search_query=JTAG+-xbox&aq=f") don't forget to check YouTube. There are videos on using JTAG
- [JTAG Training Video: "SPI Flash Programming"](http://www.youtube.com/watch?v=iKmq823GpDE&feature=related "http://www.youtube.com/watch?v=iKmq823GpDE&feature=related")
- [JTAG Training Video: "Troubleshooting Your Own Own Designs"](http://www.youtube.com/watch?v=FayCU_tZvvk&feature=autoplay&list=PL78E7A976E7A97787&index=16&playnext=2 "http://www.youtube.com/watch?v=FayCU_tZvvk&feature=autoplay&list=PL78E7A976E7A97787&index=16&playnext=2")

### Docs

→[http://openocd.berlios.de/web/](http://openocd.berlios.de/web/ "http://openocd.berlios.de/web/")

### Using a Buffered Cable with the De-Brick Utility

**Cleanup Required!**  
This page or section needs cleanup. You can edit this page to fix wiki markup, redundant content or outdated information.

⇒ this needs to be rewritten, maybe use content from here:

- → [generic.debrick](/docs/guide-user/troubleshooting/generic.debrick "docs:guide-user:troubleshooting:generic.debrick") there is content on utilizing JTAG (link to it or from it, don't leave double content!)
- → [jtag](/toh/davolink/dv-201amr#jtag "toh:davolink:dv-201amr") there is content on utilizing JTAG (link to it or from it, don't leave double content! unless specific)

Inside the zip file download for the *Hairydairymaid WRT54G Debrick Utility v48* there is a PDF file that describes the software and how to use it. He specifically talks about using an unbuffered cable and pointedly notes that the cable he uses does **not** tie pin 1 of the JTAG header to anything.

That's all well and good for an unbuffered cable, but if you *do* happen to have a buffered Wiggler-style cable then you *will* have to deal with the nTRST signal. The Hairydairymaid software doesn't account for that signal line since the recommended cable doesn't carry it, but your Wiggler-style cable *does* use that signal and the debrick utility will *not* work out-of-the-box with a Wiggler-style cable as a result. The reason for this is because the software leaves the output for the nTRST line at logic-level 0, which means the signal coming out of your cable to the JTAG header will always be asserted, and as a result the JTAG circuitry inside your router will forever be resetting itself.

Hairydairymaid notes in one of his files (wrt54g.h) that there are a few changes to make if you're using a Wiggler-style buffered cable, but those changes alone are not enough. In order to use a Wiggler-style cable with the debrick utility there are a couple of other changes you will need to make.

First and foremost is an external voltage supply. Vcc from the Linksys board must be brought to the Wiggler interface. Usually this means an extra jumper wire in addition to the 14-connector ribbon cable. Note that if your Wiggler cable has a 14-pin connector that pins 13 and 14 in it will not be connected to anything on the Linksys board. Pins 1 through 12 correspond properly to the signals on the 12-pin Linksys JTAG header, but positions 13 and 14 will not be connected to anything at all. On most Linksys routers there is another connector near the JTAG header that can be used to connect two serial ports to the router. This is typically a 10-pin header and, fortunately for us, pins 1 and 2 of this serial port header carry Vcc at 3.3 volts. This is perfect, and all that needs to be done is to run a jumper wire from one of those pins into your homemade Wiggler circuit at any appropriate spot where Vcc is called for. If you build your own cable from Alec's schematic then you should know where those spots are. Alternatively, you could also run a short jumper from pin 1 or 2 of the serial port header to the open hole of the ribbon cable connector at position 14. That might actually be the best choice.

Second is the software. File 'wrt54g.c' must be modified so that logic-level 1 is always output to pin 1 of the JTAG header. Alternatively you could just not connect pin 1 to anything, but then your cable wouldn't be a true Wiggler clone anymore. Ensuring that nTRST is always a '1' will prevent the JTAG circuitry on your device from being in a constant state of 'reset'.

Another change to the software is not directly related to the cable per-se. Some have observed that certain Intel flash chips are not successfully erased by the debrick utility. I believe that is because there is a time delay that must be observed after commanding a block of flash memory to be erased that is not observed by the program. I had this problem, specifically, on a WRT54GS v2.1 router with an Intel StrataFlash 28F640J3 chip. The datasheet for this chip states that it may take up to 5 seconds for an “erase block” command to complete. The software should account for this delay.

The following patch file addresses the issues outlined above. It should be applied to version 4.5 of Hairydairymaid's de-brick utility. It modified both 'wrt54g.h' and 'wrt54g.c'. The changes are not that extreme and less than 35 lines altogether are modified (or added; no lines are deleted).

***\[NOTE by hairydairymaid - while this patch will not harm anything - it is not needed. Intel flash chips (and most others) have a built in “pin toggle” mechanism that fires when the specific write or erase has finished. Various flash chip erases/writes can and do take different times but waiting for that “pin toggle” is the proper way to account for things (not by just waiting x seconds) and it is exactly how the debrick utility operates and virtually all proper flashing routines are written. Use what works for you.]***

* * *

[debrick-wiggler.patch.gz](/_media/oldwiki/openwrtdocs/customizing/hardware/debrick-wiggler.patch.gz "oldwiki:openwrtdocs:customizing:hardware:debrick-wiggler.patch.gz (969 B)")

* * *

Please note that the above gzipped patch file uses Unix-style line endings. The de-brick utility source code files use DOS-style line endings. This shouldn't be a problem but if you gunzip the patch file and open it in a DOS or Windows editor it may look strange.

DanielGimpelevich sez: ***The above patch is preserved for posterity for reference ONLY. In the updated version by DanielDickinson above, you would simply append “/wiggler” to the command line to use a wiggler instead of a Xilinx. This is due to the following patch of mine that he applied to v48:***

```
--- wrt54g.c.orig	2006-09-17 16:27:34.000000000 -0700
+++ wrt54g.c	2007-10-26 19:10:52.640822951 -0700
@@ -446,7 +446,7 @@
    #endif

    data ^= 0x80;
-   data >>= TDO;
+   data >>= wiggler ? WTDO : TDO;
    data &= 1;

    return data;
```

## Summary

I was trying to revive a bricked Linksys WRT54GS one day and couldn't get Hairydairymaid's utility to work. I was on a Linux system and had other software called “jtag tools” which I obtained from the [openwince JTAG site](http://openwince.sourceforge.net/jtag/ "http://openwince.sourceforge.net/jtag/"). That program was able to detect the BCM4712 processor inside my router. The de-brick utility, however, kept telling me that my cable was bad. I knew the cable was not the problem since jtag tools was working flawlessly and a couple of days worth of investigation led me to the solution I have presented here. After I tweaked the de-brick utility source code I was able to successfully re-flash my WRT54GS router.

Personally, as an engineer, I prefer the buffered cable and would not use an unbuffered cable even though hundreds of other people have used them without any problems. A Wiggler-style cable can also be used for other devices that adhere to the JTAG specification. I'm not sure about the unbuffered type of cable. I hope this writeup will help anyone who has had trouble using a buffered JTAG cable and the Hairydairymaid software together, or who might want a cable that will almost certainly work with devices besides just Linksys routers.
