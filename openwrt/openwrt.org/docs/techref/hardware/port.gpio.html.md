# GPIO

Read [General Purpose Input/Output](https://en.wikipedia.org/wiki/General%20Purpose%20Input/Output "https://en.wikipedia.org/wiki/General Purpose Input/Output") and [GPIO documentation in Linux](https://www.kernel.org/doc/Documentation/gpio/ "https://www.kernel.org/doc/Documentation/gpio/").

- [mmc\_over\_gpio](/docs/guide-user/hardware/mmc_over_gpio "docs:guide-user:hardware:mmc_over_gpio")
- [GPIOs of AR913x SoC](/toh/tp-link/tl-wr1043nd#gpios "toh:tp-link:tl-wr1043nd")
- [oldwiki GPIO](https://oldwiki.archive.openwrt.org/oldwiki/port.gpio "https://oldwiki.archive.openwrt.org/oldwiki/port.gpio")

## Hardware

GPIOs are commonly used in router devices for buttons or leds. They only safely supply or sink (pull to GND) a maximum of 4mA approx., and the voltage is usually 3.3V when active. Only two states are possible: high or low. Depending on how a device is activated by a GPIO, active low or active high is defined.

- **Active high**: the device is activated when the GPIO is HIGH
- **Active low**: the device is activated when the GPIO is LOW

In this image you can see how a GPIO is wired to buttons or leds, to work as active low or high

[![](/_media/media/doc/hardware/gpio_high_low.png?w=600&tok=f643a7)](/_detail/media/doc/hardware/gpio_high_low.png?id=docs%3Atechref%3Ahardware%3Aport.gpio "media:doc:hardware:gpio_high_low.png")

**GPIOs can be used for complex tasks:**

kernel module packaged description [1-wire](/docs/techref/hardware/port.gpio/1-wire "docs:techref:hardware:port.gpio:1-wire") kmod-w1-master-gpio ✔ 1-wire bus master [GPIO expanders](/docs/techref/hardware/port.gpio/expanders "docs:techref:hardware:port.gpio:expanders") kmod-gpio-pcf857x  
kmod-gpio-pca953x ✔ i2c GPIO expander kmod-gpio-nxp-74hc164 ✔ SPI GPIO expander kmod-gpio-mcp23s08 ✔ i2c/SPI GPIO expander [pwm](/docs/guide-user/hardware/pwm "docs:guide-user:hardware:pwm") kmod-pwm-gpio removed since [r37490](https://dev.openwrt.org/changeset/37490 "https://dev.openwrt.org/changeset/37490") pulse width modulator [spi](/docs/techref/hardware/port.gpio/spi "docs:techref:hardware:port.gpio:spi") kmod-spi-gpio ✔ bitbanging Serial Peripheral Interface kmod-mmc-over-gpio ✔ [MMC/SD card over GPIO](/docs/guide-user/hardware/mmc_over_gpio "docs:guide-user:hardware:mmc_over_gpio") [I2C](/docs/techref/hardware/port.i2c "docs:techref:hardware:port.i2c") kmod-i2c-gpio ✔ bitbanging I2C [lirc](/docs/guide-user/hardware/lirc "docs:guide-user:hardware:lirc") kmod-lirc\_gpio\_generic ☐ Linux Infrared Remote Control [LIRC GPIO blaster](/docs/guide-user/hardware/lirc-gpioblaster "docs:guide-user:hardware:lirc-gpioblaster") kmod-lirc\_gpioblaster ☐ LIRC transmitter only [PPS](/docs/techref/hardware/port.gp/pps "docs:techref:hardware:port.gp:pps") kmod-pps-gpio ✔ Pulse Per Second GPIO client [rotary\_encoder](/docs/techref/hardware/port.gpio/rotary_encoder "docs:techref:hardware:port.gpio:rotary_encoder") kmod-input-gpio-encoder ✔ GPIO rotary encoder [custom\_rotary\_encoder](/docs/techref/hardware/port.gpio/custom_rotary_encoder "docs:techref:hardware:port.gpio:custom_rotary_encoder") kmod-rotary-gpio-custom ✔ Custom GPIO rotary encoder [rcswitch-kmod](https://github.com/wendlers/rcswitch-kmod "https://github.com/wendlers/rcswitch-kmod") rcswitch-kmod ☐ 433 MHz RC power outlets (switches)

You can connect 5V digital signal sensors if you use a voltage divider to get a 3.3V range signal.You need to get acces to GND and 5V-power from the router and connect the sensor to them. Sensor signal output is in the 5V range, connect it to the voltage divider!

[![](/_media/media/voltagedividergpio.jpg?w=200&tok=003831)](/_detail/media/voltagedividergpio.jpg?id=docs%3Atechref%3Ahardware%3Aport.gpio "media:voltagedividergpio.jpg") [![](/_media/media/5vsignal.jpg?w=200&tok=b76ae7)](/_detail/media/5vsignal.jpg?id=docs%3Atechref%3Ahardware%3Aport.gpio "media:5vsignal.jpg")

### Pin Multiplexing

Pin [multiplexing](https://en.wikipedia.org/wiki/multiplexer "https://en.wikipedia.org/wiki/multiplexer") is used by manufacturers to accommodate the largest number of peripheral functions in the smallest possible package.

Many times some GPIOs cannot be controlled by the kernel because they are multiplexed, and they are not acting as GPIOs. It might be possible to undo the multiplexing by writing some particular software programmable register settings, and then recover the GPIO functionality. But probably on most cases those GPIOs were multiplexed for some good reason, like using a [SoC](/docs/techref/hardware/soc "docs:techref:hardware:soc") pin for a signal on an ethernet phy, SPI, PCI, UART or another purpose.

- Example 1: on the Broadcom BCM6328 SoC, GPIO pins 25, 26, 27 and 28 are used to indicate the LAN activity with hardware controlled LEDs. The memory register for setting this multiplexing is at 0x1000009C address, 64bits wide. Let's read it in OpenWrt
  
  ```
  root@OpenWrt:/# devmem 0x1000009C 64
  0x0154000000000000
  ```
  
  ![](/_media/media/doc/hardware/bcm6328-lan-led_pinmux-bits.png)  
  These enabled bits are enabling every LAN LED to be controlled by hardware, therefore they cannot be controlled as regular GPIO's  
  Let's disable this multiplexing for all LEDs
  
  ```
  root@OpenWrt:/# devmem 0x1000009C 64 0x0
  ```
  
  Now we can export these GPIOs and control them via software.

<!--THE END-->

- Example 2: on the Atheros AR7240 SoC, GPIO pins 6, 7 and 8 are used by the JTAG interface. The memory register for AR7240 GPIO pinmux is at 0x18040028 address, 32 bits wide. Let's read it:
  
  ```
  root@OpenWrt:/# devmem 0x18040028 32
  0x48002
  ```
  
  The bit0 disables JTAG multiplexing, then we must set this bit to 1, in other words, write the value 0x48003
  
  ```
  root@OpenWrt:/# devmem 0x18040028 32 0x48003
  ```
  
  Now we can control these GPIO pins (GPIO6, GPIO7 and GPIO8)

### GPIO Interrupts

GPIO interrupts are useful when a GPIO is used as input and you need to manage high signal frequencies. Without interrupts, GPIO inputs must be managed using the **polling** method. With polling you cannot manage signal inputs with high frequencies, but still can be used for simple tasks like reading the input on the device buttons.

GPIO IRQs are also useful for detecting the edge from an input, it can be rising or falling. Some GPIO drivers also need this feature.

Not all boards have GPIO interrupts, or the GPIO kernel drivers don't provide IRQs because they aren't still implemented. As a result of this, some input drivers listed above (requiring GPIO IRQs) won't work in these boards.

Example: ar71xx target has GPIO IRQs since [r46339](https://dev.openwrt.org/changeset/46339/ "https://dev.openwrt.org/changeset/46339/") (Linux kernel 3.18)

## Software

**The GPIO SYSFS interface has been marked as obsolete in 2015. I couldn't get the following scripts to work. This page needs an overhaul.**

The new interface is the linux GPIO character device. One way to access it is [libgpiod](https://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git/tree/README "https://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git/tree/README").

You can install it with the [gpiod-tools](/packages/pkgdata/gpiod-tools "packages:pkgdata:gpiod-tools") package like this:

```
opkg update
opkg install gpiod-tools
```

A good article on how to use the new CLI and why we should move on: [Stop using /sys/class/gpio – it’s deprecated](https://www.thegoodpenguin.co.uk/blog/stop-using-sys-class-gpio-its-deprecated/ "https://www.thegoodpenguin.co.uk/blog/stop-using-sys-class-gpio-its-deprecated/")

The biggest differences are:

- The new interface isn't stateless like the old one. Processes are able to take exclusive control over a gpio line now
- There is a character device /dev/gpiochipX for each gpio chip found in the system
- TODO

As I said: This page needs an overhaul. This info box is just to prevent people from wasting their time on a deprecated ABI.

In linux GPIOs can be accessed through GPIO SYSFS interface: **/sys/class/gpio/**

**Example**  
In this example we will use GPIO29 and use it as a switch.

With latest linux kernels you may need to first get the gpio base

```
cat /sys/class/gpio/gpiochip*/base | head -n1
200
```

and sum the base to your GPIO:  
`200 + 29 = 229`

Now first step is making GPIO available in Linux:

```
echo "229" > /sys/class/gpio/export
```

then you need to decide if it will be input or output, as we will use it as a switch so we need output

```
echo "out" > /sys/class/gpio/gpio229/direction
```

and last line turns GPIO on or off with 1 or 0:

```
echo "1" > /sys/class/gpio/gpio229/value
```

### Utilities

To control GPIOs you can use **gpioctl-sysfs**. Also with this simple script you can control GPIOs not used by buttons or leds.

```
#!/bin/sh
 
show_usage()
{
    printf "\ngpio.sh <gpio pin number> [in|out [<value>]]\n"
}
 
if [ \( $# -eq 0 \) -o \( $# -gt 3 \) ] ; then
    show_usage
    printf "\n\nERROR: incorrect number of parameters\n"
    exit 255
fi
 
GPIOBASE=`cat /sys/class/gpio/gpiochip*/base | head -n1`
GPIO=`expr $1 + $GPIOBASE`
 
#doesn't hurt to export a gpio more than once
(echo $GPIO > /sys/class/gpio/export) >& /dev/null
 
if [  $# -eq 1 ] ; then
   cat /sys/class/gpio/gpio$GPIO/value
   exit 0
fi
 
if [ \( "$2" != "in" \) -a  \( "$2" != "out" \) ] ; then
    show_usage
    printf "\n\nERROR: second parameter must be 'in' or 'out'\n"
    exit 255
fi
 
echo $2 > /sys/class/gpio/gpio$GPIO/direction
 
if [  $# -eq 2 ] ; then
   cat /sys/class/gpio/gpio$GPIO/value
   exit 0
fi
 
 
VAL=$3
 
if [ $VAL -ne 0 ] ; then
    VAL=1
fi
 
echo $VAL > /sys/class/gpio/gpio$GPIO/value  
```

Save the script somewhere with the name *gpiocontrol.sh* an give it execution permissions:

> `chmod +x gpiocontrol.sh`

Example, put the GPIO14 on HIGH state:

> `./gpiocontrol.sh 14 out 1`

Read the input value of GPIO14:

> `./gpiocontrol.sh 14 in`

## Finding GPIO pins on the PCB

Sometimes you do not know where the physical GPIO pins are on your device's PCB. In that case, you can use this little script and a multimeter to find out.

### script "blink"

```
#!/bin/sh
 
GPIOBASE=`cat /sys/class/gpio/gpiochip*/base | head -n1`
GPIOmin=`expr $1 + $GPIOBASE`
GPIOmax=`expr $2 + $GPIOBASE`
nums=`seq $GPIOmin $GPIOmax` 
 
cd /sys/class/gpio
for i in $nums; do
echo $i > export; echo out >gpio$i/direction
done
 
while true; do
  for i in $nums; do
     echo 0 > gpio$i/value
 done
  sleep 1
  for i in $nums; do
     echo 1 > gpio$i/value
  done
  sleep 1
done
```

1. Start with `./gpio 0 30`, which means pin 0 to 30
2. Press ctrl-c to stop the script, then check which GPIOs have been created: `find /sys/class/gpio/gpio*`
3. Restart the script and measure with a multimeter which pins “blink”.
4. When you find one, then cut the 0-30 range from above in half;
5. Repeat until you have identified the gpio number

### script "static"

```
#!/bin/sh
GPIOBASE=`cat /sys/class/gpio/gpiochip*/base | head -n1`
GPIOmin=`expr $1 + $GPIOBASE`
GPIOmax=`expr $2 + $GPIOBASE`
 
cd /sys/class/gpio
for i in `seq $GPIOmin $GPIOmax`; do
     echo "[GPIO$i] Trying value $3"
     echo $i > export; echo out >gpio$i/direction
     echo $3 > gpio$i/value
     echo $i > unexport
done
```

1. Measure continuosuly the voltage of the pin where you suspect there is a GPIO wired, with a multimeter or another device.
2. Put all GPIOs on HIGH state `./gpio 0 31 1`
3. Put all GPIOs on LOW state `./gpio 0 31 0`
4. If the pin changes the voltage, then cut the 0-31 range from above in half `./gpio 16 31 1`
5. If the pin doesn't change the voltage,then use the other half range `./gpio 0 15 1`
6. Cut again the new range.
7. Repeat until you have identified the gpio number

### script "blink all"

Another script to look for GPIO connected to LED

```
#!/bin/sh
# Modified from https://gist.github.com/huzhifeng/e3c222e6b780d82967db
echo GPIO LED Test
echo   Usage: $0 [wait time] [gpio start] [gpio end]
echo Example: $0 3s 0 1
echo leave gpio range blank to test all GPIOs.
echo
wait=${1:-"3s"}
for GPIOCHIP in /sys/class/gpio/gpiochip*/ ; do
    BASE=$(cat ${GPIOCHIP}base)
    SIZE=$(cat ${GPIOCHIP}ngpio)
    MAX=$(($BASE+$SIZE-1))
    gpio_end=${3:-$MAX}
    [ -z "$gpio" ] && gpio=${2:-$BASE}
    while [ $gpio -ge $BASE -a $gpio -le $MAX -a $gpio -le $gpio_end ] ; do
        # Save original value if needed
        if [ -d /sys/class/gpio/gpio${gpio} ]; then
            DIRECTION=$(cat /sys/class/gpio/gpio${gpio}/direction)
            UNEXPORT=0
            VALUE=$(cat /sys/class/gpio/gpio$gpio/value)
        else
            echo $gpio > /sys/class/gpio/export
            UNEXPORT=1
            DIRECTION=""
            VALUE=""
        fi
        if [ -d /sys/class/gpio/gpio${gpio} ]; then
            echo out > /sys/class/gpio/gpio$gpio/direction
 
            echo "[gpiochip${BASE}:$gpio:out] = 0"
            echo 0 > /sys/class/gpio/gpio$gpio/value
            sleep $wait
 
            echo "[gpiochip${BASE}:$gpio:out] = 1"
            echo 1 > /sys/class/gpio/gpio$gpio/value
            sleep $wait
 
            # Restore original value
            [ ! -z "$DIRECTION" ] && echo $DIRECTION > /sys/class/gpio/gpio${gpio}/direction
            [ ! -z "$VALUE" ] && echo $VALUE > /sys/class/gpio/gpio${gpio}/value
            [ "$UNEXPORT" -eq 1 ] && echo ${gpio} > /sys/class/gpio/unexport
        else
            echo "[gpiochip${BASE}:${gpio}] = Failed to export"
        fi
 
        gpio=$((gpio+1))
    done
done
```

1. Run the script, the script can loop all GPIOs
2. Look at the LED and record the number printed when LED is on or off

Note: some GPIOs may return an error because they're already used by the Linux kernel (i.e LEDS).

## Finding GPIO pins (input) on the PCB

### script "gpio in"

Sometimes you do not know where the physical GPIO pins (input) are on your device's PCB. In that case, you can use this little script and see screen to find the input.

```
#!/bin/sh
GPIOBASE=`cat /sys/class/gpio/gpiochip*/base | head -n1`
GPIOmin=`expr $1 + $GPIOBASE`
GPIOmax=`expr $2 + $GPIOBASE`
 
cd /sys/class/gpio
for i in `seq $GPIOmin $GPIOmax`; do
echo $i > export; echo in >gpio$i/direction
done
nums=`seq $GPIOmin $GPIOmax`
while true; do
  for i in $nums; do
     echo read gpio$i 
     cat /sys/class/gpio/gpio$i/value
 done
  sleep 1
done
```

1. Start with `./gpio 0 30`, which means pin 0 to 30
2. Press button or change the value input.
3. The script returns on screen: 'read gpio+number' followed by '0' or '1'.
4. Press ctrl-c to stop the script, then check which GPIOs have been created: `find /sys/class/gpio/gpio*`

### script "gpio in"

Another script which check each GPIO one-by-one

```
#!/bin/sh
# Modified from https://gist.github.com/huzhifeng/e3c222e6b780d82967db
echo GPIO Button Test
echo   Usage: $0 [gpio start] [gpio end]
echo Example: $0 0 1
echo leave gpio range blank to test all GPIOs.
echo 
for GPIOCHIP in /sys/class/gpio/gpiochip*/ ; do
    BASE=$(cat ${GPIOCHIP}base)
    SIZE=$(cat ${GPIOCHIP}ngpio)
    MAX=$(($BASE+$SIZE-1))
    gpio_end=${2:-$MAX}
    [ -z "$gpio" ] && gpio=${1:-$BASE}
    while [ $gpio -ge $BASE -a $gpio -le $MAX -a $gpio -le $gpio_end ] ; do
        # Save original value if needed
        if [ -d /sys/class/gpio/gpio${gpio} ]; then
            DIRECTION=$(cat /sys/class/gpio/gpio${gpio}/direction)
            UNEXPORT=0
        else
            echo $gpio > /sys/class/gpio/export
            UNEXPORT=1
            DIRECTION=""
        fi
        if [ -d /sys/class/gpio/gpio${gpio} ]; then
            echo in > /sys/class/gpio/gpio${gpio}/direction
            echo "[gpiochip${BASE}:${gpio}:in] = $(cat /sys/class/gpio/gpio${gpio}/value)"
 
            # Restore original value
            [ ! -z "$DIRECTION" ] && echo $DIRECTION > /sys/class/gpio/gpio${gpio}/direction
            [ "$UNEXPORT" -eq 1 ] && echo ${gpio} > /sys/class/gpio/unexport
        else
            echo "[gpiochip${BASE}:${gpio}] = Failed to export"
        fi
 
        gpio=$((gpio+1))
    done
done
```

1. Start with `./gpio`, which means all GPIOs
2. Hold a button and run again, release only after the script has been finished
3. Compare the changed GPIO value which corresponding to the button held

## Links

- [Kernel gpio documentation](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/Documentation/driver-api/gpio "https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/Documentation/driver-api/gpio")
- [other kernel gpio doc](http://www.mjmwired.net/kernel/Documentation/gpio.txt "http://www.mjmwired.net/kernel/Documentation/gpio.txt")

## Devices

The list of related devices: [gpio](/tag/gpio?do=showtag&tag=gpio "tag:gpio")
