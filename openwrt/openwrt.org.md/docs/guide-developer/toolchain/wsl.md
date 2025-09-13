# Build system setup WSL

This method is NOT OFFICIALLY supported. A native [GNU/Linux environment](/docs/guide-developer/toolchain/install-buildsystem "docs:guide-developer:toolchain:install-buildsystem") is recommended.

See also: [Windows Subsystem for Linux Documentation](https://docs.microsoft.com/en-us/windows/wsl "https://docs.microsoft.com/en-us/windows/wsl"), [How much faster is WSL 2?](https://devblogs.microsoft.com/commandline/announcing-wsl-2#how-much-faster-is-wsl-2 "https://devblogs.microsoft.com/commandline/announcing-wsl-2#how-much-faster-is-wsl-2")

The OpenWrt build system is reported to work in [WSL](https://en.wikipedia.org/wiki/Windows_Subsystem_for_Linux "https://en.wikipedia.org/wiki/Windows_Subsystem_for_Linux") with [Debian](https://www.microsoft.com/en-us/p/debian/9msvkqc78pk6 "https://www.microsoft.com/en-us/p/debian/9msvkqc78pk6").

```
sudo apt update
sudo apt dist-upgrade
```

## Setting up path

To be able to build an OpenWrt image, you must not have spaces in PATH or in the work folders on the drive. But by default in a WSL environment there are windows folders too and those have spaces in path:

```
> echo ${PATH}
/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/usr/lib/wsl/lib:/mnt/c/Windows/System32:/mnt/c/Windows:/mnt/c/Windows/System32/wbem:/mnt/c/Windows/System32/WindowsPowerShell/v1.0/:/mnt/c/Windows/System32/OpenSSH/:/mnt/c/Program Files/dotnet/:/mnt/c/Program Files (x86)/GnuPG/bin:/mnt/c/Program Files (x86)/dotnet/:/mnt/c/Program Files/WireGuard/:/mnt/c/Program Files/Git/cmd:/mnt/c/Program Files (x86)/AOMEI/AOMEI Backupper/6.5.1:/mnt/c/Program Files (x86)/Bitvise SSH Client:/mnt/c/WINDOWS/system32:/mnt/c/WINDOWS:/mnt/c/WINDOWS/System32/Wbem:/mnt/c/WINDOWS/System32/WindowsPowerShell/v1.0/:/mnt/c/WINDOWS/System32/OpenSSH/:/mnt/c/Users/Bas Mevissen/AppData/Local/Microsoft/WindowsApps:/mnt/c/Users/Bas Mevissen/.dotnet/tools 
```

### Temporary non-invasive solution

When launching commands in the OpenWrt build system folder, you can override the path with only the folders you want (i.e. only Linux ones since nothing from Windows is needed to compile OpenWrt) this is an example where we are just calling a `make`:

```
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin make 
```

### Permanent but invasive solution

See also: [Automatically Configuring WSL](https://devblogs.microsoft.com/commandline/automatically-configuring-wsl#section-interop "https://devblogs.microsoft.com/commandline/automatically-configuring-wsl#section-interop"), [How to remove the Win10's PATH from WSL](https://stackoverflow.com/a/63195953 "https://stackoverflow.com/a/63195953")

Configure WSL so that no Windows path elements (starts with `/mnt`) are in the PATH environment variable of the Linux distribution. In the Linux environment create `/etc/wsl.conf`:

```
sudo tee -a /etc/wsl.conf << EOF > /dev/null
[interop]
appendWindowsPath = false
EOF
exit
```

Restart WSL to apply changes:

```
wsl --shutdown
```

In the Linux environment verify whether no Windows path elements appear in the PATH environment variable by following command.

```
echo ${PATH}
```

### Alternative permanent solution that is not so invasive

```
echo 'export PATH=$(echo $PATH'" | sed 's|:/mnt/[a-z]/[a-z_]*\?/\?[A-Za-z]* [A-Za-z]* \?[A-Za-z]*\?[^:]*||g')" >> ~/.bashrc
```

Logout WSL user to apply changes:

```
exit
```

This method strips only the windows path elements that contain spaces whilst retaining access to useful windows executables within the WSL shell such as:

```
explorer.exe .
```

## Extras

### Limiting RAM/CPU usage

See also: [Configure global options with .wslconfig](https://docs.microsoft.com/en-us/windows/wsl/wsl-config#configure-global-options-with-wslconfig "https://docs.microsoft.com/en-us/windows/wsl/wsl-config#configure-global-options-with-wslconfig")

It is possible to limit WSL2's use of RAM/CPU resources by creating/editing `%USERPROFILE%\.wslconfig`.

```
[wsl2]
memory=8GB # Limits VM memory in WSL 2 to 8 GB
processors=4 # Makes the WSL 2 VM use four virtual processors
```

Restart WSL to apply changes:

```
wsl --shutdown
```

### Accessing files

By default, WSL2 mounts your Windows drive under `/mnt/c`, so you can access from WSL2 to Windows.

You can access the WSL2 file system from Windows 10 by opening explorer.exe and entering `\\wsl$\<name of WSL Instance>`, e.g. `\\wsl$\Ubuntu-20.04`. You can map this to a drive letter to easily access the WSL2 system from Windows programs, like Atom or other graphical IDE software.
