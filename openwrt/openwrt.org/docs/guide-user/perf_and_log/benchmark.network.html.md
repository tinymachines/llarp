# Networking Benchmarks

## Throughput

- Diverse websites already do test the throughput of diverse hardware and switches and operating systems, e.g. [https://www.smallnetbuilder.com/](https://www.smallnetbuilder.com/ "https://www.smallnetbuilder.com/")

(However such guides only apply for hardware running the factory firmware, once openwrt or any third-party firmware is installed, the network capabilities will switch to the network stack in openwrt or any third-party firmware used)

## Latency

- Latency (i.e. the time delay between two interactions) is often not measured at all, or they neglect to measure latency under load. Exactly this has been addressed by the project [https://www.bufferbloat.net/](https://www.bufferbloat.net/ "https://www.bufferbloat.net/")
  
  - The project bufferbloat utilizes OpenWrt for measurements and experiments: [https://www.bufferbloat.net/projects/cerowrt](https://www.bufferbloat.net/projects/cerowrt "https://www.bufferbloat.net/projects/cerowrt")

## Tools

- [Iperf](https://en.wikipedia.org/wiki/Iperf "https://en.wikipedia.org/wiki/Iperf"), [JPerf (Graphical Iperf)](http://code.google.com/p/xjperf/%E2%80%8E "http://code.google.com/p/xjperf/‎"), [Netperf](https://en.wikipedia.org/wiki/Netperf "https://en.wikipedia.org/wiki/Netperf")
- [Netem (Network Emulator)](/docs/guide-user/network/traffic-shaping/sch_netem "docs:guide-user:network:traffic-shaping:sch_netem")
- see [wireless.overview](/docs/guide-user/network/wifi/wireless.overview "docs:guide-user:network:wifi:wireless.overview") for diverse tools available in the OpenWrt package respos; (security is a again different field then benchmarking throughput and latency if you are bored)
- puppet, etc etc
- `top`
  
  - In I noticed *“sirq”* consuming 99% of the CPU (e.g. [Ticket 7356](https://dev.openwrt.org/ticket/7356 "https://dev.openwrt.org/ticket/7356"))
  - *ksoftirqd* is the kernel thread responsible for servicing software IRQs which is the context in which Ethernet frames are processe for the RX path, what this means here is:
  
  <!--THE END-->
  
  1. you are CPU bound; the hardware might be moving packet faster but software cannot keep up
  2. the NAPI implementation (if existing in the driver) might need some tweaking, in particular I see no likely(\_\_napi\_schedule\_prep) for instance
