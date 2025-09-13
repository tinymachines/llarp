# Send SMS from Shell

Sending SMS can be accomplish via shell with AT commands, thus we can automated sending SMS with shell script.  
Ref: [Send SMS using AT commands](http://www.smssolutions.net/tutorials/gsm/sendsmsat/ "http://www.smssolutions.net/tutorials/gsm/sendsmsat/")

### Using AT commands from shell

Just using shell you can send SMS, I think any modem would work altough I can't verify it because I don't have much modem lying around. By using AT commands, basic modem functionality will be utilized, so no need 3G driver and functionality.

Basically, sequence for send SMS as below:

```
# determine device modem, we use /dev/ttyUSB0 for this example
echo -e "ATZ\r" >/dev/ttyUSB0 # we need echo parameter -e for interpretation of backslash escapes
echo -e "AT+CMGF=1\r" >/dev/ttyUSB0
echo -e "AT+CMGS=\"123456789\"" >/dev/ttyUSB0 # change 123456789 with SMS destination number
echo -e "Hello this is SMS message from shell\x1A" >/dev/ttyUSB0 # message must be ending with \x1A (ASCII for CTRL+Z)
```

That's it, SMS should be recieve shortly.

### Script for sending SMS

Because SMS can sent from shell, if need it we can automating this process with shell script. Below is a sample to send SMS with shell script:

```
#!/bin/sh
 
# Modem device
DEV=/dev/ttyUSB0
# Destination mumber
DESTNUM="123456789"
# Message
SMS="Hi, there"
 
# we need to put sleep 1 to slow down commands for modem to process
echo -e "ATZ\r" >$DEV
sleep 1
echo -e "AT+CMGF=1\r" >$DEV
sleep 1
echo -e "AT+CMGS=\"$DESTNUM\"\r" >$DEV
sleep 1
echo -e "$SMS\x1A" >$DEV
```
