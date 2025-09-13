# Hotplug extras

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

## Introduction

- This instruction extends the functionality of [Hotplug](/docs/guide-user/base-system/hotplug "docs:guide-user:base-system:hotplug").
- Follow the [automated](/docs/guide-user/advanced/hotplug_extras#automated "docs:guide-user:advanced:hotplug_extras") section for quick setup.

## Features

- Run scripts at startup when the network is online.

## Implementation

- Use [Hotplug](/docs/guide-user/base-system/hotplug "docs:guide-user:base-system:hotplug") to detect connectivity change and trigger network dependent scripts.
- Process subsystem-specific scripts with [hotplug-call](https://github.com/openwrt/openwrt/blob/master/package/base-files/files/sbin/hotplug-call "https://github.com/openwrt/openwrt/blob/master/package/base-files/files/sbin/hotplug-call").
- Delay script invocation with [sleep](http://man.cx/sleep%281%29 "http://man.cx/sleep%281%29") to work around tunneled connections.
- Write and read non-interactive logs with [Syslog](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials") for troubleshooting.

## Instructions

```
# Configure hotplug
mkdir -p /etc/hotplug.d/iface
cat << "EOF" > /etc/hotplug.d/iface/90-online
if [ "${INTERFACE}" = "loopback" ]
then exit 0
fi
if [ "${ACTION}" != "ifup" ] \
&& [ "${ACTION}" != "ifupdate" ]
then exit 0
fi
if [ "${ACTION}" = "ifupdate" ] \
&& [ -z "${IFUPDATE_ADDRESSES}" ] \
&& [ -z "${IFUPDATE_DATA}" ]
then exit 0
fi
hotplug-call online
EOF
cat << "EOF" >> /etc/sysupgrade.conf
/etc/hotplug.d/iface/90-online
EOF
```

## Examples

```
# Example Hotplug script
cat << "EOF" > /etc/hotplug.d/online/00-logger
logger -t hotplug $(env)
EOF
 
# Trigger Hotplug
service network restart
 
# Check Hotplug log
logread -e hotplug
```

## Automated

```
wget -U "" -O hotplug-extras.sh "https://openwrt.org/_export/code/docs/guide-user/advanced/hotplug_extras?codeblock=0"
. ./hotplug-extras.sh
```
