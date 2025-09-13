# PWM emulation with GPIO

It's possible to use a GPIO with a kernel driver for making it work as a [PWM](https://en.wikipedia.org/wiki/Pulse-width_modulation "https://en.wikipedia.org/wiki/Pulse-width_modulation").

```
HIGH      _      _      _      _      _      _      _      _     
         | |    | |    | |    | |    | |    | |    | |    | |    
GPIO     | |    | |    | |    | |    | |    | |    | |    | |    
       __| |____| |____| |____| |____| |____| |____| |____| |____
LOW 
```

Only tested in Attitude Adjustment. Patching, and building a custom firmware required.

Driver made by Bill Gatliff.

Emulates a PWM device using a GPIO pin and an hrtimer. Subject to CPU, scheduler and hardware limitations, can support many PWM outputs, e.g. as many as you have GPIO pins available for.

On a 200 MHz ARM9 processor, a PWM frequency of 100 Hz can be attained with this code so long as the duty cycle remains between about 20-80%. At higher or lower duty cycles, the transition events may arrive too close for the scheduler and CPU to reliably service.

Caveats:

- The GPIO pin number must be valid, not already in use
- The output state of the GPIO pin is configured when the PWM starts running i.e. not immediately upon request, because the polarity of the inactive state of the pin isn't known until the pwm device's 'polarity' attribute is configured
- After creating and binding the pwm device, you must then request it by writing to /sys/class/pwm/gpio-pwm.&lt;gpio number&gt;/export

## Firmware modification

Download the source code of Attitude Adjustment, and this file [pwm-gpio-aa.tar.gz](/_media/media/doc/howtos/pwm-gpio-aa.tar.gz "media:doc:howtos:pwm-gpio-aa.tar.gz (14.7 KB)"). Patch the build root

> patch -p1 -i pwm-gpio-AA.patch

Enter in the kernel menu:

> make kernel\_menuconfig

and ensure configfs, PWM and GPIO\_PWM are enabled.

You can use a native led at the router to test the driver, but first remove it from the board definition to get the gpio access.

## Openwrt commands

Once flashed and openwrt running:

```
mkdir /config
mount -t configfs none /config
```

Now create configurable GPIO PWM, example using the GPIO8

```
mkdir /config/gpio_pwm/8
echo 1 > /sys/class/pwm/gpio_pwm\:8/export
```

Check tick-hz

```
root@OpenWrt:/# cat /sys/class/pwm/gpio_pwm\:8/tick_hz 
1000000000
root@OpenWrt:/#
```

Define the **period** for 100 Hz:

```
echo 10000000 > /sys/class/pwm/gpio_pwm\:8/period_ns
```

Define the **duty cycle**, 10%

```
echo 1000000 > /sys/class/pwm/gpio_pwm\:8/duty_ns
```

Run it

```
echo 1 > /sys/class/pwm/gpio_pwm\:8/run
```

If a led is connected it should should bright at 10% or 90% depending on LED polarity.

Let's increase/decrease the virtual brightness

```
echo 1000000 > /sys/class/pwm/gpio_pwm\:8/duty_ns
echo 2000000 > /sys/class/pwm/gpio_pwm\:8/duty_ns
echo 3000000 > /sys/class/pwm/gpio_pwm\:8/duty_ns
echo 4000000 > /sys/class/pwm/gpio_pwm\:8/duty_ns
echo 5000000 > /sys/class/pwm/gpio_pwm\:8/duty_ns
echo 6000000 > /sys/class/pwm/gpio_pwm\:8/duty_ns
echo 7000000 > /sys/class/pwm/gpio_pwm\:8/duty_ns
echo 8000000 > /sys/class/pwm/gpio_pwm\:8/duty_ns
```

To disable, stop, unexport and delete it:

```
echo 0 > /sys/class/pwm/gpio_pwm\:8/run
echo 1 > /sys/class/pwm/gpio_pwm\:8/unexport
rm -rf /config/gpio_pwm/8
```
