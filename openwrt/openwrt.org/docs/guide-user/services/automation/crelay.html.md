# Crelay

This software is intended to run on Linux systems to control USB relay cards from different manufacturers in a unified way. It provides several interfaces for controlling the relays locally or remotely via the network. The relays can be controlled by a human being via a device like smartphone or web browser, or directly by an intelligent device as used in the Internet of Things.

New relay cards support can be added by providing the cards driver code for detecting the card, reading and setting the relays. Currently the following relay cards are supported:

- Conrad USB 4-channel relay card, see Note 1 below
- Sainsmart USB 4/8-channel relay card, see Note 2 below
- HID API compatible relay cards (1/2/4/8 channel), Chinese USB relay cards, see below for some images of them.
- Sainsmart USB 16-channel relay control module
- Generic GPIO controlled relays, see Note 3 below

The used relay card is automatically detected. No complicated port or communication parameter settings required. Just plug in your card and play.

The following picture shows a high level view on the modular software architecture.

[![](/_media/docs/guide-user/services/automation/sw-architecture.png)](/_detail/docs/guide-user/services/automation/sw-architecture.png?id=docs%3Aguide-user%3Aservices%3Aautomation%3Acrelay "docs:guide-user:services:automation:sw-architecture.png")

## Features

- Command line mode and daemon mode with Web GUI
- Automatic detection of relay card
- Reading of current relay states
- Setting of new relay states
- Single pulse generation on relay contact
- HTTP API for external clients (e.g. Smartphone/tablet apps)
- Multiple relay card type support
- Support for configuration file with custom parameters
- Multiple cards support (command line interface only)

## Web GUI

The web GUI is accessible at port **8000** (by default), so if your device has IP **192.168.1.1**, you can access it by writing **192.168.1.1:8000** in your browser address bar.

[![](/_media/docs/guide-user/services/automation/crelay-screenshot1.png)](/_detail/docs/guide-user/services/automation/crelay-screenshot1.png?id=docs%3Aguide-user%3Aservices%3Aautomation%3Acrelay "docs:guide-user:services:automation:crelay-screenshot1.png") [![](/_media/docs/guide-user/services/automation/crelay-screenshot2.png)](/_detail/docs/guide-user/services/automation/crelay-screenshot2.png?id=docs%3Aguide-user%3Aservices%3Aautomation%3Acrelay "docs:guide-user:services:automation:crelay-screenshot2.png")

## Command line interface

```
$ crelay 
crelay, version 0.11

This utility provides a unified way of controlling different types of relay cards.
Currently supported relay cards:
  - Conrad USB 4-channel relay card
  - Sainsmart USB 4/8-channel relay card
  - HID API compatible relay card
  - Sainsmart USB-HID 16-channel relay card
  - Generic GPIO relays
The card which is detected first will be used, unless -s switch and a serial number is passed.

The program can be run in interactive (command line) mode or in daemon mode with
built-in web server.

Interactive mode:
    crelay [-s <serial number>] -i | [<relay number>] [ON|OFF]

       The state of any relay can be read or it can be changed to a new state.
       If only the relay number is provided then the current state is returned,
       otherwise the relays state is set to the new value provided as second parameter.
       The USB communication port is auto detected. The first compatible device
       found will be used, unless -s switch and a serial number is passed.

Daemon mode:
    crelay -d [<relay1_label> [<relay2_label> [<relay3_label> [<relay4_label>]]]] 

       In daemon mode the built-in web server will be started and the relays
       can be completely controlled via a Web browser GUI or HTTP API.
       Optionally a personal label for each relay can be supplied which will
       be displayed next to the relay name on the web page.

       To access the web interface point your Web browser to the following address:
       http://<my-ip-address>:8000

       To use the HTTP API send a POST or GET request from the client to this URL:
       http://<my-ip-address>:8000/gpio
```

## Configuration file (default)

Crelay isn't integrated in UCI, its configuration file can be found in **/etc/crelay.conf**

```
################################################
#
# crelay config file
#
# This file is read by crelay in daemon mode
# from /etc/crelay.conf
#
################################################

# HTTP server parameters
################################################
[HTTP server]
server_iface = 0.0.0.0    # listen interface IP address
#server_iface = 127.0.0.1 # to listen on localhost only
server_port  = 8000       # listen port
relay1_label = Device 1   # label for relay 1
relay2_label = Device 2   # label for relay 2
relay3_label = Device 3   # label for relay 3
relay4_label = Device 4   # label for relay 4
relay5_label = Device 5   # label for relay 5
relay6_label = Device 6   # label for relay 6
relay7_label = Device 7   # label for relay 7
relay8_label = Device 8   # label for relay 8

# GPIO driver parameters
################################################
[GPIO drv]
#num_relays = 8    # Number of GPIOs connected to relays (1 to 8)
#relay1_gpio_pin = 17   # GPIO pin for relay 1 (17 for RPi GPIO0)
#relay2_gpio_pin = 18   # GPIO pin for relay 2 (18 for RPi GPIO1)
#relay3_gpio_pin = 27   # GPIO pin for relay 3 (27 for RPi GPIO2)
#relay4_gpio_pin = 22   # GPIO pin for relay 4 (22 for RPi GPIO3)
#relay5_gpio_pin = 23   # GPIO pin for relay 5 (23 for RPi GPIO4)
#relay6_gpio_pin = 24   # GPIO pin for relay 6 (24 for RPi GPIO5)
#relay7_gpio_pin = 25   # GPIO pin for relay 7 (25 for RPi GPIO6)
#relay8_gpio_pin = 4    # GPIO pin for relay 8 ( 4 for RPi GPIO7)

# Sainsmart driver parameters
################################################
[Sainsmart drv]
num_relays = 4   # Number of relays on the Sainsmart card (4 or 8)
```

## HTTP API

An HTTP API is provided to access the server from external clients. This API is compatible with the PiRelay Android app. Therefore the app can be used on your Android phone to control crelay remotely.

Note: the author of this app seems to have removed the free version of the app from the Google Play Store (leaving only the PRO version). For this reason and the fact that PiRelay is not open source I am considering to develop a dedicated crelay Android app. This will use a more universal Json format based API. Any volunteers who want to contribute to this app are very welcome.

API url:

```
    ip_address[:port]/gpio
```

Method:

```
    POST or GET
```

- Reading relay states  
  Required Parameter: none

<!--THE END-->

- Setting relay state  
  Required Parameter:
  
  ```
  pin=[1|2|3|4], status=[0|1|2] where 0=off 1=on 2=pulse
  ```

Response from server:

```
    Relay 1:[0|1]
    Relay 2:[0|1]
    Relay 3:[0|1]
    Relay 4:[0|1]
```

## Source repository

[In this github repo](https://github.com/ondrej1024/crelay "https://github.com/ondrej1024/crelay") you find the source and the bugtracker for crelay.

## Images of chinese USB relays

These usb relays are pretty cheap and can be found on ebay. They all have an Atmel microcontroller onboard (Attiny or Atmega depending on number of relays), which does USB 1.1 emulation on 2 pins to receive commands and uses its other pins to control the relays.  
They are available in many sizes, from 1 to 8 relays. On smaller 1 and 2 channel boards there are 2 holes where you can solder wires or connectors for an auxiliary 5V power source, in case your device can't provide enough power to operate all relays through the USB port.  
The 4 and 8 relay boards have a normal barrel power socket and a contact block with screws for bare wires, as you can't operate all relays at the same time with only a USB 2.0 500mA power supply.

As all things chinese, they can have minor board differences (colors and layout) but most use the same firmware for the microcontroller, so they are plug-and-play.

Some sellers also list the protocol/commands or provide libraries/source to connect a software to their product, so if they are not supported out of the box by crelay, they can be added easily to it.

These devices were tested personally, and work out of the box:  
[![](/_media/docs/guide-user/services/automation/usb_relay.jpg?w=400&tok=0de63d)](/_detail/docs/guide-user/services/automation/usb_relay.jpg?id=docs%3Aguide-user%3Aservices%3Aautomation%3Acrelay "docs:guide-user:services:automation:usb_relay.jpg") [![](/_media/docs/guide-user/services/automation/usb_relay-side.jpg?w=400&tok=5aa365)](/_detail/docs/guide-user/services/automation/usb_relay-side.jpg?id=docs%3Aguide-user%3Aservices%3Aautomation%3Acrelay "docs:guide-user:services:automation:usb_relay-side.jpg") [![](/_media/docs/guide-user/services/automation/usb_relay_group.jpg?w=400&tok=cf63ef)](/_detail/docs/guide-user/services/automation/usb_relay_group.jpg?id=docs%3Aguide-user%3Aservices%3Aautomation%3Acrelay "docs:guide-user:services:automation:usb_relay_group.jpg")

They can be found on ebay by searching for “**usb relay 5V**”, and usually come from chinese sellers.  
The “usb delay relays” boards were not tested so I don't know if they work without adjustments.
