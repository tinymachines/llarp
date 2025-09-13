# How to send AT commands to device

AT commands (“attention commands” formally, the Hayes command set), are used to communicate directly with a modem device and configure it.

## From OpenWrt

To send AT commands directly from OpenWrt, you can simply use `echo` to send them to the right device. However, you will not get any errors, confirmation or any other answer from the modem.

A better solution is using a proper terminal application like `picocom`, which can both send commands and print the modem's answers. There are other alternatives available like `socat`.

Once the appropriate *serial* driver is loaded (typically - `kmod-usb-serial-option`), the modem will expose a number of `/dev/ttyUSBx` interfaces. Usually only one or two of them will respond to AT commands.

As an example, popular Quectel EP06 LTE modem will create 4 serial devices, `/dev/ttyUSB0` through to `/dev/ttyUSB3`.

To find the serial devices added to the system, try looking through `logread` and/or `dmesg` output. Something like the following may help:

```
root@OpenWrt:~# dmesg | grep -A 1 -B 12 ttyUSB
```

For some modems `ttyACM` devices will be created instead of `ttyUSB`.

### picocom

`picocom` is a simple terminal program that is installed in a standard way with `opkg install picocom` or through the web interface.

Sample command line:

```
root@OpenWrt:~# picocom /dev/ttyUSB2
```

Adding `--q` on the command line will suppress extra output with some help and other information.

```
root@OpenWrt:~# picocom --q /dev/ttyUSB2
at
OK
```

### socat

`socat` will open a prompt where you can enter AT commands (see examples in the [section below](/docs/guide-user/network/wan/wwan/at_commands#examples_of_at_commands "docs:guide-user:network:wan:wwan:at_commands")).

Here is a command line example:

```
root@OpenWrt:~# socat - /dev/ttyUSB2,crnl
```

In this example `socat` will send a *carriage return* (cr) and a *new line* (nl) after each command.

To quit `socat`, use `ctrl+C`.

### echo

See examples below. `echo -e` is used to send *escaped* characters such as quotation marks.

Alternative solution - use `echo` with `socat`: `echo -e ATI | socat - /dev/ttyUSB2,crnl`

## From a computer

To send AT commands to a LTE modem, you need to first connect the device/modem to the computer, most likely using an adapter (built-in modem slots are very rare these days) and access it with a COM terminal.

If you are not familiar with using COM terminals, you might want to use a graphical tool like: `CuteCom` or `minicom`. Installation of these are beyond the scope of this page.

These settings should work fine:

```
Device: /dev/ttyUSB0
Connection: 115200 @ 8-N-1
Line end: CR
```

## Examples of AT commands

To test things are working, you can issue a standard `ATI` command which should return basic information such as brand, model and firmware revision.

`AT+CSQ` can be used to get signal strength. The values returned are the RSSI (received signal strength indication, higher is better) and BER (bit error rate, lower is better)

## Huawei E392

```
Send: AT
OK

Send: AT^SETPORT=?
Recieve: 1:MODEM
Recieve: 2:PCUI 
Recieve: 3:DIAG
Recieve: 4:PCSC
Recieve: 5:GPS
Recieve: 6:GPS CONTROL
Recieve: 7:NDIS
Recieve: A:BLUE TOOTH
Recieve: B:FINGER PRINT
Recieve: D:MMS
Recieve: E:PC VOICE
Recieve: A1:CDROM
Recieve: A2:SD
Recieve: OK

Send: AT^SETPORT?
Recieve: A1,A2;1,2,3,A1,A2
Recieve: OK

Send: AT^SETPORT="A1;2,7,A2"
Recieve: OK

Send: AT^SETPORT?
Recieve: A1;2,7,A2
Recieve: OK
```

Explanations:

```
AT^SETPORT=?        - Lists the Available interfaces and their numbers  
AT^SETPORT?         - Show current configuration  
AT^SETPORT="A1;2,7  - Sets configuration.
```

Modem configuration is split into 2 parts: before `;` and after.

Once a modem is plugged-in, it should declare itself in first configuration (normally with at least: A1 - virtual CD drive with Drivers and application). If the drivers are installed, they will see the modem and issue a special command to switch to a “working” configuration - this is 2,7 interfaces in this example.

![:!:](/lib/images/smileys/exclaim.svg) **Warning: Never turn Off the AT Command interface! (“PCUI” in Huawei terms)** You will lose the ability to access modem with terminal and change the configuration.

You can add more interfaces to be active i.e. SD card:

```
AT^SETPORT="A1,A2;2,7,A2"
```

If you get an **ERROR**, maybe the numerical mode is not sorted (16,2,7)→(2,7,16). If your device answers to set command with **OK** but `AT^SETPORT?` doesn't show your desired settings, you can try using space in between numerical modes(2,7) and alphabetical modes(A2) like so:

```
AT^SETPORT="A1,A2;2,7,A2"
```

Or with multiple modes:

```
AT^SETPORT="A1,A2;2,7,A1,A2"
```

## Quectel modems

### How to force LTE connection

**Format:**

```
AT+QCFG="nwscanmode"[,<scanmode>[,<effect>]]
```

**Parameters**：

```
<scanmode> Number format, network search mode
0 AUTO
1 GSM only
2 UMTS only
3 LTE only

<effect> Number format, when to take effect
0 Take effect after UE reboots
1 Take effect immediately
```

**Examples:**

Set modem to LTE only:

```
echo -e "AT+QCFG=\"nwscanmode\",3,1" > /dev/ttyUSB2
```

Set it back to “auto”:

```
echo -e "AT+QCFG=\"nwscanmode\",0,1" > /dev/ttyUSB2
```

## Further references

- [Chromium project page](https://www.chromium.org/chromium-os/how-tos-and-troubleshooting/debugging-3g "https://www.chromium.org/chromium-os/how-tos-and-troubleshooting/debugging-3g") on debugging cellular modems
- [Wikipedia article](https://en.wikipedia.org/wiki/Hayes_command_set "https://en.wikipedia.org/wiki/Hayes_command_set") on AT commands and their history
