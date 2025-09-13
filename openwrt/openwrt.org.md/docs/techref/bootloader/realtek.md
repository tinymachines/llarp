# RealTek

The RealTek bootloader was written by RealTek and is used only with their SoCs (RTL819x, RTL8881 etc.). Its source code can be found in the Realtek SDK.

Depending on the configuration, the bootloader can support at least TFTP and optionally HTTP and DHCP.

```
Booting...

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@
@ chip__no chip__id mfr___id dev___id cap___id size_sft dev_size chipSize
@ 0000000h 0c84018h 00000c8h 0000040h 0000018h 0000000h 0000018h 1000000h
@ blk_size blk__cnt sec_size sec__cnt pageSize page_cnt chip_clk chipName
@ 0010000h 0000100h 0001000h 0001000h 0000100h 0000010h 000002dh GD25Q128
@ 
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 
---RealTek(RTL8196D)at 2013.12.26-08:32+0800 v1.1 [16bit](700MHz)
no rootfs signature at 000E0000!
no rootfs signature at 000F0000!
no rootfs signature at 00130000!
no rootfs signature at 000E1000!
no rootfs signature at 000E2000!
...
[skipped]
...
no rootfs signature at 0015E000!
no rootfs signature at 0015F000!
P0phymode=03, embedded phy

---Ethernet init Okay!

<RealTek>
```

Short help command:

```
<RealTek>?

----------------- COMMAND MODE HELP ------------------

HELP (?)    : Print this help message
DB <Address> <Len>
DW <Address> <Len>
EB <Address> <Value1> <Value2>...
EW <Address> <Value1> <Value2>...
CMP: CMP <dst><src><length>
IPCONFIG:<TargetAddress>
AUTOBURN: 0/1
LOADADDR: <Load Address>
J: Jump to <TargetAddress>
FLR: FLR <dst><src><length>
FLW <dst_ROM_offset><src_RAM_addr><length_Byte> <SPI cnt#>: Write offset-data to SPI from RAM
MDIOR:  MDIOR <phyid> <reg>
MDIOW:  MDIOW <phyid> <reg> <data>
PHYR: PHYR <PHYID><reg>
PHYW: PHYW <PHYID><reg><data>
D8 <Address>
E8 <Address> <Value>
```

DW - Hex dump memory in 32bit words Address: Start address in hex ; Len: Words to dump in decimal (rounded up to nearest 4)

```
<RealTek>DW 80000000 8
80000000: DEADBEEF 13371337 00C0FFEE D15EA5ED
80000010: 00000000 00000000 00000000 00000000
<RealTek>
```

EW - Write hex values to memory in 32bit words Address: Start address in hex ; Values: space separated hex words (Unlimited?)

```
<RealTek>EW 80000000 deadbeef 13371337 c0ffee d15ea5ed
<RealTek>
```

DB - Hex dump memory in bytes Address: Start address in hex ; Len: Bytes to dump in decimal

```
<RealTek>DB 80000000 32
[Addr] .0 .1 .2 .3 .4 .5 .6 .7 .8 .9 .A .B .C .D .E .F
80000000: de ad be ef 13 37 13 37 00 c0 ff ee d1 5e a5 ed .....7.7.....^..
80000010: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ................
<RealTek>
```

EB - Write hex values to memory in bytes Address: Start address in hex ; Values: space separated hex words (Unlimited?)

```
<RealTek>EB 80000000 00 01 02 03 04 05 06 07 08 09 0a 0b 0c 0d 0e 0f
<RealTek>
```

CMP - Compare memory in 32bit chunks dst: First address in hex ; src: Second address in hex ; length: Size in bytes (rounded to nearest word)

```
<RealTek>CMP 80000000 80000010 4
0th data(deadbeef 00000000) error
<RealTek>CMP 80000010 80000014 4
No error found
<RealTek>
```

IPCONFIG - Get/Set the IP address the bootloader listens for TFTP on (default is 192.168.1.6) ip: The IP address to set

```
<RealTek>IPCONFIG
Target Address=192.168.1.6
<RealTek>IPCONFIG 10.0.0.1
Now your Target IP is 10.0.0.1
<RealTek>
```

AUTOBURN - Should the bootloader automatically burn the received image from TFTP into flash? 0 = no, 1 = yes

```
<RealTek>AUTOBURN 0
AutoBurning=0
<RealTek>
```

LOADADDR - Set the address TFTP loads data to address: Address in hex

```
<RealTek>LOADADDR 80000000
Set TFTP Load Addr 0x80000000
<RealTek>
```

J - Jump to an address address: Address in hex

```
<RealTek>J 80500000
---Jump to address=80500000
Decompressing kernel... done!
Starting kernel at 80000000...
```

FLR - Read from Flash into RAM dst: RAM address in hex ; src: Flash address in hex ; length: Byte count in hex(!!!)

```
<RealTek>FLR 80000000 100000 f
Flash read from 00100000 to 80000000 with 0000000F bytes         ?
(Y)es , (N)o ? --> y
Flash Read Successed!
```

The bootloader accepts data over TFTP. Using the built-in Windows TFTP command it's possible to upload a kernel:

```
X:\>tftp -i 192.168.1.6 put testkernel.bin
Transfer successful: 1048576 bytes in 2 second(s), 514296 bytes/s
```

On the target you'll see:

```
<RealTek>
**TFTP Client Upload, File Name: testkernel.bin
- (Spinning progress indicator)
**TFTP Client Upload File Size = 00100000 Bytes at 80500000
Success!
```
