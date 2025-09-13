# Unbuffered Cable, Xilinx DLC5 Cable III

This is the simplest type of JTAG cable, the easiest to construct and the cheapest to make. The original cable was introduced by Xilinx and has a full name “[Xilinx DLC5 JTAG Parallel Cable III](http://toolbox.xilinx.com/docsan/3_1i/pdf/docs/jtg/jtg.pdf "http://toolbox.xilinx.com/docsan/3_1i/pdf/docs/jtg/jtg.pdf")”. Someone removed a buffer and changed it with a four 100 Ohm resistor. Popularized by the Hairydairymaid de-brick utility software for Linksys routers, many people have successfully built their own unbuffered JTAG cable. It consists of only a few cheap resistors, a 25-pin parallel port connector and a ribbon-cable with a 12-pin connector that slides onto a header soldered onto the PCB found inside the cases of Linksys WRT54G and WRT54GS routers.

The chief limitation of this type of unbuffered cable is that it must be very short; **the length must be 15 cm or less** (6 inches) to avoid problems with electrical noise.

Note : you can safely replace 100 Ohm resistors with couples of 220 Ohm connected in parallel. 220 Ohm (Red-Red-Brown) is a much more frequent value found on electronic boards of recovery.

[![](/_media/doc/hardware/jtagunbufferedrouter.png)](/_detail/doc/hardware/jtagunbufferedrouter.png?id=docs%3Atechref%3Ahardware%3Aport.jtag.cable.unbuffered "doc:hardware:jtagunbufferedrouter.png") [![](/_media/doc/hardware/jtag-unbuf3.png)](/_detail/doc/hardware/jtag-unbuf3.png?id=docs%3Atechref%3Ahardware%3Aport.jtag.cable.unbuffered "doc:hardware:jtag-unbuf3.png") Added by RealOpty - I like the simplicity

JTAG-to-LPT mapping

```
 TDI  -  DATA0  - pin 2
 TDO  -  SELECT - pin 13
 TMS  -  DATA2  - pin 4
 TCK  -  DATA1  - pin 3
```

The Linksys WRT54G and WRT54GS routers are based on Broadcom CPUs which are a type of MIPS32 processor. Broadcom has implemented EJTAG version 2.0 in their chips. This allows the use of DMA transfers via JTAG which, while slow, is faster than the implementation of EJTAG v2.5 and v2.6 which do not support DMA transfers.
