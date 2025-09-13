# Serial Console

## Overview

Most people get along without a serial console for their device because they're able to flash a working firmware the first time - or are able to apply various recovery methods - and do all their communicating with the device over a network. However, some bootloaders don't have a *“really* failsafe” network re-flash feature, making a serial console one of the few ways to recover from a “bad flash” or an error in a user's own configuration.

Most devices supported by OpenWrt have or can be modified to have a serial port. These serial ports typically provide a console to the bootloader and, when the firmware has booted, a console to the running system. A console to the running system will let you correct a misconfigured network, for example. Console access to the bootloader will often allow one to fetch and flash new firmware and may be the only way to do so on some routers if the firmware is not functional.

Enabling a serial port, if there is not one already available on the case, typically involves opening the case and basic soldering skills. The cost of components is relatively low; a 10-euro/dollar project if one uses “eBay-grade” parts (which are likely sufficient). If one wishes a more permanent installation, mechanical skills in modifying the case may also be needed.

## About a Serial Port

Most routers come with an [UART](https://en.wikipedia.org/wiki/Universal%20asynchronous%20receiver/transmitter "https://en.wikipedia.org/wiki/Universal asynchronous receiver/transmitter") integrated into the [System-on-chip](/docs/techref/hardware/soc "docs:techref:hardware:soc") and its pins are routed on the [Printed Circuit Board (PCB)](https://en.wikipedia.org/wiki/Printed%20circuit%20board "https://en.wikipedia.org/wiki/Printed circuit board") to allow debugging, firmware replacement or serial device connection (like modems).

Typically, a router first starts its “permanent” [bootloader](/docs/techref/bootloader "docs:techref:bootloader") which is responsible for the first steps of finding the OpenWrt firmware and starting OpenWrt running. During these early phases, the bootloader often gives information over the serial port and can respond to its own set of commands. These commands are not “OpenWrt” commands, but ones pre-programmed into the bootloader. Details on these commands can often be found on the device-specific pages on the OpenWrt wiki.

Once OpenWrt starts running, it is generally possible to enter failsafe mode with a terminal program attached to the serial port. Either in failsafe mode, or with OpenWrt running in normal mode, it is generally possible to enter commands the same way one would if using ssh over a network. One advantage is that if you've somehow configured your router so that the network or ssh isn't working, you can still access your router to manage it.

While a functional serial port can't protect you from a damaged bootloader or other low-level problems, it can be used to resolve many user-configuration errors, including, with luck, when the cat pulled the plug on your router as you were flashing it:-/

For low-level developers, or those that choose to flash their own bootloader, accessing the [JTAG](/docs/techref/hardware/port.jtag "docs:techref:hardware:port.jtag") port may be the next step, as the serial port requires functional software (either the bootloader or a running system) to be useful. JTAG access falls into the realm of expert use. It is mentioned here mainly as a reminder that flashing a bootloader, no matter how many have been successful before you, is a risky endeavor that a serial port may not allow recovery from errors.

- → [port.serial](/docs/techref/hardware/port.serial "docs:techref:hardware:port.serial") (this article)
  
  - → [port.serial.cables](/docs/techref/hardware/port.serial.cables "docs:techref:hardware:port.serial.cables") (homemade cables)
  - → [port.serial.utilization](/docs/techref/hardware/port.serial.utilization "docs:techref:hardware:port.serial.utilization")
    
    - → [generic.debrick](/docs/guide-user/troubleshooting/generic.debrick "docs:guide-user:troubleshooting:generic.debrick") there is content on utilizing JTAG (link to it or from it, don't leave double content!)
    - → [bootloader](/docs/techref/bootloader "docs:techref:bootloader")
    - → [uboot](/docs/techref/bootloader/uboot "docs:techref:bootloader:uboot")
    - → [uboot.config](/docs/techref/bootloader/uboot.config "docs:techref:bootloader:uboot.config")

**Cleanup Required!**  
This page or section needs cleanup. You can edit this page to fix wiki markup, redundant content or outdated information.

## Router Serial Connector Ports / Points

All [soc](/docs/techref/hardware/soc "docs:techref:hardware:soc")s have some sort of [UART](https://en.wikipedia.org/wiki/Universal%20asynchronous%20receiver/transmitter "https://en.wikipedia.org/wiki/Universal asynchronous receiver/transmitter"). Depending on the model, the device's serial port could be available

- as a 9-pin D connector accessible from the exterior of the case,
- as pin headers on the PCB,
- as unpopulated holes in the PCB.

For help with the latter two, see [soldering](/docs/techref/hardware/soldering "docs:techref:hardware:soldering"). But even if there is 9-pin D connector, beware the Voltage levels! While some may refer to this as an RS-232 or RS-422 interface, in most cases the voltage levels associated with those specifications are inappropriate and may permanently damage your router.

Also, in many modern devices you will only have 3-5 pins or holes, and that would be a TTL serial connection, requiring a TTL-USB dongle, which can be bought for real cheap from ebay or Amazon or any reputable DIY electronics seller as they are used to communicate with Arduino boards and other microcontroller-based IoT development boards.

Hint: In case of unpopulated holes in the shape of a SubD9, try fitting the pins from a disassembled SubD9 male plug into the holes instead of soldering the cable directly to the board. Fit perfectly on unbricked Asus and TP-Link routers and leaves no trace.

If the serial port is not readily accessible from the exterior of the device enclosure (which is common), you have some choices:

- modify the enclosure, either to allow passage of a cable or to attach a convenient connector, e.g.:
  
  - a 9-pin D connector (this is a good choice if you are going to build a level-shifter into the interior of the enclosure, so as to provide a standard +/- 12V interface externally);
  - a 1/8-inch stereo headphone jack (this is a good choice if you are simply bringing the lines to the exterior)
- open the case to attach to header pins or holes, as needed, this is a good choice if:
  
  - opening the enclosure is easy;
  - access to the serial port is needed only very occasionally; and/or
  - you have many devices you would rather not modify.

## Serial modes

Sometimes by shortcutting some pins, connecting them to ground or to power you can change the serial mode. Some of them can help you to restore the bootloader since they allow you to write directly to memory or load something to ram through the serial connection, which can be useful for restoring a bootloader. Also if the original bootloader is password protected with this method you can replace it with a custom bootloader and bypass it.

For example in [Lantiq Danube SoCs](/docs/techref/hardware/soc/soc.lantiq#boot "docs:techref:hardware:soc:soc.lantiq") the default mode is CFG 01, but changing to CFG 04 which is known as UART mode allows you to upload to ram through the serial connection and automatically execute a bootloader in ascii format through the serial connection.

It is recommended that you don't try blindly to shortcut or connect to anything the pins as it can brick the device. Find documentation before doing anything.

## Voltage levels

**Warning!**  
This section describes actions that might damage your device or firmware. Proceed with care!

![](/_media/meta/icons/tango/48px-dialog-warning.svg.png) **Caution:** Very few devices have standard [RS-232](https://en.wikipedia.org/wiki/RS-232 "https://en.wikipedia.org/wiki/RS-232") +/- 12V serial ports, but in many OpenWrt-supported devices the serial ports operate at TTL voltage (sometimes 5V, most often 3.3V) levels, meaning you cannot use a standard serial or USB to serial cable: it will fry your board. Buy a USB-TTL dongle instead, it will still show up as serial port in your computer, but it will be able to safely communicate with your OpenWrt device

In order for the serial console to work, the logic levels on the wires should match those expected by your device. The first step therefore is to determine which voltage levels are required. Often, you can find this documented on the OpenWrt wiki or elsewhere. If you can't determine the voltage based on a clear description in the OpenWrt page for your device or your own knowledge of electronics, you should probably stop here until you are reasonably certain of the voltage levels required.

In case your device is using a TTL connection or what seems to be a TTL connection, you can try to find out by trial and error, at the risk of burning the USB-TTL dongle or to damage the OpenWrt device.

Start by identifying the power wire (i.e. the wire carrying the 5V or 3.3 volt) and the ground pin with a multimeter on the 3-5 pin or holes in the board. The live pin should be labeled “1”, or “vcc” or have other signs that identify it as first pin.

You can then proceed to connect the ground pin to your dongle, and then try to connect the other two pins (data pins) randomly and trying different serial settings on your terminal.

Reversing Rx and Tx will not damage anything (it may will result in garbled text on your terminal), as long as the pins or holes are indeed a TTL port. If it is not a TTL port then you could probably damage your OpenWrt device, or (more commonly) burn the USB-TTL dongle.

**DO NOT connect the voltage output pin** (usually the 3.3 or 5V one) to your USB-TTL dongle as that could damage the dongle or device. It's not required by the vast majority of dongles (*except* optically or digitally isolated types which explicitly require voltage inputs “VIN” - these are rare and often expensive - if you're not sure, then you almost certainly don't have one of these) since they are USB-powered and typically have the input signal voltage levels fixed (usually at 3.3v) or selectable by a jumper on the adapter board.

### Multimeter method

#### Voltmeter

Use a voltmeter and measure voltages if board pin layout is unknown, for savety not damaging USB-TTL:

GNDto3.3V (VCC)→3.3V 3.3V (VCC)toRX→0.0V 3.3V (VCC)toTX→0.0V GNDtoRX→3.3V GNDtoTX→3.3V RXtoTX→0.0V

**FritzBox 7320****3.3V** (VCC)**RX****TX****GND** Boardsquarecirclecirclecircle [Siemens Data Cable (PL2303)](/docs/techref/hardware/port.serial.cables#prebuilt_cables "docs:techref:hardware:port.serial.cables")whiteblueblack

#### Ohmmeter

Electrical resistance between pins should be measured while the board is not powered.

Different hardware has different measured resistances between GND and other pins. However, there is often a common pattern as follows:

Smallest to Largest OhmRanges GND to GND 0 GND to VCC 5k ~ 200k GND to TX 8k ~ 2M GND to RX 10k ~ 8M

If you find something else, for example, that TX is shorted (0 Ohms) or that RX is open (OL = Open Line), this may mean that there is a resistor connecting a pin to GND that must be removed, or a resistor missing that is disconnecting the pin from the traces.

## Talking and Listening

You will need a terminal emulation program on your computer (aka: client-device), such as minicom, hyperterminal, etc to communicate with your router's serial port (aka: host-device's serial port) to talk-with &amp; listen-from router. This type of terminal emulation programs are also known as: communication tool/app. These communication terminal emulation programs need to be configured, to be compatible with your router (host-device), in particular, with regard to baud rate and flow control. If you are using only three wires (GND, TX, and RX) then hardware flow control should be turned off; you aren't using the pins (RTS and CTS) necessary for it to work. Rarely, the baud rate that the device expects *might* be different in the bootloader and the running firmware; if so, you'll need to modify the baud rate settings in your terminal emulator after the firmware boots up.

### Name of Serial Port/Device

Start a [shell](https://en.wikipedia.org/wiki/Comparison_of_command_shells "https://en.wikipedia.org/wiki/Comparison_of_command_shells") instance/program, in.example: [bash](https://en.wikipedia.org/wiki/Bash_%2528Unix_shell%2529 "https://en.wikipedia.org/wiki/Bash_%2528Unix_shell%2529") shell, inside any one of the [tab](https://en.wikipedia.org/wiki/Tab_%28interface%29 "https://en.wikipedia.org/wiki/Tab_(interface)") of your **shell manager** software (aka: [Terminal emulator](https://en.wikipedia.org/wiki/Terminal_emulator "https://en.wikipedia.org/wiki/Terminal_emulator") software, sometime aka: Command-line-interface([CLI](https://en.wikipedia.org/wiki/Command-line_interface "https://en.wikipedia.org/wiki/Command-line_interface")) software) provided by your operating system (aka: distro)**,** Or run your own preferred choice of shell inside your preferred choice of shell manager**.** Then run below command inside a shell.

- Example of few **shell manager** software / application**:** [GNOME Terminal](https://en.wikipedia.org/wiki/GNOME_Terminal "https://en.wikipedia.org/wiki/GNOME_Terminal") in GNU-Linux OS**,** [Xterm](https://en.wikipedia.org/wiki/Xterm "https://en.wikipedia.org/wiki/Xterm") in Unix OS (or GNU-Linux OS)**,** [Terminal](https://en.wikipedia.org/wiki/Terminal_%28macOS%29 "https://en.wikipedia.org/wiki/Terminal_(macOS)") in macOS**,** [Command Prompt](https://en.wikipedia.org/wiki/Command_prompt "https://en.wikipedia.org/wiki/Command_prompt") or [Command Console](https://en.wikipedia.org/wiki/Windows_Console "https://en.wikipedia.org/wiki/Windows_Console") in Windows OS**,** etc.
  
  - Note: as Windows do not support case-sensitive file-system, so options are: (1) create a case-sensitive file-system drive via Cygwin tools, &amp; use `bash` shell for it, or (2) run a Debian/Ubuntu/Fedora GNU-Linux inside/under a Windows-Sub-System-for-Linux, then inside that GNU-Linux you can use `GNOME Terminal` to do build related works.

To view list of all serial/TTY devices in GNU-Linux distros:[1](https://stackoverflow.com/questions/2530096/ "https://stackoverflow.com/questions/2530096/")

- ```
  ll /sys/class/tty
  ```
  
  - To view list of all USB based serial/TTY devices:
    
    ```
    ll /sys/class/tty/*/device/driver
    ```

To view list of all serial/TTY devices in macOS:[1](https://stackoverflow.com/questions/3815211/ "https://stackoverflow.com/questions/3815211/")

- ```
  ls /dev/{tty,cu}.*
  ```

Some GUI based terminal emulation software can also show all serial/parallel port list.

### Terminal emulation software

[Terminal emulation software](https://en.wikipedia.org/wiki/Terminal_emulator "https://en.wikipedia.org/wiki/Terminal_emulator") can interact with users via GUI[1](https://en.wikipedia.org/wiki/Graphical_user_interface "https://en.wikipedia.org/wiki/Graphical_user_interface"), TUI[1](https://en.wikipedia.org/wiki/Text-based_user_interface "https://en.wikipedia.org/wiki/Text-based_user_interface"), or CLI[1](https://en.wikipedia.org/wiki/Command-line_interface "https://en.wikipedia.org/wiki/Command-line_interface") interface. Some terminal emulator software are specially programed/developed, to allow us communicate with remote device/terminal or local device/terminal or responder, so also known as: **Communication tool**. Some of such specially developed (communication) software/tool/app has its own GUI interface, and some (communication) software/tool/app needs to run inside/under a running [shell](https://en.wikipedia.org/wiki/Comparison_of_command_shells "https://en.wikipedia.org/wiki/Comparison_of_command_shells").

**GNU-Linux/Posix:[1](https://en.wikipedia.org/wiki/POSIX "https://en.wikipedia.org/wiki/POSIX")**

- [screen](http://man.cx/screen "http://man.cx/screen"): the most simple, it runs inside a CLI shell. example command:
  
  ```
  screen /dev/ttyUSB0 115200
  ```
  
  sometimes needs manual configuration, try picocom or another software if you have any troubles
- [picocom](http://man.cx/picocom "http://man.cx/picocom"): it runs inside a CLI shell. example command:
  
  ```
  picocom -b 115200 /dev/ttyUSB0
  ```
  
  if you need to send uboot.asc files via serial. once connected you can open another terminal to send boot code as follows
  
  ```
  cat openwrt-lantiq-ram-u-boot.asc > /dev/ttyUSB0
  ```
- [CuteCom](https://gitlab.com/cutecom/cutecom "https://gitlab.com/cutecom/cutecom") with a friendly Qt5 GUI. Old Qt4 GUI → [CuteCom](http://cutecom.sourceforge.net/ "http://cutecom.sourceforge.net/")
- [Minicom](http://man.cx/Minicom "http://man.cx/Minicom") (for POSIX systems), it runs inside a CLI shell.
- [kermit](http://man.cx/kermit "http://man.cx/kermit"), a mature terminal emulator, it runs inside a CLI shell.
- [cu](http://man.cx/cu "http://man.cx/cu") (part of the Taylor UUCP package, for POSIX systems), it runs inside a CLI shell.
- [tio](https://github.com/tio/tio "https://github.com/tio/tio") (Mac and Linux) it runs inside a CLI shell.
- [Putty](http://www.chiark.greenend.org.uk/~sgtatham/putty/ "http://www.chiark.greenend.org.uk/~sgtatham/putty/"), uses both GUI &amp; CLI.

Under a Desktop OS Linux distro the access to the serial adapter requires root permissions. We can override this behavior by making an udev rule. Create the file `/etc/udev/rules.d/60-ttyUSBx.rules` with this content:

```
KERNEL=="ttyUSB[0-9]",              MODE="0666"
```

This way you can access to USB UART device as a normal user.

**Windows:**

- Hyperterm (comes with many versions of MS Windows)
- [Tera Term](https://es.osdn.net/projects/ttssh2/ "https://es.osdn.net/projects/ttssh2/")
- [Putty](http://www.chiark.greenend.org.uk/~sgtatham/putty/ "http://www.chiark.greenend.org.uk/~sgtatham/putty/") v0.59 or newer (now with serial console support!)
- [Bray's Terminal](https://sites.google.com/site/terminalbpp/ "https://sites.google.com/site/terminalbpp/")
- [Vandyke SecureCRT](http://www.vandyke.com/products/securecrt/ "http://www.vandyke.com/products/securecrt/") (commercial but very good)
- [Serial to Ethernet Connector](https://www.eltima.com/products/serial-over-ethernet/ "https://www.eltima.com/products/serial-over-ethernet/") (access remote COM port over Network)

**Other:**

- Pocketterm (for Palm PDAs)
- [GNU Screen](http://www.gnu.org/software/screen/ "http://www.gnu.org/software/screen/") (available on most OSes, including Windows (via cygwin[1](https://www.cygwin.com/ "https://www.cygwin.com/") pkg-mngr)) can connect to a serial device. The format is:
  
  ```
  screen {path to device} {baud rate},{options}
  ```
  
  A common set of options (for setting 8N1) is `cs8,-parenb,-cstopb`. For example, to connect to an Asus WL-520GU (115200 baud, 8N1) with a USB-serial adapter on OSX:
  
  ```
  screen /dev/tty.SLAB_USBtoUART 115200,-parenb,-cstopb,cs8
  ```
  
  The command on GNU-Linux is the same with a different device path. For other routers, you may need to adjust the speed and options.
- macOS has builtin posix compliant layer (aka: support), so CLI tool `Terminal` can run `screen`, `picocom`, etc communication tools mentioned above.
  
  - picocom performs better in macOS:
    
    - obtain it via `Macports`:
      
      ```
      sudo port install picocom
      ```

### Use your old PDA as a console

Since many older PDAs (e.g. Palm series) have TTL serial connections already, you can use them to get a direct serial connection to the router.

Solder the RX, TX, and ground (but **never** Vcc) TTL-level connectors on the OpenWrt box to the PDA's TTL level serial connectors.

Example: Palm IIIc, [http://www.neophob.com/serendipity/index.php?url=archives/121-Reuse-your-old-Palm-as-Serial-Console.html](http://www.neophob.com/serendipity/index.php?url=archives%2F121-Reuse-your-old-Palm-as-Serial-Console.html "http://www.neophob.com/serendipity/index.php?url=archives/121-Reuse-your-old-Palm-as-Serial-Console.html").

### Use another OpenWrt router as a console

First [disable the console](/docs/guide-user/hardware/terminate.console.on.serial "docs:guide-user:hardware:terminate.console.on.serial") in the router you want to use it as a serial console adapter and install screen in it. Connect to the target router the serial pins, and then execute screen in the first router:

```
screen /dev/ttyS0 115200
```

## Communicate with router

Communicate with router from your computer/device.  
Steps (in general)**:**

- Load driver software in your computer for the [serial cable/adapter](/docs/techref/hardware/port.serial.cables "docs:techref:hardware:port.serial.cables"), that you will be using for communication in between your host-device (in this case: your router) and client-device (in this case: your computer).
- In your computer, configure or re-verify your communication tool's settings**:** baud rate, data bits, flow-control, etc. Please read `Talking and Listening` section in above.
- Find out serial port's exact name in your client-device, that is, your computer. See `Name of Serial Port/Device` section in above to find out which command you can use.
- First boot-up the router, wait 30 seconds, then connect the serial cable[1](https://en.wikipedia.org/wiki/Serial_cable "https://en.wikipedia.org/wiki/Serial_cable")/adapter[1](https://en.wikipedia.org/wiki/Serial_communication "https://en.wikipedia.org/wiki/Serial_communication"). **Do not connect the `Vcc` or `V+` pin**. (Disconnect Vcc/V+ pin from serial cable/adapter's side). Connect only these 3 pins: `GND`, `TX`, `RX` pins[1](https://en.wikipedia.org/wiki/Universal_asynchronous_receiver-transmitter "https://en.wikipedia.org/wiki/Universal_asynchronous_receiver-transmitter"). Router's serial (UART) port's `TX` pin connection need to go into your serial cable/adapter's `RX` pin, and router's `RX` pin needs to be connected with `TX` pin of your serial cable/adapter, and router's `GND` pin connects with `GND` pin of serial cable/adapter. Your router will begin to prepare internal hardware configurations and then load an internal shell program inside the router, for serial interface/port communication.
- Run your preferred/choice of communication tool program (aka: Terminal emulation software, aka: Terminal software)[1](https://en.wikipedia.org/wiki/List_of_terminal_emulators "https://en.wikipedia.org/wiki/List_of_terminal_emulators") in your computer. Some communication tool needs to run inside a CLI or shell, you can use your OS/distro's shell-manager software (example: GNOME Terminal in GNU-Linux, Terminal in macOS, Xterm in Unix (or GNU-Linux), etc). Shell programs run under the shell-manager software. List of shell programs/tools are [here](https://en.wikipedia.org/wiki/Comparison_of_command_shells "https://en.wikipedia.org/wiki/Comparison_of_command_shells"). List of communication tools and commands are displayed few paragraphs above. More info on terminal emulators is [here](https://en.wikipedia.org/wiki/Terminal_emulator "https://en.wikipedia.org/wiki/Terminal_emulator").
- When you can view sensible alpha-numeric characters based output, (not garbled output), from your router (via serial cable/adapter connection) inside your communication tool program, and when your typed keys can appear inside communication tool (aka: Terminal emulation software), then that usually indicates connection's basic settings are correct &amp; working. If not, then we have to close existing connection session completely, do these**:** (1) exit out from communication tool program or close/terminate the tool, then (2) the USB-to-serial adapter or serial cable (which is connected with router), disconnect that from your computer, then (3) in some cases you may also need to close the (bash shell) tab inside the shell manager program, then (4) again start another instance of (bash shell) tab inside your OS/distro's shell-manager, and then (5) reconnect back USB-to-Serial adapter or serial cable, then (6) start another instance of communication tool with slightly-different settings, and (6) test again if/whether you can view sensible output from router, and test if your typed characters are appearing correctly inside the communication tool's screen. See `Troubleshooting` section / paragraph in below for more info.
- when your serial connection is apparently ok/working, then: remember the communication tool's command-line, write it down, and do not change connector-cable's pin connections in router's serial port, or in your serial cable/adapter.
- disconnect the power-plug from router or use the power-button in router to turn it off, without moving the router where you've placed it. Wait for about 15 seconds.
- if you disconnected serial adapter/cable then reconnect it back. Wait about 30 seconds, for your computer to enable serial adapter again.
- type the communication tool command-line that worked, to start the communication tool again with correct settings. Wait for about 2 to 5 seconds.
- start the router.
- now you will/should see (inside your communication tool's window) various output messages have began to appear or coming from router, coming via serial connection into your computer**:** your router will begin to send/output all activity data during boot-time, displaying all hardware configuration &amp; preparation &amp; basic initial test data, etc.
- Wait for about 2 minutes (120 seconds).
- and after above step, press ENTER button inside communication tool's window, then your router will usually start a [shell](https://en.wikipedia.org/wiki/Shell_%28computing%29 "https://en.wikipedia.org/wiki/Shell_(computing)") instance program inside the router, so you will see a shell interface prompt has appeared inside the communication tool program in your computer. **This is what we need**, to collect further detail data from the router, and to send/receive data/file into/from the router. Usually there is no login/signin prompt in serial connection. But if your router asks you to enter password/key, then enter admin/root user's password/key, or press just enter button, etc. Key-code/password can be saved in a file, and there is a command shown in above on how to send the (key/password) code from a file into the router, (via another tab in your shell-manager software).
- scroll upward in communication tool program in your computer, and copy all data output from the router, and save into a `filename.txt` or `filename.log.txt` file. Then run other commands inside communication tool window, which you need.

### Troubleshooting

#### Garbled output

If you get something like this during the bootcycle (output is garbled)

```
����������������������������������|� 2000-2008 Broadcom Corporation.
Init Arena
Init Devs.
This is ������������������?����������?����BCM4wXX�������������Ǉ����������0735750 - 0x80)
BSS:        0x80739790 -   0x80���4���������~�~������߇~����������������������������5.10
The boot is CFE
```

then probably the GND is not connected (soldered?) well. The router wont listen to any keyboard actions. After solving the problem output should look fine.

Another possible cause for the garbled output is wrong serial port speed, try different settings, most common ones are 9600, 38400 and 115200 bps.

#### Unable to send data

If you successfully receive router bootup logs but seem unable to send data (e.g. some keyboard input which might be required to intercept bootup, and where you're unable to stop continued kernel bootup), then this may be due to having configured the connection as hardware flow control rather than software (happened on TL-WDR3600 in my case).

## Physical Connection

### Router with USB port

For routers with a built in USB-connector (such as WNDR3700 for example), simply plugging in a USB-serial converter and installing the appropriate software will provide a serial console to the router.

- Install the appropriate packages, e.g. `kmod-usb-serial` and `kmod-usb-serial-ftdi` for FTDI based converters or `kmod-usb-serial-pl2303` for prolific based converters

<!--THE END-->

- Add the new serial port to /etc/inittab, (if you have multiple adaptors find the right one in /proc/tty/driver/usbserial):
  
  ```
  ttyUSB0::askfirst:/usr/libexec/login.sh
  ```

Be aware, using this method relies on the kernel loading the modules so will only work once OpenWrt is up and running. It won't bring you the possibility to use the bootloader console to reflash since the USB drivers on the router won't be running.

### Router with serial port / header / pins

In order to interact with your device over its serial port, you need a minimum of three wires connected: a ground (GND); transmit (TX); and receive (RX). It is possible to get useful information about what is happening with only GND and RX, but in order to fix a problem you will usually also need TX. Your computer's TX should be connected to the device's RX, and your computer's RX should be connected to the device's TX. The computer's GND should connect the the device's GND. That way, what you say will get heard by the device and what the device says will get heard by your computer. This is often called a “null-modem” configuration.

PC Router TX RX RX TX GND GND VCC **Do not connect VCC!**

Some things to consider:

- If your computer has a serial port, you can use a level-shifter (see below) and a “null-modem cable”.
- If your computer has a USB port, then:
  
  - if your device uses standard RS232 logic levels, you can use a standard USB-serial converter along with a standard “null-modem cable”
  - if your device uses 0/5V or 0/3.3V logic levels, you can use a USB-serial cable with a serial to TTL adaptor or a USB to TTL adapter (that use the right TTL voltage) and a connector suitably wired to connect to your device.
- If your computer has neither a serial port or a USB port, you are in trouble!

These days, computer manufacturers are dropping [RS232 serial ports](http://www.flexihub.com/serial-over-network.html "http://www.flexihub.com/serial-over-network.html"), while USB ports are increasingly ubiquitous. Particularly if you need to TTL logic levels, USB is probably the way to go since you can get the right logic levels (the voltage) integrated in the USB-TTL converter.

See [port.serial.cables](/docs/techref/hardware/port.serial.cables "docs:techref:hardware:port.serial.cables") for a variety of ways to make the physical connection from PC to router using homemade or commercial USB-serial and serial-serial cables.

## Serial port pinouts

Pinouts for your model can often be found on your model's devicepage, see [Table of Hardware](/toh/start "toh:start").

## Finding Serial Console

If the serial port pinout is not shown on your model's devicepage, do a Google search. Most of the time, the serial port(s), if they exist, have already been documented by others. If methods listed here are not enough for you, consider to go deeper reading [http://www.devttys0.com/2012/11/reverse-engineering-serial-ports/](http://www.devttys0.com/2012/11/reverse-engineering-serial-ports/ "http://www.devttys0.com/2012/11/reverse-engineering-serial-ports/")

Finding an UART on a router is fairly easy since it only needs 3 signals (without modem signaling) to work: GND, TX and RX (often accompanied by VCC). Try looking for a populated or unpopulated 4-pin header, which can be far from the SoC (signals are relatively slow) and usually with tracks on the top or bottom layer of the PCB, and connected to the TX and RX.

Once found, you can easily check where is the GND, which is connected to the same ground layer than the power connector. The VCC should be fixed at 3.3V and connected to the supply layer; the TX is also at 3.3V level, but using a multimeter as an ohm-meter, if you find an infinite resistance between the TX and VCC pins, it means they're distinct signals (else, you'll need to find the correct TX or VCC pin). The RX and GND are by default at 0V, so you can check them using the same technique.

If you don't have a multimeter, a simple trick that usually works is using a speaker or a LED to determine the 3.3V signals. Additionally, most PCB designers will draw a square pad to indicate pin number 1.

Since your router is very likely to have its I/O pins working at 3.3V ([TTL](https://en.wikipedia.org/wiki/Transistor%E2%80%93transistor%20logic "https://en.wikipedia.org/wiki/Transistor–transistor logic") level voltage), you'll need [usb.to.rs232.ttl.converter.module](/docs/techref/hardware/port.serial#usbtors232ttlconvertermodule "docs:techref:hardware:port.serial") or a level shifter such as a Maxim MAX232 to change the level from 3.3V to your computer level which is usually at 12V.

Once the correct pins are found, just interface your level shifter with the device, and the serial port on the PC on the other side. Most common baud rates for the off-the-shelf devices are 9600, 38400 and 115200 with 8-bits data, no parity, 1-bit stop.

### Piezoelectric buzzer method

1. Use a Piezoelectric buzzer and attach its ground (usually black) wire to a ground point on the router; the back of the power regulators are usually good candidates, but check this with a multimeter/voltmeter.
2. Use the other wire to probe any of the header pins which may be pre-installed, or any of the component holes which look like they could have header pins installed into (typically in a row of 4 pins for a serial port). Reset the router. The bootloader/linux bootup messages will only happen for a few seconds, and after that, the serial console will be silent - so even if you have the right pin you will not hear anything.
3. Once you get the right pin, the Piezoelectric buzzer should make a screeching sound much like that of a 56kbps connection.

### Digital multimeter method

Typically there are four pins to identify: GND - Ground, Vcc - 3.3VDC or 5VDC, TXD - Transmit data, and RXD - Receive data. There may be additional/extra pins. Every router is different.

1. Locate the set of four/five/more pins that are most likely to be the serial console.
2. Set the multimeter to measure resistance/continuity. Place the black probe on a known ground point and use the red probe to check each of the pins. Whenever you see zero or nearly zero ohms resistance, that pin should be the GND connection.
3. Switch the multimeter to measure DC voltage on a scale greater than 10 but less than 100 volts. Meters vary, but you should be able to select a range greater than five volts. Place the black probe on the known ground point again, and with the router powered on, use the red probe to check the remaining pins of the port for steady 3.3V or 5V DC. When you find it, that pin is likely to be the VCC connection. Note however that on some routers RX and VCC both have same voltage. One suggestion on how to distinguish them is to power off your device, and switch to continuity test if you have it(so that your mm would emit audible beep on near-zero ohms). VCC pin usually has a capacitor and shorting them would result in a very short beep once. RX would not emit any beeps.
4. It's easiest to find the router's TXD pin first, because all the console output from the boot process appears there. Measuring DC V with multimeter would easily point to TX pin as on output it would irregularly drop from ~3.3 or ~5 as console output occurs. If booting is long and produces a lot of output it would be easy to notice that even with a cheap multimeter. Sometimes with a very brief output some multimeters' sampling points may come at the moments when there's no output so reboot it a few times to make sure. When you see an irregular drops, that's TX. Then you can connect the RXD pin of your level shifter to that router pin and re-start the router. You should have a terminal window connected to the serial port at the correct bitrate and parity, and you've connected the proper pin, you should see output data the router's startup process. If not, try another pin, restarting the router until you receive valid output. Now you've located the serial port TXD connection. Anyway router TX and VCC are really one of the simpliest to find.
5. The only pin remaining is RXD, where the serial port receives data from your terminal session. Connect the TXD pin of your level shifter to the remaining pin (or multiple pins) until you find the one that correctly echoes characters you type in your terminal session. Sometimes when your RX pin has VCC voltage you would want to introduce a ~1K resistor in series between router RX and TTL TX not to fry something.

### Logic analyzer/oscilloscope

A more accurate method would be to use either a logic analyzer or an oscilloscope, but these are expensive and for the basic task of locating a serial pin a little overkill. ![;-)](/lib/images/smileys/wink.svg)

## Serial port speed

If you want to change serial port speed read [this article](/docs/guide-user/hardware/serialbaudratespeed "docs:guide-user:hardware:serialbaudratespeed").

## Devices

The list of related devices: [serial](/tag/serial?do=showtag&tag=serial "tag:serial")
