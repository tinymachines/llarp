# How to turnoff UART to free GPIO (only on ath79 processors)

**Related documentation:**

- [http://wiki.openwrt.org/doc/hardware/port.serial](http://wiki.openwrt.org/doc/hardware/port.serial "http://wiki.openwrt.org/doc/hardware/port.serial")
- [https://dev.openwrt.org/ticket/11243](https://dev.openwrt.org/ticket/11243 "https://dev.openwrt.org/ticket/11243")
- [http://web.cecs.pdx.edu/~jrb/ui/linux/driver4.txt](http://web.cecs.pdx.edu/~jrb/ui/linux/driver4.txt "http://web.cecs.pdx.edu/~jrb/ui/linux/driver4.txt")
- [http://www.networksecuritytoolkit.org/nst/docs/user/ch11s02.html](http://www.networksecuritytoolkit.org/nst/docs/user/ch11s02.html "http://www.networksecuritytoolkit.org/nst/docs/user/ch11s02.html")

You may need to disable the UART, to be able to use the TX and RX as GPIO-pin. The fact that the processors AR71xx/AR913x/AR724X/AR933X - UART default is locked and uses internal resources (buffer interrupt) for interaction with the driver.

So, it is possible to turn off the built-in UART by simple script, without the NO need to patch/recompile firmware.

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
touch /usr/sbin/uart_gpio
```

Paste the script in empty file:

```
#!/bin/sh
# Bitwise operations: & = And, | = Or, ^ = xOr, << = Left Shift
 
detect_addr="0x18060090"
rev_id_maj_msk="0xfff0"
func_addr="0x18040028"
bit1="1<<1"            # using bit1 for AR724x/AR933x
bit8="1<<8"            # using bit8 for AR71xx/AR913x
 
detect_value=0x`io -4 $detect_addr | cut -f3 -d' '`
detected_result=$(printf "0x%4.4x" $(($detect_value & $rev_id_maj_msk)))
func_value=0x`io -4 $func_addr | cut -f3 -d' '`
 
# depending on the detected rev_id of CPU -
# it will be use specific bit# as case_bit variable, or exit
case "$detected_result" in
# AR7240/AR7241/AR7242/AR9330/AR9331
0x00c0 | \
0x0100 | \
0x1100 | \
0x0110 | \
0x1110 )
    case_bit=$bit1
    ;;
# AR71xx/AR913x
0x00a0 | \
0x00b0 )
    case_bit=$bit8
    ;;
# AR9341/AR9342/AR9344
0x0120 | \
0x1120 | \
0x2120 )
    echo -e "No need to disable UART on AR934x processors,\n \
    just use sysfs to reprogram GPIOs."
    break
    exit 0
    ;;
* )
    echo "Can't detect your CPU, must be Atheros!"
    break
    exit 1
    ;;
esac
 
# we using Bitwise xOr operation to switching bit# state (0 or 1)
io -4 $func_addr $(printf "0x%8.8x" $(($func_value ^ $case_bit)))
 
# read bit# state and depending on the state - print some info
if [ $(($func_value & $case_bit)) = $(($case_bit)) ]; then
    echo "Hardware UART is turned OFF"
    # You can use this line for automatic configuring GPIOs via sysfs
    # or you can load other modules that use these GPIOs
else
    echo "Hardware UART is turned ON"
fi
```

Assign the right execution:

```
chmod +x /usr/sbin/uart_gpio
```

And actually the launch itself **uart\_gpio** (if launch again it turn on UART back) ...

Of course, it turn off UART until the next reboot the device, ie, you need to automate the process, for example by writing command in **/etc/rc.local**. After that you need and you can configure for yourself GPIO via **/sys/class/gpio/export**... well, I think it is not necessary to go into details, because who need to turn off the UART for some purposes - he will understand.

Let me remind you, for AR724x/AR933x:

```
UART_IN | UART_OUT
 GPIO9  |  GPIO10
```

## Forum discussion:

[https://forum.openwrt.org/viewtopic.php?id=48063](https://forum.openwrt.org/viewtopic.php?id=48063 "https://forum.openwrt.org/viewtopic.php?id=48063")
