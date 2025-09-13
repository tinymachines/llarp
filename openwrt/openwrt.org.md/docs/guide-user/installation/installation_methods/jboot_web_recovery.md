# JBoot web recovery

Installation can be done via JBoot web recovery.

- Push and hold the reset button and turn on the power.
- Wait until LED start blinking (~10sec.)
- Upload **...factory.bin** image via JBOOT http (IP: 192.168.123.254)
- If http doesn't work, it can be done with curl command: `curl -F FN=@XXXXX.bin http://192.168.123.254/upg` where `XXXXX.bin` is the name of the firmware file.

## Devices with this installation method
