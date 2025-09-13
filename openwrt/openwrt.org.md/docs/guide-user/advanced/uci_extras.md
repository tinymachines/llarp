# UCI extras

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

## Introduction

- This instruction extends the functionality of [UCI](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci").
- Follow the [automated](/docs/guide-user/advanced/uci_extras#automated "docs:guide-user:advanced:uci_extras") section for quick setup.

## Features

- Validate and compare UCI configurations.

## Implementation

- Wrap UCI calls to provide a seamless invocation method.
- Rely on [UCI](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") to validate configurations.
- Rely on [diff](http://man.cx/diff%281%29 "http://man.cx/diff%281%29") to identify configuration changes.

## Commands

Sub-command Description `validate [<confs>]` Validate UCI configurations. `diff <oldconf> [<newconf>]` Compare UCI configurations, requires [diffutils](/packages/pkgdata/diffutils "packages:pkgdata:diffutils").

## Instructions

```
# Configure profile
mkdir -p /etc/profile.d
cat << "EOF" > /etc/profile.d/uci.sh
uci() {
local UCI_CMD="${1}"
case "${UCI_CMD}" in
(validate|diff) uci_"${@}" ;;
(*) command uci "${@}" ;;
esac
}
 
uci_validate() {
local UCI_CONF="${@:-/etc/config/*}"
for UCI_CONF in ${UCI_CONF}
do if ! uci show "${UCI_CONF}" > /dev/null
then echo "${UCI_CONF}"
fi
done
}
 
uci_diff() {
local UCI_OCONF="${1:?}"
local UCI_NCONF="${2:-${1}-opkg}"
local UCI_OTEMP="$(mktemp -t uci.XXXXXX)"
local UCI_NTEMP="$(mktemp -t uci.XXXXXX)"
uci export "${UCI_OCONF}" > "${UCI_OTEMP}"
uci export "${UCI_NCONF}" > "${UCI_NTEMP}"
diff -a -b -d -y "${UCI_OTEMP}" "${UCI_NTEMP}"
rm -f "${UCI_OTEMP}" "${UCI_NTEMP}"
}
EOF
. /etc/profile.d/uci.sh
```

## Examples

```
# Install packages
opkg update
opkg install diffutils
 
# Validate UCI configurations
uci validate
 
# Compare UCI configurations
opkg newconf
uci diff dhcp
```

## Automated

```
wget -U "" -O uci-extras.sh "https://openwrt.org/_export/code/docs/guide-user/advanced/uci_extras?codeblock=0"
. ./uci-extras.sh
```
