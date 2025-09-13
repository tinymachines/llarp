# ZNC IRC network bouncer

[ZNC's](https://en.wikipedia.org/wiki/ZNC "https://en.wikipedia.org/wiki/ZNC") configuration is located in `/etc/config/znc`. You can use it to configure most common aspects of ZNC. Supplying your own configuration is supported as of 0.998-2.

Notes:

- This configuration is only for ZNC 0.094 or later.
- 10.03.1-rc4's ZNC 0.094 has a hidden dependency to `libstdcpp`. This is fixed in trunk and recent Backfire builds.
- 10.03.1-rc4's ZNC 0.094 takes 30 seconds until it actually works after starting it. This wait time is removed in trunk.

## Sections

There are two section types for ZNC, a common one and one or more user sections.

### Common Options

The common section defines where ZNC is supposed to listen, which global modules should be loaded and some other global options. A minimum configuration looks like this:

```
config 'znc'
	list 'listener'	'192.168.1.1 1234'
```

#### Valid Options

Name Type Required Default Description `anoniplimit` integer no `10` Number of anonymous connections allowed. `connectdelay` integer no `5` Time in seconds ZNC waits between establishing connections. `listener` list of strings Yes *none* One or more directives where ZNC should listen, in the format “&lt;IP/Host&gt; \[+]&lt;Port&gt;”. The “+” forces the port to be SSL. Both IPv4 and IPv6 addresses are valid. **Note:** You need to provide a SSL certificate for using SSL ports. `maxbuffersize` integer no `500` Sets the global Max Buffer Size a user can have. `module` list of strings no *none* Instructs ZNC to load global modules. Uses the format “&lt;modulename&gt; \[arguments...]”. `runas_user` string no *root/nobody* Run ZNC as this user instead of the default user (root for external config, nobody for generated config) `runas_group` string no *nogroup* Run ZNC as this group. Only used when using a generated config. `runas_shell` string no *none* Use this when the *runas\_user* does not have a shell, i.e. *nobody* in *passwd* is */bin/false*. Only used when using a generated config. `serverthrottle` integer no `30` Time in seconds ZNC waits between two connection attempts to an IRC server. `znc_config_path` string no *none* Use an external configuration at this location instead of the generated one. Any other options except `runas_user` will get ignored.  
**Note:** Using runas\_user to run ZNC as a different user with an external config requires `'su`' installed. Alternatively, you may make use of [droproot](http://wiki.znc.in/Droproot "http://wiki.znc.in/Droproot") from your external configuration file, as it is always installed with ZNC. `znc_ssl_cert` string no *none* Use this certificate for SSL ports.

**Note:** If you want your ZNC to be reachable from the outside, you can use '0.0.0.0' as the IP address, which makes ZNC listen on all interfaces. You also need to allow connections to its port through the firewall.

### User Definition

For each connection you want to use you need to create a separate user. Each user section corresponds to one user in ZNC. The section name is the user name for authentication to ZNC itself.

A minimal user configuration looks like this:

```
config 'user' 'sampleUser'
	option 'password' 'changeme'
	option 'nick'     'sampleUser'
```

This would create a user with the login `sampleUser`, the password `changeme` and the nick `sampleUser`.

#### Valid Options

Name Type Required Default Description `altnick` string no *none* The Alternative Nickname, if the first one is occupied. `buffer` integer no `50` Specifies the per channel log buffer limit in lines. `chanmodes` string no *&lt;Server defaults&gt;* Overrides the channel modes. `channel` list of strings no *none* Specifies one or more channels to join on connect. The required format is “&lt;channelname&gt; \[&lt;password&gt;]”. **Note:** Only ZNC 0.096 or later. `ident` string no *&lt;nick&gt;* Specifies the ident to use. `module` list of strings no *none* Instructs ZNC to load user modules. The required format is “modulename&gt; \[&lt;arguments...&gt;]”. `nick` string Yes *none* The Nickname of this user. `realname` string no *&lt;nick&gt;* The real name of this user. `password` string Yes *none* Password for this user. Can be either a plain text password, or a generated password hash through `znc -s`. **Note:** ZNC 0.094 supports only plain text.

Example code for crypted

```
        option 'password' 'sha256#...'
 
<Pass password>
        Method = sha256
        Hash = 746a8a22b32f22c9dd92e9918b084ac8bcf1c94361d71fd5ee4a7154f86371d4
        Salt = 8+1Isl8ewZ+Bai;tx2ML
</Pass>
```

`quitmsg` string no *&lt;ZNC default&gt;* Specifies the quit message used when closing the connection to the server. `server` list of strings no *none* Specifies the list of servers to connect to. The required format “&lt;IP/Host&gt; \[+]&lt;Port&gt; \[&lt;Password&gt;]”, where the “+” indicates that SSL should be used. Both IPv4 and IPv6 addresses are valid.
