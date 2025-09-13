# Random generator

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

## Introduction

- This how-to describes the method for optimizing [RNG](https://en.wikipedia.org/wiki/Random_number_generation "https://en.wikipedia.org/wiki/Random_number_generation") on OpenWrt.
- It may help to minimize system startup time on low performance devices.

## Goals

- Minimize startup time for cryptography-dependent services.
  
  - Avoid potential deadlock states and race conditions.

## Command-line instructions

Provide fast RNG with rng-tools.

```
# Install packages
opkg update
opkg install rng-tools
 
# Configure RNG
uci set system.@rngd[0].enabled="1"
uci commit system
service rngd restart
```

## Testing

Test the [entropy](https://en.wikipedia.org/wiki/Entropy_%28computing%29#Practical_implications "https://en.wikipedia.org/wiki/Entropy_(computing)#Practical_implications") pool size.

```
sysctl kernel.random.entropy_avail
```

Use [rngtest](http://man.cx/rngtest%281%29 "http://man.cx/rngtest%281%29") to check the randomness of data.

```
RNG_DEV="$(uci get system.@rngd[0].device)"
rngtest -c 1000 < ${RNG_DEV}
```

## Troubleshooting

Collect and analyze the following information.

```
# Restart services
service log restart; service rngd restart
 
# Log and status
logread -e rngd; pgrep -f -a rngd
 
# Persistent configuration
uci show system
```

## Extras

### Software RNG

Use software RNG by default.

```
# Use software RNG
uci set system.@rngd[0].device="/dev/urandom"
uci commit system
service rngd restart
```

### Hardware RNG

Use hardware RNG if available.

```
# Use hardware RNG
uci set system.@rngd[0].device="/dev/hwrng"
uci commit system
service urngd disable && service urngd stop
service rngd restart
```
