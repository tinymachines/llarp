# Elevating privileges with sudo

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

## Introduction

- This how-to helps improve security with [sudo](https://en.wikipedia.org/wiki/Sudo "https://en.wikipedia.org/wiki/Sudo") when using command-line interface.
- Log in as an unprivileged user and use sudo to run commands with elevated privileges.

## Goals

- Drop user privileges by default.
- Elevate user privileges on demand.

## Command-line instructions

Install the required packages.

```
# Install packages
opkg update
opkg install shadow-useradd shadow-usermod shadow-groupadd sudo
```

Create an unprivileged test user and set a password.

```
# Create a user
useradd -m -s /bin/ash test
 
# Set user password
passwd test
```

Create a privileged group and make the test user its member.

```
# Create system group
groupadd -r sudo
 
# Add user to group
usermod -a -G sudo test
```

Grant root privileges to the group when using sudo.

```
# Configure sudoers
cat << EOF > /etc/sudoers.d/00-custom
%sudo ALL=(ALL) ALL
EOF
```

## Testing

Log in as an unprivileged user. Elevate privileges for a specific command.

```
sudo -i -u test
id
sudo id
```

## Troubleshooting

Collect and analyze the following information.

```
id test
ls -l /etc/sudoers /etc/sudoers.d/*
grep -v -e "^#" -e "^$" /etc/sudoers /etc/sudoers.d/*
```

## Extras

### References

- [useradd](http://man.cx/useradd%288%29 "http://man.cx/useradd%288%29")
- [usermod](http://man.cx/usermod%288%29 "http://man.cx/usermod%288%29")
- [groupadd](http://man.cx/groupadd%288%29 "http://man.cx/groupadd%288%29")
- [passwd](http://man.cx/passwd%288%29 "http://man.cx/passwd%288%29")
- [sudo](http://man.cx/sudo%288%29 "http://man.cx/sudo%288%29")
- [visudo](http://man.cx/visudo%288%29 "http://man.cx/visudo%288%29")

### Manual setup

Add the user by hand using a unique UID and GID.

```
# Edit configs
vi /etc/passwd
vi /etc/group
vi /etc/shadow
 
# Create home directory
mkdir -p /home/test
 
# Set permissions
chown test:test /home/test
 
# Set user password
passwd test
```

Check the resulting configs.

```
# Check configs
> grep -e test /etc/passwd /etc/group /etc/shadow
/etc/passwd:test:x:1000:1000::/home/test:/bin/ash
/etc/group:test:!:1000:
/etc/shadow:test:$1$uPzGJ3jI$n7ld4E73SPsIx0QTXPMfu1:19615:0:99999:7:::
```

### Removing user and group

Install the required packages. Remove the user and group.

```
# Install packages
opkg update
opkg install shadow-userdel shadow-groupdel
 
# Remove user and group
userdel test
groupdel sudo
```
