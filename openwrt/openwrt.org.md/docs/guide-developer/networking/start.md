# Networking

## Theory

### Networking... is packet based

Information (data) is broken into packets prior to being transported to its destination(s). [read more...](/docs/guide-developer/networking/theory "docs:guide-developer:networking:theory")

## Praxis

### Networking in the Linux kernel

Above we read merely about the theory of networking, about the basic ideas, about communication protocols and standards. [read more...](/docs/guide-developer/networking/praxis "docs:guide-developer:networking:praxis")

## Network interfaces

### Types of network interfaces

GNU/Linux universally distinguishes two types of network interfaces: [read more...](/docs/guide-developer/networking/network.interfaces "docs:guide-developer:networking:network.interfaces")

## Applications

### Routing

Routing is the process of selecting paths in a network along which to send network traffic. [read more...](/docs/guide-user/network/routing/start "docs:guide-user:network:routing:start")

### Netfilter

Well, let's consider what you already know, that data communication, that is, the exchange and transfer of information, or data, takes place in chunks and not as a continuous flow. [read more...](/docs/guide-user/firewall/netfilter_iptables/netfilter_openwrt "docs:guide-user:firewall:netfilter_iptables:netfilter_openwrt")

You find the sources for this functionality `/net/netfilter`

### Traffic control

Traffic control is the umbrella term for packet prioritizing, traffic shaping, bandwidth limiting, AQM (Active Queue Management), etc. [read more...](/docs/guide-user/network/traffic-shaping/packet.scheduler "docs:guide-user:network:traffic-shaping:packet.scheduler")

You find the sources for this functionality `/net/sched/`

- `/net/netlink`
- `/net/atm`
- `/net/wimax`
- `/net/phonet`
