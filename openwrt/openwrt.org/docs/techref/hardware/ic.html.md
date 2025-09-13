# Integrated Circuit

From [Transistor](https://en.wikipedia.org/wiki/Transistor "https://en.wikipedia.org/wiki/Transistor") to [Electrical circuit](https://en.wikipedia.org/wiki/Electrical%20network "https://en.wikipedia.org/wiki/Electrical network") to [Electronic circuit](https://en.wikipedia.org/wiki/Electronic%20circuit "https://en.wikipedia.org/wiki/Electronic circuit") to [Integrated Circuit](https://en.wikipedia.org/wiki/Integrated%20Circuit "https://en.wikipedia.org/wiki/Integrated Circuit"). Today, a great variety of [ASIC](https://en.wikipedia.org/wiki/Application-specific%20integrated%20circuit "https://en.wikipedia.org/wiki/Application-specific integrated circuit")s exist.

**NOTE:** The processing of information can be done by flow and storage of data. Data can be represented by the switching status of switches, and the flow of data can be managed by potatoes, fluids, gases or by electrical current. See the article [Circuit](https://en.wikipedia.org/wiki/Circuit "https://en.wikipedia.org/wiki/Circuit") for an overview of different types of circuits.

A very simple functionality thingy is here: [impressive](http://www.youtube.com/watch?feature=player_detailpage&v=fehUKMTepd8#t=292s "http://www.youtube.com/watch?feature=player_detailpage&v=fehUKMTepd8#t=292s"); replace the balls with potatoes or with a bunch of electrons. You understand that, you understand information processing. If you then see what a relay, and vacuum tube and a transistor have in common, you understand their use in information processing. And once you understand that, you basically know how a processor works: It's all math, it's all about arithmetic operations.

## A step-by-step approach

### 1. The Transistor

A transistor is a very simple and very basic electronic component. It can be used to do the same thing as a [relay](https://en.wikipedia.org/wiki/Relay "https://en.wikipedia.org/wiki/Relay") or a [vacuum tube](https://en.wikipedia.org/wiki/Vacuum%20tube "https://en.wikipedia.org/wiki/Vacuum tube") but it can be shrunk to much lower levels than these electronic components. It consumes less current and the production is far cheaper. Thus in the field of data processing, the transistor replaced them completely.

### 2. The Circuit

By **combining more Transistors** to build a **circuit** you can achieve different tasks, such as:

- [Transistor Teil 1](http://www.youtube.com/watch?v=si8gJpVhVfs&feature=related "http://www.youtube.com/watch?v=si8gJpVhVfs&feature=related")
- [Der Transistor Teil 2 Emitterschaltung](http://www.youtube.com/watch?v=Gm1A6x6ZWWc&feature=related "http://www.youtube.com/watch?v=Gm1A6x6ZWWc&feature=related")
- [Der Transistor Teil 3 Die Basisschaltung](http://www.youtube.com/watch?v=xx-hJQZDwiA&feature=related "http://www.youtube.com/watch?v=xx-hJQZDwiA&feature=related")
- [Der Transistor Teil 4 Die Kollektorschaltung](http://www.youtube.com/watch?v=rA41NdFLSNI&feature=related "http://www.youtube.com/watch?v=rA41NdFLSNI&feature=related")
- [How a MOSFET transistor works](http://www.youtube.com/watch?v=lf4V97HZZ0M&NR=1 "http://www.youtube.com/watch?v=lf4V97HZZ0M&NR=1")

Basically these represent different control tasks. And as you can see, the logic “is the equivalent”/“equates to”/“can be described”/“reproduced” precisely with algebraical operations performed in the [Binary numeral system](https://en.wikipedia.org/wiki/Binary%20numeral%20system "https://en.wikipedia.org/wiki/Binary numeral system"). So, with using transistors only, we can construct circuits, with which we can perform algebraical operations. Using [Registers](https://en.wikipedia.org/wiki/Hardware%20register "https://en.wikipedia.org/wiki/Hardware register") we can create circuits to perform very complex operations in very short time.

[Circuit diagram](https://en.wikipedia.org/wiki/Circuit%20diagram "https://en.wikipedia.org/wiki/Circuit diagram")s are used to display and plan more simple circuits. Example: [OpAmpTransistorLevel\_Colored\_DE.svg](http://upload.wikimedia.org/wikipedia/commons/2/28/OpAmpTransistorLevel_Colored_DE.svg "http://upload.wikimedia.org/wikipedia/commons/2/28/OpAmpTransistorLevel_Colored_DE.svg"). On [http://commons.wikimedia.org/wiki/Category:Circuit\_diagrams?uselang=de](http://commons.wikimedia.org/wiki/Category:Circuit_diagrams?uselang=de "http://commons.wikimedia.org/wiki/Category:Circuit_diagrams?uselang=de") you'll find even more examples. One basically still draws all the lines through which the current flows, but uses symbols for the various electronic components. Such drawings are cumbersome for very complex circuits, but they can be realized 1:1 into hardware by soldering prefabricated components onto a [PCB](https://en.wikipedia.org/wiki/Printed%20circuit%20board "https://en.wikipedia.org/wiki/Printed circuit board").

#### Examples

As you see, we distinguish between [Analog](http://commons.wikimedia.org/wiki/Category:Analog_signal_processing_circuit_diagrams "http://commons.wikimedia.org/wiki/Category:Analog_signal_processing_circuit_diagrams")- or ASPs and [Digital Signal Processing Circuit Diagrams](http://commons.wikimedia.org/wiki/Category:Digital_circuit_diagrams "http://commons.wikimedia.org/wiki/Category:Digital_circuit_diagrams") or DSPs.

### 3. The Integrated Circuit

The smaller we make the component, the more transistors we can use to do stuff because we get along with less electrical current and also, the shrinkage cuts on production cost dramatically. But how to accomplish that? By abandoning the usual way to produce individual components and instead integrate a whole lot of them directly onto silicon substrate. **NOTE:** Today this is considered trivial, but it took some serious effort to make this work!

But how to build a Transistor on silicon substrate? By working with multiple layers:

- [How to build a transistor](http://www.youtube.com/watch?v=dR-Qtv-7uWI&feature=related "http://www.youtube.com/watch?v=dR-Qtv-7uWI&feature=related") Shows a Transistor section on a IC cut through.
- [MOSFET transistor](http://www.youtube.com/watch?v=v7J_snw0Eng&feature=related "http://www.youtube.com/watch?v=v7J_snw0Eng&feature=related") Displays a nice Zoom in from the desktop

By using short wave light and several master plates, a dense but light sensitive lacker is being used as a master platter for spraying the different materials onto and into the silicon substrate.

### 4. More Complex Circuits

Adding and multiplying shit, is fun, but also a bit boring and limited. Could we have **Circuits more complex then a pocket calculator**? Yes, pretty much.

Let's use the ability to build a circuit which consists of so many (at the beginning 10, today 109) transistors, to create a processor. A computer. Like say, something like the [DEC Alpha](https://en.wikipedia.org/wiki/DEC%20Alpha "https://en.wikipedia.org/wiki/DEC Alpha") [ISA](https://en.wikipedia.org/wiki/Instruction%20set%20architecture "https://en.wikipedia.org/wiki/Instruction set architecture"). ← to complicated example?

We look at the current possibilities of the semiconductor industry and sketch the basic outline of the ISA to be, like the word-width. Bla bla, see [DEC Alpha](https://en.wikipedia.org/wiki/DEC%20Alpha "https://en.wikipedia.org/wiki/DEC Alpha"), the Wikipedia article is quite good.

The next step is to realize this theory into circuit. Something like a [Circuit diagram](https://en.wikipedia.org/wiki/Circuit%20diagram "https://en.wikipedia.org/wiki/Circuit diagram") is needed, but it would not only be very complicated to obtain such a drawing, also it would be useless, since we won't solder components onto a board. We are going to fabricate an IC onto silicon substrate, so at the end, we are going to need some plan, some drawings to accomplish that.

There are different [Hardware description language](https://en.wikipedia.org/wiki/Hardware%20description%20language "https://en.wikipedia.org/wiki/Hardware description language")s for *analogue* and for *digital circuit design* such as [VHDL](https://en.wikipedia.org/wiki/VHDL "https://en.wikipedia.org/wiki/VHDL"). As a compiler translates code written in a higher programming language into machine code, so does a different kind of compiler translate code written in a hardware description language into a plan for the wiring.

In order to understand the difference between Soft- and Hard IP Core, you should read on.

Although humans can be considered smart, our monkey brains have serious difficulties dealing with this kind of stuff. That is why, we use several layers of abstraction. As long as you merely use software running on this hardware, you basically need to know nothing about the hardware, it's specifications or even it's functionality. However, I wanted to understand some of it, so I created this article.

***Hint:*** [BSDL](https://en.wikipedia.org/wiki/Boundary%20scan%20description%20language "https://en.wikipedia.org/wiki/Boundary scan description language") is a subset of VHDL. You could use BSDL in conjunction with [JTAG](/docs/techref/hardware/port.jtag "docs:techref:hardware:port.jtag").

## Design

See [Integrated circuit design](https://en.wikipedia.org/wiki/Integrated%20circuit%20design "https://en.wikipedia.org/wiki/Integrated circuit design"). To get from the theory (ISA + microarchitecture) to the reality (silicon hardware), you need two types of “construction guidance”s. There are companies that produce such and license them for money:

Soft IP core ⇒ ![FIXME](/lib/images/smileys/fixme.svg)

Hard IP core ⇒ ![FIXME](/lib/images/smileys/fixme.svg)

### IC Physical Layout

- [Generating IC physical layout automatically Part 1](http://www.youtube.com/watch?v=6T8axj-hMxc&feature=related "http://www.youtube.com/watch?v=6T8axj-hMxc&feature=related")
- [Generating IC physical layout automatically Part 2](http://www.youtube.com/watch?v=COmPqa4euAA&feature=related "http://www.youtube.com/watch?v=COmPqa4euAA&feature=related")

<!--THE END-->

- [Lecture-1-Introduction to VLSI Design](http://www.youtube.com/watch?v=Y8FvvzcocT4&feature=related "http://www.youtube.com/watch?v=Y8FvvzcocT4&feature=related")

<!--THE END-->

- [Analog CMOS VLSI Lecture One-1 Electric Symbols](http://www.youtube.com/watch?v=dKNzHqLEtYM&feature=related "http://www.youtube.com/watch?v=dKNzHqLEtYM&feature=related")
- [Analog CMOS VLSI Lecture One -2 NMOS Structure](http://www.youtube.com/watch?v=u6TY6jKsHGQ&feature=related "http://www.youtube.com/watch?v=u6TY6jKsHGQ&feature=related")

## Manufacturing

### Industrialization and fabrication

- [The Fabrication of Integrated Circuits](http://www.youtube.com/watch?feature=player_detailpage&v=35jWSQXku74#t=123s "http://www.youtube.com/watch?feature=player_detailpage&v=35jWSQXku74#t=123s")
- [Fairchild Briefing on Integrated Circuits](http://www.youtube.com/watch?v=z47Gv2cdFtA&feature=related "http://www.youtube.com/watch?v=z47Gv2cdFtA&feature=related") ← old, but very well explained
- [Fabrication Process for CMOS Device](http://www.youtube.com/watch?v=TXvhyvwttRE&feature=fvwrel "http://www.youtube.com/watch?v=TXvhyvwttRE&feature=fvwrel") even more detail about the individual processes
- [Microchip production part 2](http://www.youtube.com/watch?v=26fkuAY8jKs&feature=related "http://www.youtube.com/watch?v=26fkuAY8jKs&feature=related") even more insight!

Some catchwords from the videos:

1. 400 process steps are required along with 15-20 different photographic negative masks
2. production of a wafer takes about 3 Weeks
3. bla bla
4. Last step involves making the connection between the various elements of the IC. Minuscule vacuum deposited layer of Al

### Package or Chip carrier

First the slicing, then the 400 processes and then the dicing. Now we put each die into a package carrier:

- [Wedge Bonding Process](http://www.youtube.com/watch?v=VwOEQodkBrY&feature=related "http://www.youtube.com/watch?v=VwOEQodkBrY&feature=related")
- [Gold Ball Bonding](http://www.youtube.com/watch?v=pajE4Bi6Xts&feature=related "http://www.youtube.com/watch?v=pajE4Bi6Xts&feature=related")
- [Bonder](http://www.youtube.com/watch?v=_qKThIzDaP0&feature=related "http://www.youtube.com/watch?v=_qKThIzDaP0&feature=related")
- [PoP](https://en.wikipedia.org/wiki/Package%20on%20package "https://en.wikipedia.org/wiki/Package on package") is implemented e.g. by the [Pandaboard](http://www.omappedia.com/images/5/54/PandaBoard_Setup.png "http://www.omappedia.com/images/5/54/PandaBoard_Setup.png")

As the Pentium Pro included CPU and L2-Cache on one *“package” or “chip”* but still on two distinct [dies](https://en.wikipedia.org/wiki/Die%20%28integrated%20circuit%29 "https://en.wikipedia.org/wiki/Die (integrated circuit)"), and the first intel QuadCores, were actually 2 distinct dies, with two CPU-Cores on each packaged on one Chip, so can a SoC consists of more then one single die.

### The PCB

The [Printed circuit board](https://en.wikipedia.org/wiki/Printed%20circuit%20board "https://en.wikipedia.org/wiki/Printed circuit board") (PCB) is for combining many components, such as CPUs, RAM, Flash, resistors, capacitors, inductors and connectors. On (and often in) the board, copper wires called “traces” or “tracks” connect all the electronic components together to form a complete, working electronic circuit.

A PCB can have from 1 to over 10 layers, each layer making additional electrical connections. In general, the more components and/or more signals that have to be routed in a circuit, the more layers are required in the PCB.

## Notes

- [Lecture - 1 Introduction to Basic Electronics](http://www.youtube.com/watch?v=w8Dq8blTmSA&feature=related "http://www.youtube.com/watch?v=w8Dq8blTmSA&feature=related") by the IIT Madras = Indian Institude of Technology
- [JTAG Training Video: "Getting Started"](http://www.youtube.com/watch?v=tpjnGFn9SP4&feature=related "http://www.youtube.com/watch?v=tpjnGFn9SP4&feature=related")
- [JTAG Training Video: "FPGA Demo Board"](http://www.youtube.com/watch?v=R0XNpB0hwwY&feature=related "http://www.youtube.com/watch?v=R0XNpB0hwwY&feature=related")
- [FPGA](https://en.wikipedia.org/wiki/Field-programmable%20gate%20array "https://en.wikipedia.org/wiki/Field-programmable gate array")
- [FPGA Basics](http://www.youtube.com/watch?v=L2wsockKwPQ&feature=related "http://www.youtube.com/watch?v=L2wsockKwPQ&feature=related")
- [Lecture 48 - System Design Examples Using FPGA Board](http://www.youtube.com/watch?v=t2Iba9CG6qE&feature=related "http://www.youtube.com/watch?v=t2Iba9CG6qE&feature=related")
- [How a CPU works](http://www.youtube.com/watch?v=xTrMmVKJ1KQ&feature=related "http://www.youtube.com/watch?v=xTrMmVKJ1KQ&feature=related")
