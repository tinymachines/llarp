# Static IP

This page is a lite version of Static leases comparing with that in the usual LuCI interface (Network → DHCP and DNS → Static Leases).

Static leases are used to assign fixed IP addresses and symbolic hostnames to DHCP clients. They are also required for non-dynamic interface configurations where only hosts with a corresponding lease are served.

**Attention:** It is not available yet with LuCI interface.

This version keeps the essential configurations: Hostname, MAC-Address, and IPv4-Address.  
When you select a MAC-Address within the list, the IPv4-Address associated with the MAC-Address is shown behind.  
If you have added this static lease before, it is the hostname shown behind the MAC-Address/IPv4-Address.

Furthermore, the users don't have to enter a new window to create or modify a static lease, that means, they can manipulate on the showing page, which simplifies the use of the interface.

[![](/_media/media/static_ip.png)](/_detail/media/static_ip.png?id=docs%3Aguide-user%3Aluci%3Astatic_ip "media:static_ip.png")
