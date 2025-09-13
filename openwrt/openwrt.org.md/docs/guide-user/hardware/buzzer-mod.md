# Add a buzzer (beeper) to the router

A buzzer or beeper is an audio signalling device tipically used for alarms or timers. They need an oscillating circuit to make them work. Fortunatelly there are in the market buzzers with the oscillating circuit already built in. These buzzers with the oscillating circuit included are usually called:

- Active buzzers
- Self-drive buzzers
- DC buzzers

[![](/_media/media/doc/howtos/buzzer.jpg?w=200&tok=d572ee)](/_media/media/doc/howtos/buzzer.jpg "media:doc:howtos:buzzer.jpg")

They are commonly made with a piezoelectric buzzer plus the oscillating circuit. They work with a DC power source and the typical current consumption is about 10 mA.

The drawback of these active buzzers is they make beeps with a fixed frequency, about 2.3 kHz.

## Feed the buzzer with a transistor

We can connect the buzzer to a LED GPIO driven on the router. Depending on the type of LED, active low or high, we will use a **PNP** or **NPN** transistor to feed the active buzzer. Almost any transistor should work since a buzzer doesn't require much current to work.

Most routers use use active LOW leds connected to GPIOs. Check both pins of the led, if one is connected to Vcc then it's an active low LED, if connected to GND then it's active HIGH.

### Active low circuit

When the led is active LOW, we must use a PNP transistor:

[![](/_media/media/doc/howtos/buzzer-mod-low.png?w=300&tok=2d258f)](/_media/media/doc/howtos/buzzer-mod-low.png "media:doc:howtos:buzzer-mod-low.png")

### Active high circuit

And when the led is active HIGH, we must use a NPN transistor:

[![](/_media/media/doc/howtos/buzzer-mod-high.png?w=300&tok=65f772)](/_media/media/doc/howtos/buzzer-mod-high.png "media:doc:howtos:buzzer-mod-high.png")

### Example

This is a board with active low LEDs

[![](/_media/media/doc/howtos/buzzer-mod-low-board.jpg?w=300&tok=fc658c)](/_media/media/doc/howtos/buzzer-mod-low-board.jpg "media:doc:howtos:buzzer-mod-low-board.jpg")

## Connect directly the buzzer

It could be also possible to connect directly the buzzer in parallel with the led. This can be possible if the buzzer doesn't need more than about 2mA to work.

[![](/_media/media/doc/howtos/buzzer-mod-direct.png?w=250&tok=18d76e)](/_media/media/doc/howtos/buzzer-mod-direct.png "media:doc:howtos:buzzer-mod-direct.png")

Of course it could also be possible to attach the buzzer to a free GPIO. GPIOs usually can supply about 4mA safetly. An active high circuit should be used in this case: [![](/_media/media/doc/howtos/buzzer-mod-high-gpiodirect.png?w=250&tok=290092)](/_media/media/doc/howtos/buzzer-mod-high-gpiodirect.png "media:doc:howtos:buzzer-mod-high-gpiodirect.png")

It's also possible to atach the buzzer directly to the gpio, but the buzzer shouldn't draw more than 4 mA

[![](/_media/media/doc/howtos/buzzer-mod-direct-gpio.png?w=90&tok=c2e1cd)](/_media/media/doc/howtos/buzzer-mod-direct-gpio.png "media:doc:howtos:buzzer-mod-direct-gpio.png")

If you draw more current from the GPIO beyond its capacity, you could damage the SoC.

## Make some beeps

Since the buzzer is connected to a configurable LED on the router, they will be controlled together. Just configure the LED where the buzzer is soldered via Luci web interface, or use the sys filesystem interface.

Examples:

```
echo timer > /sys/class/leds/MYLED/trigger
 
echo oneshot > /sys/class/leds/MYLED/trigger
echo 1 > /sys/class/leds/MYLED/shot
 
echo morse > /sys/class/leds/MYLED/trigger
echo "SOS" > /sys/class/leds/MYLED/message
 
echo 1 > /sys/class/leds/MYLED/brightness
echo 0 > /sys/class/leds/MYLED/brightness
```
