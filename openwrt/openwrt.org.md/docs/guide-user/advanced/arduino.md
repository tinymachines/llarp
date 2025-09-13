# Connect an Arduino to OpenWrt

An “Arduino” is an Atmel microcontroller, usually mounted on a board that exposes its pins for use in electronic projects, and programmed in “Arduino language” (which is C++ with some limitations) with a thriving software (library and projects) and hardware (expansion boards and clones) ecosystem around it.

To allow easy programming, Arduino boards provide a USB interface that allows the user to connect them with a USB port to their PC. This means either that the board has a serial-to-usb adapter, or that the microcontroller itself is faking a serial-over-USB connection (which is perfectly possible for midrange and higher Arduinos).

An Openwrt device with a USB port can be connected to an Arduino too, you just need to install usb-to-serial kernel modules.

Please install the following packages (with “**opkg install**” if you are with terminal or with LuCi **Software** page)

**kmod-usb-serial kmod-usb-serial-ark3116 kmod-usb-serial-belkin kmod-usb-serial-ch341 kmod-usb-serial-cp210x kmod-usb-serial-ftdi kmod-usb-serial-mct kmod-usb-serial-mos7720 kmod-usb-serial-oti6858 kmod-usb-serial-pl2303 kmod-usb-acm kmod-usb-serial-simple kmod-usb-serial-ti-usb**

In practice you will probably need only one of these if you can identify what is the usb-to-serial chip used in your arduino (or clone). They don't need much space anyway, so if you are unsure or lazy you can just install all.

After the installation of the packages, connect the Arduino to the USB port, then write **dmesg** to see if it was detected, and what is the serial device assigned to it (usually /dev/ttyUSB0 if you have only one Arduino connected)

## Direct control through a serial terminal

If you want to open a serial “terminal” to the Arduino from within the OpenWrt terminal, you will need to install a terminal emulator in the OpenWrt device.

**screen picocom minicom** are some of the terminal emulators you can install in OpenWrt

for example, let's install picocom with opkg install picocom

and then start the terminal with

**picocom -b 115200 /dev/ttyUSB0**

Now all you write in the terminal will be sent to the Arduino directly and you will see its answers on screen. This of course assumes that the Arduino is running a program that allows it to read from serial and react some way.

The command to exit from picocom and return to your OpenWrt device command line is **Ctrl + a**.

## Script-friendly control methods

If you just want to send commands to an Arduino (like through a script)

hexadecimal  
**echo -e “\\x7E\\x03\\xD0\\xAF” &gt; /dev/ttyUSB0**

text  
**echo -e “hello world” &gt; /dev/ttyUSB0**

If you want to read its answers do a

**cat /dev/ttyUSB0**

## Other Possibilities

**Router-builtin-UART&lt;&gt;GPIO(non-usb-serial)**

For limited usage, especially on routers without USB connections, limited interaction is possible over the routers UART port. This can be achieved using custom message headers and acknowledgement logic. Be prepared to write lots of uC code if you choose this route... and be realistic about the limitations...

**USB-UART-TTL-DEVICE/SIMILAR&lt;&gt;GPIO(non-usb-serial)**

Similar to the above but isolated from console output making message passing much cleaner.

**telnet&lt;&gt;ESP8266&lt;&gt;GPIO(non-usb-serial)**

Using a network serial “bridge” access arduino serial pins.
