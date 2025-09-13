**OEM installation using the TFTP method**

For installing the Openwrt firmware you will need to use the CFE serial console:

Connect a serial TTL cable to send commands to CFE via serial console software, for loading the firmware via TFTP.  
Start a TFTP server in your PC. Copy the firmware.bin file to the TFTP server's directory.  
Set the IP at your pc to 192.168.1.35 (or any compatible), and connect the ethernet cable to the router.  
Power ON the router, press any key in the serial console to break into the CFE command line interpreter.  
Execute the command: f 192.168.1.35:firmware.bin

This is a session of flashing via TFTP:

```
CFE> f 192.168.1.35:firmware.bin
Loading 192.168.1.35:firmware.bin ...
Finished loading 2686980 bytes

Flashing root file system and kernel at 0xb8020000: ............................................
*** Image flash done *** !
Resetting board...\0xff
```
