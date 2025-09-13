# Send SMS or Email using 3G/GSM modem

This method is fairly simple-minded, and uses only the serial /dev/ttyUSB0 port and “AT” commands to send an SMS message.

Almost any OpenWrt version should work, and any OpenWrt device which supports USB. It has been tested n a WL-500gPv2, a WL-520Gu, and a MPR-A8 (Ralink-based Hame A1 clone).

One modem was from dx.com, 7.2M HSDPA 3G SIM Card USB 2.0 Wireless Modem Adapter with TF Card Slot, item 80032. This is a Huawei E169 clone.

If you have device like WL-520Gu that has little onboard flash then you need to built my own OpenWrt firmware image with following modules (usually installing them via opkg installing fails due to for lack of memory):

```
kmod-usb2 kmod-usb-ohci kmod-usb-serial kmod-usb-serial-option usbutils usb-modeswitch kmod-usb-storage kmod-scsi-core kmod-scsi-cdrom kmod-scsi-generic picocom
```

When I plugged in the usb modem, it detected scsi drives and 4 tty devices--/dev/ttyUSB0 through ttyUSB3.

I connected to the modem using picocom: picocom -b 9600 -f n -p n -d 8 -r /dev/ttyUSB0

Typing “AT&lt;Enter&gt;” got the response, “OK”

I then sent a message with the following commands:

```
AT+CMGF=1 [set pdu mode to text]
AT+CMGS="+12345678900"  [use a valid cell phone number]
Type some message<Ctrl-z> [type a message terminated with <Ctrl-z>]
```

After a short while I got a response, “+CMGS: 18”

That was all there was to it with this device.

**Mode Switching**

With the WL-500gPv2 it was harder. The ttyUSB devices were not detected. This is because many (most?) cell modems initiate as scsi devices, which, in Windows, automatically load a driver and then switches mode to enable the modem. In linux, you have to perform the mode switch. There's a program for that, usb-modeswitch, and also usb-modeswitch-data. On the WL-500gPv2, I needed to use lsusb (from usbutils) to get the Vendor # and product ID. You then execute “usb-modeswitch -v nnnn -p nnnn”. After doing this, dmesg showed the ttyUSB devices 0-3, and I was able to proceed as above.

The modeswitch process can apparently be more complicated for other devices. Various web sites explain it.

**MPR-A8--modeswitch not needed**

With the MPR-A8, with self-compiled trunk, watching on serial console, the scsi drives were recognized first, and then, after 30m seconds or so, the 4 ttyUSB devices. I again signed on to /dev/ttyUSB0 (with microcom), and sent an SMS message using the commands shown above.

**Sending Email**

With my provider, T-Mobile, you can also send an email with the address number of “500” with these commands (after “AT+CMGF=1”):

```
AT+CMGS="500"
myAddress@myProvider.com/Subject2/sending text.<Ctrl+z>
```

The subject is within “/” or “#”.
