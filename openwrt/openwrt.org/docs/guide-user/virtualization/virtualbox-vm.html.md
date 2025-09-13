# OpenWrt on VirtualBox HowTo

This document describes how to run the x86-64 OpenWrt images in VM [VirtualBox](https://www.virtualbox.org "https://www.virtualbox.org"), or VBox for short.

## Prerequisites

- Download and install [VirtualBox](https://www.virtualbox.org/wiki/Downloads "https://www.virtualbox.org/wiki/Downloads")
- Download and install the VirtualBox Guest Additions (needed for USB connectivity among others)

### Select an OpenWrt image

You need a [x86 64 bit version of OpenWrt](/docs/guide-user/installation/openwrt_x86 "docs:guide-user:installation:openwrt_x86"). There is two versions of them:

- `combined-squashfs.img.gz` This disk image uses the traditional OpenWrt layout, a squashfs read-only root filesystem and a read-write partition where settings and packages you install are stored. Due to how this image is assembled, you will have only 230-ish MB of space to store additional packages and configuration, and Extroot does not work.
- `combined-ext4.img.gz` This disk image uses a single read-write ext4 partition with no read-only squashfs root filesystem, which allows to enlarge the partition. Features like Failsafe Mode or Factory Reset won't be available as they need a read-only squashfs partition to function.

In the guide we'll use *openwrt-x86-64-combined-ext4.img.gz* because it has fewer limitations.

- Download a stable release of the *openwrt-x86-64-combined-ext4.img.gz* image from [targets/x86/64/ folder](https://archive.openwrt.org/releases/ "https://archive.openwrt.org/releases/") e.g. [22.03.5](https://archive.openwrt.org/releases/22.03.5/targets/x86/64/openwrt-22.03.5-x86-64-generic-ext4-combined.img.gz "https://archive.openwrt.org/releases/22.03.5/targets/x86/64/openwrt-22.03.5-x86-64-generic-ext4-combined.img.gz"). Or you can try the fresher but unstable [snapshot](https://downloads.openwrt.org/snapshots/targets/x86/64/openwrt-x86-64-generic-ext4-combined.img.gz "https://downloads.openwrt.org/snapshots/targets/x86/64/openwrt-x86-64-generic-ext4-combined.img.gz") image
- Uncompress the gziped img file. On Linux use the command `gzip -d openwrt-*.img.gz`. As a result you should get the raw `openwrt-x86-64-combined-ext4.img` image file.

#### Custom Images

You can compile your own image (*Target System → x86-64* and *Target Images → Build VirtualBox image files*). `ext4` needs to be enabled first.

### Convert openwrt.img to VBox drive

- Open a terminal and go in the folder where you have downloaded the file (sorry, the tool has only a command line interface). On Windows, the `VBoxManage.exe` is available in the installation path `C:\Program Files\Oracle\VirtualBox`.
- Convert it to native VBox format by writing this in command line (the same for Windows, macOS and Linux. Sadly this tool does not have graphical user interface): `VBoxManage convertfromraw --format VDI openwrt-*.img openwrt.vdi`. This will create the `openwrt.vdi` file which a virtual drive for VBox virtual machine.

#### Error

If you receive an error similar to:

```
VBoxManage: error: VD: The given disk size 19444018 is not aligned on a sector boundary (512 bytes)
VBoxManage: error: Error code VERR_VD_INVALID_SIZE at /Users/vbox/tinderbox/5.1-mac-rel/src/VBox/Storage/VD.cpp(7002) in function int VDCreateBase(PVBOXHDD, const char *, const char *, uint64_t, unsigned int, const char *, PCVDGEOMETRY, PCVDGEOMETRY, PCRTUUID, unsigned int, PVDINTERFACE, PVDINTERFACE)
VBoxManage: error: Cannot create the disk image "openwrt.vdi": VERR_VD_INVALID_SIZE
```

or:

```
VBoxManage.exe: error: VDI: cannot create image 'openwrt.vdi'
VBoxManage.exe: error: Error code VERR_ACCESS_DENIED at D:\tinderboxb\win-6.1\src\VBox\Storage\VDI.cpp(691) in function int __cdecl vdiImageCreateFile(struct VDIIMAGEDESC *,unsigned int,struct VDINTERFACEPROGRESS *,unsigned int,unsigned int)
VBoxManage.exe: error: Cannot create the disk image "openwrt.vdi": VERR_ACCESS_DENIED
```

you may need to pad the image with `dd if=openwrt-x86-64-combined-ext4.img of=openwrt.img bs=128000 conv=sync` and use the padded image as input to VBoxManage convertfromraw or try another with this command line: `VBoxManage convertdd openwrt-*.img openwrt.vdi`.

- Enlarge the image to a useful size (size is in MB)

```
$ VBoxManage modifymedium openwrt.vdi --resize 128
0%...10%...20%...30%...40%...50%...60%...70%...80%...90%...100%
```

- Resize /dev/sda2 partition to new size, or create new partition and copy all files from root partition there and amend /boot/grub/grub.cfg

## VM Setup in VirtualBox

### VM creation

![:!:](/lib/images/smileys/exclaim.svg) Tutorial and screenshots from VirtualBox 5.1.8 on Linux host, on Windows or macOS hosts there will be some cosmetic differences (a different top bar) but the VirtualBox panels and buttons will be exactly the same

[![](/_media/docs/guide-user/vboxstart.png?w=70&tok=fba14e)](/_media/docs/guide-user/vboxstart.png "docs:guide-user:vboxstart.png") Start VirtualBox and click *New* to add a virtual machine (VM)

* * *

[![](/_media/docs/guide-user/vboxaddvm1.png?w=70&tok=4eb4af)](/_media/docs/guide-user/vboxaddvm1.png "docs:guide-user:vboxaddvm1.png") Choose a *Name* for your virtual machine, choose `Linux` for *Type*, and `Linux 2.6 / 3.x / 4.x (64-bit)` for *Version*, then click *Next*.

* * *

[![](/_media/docs/guide-user/vboxaddvm2.png?w=70&tok=4b1841)](/_media/docs/guide-user/vboxaddvm2.png "docs:guide-user:vboxaddvm2.png") OpenWrt will work fine with much less RAM than the recommended amount, 128 MiB will be enough.

* * *

[![](/_media/docs/guide-user/vboxaddvm3.png?w=70&tok=0bad2c)](/_media/docs/guide-user/vboxaddvm3.png "docs:guide-user:vboxaddvm3.png") Choose *Use an existing hard disk file*, click the *file* icon to open *Virtual Media Manager*, click *Add* and choose your `openwrt.vdi` file using the file chooser window. Click *Create* to end this guided procedure.

* * *

![:!:](/lib/images/smileys/exclaim.svg) It's recommended to place the disk image in a permanent place *before* linking it with VBox. If you move it *afterwards*, VBox will not find it anymore and will complain about this issue on next start (or when you try to start the VM). It will offer a guided procedure to link the disk image again, so don't worry.

![:!:](/lib/images/smileys/exclaim.svg) If the Virtual machine keeps restarting with `Kernel Panic - not syncing: Attempted to kill the idle task!` message, try changing the number of CPUs to 2 and then start the VM. Reference: [https://forums.virtualbox.org/viewtopic.php?t=106196](https://forums.virtualbox.org/viewtopic.php?t=106196 "https://forums.virtualbox.org/viewtopic.php?t=106196").

### VM setup

This article may contain network configuration that depends on migration to DSA in OpenWrt 21.02

- Check if your device uses DSA or swconfig as not all devices have been migrated
- ifname@interface has been moved to device sections
- [DSA Networking](/docs/guide-user/network/dsa/start "docs:guide-user:network:dsa:start")
- [Mini tutorial for DSA network config](https://forum.openwrt.org/t/mini-tutorial-for-dsa-network-config/96998 "https://forum.openwrt.org/t/mini-tutorial-for-dsa-network-config/96998") on the forum
- [DSA in the 21.02 release notes](https://openwrt.org/releases/21.02/notes-21.02.0#new_network_configuration_syntax_and_boardjson_change "https://openwrt.org/releases/21.02/notes-21.02.0#new_network_configuration_syntax_and_boardjson_change")

This part of the configuration will deal with setting up networking manually.  
The configuration you will set up by following this tutorial is:

- **eth0** of the VM on **mng** (management) interface, fixed address 192.168.56.2, set in VirtualBox as **Host-only Adapter** on adapter **vboxnet0**. This interface will be *always* available to the host even if host or VM are disconnected from any network.
- **eth1** of the VM on **wan** interface, dynamic address, set in VirtualBox as **NAT**. This interface will be used to access the Internet through whatever setup the host also uses.
- *(optional) **eth2** of the VM on **lan** interface, configured depending on your local network, set in VirtualBox as **Bridged Adapter**. This interface allows other devices (host included) to connect to the VM as if it was a physical device in the local network. Will only work if there is already a local network of some kind.*
- *For a setup with 2 bridged physical network cards WAN/LAN Setup see [troubleshooting](#troubleshooting "docs:guide-user:virtualization:virtualbox-vm ↵"). The rest of this guide applies to a setup with 2 physical cards as well.*

Note that the *order* of the “Host-only Adapter” as “Adapter 1” and “NAT” as “Adapter 2” is important for turn-key operation of OpenWrt in the VM. While it can be configured using the console, configuration in this way simplifies getting to a running configuration.

#### Virtualbox settings

##### Host-only network adapter

we first need to make sure there is a Host-only network adapter and that it has the right settings  
Note: this is found in VBox 6.0 (at least for Windows) under Tools, and is pre-configured.

* * *

[![](/_media/docs/guide-user/vboxvmhost-only-network1.png?w=70&tok=540e3e)](/_media/docs/guide-user/vboxvmhost-only-network1.png "docs:guide-user:vboxvmhost-only-network1.png") Click on **File** → **Preferences** → **Network**  
On macOS, this setting may be found through File &gt; Host Network Manager...

* * *

[![](/_media/docs/guide-user/vboxvmhost-only-network2.png?w=70&tok=d63a36)](/_media/docs/guide-user/vboxvmhost-only-network2.png "docs:guide-user:vboxvmhost-only-network2.png") Click on Host-only Networks tab and then if you don't see a **vboxnet0** entry click on the **+** icon on the right of the window to add a new one.  
Now select the **vboxnet0** entry, and click on the screwdriver icon on the right to open its settings.

* * *

[![](/_media/docs/guide-user/vboxvmhost-only-network3.png?w=70&tok=2f8737)](/_media/docs/guide-user/vboxvmhost-only-network3.png "docs:guide-user:vboxvmhost-only-network3.png") **IPv4 Address** should be **192.168.56.1**, **IPv4 Network Mask** should be **255.255.255.0**, **IPv6 Address** should be empty and **IPv6 Network Mask** should be **0**

* * *

[![](/_media/docs/guide-user/vboxvmhost-only-network4.png?w=70&tok=ee9315)](/_media/docs/guide-user/vboxvmhost-only-network4.png "docs:guide-user:vboxvmhost-only-network4.png") *(optional) you can also set the DHCP server as shown in the screenshot if you want to have dynamic addresses to the VM, but for this tutorial it is not required as we set a static address in the VM itself*

* * *

Press OK to save and close until you are back to VirtualBox Manager interface again.

##### Network Settings

[![](/_media/docs/guide-user/vboxvmsettings1.png?w=70&tok=5e53e8)](/_media/docs/guide-user/vboxvmsettings1.png "docs:guide-user:vboxvmsettings1.png") Open the VM's settings

* * *

[![](/_media/docs/guide-user/vboxvmsettings2.png?w=70&tok=427688)](/_media/docs/guide-user/vboxvmsettings2.png "docs:guide-user:vboxvmsettings2.png") Go in the **Network** tab

* * *

[![](/_media/docs/guide-user/vboxvmsettings3.png?w=70&tok=acb156)](/_media/docs/guide-user/vboxvmsettings3.png "docs:guide-user:vboxvmsettings3.png")configure **Adapter 1**:

1. with **Host-only Adapter**
2. select vboxnet0 as (adapter) **Name**
3. click on **Advanced** and in **Adapter Type** select **Intel PRO/1000 MT Desktop**
4. **Promiscuous mode** should be set to **Deny** unless you have good reasons to enable it.

<!--THE END-->

- Configure **Adapter 2**
  
  1. with **NAT**
- *(optional) Configure **Adapter 3***
  
  1. *with **Bridged Adapter***
  2. *in the Name field select the name of the network card (ethernet or wifi) of your PC that connected to a local network. On Windows it has a full device name, on Linux it will have codenames like **eth0**, **eth1** for ethernet or **wlp2s0** for wifi.*
  3. *Click on **Advanced** and do the same you did for **Adapter 1**'s advanced options*

#### Virtual Machine Settings

![:!:](/lib/images/smileys/exclaim.svg) Due to limitations, the keyboard in the virtual machine's terminal is set to US, so some (or most) of your keys may not print the symbols as indicated by the keycaps.  
Also, due to the fact that what you see there is a bare machine terminal and not a smart thing like a SSH program (Putty/Kitty/whatever) or a terminal emulator program, you cannot copy-paste text into it.  
Don't worry, most of the setup will be done after you are connected with SSH (remote terminal) that does not have any of these issues.  
[![](/_media/docs/guide-user/1280px-qwerty.png?w=50&tok=fa3e88)](/_media/docs/guide-user/1280px-qwerty.png "docs:guide-user:1280px-qwerty.png") Look at this US keyboard layout to find what button you need to press on your keyboard to generate the right symbol.

* * *

1. Boot into your Virtual Machine
2. Wait 4 seconds for GRUB to boot automatically
3. Press Enter to activate the console when the boot messages have finished scrolling by. It may take two or three minutes for “entropy” to be generated (`random: crng init done` with OpenWrt 17.01.4). Until there is sufficient entropy, SSH and other cryptographic functions may fail.
4. Display the current network configuration
   
   ```
   root@openwrt:~# uci show network
   network.loopback=interface
   network.loopback.ifname='lo'
   network.loopback.proto='static'
   network.loopback.ipaddr='127.0.0.1'
   network.loopback.netmask='255.0.0.0'
   network.globals=globals
   network.globals.ula_prefix='fd1b:e541:8f1a::/48'
   network.lan=interface
   network.lan.type='bridge'
   network.lan.ifname='eth0'
   network.lan.proto='static'
   network.lan.netmask='255.255.255.0'
   network.lan.ip6assign='60'
   network.lan.ipaddr='192.168.1.1'
   network.wan=interface
   network.wan.ifname='eth1'
   network.wan.proto='dhcp'
   network.wan6=interface
   network.wan6.ifname='eth1'
   network.wan6.proto='dhcpv6'
   ```

Note that the default LAN address of 192.168.1.1 is present on first boot.

1. Edit the network configuration to allow SSH access by writing these commands and pressing enter:
   
   1. **uci set network.lan.ipaddr='192.168.56.2'**
   2. **uci commit**
   3. **reboot**
2. Now your VM should be accessible from SSH, user **root** (no password) address **192.168.56.2**
3. After you have logged in successfully, we can actually do the true configuration. For 22.03 and earlier, copy-paste the following block of code and press enter:
   
   ```
   uci batch <<EOF 
   set network.mng=interface 
   set network.mng.type='bridge' 
   set network.mng.proto='static'
   set network.mng.netmask='255.255.255.0'
   set network.mng.ifname='eth0'
   set network.mng.ipaddr='192.168.56.2'
   delete network.lan
   delete network.wan6
   set network.wan=interface
   set network.wan.ifname='eth1'
   set network.wan.proto='dhcp'
   EOF
   ```
   
   For 23.05 and later, copy-paste the following:
   
   ```
   uci batch <<EOF 
   set network.mng=interface 
   set network.mng.device='br-lan'  
   set network.mng.proto='static'
   set network.mng.ipaddr='192.168.56.2'  
   set network.mng.netmask='255.255.255.0'
   set firewall.@zone[0].network='mng'
   set firewall.@zone[0].name='mng'
   delete network.lan
   delete network.wan6
   set network.wan=interface
   set network.wan.device='eth1'
   set network.wan.proto='dhcp'
   EOF
   ```
4. now write **uci changes** to check if the setting configuration was loaded correctly. If you see the following on 22.03 and earlier (the **network.mng** entries MUST be the same as the ones shown here, the **network.wan** might be slightly different), everything went well
   
   ```
   root@openwrt:~# uci changes
   network.mng='interface'
   network.mng.type='bridge'
   network.mng.proto='static'
   network.mng.netmask='255.255.255.0'
   network.mng.ifname='eth0'
   network.mng.ipaddr='192.168.56.2'
   -network.lan
   -network.wan6
   network.wan='interface'
   ```
   
   For 23.03 and later, you should see
   
   ```
   root@OpenWrt:~# uci changes
   firewall.cfg02dc81.network='mng'
   firewall.cfg02dc81.name='mng'
   network.mng='interface'
   network.mng.device='br-lan'
   network.mng.proto='static'
   network.mng.ipaddr='192.168.56.2'
   network.mng.netmask='255.255.255.0'
   -network.lan
   -network.wan6
   ```
5. if all is well, save config with **uci commit &amp;&amp; reboot**, if all is NOT well, write **reboot** to erase the temporary changes and find a way to set the above configuration manually.
6. close and open again the SSH terminal when the VM has restarted, with same connection parameters (user **root** and **192.168.56.2**)
7. now you should have both internet access (try a **opkg update**) AND a management interface with a static address you can connect your SSH client program to even if your PC is disconnected from a local network.
8. the optional **Bridged Adapter** on **Adapter 3** isn't crucial for basic functionality and is also specific for your own local network parameters. In my own network (and in most home networks) it will work fine for 22.03 and earlier if you write
   
   ```
   uci batch <<EOF 
   set network.lan=interface
   set network.lan.ifname='eth2'
   set network.lan.proto='dhcp'
   EOF
   uci commit
   ```
   
   and for 23.05 and later
   
   ```
   uci batch <<EOF 
   set network.lan=interface
   set network.lan.device='eth2'
   set network.lan.proto='dhcp'
   EOF
   uci commit
   service network restart
   ```
   
   If you have more complex requirements you will have to set that up on your own by reading the documentation, or through luci.
9. you can now install packages to this images as normal, you will probably want to install luci, write **opkg update &amp;&amp; opkg install luci**, then you can connect to the VM's luci by typing 192.168.56.2 in your browser address bar or [click on this link](http://192.168.56.2 "http://192.168.56.2") to get there.

## Troubleshooting

- If you rebuild the disk image, and VirtualBox complains about invalid UUIDs for the disk
  
  - You need to remove the disk from **both** the *VM* **and** from the *Virtual Media Manager*
  - Then add the disk image to the VM again

<!--THE END-->

- If you want to use a bridged VPN on your device to bridge it to your local network you need to set the
  
  - **Promiscuous Mode** of the corresponding **Bridged Network Adapter** to “Allow All” or else your local network won't be bridged properly to your vpn bridged network

<!--THE END-->

- You can also have 2 physical network interfaces on your main operating system that is hosting the virtual machine. In this case
  
  - Use one Network Adapter as **WAN** and in VirtualBox you select **Bridged Adapter** with **Promiscuous Mode** to **Deny**
  - Use the other Network Adapter as **LAN** and in VirtualBox you select **Bridged Adapter** with **Promiscuous Mode** to
    
    - **Deny** if you don't want to expose bridged virtual networks to your physical network
    - **Allow All** if you want to connect your bridged virtual network to your physical network

## Run with VirtualBox automatically on Start of Windows OS

- Ordered List ItemImport the following entry to your registry or add it manually:
  
  1. \[HKEY\_LOCAL\_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Run]
  2. “VB-MYDEVICE”=“\\”C:\\\\Program Files\\\\Oracle\\\\VirtualBox\\\\VBoxManage.exe\\“ startvm \\”NAMEOFVBINSTANCE\\“ --type headless”

<!--THE END-->

- Alternatively create 2 shortcuts and use the Windows Task scheduler
  
  1. “C:\\Program Files\\Oracle\\VirtualBox\\VBoxManage.exe” startvm MYDEVICE --type headless
     
     1. Create a task in the Scheduler triggered by logon of any user as action the shortcut
  2. “C:\\Program Files\\Oracle\\VirtualBox\\VBoxManage.exe” controlvm MYDEVICE acpipowerbutton
     
     1. Create a task in the Scheduler triggered by an event and as action the shortcut
        
        1. Begin the task: On an event
        2. Basic Log: System
        3. Source: User32
        4. Event ID: 1074

<!--THE END-->

- Or use following:
  
  1. [VBoxVmService](https://github.com/onlyfang/VBoxVmService "https://github.com/onlyfang/VBoxVmService") Windows Service to run VirtualBox VMs automatically

## See also

- [VirtualBox Advanced](/docs/guide-user/virtualization/virtualbox-advanced "docs:guide-user:virtualization:virtualbox-advanced")
- [Other virtualization options](/docs/guide-user/virtualization/start "docs:guide-user:virtualization:start"): Docker, VMware etc.
