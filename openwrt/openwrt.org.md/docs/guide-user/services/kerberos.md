# Kerberos Server HowTo

Kerberos is a network authentication protocol which works on the basis of “tickets” to allow nodes communicating over a non-secure network to prove their identity to one another in a secure manner. (Source [Kerberos\_(protocol)](https://en.wikipedia.org/wiki/Kerberos_%28protocol%29 "https://en.wikipedia.org/wiki/Kerberos_(protocol)"))

## Preparation

### Prerequisites

Please read about here [Kerberos\_(protocol)](https://en.wikipedia.org/wiki/Kerberos_%28protocol%29 "https://en.wikipedia.org/wiki/Kerberos_(protocol)") and especially [Kerberos How-to](http://www.kerberos.org/software/adminkerberos.pdf "http://www.kerberos.org/software/adminkerberos.pdf").

### Required Packages

#### Server (OpenWrt)

- **`krb5-server`**
  
  - **`krb5-libs`** (dependency of *krb5-server*)

#### Client (OpenWrt)

- **`krb5-client`**

## Installation

[opkg](/docs/guide-user/additional-software/opkg "docs:guide-user:additional-software:opkg")

```
opkg install krb5-server
```

## Configuration

### Server configuration

Create the file `/etc/krb5.conf` with the following credentials. Example:

```
[libdefaults]
    default_realm = YOURDOMAIN.ORG
    dns_lookup_realm = false
    dns_lookup_kdc = false
    ticket_lifetime = 24h
    forwardable = yes

[realms]
    YOURDOMAIN.ORG = {
        kdc = server_address_of_this_machine:88
        admin_server = server_address_of_this_machine:749
        default_domain = yourdomain.org
    }

[domain_realm]
    .yourdomain.org = YOURDOMAIN.ORG
    yourdomain.org = YOURDOMAIN.ORG
```

Replace **YOURDOMAIN.ORG** / **yourdomain.org** with the domain name of your domain the server should act for (names must be specified in UPPER- / lowercase as shown above). Replace **server\_address\_of\_this\_machine** with the host name/IP adress of this server you're setting up.

### Starting the server

Start the server by issuing

```
/etc/init.d/krb5kdc start
```

This should create the /etc/krb5kdc/ directory with the following files

```
-rw-------    1 root     root         8192 Feb 13 11:17 principal
-rw-------    1 root     root         8192 Feb 13 09:12 principal.kadm5
-rw-------    1 root     root            0 Feb 13 09:12 principal.kadm5.lock
-rw-------    1 root     root            0 Feb 13 11:17 principal.ok
```

In case you don't get any error messages check your server by logging on with

```
kadmin.local
```

In case everything works well you will see the following message

```
root@bridge:~# kadmin.local
Authenticating as principal xxxxxxx/admin@YOURDOMAIN.ORG with password.
kadmin.local:
```

### Testing the server

Perform the tests as described in the [Kerberos How-to](http://www.kerberos.org/software/adminkerberos.pdf "http://www.kerberos.org/software/adminkerberos.pdf") document on page 16/17.

## Start on boot

To enable/disable automatic start on boot:

```
/etc/init.d/krb5kdc enable
```

this simply creates a symlink: `/etc/rc.d/S60krb5kdc → /etc/init.d/krb5kdc`

```
/etc/init.d/krb5kdc disable
```

this removes the symlink again

## Notes

- The Project Homepage: [http://web.mit.edu/kerberos/](http://web.mit.edu/kerberos/ "http://web.mit.edu/kerberos/")
- Kerberos How-To: [http://www.kerberos.org/software/adminkerberos.pdf](http://www.kerberos.org/software/adminkerberos.pdf "http://www.kerberos.org/software/adminkerberos.pdf")
- Kerberos Tutorial: [http://www.kerberos.org/software/tutorial.html](http://www.kerberos.org/software/tutorial.html "http://www.kerberos.org/software/tutorial.html")
