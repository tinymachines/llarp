# CoDel

CoDel - The Controlled-Delay Active Queue Management algorithm.

- [Source Code](https://elixir.bootlin.com/linux/latest/source/net/sched/sch_fq_codel.c "https://elixir.bootlin.com/linux/latest/source/net/sched/sch_fq_codel.c")
- [Buffer Bloat](https://www.bufferbloat.net/projects/codel/wiki "https://www.bufferbloat.net/projects/codel/wiki")

Explanations for the average person:

- [this video (YT, 41 minutes)](http://www.youtube.com/watch?v=y5KPryOHwk8 "http://www.youtube.com/watch?v=y5KPryOHwk8") starting at ~21:00 explains CoDel
- it also explains [Fair Queue CoDel](/docs/guide-user/network/traffic-shaping/sch_fq_codel "docs:guide-user:network:traffic-shaping:sch_fq_codel")
- but it does not explain [HFSC](/docs/guide-user/network/traffic-shaping/sch_hfsc "docs:guide-user:network:traffic-shaping:sch_hfsc")

<!--THE END-->

- measure the latency in the queue (from ingress to egress, via time stamping on entry and checking the timestamp on exit
- when latency exceeds tartget, think about dropping a packet
- after latency exceeds target, drop a packet at the HEAD of the queue (not the tail!)
- if that does not fix it, after a shorter interval (inverse sqrt), drop the net packet sooner, again at the HEAD
- keep decreasing the interval between drops until the latency in the queue drops below target
- we start with 100ms at the interval of the estimate and 5ms as the target (for 4Mbit/s and up); 10Gb/s needs a smaller target.
- below 4Mbit/s ... well, we don't know
