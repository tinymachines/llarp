# Networking in the Linux Kernel

Above we read merely about the theory of networking, about the basic ideas, about communication protocols and standards. Now, let us see, how all of this is being handled by the Linux Kernel 2.6:

Everything related is found under `/net/`. But drivers, for the network devices, are of course found `/drivers/`.

***NOTE***:

1. The Linux kernel is only one component of the operating system
   
   1. it does require libraries itself (we at OpenWrt use the µCLibC, see →[links.software.libraries](/docs/guide-developer/links.software.libraries "docs:guide-developer:links.software.libraries")) [Section: 3 - C library functions](http://man.cat-v.org/unix_8th/3/ "http://man.cat-v.org/unix_8th/3/")
   2. it is very modular and there are many modules
   3. it does require applications to provide features to end users (these run in userspace)

The main interface between the kernel and userspace is the set of `system calls`. There are about ![FIXME](/lib/images/smileys/fixme.svg) `system calls`. Network related `system calls` include: writes to socket, ...

## Network Data Flow through the Linux Kernel

- [Kernel Flow](http://www.linuxfoundation.org/collaborate/workgroups/networking/kernel_flow "http://www.linuxfoundation.org/collaborate/workgroups/networking/kernel_flow")

[![](/lib/exe/fetch.php?tok=c7421e&media=http%3A%2F%2Fweb.archive.org%2Fweb%2F20170905131225if_%2Fhttps%3A%2F%2Fwiki.linuxfoundation.org%2Fimages%2F1%2F1c%2FNetwork_data_flow_through_kernel.png)](/lib/exe/fetch.php?tok=c7421e&media=http%3A%2F%2Fweb.archive.org%2Fweb%2F20170905131225if_%2Fhttps%3A%2F%2Fwiki.linuxfoundation.org%2Fimages%2F1%2F1c%2FNetwork_data_flow_through_kernel.png "http://web.archive.org/web/20170905131225if_/https://wiki.linuxfoundation.org/images/1/1c/Network_data_flow_through_kernel.png") [Internet archive - Sep. 5th, 2017](http://web.archive.org/web/20170905131225/https://wiki.linuxfoundation.org/images/1/1c/Network_data_flow_through_kernel.png "http://web.archive.org/web/20170905131225/https://wiki.linuxfoundation.org/images/1/1c/Network_data_flow_through_kernel.png")

- [Linux Network Stack Walkthrough (Linux Kernel 2.4.20)](http://www.jsevy.com/network/Linux_network_stack_walkthrough.html "http://www.jsevy.com/network/Linux_network_stack_walkthrough.html")
- [google.com: "Network Data Flow through the Linux Kernel"](http://www.google.com/search?q=Network%20Data%20Flow%20through%20the%20Linux%20Kernel&btnG=Search&hl=en&gbv=1&sei=Bv1dT4XfA_Da4QSM5ZG6Dw "http://www.google.com/search?q=Network+Data+Flow+through+the+Linux+Kernel&btnG=Search&hl=en&gbv=1&sei=Bv1dT4XfA_Da4QSM5ZG6Dw")

### Packet Handling

#### TX Transmission

1. Queue No.1: The application process does a `write()` on a *socket* and all the data is copied from the process space into the *send socket buffer*
2. Queue No.2: The data goes through the *TCP/IP stack* and the packets are put ([Evaluation strategy#Call\_by\_reference](https://en.wikipedia.org/wiki/Evaluation%20strategy#Call_by_reference "https://en.wikipedia.org/wiki/Evaluation strategy#Call_by_reference")) into the NIC's *egress buffer* (here works the packet scheduler)
3. Queue No.3: After a packet gets dequeued, the transmission procedure of the driver is called, and it is copied into the *tx\_ring*, a ring buffer the driver shares with the NIC

#### RX Reception

1. Queue No.1: The hardware (NIC) puts all incoming network packets into the *rx\_ring*, a ring buffer the driver shares with the NIC
2. Queue No.2: The *IRQ handler* of the driver takes the packet from the *rx\_ring*, puts it (by ([Evaluation strategy#Call\_by\_reference](https://en.wikipedia.org/wiki/Evaluation%20strategy#Call_by_reference "https://en.wikipedia.org/wiki/Evaluation strategy#Call_by_reference"))) in the *ingress buffer* (aka *backlog queue*) and schedules a SoftIRQ (in kernels up to 2.4, every incoming packet triggered an IRQ, since Kernels 2.6 and the introduction of [NAPI](https://en.wikipedia.org/wiki/New_API "https://en.wikipedia.org/wiki/New_API") this is solved by polling instead: [https://lwn.net/Articles/30107/](https://lwn.net/Articles/30107/ "https://lwn.net/Articles/30107/"))
3. Queue No.3: is the the *receive socket buffer*

#### Typical queue lengths

- The *socket buffers* can be set by the application (`set_sockopt()`)
  
  - `cat /proc/sys/net/core/rmem_default` or `cat /proc/sys/net/core/wmem_default`
- The default queuing discipline is a FIFO queue. Default length is 1000 packets (ether\_setup(): dev→queue\_len, net/ethernet/eth.c)
- The *tx\_ring* and *rx\_ring* are driver dependent (e.g. the e1000 driver set these lengths to 80 packets)
- The *backlog queue* is 1,000 packets in size (`/proc/sys/net/core/netdev_max_backlog`). Once it is full, it waits for being totally empty to allow again an enqueue() (netif\_rx(), net/core/dev.c).

##### /proc

`/proc` is the POSIX complient mount point for the *Virtual Filesystem* for the processes.

- `/proc/cpuinfo`: processor information
- `/proc/meminfo`: memory status
- `/proc/version`: kernel version and build information
- `/proc/cmdline`: kernel command line
- `/proc/<pid>/environ`: calling environment
- `/proc/<pid>/cmdline`: process command line

See [Procfs](https://en.wikipedia.org/wiki/Procfs "https://en.wikipedia.org/wiki/Procfs") or [http://www.comptechdoc.org/os/linux/howlinuxworks/linux\_hlproc.html](http://www.comptechdoc.org/os/linux/howlinuxworks/linux_hlproc.html "http://www.comptechdoc.org/os/linux/howlinuxworks/linux_hlproc.html") or [proc.txt](http://www.mjmwired.net/kernel/Documentation/filesystems/proc.txt "http://www.mjmwired.net/kernel/Documentation/filesystems/proc.txt")

See → [http://gettys.wordpress.com/2010/11/29/home-router-puzzle-piece-one-fun-with-your-switch/](http://gettys.wordpress.com/2010/11/29/home-router-puzzle-piece-one-fun-with-your-switch/ "http://gettys.wordpress.com/2010/11/29/home-router-puzzle-piece-one-fun-with-your-switch/") for some “fun” with all the queues.

##### Transmitting

So you can install hardware capable of Ethernet (usually a network card or more precisely an Ethernet card) on two *hosts*, connect them with a standardized cable, like a [Category 5 cable](https://en.wikipedia.org/wiki/Category%205%20cable "https://en.wikipedia.org/wiki/Category 5 cable") and communicate with one another over Ethernet as far as your software supports Ethernet ![;-)](/lib/images/smileys/wink.svg) Sooner or later the sausage will get to the Ethernet thingy of the network stack, this will prepare the data conforming to the Ethernet standard, then will deliver the frames to the network card drivers and this will make the hardware, the network card, transmit the data.

##### Receiving

The NIC on the other side will receive the signal, relay it to the *Ethernet thingy* of the *network stack*, this will create one huge data out of the Ethernet frames and relay it to the software.

When a packet is enqueued on an interface with `dev queue xmit` (in `net/core/dev.c`), the `enqueue` operation of the packet scheduler is triggered and `qdisc wakeup` is being called (in `net/pkt_sched.h`) to send the packet on that device.

A transmit queue is associated with each device. When a network packet is ready for transmission, the “networking code” will call the driver's `hard_start_xmit()`-function to let it know, a packet is waiting. The driver will then put that packet into the `transmit queue` of the hardware.

You find the sources for the whole *TCP/IP protocol suite* implementation
