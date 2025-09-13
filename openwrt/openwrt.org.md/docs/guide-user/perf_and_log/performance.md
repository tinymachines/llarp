# Performance HowTo

Everything, all the hardware components and the software has an effect on the performance of a system as a whole. And there is always a bottleneck, the component that restricts the performance the most. This can be anything: the used protocol (e.g. ftp &gt; nfs &gt; cifs), the used filesystem (e.g. without journaling &gt; bla journaling &gt; full journaling), the Kernel Version, the [cpu](/docs/techref/hardware/cpu "docs:techref:hardware:cpu"), the amount of RAM, the available amount of RAM, the hard disc connection (e.g. eSATA &gt; USB2 &gt; USB1.1 &gt; USB1.0) and so on and so forth.

So if you're talking about `performance`, you should comprehend what exactly you mean by that and what not! There are good adequate ways to measure and compare performance and there are completely useless ones. There are good and useful performance values (e.g. time to zip a file) and completely useless ones (e.g. BogoMIPS).

## Internal Links

- → [benchmark.openssl](/docs/guide-user/perf_and_log/benchmark.openssl "docs:guide-user:perf_and_log:benchmark.openssl")
- → [benchmark.usb](/docs/guide-user/perf_and_log/benchmark.usb "docs:guide-user:perf_and_log:benchmark.usb")
- → [cryptographic.hardware.accelerators](/docs/techref/hardware/cryptographic.hardware.accelerators "docs:techref:hardware:cryptographic.hardware.accelerators")

## External Links

- → [Digital signal processor](https://en.wikipedia.org/wiki/Digital%20signal%20processor "https://en.wikipedia.org/wiki/Digital signal processor") or [https://web.archive.org/web/20180130072800/http://wehavemorefun.de/fritzbox/DSP](https://web.archive.org/web/20180130072800/http://wehavemorefun.de/fritzbox/DSP "https://web.archive.org/web/20180130072800/http://wehavemorefun.de/fritzbox/DSP")
  
  - → [https://web.archive.org/web/20180330114651/http://www.wehavemorefun.de/fritzbox/Sar](https://web.archive.org/web/20180330114651/http://www.wehavemorefun.de/fritzbox/Sar "https://web.archive.org/web/20180330114651/http://www.wehavemorefun.de/fritzbox/Sar") can very well be accelerated by special purpose hardware ([ic](/docs/techref/hardware/ic "docs:techref:hardware:ic"))!
  - → [https://web.archive.org/web/20180316113107/http://www.wehavemorefun.de/fritzbox/QoS](https://web.archive.org/web/20180316113107/http://www.wehavemorefun.de/fritzbox/QoS "https://web.archive.org/web/20180316113107/http://www.wehavemorefun.de/fritzbox/QoS") can very well be accelerated by special purpose hardware ([ic](/docs/techref/hardware/ic "docs:techref:hardware:ic"))!
- → [https://web.archive.org/web/20180130070156/http://wehavemorefun.de/fritzbox/UR8](https://web.archive.org/web/20180130070156/http://wehavemorefun.de/fritzbox/UR8 "https://web.archive.org/web/20180130070156/http://wehavemorefun.de/fritzbox/UR8") The UR8-SoC contains a C55x VoIP-DSP additionally to the MIPS 4KEc CPU.
- [https://web.archive.org/web/20180130071217/http://wehavemorefun.de/fritzbox/DaVinci](https://web.archive.org/web/20180130071217/http://wehavemorefun.de/fritzbox/DaVinci "https://web.archive.org/web/20180130071217/http://wehavemorefun.de/fritzbox/DaVinci") Another [soc](/docs/techref/hardware/soc "docs:techref:hardware:soc") with hardware acceleration

<!--THE END-->

- → [Thrashing (computer science)](https://en.wikipedia.org/wiki/Thrashing%20%28computer%20science%29 "https://en.wikipedia.org/wiki/Thrashing (computer science)")

## Tests

A good program to measure file system performance is `bonnie++`.

## Results

Since this results are not device specific, but depend on the [soc](/docs/techref/hardware/soc "docs:techref:hardware:soc") or on the [cpu](/docs/techref/hardware/cpu "docs:techref:hardware:cpu") we collect such centrally to make it easier to compare the results. See [performance](/docs/techref/hardware/performance "docs:techref:hardware:performance")
