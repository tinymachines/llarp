# uBus IPC/RPC System

## uBus - IPC/RPC

uBus is the interconnect system used by most services running on a *OpenWrt* setup. Services can connect to the bus and provide methods that can be called by other services or clients.

See [uBus Technical Reference](/docs/techref/ubus "docs:techref:ubus")

### Reference documentation for ubus

**Path only contains the first context. E.g. network for network.interface.wan**

path Description Package [dhcp](/docs/guide-developer/ubus/dhcp "docs:guide-developer:ubus:dhcp") dhcp server odhcpd [file](/docs/guide-developer/ubus/file "docs:guide-developer:ubus:file") file rpcd [hostapd](/docs/guide-developer/ubus/hostapd "docs:guide-developer:ubus:hostapd") acesspoints wpad/hostapd [iwinfo](/docs/guide-developer/ubus/iwinfo "docs:guide-developer:ubus:iwinfo") wireless informations rpcd iwinfo [log](/docs/guide-developer/ubus/log "docs:guide-developer:ubus:log") logging procd [mdns](/docs/guide-developer/ubus/mdns "docs:guide-developer:ubus:mdns") mdns avahi replacement mdnsd [network](/docs/guide-developer/ubus/network "docs:guide-developer:ubus:network") network netifd [service](/docs/guide-developer/ubus/service "docs:guide-developer:ubus:service") init/service procd [session](/docs/guide-developer/ubus/session "docs:guide-developer:ubus:session") Session management rpcd [system](/docs/guide-developer/ubus/system "docs:guide-developer:ubus:system") system misc procd [uci](/docs/guide-developer/ubus/uci "docs:guide-developer:ubus:uci") Unified Configuration Interface rpcd
