# udpxy

[udpxy](https://web.archive.org/web/20220316191744/http://www.udpxy.com/ "https://web.archive.org/web/20220316191744/http://www.udpxy.com/") ('you-dee-pixie') is an IPTV stream relay: forwards multicast UDP streams to HTTP clients (subscribers).

The file `/etc/config/udpxy` provides the configuration for the *udpxy* package.

## Sections

There is only one unnamed section of type `udpxy` defined. Only one instance of this section is allowed.

### Options in "udpxy"

Below is the listing of defined options for the `udpxy` section.

Name Type Required Default Description `verbose` Boolean no `false` Enables verbose output `status` Boolean no `true` Enables client statistics `bind` IPv4 Address/Interface no 0.0.0.0 Address/Interface to listen on `port` Port number no `4022` Port to listen on `source` IPv4 Address/Interface no 0.0.0.0 Address/Interface of multicast source `max_clients` Number no `3` Max clients to serve `log_file` File no `/var/log/udpxy` Log output to file `buffer_size` Number no `4096` Buffer size for inbound multicast data `buffer_messages` Number no `1` Maximum messages to store in buffer `buffer_time` Number no `1` Maximum time (s) to hold data in buffer `nice_increment` Number no `0` Nice value increment `mcsub_renew` Number no `0` Renew multicast subscription periodicity
