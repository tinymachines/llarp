# SMP/CMT Broadcom 63xx

**Work in Progress!**  
This page is a continuous work in progress. You can edit this page to contribute information.

An example of SMP initialization on BCM6358 SoC: [http://pastebin.com/wV3njK7c](http://pastebin.com/wV3njK7c "http://pastebin.com/wV3njK7c") taken from [linux-2.6.12.tar.bz2](http://www.livebox-floss.com/Products//LiveBox/LiveBox1/Thomson/vunknown/linux-2.6.12.tar.bz2 "http://www.livebox-floss.com/Products//LiveBox/LiveBox1/Thomson/vunknown/linux-2.6.12.tar.bz2"), mirror →[linux-2.6.12-inv.zip](https://drive.google.com/uc?export=download&id=0B-EMoBe-_OdBRnppenZMOExOUEU "https://drive.google.com/uc?export=download&id=0B-EMoBe-_OdBRnppenZMOExOUEU")

OpenWrt SMP on BMIPS cores: [smp-bmips.c](http://lxr.free-electrons.com/source/arch/mips/kernel/smp-bmips.c "http://lxr.free-electrons.com/source/arch/mips/kernel/smp-bmips.c")

## Main Thread

The main thread is configured by the bootloader (CFE) when the SoC is initialized. It can be checked in the log returned by CFE via serial. Example:

```
CFE version cfe.d081.5003 for BCM96358 (32bit,SP,BE)
Build Date: Wed Nov 11 10:36:35 CST 2009 (Lihua_68693)
Copyright (C) 2006 Huawei Technologies Co. Ltd.


Boot Address 0xbe000000

Initializing Arena.
Initializing Devices.

@w45260: Flash Manufacture id :c2

@w45260Flash Device id :2201

@w45260flipCFIGeometry:1
Parallel flash device: name , id 0x2201, size 16384KB
*** GetHG556aBoardVersion = <0> ***

CPU type 0x2A010: 300MHz, Bus: 133MHz, Ref: 64MHz
Total memory: 67108864 bytes (64MB)

Total memory used by CFE:  0x80401000 - 0x8052A510 (1217808)
Initialized Data:          0x8041F3C0 - 0x80421B60 (10144)
BSS Area:                  0x80421B60 - 0x80428510 (27056)
Local Heap:                0x80428510 - 0x80528510 (1048576)
Stack Area:                0x80528510 - 0x8052A510 (8192)
Text (code) segment:       0x80401000 - 0x8041F3B4 (123828)
Boot area (physical):      0x0052B000 - 0x0056B000
Relocation Factor:         I:00000000 - D:00000000

*** GetHG556aBoardVersion = <0> ***

Board IP address                  : 192.168.1.1  
Host IP address                   : 192.168.1.35  
Gateway IP address                :   
Run from flash/host (f/h)         : h  
Default host run file name        : vmlinux  
Default host flash file name      : bcm963xx_fs_kernel  
Boot delay (0-9 seconds)          : 1  
Board Id Name                     : HW556  
Psi size in KB                    : 64
Number of MAC Addresses (1-32)    : 14  
Base MAC Address                  : 5c:4c:a9:6e:4a:a2  
Ethernet PHY Type                 : Internal
Memory size in MB                 : 64
CMT Thread Number                 : 1
```

Here we have

```
CMT Thread Number                 : 1
```

Then the main thread will be the core1. This is important since the BCM6358 SoC cores haven't the same features:

BCM6358 Data cache Instruction cache core0 16kB 32kB core1 16kB

This parameter is located between **offsets 0x014-0x017** in [CFE](/docs/techref/bootloader/cfe#bcm63xx_cfe "docs:techref:bootloader:cfe"). We can change it HEX editing the CFE. Setting the value to 0, makes the core0 the main thread. This brings 32kB instead 16kB icache to the operating system and therefore increases the performance.

Some CFEs allow to change the Main thread using the command line interface. This option is probably only present in most recent SoCs such as BCM6368.

BCM6368 SoC cores are identical:

BCM6368 Data cache Instruction cache core0 32kB 64kB core1 64kB

So no benefit using a different core for the main thread.

## CP0 Registers

### Configuration Registers

To know if your CPU has concurrent multi-threading support (CMT) check **bit 18** at BRCM Configuration register (read\_c0\_brcm\_config\_0):  
0 = 1 core  
1 = 2 cores, multi-thread supported

Also check the **bit 12**:  
1 = Multicore CPU with split I-cache  
0 = Multicore CPU with shared I-cache

c0\_register($22, 0) Name bit typical value Instruction Cache enabled 31 1 Data Cache enabled 30 1 RAC presence 29 1 TLB power save disabled 28 0 EJTAG power save disabled 27 0 unknown 26 0 DSU Power save enabled 25 1 D-Cache power save enabled 24 1 unknown 23 0 ADSL with extra instructions 22 0 Branch prediction disabled 21 0 Critical Line First 20 0 Ordered Write Buffer 19 1 **CMT support** **18** **1** NBK (non blocking Data Cache) 17 1 weak order flags 16 0 unknown 15 0 unknown 14 0 unknown 13 0 **split I-cache for each thread** **12** **1** unknown 11 0 unknown 10 0 unknown 9 0 unknown 8 0 unknown 7 0 unknown 6 0 unknown 5 0 unknown 4 0 unknown 3 0 unknown 2 1 unknown 1 1 Counter Register disabled 0 0

### CMT Interrupt Registers

read\_c0\_brcm\_cmt\_intr();

register($22, 1) Name bit value description **external interrupt 4 routing** 31 1  
0 IP4: set A to T1, set B to T0  
IP4: set A to T0, set B to T1 **external interrupt 3 routing** 30 1  
0 IP3: set A to T1, set B to T0  
IP3: set A to T0, set B to T1 **external interrupt 2 routing** 29 1  
0 IP2: set A to T1, set B to T0  
IP2: set A to T0, set B to T1 **external interrupt 1 routing** 28 1  
0 IP1: set A to T1, set B to T0  
IP1: set A to T0, set B to T1 **external interrupt 0 routing** 27 1  
0 IP0: set A to T1, set B to T0  
IP0: set A to T0, set B to T1 unknown 26 0 unknown 25 0 unknown 24 0 unknown 23 0 unknown 22 0 unknown 21 0 unknown 20 0 unknown 19 0 unknown 18 0 unknown 17 0 **software interrupt 1 routing** 16 1  
0 SOFT1: set A to T1, set B to T0  
SOFT1: set A to T0, set B to T1 **software interrupt 0 routing** 15 1  
0 SOFT0: set A to T1, set B to T0  
SOFT0: set A to T0, set B to T1 unknown 14 0 unknown 13 0 unknown 12 0 unknown 11 0 unknown 10 0 unknown 9 0 unknown 8 0 unknown 7 0 unknown 6 0 unknown 5 0 unknown 4 0 unknown 3 0 unknown 2 0 **NMI interrupt routing to thread** 1  
0 01  
10 NMI routed to thread 0  
NMI routed to thread 1

### CMT Control Registers

read\_c0\_brcm\_cmt\_ctrl();

register($22, 2) Name bit value description DSU\_TP1 31 0 unknown 30 0 unknown 29 0 unknown 28 0 unknown 27 0 unknown 26 0 unknown 25 0 unknown 24 0 unknown 23 0 unknown 22 0 unknown 21 0 unknown 20 0 TPS3 19 0 TPS2 18 0 TPS1 17 0 TPS0 16 0 unknown 15 0 unknown 14 0 unknown 13 0 unknown 12 0 unknown 11 0 unknown 10 0 unknown 9 0 unknown 8 0 unknown 7 0 unknown 6 0 **give exception priority to thread 1** 5 1 D-cache priority to thread 1 **give exception priority to thread 0** 4 1 D-cache priority to thread 0 unknown 3 0 unknown 2 0 unknown 1 0 **thread 1 reset** 0 1

### CMT Local Registers

read\_c0\_brcm\_cmt\_local();

register($22, 3) Name bit value description **Thread identifier** 31 0 Return the thread ID where the code is executed unknown 30 0 unknown 29 0 unknown 28 0 unknown 27 0 unknown 26 0 unknown 25 0 unknown 24 0 unknown 23 0 unknown 22 0 unknown 21 0 unknown 20 0 unknown 19 0 unknown 18 0 unknown 17 0 unknown 16 0 unknown 15 0 unknown 14 0 unknown 13 0 unknown 12 0 unknown 11 0 unknown 10 0 unknown 9 0 unknown 8 0 unknown 7 0 unknown 6 0 unknown 5 0 unknown 4 0 unknown 3 0 unknown 2 0 unknown 1 0 unknown 0 0

## TLB exception handlers

### BCM6358

On a CMT CPU, the TLB is shared between the two cores. Since hardware exception serialization must be turned off to allow ipis to reach the other core during operations such as I-cache flushing, we need to use software locking to ensure serialized access to the TLB and the corresponding CP0 registers.

Besides locking, the implementation is slightly different than on a standard SMP, as the CP0\_CONTEXT is shared between the cores. Therefore it cannot be used to store **the processor number**, which **is obtained from the CP0 CMT local register** instead. It cannot be used to find the faulting address either.

If the lock cannot be taken, we must return from exception to allow software interrupts (of higher priority than TLB exceptions) to be serviced. The TLB exception will be retaken if really needed and we can try again to obtain the lock.

An entry may also be added on one core while the other core enters a TLB handler, so we must ensure the exception is is still valid by probing the TLB to avoid the following race:

```
		TP0			TP1
	TLB exception
	acquire lock
	...			access Badvaddr corresponding to entry X
	write to tlb entry X	enter TLB exception
	release lock		acquire lock
				...
	<refill:		Badvaddr may be present in the TLB now>
	<mod/load/store:	Badvaddr may have been removed from the TLB>
```

→ [http://pastebin.com/JWCFs0qz](http://pastebin.com/JWCFs0qz "http://pastebin.com/JWCFs0qz")

Note: Enable CMT support for the BCM6358 should be possible reviewing the code of linux-2.6.12.tar.bz2 (in the top of the page) and adapting it to a recent kernel.

### BCM6362, BCM6368

BCM6362 and BCM6368 have a private TLB for each thread.

## OpenWrt status

- No support in BCM6358, mainly caused by the shared TLB.
- BCM6362 and BCM6368 are supported. Available through the SMP subtarget in trunk versions:  
  [https://dev.openwrt.org/changeset/36526](https://dev.openwrt.org/changeset/36526 "https://dev.openwrt.org/changeset/36526")  
  [https://dev.openwrt.org/changeset/36527](https://dev.openwrt.org/changeset/36527 "https://dev.openwrt.org/changeset/36527")
- Fatal bug causing jffs2 data corruption → temporal workaround [https://dev.openwrt.org/changeset/40396](https://dev.openwrt.org/changeset/40396 "https://dev.openwrt.org/changeset/40396")

## Devices

The list of related devices: [bcm63xx](/tag/bcm63xx?do=showtag&tag=bcm63xx "tag:bcm63xx")
