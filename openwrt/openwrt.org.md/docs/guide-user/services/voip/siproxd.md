# Siproxd on OpenWrt intro

[Siproxd](http://siproxd.sourceforge.net/ "http://siproxd.sourceforge.net/") is a proxy/masquerading daemon for the SIP protocol. It handles registrations of SIP clients on a private IP network and performs rewriting of the SIP message bodies to make SIP connections work via an masquerading firewall (NAT). It allows SIP software clients (like kphone, linphone) or SIP hardware clients (Voice over IP phones which are SIP-compatible) to work behind an IP masquerading firewall or NAT router.

## Siproxd configuration

In `/etc/config/siproxd` you can configure Siproxd. You can add to the default configuration to setup the plugins that you'd like to use. For example to load and configure the regex plugin something along the following lines would be appropriate:

```
# Load regex plugin and define some replacement rules to ensure that
# local and domestic numbers without area/country code are dialled
# properly:
list load_plugin 'plugin_regex.so'

# International calls, prefix 00 converted to +:
# 00 385 1 123456 -> +385 1 123456
list plugin_regex_desc   = 'Intl'
list plugin_regex_pattern = '^(sips?:)00'
list plugin_regex_replace = '\1+'

# Domestic calls to a different area code, drop the 0 and prefix with
# country code added:
# 01 123456 -> +385 1 123456
list plugin_regex_desc    = 'Domestic'
list plugin_regex_pattern = '^(sips?:)0'
list plugin_regex_replace = '\1+385'

# Local calls without an area code - prefix with country code + local
# area code:
# 123456 -> +385 1 123456
list plugin_regex_desc  = 'Local'
list plugin_regex_pattern = '^(sips?:)'
list plugin_regex_replace = '\1+3851'
```
