# IP set examples

See also: [IP set configuration](/docs/guide-user/firewall/firewall_configuration#ip_sets "docs:guide-user:firewall:firewall_configuration"), [Filtering traffic with IP sets by DNS](/docs/guide-user/firewall/fw3_configurations/dns_ipset "docs:guide-user:firewall:fw3_configurations:dns_ipset")

[IP sets](https://wiki.nftables.org/wiki-nftables/index.php/Sets "https://wiki.nftables.org/wiki-nftables/index.php/Sets") is a netfilter feature to manage a large group of stations/networks as a single named set. The netfilter rules can then match packet fields on the set rather than individual stations. This creates a number of efficiencies, for example a hash lookup of the station addresses in the set.

firewall4 supports the most common IP sets functions. This section provides some examples to illustrate how to incorporate IP sets into netfilter rules.

## Using IP sets to drop SMTP spam

IP sets is great for collecting a large set of IP addresses/networks under one label and then using the label in subsequent rules as a single match criteria for any entry in the IP set.

One of the big uses of IP sets is to block spam generators (stations or networks that randomly generate *billions* of spam emails daily.) There are thousands of spam generators; adding a reject rule for each makes the netfilter rule list huge and inefficient.

So all Spam networks are added to a single IP set `name` and then that `name` is used in the match rules.

In the `/etc/config/firewall` rules add:

```
config	ipset
	option	name		'dropcidr'
	option	match		'src_net'
	option	enabled		'1'
	list	entry		'42.56.0.0/16'
	list	entry		'180.178.160.0/20'
	list	entry		'79.133.43.0/24'
	list	entry		'27.44.0.0/15'
	list	entry		'192.168.3.0/24'
 
config	rule
	option	src		'wan'
	option	ipset		'dropcidr'
	option	dest_port	'25'
	option	target		'DROP'
	option	name		'DROP-SMTP-WAN-LAN'
	option	enabled		'1'
```

The `ipset` configuration instructs the firewall to create an IP set named `dropcidr` and matches it to the source network field using a traffic rule.

You can list the resulted IP sets to check it.

```
nft list sets
```

There is a good deal of internal optimization that can be done inside the IP sets kernel modules. This IP set is configured to use a highly efficient hash rather than a linear search to match the source network.

The `rule` section matches on a network in `dropcidr` and port 25 aka SMTP. If there is a match, the DROP target is called. Use DROP and not REJECT for this rule.

See [Netfilter Managment](/docs/guide-user/firewall/netfilter_iptables/netfilter_management "docs:guide-user:firewall:netfilter_iptables:netfilter_management") to view and verify the new firewall sections.

## Populating the IP set

The configuration above uses a number of `list entry` lines to populate the IP set with some initial IP ranges. `192.168.3.0` is a private network on the WAN-side used to test this feature. The others are actual spam sources.

In practice it is better to use the `loadfile` option instead which allows specifying the IP set contents in an external file for easier maintenance. Such an external file can be for example created from publicly available blocklists or populated by other programs for use with the IP set.

To use the `loadfile` option, first create a plaintext file containing the IP ranges to add to the set:

```
cat << "EOF" > /etc/dropcidr.txt
42.56.0.0/16
180.178.160.0/20
79.133.43.0/24
27.44.0.0/15
192.168.3.0/24
EOF
```

Afterwards, modify the IP set declaration in the firewall configuration by removing the `list entry` lines and replacing them with a sole `loadfile` option:

```
config	ipset
	option	name		'dropcidr'
	option	match		'src_net'
	option	enabled		'1'
	option	loadfile	'/etc/dropcidr.txt'
```

The CIDRs can be dynamically added and deleted in the `dropcidr` table while the netfilter rule is active.

Besides adding IPs manually, package [dnsmasq-full](/packages/pkgdata/dnsmasq-full "packages:pkgdata:dnsmasq-full") can automatically populate the list. It can be used to add IPs that were send to hosts for certain names. This is helpful if names are used for filtering.
