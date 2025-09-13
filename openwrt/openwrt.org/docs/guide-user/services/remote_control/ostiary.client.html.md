# Ostiary Client (run a fixed set of commands remotely)

The Ostiary client, “ostclient” is designed to talk to an [ostiaryd](/docs/guide-user/services/remote_control/ostiary.server "docs:guide-user:services:remote_control:ostiary.server") service that allows you to run a fixed set of commands remotely, without giving everyone else access to the same commands.

The following are the key design goals:

- “First, do no harm.” It should not be possible to use the Ostiary system itself to damage the host it's running on. In particular, it's willing to accept false negatives (denying access to legitimate users) in order to prevent false positives (allowing access to invalid users).
- Insofar as possible, eliminate any possibility of bugs causing undesired operations. Buffer overflows, timing attacks, etc. should be impossible for an external attacker to execute. There's no point in installing security software if it makes you less secure.
- Be extremely modest in memory and CPU requirements. (eg. running on a Mac SE/30, a 16MHz 68030 machine) and connecting from a Palm Pilot (a 16MHz 68000 machine).
- Keep things simple. This is not an ssh replacement. Each successful challenge/response will result in executing a corresponding script.
- It is immune to replay attacks

This wiki is a quick summary of the author's documentation followed by openwrt specific usage instructions. For any technical info you may wish to view the author's site: [http://ingles.homeunix.net/software/ost/index.html](http://ingles.homeunix.net/software/ost/index.html "http://ingles.homeunix.net/software/ost/index.html") .

## How to get it

The client installs as part of the server package [ostiaryd](/docs/guide-user/services/remote_control/ostiary.server "docs:guide-user:services:remote_control:ostiary.server"); both client and server will be located in /usr/bin

## Client Syntax

```
osctlient v4.0 usage: 
        ostclient -a address [-p port] [-f fd]

	-a	address to contact - two formats:
			address
			address:port
	-p	port (only needed if unspecified in -a)
	-f	read passphrase from indicated file descriptor
```
