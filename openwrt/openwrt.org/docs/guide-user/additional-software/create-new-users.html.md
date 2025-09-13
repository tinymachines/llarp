# Create new users and groups for applications or system services

Running applications as root is not a good security practice, any vulnerability in the application will allow to have access to root privileges in the OpenWrt system.

For this reason, many applications are set to use a dedicated user, that has no root privileges and no access to shell (command line), and also limited access to some folders only (usually for the service configuration and data).

## Add a new user

```
# opkg update
# opkg install shadow-useradd
# useradd -r -s /bin/false service-name
```

The file where all the users are registered is /etc/passwd, so you can see what UID and GID your new user has (and change them if you want). See the following example

```
# cat /etc/passwd
root:x:0:0:root:/root:/bin/ash
daemon:*:1:1:daemon:/var:/bin/false
ftp:*:55:55:ftp:/home/ftp:/bin/false
network:*:101:101:network:/var:/bin/false
nobody:*:65534:65534:nobody:/var:/bin/false
dnsmasq:x:453:453:dnsmasq:/var/run/dnsmasq:/bin/false
docker:x:65536:65536:docker:/var/run/docker:/bin/false
ubus:x:81:81:ubus:/var/run/ubus:/bin/false
```

We can see that there are multiple users, the first is “root” (the administrator user) and many others for other services in the system. Depending on what you have installed you may have more or less users here.

Each line is an entry for one user, and fields on each line are separated by a colon. The fields are:

1. User name
2. Encrypted password
3. User ID number (UID)
4. User’s group ID number (GID)
5. Full name of the user (GECOS)
6. User home directory
7. Login shell ( **/bin/ash** is the valid shell on OpenWrt, write **/bin/false** instead to disable the shell for this user)

To add a new user by hand, add a new line at the end of the file, filling in the appropriate information. The information you add needs to meet some requirements, make sure that both the user name and user ID is unique. Assign the user a group, either 100 (the “users” group in OpenWRT) or your default group (use its number, not its name). Give the user a valid home directory (which you’ll create later) and shell (set shell to /bin/false if you want to disable shell access and also login).

So, open the file for editing and add an entry of user details in /etc/passwd file.

```
# vi /etc/passwd
```

Example new entry:

```
testuser:x:501:501:testuser:/home/user:/bin/ash
```

Assign a password to the user you just created.

```
# passwd testuser
```

passwd will prompt you for a password. You will see output like this

```
Changing password for user testuser.
New password:
Retype new password:
passwd: all authentication tokens updated successfully.
```

## Adding groups

All normal users are members of the “users” group on a typical Linux system. However, if you want to create a new group, or add the new user to additional groups, you’ll need to modify the /etc/group file. Here is a typical entry:

```
cvs::102:chris,logan,david,root
```

The fields are group name, group password, group ID, and group members, separated by commas. Creating a new group is a simple matter of adding a new line with a unique group ID, and listing all the users you want to be in the group. Any users that are in this new group and are logged in will have to log out and log back in for those changes to take effect.

## Adding user's home directory

Use mkdir to create the new user’s home directory in the location you entered into the /etc/passwd file, and use chown to change the owner of the new directory to the new user.

```
# mkdir /home/testuser
# chown testuser /home/testuser
```

## Remove users

Removing a user is a simple matter of deleting all of the entries that exist for that user. Remove the user’s entry from /etc/passwd and remove the login name from any groups in the /etc/group file. If you wish, delete the user’s home directory, too.
