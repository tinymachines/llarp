# Exceeding transmit power limits

**TL;DR** Don't do it. Increasing transmit power over the the limits for your country is against the law. (OpenWrt automatically set the levels properly if you select the right nation in the wifi settings.) But here are additional reasons that you should consider.

## Altruistic reasons to stay within the limits

### Spillage on neighboring bands

I bet that if you were cranking up the power, you would quickly fail even this very simple bandwidth test:

- [https://wifinigel.blogspot.hu/2013/02/adjacent-channel-interference.html](https://wifinigel.blogspot.hu/2013/02/adjacent-channel-interference.html "https://wifinigel.blogspot.hu/2013/02/adjacent-channel-interference.html")

You could also look into the effect by executing an ath9k spectral scan on the edge of your channel from another computer.

- [https://wireless.wiki.kernel.org/en/users/drivers/ath9k/spectral\_scan](https://wireless.wiki.kernel.org/en/users/drivers/ath9k/spectral_scan "https://wireless.wiki.kernel.org/en/users/drivers/ath9k/spectral_scan")
- [https://github.com/kazikcz/ath9k-spectral-scan](https://github.com/kazikcz/ath9k-spectral-scan "https://github.com/kazikcz/ath9k-spectral-scan")
- [http://blog.altermundi.net/article/playing-with-ath9k-spectral-scan/](http://blog.altermundi.net/article/playing-with-ath9k-spectral-scan/ "http://blog.altermundi.net/article/playing-with-ath9k-spectral-scan/")
- [https://github.com/vanhoefm/modwifi-ath9k-htc/wiki/Spectral-Scan](https://github.com/vanhoefm/modwifi-ath9k-htc/wiki/Spectral-Scan "https://github.com/vanhoefm/modwifi-ath9k-htc/wiki/Spectral-Scan")

### Increased general RF noise in random parts of the spectrum

See next points about heat, pushing components to their limits and noise.

### Tragedy of the commons

You increase volume of your boom box because you can't hear your music due to a loud neighbor, your neighbor then increases volume a bit more, forevermore.

- [https://en.wikipedia.org/wiki/Tragedy\_of\_the\_commons](https://en.wikipedia.org/wiki/Tragedy_of_the_commons "https://en.wikipedia.org/wiki/Tragedy_of_the_commons")

## Egoistic reasons to stay within the limits

### Distortion of the intended output signal

Such imperfection makes the signal harder to decode at a distance or in worst case may even force slower links or increased packet loss altogether.

Testing is as simple as checking for throughput at a distance while monitoring packet error rate and link rate. MIMI testing is also a good idea in this case. Although if the distortion is not that great, the effect seen hare may be smaller, the constellation imperfections could make other parts of the circuit work harder, thus introducing more noise.

### NIC and PA overheating

Reduced lifetime, added noise, temporarily or permanently reduced sensitivity, risk of instability, added system heat

### Power consumption increase

Remember that due to DC/DC and AC/DC conversion efficiencies, increasing TX power by 1W could easily present an additional load of 1.5W.

It may drive components in the switching power supply over their limits: reduced lifetime, added noise, temporarily reduced sensitivity, risk of instability, added system heat.

It also mildly increases electricity costs and decreases time on battery.

It can cause certain AC PSU units to start producing an unbearable audible squeak/whine more quickly than planned.

### General EMI increase

Mostly affects your own equipment nearby, though your neighbors may not be happy either.

### Proper coverage with multiple AP/repeaters

It may even cause your nodes to interfere with each other. The general recommendation has always been to reduce TX power whenever possible.

### SINR vs. SNR

Does not help you if you are already limited by interference and not noise. This is the case for many high density, medium-range urban settings.

### Link asymmetry

Does not help that much if only one side of the link is shouting: the other side is still whispering and our side has still not improved in sensitivity, it is much better to reduce TX power to the minimum and place directional antennae on both sides.

### If you get caught

You are legally responsible for willfully interfering with telecommunications as the operator of this non-certified system modification.

## References

- [https://openwrt.org/toh/tp-link/tl-mr3020#external\_antenna\_output\_power](https://openwrt.org/toh/tp-link/tl-mr3020#external_antenna_output_power "https://openwrt.org/toh/tp-link/tl-mr3020#external_antenna_output_power")
- [https://openwrt.org/docs/guide-user/network/wifi/faq.wireless#can\_i\_adjust\_the\_transmit\_power](https://openwrt.org/docs/guide-user/network/wifi/faq.wireless#can_i_adjust_the_transmit_power "https://openwrt.org/docs/guide-user/network/wifi/faq.wireless#can_i_adjust_the_transmit_power")
- [https://www.dd-wrt.com/wiki/index.php/Advanced\_wireless\_settings#TX\_Power](https://www.dd-wrt.com/wiki/index.php/Advanced_wireless_settings#TX_Power "https://www.dd-wrt.com/wiki/index.php/Advanced_wireless_settings#TX_Power")
- [https://www.dd-wrt.com/wiki/index.php/Atheros/ath\_wireless\_settings#TX\_Power](https://www.dd-wrt.com/wiki/index.php/Atheros/ath_wireless_settings#TX_Power "https://www.dd-wrt.com/wiki/index.php/Atheros/ath_wireless_settings#TX_Power")
- [https://dfarq.homeip.net/reduce-dd-wrt-packet-errors/](https://dfarq.homeip.net/reduce-dd-wrt-packet-errors/ "https://dfarq.homeip.net/reduce-dd-wrt-packet-errors/")

## Failed attempts

Note that such hacks never turn out well, but most people are too embarrassed to confess that, so most threads seem to simply fade away. There are a few who do stand up and note that they aren't getting what they've expected, though.

- [https://forum.openwrt.org/t/atheros-art-bypass/7130/8](https://forum.openwrt.org/t/atheros-art-bypass/7130/8 "https://forum.openwrt.org/t/atheros-art-bypass/7130/8")
- [https://forum.openwrt.org/viewtopic.php?id=44916](https://forum.openwrt.org/viewtopic.php?id=44916 "https://forum.openwrt.org/viewtopic.php?id=44916")
- [https://forum.openwrt.org/viewtopic.php?id=65655](https://forum.openwrt.org/viewtopic.php?id=65655 "https://forum.openwrt.org/viewtopic.php?id=65655")
- [https://forums.kali.org/showthread.php?28874-ALFA-AWUS036NHA-hacking-EEPROM-via-UART-JTAG](https://forums.kali.org/showthread.php?28874-ALFA-AWUS036NHA-hacking-EEPROM-via-UART-JTAG "https://forums.kali.org/showthread.php?28874-ALFA-AWUS036NHA-hacking-EEPROM-via-UART-JTAG")
- [https://www.dd-wrt.com/phpBB2/viewtopic.php?p=651588](https://www.dd-wrt.com/phpBB2/viewtopic.php?p=651588 "https://www.dd-wrt.com/phpBB2/viewtopic.php?p=651588")

## Conspiracy theories regarding manufacturers segmenting the market

The exact value you find on your given router represents the absolute maximum power it can output on its antennae without ill effects. They are calibrated on each channel and modulation one by one at the factory.

If a given NIC or PA could support more than this, believe me, they would be happy to advertise and sell them stating so. As can be seen from above, the cheapest models fail to hit the ceiling of the restrictive 20dBm European limit even at the slowest link rate.

Sadly, above a certain level, NIC, PA and filtering cost a lot of money and it is well worth it to selectively breed and mass produce devices with inferior capabilities, thus saving the average buyer many dollars.

If what you get does not suit your needs, you must purchase a different router or wireless card. And of course always obey the regulations that apply to the country of operation.

The ball park of non-regulatory, hardware capabilities reported by \`iw phy\` (loaded from ART) seem to be correlated to the wireless NIC (and PA) and not tied to the exact model.

- [Table of capabilities for wireless chipsets](/docs/guide-user/network/wifi/chipset.capabilities "docs:guide-user:network:wifi:chipset.capabilities")
