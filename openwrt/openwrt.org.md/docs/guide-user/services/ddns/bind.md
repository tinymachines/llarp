# DDNS with bind as own DNS server

If you have your own domain and are running `bind` as your primary DNS server, you can use the [ddns-scripts-nsupdate](/packages/pkgdata/ddns-scripts-nsupdate "packages:pkgdata:ddns-scripts-nsupdate") package to update `bind`. There are two parts:

1. Configure `bind` to accept DNS updates using TSIG.
2. Configure OpenWr DDNS client to send updates to `bind` when the IP changes.

In the below example, we will use the following parameters:

- Domain name: `example.org`
- DNS Server: `ns.example.org`
- Router hostname: `openwrt.example.org`

#### Configure Bind

The first step is to set up `bind` to allow updates to the `A` (IPv4) and `AAAA` (IPv6) records for **openwrt.example.org**. To do this, log onto your DNS server and run `/usr/sbin/ddns-confgen -s openwrt.example.org`. This will generate the key and shared secret that will be used to update DNS. You should see output similar to the following:

```
$ /usr/sbin/ddns-confgen -s openwrt.example.org
# To activate this key, place the following in named.conf, and
# in a separate keyfile on the system or systems from which nsupdate
# will be run:
key "ddns-key.openwrt.example.org" {
        algorithm hmac-sha256;
        secret "B1m6Xb1ngrEeNFSExr8homgfzeN8kWIBkJpnoAHF5D8=";
};

# Then, in the "zone" statement for the zone containing the
# name "openwrt.example.org", place an "update-policy" statement
# like this one, adjusted as needed for your preferred permissions:
update-policy {
          grant ddns-key.openwrt.example.org name openwrt.example.org ANY;
};

# After the keyfile has been placed, the following command will
# execute nsupdate using this key:
nsupdate -k <keyfile>
```

The two important things to note for the second part of the setup, on openwrt, are:

1. Key Name: **ddns-key.openwrt.example.org**
2. Shared Secret (Base64 encoded): **B1m6Xb1ngrEeNFSExr8homgfzeN8kWIBkJpnoAHF5D8=** (yours will differ as it is randomly generated)

You then need to do as the comments in the output say and put both the `key` block and the `update-policy` block in the proper places within your bind configuration file (generally `/etc/bind/named.conf.local` or `/etc/bind/named.conf`) and reload/restart bind.

To test that bind is now properly configured you can run a test as follows:

```
$ nsupdate
server ns.example.org
key hmac-sha256:ddns-key.openwrt.example.org B1m6Xb1ngrEeNFSExr8homgfzeN8kWIBkJpnoAHF5D8=
update del openwrt.example.org A
update add openwrt.example.org 600 A 10.10.10.10
show
send
answer
quit
$ dig @ns.example.org openwrt.example.org A
```

You should see no errors, and the `10.10.10.10` IPv4 address returned for **openwrt.example.org**. If so, you are ready to move on to the next step which is to configure DDNS on OpenWRT to send updates to bind.

See also: [BIND 9 Administrator Reference Manual](https://bind9.readthedocs.io/en/latest/advanced.html#tsig "https://bind9.readthedocs.io/en/latest/advanced.html#tsig")

#### Configure DDNS client

Using LuCI Web UI: install [luci-app-ddns](/packages/pkgdata/luci-app-ddns "packages:pkgdata:luci-app-ddns") package, then go to **Services** → **Dynamic DNS**. In the bottom section, Services, you will see two example configurations: one for IPv4 and one for IPv6. Click the **Edit** button, and enter the following information (based on the example config from above; but, use your own values):

- Lookup Hostname: **openwrt.example.org**
- DDNS Service provider: **bind-nsupdate**
- Domain: **openwrt.example.org**
- Username: **hmac-sha256:ddns-key.openwrt.example.org**
- Password: **B1m6Xb1ngrEeNFSExr8homgfzeN8kWIBkJpnoAHF5D8=**
- DNS-Server (on the Advanced Settings tab): **ns.example.org**

Then click **Save**, followed by **Save &amp; Apply**.

Congratulations, if you did everything right, OpenWrt should now update DNS with the current IP Address for your router.

If you are not using LuCI and want to configure manually from the command line, you will need to edit `/etc/config/ddns` as follows (using the example config from above):

```
config ddns 'global'
        option ddns_dateformat '%F %R'
        option ddns_loglines '250'
        option ddns_rundir '/var/run/ddns'
        option ddns_logdir '/var/log/ddns'

config service 'myddns_ipv4'
        option enabled '1'
        option lookup_host 'openwrt.example.org'
        option use_ipv6 '0'
        option service_name 'bind-nsupdate'
        option domain 'openwrt.example.org'
        option ip_source 'network'
        option ip_network 'wan'
        option interface 'wan'
        option dns_server 'ns.example.org'
        option use_syslog '2'
        option check_unit 'minutes'
        option force_unit 'minutes'
        option retry_unit 'seconds'
        option username 'hmac-sha256:ddns-key.openwrt.example.org'
        option password 'B1m6Xb1ngrEeNFSExr8homgfzeN8kWIBkJpnoAHF5D8='
```

You can then add another stanza for IPv6, by turning on `use_ipv6` and changing `ip_network` and `interface` to **wan6**.
