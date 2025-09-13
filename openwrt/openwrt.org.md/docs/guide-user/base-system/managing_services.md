# Managing services

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

## Introduction

- There are multiple [services](/docs/guide-user/services/start "docs:guide-user:services:start") running on OpenWrt to perform different tasks.
- This how-to describes the method for managing OpenWrt services.

## Goals

- Start, stop, restart, enable and disable system services.
- Check if a specific service is enabled and running.

## Web interface instructions

Manage services using web interface.

1. Navigate to **LuCI → System → Startup**.
2. See the list of all the available services and use buttons to execute actions.

## Command-line instructions

Manage services using command-line interface. Use the “equivalent” column inside [scripts](/docs/guide-developer/write-shell-script "docs:guide-developer:write-shell-script"), [hotplug](/docs/guide-user/base-system/hotplug "docs:guide-user:base-system:hotplug") or [cron](/docs/guide-user/base-system/cron "docs:guide-user:base-system:cron"). Check [syslog](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials") for troubleshooting.

Command Equivalent Description `service` `ls /etc/init.d` Print a list of available services. `service <service>` `/etc/init.d/<service>` Print a list of available actions for a service. `service <service> <action>` `/etc/init.d/<service> <action>` Execute that action on a specific service. `service <service> <action> <instance>` `/etc/init.d/<service> <action> <instance>` Execute that action on a specific service instance, e.g. OpenVPN connection.

Common actions supported by most services.

Action Description `start` Start the service. `stop` Stop the service. `restart` Restart the service. `reload` Reload configuration files or restart if that fails. `enable` Enable service autostart. `disable` Disable service autostart. `enabled` Check if the service is enabled. `running` Check if the service is running. `status` Service status. `trace` Start with syscall trace. `info` Dump procd service info.
