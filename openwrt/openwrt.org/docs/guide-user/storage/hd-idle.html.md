**Work in Progress!**  
This page is a continuous work in progress. You can edit this page to contribute information.

# hd-idle Configuration

The `/etc/config/hd-idle` configuration is provided by the *hd-idle* package.

## Sections

#### hd-idle

This is the default configuration for this section:

```
config 'hd-idle'
	option 'disk' 'sda'
	option 'enable_debug' '0'
	option 'enabled' '0'
	option 'idle_time_unit' 'minutes'
	option 'idle_time_interval' '10'
```

The `hd-idle` section contains these settings:

Name Type Required Default Description `disk` string `enable_debug` string `enabled` boolean no 1 `idle_time_unit` string no 'minutes' 'days', 'hours', 'minutes' or 'seconds' `idle_time_interval` integer

To configure multiple disks, include one section for each disk.
