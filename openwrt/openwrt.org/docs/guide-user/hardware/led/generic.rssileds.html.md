# Use LEDs to show signal strength with rssileds

The rssileds package allows you to control LEDs on a router or access point depending on the signal strength of a WiFi interface.

For instance, many wireless repeaters and range extenders have a signal strength meter on them for the received signal.

## Step 1: installing rssileds

```
opkg update
opkg install rssileds
```

## Step 2: configuring the system

The rssileds configuration is stored in the “system” UCI section. At least two sections are needed.

### rssileds configuration

Name Type Required Default Description `refresh` integer yes *(none)* Refresh rate in microseconds `threshold` integer yes *(none)* The minimun required change in the quality to trigger a LED refresh action `dev` string yes *(none)* Specifies the used wireless adapter, must refer to one of the defined wifi-device sections ![:!:](/lib/images/smileys/exclaim.svg) The node name is used to link each LED rule to the rssi block configuration

### LED definitions

Options available for the “rssi trigger”, for more details on other parameters refer to LED section in [System configuration](/docs/guide-user/base-system/led_configuration "docs:guide-user:base-system:led_configuration").

Name Type Required Default Description `iface` string yes *(none)* Specifies the rssi block, must refer to the name defined in the “rssid” block sections `minq` integer yes *(none)* The minimum quality percentage for the LED to turn on `maxq` integer yes *(none)* The maximum quality percentage for the LED to turn on `offset` integer no 0 Used for PWM LED, the led brightness is equal to the quality with the specified offset `factor` integer no 1 Used for PWM LED, after the offset is applied, the brightness is scaled by the specified factor ![:?:](/lib/images/smileys/question.svg) With PWM capable LEDs the brightness is calculated as: `brightness = ( quality + offset ) * factor` ![:!:](/lib/images/smileys/exclaim.svg) Any quality values outside the specified range will mean the LED is off

### Example

```
config rssid 'wlan0'         
        option refresh 40000          
        option threshold 1   
        option dev 'wlan0'
 
config led 'rssilow'                        
        option trigger 'rssi'               
        option name 'RSSILOW'               
        option iface 'wlan0'                
        option sysfs 'mt2681:green:rssilow'
        option minq '1'                    
        option maxq '100'    
        option offset '0'                  
        option factor '6'    
 
config led 'rssimedium'     
        option trigger 'rssi'              
        option name 'RSSIMEDIUM'
        option iface 'wlan0'    
        option sysfs 'mt2681:green:rssimed'
        option minq '30'                   
        option maxq '100'    
        option offset '-29'                
        option factor '5'    
 
config led 'rssihigh'       
        option trigger 'rssi'              
        option name 'RSSIHIGH'
        option iface 'wlan0'  
        option sysfs 'mt2681:green:rssihigh'
        option minq '70'                    
        option maxq '100'    
        option offset '-69'                 
        option factor '8'    
```
