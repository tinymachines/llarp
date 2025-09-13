# Managing packages

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

## Introduction

- There are multiple [packages](/packages/start "packages:start") available in the OpenWrt package repository.
- This how-to describes the method for managing OpenWrt packages.

## Goals

- Search, install and remove OpenWrt packages.

## Web interface instructions

Manage packages using web interface.

1. Navigate to **LuCI → System → Software**.
2. Click **Update lists** button to fetch a list of available packages.
3. Fill in **Filter** field and click **Find package** button to search for a specific package.
4. Switch to **Available packages** tab to show and install available packages.
5. Switch to **Installed packages** tab to show and remove installed packages.

Search and install `luci-app-*` packages if you want to configure services using LuCI.

## Command-line instructions

Manage packages with [Opkg](/docs/guide-user/additional-software/opkg "docs:guide-user:additional-software:opkg") using command-line interface.

Command Description `opkg update` Fetch a list of available packages from the OpenWrt package repository. `opkg list` Display a list of available packages and their descriptions. `opkg list | grep -e <search>` Filter the list by a search term in the package name or its description. `opkg install <packages>` Install a package. `opkg remove <packages>` Uninstall a previously installed package.
