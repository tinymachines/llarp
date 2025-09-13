# Ubiquiti TFTP recovery

*NOTES &amp; REQUIREMENTS:*

- A narrow tool to press down reset button (like a paper clip)
- An Ethernet cable
- TFTP client running on PC

Take note of what airOS firmware the device was running. You will have to use that same firmware for TFTP and once recovered, perform a regular upgrade via the WebUI to the latest airOS firmware. The firmware used is dependent on:

1. The firmware compatible with the product, be it a M or AC model.
2. The version (as stated, you will need to first upgrade to the same firmware the device had).

**Introduction**

By reloading fresh firmware to restore the device, this process can also be useful to recover devices that have appeared to fail when no other solution is working.

WARNING: Do not switch off, reboot or disconnect the device from the power supply during the firmware upgrade process, as these actions will damage the device.

***Steps**: Recovery Procedure for Windows*

1. Power off the device.
2. Configure your computer: Windows PC's Ethernet must be configured manually with the following settings (under Network Connections):  
   IP Address: `192.168.1.254`, Subnet Mask : `255.255.255.0`
3. Connect your device to the PC.
4. Press the reset button on the device. While holding the reset button down, power the unit on. Wait 8 seconds then release the button (if you want to reset the unit to factory defaults, wait about 15 seconds or until the signal LEDs light up to indicate that the device is ready for recovery).
5. For airCubes (ISP and AC) and AirGateway: Push reset button and hold while powering unit. LED panel should blink fast several times, continue holding the reset button and the LED should turn off. Now you can release the reset button and the LED will flash slowly three times.
6. Make sure that the device responds to pings (perform a ping 192.168.1.20 from a DOS window), if it does not, go back to the first step and repeat.
7. Upload firmware image file (.bin) to 192.168.1.20, using a TFTP client software (binary mode). Windows integrated command line TFTP client or download a third party utility to upload the airOS firmware. Below are two alternatives:
   
   - Method 1:
     
     1. From the Windows PC, you can use TFTP command line from a DOS window (START&gt;&gt;&gt;CMD)
     2. Go into the same directory structure as the firmware (e.g., assuming that you have stored the image files in c:\\firmware directory, type the command :cd c:\\firmware) and enter the following (for help type TFTP -h) , e.g.:
        
        ```
        tftp -i 192.168.1.20 put WA.v8.5.0.36727.180118.1314.bin
        ```
   - Method 2: Download and execute tftp2 and configure it as below:  
     Server: `192.168.1.20`  
     File: Browse the firmware to upload
8. Signal LEDs will keep blinking one by one in 4 different colors during firmware upgrade. Wait for about 7-10 minutes (devices and firmware depending). Remember to not power off the device during the procedure.
9. Once the device is back online, remember to upgrade to the latest airOS firmware via the WebUI and the IP 192.168.1.20

***Steps**: Recovery Procedure for Linux*

1. Power off the device
2. Connect in fast ethernet mode (100Mbit) to the LAN side at the power adapter. This can be done using a 4 wires ethernet cable, or with a fast ethernet switch in between. This isn't strictly neccesary, but on some devices the Gigabit mode could fail.
3. Press the reset button on the device. While holding the reset button down, power the unit on. Wait 8 seconds then release the button (if you want to reset the unit to factory defaults, wait about 15 seconds or until the signal LEDs light up to indicate that the device is ready for recovery).
4. Check if the device entered the recovery mode, with the signal strength leds flashing in an alternating pattern.
5. Ping to `192.168.1.20`, just to be sure you have connectivity
6. Using TFTP client you can then upload signed firmware. Send the Ubiquiti **exact** version number you used previously to flash OpenWrt.
   
   - In a Linux OS execute these commands:
     
     ```
     tftp 192.168.1.20
     tftp> binary
     tftp> trace
     tftp> put WA.v8.5.0.36727.180118.1314.bin
     ```
7. Signal LEDs will keep blinking one by one with a particular patern depending on the device. Wait some minutes until it finish. Remember to not power off the device during the procedure.

Original Guide:

[https://help.ubnt.com/hc/en-us/articles/204911324-airMAX-How-to-Reset-Your-Device-with-TFTP-Firmware-Recovery](https://help.ubnt.com/hc/en-us/articles/204911324-airMAX-How-to-Reset-Your-Device-with-TFTP-Firmware-Recovery "https://help.ubnt.com/hc/en-us/articles/204911324-airMAX-How-to-Reset-Your-Device-with-TFTP-Firmware-Recovery")
