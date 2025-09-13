# Smartmontools

This article refers to [Smartmontools](https://www.smartmontools.org/ "https://www.smartmontools.org/"). You can install it by

## Installation

```
opkg update
opkg install smartmontools
```

## Update Drive Database (drivedb.h)

To save flash space there is no `drivedb` included in the OpenWRT package of `smartmontools`. The automatic update of `drive.db` described [here](https://www.smartmontools.org/browser/trunk/smartmontools/update-smart-drivedb.8.in "https://www.smartmontools.org/browser/trunk/smartmontools/update-smart-drivedb.8.in") is missing as well. In case you can affort/waste ~215kB (12-April-2020) you can download the current database from GIT [Drivedb.h](https://raw.githubusercontent.com/mirror/smartmontools/master/drivedb.h "https://raw.githubusercontent.com/mirror/smartmontools/master/drivedb.h"). Transfer it via SCP or WinSCP and place it at

```
mkdir /usr/share/smartmontools
mv drivedb.h /usr/share/smartmontools/drivedb.h
```

## SMART Information / Attributes

It allows you to monitor the health of an external storage device. This example assumes an SSD mounted at `/dev/sda`

```
smartctl -a /dev/sda
 
smartctl 7.0 2018-12-30 r4883 [armv5tel-linux-4.14.162] (localbuild)
Copyright (C) 2002-18, Bruce Allen, Christian Franke, www.smartmontools.org
 
=== START OF INFORMATION SECTION ===
Model Family:     Marvell based SanDisk SSDs
Device Model:     SanDisk SSD PLUS 240GB
Serial Number:    1944AA800xxx
LU WWN Device Id: 5 001b44 8b18d5803
Firmware Version: UF2204RL
User Capacity:    240,057,409,536 bytes [240 GB]
Sector Size:      512 bytes logical/physical
Rotation Rate:    Solid State Device
Form Factor:      2.5 inches
Device is:        In smartctl database [for details use: -P show]
ATA Version is:   ACS-3, ACS-2 T13/2015-D revision 3
SATA Version is:  SATA 3.2, 6.0 Gb/s (current: 3.0 Gb/s)
Local Time is:    Mon Apr 13 09:28:31 2020 CEST
SMART support is: Available - device has SMART capability.
SMART support is: Enabled
...
SMART Attributes Data Structure revision number: 1
Vendor Specific SMART Attributes with Thresholds:
ID# ATTRIBUTE_NAME          FLAG     VALUE WORST THRESH TYPE      UPDATED  WHEN_FAILED RAW_VALUE
  5 Reallocated_Sector_Ct   0x0032   100   100   000    Old_age   Always       -       0
  9 Power_On_Hours          0x0032   100   100   000    Old_age   Always       -       215
 12 Power_Cycle_Count       0x0032   100   100   000    Old_age   Always       -       27
165 Total_Write/Erase_Count 0x0032   100   100   000    Old_age   Always       -       34
166 Min_W/E_Cycle           0x0032   100   100   ---    Old_age   Always       -       1
167 Min_Bad_Block/Die       0x0032   100   100   ---    Old_age   Always       -       10
168 Maximum_Erase_Cycle     0x0032   100   100   ---    Old_age   Always       -       3
169 Total_Bad_Block         0x0032   100   100   ---    Old_age   Always       -       106
170 Unknown_Attribute       0x0032   100   100   ---    Old_age   Always       -       0
171 Program_Fail_Count      0x0032   100   100   000    Old_age   Always       -       0
172 Erase_Fail_Count        0x0032   100   100   000    Old_age   Always       -       0
173 Avg_Write/Erase_Count   0x0032   100   100   000    Old_age   Always       -       1
174 Unexpect_Power_Loss_Ct  0x0032   100   100   000    Old_age   Always       -       0
184 End-to-End_Error        0x0032   100   100   ---    Old_age   Always       -       0
187 Reported_Uncorrect      0x0032   100   100   000    Old_age   Always       -       0
188 Command_Timeout         0x0032   100   100   ---    Old_age   Always       -       0
194 Temperature_Celsius     0x0022   063   042   000    Old_age   Always       -       37 (Min/Max 15/42)
199 SATA_CRC_Error          0x0032   100   100   ---    Old_age   Always       -       0
230 Perc_Write/Erase_Count  0x0032   100   100   000    Old_age   Always       -       9 20 9
232 Perc_Avail_Resrvd_Space 0x0033   100   100   005    Pre-fail  Always       -       100
233 Total_NAND_Writes_GiB   0x0032   100   100   ---    Old_age   Always       -       136
234 Perc_Write/Erase_Ct_BC  0x0032   100   100   000    Old_age   Always       -       274
241 Total_Writes_GiB        0x0030   100   100   000    Old_age   Offline      -       131
242 Total_Reads_GiB         0x0030   100   100   000    Old_age   Offline      -       190
244 Thermal_Throttle        0x0032   000   100   ---    Old_age   Always       -       0
```
