# Command-line interpreter

See also: [SSH access for newcomers](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")

A command-line interpreter is a computer program that reads singular lines of text entered by a user and interprets them in the context of a given operating system or programming/scripting language. The interaction takes place by means of a [command-line interface](https://en.wikipedia.org/wiki/command-line%20interface "https://en.wikipedia.org/wiki/command-line interface"). Other common, but technically not quite correct, denominations are **console** or **shell**.

The OpenWrt standard [unix shell](https://en.wikipedia.org/wiki/unix%20shell "https://en.wikipedia.org/wiki/unix shell") is the Busybox-fork of the Debian implementation of the [Almquist shell](https://en.wikipedia.org/wiki/Almquist%20shell "https://en.wikipedia.org/wiki/Almquist shell") (see → [https://www.in-ulm.de/~mascheck/various/ash/#busybox](https://www.in-ulm.de/~mascheck/various/ash/#busybox "https://www.in-ulm.de/~mascheck/various/ash/#busybox")). In case you want to read about it.

## Start

At the end of the boot up process, the **init daemon** is started, this can be [init](https://en.wikipedia.org/wiki/init "https://en.wikipedia.org/wiki/init") or [systemd](https://en.wikipedia.org/wiki/systemd "https://en.wikipedia.org/wiki/systemd") or [upstart](https://en.wikipedia.org/wiki/upstart "https://en.wikipedia.org/wiki/upstart"), etc. OpenWrt currently uses **`procd`** . Following the boot up scripts located in `/etc/rc.d`, `init` will then start all sorts of programs, amongst them the chosen shell. This listens to keyboard strokes and outputs a more or less colorful command-line interface to the connected display.

But most devices you run OpenWrt on, have neither a keyboard nor a display adapter. So we need to access it over the [serial port](/docs/techref/hardware/port.serial "docs:techref:hardware:port.serial") (=local) or over the Ethernet port (= over the network).

## Network

To gain access to a shell over the network, you obviously need some other programs to help you with that. And the whole data exchange (aka communication) has to involve some kind of [network protocol](https://en.wikipedia.org/wiki/Communications%20protocol "https://en.wikipedia.org/wiki/Communications protocol").

Network protocols of choice are [telnet](https://en.wikipedia.org/wiki/telnet "https://en.wikipedia.org/wiki/telnet") and [SSH](https://en.wikipedia.org/wiki/Secure%20Shell "https://en.wikipedia.org/wiki/Secure Shell"). Both follow the server ↔ client scheme. On the device running OpenWrt we deploy `telnetd` for the telnet protocol and `dropbear` for for the SSH protocol. Try [PuTTY](https://en.wikipedia.org/wiki/PuTTY "https://en.wikipedia.org/wiki/PuTTY") for the real look-and-feel, but you should definitely also checkout [WinSCP](https://en.wikipedia.org/wiki/WinSCP "https://en.wikipedia.org/wiki/WinSCP")! The latter won't work quite correctly, however [Konqueror](https://en.wikipedia.org/wiki/Konqueror "https://en.wikipedia.org/wiki/Konqueror") with `fish://` does! See [FISH (Files transferred over shell protocol)](https://en.wikipedia.org/wiki/Files%20transferred%20over%20shell%20protocol "https://en.wikipedia.org/wiki/Files transferred over shell protocol").

(OpenWrt does also include a SSH-client `ssh` and a telnet-client `telnet`, in case you want to login from it to somewhere else.)

![](/_media/meta/icons/tango/dialog-information.png) **Note:** Before [walkthrough\_login](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") only `telnetd` will run, and after only `dropbear`.

In case of a successful login `dropbear` will (generate a LOG and) spawn an instance of the specified shell (more shells can be installed simultaneously) with the users ID.

- [SSH Access for Newcomers](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")

## Configuration

In OpenWrt this is done in the file: `/etc/profile` by setting [environment variables](https://en.wikipedia.org/wiki/Environment%20variable "https://en.wikipedia.org/wiki/Environment variable") and aliases. It comes (of course) pre-configured and will work out-of-the-box, but you can alter and augment it's configuration:

- you can configure the [command prompt](https://en.wikipedia.org/wiki/command-line_interface#Command_prompt "https://en.wikipedia.org/wiki/command-line_interface#Command_prompt") via the variable `PS1`. see → [https://controlc.de/2010/03/12/bash-shell-einrichten/](https://controlc.de/2010/03/12/bash-shell-einrichten/ "https://controlc.de/2010/03/12/bash-shell-einrichten/") and many many many other pages in the web on help with that
- you change the content of existent variables and can define new ones
- etc.

## Copy &amp; paste

When in PuTTY, you can mark text content with the mouse and, without pressing any key (like \[Ctrl]+\[c]), it is being automatically stored. You can then insert it the usual way (with \[Ctrl]+\[v]) in an other windows, e.g. an open firefox. The other way around, you copy text the usual way \[Ctrl]+\[c]) and then paste it in PuTTY by pressing the \[right mouse button]!

### Numpad in PuTTY while using Vi

In PuTTY goto *“Terminal”* ⇒ *“Features”* and check *“Disable application keypad mode”*.

## Issue commands

\* For some orientation with the file system and the whole directories, check [flash.layout](/docs/techref/flash.layout "docs:techref:flash.layout").

At login you will be in your $HOME directory, which is `/root` for user root and would be `/home/user1` for user1, etc. Commands:

Command Memorize Description `pwd` *print working directory* prints out the current directory you are in `cd` *change directory* move through the file system directory tree: `cd ..`, `cd /`, `cd /etc/init.d`, `cd /tmp` `ls` *list* print the content of the current directory, `ls -l /etc` `cat` *concatenate* print the content of a file on screen: cat `/etc/config/network`, `cat /tmp/dhcp.leases` `cp` *copy* creates a copy of the specified file, `cp network network.bak` `mv` *move* creates a copy of the specified file and deletes the original, `mv /tmp/opkg-lists/snapshots /mnt/sda1/opkg/packages` `df` *disk free* Shows you available space. Again, see [flash.layout](/docs/techref/flash.layout "docs:techref:flash.layout") for understanding `/rom`, etc. And see [df](http://man.cx/df "http://man.cx/df") for help with the command and it's options. Try `df -h`. `free` info about free RAM `uptime` time elapsed since last boot `dmesg` print or control the kernel ring buffer `logread` Shows the messages from syslogd (using circular buffer) `cat /proc/version` `cat /proc/meminfo` more detailed info about RAM usage `cat /proc/cpuinfo` info about your CPU `cat /proc/mtd` `cat /proc/partitions` `cat /proc/net/nf_conntrack` `cat /proc/cmdline` `cat /proc/modules`

There is a ton of commands with a ton of options. On a full blown Linux distribution you would issue a `man command` to learn about the command and its options. However OpenWrt is minimalistic and thus does not contain this functionality. So either read the man-pages (manual pages) on another GNU/Linux machine or read them online: e.g. at [vi](http://man.cx/vi "http://man.cx/vi"). Man pages are in the process of being translated.

**`Tip`** In firefox, you can use [keywords](https://kb.mozillazine.org/Using_keyword_searches "https://kb.mozillazine.org/Using_keyword_searches") to simplify the usage. Create a new bookmark, use `https://man.cx/?page=%s` as address and `man` as keyword.

## Editing files

To edit a file you need an editor, to edit a text file, you would use a text editor.

The standard text editor included is `vi`. Until you get used to it, vi is neither intuitive nor pretty.

- `vi` has two modes: *command mode* and *insert mode*.
- to enter command mode press \[Esc] (escape key)
- to enter insert mode press either \[i] for *insert* or \[a] for *append*
- `vi` starts out in command mode

#### Starting vi

Start with `vi` or `vi /etc/config/network` or `vi firewall.user` if you are already in the same directory.

#### Editing

In order to edit the file, you have to be in *insert mode*. Press \[i] or \[a].

#### Exiting vi

In order to get out of vi, you have to be in *command mode*. Press \[Esc] (the escape key). Then issue one of the following commands:

- `:w` to write the current file to disc, this will overwrite the old file
- `:q` to quit without writing
- `:wq!` to (forcefully) write to disk and then quit vi
- `:%s/string1/string2/g` replace string1 with string2 in the whole file

#### Configuring vi

Vi can be configured in *command mode* by setting certain variables:

- `:set ai` use auto indentation (sometimes annoying default)
- `:set noai` NO auto indentation

#### Alternative text editors

If you do not like `vi`, try `joe`, `mg`, `nano`, `mc --edit`, `vim`, `vim-full`, `vim-help`, `vim-runtime` or `zile`

- `vim`
- `joe`
- `nano`
- `mc`
- `zile`
- `mg`

and there may be other text editors available in the OpenWrt repos.

'Note:' * Many modern and free graphical text editors, from [Visual Studio Code](https://en.wikipedia.org/wiki/Visual%20Studio%20Code "https://en.wikipedia.org/wiki/Visual Studio Code") to [Atom](https://en.wikipedia.org/wiki/Atom%20%28text%20editor%29 "https://en.wikipedia.org/wiki/Atom (text editor)") to [Notepad++](https://en.wikipedia.org/wiki/Notepad++ "https://en.wikipedia.org/wiki/Notepad++"), (to say nothing of [CudaText](https://en.wikipedia.org/wiki/CudaText "https://en.wikipedia.org/wiki/CudaText"), [TextMate](https://en.wikipedia.org/wiki/TextMate "https://en.wikipedia.org/wiki/TextMate"), [Komodo Edit](https://en.wikipedia.org/wiki/Komodo%20Edit "https://en.wikipedia.org/wiki/Komodo Edit"), et al.) offer plugins in their official repositories that add the ability to edit files over SFTP, meaning if you're connected to your OpenWrt device from your desktop computer over SSH, those applications with their respective plugins would be able to edit any file on your OpenWrt device as well. * You may need to restart the device after installing vim for it to function properly.

## Scripting language

OpenWrt uses [busybox's](https://www.busybox.net/BusyBox.html "https://www.busybox.net/BusyBox.html") ash shell by default, which is in most parts [*POSIX*](https://en.wikipedia.org/wiki/POSIX "https://en.wikipedia.org/wiki/POSIX") compliant. Visit [*shell script*](https://en.wikipedia.org/wiki/shell%20script "https://en.wikipedia.org/wiki/shell script") for general information about shell scripts.

## Executing shell scripts

Shell scripts can be executed with:

`sh /path/to/script.sh`

After changing the executable bit its also possible to run it without the sh in front:

```
chmod +x /path/to/script.sh
/path/to/script.sh
```

## Profile customization

User profile customization example.

```
# Configure profile
mkdir -p /etc/profile.d
cat << "EOF" > /etc/profile.d/custom.sh
export EDITOR="nano"
export PAGER="less"
alias bridge="bridge -color=auto"
alias diff="diff --color=auto"
alias grep="grep --color=auto"
alias ip="ip -color=auto"
EOF
. /etc/profile
```

## File managers

You may also want to try `mc` or `deco`.

## Use GUIs

[![Konqueror](/_media/doc/howto/konqueror.fish1.png?w=300&tok=c6c62c "Konqueror")](/_detail/doc/howto/konqueror.fish1.png?id=docs%3Aguide-user%3Abase-system%3Auser.beginner.cli "doc:howto:konqueror.fish1.png") [![GVim](/_media/doc/howto/konqueror.fish_gvim.png?w=300&tok=a14364 "GVim")](/_detail/doc/howto/konqueror.fish_gvim.png?id=docs%3Aguide-user%3Abase-system%3Auser.beginner.cli "doc:howto:konqueror.fish_gvim.png") [![WinSCP](/_media/doc/howto/winscp-ss1.png?w=300&tok=54be09 "WinSCP")](/_detail/doc/howto/winscp-ss1.png?id=docs%3Aguide-user%3Abase-system%3Auser.beginner.cli "doc:howto:winscp-ss1.png")

## Further help

- [https://wiki.debian.org/CommandLineInterface](https://wiki.debian.org/CommandLineInterface "https://wiki.debian.org/CommandLineInterface")
- [http://linuxcommand.org/tlcl.php](http://linuxcommand.org/tlcl.php "http://linuxcommand.org/tlcl.php") ---- William Shotts free PDF books starting from terminal basics
