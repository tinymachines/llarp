# Printing over SSH

## Introduction

This page describes a way to make CUPS print, over SSH, to a USB printer attached to an OpenWrt device.

No extra software is required, other than some shell scripts and the standard USB driver; and no storage is required on the OpenWrt device.

## CUPS setup

Install the following script on a system running CUPS, using the instructions in its comment block. `DeviceURI` in `printers.conf` should point to your OpenWrt system.

```
#!/bin/sh
# copyright waived as per CC0:
# https://creativecommons.org/publicdomain/zero/1.0/legalcode-plain
 
# This CUPS backend will forward each job to the standard input of a program on
# a remote system, via ssh.
#
# Install it as /usr/lib/cups/backend/ssh; either use "chmod u+x,go-wx" to make
# it run as root, or "chmod ugo+x,go-w" to run as the CUPS user (generally lp).
# Create a passwordless ssh key as that user, e.g.:
#   # mkdir -p -m 711 ~lp
#   # chown lp: ~lp
#   # su -s /bin/sh lp -c "ssh-keygen -N '' -t rsa -b 2048"
# And add the key to an ssh authorized_keys file on the remote system:
#   command="./recv-lpjob",no-pty,no-port-forwarding ssh-rsa AAAAB2...19Q== lp@cups.example.net
#
# To enable it, add this to /etc/cups/printers.conf while cups is not running:
#   <Printer ssh_example>
#   UUID urn:uuid:e2f74bc0-2d45-4afd-915e-a16df20c49a1
#   DeviceURI ssh://root@openwrt.example.net:22/dev/usb/lp0
#   State Idle
#   Type 8388612
#   Accepting Yes
#   Shared No
#   ErrorPolicy retry-current-job
#   </Printer>
# Be sure to connect once manually so the host key fingerprint is known:
#   # su -s /bin/bash lp
#   $ ssh -p 22 root@openwrt.example.net < /dev/null
# Install a PPD file as /etc/cups/ppd/ssh_example.ppd if necessary.
#
# To debug, set "LogLevel warn" in /etc/cups/cupsd.conf; stderr will be saved
# in /var/log/cups/error_log.
 
set -o errexit
set -o nounset
 
remote_cmd=./recv-lpjob
 
CUPS_BACKEND_OK=0
CUPS_BACKEND_FAILED=1
CUPS_BACKEND_AUTH_REQUIRED=2  # cups will rewrite printers.conf with auth. data
CUPS_BACKEND_HOLD=3
CUPS_BACKEND_STOP=4
CUPS_BACKEND_CANCEL=5  # could be bad options
CUPS_BACKEND_RETRY=6
CUPS_BACKEND_RETRY_CURRENT=7
 
debugf () {
	dbg="[backend/ssh] $1"
	shift
	printf "$dbg" "$@" >&2
}
 
if [ "$#" -eq 0 ]
then
	debugf 'in discovery mode\n'
 
	# Output zero or more lines in any of these formats:
	#   device-class scheme "Unknown" "device-info"
	#   device-class device-uri "device-make-and-model" "device-info"
	#   device-class device-uri "device-make-and-model" "device-info" "device-id"
	#   device-class device-uri "device-make-and-model" "device-info" "device-id" "device-location"
	# Quoted strings use '\' as escape.
 
	printf 'direct ssh "Unknown" "%s"\n' "prints via ssh"
	exit "$CUPS_BACKEND_OK"
elif [ "$#" -lt 5 ]
then
	printf 'Usage: %s job-id user title copies options [file ...]\n' "$0" >&2
	exit "$CUPS_BACKEND_FAILED"
fi
 
ssh_user=''
ssh_host=''
ssh_port=''
ssh_path=''
 
case "$DEVICE_URI" in
ssh://*)  # https://tools.ietf.org/html/draft-ietf-secsh-scp-sftp-ssh-uri-04
	x=${DEVICE_URI#ssh://}
 
	# strip off any path; the other end can try to handle it
	y=${x%%/*}
	ssh_path=${x#"$y"}
	x=$y
 
	case "$x" in *%*)
		debugf 'Unescaping not implemented for URI "%s"\n' \
				"$DEVICE_URI"
		exit "$CUPS_BACKEND_CANCEL"
	esac
 
	case "$x" in *@*)
		ssh_user=${x%%@*}
		x=${x#*@}
		case "$ssh_user" in '' | *:* | *\;* | -*)
			debugf 'Bad/unsupported userinfo "%s" in URI "%s"\n' \
					"$ssh_user" "$DEVICE_URI"
			exit "$CUPS_BACKEND_CANCEL"
		esac
	esac
 
	case "$x" in
	'' | [-:]* | *:*:*)
		debugf 'Bad address "%s" in URI "%s"\n' \
				"$x" "$DEVICE_URI"
		exit "$CUPS_BACKEND_CANCEL"
		;;
	*:*)
		ssh_port=${x#*:}
		x=${x%%:*}
	esac
 
	ssh_host=$x
	;;
*)
	debugf 'Bad scheme in URI "%s"\n' "$DEVICE_URI"
	exit "$CUPS_BACKEND_CANCEL"
esac
 
debugf 'ssh-user: %s\n' "$ssh_user"
debugf 'ssh-host: %s\n' "$ssh_host"
debugf 'ssh-port: %s\n' "$ssh_port"
debugf 'ssh-path: %s\n' "$ssh_path"
 
job_id=$1
user=$2
title=$3
copies=$4
options=$5
shift 5
# remaining arguments are filenames
 
debugf 'job-id: %s\n' "$job_id"
debugf 'user: %s\n' "$user"
debugf 'title: %s\n' "$title"
debugf 'copies: %s\n' "$copies"
debugf 'options: %s\n' "$options"
[ "$#" -gt 0 ] || debugf 'file not set\n'
for file
do
	debugf 'file: %s\n' "$file"
done
 
do_printing () {
	printf 'set path=%s\n' "$ssh_path"
	printf 'set job_id=%s\n' "$job_id"
	printf 'set user=%s\n' "$user"
	printf 'set title=%s\n' "$title"
	printf 'set options=%s\n' "$options"
	if [ "$#" -eq 0 ]
	then
		debugf 'printing stdin\n'
		printf 'print\n'
		cat
		if [ "$copies" -gt 1 ]
		then
			debugf 'cannot print multiple copies from stdin\n'
		fi
	else
		while [ "$copies" -gt 0 ]
		do
			copies=$((copies - 1))
			n=$#
			while [ "$n" -gt 0 ]
			do
				n=$((n -= 1))
				file=$1
				shift
				set -- "$@" "$file"
 
				debugf 'printing file %s\n' "$file"
				printf 'print '; wc -c "$file"
				cat <"$file"
			done
		done
	fi
	debugf 'done printing\n'
}
do_ssh () {
	set -- ssh -o BatchMode=yes -o RequestTTY=no
	[ -z "$ssh_port" ] || set -- "$@" -p "$ssh_port"
	# use ~/.ssh/config (man ssh_config) to set global or per-host options
 
	if [ -n "$ssh_user" ]
	then
		set -- "$@" "$ssh_user@$ssh_host"
	else
		set -- "$@" "$ssh_host"
	fi
 
	set -- "$@" "$remote_cmd"
	debugf 'will run %s\n' "$*"
 
	"$@" >/dev/null && set -- 0 || set -- "$?"
	debugf 'ssh exited with status %d\n' "$1"
	printf '%d\n' "$1"
}
 
rc=$(do_printing "$@" | do_ssh)
debugf 'exit status "%s"\n' "$rc"
 
case "$rc" in
'' | *[!0-9]*)
	exit "$CUPS_BACKEND_FAILED"
	;;
127 | 255)  # ssh error
	exit "$CUPS_BACKEND_RETRY_CURRENT"
	;;
esac
exit "$rc"
```

## OpenWrt setup

Save the following script as `/root/recv-lpjob` on your OpenWrt device:

```
#!/bin/sh
# copyright waived as per CC0:
# https://creativecommons.org/publicdomain/zero/1.0/legalcode-plain
 
set -o errexit
set -o nounset
 
CUPS_BACKEND_OK=0
CUPS_BACKEND_FAILED=1
CUPS_BACKEND_AUTH_REQUIRED=2  # cups will rewrite printers.conf with auth. data
CUPS_BACKEND_HOLD=3
CUPS_BACKEND_STOP=4
CUPS_BACKEND_CANCEL=5  # could be bad options
CUPS_BACKEND_RETRY=6
CUPS_BACKEND_RETRY_CURRENT=7
 
# state variables
printer=''
locked=''
exec 3>&-
 
# var_* variables controlled by sender
var_path=''
var_job_id=''
var_user=''
var_title=''
var_options=''
 
debugf () {
	dbg="[recv-lpjob] $1"
	shift
	printf "$dbg" "$@" >&2
}
 
set_lock () {
	debugf 'setting locked=%d for "%s"\n' "$2" "$1"
	[ "$1" != /dev/null ] || return 0
 
	if [ -x /bin/lock ]
	then
		debugf 'using /bin/lock\n'
		if [ "$2" -eq 0 ]
		then
			/bin/lock -u "$1.lock" || return
		else
			/bin/lock "$1.lock" || return
		fi
	else
		debugf 'no locks available\n'
		# it's OK to continue without locking;
		# Linux will fail a second open() with EBUSY
	fi
}
 
lock_and_open_printer () {
	if [ -n "$printer" ]
	then
		close_printer
		# unlock if we're switching printers
		[ "$1" = "$locked" ] || unlock_printer
	fi
 
	if [ -z "$locked" ]
	then
		if ! set_lock "$1" 1
		then
			debugf 'failed to lock "%s"\n' "$1"
			return 1
		fi
		if ! [ -c "$1" ]
		then
			debugf 'printer "%s" not found\n' "$1"
			return 1
		fi
 
		locked=$1
	fi
 
	if exec 3>"$1"
	then
		debugf 'opened printer "%s"\n' "$1"
	else
		debugf 'failed to open printer "%s"\n' "$1"
	fi
	printer=$1
}
 
cat_to_printer () {
	cat >&3
}
 
close_printer () {
	if [ -n "$printer" ]
	then
		debugf 'closing printer "%s"\n' "$printer"
		exec 3>&-
		printer=''
	fi
}
 
unlock_printer () {
	if [ -n "$locked" ]
	then
		set_lock "$locked" 0
		locked=''
	fi
}
 
handle_set () {
	debugf 'got %s\n' "$1"
	case "$1" in
	*=*)
		key=${1%%=*}
		val=${1#"$key"}
		val=${val#=}
		;;
	*)
		debugf 'bad set command "%s"\n' "$line"
		exit "$CUPS_BACKEND_CANCEL"
	esac
 
	case "$key" in '' | [0-9]* | *[!a-zA-Z_0-9]*)
		debugf 'bad key "%s"\n' "$key"
		exit "$CUPS_BACKEND_CANCEL"
	esac
	eval "var_$key=\$val"
}
 
write_exitcode () {
	"$@" >/dev/null && set -- 0 || set -- "$?"
	printf '%d\n' "$1"
}
 
handle_print () {
	case "$var_path" in
	'' | /)
		set -- /dev/usb/lp*
		if ! [ -e "$1" ]
		then
			debugf 'no default printer found\n'
			exit "$CUPS_BACKEND_RETRY_CURRENT"
		fi
		var_path=$1
		;;
	/dev/usb/lp[0-9]) ;;
	/dev/null) ;;
	*)
		debugf 'printer "%s" disallowed\n' "$var_path"
		exit "$CUPS_BACKEND_CANCEL"
	esac
 
	lock_and_open_printer "$var_path" || return
 
	arg=${1%% *}
	case "$arg" in
	'')
		debugf 'printing to eof\n'
		cat_to_printer
		;;
	0?* | *[!0-9]*)
		debugf 'bad print size "%s"\n' "$arg"
		exit "$CUPS_BACKEND_CANCEL"
		;;
	*)
		arg=$((arg))
		debugf 'printing %d bytes\n' "$arg"
		rc=$(head -c "$arg" | write_exitcode cat_to_printer)
		case "$rc" in '' | *[!0-9]*)
			exit "$CUPS_BACKEND_FAILED"
		esac
		[ "$rc" -eq 0 ] || exit "$rc"
		;;
	esac
	debugf 'print command completed\n'
}
 
onexit () {
	debugf 'exiting\n'
	close_printer
	unlock_printer
}
 
trap onexit 0
 
IFS=''
while read -r line
do
	cmd=${line%% *}
	arg=${line#"$cmd"}
	arg=${arg# }
	case "$cmd" in
	set) handle_set "$arg";;
	print) handle_print "$arg";;
	*)
		debugf 'unknown protocol command "%s"\n' "$cmd"
		exit "$CUPS_BACKEND_CANCEL"
	esac
done
```

Make sure `/etc/dropbear/authorized_keys` will allow CUPS to connect (as described in the backend/ssh script); e.g.,

```
command="./recv-lpjob",no-pty,no-port-forwarding ssh-rsa AAAAB2...19Q== lp@cups.example.net
```

## Non-CUPS usage

If not using CUPS, the backend can be called manually from the command line; e.g. (assuming the printer wants PJL):

```
export DEVICE_URI=ssh://root@openwrt.example.net/dev/usb/lp0
/usr/lib/cups/backend/ssh 0 . '' 1 '' test.pjl
```

If no filename is given, it will read from stdin. You can replace `/dev/usb/lp0` with `/dev/null` (in the URI) for testing.

To embed a raw PostScript file in PJL and send it:

```
export DEVICE_URI=ssh://root@openwrt.example.net/dev/usb/lp0
(
printf '\33%%-12345X@PJL\n@PJL ENTER LANGUAGE = POSTSCRIPT\n'
cat test.ps
printf '\33%%-12345X'
) | /usr/lib/cups/backend/ssh 0 . '' 1 ''
```
