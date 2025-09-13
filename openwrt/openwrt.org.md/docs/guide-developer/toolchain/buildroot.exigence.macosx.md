# Build system setup macOS

This method is NOT OFFICIALLY supported. A native [GNU/Linux environment](/docs/guide-developer/toolchain/install-buildsystem "docs:guide-developer:toolchain:install-buildsystem") is recommended.

Tested with [macOS](https://en.wikipedia.org/wiki/MacOS "https://en.wikipedia.org/wiki/MacOS") 10.15.7 (Darwin v19.6.0), [Xcode](https://en.wikipedia.org/wiki/Xcode "https://en.wikipedia.org/wiki/Xcode") 12.1 build 12A7403, &amp; packages from homebrew.  
Tested with [macOS](https://en.wikipedia.org/wiki/MacOS "https://en.wikipedia.org/wiki/MacOS") 11.6 (Darwin v20.6.0) [Xcode](https://en.wikipedia.org/wiki/Xcode "https://en.wikipedia.org/wiki/Xcode") 13.0 build 13A233, arm64 kernel, &amp; packages from homebrew.

● to view macOS version numbers, etc, run **:** `sw_vers`  
● to view Darwin version numbers, etc, run **:** `sysctl kern.osrelease`

#### macOS &amp; Darwin Unix:

You can skip this section *(if you want to)*, &amp; goto next section `A. Obtain build toolchain`.  
Brief/short info on macOS and Darwin Unix **:** [macOS](https://en.wikipedia.org/wiki/MacOS "https://en.wikipedia.org/wiki/MacOS") contains APSL *(Apple Public Source License)* &amp; BSD *(Berkeley Software Distribution)* and others licensed opensource[1](https://github.com/apple/darwin-xnu "https://github.com/apple/darwin-xnu"), [2](https://code.google.com/p/voodoo-kernel/source/checkout "https://code.google.com/p/voodoo-kernel/source/checkout"), [3](https://opensource.apple.com/ "https://opensource.apple.com/") [Darwin](https://en.wikipedia.org/wiki/Darwin_%28operating_system%29 "https://en.wikipedia.org/wiki/Darwin_(operating_system)") Unix based XNU[1](https://en.wikipedia.org/wiki/XNU "https://en.wikipedia.org/wiki/XNU") hybrid core/kernel, &amp; also contains Darwin unix as internal subsystem to support commandline based tools (from various Unix &amp; Linux distros). Darwin supports POSIX API because of its BSD unix based lineage and because of largely FreeBSD userland tools, etc. Most drivers, &amp; GUI layer's most components are proprietary (not-opensource) licensed. Build tools need to be compatible with “darwin”.

- In macOS v10.15.x *(Catalina)* &amp; earlier versions, the Kernel modules, hardware drivers, etc are known-as &amp; usually loaded as kext *(kernel extension)* inside kernel space/layer, &amp; uses [LKM](https://en.wikipedia.org/wiki/Loadable_kernel_module "https://en.wikipedia.org/wiki/Loadable_kernel_module") with KPI *(kernel programming interface)* &amp; d-KPI[1](https://developer.apple.com/support/kernel-extensions/ "https://developer.apple.com/support/kernel-extensions/") *(deprecated-KPI)*. But, since macOS v11 *(Big Sur)* &amp; newer versions, the newer sext/sysext *(system extension)* and (older) kext without d-KPI are used in user space/layer. And newer dext *(driver extension)* in macOS v11 &amp; later also runs in user space/layout, and replaces earlier I/O kit. So hardware/software developer/MFR should still supply sext/dext &amp; kext (without d-KPI). Earlier macOS/darwin used HFS partition, now uses APFS.
- A derivative, OpenDarwin project released last stable v7.2.1 on July 16, 2004, then shutdown on July 25, 2006. Some free software community, ISC, etc particiapted with Apple to develop OpenDarwin[1](https://sourceforge.net/projects/darwinsource/ "https://sourceforge.net/projects/darwinsource/"), and some ideas were used to build GNU-Darwin[1](http://gnu-darwin.org/ "http://gnu-darwin.org/"), [2](https://sourceforge.net/projects/gnu-darwin/ "https://sourceforge.net/projects/gnu-darwin/"). Another derivative, PureDarwin[1](https://github.com/PureDarwin/PureDarwin/wiki/Xmas "https://github.com/PureDarwin/PureDarwin/wiki/Xmas") released a preview based Darwin 9 with X11 GUI in 2015, followed by a command-line only 17.4 Beta based on Darwin 17 in 2019.
- Drivers**:** Wireless: [1](http://wirelessdriver.sourceforge.net/ "http://wirelessdriver.sourceforge.net/"), [2](http://sourceforge.net/projects/iwi2200 "http://sourceforge.net/projects/iwi2200"). NIC: [1](http://sourceforge.net/projects/darwin-tulip/ "http://sourceforge.net/projects/darwin-tulip/"), [2](http://sourceforge.net/projects/darwin-rtl8139 "http://sourceforge.net/projects/darwin-rtl8139"), [3](http://sourceforge.net/projects/rtl8150lm "http://sourceforge.net/projects/rtl8150lm"). Zyxel modem: [1](http://sourceforge.net/projects/darwinmodems "http://sourceforge.net/projects/darwinmodems"). Card-readers: [1](http://pccardata.sourceforge.net/ "http://pccardata.sourceforge.net/"). Ext2 &amp; Ext3 (Linux filesystem support) under macOS: [1](http://sourceforge.net/projects/ext2fsx/ "http://sourceforge.net/projects/ext2fsx/"), [2](http://sourceforge.net/projects/ext2fuse "http://sourceforge.net/projects/ext2fuse").

#### A. Obtain build toolchain:

Obtain build toolchain that is more suitable for Apple hardware &amp; macOS &amp; Darwin Unix.

● Install *Xcode* or *CLT:*

1. Obtain Xcode[1](https://en.wikipedia.org/wiki/Xcode "https://en.wikipedia.org/wiki/Xcode") from [here](https://developer.apple.com/support/xcode/ "https://developer.apple.com/support/xcode/"). Note**:** installer file download is over/near 5 GB, and needs 17+ GB space. Xcode 11.5 : 16,958,217,326 bytes (10.5 GB on disk).
   
   - to view installed Xcode version number, run this command **:** `xcodebuild -version` . If output not-showing version number then Xcode is not-installed.
2. If you prefer to not obtain Xcode, then one of the alternative is**:**
   
   - obtain [Command-Line-Tools](https://stackoverflow.com/questions/9329243/ "https://stackoverflow.com/questions/9329243/")[1](https://en.wikipedia.org/wiki/Xcode "https://en.wikipedia.org/wiki/Xcode") (**CLT**) from [here](https://developer.apple.com/download/ "https://developer.apple.com/download/"), or Load it from `App Store` in macOS, or use below command, or obtain apple-gcc package via package manager software. CLT is also known as Command Line Developer Tools. Note**:** installer download is under/near 300 MB, and may need around ~ 2 GB space.
   - inside `Terminal`[1](https://en.wikipedia.org/wiki/Terminal_%28macOS%29 "https://en.wikipedia.org/wiki/Terminal_(macOS)") utility/app, run this command to load CLT**:**
     
     ```
     xcode-select --install
     ```
     
     - to view installed CLT version number, run this command **:** `pkgutil --pkg-info=com.apple.pkg.CLTools_Executables` . If output not-showing verison number or showing msg that *“...No receipt...”* then CLT is not installed, or its bundled inside+with Xcode. To view pre-installed pkgs you may run **:** `pkgutil --pkgs`

● To view toolchain version numbers, directory, etc info, run this command**:**

```
gcc -v && llvm-gcc -v && clang -v
```

● you may also run `xcrun clang` command, &amp; see what it outputs**:**

```
UserMacBook:~ username$  xcrun clang
clang: error: no input files
```

- if output is NOT this message `clang: error: no input files`, then either installation has error or executable files are not in PATH env var correctly.

● Build toolchain (Xcode or CLT) from apple is used (in first stage) to create a software components for openwrt build purpose, then (in second stage) those software components are used to create the final openwrt components, in order to create openwrt firmware, etc, that are widely compatible with cross-platform.

#### B. View hidden files/folders:

● We need to view full filename, file extensions, all files &amp; directories, etc including hidden ones, very accurately, so that there is lesser mistakes.  
● Use **Finder** to start **Terminal**[1](https://en.wikipedia.org/wiki/Terminal_%28macOS%29 "https://en.wikipedia.org/wiki/Terminal_(macOS)") in macOS**:**

- `Finder` is very similar to `Windows-Explorer` file-browser app/tool. In macOS &gt; click on any empty area in Desktop screen &gt; then in top-side  menu, click on `Window` &gt; click on `Bring All to Front` &gt; in left-pane (in left side column) of `Finder`, go under `Favorites` and click on the `Applications` &gt; then scroll down &amp; go into `Utilities` sub-folder &gt; then click on `Terminal` or `Terminal.app` to start it. macOS `Terminal` is very similar to Windows `Command-Prompt`, a command-line interface (CLI) tool.
- Hotkeys to start `Finder` instantly **:** `[Alt/Option⌥]` + `[Command⌘]` + `[Space-bar]` then close the Search tab.
- Hotkeys to start `Terminal` instantly **:** None. ( Note: Keep `Terminal` running, after a reboot `Terminal` will auto-start if you check-marked the option: Load previous running apps after reboot ).

● Run below command inside `Terminal`**:**

```
defaults write com.apple.Finder AppleShowAllFiles true
```

- above only makes the files viewable inside file-browser software, it does not actually change any file-attributes.

● then you must reboot Mac-computer OR run (any one of the) below command**:**

- ```
  /usr/bin/sudo /usr/bin/killall Finder /System/Library/CoreServices/Finder.app
  ```
  
  or, run just this:
  
  ```
  /usr/bin/sudo /usr/bin/killall Finder
  ```
  
  or, just this:
  
  ```
  sudo killall Finder
  ```
- then `Finder` will auto start, and all hidden files+folders will by-default begin to be shown to user in macOS Finder.

● in macOS `Finder` or inside any other file browsing window in macOS, user can also press below THREE buttons altogether ONCE to show all HIDDEN files/folders**:**

- `[Command⌘]` + `[Shift⇧]` + `[.>]`
- if user press-es above three buttons again, file-browsing-window will HIDE the HIDDEN files/folders.

● By default in macOS, `Finder` will keep most of the **file extension** hidden. But we need to see all file's extension to see FULL filename, so we can be sure &amp; not make mistake. To view all file's extension, do below steps**:**

- in macOS &gt; start “Finder” app &gt; goto main menu &gt; `Finder` &gt; `Preferences` &gt; `Advanced` &gt; select the `Show All Filename Extensions` option.

#### C. Install Package-Manager:

Install any one of the (3rd-party) [package manager](https://en.wikipedia.org/wiki/List_of_software_package_management_systems "https://en.wikipedia.org/wiki/List_of_software_package_management_systems") (**pkg-mngr**) software in macOS**:**

(1) Homebrew, or (2) MacPorts, or (3) pkgsrc.

- Notice/CAUTION **:** Usually most of the time, using source *(or binary)* packages distributed from primary/original author/developer is much much better than next-level (aka: downstream) package distributors: like, OS/distro developer *(dev)*, computer MFR *(manufacturer)*, etc distributed packages, And usually most of the time OS/distro dev's or computer MFR's distributed package is better than 3rd-party Package-Manager *(pkg-mngr)* maintainer distributed package. But often OS/distro dev or computer MFR does not update their pre-included packages, or uses older version, or does not include option for user to obtain other/related packages (from OS/distro dev or computer MFR). So in such cases, next best option is: obtain the *(src/bin)* package from original author's website for your OS/distro via secure conneciton. *(Package's source (src) code/file needs to be compiled to build package's binary/executable (bin) file⒮)*. If original author shares only source, then that means author wants you to compile source. So your next best option is: compile the source obtained from original author/developer, after you patched the source to make it compatible &amp; compilable for your OS/distro. Compile *(compilation)* process builds package's binary *(aka: executable)*, etc file(s). If previous steps are not possible for you, *(because, “patching” requires software development, and OS/distro platform, and harwdare platform based knowledge, etc)* then in such cases using 3rd-party package-manager *(pkg-mngr)* may be necessary for you. Some *(3rd-party)* pkg-mngr by default downloads package's source *(and dependencies / pre-requisites)* &amp; also auto compiles it in your OS/distro to create/build binary file(s). Usually package's maintainer patches the original-source to make it suitable for compile/run in target OS/distro. Some *(3rd-party)* pkg-mngr downloads binary that is pre-built with already patched source for your OS/distro. When binaries are properly compiled &amp; built in your own OS/distro then that is more trustworthy &amp; better, than faster &amp; directly download (pre-built) binaries. “Trust” is more important &amp; safer &amp; secure, than “Fast”/“Slow”. macOS has native pkg-mngr known as `App Store`, it has various or too many unfair restrictions &amp; walls, set by macOS dev apple, does not allow various types of open-source apps, etc, So that is why sometime we need to use 3rd-party pkg-mngr. You must not download &amp; compile &amp; use source *(src)* or binary *(bin)* from any non-original author website or post. Either download src/bin over secure/encrypted connection from original-author's website, OR, you must use OpenPGP/GPG/PGP based authentication to make sure downloaded src/bin is indeed actually released by actual original author. Pkg-manager tool internally includes option to use *(some form of)* authentication &amp; verification for any download.

**1**. **[Homebrew](https://Brew.sh/ "https://Brew.sh/"):**  
it is opensource &amp; free *(3rd-party)* pkg-mngr for macOS, etc. Homebrew was built 7yrs after MacPorts pkg-mngr *(formerly known as `DarwinPorts`)*.

● Notice / WARNING / *CAUTION* **:** homebrew is opensource pkg-mngr but this tool uses Google Analytics to collect usage telemetry. If you use homebrew: use OPT OUT option/command,

```
brew analytics off
```

or by setting

```
export HOMEBREW_NO_ANALYTICS=1
```

**2**. **[MacPorts](https://www.MacPorts.org/ "https://www.MacPorts.org/"):**  
it is opensource &amp; free *(3rd party)* pkg-mngr *(package manager)* for macOS, etc, &amp; it does not steal your usage/private data. MacPorts [guide](https://guide.macports.org/ "https://guide.macports.org/"). It can obtain source or binary or both *(for most)* package. After downloading source, it can auto compile in your OS/distro to create/build trustworthy binary files. MacPorts was created 7yrs before homebrew. [wp](https://en.wikipedia.org/wiki/MacPorts "https://en.wikipedia.org/wiki/MacPorts").  
● download/obtain MacPorts installer dmg/pkg file, install it. More info [here](https://www.macports.org/install.php "https://www.macports.org/install.php").  
● Before MacPorts is installed, your `~/.bash_profile` file (inside your home directory) may look close to like this**:**

```
# .bash_profile for BASH
# PROMPT_COMMAND=update_terminal_cwd
PS1='\h:\W \u\$ '
PS2='> '
PS4='+ '
PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export PATH
```

● MacPorts installer webpage will instruct you to add `macports` pkg-mngr executable file locations in the end of your PATH variable, like this**:**

```
PATH="$PATH:/opt/macports/bin:/opt/macports/sbin"
```

- after you add above line manually in `~/.bash_profile` file, it will look like below**:**
  
  ```
  # .bash_profile for BASH
  # PROMPT_COMMAND=update_terminal_cwd
  PS1='\h:\W \u\$ '
  PS2='> '
  PS4='+ '
  PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
  PATH="$PATH:/opt/macports/bin:/opt/macports/sbin"
  export PATH
  ```
- you can use this command to edit the `~/.bash_profile` file**:**
  
  ```
  sudo nano ~/.bash_profile
  ```

● When MacPorts is installed, installer will add locations in PATH where macports port package executables are stored, inside the `~/.bash_profile` file. In that way, your macOS user account can find+use the installed macports port package files, after you login. But we have to change it little bit.  
Here is what you will usually see in `~/.bash_profile` file (after macports is installed)**:**

```
# .bash_profile for BASH
# PROMPT_COMMAND=update_terminal_cwd
PS1='\h:\W \u\$ '
PS2='> '
PS4='+ '
PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
PATH="$PATH:/opt/macports/bin:/opt/macports/sbin"
 
##
# Your previous /Users/<YOUR-USER-NAME>/.bash_profile file was backed up as /Users/<YOUR-USER-NAME>/.bash_profile.macports-saved_2021-08-29_at_16:38:31
##
 
# MacPorts Installer addition on 2021-08-29_at_16:38:31: adding an appropriate PATH variable for use with MacPorts.
export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
# Finished adapting your PATH environment variable for use with MacPorts.
```

● **Change above codes**, into below code**:**

```
# .bash_profile for BASH
# PROMPT_COMMAND=update_terminal_cwd
PS1='\h:\W \u\$ '
PS2='> '
PS4='+ '
PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
PATH="$PATH:/opt/macports/bin:/opt/macports/sbin"
 
##
# Your previous /Users/<YOUR-USER-NAME>/.bash_profile file was backed up as /Users/<YOUR-USER-NAME>/.bash_profile.macports-saved_2021-08-29_at_16:38:31
##
 
# MacPorts Installer addition on 2021-08-29_at_16:38:31: adding an appropriate PATH variable for use with MacPorts.
# export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
export PATH
# Finished adapting your PATH environment variable for use with MacPorts.
```

- in above we have disabled MacPorts based port package locations from PATH, but locations of MacPorts pkg-mngr itself are kept in PATH. The “PATH” is an essential environment variable which indicates the sequence of directories/folders where to look for a specific (executable) program. The changes we made, will allow newly installed (MacPorts) packages stay out of touch of other software which does not need to use them. These (MacPorts) packages are needed for development/build purpose of OpenWRT, so we will create a separate executable file ( **`env.sh`** ) to load PATH (and other build environment variables), which is suitable for using inside a shell-manager's specific shell TAB(s) only, for openwrt build/development purpose. See step/section **F** in below for details on creating this `env.sh` file.

Tips for MacPorts users**:**

- to search for a pkg: `port search --name --glob '*pkgName*'`
- to view info on a pkg: `port info pkgName`
- to view what depencies are needed for a pkg: `port deps pkgName`
- to install a pkg: `sudo port install pkgName`

**3**. **[pkgsrc](https://www.pkgsrc.org/ "https://www.pkgsrc.org/"):**  
it is opensource &amp; free *(3rd-party)* pkg-mngr *(package-manager)* for NetBSD unix OS, but can also be used by other OS, including macOS/darwin. It can obtain binary packages. Download: [dev](https://pkgsrc.joyent.com/ "https://pkgsrc.joyent.com/"), Src: [gh](https://github.com/NetBSD/pkgsrc.git "https://github.com/NetBSD/pkgsrc.git"), More info: [wp](https://en.wikipedia.org/wiki/Pkgsrc "https://en.wikipedia.org/wiki/Pkgsrc").

*Warning* **:** macOS keeps the default PATH in `/etc/paths` file, but **do not edit/change it**, because such change can affect entire or many parts of macOS system. We only need to change build environment only for 1 or 2 shell instance(s), and not for entire macOS system, and also not for all other apps in macOS.

#### D. Create Dedicated Case-Sensitive Filesystem:

Create a dedicated case-sensitive filesystem for OpenWRT build/compile purpose**:**  
● We will be using a sparsebundle to allow us to have a case sensitive filesystem.  
● The size that you provide will be the max size of the volume for working with OpenWrt. Execute below commands inside a Terminal shell instance**:**

```
cd ~
hdiutil create -size 20g -type SPARSE -fs "Case-sensitive HFS+" -volname OpenWrt OpenWrt.sparseimage
hdiutil attach OpenWrt.sparseimage
```

- the command `cd ~` in above is taking developer-user inside the HOME directory of user-account in macOS, then `OpenWrt.sparseimage` file is created there. But if you want to create the SPARSE image file in a different directory, then change the `cd ~` line &amp; go inside your preferred volume/directory.

● Optional/Informational**:**

- if you want to open the `OpenWRT` Volume (aka: Drive, aka: Disk) after creating then use below command as 3rd-command line in above**:**
  
  ```
  hdiutil attach OpenWrt.sparseimage -autoopenrw
  ```
- after a reboot, if `OpenWRT` volume is not available in your macOS, then run**:**
  
  ```
  cd ~ && hdiutil attach OpenWrt.sparseimage -autoopenrw
  ```
- if you want to keep the `OpenWRT` volume always attached, then**:**
  
  ```
  cd ~ && sudo hdiutil attach OpenWrt.sparseimage -notremovable -autoopenrw
  ```
- if you want to detach (aka: unmount) the `OpenWRT` volume, then**:**
  
  ```
  hdiutil detach /Volumes/OpenWrt
  ```
- More info on `hdiutil` is [here](https://www.unix.com/man-page/OSX/1/hdiutil/ "https://www.unix.com/man-page/OSX/1/hdiutil/").

#### E. Goto OpenWRT build volume:

Go inside the OpenWRT build volume, with below command, in Terminal**:**

```
cd /Volumes/OpenWrt
```

#### F. Create location indicator &amp; build environment file:

● Create a file called **`env.sh`** inside `/Volumes/OpenWrt` to indicate location of installed packages. It will also help us to create openwrt build friendly environment, inside a specific shell [tab](https://en.wikipedia.org/wiki/Tab_%28interface%29 "https://en.wikipedia.org/wiki/Tab_(interface)")/instance in shell-manager software like `Terminal`.

- This is to allow packages from pkg-mngr (which we will install in next step) to be used, instead of the macOS provided ones.

Based on your pkg-mngr *(package-manager)*, follow one of the below appropriate section**:**

● For **x86\_64** Apple hardware, &amp; when you have **MacPorts** pkg-mngr, then create `env.sh` file with below content, save it inside `/Volumes/OpenWrt` location**:**

[env.sh](/_export/code/docs/guide-developer/toolchain/buildroot.exigence.macosx?codeblock=21 "Download Snippet")

```
#!/opt/local/bin/bash
PS1='\h:\W \u\$ ';PS2='> ';PS4='+ ';
# Bring PATH lines from the ~/.bash_profile file into below:
PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
PATH="$PATH:/opt/macports/bin:/opt/macports/sbin"
# Adding path of macports port packages, in ahead of others:
PATH="/opt/local/libexec/gnubin:/opt/local/bin:/opt/local/sbin:/opt/local/libexec:/opt/local/x86_64-apple-darwin19.6.0/bin:$PATH";
# Load PATH into currently running shell:
export PATH;
# Load other environment variables:
export JAVA_HOME=/Library/Java/JavaVirtualMachines/openjdk7-zulu/Contents/Home
```

- turn the `env.sh` file an executable shell script file with this command**:**
  
  ```
  chmod +x /Volumes/OpenWrt/env.sh
  ```
- For **MacPorts** create `MacPorts.sh` file in your home `~/` directory with this command**:**
  
  ```
  sudo nano ~/MacPorts.sh
  ```
- find the PATH variables lines in your `~/.bash_profile` file, and add into below content, then copy all from below &amp; paste into `~/MacPorts.sh` file. You can also download below code as a file, then change upper 2 PATH variables, to match with your PATH inside your `~/.bash_profile` file**:**
  
  [MacPorts.sh](/_export/code/docs/guide-developer/toolchain/buildroot.exigence.macosx?codeblock=24 "Download Snippet")
  
  ```
  #!/opt/local/bin/bash
  PS1='\h:\W \u\$ ';PS2='> ';PS4='+ ';
  # Bring PATH lines from the ~/.bash_profile file into below:
  PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
  PATH="$PATH:/opt/macports/bin:/opt/macports/sbin"
  # Bring last PATH line from the /Volumes/OpenWrt/env.sh file into below:
  PATH="/opt/local/libexec/gnubin:/opt/local/bin:/opt/local/sbin:/opt/local/libexec:/opt/local/x86_64-apple-darwin19.6.0/bin:$PATH";
  # Load PATH into currently running shell program:
  export PATH;
  # Load other environment variables:
  export JAVA_HOME=/Library/Java/JavaVirtualMachines/openjdk7-zulu/Contents/Home
  ```
- turn the `MacPorts.sh` file an executable shell script file with this command**:**
  
  ```
  chmod +x ~/MacPorts.sh
  ```

● For **x86\_64** Apple hardware, &amp; when you have **homebrew**, then create `env.sh` file with below content**:**

```
PATH="/usr/local/opt/make/libexec/gnubin:$PATH"
PATH="/usr/local/opt/gnu-getopt/bin:$PATH"
PATH="/usr/local/opt/gettext/bin:$PATH"
PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
PATH="/usr/local/opt/findutils/libexec/gnubin:$PATH"
export PATH
```

● For **arm64** (Apple Silicon(M1)) Apple hardware, &amp; when you have **homebrew**, then create `env.sh` file with below content**:**

```
PATH="/opt/homebrew/opt/make/libexec/gnubin:$PATH"
PATH="/opt/homebrew/opt/gnu-getopt/bin:$PATH"
PATH="/opt/homebrew/opt/gettext/bin:$PATH"
PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
PATH="/opt/homebrew/opt/findutils/libexec/gnubin:$PATH"
export PATH
```

● Optional**:**

- you may check [homebrew official page](https://docs.brew.sh/Installation "https://docs.brew.sh/Installation") or [MacPorts-guide](https://guide.macports.org/ "https://guide.macports.org/") if you need more information related to PATH variable, or other info on pkg-mngr.
- turn `env.sh` file an executable shell script file**:** `chmod +x /Volumes/OpenWrt/env.sh`

#### G. Install necessary packages:

Install necessary packages via pkg-mngr, packages which help to build openwrt components. Use below commands inside a shell instance/tab in `Terminal`. Note: Packages will be installed inside macOS default volume, not inside `/Volumes/OpenWrt`

Based on your pkg-mngr *(package-manager)* follow one of the below appropriate section**:**

● if you have **homebrew** pkg-mngr then run this command**:**

```
brew install coreutils findutils gawk grep gnu-getopt gnu-tar wget diffutils git-extras quilt svn make ncurses pkg-config
```

- in above, homebrew command does **not** include the pre-requisites (aka: dependencies) packages mentioned [here](/docs/guide-developer/toolchain/install-buildsystem "docs:guide-developer:toolchain:install-buildsystem").

● if you have **MacPorts** pkg-mngr then run below 2 commands**:**

```
source ~/MacPorts.sh
sudo port install libiconv gettext-runtime coreutils findutils gwhich gawk zlib pcre bzip2 ncurses grep getopt gettext-tools-libs gettext diffutils sharutils util-linux libxslt libxml2 help2man readline gtime gnutar unzip zip lzma xz libelf fastjar libusb libftdi0 expat sqlite3 openssl3 openssl kerberos5 dbus lz4 libunistring nettle icu gnutls p11-kit wget quilt subversion gmake pkgconfig libzip cdrtools ccache curl xxhashlib rsync libidn perl5 p5.28-xml-parser p5.30-xml-parser p5-extutils-makemaker p5-data-dumper boost-jam boost boost-build bash bash-completion binutils m4 flex intltool patchutils swig git-extras git openjdk17 openjdk7-zulu luajit libtool glib2 file python27 python310 libzzip mercurial asciidoc sdcc gnu-classpath
```

- in above, MacPorts command includes the pre-requisites (aka: dependencies) packages mentioned [here](/docs/guide-developer/toolchain/install-buildsystem "docs:guide-developer:toolchain:install-buildsystem"). Space initially used by all of these packages **:** 4,190,442,792 bytes (2.57 GB on disk) for 129,623 items, (as of March-11, 2022). Note**:** As different packages are continuously modified &amp; improved by their devs or releaser or adopter or maintainer, so their occupying space size &amp; items count will be different in your computer in different time.

● Optional tools via MacPorts**:**

- if you need `picocom` tool to communicate with router via [serial](/docs/techref/hardware/port.serial "docs:techref:hardware:port.serial") adapter/cable[1](/docs/techref/hardware/port.serial.cables "docs:techref:hardware:port.serial.cables") connection, then**:**
  
  ```
  sudo port install picocom
  ```
- if you need last stable `openssh` (aka: `ssh`), `sftp`, `scp` tools for [secure](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration") communication or file-transfer, then**:**
  
  ```
  sudo port install openssh
  ```
- if you need to use last stable `telnet`[1](/toh/netgear/telnet.console "toh:netgear:telnet.console"), `ftp`, `rsh`, `rlogin`, `tftp`[1](/docs/guide-user/troubleshooting/tftpserver "docs:guide-user:troubleshooting:tftpserver") tools and corresponding daemons/servers, then**:**
  
  ```
  sudo port install inetutils
  ```
  
  - if you need other type of bundled packages, then look here: [1](https://ports.macports.org/search/?q=utils&name=on "https://ports.macports.org/search/?q=utils&name=on").
  - if you need other TFTP daemon/server (`tftpd`), then you may try below. TFTP server alows to [receive](/docs/guide-user/troubleshooting/tftpserver "docs:guide-user:troubleshooting:tftpserver") files from router, or allows (bricked) router to boot from TFTP server, etc**:**
    
    ```
    sudo port install tftp-hpa
    ```
- if you need these type of tools, (more info: [1](https://ports.macports.org/category/cross/ "https://ports.macports.org/category/cross/")), then**:**
  
  ```
  sudo port install arm-elf-binutils i386-elf-binutils m68k-elf-binutils mips-elf-binutils x86_64-elf-binutils
  ```

#### H. Optional-step: Start build friendly shell:

macOS by default uses a very old version of `bash` [shell](https://en.wikipedia.org/wiki/Comparison_of_command_shells "https://en.wikipedia.org/wiki/Comparison_of_command_shells"). So, we can+should start a build/compile friendly common last+stable or recent version of **bash** shell inside macOS-Terminal's specific `tab`, as such recent version can be obtained &amp; used by most developer users. Shell-manager software `Terminal` can run multiple shell instances, by using multiple Terminal-tabs. Select one (or more) Terminal-tab(s) to use for openwrt build purpose, then run below command to have same (last+stable) build environment.

● If you installed new **bash** package, then start new bash shell inside a specific tab in Terminal, (when you have **MacPorts** based bash package), with this command**:**

```
exec /opt/local/bin/bash
```

● optional**:**

- approve/permit new bash shell in macOS with this command**:**  
  `echo “/opt/local/bin/bash” | sudo tee -a /private/etc/shells`
- if you want to continue to use the new bash always, then: click on apple **** symbol in topside apple menu-bar &gt; `System Preferences...` &gt; `Users & Groups` &gt; Unlock the 🔒pane &gt; control click on your user-name &gt; select `Advanced Options...` &gt; then update/change the `Login shell` into `/opt/local/bin/bash` &gt; `ok`.

#### I. Load build environment:

We need to load build package locations indicator file as shell environment. OpenWRT developing (aka: building, aka: compiling, aka: compilation) is done inside a suitable (aka: build friendly) shell environment. So, we have to allow openwrt build commands to find packages that we installed via pkg-mngr, by loading build package location indicator file **`env.sh`** into one of the `Terminal` shell environment tab, to create that openwrt build friendly &amp; suitable shell environment.

When developing (aka: building, aka: compiling), run below command to set up build-friendly PATH (and other) variable(s). This leaves your system in a clean state without symlinking.

```
source /Volumes/OpenWrt/env.sh
```

- Optional **:** So from next time or after a reboot, when you want to enter into openwrt build mode, then run below 2 commands inside a specific tab in Terminal, when you have MacPorts based bash package**:**
  
  ```
  exec /opt/local/bin/bash
  source /Volumes/OpenWrt/env.sh
  ```

#### J. Build:

Now proceed normally, (that is, start to follow build related other steps/procedures shown in parent/previous page).

# Other Tools:

Some users may need below some of the tool.

## B43-FWCutter

Users who are developing openwrt firmware for Broadcom (BCM) 43xx chipset, *(to use in OpenWRT)*, those users need this b43-fwcutter tool to extract wireless drivers from firmware.

- More info [here](https://wireless.wiki.kernel.org/en/users/drivers/b43 "https://wireless.wiki.kernel.org/en/users/drivers/b43").
- Package manager `homebrew` has this tool, and `MacPorts` does not.
  
  - Users of `MacPorts` can obtain source[1](https://bues.ch/cms/hacking/misc.html#linux_b43_driver_firmware_tools "https://bues.ch/cms/hacking/misc.html#linux_b43_driver_firmware_tools"), [2](https://cgit.freebsd.org/ports/tree/sysutils/b43-fwcutter "https://cgit.freebsd.org/ports/tree/sysutils/b43-fwcutter"), [3](https://github.com/mbuesch/b43-tools "https://github.com/mbuesch/b43-tools"), [4](https://sourceforge.net/projects/bcm43xx.berlios/files/ "https://sourceforge.net/projects/bcm43xx.berlios/files/") &amp; compile, or get [it](https://freebsd.pkgs.org/13/freebsd-amd64/b43-fwcutter-019.pkg.html "https://freebsd.pkgs.org/13/freebsd-amd64/b43-fwcutter-019.pkg.html")[1](https://pkg.freebsd.org/FreeBSD:13:amd64/latest/All/b43-fwcutter-019.pkg "https://pkg.freebsd.org/FreeBSD:13:amd64/latest/All/b43-fwcutter-019.pkg") from FreeBSD pkg.

## Golang related

Golang[1](https://en.wikipedia.org/wiki/Go_%28programming_language%29 "https://en.wikipedia.org/wiki/Go_(programming_language)"): For darwin/arm64 and linux/aarch64 golang package (feed “packages”) golang C-bootstrap method doesn't work, but it is possible to use external golang bootstrap. On MacOS arm64 the easiest way is to install golang using brew and use installed golang as bootstrap:

- ```
  brew install golang
  ```
- Then set CONFIG\_GOLANG\_EXTERNAL\_BOOTSTRAP\_ROOT=“/opt/homebrew/opt/go/libexec” in .config file

# Optional Tools:

optional tools, drivers, software, etc for macOS, to assist into build/compile process, &amp; to increase security.

## Software Tools:

No need to install these, unless you specifically need such tool/app/utility to assist your build related works. Here is a small list of some optional/extra tools related to openwrt software code build &amp; test &amp; usage &amp; diagnostics, etc, and also list of some optional/extra tools related to network device test/diagnostics, etc to run/use in macOS (apple macintosh operating system) and apple hardware. For more, goto [wp](https://en.wikipedia.org/wiki/List_of_Macintosh_software "https://en.wikipedia.org/wiki/List_of_Macintosh_software").

● *XQuartz* ([dev](https://www.xquartz.org/ "https://www.xquartz.org/"), [wp](https://en.wikipedia.org/wiki/XQuartz "https://en.wikipedia.org/wiki/XQuartz"), [src](https://github.com/XQuartz/XQuartz "https://github.com/XQuartz/XQuartz"), [dnld](https://github.com/XQuartz/XQuartz/releases/ "https://github.com/XQuartz/XQuartz/releases/")) : it allows cross-platform (GNU-Linux, etc) apps/tools (which were developed to use `X11` GUI), to run on macOS &amp; use macOS's native `Quartz` GUI, etc. Many GUI apps/tools need this. It is opensource tool.

● *PeaZip* ([dev](https://peazip.github.io/ "https://peazip.github.io/"), [dnld](https://sourceforge.net/projects/peazip/files/ "https://sourceforge.net/projects/peazip/files/"), [src](https://github.com/peazip/PeaZip "https://github.com/peazip/PeaZip"), [wp](https://en.wikipedia.org/wiki/PeaZip "https://en.wikipedia.org/wiki/PeaZip"), [comparison](https://en.wikipedia.org/wiki/Comparison_of_file_archivers "https://en.wikipedia.org/wiki/Comparison_of_file_archivers")) : it is a free &amp; opensource archiver (zip, compress) &amp; unarchiver (unzip, decompress) app/tool. GUI *(Graphical User Interface)* based. Allows to create: 7Z, ARC, Brotli, BZ2 (BZip), GZ (GZip), PAQ/ZPAQ, PEA, QUAD/BALZ/BCM, sfx, TAR, WIM, XZ, ZPAQ, ZIP, Zstandard, etc, and peazip allows to Open &amp; Extract 200+ file types: ACE, CAB, DEB, ISO, RAR, UDF, ZIPX, etc. Do not download this app from any other website.

● *GnuPG for OSX* ([dev](https://sourceforge.net/projects/gpgosx/ "https://sourceforge.net/projects/gpgosx/"), [dnld](https://sourceforge.net/projects/gpgosx/files/ "https://sourceforge.net/projects/gpgosx/files/")) : verifies file's/message's authenticity. [GnuPG](https://gnupg.org/ "https://gnupg.org/") is aka *(also known as)* [GPG](https://en.wikipedia.org/wiki/GNU_Privacy_Guard "https://en.wikipedia.org/wiki/GNU_Privacy_Guard"). We need this tool to verify/authenticate downloaded files *(or messages)* to find-out whether files *(or messages)* are indeed what actual file *(or message)* creator/author/developer actually released/shared/created/sent, So this tool will indicate/tell us whether received files *(or messages)* were modified/altered/changed/abused/corrupted by someone or some-device in the middle of file/msg travel path or during file/msg travel path, or this tool will indicate to us NO modification was done during file/msg travel path. File's *(or message's)* actual creator/developer shares their *(GnuPG/GPG or PGP or [OpenPGP](https://en.wikipedia.org/wiki/Pretty_Good_Privacy#OpenPGP "https://en.wikipedia.org/wiki/Pretty_Good_Privacy#OpenPGP") based)* crypto *([cryptographic](https://en.wikipedia.org/wiki/Public-key_cryptography "https://en.wikipedia.org/wiki/Public-key_cryptography"))* digital **pub**-key file as **pub** file or as **asc** file with public. Most trustworthy way to obtain such pub-key is: goto a [KSP](https://en.wikipedia.org/wiki/Key_signing_party "https://en.wikipedia.org/wiki/Key_signing_party") or conference and meet actual file/msg creator/developer &amp; obtain pub-key file directly, (or else, the next (slightly-less) trustworthy solution is: use [WoT](https://en.wikipedia.org/wiki/Web_of_trust "https://en.wikipedia.org/wiki/Web_of_trust") &amp; inspect pub-key components to compare &amp; verify a pub-key's authenticity). File/msg creator/developer [signs](https://en.wikipedia.org/wiki/Digital_signature "https://en.wikipedia.org/wiki/Digital_signature") main-file *(or main-msg)* with their **prv**-key, &amp; that creates an unique **sig** *(signature)* file for a main-file *(or main-msg)*, then file/msg creator/dev shares main-file *(or main-msg)* &amp; sig-file with public. This (GnuPG) tool can use sig-file, pub-key file, &amp; main-file *(or main-msg)*, &amp; can indicate if the main-file *(or main-msg)* was actually released by the actual holder of the pub-key, or not. Install a GUI frontend / wrapper for this tool.

- to know directory location of installed `gpg2` which your system will find (via PATH env var) &amp; use, run **:** `which gpg2`
- the GnuPG tool can also be loaded via MacPorts pkg-mngr, when you run this command **:** `sudo port install gnupg2`
- *GpgFrontend* ([dev](https://www.gpgfrontend.pub/ "https://www.gpgfrontend.pub/"), [src](https://github.com/saturneric/GpgFrontend "https://github.com/saturneric/GpgFrontend"), [dnld](https://github.com/saturneric/GpgFrontend/releases "https://github.com/saturneric/GpgFrontend/releases")) : opensource, free tool to authenticate file, to authenticate message, etc. it contains OpenPGP crypto tool and can also function as a frontend / wrapper for GnuPG. See `GnuPG for OSX` item in above.

● *DevUtils* ([dev](https://github.com/DevUtilsApp/DevUtils-app "https://github.com/DevUtilsApp/DevUtils-app"), [dnld](https://devutils.app/ "https://devutils.app/"), [appstore](https://apps.apple.com/us/app/id1533756032 "https://apps.apple.com/us/app/id1533756032")) : it has various functionalities to perform various development related activities. App is free &amp; opensource, but source-code requires a payment.

- Various tools/apps for Build, Deployment, etc are here: [1](https://github.com/smashism/awesome-macadmin-tools "https://github.com/smashism/awesome-macadmin-tools").

● *TimeUTC* ([AppStore](https://apps.apple.com/us/app/timeutc/id1293572792?mt=12 "https://apps.apple.com/us/app/timeutc/id1293572792?mt=12")) : it can add a second date &amp; clock in your topside apple  menu bar, to display current UTC time &amp; date. freeware.

● *PumpKIN* ([dev](https://kin.klever.net/pumpkin/ "https://kin.klever.net/pumpkin/"), [src](https://kin.klever.net/pumpkin/repository/ "https://kin.klever.net/pumpkin/repository/")[2](https://github.com/hacker/pumpkin "https://github.com/hacker/pumpkin"), [dnld](https://kin.klever.net/pumpkin/binaries/ "https://kin.klever.net/pumpkin/binaries/")) : opensource &amp; free &amp; GUI based. it is a TFTP server &amp; client app, *(with builtin TFTP server &amp; client functionalities)*. For macOS *(and Windows)*. It was tested &amp; can run on macOS `Mountain Lion`. TFTP can abused/exploited to do harmful things, so keep it firewalled or disable it after you are done working with this app, and also disable it when you pause to work on something else. Do not keep this running. More info [here](/docs/guide-user/troubleshooting/tftpserver "docs:guide-user:troubleshooting:tftpserver").

● *FileZilla* ([dev](https://filezilla-project.org/ "https://filezilla-project.org/"), [dnld](https://filezilla-project.org/download.php?type=client "https://filezilla-project.org/download.php?type=client"), [src](https://svn.filezilla-project.org/filezilla/FileZilla3/ "https://svn.filezilla-project.org/filezilla/FileZilla3/"), [comparison](https://en.wikipedia.org/wiki/Comparison_of_FTP_client_software "https://en.wikipedia.org/wiki/Comparison_of_FTP_client_software")) : it is a client app for FTP, FTP over TLS (FTPS), SFTP SSH, SFTP. Opensource &amp; free &amp; GUI based. Do not download this app from any other website.

● *ProFTPD* ([dev](http://www.proftpd.org/ProFTPD "http://www.proftpd.org/ProFTPD"), [dnld](https://github.com/proftpd/proftpd/releases "https://github.com/proftpd/proftpd/releases"), [src](https://github.com/proftpd/proftpd "https://github.com/proftpd/proftpd"), [comparison](https://en.wikipedia.org/wiki/Comparison_of_FTP_client_software "https://en.wikipedia.org/wiki/Comparison_of_FTP_client_software")) : For FTP / FTPS / SFTP server. opensource &amp; free. CLI based. Get a GUI frontend / wrapper for this tool.

- And also get web (GUI) based admin interface app *proFTPd-admin* (from [here](https://sourceforge.net/projects/proftpd-adm/ "https://sourceforge.net/projects/proftpd-adm/")) for ProFTPD. Do not keep this app running, when you pause to work on something else. It can be abused / exploited to do harmful things.

● *Github Desktop for Mac* ([dev](https://desktop.github.com/ "https://desktop.github.com/")) : allows a developer user to access &amp; collaborate &amp; develop software, etc on Github.com site. GUI based free app.

● *TextMate* ([dev](https://github.com/textmate/textmate "https://github.com/textmate/textmate"), [dnld](https://macromates.com/download "https://macromates.com/download"), [comparison](https://en.wikipedia.org/wiki/Comparison_of_text_editors "https://en.wikipedia.org/wiki/Comparison_of_text_editors")) : a text editor. Opensource &amp; GUI based free app. Few features : multi tabs, multi windows, regex based search &amp; replacement, etc.

● *Kate* ([dev](https://kate-editor.org/ "https://kate-editor.org/"), [dnld](https://kate-editor.org/get-it/ "https://kate-editor.org/get-it/")) : opensource &amp; free code/text editor.

● *LuLu* ([dev](https://github.com/objective-see/LuLu "https://github.com/objective-see/LuLu")) : it is GUI based &amp; free &amp; opensource firewall app to control outbound internet data traffic of apps/tools in macOS.

● *Loading* ([dev](https://github.com/BonzaiThePenguin/Loading "https://github.com/BonzaiThePenguin/Loading")) : it can show a spinning progress wheel in  menu bar when network is being used by app/tool. Clicking the icon can show the apps/tools that are using network, &amp; holding down the option key can show individual processes. Opensource, free &amp; GUI based tool.

● *OpenSSH (Portable)* ([dev](https://www.openssh.com/ "https://www.openssh.com/"), [src](https://github.com/openssh/openssh-portable "https://github.com/openssh/openssh-portable"), [dnld-src](https://www.openssh.com/portable.html#http "https://www.openssh.com/portable.html#http"), [comparison](https://en.wikipedia.org/wiki/Comparison_of_SSH_clients "https://en.wikipedia.org/wiki/Comparison_of_SSH_clients")) : opensource &amp; free. it is a remote-access client tool to connect with SSH-servers[1](https://en.wikipedia.org/wiki/Comparison_of_SSH_servers "https://en.wikipedia.org/wiki/Comparison_of_SSH_servers"). It can encrypt all traffic into SSH-server to eliminate eavesdropping, connection hijacking, and other attacks, it has large suite of secure tunneling capabilities, several authentication methods, and sophisticated configuration options. Includes ssh, scp, sftp[1](https://en.wikipedia.org/wiki/SSH_File_Transfer_Protocol "https://en.wikipedia.org/wiki/SSH_File_Transfer_Protocol"), ssh-add, ssh-agent, ssh-keygen, ssh-keyscan. Source can be compiled/built in macOS, or download openssh from macports pkg-mngr, or download dependencies via macports &amp; then build/compile. CLI based. Get a GUI wrapper / frontend for this tool.

● *Fugu* ([dev](http://rsug.itd.umich.edu/software/fugu "http://rsug.itd.umich.edu/software/fugu"), [src](https://sourceforge.net/p/fugussh/ "https://sourceforge.net/p/fugussh/")-2, [wp](https://en.wikipedia.org/wiki/Fugu_%28software%29 "https://en.wikipedia.org/wiki/Fugu_(software)")) : a free &amp; opensource &amp; GUI based frontend / wrapper for OpenSSH ssh,sftp,scp, etc commandline tools. Very old, but still useful to handle SSH keys, etc. It is a SFTP client, SSH app.

● *PuTTY* ([dev](https://www.chiark.greenend.org.uk/~sgtatham/putty/ "https://www.chiark.greenend.org.uk/~sgtatham/putty/"), [wp](https://en.wikipedia.org/wiki/PuTTY "https://en.wikipedia.org/wiki/PuTTY"), [src](https://git.tartarus.org/?p=simon%2Fputty.git "https://git.tartarus.org/?p=simon/putty.git")) : it is a free &amp; open-source terminal emulator, serial console and network file transfer tool, &amp; supports several network protocols: SCP, SSH, Telnet, rlogin, and raw socket connection. Actually developed for Windows OS, but has been ported into MacPorts pkg-mngr to use in macOS. GUI based. To install via Macports pkg-mngr, run**:** `sudo port install putty`

- PuTTY in MacPorts needs these dependencies *(these wil be auto-loaded by macports):* pkgconfig, gtk2. And `gtk2` needs these dependenicies**:** gtk-doc, pkgconfig, perl5, autoconf, automake, libtool, xz, atk, pango, gdk-pixbuf2, gobject-introspection, xorg-libXi, xorg-libXrandr, xorg-libXcursor, xorg-libXinerama, xorg-libXdamage, xorg-libXcomposite, xorg-libXfixes, shared-mime-info, hicolor-icon-theme.

● *Coccinellida* ([dev](https://sourceforge.net/projects/coccinellida/ "https://sourceforge.net/projects/coccinellida/"), [dnld](https://sourceforge.net/projects/coccinellida/files/ "https://sourceforge.net/projects/coccinellida/files/")) : a simple SSH tunnel manager app. opensource, free. GUI based.

● *STM (SSH Tunnel Manager)* ([dev](https://www.tynsoe.org/stm/ "https://www.tynsoe.org/stm/"), [doc](https://www.tynsoe.org/stm/documentation/ "https://www.tynsoe.org/stm/documentation/"), [appstore](http://itunes.apple.com/us/app/ssh-tunnel-manager/id424470626?mt=12 "http://itunes.apple.com/us/app/ssh-tunnel-manager/id424470626?mt=12")) : it can manage multiple ssh tunnels / connections: local, remote, socks-proxy, etc. it is a GUI based fronend / wrapper for ssh tool, but for socks-proxy it can use builtin ssh on some situations. freeware. not-opensource. GUI based &amp; also frontend for SSH.

● *OpenVPN Connect* ([dev](https://openvpn.net/ "https://openvpn.net/"), [dnld](https://openvpn.net/download-open-vpn/ "https://openvpn.net/download-open-vpn/"), [appstore](https://itunes.apple.com/us/app/openvpn-connect/id590379981?mt=8 "https://itunes.apple.com/us/app/openvpn-connect/id590379981?mt=8"), [community-dnld](https://openvpn.net/community-downloads/ "https://openvpn.net/community-downloads/"), [wp](https://en.wikipedia.org/wiki/OpenVPN "https://en.wikipedia.org/wiki/OpenVPN")) : opensource &amp; free. VPN *(virtual private network)* connector client tool. GUI based. *(There are many other types of VPN[1](https://en.wikipedia.org/wiki/Virtual_private_network "https://en.wikipedia.org/wiki/Virtual_private_network") connector client/server app/tool)*.

● *TunnelBlick* ([dev](https://github.com/Tunnelblick/Tunnelblick "https://github.com/Tunnelblick/Tunnelblick")) : a free &amp; opensource &amp; GUI based frontend / wrapper for OpenVPN commandline tool.

● *WireShark* ([dev](https://www.wireshark.org/ "https://www.wireshark.org/"), [dnld](https://www.wireshark.org/#download "https://www.wireshark.org/#download"), [src](https://gitlab.com/wireshark/wireshark.git "https://gitlab.com/wireshark/wireshark.git"), [comparison](https://en.wikipedia.org/wiki/Comparison_of_packet_analyzers "https://en.wikipedia.org/wiki/Comparison_of_packet_analyzers"), [wiki](https://gitlab.com/wireshark/wireshark/-/wikis/home "https://gitlab.com/wireshark/wireshark/-/wikis/home")) : it is a network data packet analyzer (aka: network protocol analyzer = NPA) software. Opensource, free &amp; GUI based.

● *VirtualBox* ([dev](https://www.virtualbox.org/ "https://www.virtualbox.org/"), [dnld](https://www.virtualbox.org/wiki/Downloads "https://www.virtualbox.org/wiki/Downloads"), [comparison](https://en.wikipedia.org/wiki/Comparison_of_platform_virtualization_software "https://en.wikipedia.org/wiki/Comparison_of_platform_virtualization_software")[2](https://en.wikipedia.org/wiki/Comparison_of_application_virtualization_software "https://en.wikipedia.org/wiki/Comparison_of_application_virtualization_software")) : a free &amp; opensource &amp; GUI based virtualizer software (from Oracle) to create (software based) virtual-machine (VM) inside a hardware based host machine. So with this app, user can run+use multiple+different operating systems (OS) simultaneously. User can create VM as client, VM as server, client+server VM, Desktop OS VM, Mobile OS VM, etc, etc. First version used codes from QEMU. It can emulate these (hardware) architectures as VM: x86, x86-64.

● *QEMU* ([dev](https://www.qemu.org/ "https://www.qemu.org/"), [dnld](https://www.qemu.org/download/#macos "https://www.qemu.org/download/#macos"), [src](https://git.qemu.org/git/qemu.git "https://git.qemu.org/git/qemu.git"), [wp](https://en.wikipedia.org/wiki/QEMU "https://en.wikipedia.org/wiki/QEMU")) : it is free &amp; opensource. It is a generic &amp; open source machine emulator and virtualizer. It can emulate various (hardware) architectures as VM, such as: x86, x86-64, MIPS64 (up to Release 6), SPARC (sun4m and sun4u) (32/64), ARM (Integrator/CP and Versatile/PB), SuperH, PowerPC (PReP and Power Macintosh), ETRAX CRIS, MicroBlaze, and RISC-V, OpenRisc32, Alpha, LM32, M68k, S/390, SH4, Unicore32, Xtensa, etc.

● *NTFS for Mac* (Microsoft NTFS for Mac By Tuxera) ([dev](https://ntfsformac.tuxera.com/ "https://ntfsformac.tuxera.com/")) : The functionality or ability to read NTFS partitions inside macOS is very helpful feature to transfer file(s) between Windows NTFS partition HDD/SSD and your APFS *(apple macOS file-system)*. This “NTFS for Mac” by Tuxera tool is not free *(aka: as freedom of software)*, it is proprietary (non-opensource) tool. Only trial version is freeware for 15days, tiral version has some helpful functionalities. Full functionalities *(after 15 days trial)* requires a payment.

- HDD/SSD storage device MFR (aka: manufacturers) also includes `NTFS for Mac` (*Microsoft NTFS for Mac By Paragon*[1](https://www.paragon-software.com/home/ntfs-mac/ "https://www.paragon-software.com/home/ntfs-mac/"), etc) software for macOS, with their some HDD/SSD storage device, So if you purchased such HDD/SSD or if your HDD/SSD drive *(in your computer)* matches with MFR's such HDD/SSD then you may use that full-version `NTFS for Mac` *(by Paragon)* software (by obtaining it from HDD/SSD MFR's website). a 10-day trial-version is here: [1](https://www.paragon-software.com/home/ntfs-mac/ "https://www.paragon-software.com/home/ntfs-mac/").
- Earlier helpful software *FUSE for macOS*[1](https://osxfuse.github.io/ "https://osxfuse.github.io/"), [2](https://github.com/libfuse/libfuse "https://github.com/libfuse/libfuse"), [3](https://en.wikipedia.org/wiki/Filesystem_in_Userspace "https://en.wikipedia.org/wiki/Filesystem_in_Userspace") is not anymore `free` (as in freedom of software) for macOS, it is now proprietary for macOS. The *Mounty for NTFS*[1](https://mounty.app/ "https://mounty.app/") and *NTFS-3G*[1](https://github.com/tuxera/ntfs-3g "https://github.com/tuxera/ntfs-3g"), [2](https://www.tuxera.com/community/ntfs-3g-download/ "https://www.tuxera.com/community/ntfs-3g-download/") are free &amp; opensource, but slow. Linux kernel v5.15 &amp; onward has began to support NTFS[1](https://www.kernel.org/doc/html/latest/filesystems/ntfs3.html "https://www.kernel.org/doc/html/latest/filesystems/ntfs3.html") 3.1 &amp; earlier versions, NTFS driver was provided by Paragon.

● *GPT fdisk (gdisk)* ([dev](https://www.rodsbooks.com/gdisk/ "https://www.rodsbooks.com/gdisk/"), [dnld](https://sourceforge.net/projects/gptfdisk/files/ "https://sourceforge.net/projects/gptfdisk/files/"), [list](https://en.wikipedia.org/wiki/List_of_disk_partitioning_software "https://en.wikipedia.org/wiki/List_of_disk_partitioning_software")) : opensource &amp; free partition manager tool. gdisk has TUI *(text-based semi-graphical user interface)* interface. gdisk can edit GUID partition table (GPT) definitions in Linux, FreeBSD, MacOS X, or Windows, it can convert MBR to GPT without data loss, convert BSD disklabels to GPT without data loss, create hybrid MBR or convert GPT to MBR without data loss, repair damaged GPT data structures, repair damaged MBR data structures (FixParts). macOS 10.11.x (“El Capitan”) and later created some areas *(and layers)* of partitions “rootless”, so users need to either disable[1](http://osxdaily.com/2015/10/05/disable-rootless-system-integrity-protection-mac-os-x/ "http://osxdaily.com/2015/10/05/disable-rootless-system-integrity-protection-mac-os-x/") SIP *(System Integrity Protection)*, or Run it from a bootable USB/CD/DVD storage disk/media (by using partition manager tools like: *PartedMagic*[1](https://PartedMagic.com/ "https://PartedMagic.com/")). Obviously using trustworthy bootable disk is better idea+method. gdisk can work on external / USB media / disk / drive fine (without disabling SIP in macOS). it can also be installed via MacPorts pkg-mngr: `sudo port install gptfdisk`

- *Paragon Hard Disk Manager for Mac* ([dev](https://www.paragon-software.com/hdm-mac/ "https://www.paragon-software.com/hdm-mac/")) : it is a commercial &amp; non-opensource software, GUI based. it can manage drive/disk partitions. a 10-day trial version is [here](https://main-site-preproduction.paragon-software.com/us/hdm-mac/ "https://main-site-preproduction.paragon-software.com/us/hdm-mac/#") for macOS. A community edition of *(Paragon Partition Manager)* is avilable which is not-trial &amp; can continue to function for non-commercial use purpose only, but available only for Windows 7 &amp; higher OS, [here](https://www.paragon-software.com/free/pm-express/ "https://www.paragon-software.com/free/pm-express/").

● *UNetbootin* ([dev](https://unetbootin.github.io/ "https://unetbootin.github.io/"), [dnld](https://sourceforge.net/projects/unetbootin/files/UNetbootin/ "https://sourceforge.net/projects/unetbootin/files/UNetbootin/")[2](https://github.com/unetbootin/unetbootin/releases/ "https://github.com/unetbootin/unetbootin/releases/"), [list](https://en.wikipedia.org/wiki/List_of_tools_to_create_Live_USB_systems "https://en.wikipedia.org/wiki/List_of_tools_to_create_Live_USB_systems"), [comparison](https://en.wikipedia.org/wiki/Comparison_of_boot_loaders "https://en.wikipedia.org/wiki/Comparison_of_boot_loaders")) : opensource &amp; free boot disk creator. GUI based. it allows to create bootable Live USB drives for booting Ubuntu, Fedora, and other Linux distributions without burning a CD. It can run on *(Windows, Linux, and)* macOS. You can either let UNetbootin download one of the many distributions supported out-of-the-box for you, or you can supply your own *(Linux, etc)* .iso file.

● *Clonezilla* ([dev](https://clonezilla.org/ "https://clonezilla.org/"), [src](https://sourceforge.net/projects/clonezilla/files/clonezilla_live_stable/ "https://sourceforge.net/projects/clonezilla/files/clonezilla_live_stable/"), [dnld](https://clonezilla.org/downloads.php "https://clonezilla.org/downloads.php"), [comparison](https://en.wikipedia.org/wiki/Comparison_of_disk_cloning_software "https://en.wikipedia.org/wiki/Comparison_of_disk_cloning_software")-(clone), [comparison](https://en.wikipedia.org/wiki/Comparison_of_disc_image_software "https://en.wikipedia.org/wiki/Comparison_of_disc_image_software")-(img), [list](https://en.wikipedia.org/wiki/List_of_disk_cloning_software "https://en.wikipedia.org/wiki/List_of_disk_cloning_software")-(clone), [list](https://en.wikipedia.org/wiki/List_of_data_recovery_software "https://en.wikipedia.org/wiki/List_of_data_recovery_software")-(recovery) ) : it is opensource &amp; free tool to clone/backup/copy drive &amp; partitions, from Linux OS. it has TUI *(text-based semi-graphical user interface)* based interface. Supports: FAT12, FAT16, FAT32, NTFS, ext2, ext3, ext4, ReiserFS, Reiser4, xfs, jfs, btrfs, f2fs, NILFS2, HFS+, UFS, minix, VMFS3. Obtain Clonezilla's bootable disk img file from Clonezilla dev site, After you boot from that, it will load Debian Linux &amp; it will run Clonezilla. Usually it can be used on *(almost)* any computer (including Mac). Notice: Partitions which are proprietary &amp; very recent &amp; no API/access solution is yet found, support for those partitions are not yet available in this software.

- You can also use *(opensource)* *RescueZilla*[1](https://RescueZilla.com/ "https://RescueZilla.com/") which is a Clonezilla GUI version from another developer, obtain from here: [1](https://github.com/rescuezilla/rescuezilla "https://github.com/rescuezilla/rescuezilla"), *(it also requires booting from USB/external media/disk)*. You can also try *(opensource)* *Redo Rescue*[1](http://RedoRescue.com/ "http://RedoRescue.com/") *(formerly “Redo Backup &amp; Recovery”)* software from here: [dnld](https://sourceforge.net/projects/redobackup/files/ "https://sourceforge.net/projects/redobackup/files/") [src](https://github.com/redorescue/redorescue "https://github.com/redorescue/redorescue"), it is partly based on Clonezila, *(and it also requires booting from USB/external media/disk)*.
- *Acronis True Image 2021 for Mac* ([dev](https://www.acronis.com/en-us/support/trueimage/2021mac/ "https://www.acronis.com/en-us/support/trueimage/2021mac/")) : it is non-opensource &amp; commercial software to clone/backup/copy drive &amp; partitions. GUI based. 30-day trial version is available [here](https://www.acronis.com/en-us/support/trueimage/2021mac/ "https://www.acronis.com/en-us/support/trueimage/2021mac/"). Supports: FAT32, NTFS, HFS+, APFS, ext2, ext3, ext4 and ReiserFS. Some HDD/SSD storage drive MFR *(manufacturers)* include this with their HDD/SSD, so if you've purchased drive or if your drive in your computer matches thier drive, then you can obtain the full-version from HDD/SSD MFR's website.

● *Deluge* ([dev](https://deluge-torrent.org/ "https://deluge-torrent.org/"), [dnld](https://ftp.osuosl.org/pub/deluge/mac_osx/?C=M%3BO%3DD "https://ftp.osuosl.org/pub/deluge/mac_osx/?C=M;O=D"), [comparison](https://en.wikipedia.org/wiki/Comparison_of_BitTorrent_clients "https://en.wikipedia.org/wiki/Comparison_of_BitTorrent_clients")) : a bittorrent network based file-sharing software. free &amp; opensource. Encrypt or Password protect files before sharing, &amp; share password via a separate (private) channel. Filename can have contact info if you wish to be contacted, but remember that such contact info will also be abused by someone out there. More info [here](https://dev.deluge-torrent.org/wiki/Installing/MacOSX#MacPorts "https://dev.deluge-torrent.org/wiki/Installing/MacOSX#MacPorts").

● *Thunderbird* ([dev](https://www.thunderbird.net/ "https://www.thunderbird.net/"), [dnld](https://www.thunderbird.net/thunderbird/all/ "https://www.thunderbird.net/thunderbird/all/"), [src](https://hg.mozilla.org/comm-central "https://hg.mozilla.org/comm-central"), [comparison](https://en.wikipedia.org/wiki/Comparison_of_email_clients "https://en.wikipedia.org/wiki/Comparison_of_email_clients")) : multi data communication-protocol supporting client, but more commonly known as an Email client app *(for viewing, reading, sending emails)*, so it is a PIM[1](https://en.wikipedia.org/wiki/Personal_information_manager "https://en.wikipedia.org/wiki/Personal_information_manager")/PDM[1](https://en.wikipedia.org/wiki/Personal_data_manager "https://en.wikipedia.org/wiki/Personal_data_manager") client *(that supports personal/private information like: emails, address-book, calendar dates, emails, instant messages, passwords, alerts, browsing site data, etc, etc)*. Thunderbird is free &amp; opensource. It is also client app/tool for: newsfeeds[1](https://en.wikipedia.org/wiki/List_of_Usenet_newsreaders "https://en.wikipedia.org/wiki/List_of_Usenet_newsreaders")/newsgroups[1](https://en.wikipedia.org/wiki/List_of_newsgroups "https://en.wikipedia.org/wiki/List_of_newsgroups"), [2](https://en.wikipedia.org/wiki/Comparison_of_Usenet_newsreaders "https://en.wikipedia.org/wiki/Comparison_of_Usenet_newsreaders") *(NNTP[1](https://en.wikipedia.org/wiki/NNTP "https://en.wikipedia.org/wiki/NNTP") client, NNTPS)* , web feeds[1](https://en.wikipedia.org/wiki/Comparison_of_feed_aggregators "https://en.wikipedia.org/wiki/Comparison_of_feed_aggregators"), [2](https://support.mozilla.org/en-US/kb/how-subscribe-news-feeds-and-blogs "https://support.mozilla.org/en-US/kb/how-subscribe-news-feeds-and-blogs") *(news aggregators[1](https://en.wikipedia.org/wiki/News_aggregator "https://en.wikipedia.org/wiki/News_aggregator"), like: Atom[1](https://en.wikipedia.org/wiki/Atom_%28Web_standard%29 "https://en.wikipedia.org/wiki/Atom_(Web_standard)"), RSS[1](https://en.wikipedia.org/wiki/RSS "https://en.wikipedia.org/wiki/RSS"), etc)* client, instant messaging[1](https://support.mozilla.org/en-US/kb/instant-messaging-and-chat "https://support.mozilla.org/en-US/kb/instant-messaging-and-chat") *(aka: chat[1](https://en.wikipedia.org/wiki/Chat_client "https://en.wikipedia.org/wiki/Chat_client") networks, like IRC[1](https://en.wikipedia.org/wiki/IRC "https://en.wikipedia.org/wiki/IRC"), XMPP[1](https://en.wikipedia.org/wiki/XMPP "https://en.wikipedia.org/wiki/XMPP"), Google-Talk, Twitter, Odnoklassniki, etc)* client, address auto-completion (LDAP) client, etc. Thunderbird contains core/engine of Mozilla Firefox web-browser, which allows thunderbird to connect with various types of web-servers / web-sites to use various web-services as HTTP/HTTPS protocols cleints &amp; as other protocols cleints, and firefox web-browser core also allows thunderbird to open[1](https://addons.thunderbird.net/thunderbird/addon/browseintab/ "https://addons.thunderbird.net/thunderbird/addon/browseintab/"), [2](https://addons.thunderbird.net/thunderbird/addon/new-tab-button/ "https://addons.thunderbird.net/thunderbird/addon/new-tab-button/"), [3](https://addons.thunderbird.net/thunderbird/addon/open-tab/ "https://addons.thunderbird.net/thunderbird/addon/open-tab/") multiple web-browser tab(s) *(inside thunderbird)* to be used by users, manually. Send yourself *(a HTML based)* email *(or chat-msg)* with URL-links to various web-site services, then inside thinderbird right-click on link *(inside email or chat-msg)* &amp; select the option to open the link inside a New Tab inside thunderbird[1](https://stackoverflow.com/questions/63253091/ "https://stackoverflow.com/questions/63253091/"), in this way you can use/access various WebMails[1](https://stackoverflow.com/questions/63253091/ "https://stackoverflow.com/questions/63253091/"), [2](https://en.wikipedia.org/wiki/Comparison_of_webmail_providers "https://en.wikipedia.org/wiki/Comparison_of_webmail_providers"), Twitter[1](https://m.twitter.com/ "https://m.twitter.com/"), etc. More info on how to approve cookies &amp; JS for such web-service website and dependent 3rd-party web-services *(inside thunderbird)*, are explained [here](https://stackoverflow.com/questions/63253091/ "https://stackoverflow.com/questions/63253091/"). Thunderbird addons can also allow access to various web-services more easily: Google-Chat[1](https://addons.thunderbird.net/thunderbird/addon/google-chat-tab/ "https://addons.thunderbird.net/thunderbird/addon/google-chat-tab/"), Skype-WebApp[1](https://addons.thunderbird.net/thunderbird/addon/skypewebapp/ "https://addons.thunderbird.net/thunderbird/addon/skypewebapp/"), Telegram-Web[1](https://addons.thunderbird.net/thunderbird/addon/telegramwebapp/ "https://addons.thunderbird.net/thunderbird/addon/telegramwebapp/"), [2](https://addons.thunderbird.net/thunderbird/addon/telegram-web-in-thunderbird/ "https://addons.thunderbird.net/thunderbird/addon/telegram-web-in-thunderbird/"), Google-Voice[1](https://addons.thunderbird.net/thunderbird/addon/open-google-voice/ "https://addons.thunderbird.net/thunderbird/addon/open-google-voice/"), ProtonMail-Encryption-Status[1](https://addons.thunderbird.net/thunderbird/addon/protonmail-encryption-status/ "https://addons.thunderbird.net/thunderbird/addon/protonmail-encryption-status/"), regimail[1](https://addons.thunderbird.net/thunderbird/addon/regimail/ "https://addons.thunderbird.net/thunderbird/addon/regimail/"), Google-Calendar[1](https://addons.thunderbird.net/thunderbird/addon/gcaltab/ "https://addons.thunderbird.net/thunderbird/addon/gcaltab/"), [2](https://addons.thunderbird.net/thunderbird/addon/google-calendar-plugin/ "https://addons.thunderbird.net/thunderbird/addon/google-calendar-plugin/"), M-Hub Lite[1](https://addons.thunderbird.net/thunderbird/addon/m-hub-lite_microsft-office-365/ "https://addons.thunderbird.net/thunderbird/addon/m-hub-lite_microsft-office-365/"), TbSync[1](https://addons.thunderbird.net/thunderbird/addon/tbsync/ "https://addons.thunderbird.net/thunderbird/addon/tbsync/"), Exquilla-for-Exchange[1](https://addons.thunderbird.net/thunderbird/addon/exquilla-exchange-web-services/ "https://addons.thunderbird.net/thunderbird/addon/exquilla-exchange-web-services/"), Google-Contacts[1](https://addons.thunderbird.net/thunderbird/addon/google-contacts/ "https://addons.thunderbird.net/thunderbird/addon/google-contacts/"), [2](https://addons.thunderbird.net/thunderbird/addon/gcontactsync/ "https://addons.thunderbird.net/thunderbird/addon/gcontactsync/"), Outlook AddressBook Enabler[1](https://addons.thunderbird.net/thunderbird/addon/outlook-address-book-enabler/ "https://addons.thunderbird.net/thunderbird/addon/outlook-address-book-enabler/"), Display Mail User-Agnet T[1](https://addons.thunderbird.net/thunderbird/addon/display-mail-user-agent-t/ "https://addons.thunderbird.net/thunderbird/addon/display-mail-user-agent-t/") *(Display Email Writer's Email-Client)*, Google-Keep-(tab)[1](https://addons.thunderbird.net/thunderbird/addon/google-keep-tab/ "https://addons.thunderbird.net/thunderbird/addon/google-keep-tab/"), Owl (OWA) for Exchange[1](https://addons.thunderbird.net/thunderbird/addon/owl-for-exchange/ "https://addons.thunderbird.net/thunderbird/addon/owl-for-exchange/"). This type of app is very helpful to keep multi channel communications with openwrt &amp; other various project developers, and to test your own servers. Get firefox addon uBlock Origin[1](https://addons.mozilla.org/firefox/addon/ublock-origin/ "https://addons.mozilla.org/firefox/addon/ublock-origin/"), &amp; load into Thunderbird, that addon allows you to stop un-approved Advertisements that are using+stealing your computing (CPU, GPU, etc) resources, &amp; internet *(limited &amp; costly)* data allotments from your ISP, etc, without your consent/permission/approval, and these advertisers also DO NOT PAY you any FEE after they used your computing &amp; data resources.

● *Apparency* ([dev](https://www.mothersruin.com/software/Apparency/ "https://www.mothersruin.com/software/Apparency/"), [dnld](https://www.mothersruin.com/software/Apparency/get.html "https://www.mothersruin.com/software/Apparency/get.html")) : it can inspect software application bundles (pkg, app, etc) for macOS, &amp; then it can show info on code signing requirements, notarization, signatures, included frameworks, etc. it is a freeware.

● *AppCleaner* ([dev](https://freemacsoft.net/appcleaner/ "https://freemacsoft.net/appcleaner/")) : open `Finder` &gt; goto `Application` in any finder-tab &gt; open this `AppCleaner` app, then drag the app that you want to remove/uninstall from `Application` folder/directory, &amp; drop it inside the `AppCleaner`, it will inspect &amp; find-out &amp; show all elements used by that unwanted app, &amp; also show you option to Remove. it is freeware.

## Drivers:

various *(opensource)* drivers for macOS, are mentioned (with website links) in this page, inside the topside `macOS & Darwin Unix` section.

Serial-to-UART, USB-to-UART, USB-to-JTAG, etc cable/adapter's macOS/darwin drivers, to communicate with router *(from apple mac computer)*, are usually provided by the cable/adapter device's manufacturer. a slow but opensource serial-to-UART driver is also available. For more info goto [here](/docs/techref/hardware/port.serial "docs:techref:hardware:port.serial").
