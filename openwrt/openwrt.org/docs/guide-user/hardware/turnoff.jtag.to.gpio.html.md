# How to turnoff JTAG to free GPIO (only on ath79 processors)

You may need to disable the JTAG, to be able to use the TDI, TDO, TMS and TCK as GPIO-pin. The fact that the some special routers with EJTAG on PCB - EJTAG default is locked by hardware.

So, it is possible to turn off the built-in JTAG by simple script, without the NO need to patch/recompile firmware.

## Method (NO need re-build the Kernel):

Install io:

```
opkg update && opkg install io
```

or use this installation method:

```
cd /tmp
wget http://downloads.openwrt.org/barrier_breaker/14.07/ar71xx/generic/packages/oldpackages/io_1_ar71xx.ipk
opkg install io_1_ar71xx.ipk
```

Create an empty file (if it is from the console):

```
touch /usr/sbin/jtag_gpio
```

Paste the script in empty file:

```
#!/bin/sh
# Bitwise operations: & = And, | = Or, ^ = xOr, << = Left Shift
 
detect_addr="0x18060090"
rev_id_maj_msk="0xfff0"
bit0="1<<0"            # using bit0 for AR724x/AR933x
bit1="1<<1"            # using bit8 for AR9341/AR9342/AR9344
 
detect_value=0x`io -4 $detect_addr | cut -f3 -d' '`
detected_result=$(printf "0x%4.4x" $(($detect_value & $rev_id_maj_msk)))
 
# depending on the detected rev_id of CPU -
# it will be use specific bit# as case_bit variable, or exit
case "$detected_result" in
# AR7240/AR7241/AR7242/AR9330/AR9331
0x00c0 | \
0x0100 | \
0x1100 | \
0x0110 | \
0x1110 )
    func_addr="0x18040028"
    case_bit=$bit0
    ;;
# AR71xx/AR913x
0x00a0 | \
0x00b0 )
    echo "This CPU does not support this function!"
    break
    exit 0
    ;;
# AR9341/AR9342/AR9344
0x0120 | \
0x1120 | \
0x2120 )
    func_addr="0x1804006C"
    case_bit=$bit1
    ;;
* )
    echo "Can't detect your CPU, must be Atheros!"
    break
    exit 1
    ;;
esac
 
func_value=0x`io -4 $func_addr | cut -f3 -d' '`
 
# we using Bitwise xOr operation to switching bit# state (0 or 1)
io -4 $func_addr $(printf "0x%8.8x" $(($func_value ^ $case_bit)))
 
# read bit# state and depending on the state - print some info
if [ $(($func_value & $case_bit)) = $(($case_bit)) ]; then
    echo "Hardware JTAG is turned OFF"
    # You can use this line for automatic configuring GPIOs via sysfs
    # or you can load other modules that use these GPIOs
else
    echo "Hardware JTAG is turned ON"
fi
```

Assign the right execution:

```
chmod +x /usr/sbin/jtag_gpio
```

And actually the launch itself **jtag\_gpio** (if launch again it turn on JTAG back) ...

Of course, it turn off JTAG until the next reboot the device, ie, you need to automate the process, for example by writing command in **/etc/rc.local**. After that you need and you can configure for yourself GPIO via **/sys/class/gpio/export**... well, I think it is not necessary to go into details, because who need to turn off the JTAG for some purposes - he will understand.

Let me remind you, for AR724x/AR933x:

```
  TDI   |   TDO   |   TMS
 GPIO6  |  GPIO7  |  GPIO8
```

For AR934x:

```
  TCK   |   TDI   |   TDO   |   TMS
 GPIO0  |  GPIO1  |  GPIO2  |  GPIO3
```
