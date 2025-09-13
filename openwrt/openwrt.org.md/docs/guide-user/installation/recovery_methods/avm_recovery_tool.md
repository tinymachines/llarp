# AVM recovery tool

Many AVM devices can be unbricked by a AVM recovery tool which is specific to your device.

**Example:** For Fritz!Box 7530 [https://download.avm.de/fritzbox/fritzbox-7530/other/recover/](https://download.avm.de/fritzbox/fritzbox-7530/other/recover/ "https://download.avm.de/fritzbox/fritzbox-7530/other/recover/")

Search the corresponding recovery tool for your specific device on the AVM FTP server.

## Debricking a branded device

If you have a branded (e.g. 1&amp;1) AVM device and you get the following message

```
The device contains basic settings adapted for your Internet Service Provider
```

when trying to go back to OEM firmware via the AVM recovery tool, you have to unbrand your device first. See the procedure below how to do this.

1. Set your PCs IP to 192.168.178.x/24 (where x is not 1) and the default gateway to 192.168.178.1.
2. Turn off your router, ensure your PC is connected to LAN1 via Ethernet, and turn the router back on.
3. Wait for the interface to become active (usually indicated by LEDs on your PC's Ethernet port) and connect to the bootloader's FTP server, e.g. `ftp -n 192.168.178.1`
4. If connecting to the bootloader's FTP server fails with 'connection refused': It has been reported that some models require a magic UDP packet exchange before the FTP connection is accepted by the router. This can also be required for some Fritz!Box 7530 routers. There are two possibilities to enable the connection:
   
   1. Refer to the scripts in this thread: [https://forum.openwrt.org/t/fritzbox-4040-flash-ftp-connection-refused/42543/4](https://forum.openwrt.org/t/fritzbox-4040-flash-ftp-connection-refused/42543/4 "https://forum.openwrt.org/t/fritzbox-4040-flash-ftp-connection-refused/42543/4").
   2. Run tha AVM recovery tool until the prompt appears that warns 'The device contains basic settings adapted for your Internet Service Provider'. At this point, leave the prompt open and the tool running, and the FTP connection should be possible.
5. Once connected to the FTP server, issue the following set of commands:
   
   ```
       quote USER adam2
       quote PASS adam2
       quote SETENV firmware_version avm
       quote UNSETENV provider
       quit
   ```
   
   Not sure if it's necessary to change the firmware\_version variable.
6. Run the recovery tool (or re-start it, if it was already running to enable connecting to the FTP server), but make sure you **do not reset the device**, otherwise the environment variables will go back to their default values. Even if the recovery tool asks you to power cycle the device, **do not do it**.

## Experiences

### Router by Zen (UK)

The following steps worked for FRITZ!Box 7530 from Zen. A Windows machine is needed.

1. Set PC IP address to 192.168.178.x/24 gateway 192.168.178.1
2. In “Device Manager &gt; Network Adapters &gt; Ethernet Adapter &gt; Advanced &gt; Speed &amp; Duplex” select “10 Mbit/s, half-duplex” [1)](#fn__1)
3. Start AVM recovery tool and follow instructions to get to “settings adapted for your ISP” dialog. Keep the dialog on. [2)](#fn__2)
4. Login via FTP like shown above and do \`\`\`UNSETENV provider\`\`\` but skip \`\`\`SETENV firmware\_version avm\`\`\` [3)](#fn__3)
5. In the AVM recovery tool, now close the dialog and exit the tool cleanly.
6. Run the AVM recovery tool again, but do not power cycle the Fritz!Box in between.
7. See the tool deleting the flash area, restoring the flash, then say “... recovered successfully!”

Afterwards, remember to clear the settings on your ethernet port, i.e., undo step 1 and 2.

[1)](#fnt__1)

Instructions by [AVM themselves](https://en.avm.de/service/knowledge-base/dok/FRITZ-Box-7590/160_Restoring-the-FRITZ-OS-of-your-FRITZ-Box/ "https://en.avm.de/service/knowledge-base/dok/FRITZ-Box-7590/160_Restoring-the-FRITZ-OS-of-your-FRITZ-Box/") say that one error can be prevented by using only 10 Mbit/s half-duplex mode on the ethernet port. This supposedly avoids the “Could not determine the version!” error.

[2)](#fnt__2)

The bootloader's FTP is not immediately available. As per above instructions, I ran the AVM tool first until it reached the 'The device contains basic settings adapted ...' state and left it like that. Then FTP was available.

[3)](#fnt__3)

I skipped the \`\`\`quote SETENV firmware\_version avm\`\`\` command. One of these alternations to the procedure helped me get past the “Could not determine the version!” error.
