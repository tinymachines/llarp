# Buffered Cable, Wiggler

This type of cable is a bit more complicated than the unbuffered one, although it is also fairly easy to construct. The cable most often used in this category is the so-called Wiggler cable. The Wiggler is a commercial cable sold by [Macraigor Systems](http://www.macraigor.com/wiggler.htm "http://www.macraigor.com/wiggler.htm"). With a list price of $150 USD they are not cheap. There is a schematic on the internet that is commonly accepted to be the equivalent of what's inside a Wiggler cable. This schematic, by [Alec](http://www.sensi.org/~alec/ "http://www.sensi.org/~alec/"), was drawn up for devices that implement a typical EJTAG header in devices based on the ADM5120 System-on-Chip, another design based on the MIPS32 architecture. The ADM5120 has support for EJTAG v2.6, which does *not* support DMA transfers.

[![](/_media/oldwiki/openwrtdocs/customizing/hardware/wiggler.png)](/_detail/oldwiki/openwrtdocs/customizing/hardware/wiggler.png?id=docs%3Atechref%3Ahardware%3Aport.jtag.cable.buffered "oldwiki:openwrtdocs:customizing:hardware:wiggler.png")

[![](/_media/oldwiki/openwrtdocs/customizing/hardware/jtag-wiggler-600x.jpg)](/_detail/oldwiki/openwrtdocs/customizing/hardware/jtag-wiggler-600x.jpg?id=docs%3Atechref%3Ahardware%3Aport.jtag.cable.buffered "oldwiki:openwrtdocs:customizing:hardware:jtag-wiggler-600x.jpg")

JTAG-to-LPT mapping

```
 TDI   - DATA3   - pin 5
 TDO   - BUSY    - pin 11
 TMS   - DATA1   - pin 3
 TCK   - DATA2   - pin 4
 nSRST - DATA0   - pin 2
 nTRST - DATA4   - pin 6
```

Whereas an unbuffered cable can be constructed for maybe $5 USD or less, the parts for a Wiggler-type cable will cost a little more, perhaps in the $15 to $30 USD range. The advantage of a buffered cable is that it is not as constrained as to length and is more immune to noise and static, thus permitting a higher data transfer rate.

This cable is fully compatible with Macraigor [OCD Commander](http://www.macraigor.com/ocd_cmd.htm "http://www.macraigor.com/ocd_cmd.htm"). The wire between DATA6 (pin 8 on the LPT DB-25) and ERROR (pin 15) is used to identify a presence of the Wiggler cable and required by some JTAG software (i.e. Macraigor). It may be omitted for Hairydairymaid debrick utility.

Another consideration is that a buffered Wiggler-style cable **requires** a voltage source to operate. Usually +3.3 volts is needed and is commonly referred to as Vcc (voltage common-collector is the traditional meaning of Vcc). The buffer IC may take a Vcc from the PC LPT also. The DATA7 pin may be used for this purposes, so Wiggler software should provide aclive “1” at this pin. Do not use this pin if your JTAG header provides Vcc.

The schematic is incomplete: You should not forget to tie pins 13, 15 and 17 to GND. They are inputs to unused buffers and should not be allowed to float.

Do not change 74**HC**244 (High-speed CMOS) series with another 74 type i.e. LS, ALS or LV. This HC series works fine from 2.6 V to 6.0V Vcc range. The decoupling capacitor should be preferably ceramic and about 0.1 micro Farad.

This used to say that “any” type was OK, even electrolytic and values up to 10 micro (in fact it said mili-farad!). Those have too large an equivalent series resistance and may cause difficult-to-diagnose problems. If you want to ADD an extra 10 micro Farad capacitor, go ahead, but use 0.1 micro F ceramic for the first one....

***\[Edit by fw\_crocodile: I had to insert a 100pF capacitor between clk and ground just after the buffer to avoid problem with DeBrick on a DG834]***

## Another wiggler schematic

[![](/_media/doc/hardware/wiggler_reduced.png?w=800&tok=08873a)](/_detail/doc/hardware/wiggler_reduced.png?id=docs%3Atechref%3Ahardware%3Aport.jtag.cable.buffered "doc:hardware:wiggler_reduced.png")

Example of implementation made with salvaged electronic junk:

[![](/_media/media/doc/hardware/jtag_wiggler_homemade.jpg?w=800&tok=84eb4f)](/_media/media/doc/hardware/jtag_wiggler_homemade.jpg "media:doc:hardware:jtag_wiggler_homemade.jpg")
