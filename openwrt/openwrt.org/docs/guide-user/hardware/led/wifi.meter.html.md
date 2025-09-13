# Signal strength LED meter

Sometimes you may need a simple indicator to know if the link has a good signal strength. Or for moving an antenna to catch the remote AP. Using leds is the more simple aproach.

## Scripts

### By blinking one led

This script uses 5 different blinks on the same led to show the signal strength. When blinking, if the led is more time on, it means the signal is better.

[![](/_media/media/doc/howtos/led-meter-ex.gif)](/_media/media/doc/howtos/led-meter-ex.gif "media:doc:howtos:led-meter-ex.gif")

The image shows left to right worst to best signal.

```
#!/bin/sh
#Filename: ledwsignal.sh 
#Description: This script shows wifi signal strength by blinking one led.
#2015 raphik, danitool
 
AVLEDS=`ls /sys/class/leds`
ELED=`ls /sys/class/leds|grep -wo -m1 "$1"`
OLD_STRENGTH=-1
 
Led_On() { 
	  echo $2 > /sys/class/leds/$1/delay_on 
}
 
Led_Off() {
	  echo $2 > /sys/class/leds/$1/delay_off
}
 
#HELP
if [ "$#" -ne 1 ] || [ "$ELED" != "$1" ]; then
    printf "\nUSAGE:
    ledwsignal.sh <led name>
    \navailable leds:\n$AVLEDS
    \n\nERROR\n"
    exit 255
fi
 
echo timer > /sys/class/leds/$1/trigger
 
while true ; do
  RSSI=`cat /proc/net/wireless | awk 'NR==3 {print $4}' | sed 's/\.//'`
  #echo "RSSI: $RSSI"
 
  if [ -z $RSSI ] || [ $RSSI -ge 0 ]; then STRENGTH=0 #error
  elif [ $RSSI -ge -65 ] ; then STRENGTH=4 #excellent
  elif [ $RSSI -ge -73 ] ; then STRENGTH=3 #good
  elif [ $RSSI -ge -80 ] ; then STRENGTH=2 #fair
  elif [ $RSSI -ge -94 ] ; then STRENGTH=1 #bad
  else STRENGTH=0
  fi
 
  if [ $OLD_STRENGTH != $STRENGTH ] ; then
    case $STRENGTH in
      4)  Led_On $1 1960; Led_Off $1 40 ;;
      3)  Led_On $1 950;  Led_Off $1 50  ;;
      2)  Led_On $1 500;  Led_Off $1 500 ;;
      1)  Led_On $1 50;   Led_Off $1 950  ;;
      0)  Led_On $1 40;   Led_Off $1 1960 ;;
    esac
    echo "STRENGTH (0-4): $STRENGTH"
  fi
 
OLD_STRENGTH=$STRENGTH
 
sleep 3
done
exit
```

### By controlling one led brightness

This script virtually controls the brightness of the led using the concept of PWM for brightness, with an interval of 20 miliseconds and 4 states:

- Excelent signal: Full brightness (no PWM)
- Good signal: High brightness
- Fair signal: Low brightness
- Bad signal: Minimal brightness (1 milisecond on)
- Signal error: Blinking led

```
#!/bin/sh
#Filename: ledwsignal.sh 
#Description: This script shows wifi signal strength by controlling one led brightness
#2015 raphik, danitool
 
AVLEDS=`ls /sys/class/leds`
ELED=`ls /sys/class/leds|grep -wo -m1 "$1"`
OLD_STRENGTH=-1
 
Led_On() { 
	  echo $2 > /sys/class/leds/$1/delay_on 
}
 
Led_Off() {
	  echo $2 > /sys/class/leds/$1/delay_off
}
 
#HELP
if [ "$#" -ne 1 ] || [ "$ELED" != "$1" ]; then
    printf "\nUSAGE:
    ledwsignal.sh <led name>
    \navailable leds:\n$AVLEDS
    \n\nERROR\n"
    exit 255
fi
 
echo timer > /sys/class/leds/$1/trigger
 
while true ; do
  RSSI=`cat /proc/net/wireless | awk 'NR==3 {print $4}' | sed 's/\.//'`
  #echo "RSSI: $RSSI"
 
  if [ -z $RSSI ] || [ $RSSI -ge 0 ]; then STRENGTH=0 #error
  elif [ $RSSI -ge -65 ] ; then STRENGTH=4 #excellent
  elif [ $RSSI -ge -73 ] ; then STRENGTH=3 #good
  elif [ $RSSI -ge -80 ] ; then STRENGTH=2 #fair
  elif [ $RSSI -ge -94 ] ; then STRENGTH=1 #bad
  else STRENGTH=0
  fi
 
  if [ $OLD_STRENGTH != $STRENGTH ] ; then
      if [ $OLD_STRENGTH = 4 ] ; then echo timer > /sys/class/leds/$1/trigger
      fi
      case $STRENGTH in
	4)  echo default-on > /sys/class/leds/$1/trigger ;;
	3)  Led_On $1 12;  Led_Off $1 8  ;;
	2)  Led_On $1 6;   Led_Off $1 14 ;;
	1)  Led_On $1 1;   Led_Off $1 19  ;;
	0)  Led_On $1 500; Led_Off $1 500 ;;
      esac
  echo "SIGNAL STRENGTH (0-4): $STRENGTH"
  fi
 
OLD_STRENGTH=$STRENGTH
 
sleep 3
done
exit
```

Note: to appreciate the different led states with this script you may need to be in a dark environment.
