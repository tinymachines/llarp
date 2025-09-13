# Soldering

## Most Common Mistakes

Beginners and casual modders, keep these in mind. These are mistakes ordered roughly from most common to least common.

- Cold solder joints, i.e. with a profile looking like (|) instead of /|\\ because of not heating enough pin before applying heat, not using flux to conduct heat, using a soldering iron not sufficiently hot.
- Thinking that you can get away without using at least three hands, human or mechanical for holding iron, solder and magnifying glass.
- Solder bridges between pins because of too much solder applied.
- Not making sure hardware mod is perfect both visually (with a magnifying glass) and electrically (audible continuity tester, ohmmeter and diode tester checks on unpowered device) before trying to debug software.
- Not making a hardware mod that will be rugged enough for possibly quite a few connect/disconnect cycles, i.e. flimsy connector, no strain relief on manipulated wire.
- Pieces of conductive material hanging around (solder blobs, pieces of wire).
- Flux left on board making medium-resistance bridges between critical pins.

## General

- [Soldering](https://en.wikipedia.org/wiki/Soldering "https://en.wikipedia.org/wiki/Soldering"), [Solder](https://en.wikipedia.org/wiki/Solder "https://en.wikipedia.org/wiki/Solder"), [Flux (metallurgy)](https://en.wikipedia.org/wiki/Flux%20%28metallurgy%29 "https://en.wikipedia.org/wiki/Flux (metallurgy)")
- [Chip carrier](https://en.wikipedia.org/wiki/Chip%20carrier "https://en.wikipedia.org/wiki/Chip carrier"), [TSOP](https://en.wikipedia.org/wiki/Thin%20small-outline%20package "https://en.wikipedia.org/wiki/Thin small-outline package"), [BGA](https://en.wikipedia.org/wiki/Ball%20grid%20array "https://en.wikipedia.org/wiki/Ball grid array"), to get an overview you could have read [Chip\_carrier\_drawings](https://en.wikipedia.org/wiki/Chip_carrier_drawings "https://en.wikipedia.org/wiki/Chip_carrier_drawings"), but some idiot deleted it. But it looks like somebody saved the content here: [Some Wikia page](http://how-to.wikia.com/wiki/Howto_identify_integrated_circuit%28IC%29_chip_packages "http://how-to.wikia.com/wiki/Howto_identify_integrated_circuit%28IC%29_chip_packages") ![;-)](/lib/images/smileys/wink.svg)

## Equipment

This is NOT for marketing purposes.

- [Soldering iron](https://en.wikipedia.org/wiki/Soldering%20iron "https://en.wikipedia.org/wiki/Soldering iron") ← typical low quality Wikipedia article, when somebody finds an better one, please replace it (mind the License though)
- [Helping\_hand\_(tool)](https://en.wikipedia.org/wiki/Helping_hand_%28tool%29 "https://en.wikipedia.org/wiki/Helping_hand_(tool)") you can buy this, or manufacture one yourself
- [Hackerspace](https://en.wikipedia.org/wiki/Hackerspace "https://en.wikipedia.org/wiki/Hackerspace") maybe they lend you equipment. Bring Pizza and be careful: some Hackers do sacrifice to Odin. Bring your Hamster.
  
  - [http://hackerspaces.org/wiki/List\_of\_Hacker\_Spaces](http://hackerspaces.org/wiki/List_of_Hacker_Spaces "http://hackerspaces.org/wiki/List_of_Hacker_Spaces") here all Hackerspaces are *“notable”*.

## Howtos

### Videos

- a very good introduction to surface soldering. Tells you what equipment to use, why and how ![;-)](/lib/images/smileys/wink.svg) From time: 6:20 you also learn about removing parts
- another (shorter) introduction
- SMD Components self-align in toaster / skillet reflow
- [http://www.mikrocontroller.net/articles/SMD\_L%C3%B6ten](http://www.mikrocontroller.net/articles/SMD_L%C3%B6ten "http://www.mikrocontroller.net/articles/SMD_L%C3%B6ten") german language, with links to videos in German or English language

### Pictures

Do we need this? There are excellent videos with audio commentary from professionals for free on the web!

### Text

There are excellent videos with audio commentary! But if somebody is deaf and wants to read about it, here it is:

- [pdf](http://www.indium.com/_dynamo/download.php?docid=323 "http://www.indium.com/_dynamo/download.php?docid=323") License?
- Read [desoldering](https://en.wikipedia.org/wiki/desoldering "https://en.wikipedia.org/wiki/desoldering")

Be careful to remove the old one! Following procedure has been working for me:

1. consider unsoldering all big capacitor close to the memory that may block access. Better then bending them and risking rupture.
2. Wrap the board in Aluminum foil so that only the memory is visible.
3. Heat the chip with a [heat gun](https://en.wikipedia.org/wiki/heat%20gun "https://en.wikipedia.org/wiki/heat gun") (a hairdryer is *not* enough)
4. Once the chip is decently hot, slap the board carefully to the table, the chip should fall off. If not repeat 3.)
5. remove the excess of solder by using a fine desoldering braid, see [Desoldering](https://en.wikipedia.org/wiki/Desoldering "https://en.wikipedia.org/wiki/Desoldering")
6. put the new IC very exactly to the pads and solder on two corners. Then solder the rest.
7. Resolder the condensators.

An alternate method to use a small butane torch, such as a jet lighter to heat the chip pins. Keep the flame moving and do not linger in one spot. This method is faster than a heatgun and does not require masking of the board or removal of the capacitors, but requires more care to avoid scorching the components or board.

Yet another alternate method for if you only have a soldering iron (nonetheless with a small tip) is to simply flood all the pins with solder so that they're bridged and then, maintaining heat to it, use tweezers to lift that side up off the board, then simply do the same with the other side and finally, clean up all the solder using some copper solder braid to absorb it.

When it comes to resoldering, you can do roughly the same in reverse; first get the chip lined up with the pads and stuck down with masking tape and/or blu-tack then again flood the pins with solder and use solder braid to soak it all up... assuming you do it right there won't be any joins between the pins, but of course, use a magnifying glass to check it, and a scalpel can do wonders if there's a join you just can't get rid of.

If the router is not working and you see a permanent restart on the serial console, check the connections, the memory is quite hard to destroy.
