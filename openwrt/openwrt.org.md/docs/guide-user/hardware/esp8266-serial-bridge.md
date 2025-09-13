# ESP8266 serial bridge

It is possible to export the serial TTL console of most routers through Wifi via those cheap ESP8266 serial2wifi modules.

[![](/_media/media/doc/howtos/esp8266-openwrt-glinet-wifi2serial.jpg?w=500&tok=091ec0)](/_detail/media/doc/howtos/esp8266-openwrt-glinet-wifi2serial.jpg?id=docs%3Aguide-user%3Ahardware%3Aesp8266-serial-bridge "media:doc:howtos:esp8266-openwrt-glinet-wifi2serial.jpg")

# Pinout

In this example, we use the ESP-12 module powered over a 5V USB cable. As the ESP8266 works in 3.3V, and most openwrt routers works on 3.3V TTL, it is not necessary to do any voltage conversion. You can then connect the GND, TX, RX pins of the ESP8266 to the GND, RX, TX of the router respectively. Alternatively, you could also suck the 3.3V power from on the fourth pin of the serial header, usually labelled VCC.

# Screenshots

You can connect to the web interface, unfortunately the console only allows you to view the output of the openwrt console, not to input anything:

[![](/_media/media/doc/howtos/esp8266-openwrt-glinet-wifi2serial-webconsole.jpg)](/_detail/media/doc/howtos/esp8266-openwrt-glinet-wifi2serial-webconsole.jpg?id=docs%3Aguide-user%3Ahardware%3Aesp8266-serial-bridge "media:doc:howtos:esp8266-openwrt-glinet-wifi2serial-webconsole.jpg")

For the input, you can telnet to the IP of the ESP8266 on port 23, via telnet or netcat or socat: [![](/_media/media/doc/howtos/esp8266-openwrt-glinet-wifi2serial-telnet.png)](/_detail/media/doc/howtos/esp8266-openwrt-glinet-wifi2serial-telnet.png?id=docs%3Aguide-user%3Ahardware%3Aesp8266-serial-bridge "media:doc:howtos:esp8266-openwrt-glinet-wifi2serial-telnet.png")

However, if you launch programs like “top”, you will have a hard time to exit, as CRTL-C does not seem to work.

# Firmware

The goal here is to document how to export serial consoles through the network with the ESP-LINK firmware.

[https://github.com/jeelabs/esp-link](https://github.com/jeelabs/esp-link "https://github.com/jeelabs/esp-link")

# Todo

- Document the flashing procedure of the ESP8266-ESP12
- Try some ESP01 modules (flashing was less easy as with the ESP12)
- Try some ESP05 modules to provide a reconfigurable tiny 4 pins adaptor with a simple PCB like the ModernDevice FTDI
- Try some RS232 with MAX232 chips for Cisco and other routers
- Add support for input through the web console
- HTTPS cloud console, ajaxterm or similar
- Control reset buttons on the router
- Ser2net export
- Take power from the VCC
- Crtl-c and go out of top?
- Add some multiplexer like 74HC4502 to handle multiple serial ports

# Links

- Zoobab ESP8266 bridge: [http://www.zoobab.com/esp8266-serial2wifi-bridge](http://www.zoobab.com/esp8266-serial2wifi-bridge "http://www.zoobab.com/esp8266-serial2wifi-bridge")
- ESP12E devkit (with an cp2102 usb): [https://github.com/nodemcu/nodemcu-devkit-v1.0](https://github.com/nodemcu/nodemcu-devkit-v1.0 "https://github.com/nodemcu/nodemcu-devkit-v1.0")
