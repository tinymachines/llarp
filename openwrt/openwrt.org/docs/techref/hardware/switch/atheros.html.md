# Atheros Switches

## AR8327 / QCA8337

### Fine Tuning RGMII delay

For boards with uboot as the bootloader, with an available console, it will set registers when boot cycle is interrupted.

The necessary registers needed for the QCA8337 switch can be read from interrupted boot (tftpboot, bootm) by using the following lines in the switch driver ar8327.c in the function 'ar8327\_hw\_config\_of' where 'qca,ar8327-initvals' is parsed from DTS before the new register values are written:

```
  pr_info("0x04 %08x\n", ar8xxx_read(priv, AR8327_REG_PAD0_MODE));
  pr_info("0x08 %08x\n", ar8xxx_read(priv, AR8327_REG_PAD5_MODE));
  pr_info("0x0c %08x\n", ar8xxx_read(priv, AR8327_REG_PAD6_MODE));
  pr_info("0x10 %08x\n", ar8xxx_read(priv, AR8327_REG_POWER_ON_STRAP));
  ...
  ...
```

### common PAD CTRL MODE values

0x04000000RGMII enable no delay 0x05000000rx delay min 0x05300000rx delay max 0x06000000tx delay min 0x06c00000tx delay max 0x07000000rx/tx delay min 0x07f00000rx/tx delay max
