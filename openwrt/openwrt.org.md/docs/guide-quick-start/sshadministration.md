# SSH access for newcomers

One of the methods to manage OpenWrt is by using a [command-line interface](/docs/guide-user/base-system/user.beginner.cli "docs:guide-user:base-system:user.beginner.cli") over [SSH](https://en.wikipedia.org/wiki/SSH_%28Secure_Shell%29 "https://en.wikipedia.org/wiki/SSH_(Secure_Shell)"). OpenWrt listens for incoming SSH connections on port `22/tcp` by default. In order to SSH into your router, you can enter the following command in a terminal emulator, using your router's LAN IP address, which is typically `192.168.1.1`:

```
ssh root@192.168.1.1
```

The first time you SSH into your router, you will probably see a warning about the *RSA key fingerprint*. If you are certain this is the address of your OpenWrt device, simply type `yes` and press Return. Then enter the password you assigned to your router, or press Return if this is the initial setup. Here is an example session:

```
$ ssh root@192.168.1.1
The authenticity of host '192.168.1.1 (192.168.1.1)' can't be established.
RSA key fingerprint is SHA256:4VbDA/MOc7inPiyllF5f0r3Q6iEx89ddKdhLGBovsiY.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '192.168.1.1' (RSA) to the list of known hosts.
root@192.168.1.1's password:

BusyBox v1.28.4 () built-in shell (ash)

  _______                     ________        __
 |       |.-----.-----.-----.|  |  |  |.----.|  |_
 |   -   ||  _  |  -__|     ||  |  |  ||   _||   _|
 |_______||   __|_____|__|__||________||__|  |____|
          |__| W I R E L E S S   F R E E D O M
 -----------------------------------------------------
 OpenWrt 18.06.2, r7676-cddd7b4c77
 -----------------------------------------------------

root@OpenWrt:~#
```

*Note: you probably won't see your password as you type it, though that depends on the configuration of your system.*

To end the *SSH session*, type `exit` and press Return.

The remainder of this page describes several terminal emulators that can be used on Windows, Linux, or macOS to access your OpenWrt device.

*Note: To add an SSH public key to your OpenWrt device, see [From the LuCI Web Interface](/docs/guide-user/security/dropbear.public-key.auth#from_the_luci_web_interface "docs:guide-user:security:dropbear.public-key.auth")*

## Windows terminal emulators

### Windows 10/11 built-in terminals

[Windows Terminal](https://github.com/microsoft/terminal "https://github.com/microsoft/terminal"), PowerShell, and Command Prompt allow using the SSH client. That client is now available by default, however if your version of Windows is older, you may follow this guide to [enable SSH](https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse "https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse").

If you directly launch `cmd.exe`, `powershell.exe` or `wsl.exe` the legacy ConHost terminal will open. Otherwise, you can install the modern [Windows Terminal](https://www.microsoft.com/store/productId/9N0DX20HK701 "https://www.microsoft.com/store/productId/9N0DX20HK701") from the MS store and select any of these shells from there.

1. Open any of the above terminal emulators and write `ssh root@192.168.1.1` (“ssh” is the command, “root” is the OpenWrt user you are connecting as, and “192.168.1.1” is the IP)
2. There will be a message to accept a new key from the OpenWrt device, write “yes” and press Enter key.
   
   1. If for some reason you have reinstalled OpenWrt, the device will have a different key, and you will get an error about a key mismatch. The error will state the command to copy and paste into your terminal to delete the old key and proceed. Do it and retry. If that does not resolve the error then you may have to delete `C:\Users\yourusername\.ssh\known_hosts` and try again.
3. If you want to close the session, write “exit”.

The Windows optional SSH feature also includes an SCP client (to open/edit/download/upload files in OpenWrt via SSH). Alternatively, you can use [WinSCP](/docs/guide-quick-start/sshadministration#winscp "docs:guide-quick-start:sshadministration"), which is often easier for SCP purposes.

### PowerShell

[Powershell](https://docs.microsoft.com/en-us/powershell/scripting/overview?view=powershell-7.2 "https://docs.microsoft.com/en-us/powershell/scripting/overview?view=powershell-7.2") provides SSH access.

### Windows Subsystem for Linux (WSL)

The Windows Subsystem for Linux is a convenient way to run a Linux environment of your choice directly on Windows. It should already have a command-line SSH client preinstalled, for more instructions see the [Linux terminal emulators](/docs/guide-quick-start/sshadministration#linux_terminal_emulators "docs:guide-quick-start:sshadministration") section. For detailed steps on how to install WSL, refer to Microsoft's documentation: [https://docs.microsoft.com/en-us/windows/wsl/install](https://docs.microsoft.com/en-us/windows/wsl/install "https://docs.microsoft.com/en-us/windows/wsl/install")

### PuTTY

PuTTY gives you command-line access to OpenWrt.

1. Download [PuTTY](https://www.putty.org/ "https://www.putty.org/"), get the 32bit `putty.exe` from the `Alternative binary files` section.
2. Start `putty.exe` on your Windows client, PuTTY's login window will pop up.
3. Go to the `Session` category of PuTTY's login window, look for the field `Host Name (or IP address)` and enter the IP address (e.g. **192.168.1.1**) of your OpenWrt device. Keep the default provided port **22**.
4. Click the `Open` button at the bottom to open a connection. This will pop up a shell window, asking to `login as`. Log in as **root** with your password. If you have not yet set a password for “root”, you will not be prompted for one.
5. You are now logged into the OpenWrt command line.

Setting up key-based authentication.

1. Generate a key pair using `puttygen.exe`. Save the private key to your PC and add the public key to `/etc/dropbear/authorized_keys` on your OpenWrt device.
2. Connection → SSH → Auth: In the box “Authentication Parameters” under “Private key file for Authentication” state the path to your private key file for this connection (e.g. the `openwrt.ppk` file you created before). It is best to click “Browse...” and select the file via the file dialog.

Automating connections.

1. Connection → Data: In the box “Login details” enter the “Auto-login username” which is `root`.
2. Load, save or delete a stored session, enter `openwrt.lan` in Saved Sessions and click the Save button.
3. To make a PuTTY shortcut with an automatic login, create one and append the saved session with an `@` sign, for example call PuTTY with: `putty.exe @openwrt.lan`

### WinSCP

WinSCP allows you to browse the OpenWrt file system in a Windows Explorer-like GUI-style.

1. Download [WinSCP](https://winscp.net/eng/download.php "https://winscp.net/eng/download.php"), get the non-beta `Installation package` or `portable executables` and install or unzip them on your Windows client.
2. Start `WinSCP.exe`, WinSCP's login window will pop up.
3. Click on `New Site` on the left, ensure `File protocol` is set to **scp** then enter the IP address of your OpenWrt device (usually 192.168.1.1) on the right side into `Host name`, keep the default port `22`. In `User name` enter **root**, in `Password`, enter your root **password** (or leave blank if you have not set a password yet)
4. Click the `Login` at the bottom of the window.
5. You now have an Exlorer-like view of your OpenWrt file system.

Editing OpenWrt config files with WinSCP's integrated GUI editor.

1. Just right-click the file in WinSCP and select `Edit` from the context menu.

### Cmder

Cmder for Windows is an open-source terminal emulator that runs on Windows. It is free to use and provides an easy command line shell that allows you to SSH into OpenWrt. The *Full* distribution is preferred (over the *mini* distribution), since it provides bash emulation and a Unix-y suite of commands.

1. Download [Cmder](https://cmder.net/ "https://cmder.net/").
2. Unzip the *cmder.zip* file.
3. Open the Cmder folder and double-click the Cmder icon. You'll see a Cmder window open.
4. To SSH into the OpenWrt router at 192.168.1.1, type `ssh root@192.168.1.1` then press Return.

### SmarTTY

SmarTTY gives you command line access to OpenWrt and allows you to open/edit/download/upload files in OpenWrt, and is overall more modern and user-friendly.

1. Download [SmarTTY](http://sysprogs.com/SmarTTY/ "http://sysprogs.com/SmarTTY/"), choose “download” for the installer, or “portable version” if you want it as a standalone program that works without installation.
2. After installation or after unzipping the archive, double-click on the **SmarTTY** executable file.
3. You will be greeted by a window with two choices, double-click on “setup a new SSH connection” (The other option is for serial connections, typically used with USB-TTL dongles, where you connect to the device's debug serial pins on the board, but we won't be using that option now).
4. The window changes into the SSH setup, write the following info:
   
   1. **Host name:** OpenWrt device IP address (default is **192.168.1.1**)
   2. **User Name:** **root**
   3. **Password:** leave this blank for your first connection, then write the password you set up (either in Luci GUI or after your first SSH access)
5. Click the “Connect” button at the bottom, you will now see a big terminal screen coming up.
6. A default OpenWrt firmware lacks the server component to allow you to open/edit/view/upoad/download files in SmarTTY, so after you have connected to the internet write `opkg update && opkg install openssh-sftp-server` to install it. If the next step fails, it might be necessary to reboot the OpenWrt device for this new service to start up properly.
7. Now you can click on **File → Open a Remote File** to open a popup that shows the file system of the OpenWrt device, and you can navigate in it and open text files for example as normal (they will open in a SmarTTY text editor window)
8. If you want to upload or download files to/from a specific folder in the device, you can click on the SCP menu and choose the most appropriate action from there.

After the first time you connected to a device, SmarTTY saved a profile, so you can connect again to the same device by just double-clicking its icon on the first window you see when starting SmarTTY. You can right-click on this profile icon to edit it again, if needed.

## Linux terminal emulators

Most Linux distributions provide a command-line SSH client as part of the default installation.

1. Open a terminal emulator and write `ssh root@192.168.1.1`
2. There will be a message about accepting a new key from the OpenWrt device, write “yes” and press Enter.
   
   1. If for some reason you have reinstalled OpenWrt, the device will have a different key, and you will get an error about a key mismatch. The error will state the command to copy and paste into your terminal to delete the old key and proceed.
3. If you want to close the session, write “exit”

Linux also usually has SCP/SFTP clients (to open/edit/download/upload files in OpenWrt), which may or may not be installed by default.

### Midnight Commander

[Midnight Commander](https://midnight-commander.org/ "https://midnight-commander.org/") is a Norton Commander-like file manager that works on Linux and macOS. You can access remote files on OpenWrt via mc:

1. Press 'F9'
2. Select 'Left' panel config
3. Select 'Shell link'
4. Input 'root@192.168.1.1/' and press OK
5. Now you'll see list of files and directories in root of OpenWrt

Internally, it works over a protocol similar to SCP, called [FISH](https://en.wikipedia.org/wiki/Files_transferred_over_shell_protocol "https://en.wikipedia.org/wiki/Files_transferred_over_shell_protocol"), so it doesn't require an installed SFTP server.

## macOS terminal emulators

On macOS (formerly Mac OSX) any terminal emulator will allow you to SSH.

1. Terminal - The macOS built-in terminal program, you can find it in /Applications/Utilities.
2. [iTerm2](https://iterm2.com/ "https://iterm2.com/") a much-enhanced terminal program.

To SSH into your OpenWrt router at 192.168.1.1, type `ssh root@192.168.1.1`, then press Return.

## ChromeOS terminal emulator

On [ChromeOS](https://en.wikipedia.org/wiki/ChromeOS "https://en.wikipedia.org/wiki/ChromeOS"), the [Secure Shell App](https://chrome.google.com/webstore/detail/secure-shell/iodihamcpbpeioajjeobimgagajmlibd "https://chrome.google.com/webstore/detail/secure-shell/iodihamcpbpeioajjeobimgagajmlibd") will allow you to SSH.
