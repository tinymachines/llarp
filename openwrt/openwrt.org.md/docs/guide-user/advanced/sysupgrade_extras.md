# Sysupgrade extras

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

## Introduction

- This instruction extends the functionality of [Sysupgrade](/docs/techref/sysupgrade "docs:techref:sysupgrade") on [x86](/docs/guide-user/installation/openwrt_x86 "docs:guide-user:installation:openwrt_x86") target.
- Follow the [automated](/docs/guide-user/advanced/sysupgrade_extras#automated "docs:guide-user:advanced:sysupgrade_extras") section for quick setup.

## Features

- Check the latest firmware release available.
- Download the firmware image and verify its checksum.
- Allow to force/skip upgrade matching the current release.
- Save/restore the state of enabled/disabled services.

## Options

Option Description `-A` Download and upgrade firmware if a newer stable release is available. `-U` Download and upgrade firmware for the latest stable release. `-S` Save the current state of enabled/disabled services to UCI. `-R` Restore the state of enabled/disabled services.

## Instructions

```
# Configure profile
mkdir -p /etc/profile.d
cat << "EOF" > /etc/profile.d/sysupgrade.sh
sysupgrade() {
local SYSUP_CMD="${1}"
case "${SYSUP_CMD}" in
(-A|-U) sysupgrade_proc "${@}" ;;
(-S) service_save ;;
(-R) service_restore ;;
(*) command sysupgrade "${@}" ;;
esac
}
 
sysupgrade_proc() {
. /etc/os-release
local SYSUP_VER="$(sysupgrade_ver)"
local SYSUP_URL="$(sysupgrade_url)"
local SYSUP_REV="$(sysupgrade_rev)"
if [ "${SYSUP_REV}" != "${BUILD_ID}" ] \
|| [ "${SYSUP_CMD}" = "-U" ]
then shift
local SYSUP_DEV="$(sysupgrade_dev)"
local SYSUP_PROF="$(sysupgrade_prof)"
local SYSUP_FS="$(sysupgrade_fs)"
local SYSUP_TYPE="$(sysupgrade_type)"
local SYSUP_EFI="$(sysupgrade_efi)"
local SYSUP_IMG="$(sysupgrade_img)"
sysupgrade "${@}" "${SYSUP_URL}/${SYSUP_IMG}"
fi
}
 
sysupgrade_ver() {
case "${VERSION_ID}" in
(snapshot) echo "../snapshots" ;;
(*) wget -O - \
"https://api.github.com/repos/openwrt/openwrt/tags" \
| jsonfilter -e "@[*]['name']" \
| sed -e "/-rc[0-9]*$/d;s/^v//;q" ;;
esac
}
 
sysupgrade_url() {
echo "https://downloads.openwrt.org/\
releases/${SYSUP_VER}/targets/${OPENWRT_BOARD}"
}
 
sysupgrade_rev() {
wget -O - "${SYSUP_URL}/version.buildinfo"
}
 
sysupgrade_dev() {
ubus call system board \
| jsonfilter -e "@['board_name']"
}
 
sysupgrade_prof() {
case "${OPENWRT_BOARD}" in
(x86/*) echo "generic" ;;
(*) echo "${SYSUP_DEV//,/_}" ;;
esac
}
 
sysupgrade_fs() {
ubus call system board \
| jsonfilter -e "@['rootfs_type']"
}
 
sysupgrade_type() {
case "${OPENWRT_BOARD}" in
(x86/*) echo "combined" ;;
(*) echo "sysupgrade" ;;
esac
}
 
sysupgrade_efi() {
if [ -d /sys/firmware/efi ]
then echo "-efi"
fi
}
 
sysupgrade_img() {
wget -O - "${SYSUP_URL}/profiles.json" \
| jsonfilter -e "@['profiles']['${SYSUP_PROF}']
['images'][@['type']='${SYSUP_TYPE}${SYSUP_EFI}'
&&@['filesystem']='${SYSUP_FS}']['name']"
}
 
service_save() {
local SVC_NAME="$(ls /etc/init.d)"
local SVC_AUTO
for SVC_NAME in ${SVC_NAME}
do if command service "${SVC_NAME}" enabled
then SVC_AUTO="enable"
else SVC_AUTO="disable"
fi
uci -q batch << EOI
set system.service='service'
del_list system.service.enable='${SVC_NAME}'
del_list system.service.disable='${SVC_NAME}'
add_list system.service.'${SVC_AUTO}'='${SVC_NAME}'
EOI
done
uci commit system
}
 
service_restore() {
local SVC_NAME
local SVC_AUTO="enable disable"
for SVC_AUTO in ${SVC_AUTO}
do SVC_NAME="$(uci -q get system.service."${SVC_AUTO}")"
for SVC_NAME in ${SVC_NAME}
do command service "${SVC_NAME}" "${SVC_AUTO}"
done
done
}
EOF
. /etc/profile.d/sysupgrade.sh
 
# Configure startup scripts
cat << "EOF" > /etc/uci-defaults/60-service-restore
if [ ! -e /etc/service-restore ]
then . /etc/profile.d/sysupgrade.sh
sysupgrade -R
touch /etc/service-restore
fi
exit 1
EOF
cat << "EOF" >> /etc/sysupgrade.conf
/etc/uci-defaults/60-service-restore
EOF
```

## Examples

```
# Automated interactive Sysupgrade
sysupgrade -A -i
 
# Forced interactive Sysupgrade
sysupgrade -U -i
```

## Automated

```
wget -U "" -O sysupgrade-extras.sh "https://openwrt.org/_export/code/docs/guide-user/advanced/sysupgrade_extras?codeblock=0"
. ./sysupgrade-extras.sh
```
