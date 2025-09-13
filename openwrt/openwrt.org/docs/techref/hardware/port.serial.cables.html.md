# Serial Cables

The most likely adapter you need is **USB-TTL serial adapter**, consumer routers with rs-232 ports are pretty rare

This page assumes you have identified a serial connector on the router that you want to connect to from the PC. Modern PCs will usually have only a USB port to use for serial connectivity, and the first part of the page discusses how to use this. Some PCs have a traditional, 'proper' 9-pin (or maybe even 25-pin) serial connector and the use of this is discussed later in the page.

See also [port.serial](/docs/techref/hardware/port.serial "docs:techref:hardware:port.serial") for information on making use of the connection, background information on serial port characteristics, etc.

Firstly:

**WARNING!:** Some people reported they fried their router connecting the voltage pins spite it isn't neccesary.  
**NEVER** connect voltage pins when using USB adapters unless you know what are you doing. Unless you need to power the device, you don't have to connect the voltage pins. And you usually don't need to power it this way - use the router power supply.

RS232 serial (usually somewhere around 13 V) will fry any TTL serial port instantly.

TTL serial levels (5 or 3.3 V) from an as-shipped adapter can quickly destroy it as well.

Always confirm that the adapter outputs no more than 3.3 V and never output negative voltage before connecting.

Note that 2.5 V logic and even lower levels are beginning to appear in consumer routers. Lower voltage logic can be destroyed by even a 3.3 V adapter.

In other words you usually only need to connect **GND**, **TX** and **RX** at a suitable level for the specific device in question. Checking the V+ (sometimes labeled Vcc or Vss) with a voltmeter is recommended if you are at all unsure of the voltage levels.

**Think and confirm** before assuming a physical connection is all you need!

## USB (PC) to Serial (Router)

This section is aimed at what hardware is needed to communicate from the USB port on a PC to a device (router or similar) that has a serial connector of some kind.

### Prebuilt Cables

TTL 5V, for example:

- [FTDI TTL-232R-5V](http://www.mouser.com/Search/ProductDetail.aspx?qs=OMDV80DKjRorBEBwmlJ4Pg%3D%3D "http://www.mouser.com/Search/ProductDetail.aspx?qs=OMDV80DKjRorBEBwmlJ4Pg%3d%3d")
- [FTDI TTL-232R-5V (£)](http://apple.clickandbuild.com/cnb/shop/ftdichip?productID=49&op=catalogue-product_info-null&prodCategoryID=47 "http://apple.clickandbuild.com/cnb/shop/ftdichip?productID=49&op=catalogue-product_info-null&prodCategoryID=47")
- [FTDI TTL-232R-AJ (£)](http://apple.clickandbuild.com/cnb/shop/ftdichip?productID=69&op=catalogue-product_info-null&prodCategoryID=47 "http://apple.clickandbuild.com/cnb/shop/ftdichip?productID=69&op=catalogue-product_info-null&prodCategoryID=47")
- [FTDI TTL-232R-WE (£)](http://apple.clickandbuild.com/cnb/shop/ftdichip?productID=67&op=catalogue-product_info-null&prodCategoryID=47 "http://apple.clickandbuild.com/cnb/shop/ftdichip?productID=67&op=catalogue-product_info-null&prodCategoryID=47")

TTL 3.3V, for example:

- [FTDI TTL-232R-3V3](http://www.mouser.com/Search/ProductDetail.aspx?R=TTL-232R-3V3virtualkey62130000virtualkey895-TTL-232R-3V3 "http://www.mouser.com/Search/ProductDetail.aspx?R=TTL-232R-3V3virtualkey62130000virtualkey895-TTL-232R-3V3")
- [FTDI TTL-232R-3V3 (£)](http://apple.clickandbuild.com/cnb/shop/ftdichip?productID=53&op=catalogue-product_info-null&prodCategoryID=47 "http://apple.clickandbuild.com/cnb/shop/ftdichip?productID=53&op=catalogue-product_info-null&prodCategoryID=47")
- [FTDI TTL-232R-3V3-AJ (£)](http://apple.clickandbuild.com/cnb/shop/ftdichip?productID=70&op=catalogue-product_info-null&prodCategoryID=47 "http://apple.clickandbuild.com/cnb/shop/ftdichip?productID=70&op=catalogue-product_info-null&prodCategoryID=47")
- [FTDI TTL-232R-3V3-WE (£)](http://apple.clickandbuild.com/cnb/shop/ftdichip?productID=68&op=catalogue-product_info-null&prodCategoryID=47 "http://apple.clickandbuild.com/cnb/shop/ftdichip?productID=68&op=catalogue-product_info-null&prodCategoryID=47")
- [FTDI's TTL-232R-RPi Raspberry Pi / 3.3v boards (£)](http://shop.clickandbuild.com/cnb/shop/ftdichip?op=catalogue-products-null&prodCategoryID=167&title=TTL-232R-RPi "http://shop.clickandbuild.com/cnb/shop/ftdichip?op=catalogue-products-null&prodCategoryID=167&title=TTL-232R-RPi")

You may need to rewire the terminals of the TTL cables to match your device pinout.

#### USB - Serial TTL Cable Reviews

[https://www.adafruit.com/products/70](https://www.adafruit.com/products/70 "https://www.adafruit.com/products/70") is a great serial cable. It's used for ttl level serial. If you have to solder to the board, it's probably ttl. If there is an actual serial port, then it's 12V serial. Different device!

#### PL2303 cables

Its a component of many cheap USB-TTL cables available on ebay. Prolific produces the PL-2303HX/PL-2303HX.D chip in different variants at least since 2002 ( [PL2303HX datasheet](http://www.stkaiser.de/anleitung/files/PL2303.pdf "http://www.stkaiser.de/anleitung/files/PL2303.pdf") , [PL2303HXD datasheet](http://www.prolific.com.tw/UserFiles/files/ds_pl2303HXD_v1_4_4.pdf "http://www.prolific.com.tw/UserFiles/files/ds_pl2303HXD_v1_4_4.pdf") ). There are different designt with unattached cables, 3 pin (no 3.3V / 5V ), 4 pin (likely 3.3V ) or more pins available. Connecting 3.3V/5V is not needed and can damage the board.

#### Use low cost cables with mechanical fixing

Drill hole and use wire straps and some hot glue for fixing the cable: (Zyxel NBG6617 used as example)

[![](/_media/media/1c.jpg?h=200&tok=45584b)](/_detail/media/1c.jpg?id=docs%3Atechref%3Ahardware%3Aport.serial.cables "media:1c.jpg") [![](/_media/media/2c.jpg?h=200&tok=bba662)](/_detail/media/2c.jpg?id=docs%3Atechref%3Ahardware%3Aport.serial.cables "media:2c.jpg") [![](/_media/media/3c.jpg?h=200&tok=f35556)](/_detail/media/3c.jpg?id=docs%3Atechref%3Ahardware%3Aport.serial.cables "media:3c.jpg") [![](/_media/media/4c.jpg?h=200&tok=c6dbad)](/_detail/media/4c.jpg?id=docs%3Atechref%3Ahardware%3Aport.serial.cables "media:4c.jpg") [![](/_media/media/5c.jpg?h=200&tok=113f61)](/_detail/media/5c.jpg?id=docs%3Atechref%3Ahardware%3Aport.serial.cables "media:5c.jpg")

### USB Serial Adapters

These things make it simple to connect a computer (USB port) to the serial pins on the router.

[![](/_media/media/doc/hardware/serial/usb_to_rs232.ttl.jpeg)](/_detail/media/doc/hardware/serial/usb_to_rs232.ttl.jpeg?id=docs%3Atechref%3Ahardware%3Aport.serial.cables "media:doc:hardware:serial:usb_to_rs232.ttl.jpeg")

They are usually shipped with four jumper cables. Try [Dealextreme SKU 81872](http://www.dealextreme.com/p/usb-to-uart-5-pin-cp2102-module-serial-converter-81872?item=20 "http://www.dealextreme.com/p/usb-to-uart-5-pin-cp2102-module-serial-converter-81872?item=20"). Or on [Amazon B009T2ZR6W](http://www.amazon.com/CP2102-Module-Download-Serial-Converter/dp/B009T2ZR6W/ "http://www.amazon.com/CP2102-Module-Download-Serial-Converter/dp/B009T2ZR6W/"). Or on ebay there are plenty of these cheap adapters.

Simply connect the jumper cables to the pins like this:

Router Converter module **GND** **GND** **TXD** **RXD** **RXD** **TXD**

**Please note** that some USB serial adapters (The CP2102-based one in the Amazon link above, for example) have the RX and TX connectors labelled according to what you should connect them to, not what they actually do. If connecting TX → RX and RX → TX doesn't work for you, try switching to TX → TX and RX → RX.

### Arduino Uno (REV3) as USB to serial cable

![](/_media/meta/icons/tango/48px-dialog-warning.svg.png) **Caution:** Do this at your own risk, since the Arduino runs at 5v and the serial sometimes is at a different voltage. Therefore, using the following technique may cause the router, Arduino, or other things, to malfunction or break. That said, this technique worked well for me during for lots of use (hours), with a [Linksys E1000 v1](/toh/linksys/e1000 "toh:linksys:e1000") at 3.3v, and an Arduino Uno REV3.

This method uses the Development board's built in USB to RS232 converter and results in 5V signals. This technique works since the Arduino Uno REV3 has a chip called the atmega16U2, which is a serial to USB converter, to talk to the computer; we use it here to talk to the router. So, other Arduinos may work. I was unable to get this to work with a Arduino nano Clone with the CH340 usb serial chip.

A PC typically communicates with an Arduino such as the Uno via a USB cable that enters the board via a chip that does USB - serial conversion to allow use of the microcontroller's serial interface. The outputs from this chip connect to the RX and TX pins on the microcontroller, and are generally suitable for use with other chips that operate at similar voltages.

#### Method A (reversible changes to Arduino board)

1. Remove the programmable IC
2. Connect the RX(0) and TX(1) and the development board ground through to the router/device.
3. Use software to talk to the router/device.
4. Replace the programmable IC

#### Method B (no physical changes to Arduino board)

1. An Arduino Uno REV3 (or clone with the atmega16u2)
2. Using a Jumper wire, connect the Reset Pin to Ground on the Arduino
3. Connect the RX(0) and TX(1) and the Arduino ground through to the router/device.
4. Use your favorite Serial capable program to talk to the router/device.

#### Method C (no physical changes to Arduino board)

1. An Arduino Uno REV3 (may work on other arduinos, but only tested on the above)
2. A router
3. A computer
4. A USB A-B cable (to use with the Arduino)

Upload [the Arduino Bare Minimum sample sketch](http://arduino.cc/en/Tutorial/BareMinimum "http://arduino.cc/en/Tutorial/BareMinimum") (consisting of empty setup() and loop() functions) to the Arduino.

#### Common

Remember, many devices will not need the Vcc to be connected, and connecting it when not needed may damage the router.

Then connect one end of the wires to the serial port / header and the other to the Arduino board:

- Connect the ground to the Arduino's ground
- Connect the TX and RX pins (digital 0 and 1 on a Uno, also labelled as TX and RX) of the Arduino to the RX and TX of the device.

The Arduino development environment is not needed; just use a regular serial terminal program using the USB Serial device that the Arduino drivers create.

If nothing is seen try switching TX and RX - it shouldn't break if reversed.

### Raspberry Pico as USB to serial cable

Using this board as a serial modem emulator can be a better match for most routers as it uses 3V pin signals. No user programming is required as an official loadable binary (UF2) for a tool called “picoprobe” (originally used to program micro processors) can be downloaded from raspberry's web page *(from the Software Utilities section of the Raspberry Pi Pico documentation page. Click on the Raspberry Pi Pico section, scroll down to Software Utilities, and download the UF2 under “Debugging using another Raspberry Pi Pico”)* Then you should only wire (and disregard other pins/functions) a GND Pin, Pin GP4 = UART1 TX and Pin GP5 = UART1 RX and you will be able to access our router serial port as per instructions described elsewhere in this document.

Further information about the tool can be found in the document “Getting started with Raspberry Pi Pico”

### Build or hack your own USB - Serial cable

#### USB-serial parts

If you want to solder:

- [Breakout Board for FT232RL USB to Serial](http://www.sparkfun.com/commerce/product_info.php?products_id=718 "http://www.sparkfun.com/commerce/product_info.php?products_id=718")
- [Breakout Board for CP2103 USB to Serial w/ GPIOs](http://www.sparkfun.com/commerce/product_info.php?products_id=199 "http://www.sparkfun.com/commerce/product_info.php?products_id=199").
- [FTDI TTL-232R-PCB (£)](http://apple.clickandbuild.com/cnb/shop/ftdichip?productID=71&op=catalogue-product_info-null&prodCategoryID=47 "http://apple.clickandbuild.com/cnb/shop/ftdichip?productID=71&op=catalogue-product_info-null&prodCategoryID=47")
- [FTDI TTL-232R-3V3-PCB (£)](http://apple.clickandbuild.com/cnb/shop/ftdichip?productID=72&op=catalogue-product_info-null&prodCategoryID=47 "http://apple.clickandbuild.com/cnb/shop/ftdichip?productID=72&op=catalogue-product_info-null&prodCategoryID=47")

#### Cellphone Data Cables

A USB based data cable for a mobile cell phone is another possibility.

Ebay clone cables:

- Datacable for Nokia 6210, 6250, 6310, 6310i, 7110

reference: [http://www.nslu2-linux.org/wiki/HowTo/AddASerialPort](http://www.nslu2-linux.org/wiki/HowTo/AddASerialPort "http://www.nslu2-linux.org/wiki/HowTo/AddASerialPort")

#### Data cable for Siemens cell phones

This kind of cable is really cheap. Only some €uros on ebay, because the phones are not built any more.

The cable should be compatible to one of these Siemens cell phones:  
A35 / A36 / A50 / C25 / C25 Power / C28 / C35i / C45 / M35i / M50 / ME45 / MT50 / S25 / S35i / S45 / S45i / SL42 / SL45 / SL45i

It's the well supported prolific pl2303 USB to serial converter. There are 4 lines coming from the USB part to the phone jack. You don't need the Vcc line.

pin function 1 GND 3 Vcc 5 Tx 6 Rx

[![](/_media/media/doc/hardware/serial/siemens_plug.jpg)](/_detail/media/doc/hardware/serial/siemens_plug.jpg?id=docs%3Atechref%3Ahardware%3Aport.serial.cables "media:doc:hardware:serial:siemens_plug.jpg")

[Mesh cube wiki page from archive.org](http://web.archive.org/web/20070820095200/http://www.meshcube.org/meshwiki/ModifiedMobileSerCable "http://web.archive.org/web/20070820095200/http://www.meshcube.org/meshwiki/ModifiedMobileSerCable")

## Serial (PC) - Serial (Router)

This section is aimed at what hardware is needed to communicate with a router or similar OpenWrt device that has a serial connector of some kind from the serial port on a PC.

### Level conversion

Proper serial RS232C ports operate at -12V (logical 1) and +12V (logical 0). Not only that's completely opposite of the usual logic signalling (+Vcc for 1 and -Vcc or 0 for 0) - that's also a lot higher than the 3.3V or 5V that a router is likely to need, and will easily cook the device if it's not protected - and you should always assume that it isn't!

TTL/RS-232 level conversion is a fairly common problem, so there are a number of ICs on the market that convert between these voltage levels (search for “RS-232 Drivers” or “RS-232 level converter”). [Maxim IC](http://www.maxim-ic.com "http://www.maxim-ic.com") has made a few handy little ICs for us to use - see [https://www.maximintegrated.com/en/datasheet/index.mvp/id/1798](https://www.maximintegrated.com/en/datasheet/index.mvp/id/1798 "https://www.maximintegrated.com/en/datasheet/index.mvp/id/1798").

### Prebuilt Cables

Standard RS232 levels, for example:

- [Zonet ZUC3100](http://www.zonetusa.com/products-132.aspx "http://www.zonetusa.com/products-132.aspx") uses pl2303 chip, well-supported in Linux
- [http://www.superdroidrobots.com/shop/item.aspx?itemid=335](http://www.superdroidrobots.com/shop/item.aspx?itemid=335 "http://www.superdroidrobots.com/shop/item.aspx?itemid=335")

### With MAX232x IC

First, you need an “RS232-TTL level converter chip.” RS232 refers to the standard defining what plugs into your computer, and TTL is a family of chips that use 0V and 0.8V as low and 2.2V and 5V as high. They can be purchased new (the [Maxim IC](http://www.maxim-ic.com "http://www.maxim-ic.com") MAX233x line is popular). Most vendors have large minimums, but some (e.g. [Mouser Electronics](http://mouser.com/ "http://mouser.com/")) sell components in small quantities.

The wiring is fairly simple, but it depends on the chip. Generally, it involves connecting Vcc from the router to the chip's Vcc pin, both router and RS-232 grounds to the ground pin, and the TX and RX wires to the chip. Remember that the router's TX will “connect” to the same level conversion bank as the computer's RX. Additionally, some of these level converters require external capacitors, while some have them built in. Much of this varies, so consult the chip's spec.

### With basic components

Some of the simplest ways to create a level converter is using discrete transistors (one is needed for each direction, so you need two for bidi communication).

This one, using MOSFETs, allows the completely minimal part count: 2x 2N7000, 1x 4K7 &amp; 100K resistors. That's all! (note that you can add additional gate pulldown for more stable operation)

[![](/lib/exe/fetch.php?tok=c9c4d2&media=http%3A%2F%2Fhomepage.hispeed.ch%2Fpeterfleury%2Fstarterkit-uart-mosfet.gif)](/lib/exe/fetch.php?tok=c9c4d2&media=http%3A%2F%2Fhomepage.hispeed.ch%2Fpeterfleury%2Fstarterkit-uart-mosfet.gif "http://homepage.hispeed.ch/peterfleury/starterkit-uart-mosfet.gif")

Another solution, using BJTs:

[![ttl_to_rs2320kf.jpg](/_media/media/doc/hardware/serial/ttl_to_rs2320kf.jpg "ttl_to_rs2320kf.jpg")](/_detail/media/doc/hardware/serial/ttl_to_rs2320kf.jpg?id=docs%3Atechref%3Ahardware%3Aport.serial.cables "media:doc:hardware:serial:ttl_to_rs2320kf.jpg")

Ensure that either the hardware handshake is disabled (flow control on PC set to either XON/XOFF or none) or the DTR signal at the PC end is asserted, otherwise nothing will be received by the PC from the router. For example, in the Bray terminal program click on the DTR icon to turn it green.

#### From a PDA or cell phone serial cable

Another great source for RS232-TTL converters is in cell phone serial cables. Most cell phones need this same circuit to level-up for connection to a PC's serial port. Many people already have such a cable laying around, or can buy one fairly cheap. Using an existing cable is much easier than building one. If you open up the cell phone cable's serial port casing and see a MAX### chip, it's probably the cable you need. One known chip is a MAX323 (yes, 323, the original MAX232 is a 5V device and we need 3.3V here).

If you've found a good cell phone cable to use, you merely need to determine which wires are the VCC, GND, TX, and RX connections. Usually the VCC is red and the GND is black, but the other colors may vary (though blue and orange are common). There should be no need to modify the PCB embedded in the cable.

One type of the “Made in China” ones, not mentioned at [http://www.nslu2-linux.org/wiki/HowTo/AddASerialPort](http://www.nslu2-linux.org/wiki/HowTo/AddASerialPort "http://www.nslu2-linux.org/wiki/HowTo/AddASerialPort") ist the “S30880-S5601-A802-1”; its WHITE wire is data out (TX) of the DTE (PC) and conntcts to the RX of the DCE (Router); the ORANGE one is data in (RX) of the DTE (PC) and conntcts to the TX of the DCE (Router), VCC and GND are red and black. Its a 3.3V converter built with the MAX3386E chip.

#### MAX232 Kits

You can also search for MAX232 Kits. There are some kits available.

- [http://shop.ebay.com/?\_nkw=rs232+ttl](http://shop.ebay.com/?_nkw=rs232%20ttl "http://shop.ebay.com/?_nkw=rs232+ttl")
- [http://www.elv-downloads.de/service/manuals/TTLRS232-Umsetzer/38439-TTLRS232-Umsetzer.pdf](http://www.elv-downloads.de/service/manuals/TTLRS232-Umsetzer/38439-TTLRS232-Umsetzer.pdf "http://www.elv-downloads.de/service/manuals/TTLRS232-Umsetzer/38439-TTLRS232-Umsetzer.pdf")
- [http://www.compsys1.com/workbench/On\_top\_of\_the\_Bench/Max233\_Adapter/max233\_adapter.html](http://www.compsys1.com/workbench/On_top_of_the_Bench/Max233_Adapter/max233_adapter.html "http://www.compsys1.com/workbench/On_top_of_the_Bench/Max233_Adapter/max233_adapter.html")
- [http://alldav.com/index.php?main\_page=product\_info&amp;cPath=9&amp;products\_id=11](http://alldav.com/index.php?main_page=product_info&cPath=9&products_id=11 "http://alldav.com/index.php?main_page=product_info&cPath=9&products_id=11")

These may be useful for connecting to a device:

- [http://shop1.frys.com/product/1599820](http://shop1.frys.com/product/1599820 "http://shop1.frys.com/product/1599820")

#### Model-specific guides

These guides are somewhat model specific, but if you're struggling to build your own cable, they're filled with information that applies to that part of the process.

- [WRT54G serial mod guide](http://jdc.parodius.com/wrt54g/serial.html "http://jdc.parodius.com/wrt54g/serial.html")
- [NSLU2 serial guide](http://www.nslu2-linux.org/wiki/HowTo/AddASerialPort "http://www.nslu2-linux.org/wiki/HowTo/AddASerialPort")
- [WRT54GS serial guide](http://www.rwhitby.net/wrt54gs/serial.html "http://www.rwhitby.net/wrt54gs/serial.html")
