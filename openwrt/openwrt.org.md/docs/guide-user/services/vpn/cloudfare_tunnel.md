# Cloudflare tunnel

> [Cloudflare Tunnel](https://www.cloudflare.com/products/tunnel/ "https://www.cloudflare.com/products/tunnel/") provides you with a secure way to connect your resources to [Cloudflare](https://www.cloudflare.com/ "https://www.cloudflare.com/") without a publicly routable IP address. With Tunnel, you do not send traffic to an external IP — instead, a lightweight daemon in your infrastructure `cloudflared` creates outbound-only connections to Cloudflare’s global network. [Cloudflare Tunnel](https://www.cloudflare.com/products/tunnel/ "https://www.cloudflare.com/products/tunnel/") can connect HTTP web servers, SSH servers, remote desktops, and other protocols safely to [Cloudflare](https://www.cloudflare.com/ "https://www.cloudflare.com/"). This way, your origins can serve traffic through [Cloudflare](https://www.cloudflare.com/ "https://www.cloudflare.com/") without being vulnerable to attacks that bypass [Cloudflare](https://www.cloudflare.com/ "https://www.cloudflare.com/").

Beyond enhancing security and privacy, Cloudflare Zero Trust Tunnel is frequently used for NAT traversal, especially in environments with [CGN](https://en.wikipedia.org/wiki/Carrier-grade_NAT "https://en.wikipedia.org/wiki/Carrier-grade_NAT").

## Site

Start by creating an account at [https://www.cloudflare.com/plans/](https://www.cloudflare.com/plans/ "https://www.cloudflare.com/plans/"). The *free plan* is sufficient for most users.

You require a domain to add as a site to Cloudflare's service. You receive instructions on how to point the domain to selected Cloudflare DNS servers Sometimes it takes a while for DNS to propagate. In the meantime set up the rest of your settings. I registered a cheap domain specific for this purpose and have no plans to host anything there for an audience. Finally, once DNS has propagated and your site's status says active, we can proceed.

### Zero trust

Select *Zero Trust* from the sidebar; this is where tunnels are managed. Set up things as you like. For example, under *Gateway* you find DNS and Firewall policies; there is no need to touch them at all to get tunnel(s) working. Under *Settings* → *General settings* you can find your **Team domain**. The sub-domain/hostname part, meaning that part before *.cloudflareaccess.com* is something that you should remember. When you log in with **WARP** (available for desktop OSs and phones) to establish a client connection, this Team ID is asked upon logon. So write it down if it is difficult to remember.

### Important note

Under *Settings* → *Network* are settings for the proxy. To get tunnels working, you **must** enable the proxy. By default, it seems to be disabled. When you enable it, you can select either TCP or UDP, or both. This part is rarely mentioned in other guides.

Other settings on that page are not important for tunneling, except *Split tunnels and local domain fallback* - so select **manage**. There, are settings for **device enrolments**. Make necessary changes there for login requirements. For example, *\*.yourmaildomain.com*.

Edit also the *default profile* - there you find the section *Split tunnels*. Select what you prefer. In this example, we choose to **Exclude IPs and domains**. Click *manage* then find a list of subnets, IP addresses, and domain names. Make sure that the network you want to connect to is not on the list. For example, if your LAN is 192.168.0.1/24, make sure none of the subnets on the list include your used IP range.

For service mode, I chose *Gateway with WARP*. Unsure whether other modes work. It should be chosen as default.

If you want local DNS to resolve to IP addresses, set this under *Local Domain Fallback*. As I did not use it, I cannot comment.

On *Device posture*, as *WARP Client checks*, I added **Gateway** with name *Gateway* - but that is possibly not a requirement. Other settings on that page can be left as-is.

Finally, basic setup is complete. **Keep your browser open and make sure you stay logged in to Cloudflare**.

## OpenWrt shell

Login to your router and install *cloudflared* package:

```
opkg update
opkg install cloudflared
```

Settings are in `/etc/config/cloudflared`, but the only setting that should be changed is the `enabled` boolean. It is `false` by default.

Another location is at `/etc/cloudflared`, some changes there are necessary but at this moment, we won't touch anything there.

## Let's create our tunnel

You can create a tunnel in the Cloudflare dashboard or via command line on your machine (“locally managed”).

Go to Zero Trust Dashboard at [https://one.dash.cloudflare.com/](https://one.dash.cloudflare.com/ "https://one.dash.cloudflare.com/") Open *Networks* → *Tunnels* and click on *Create a tunnel*.

You can copy the token from “4. Run the following command:” and put it into `/etc/config/cloudflared` option `token`.

Then you need to specify a Public Hostname with type HTTP and URL `http://localhost:80` where your Luci or website is running.

Then restart daemon with `/etc/init.d/cloudflared restart`. It may take up to 3 minutes while the tunnel will be established. Once you see in logs `Updated to new configuration config=“{\”ingress\` then your local tunnel was established and received its config.

Since a tunnel is configured remotely you may need to open `/etc/cloudflared/config.yml` and comment all lines there.

## Create tunnel from a command line

First you'll need to run `cloudflared tunnel login`:

```
root@openwrt:/etc/cloudflared# cloudflared tunnel login
Please open the following URL and log in with your Cloudflare account:

https://dash.cloudflare.com/argotunnel?callback=https%3A%2F%2Flogin.cloudflareaccess.org%2FXXXXXXXXXX

Leave cloudflared running to download the cert automatically.
```

Copy the link and open it in your **browser** to proceed. If you were still logged in, you will get a view where you see the site as option that we added in the beginning. Select your site and click **Authorize**.

Go back to your OpenWrt shell, and you see a notification that **cert.pem** has been created. We copy it to `cloudflared`s **config path**.

```
You have successfully logged in.
If you wish to copy your credentials to a server, they have been saved to:
/root/.cloudflared/cert.pem
root@openwrt:/etc/cloudflared# cp /root/.cloudflared/cert.pem /etc/cloudflared/
```

Next we create the tunnel named `TUNNELNAME`. Copy the generated `json` config file to the `/etc/cloudflared/` config path. `XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX` is the generated id.

```
root@openwrt:/etc/cloudflared# cloudflared tunnel create TUNNELNAME
Tunnel credentials written to /root/.cloudflared/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX.json. cloudflared chose this file based on where your origin certificate was found. Keep this file secret. To revoke these credentials, delete the tunnel.

Created tunnel TUNNELNAME with id XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
root@openwrt:/etc/cloudflared# cp /root/.cloudflared/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX.json /etc/cloudflared/
```

#### Get JSON file from configured tunnel token

**I already created my tunnel from CF dashboard, how can i get json file?**

Token and JSON actually contain the same information, just in slightly different formats.

**How to convert token to JSON**

1. Decode token from base64. It will become a JSON data with one-letter keys.
2. Replace keys with longer versions: a → AccountTag, t → TunnelID, s → TunnelSecret.

**How to convert JSON to token**

Just the opposite:

1. Convert keys to short versions: AccountTag → a, TunnelID → t, TunnelSecret → s
2. Remove whitespaces and line ends, if any
3. Encode to base64, probably removing trailing = if any.

Edit `/etc/cloudflared/config.yml`: I commented out the first line about the URL which is superfluous:

[/etc/cloudflared/config.yml](/_export/code/docs/guide-user/services/vpn/cloudfare_tunnel?codeblock=4 "Download Snippet")

```
#url: http://localhost:8000
tunnel: XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
credentials-file: /etc/cloudflared/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX.json
```

I got errors logged about wrong `sysctl` values so put the settings to I created the `/etc/sysctl.d/30-cloudflared-conf` file:

[/etc/sysctl.d/30-cloudflared-conf](/_export/code/docs/guide-user/services/vpn/cloudfare_tunnel?codeblock=5 "Download Snippet")

```
net.ipv4.ping_group_range="0 429296729"
net.core.rmem_max=2500000
```

After this, restart the service: `/etc/init.d/cloudflared restart`

Return to the browser and at *Cloudflare Zero Trust*, open *Access* → *Tunnels*. In the list should be our freshly created `TUNNELNAME`.

Choose to configure it and you are prompted that `TUNNELNAME` must be irreversibly migrated. Go ahead and migrate it, confirm all queries. Now, re-configure it. Choose *Private Network* tab and add new network. On the CIDR prompt add your LAN subnet. In this example it was 192.168.0.0/24.

After this we enable, and restart `cloudflared`:

```
/etc/init.d/cloudflared stop
/etc/init.d/cloudflared enable
/etc/init.d/cloudflared start
```

## Test network

Install **Cloudflare WARP** to your phone, **disable wi-fi** staying on the mobile network and start **WARP**. In *Settings* → *Account*, enter your **team name**. This is in Cloudflare *General Settings*. If you added suitable rules to *Settings* → *Warp settings* → *Device enrollment* you will be asked your credentials, i.e. email address. You are emailed a verification code which you need to enter there.

Under *WARP's Settings* → *Advanced* → *Connection options* → *Excluded routes* verify that your LAN subnet is absent from the list - we previously excluded it. Under *Virtual Networks*, verify that the profile you chose is checked. I edited the default profile without creating a new one. Finally, exit settings. The front page should say Zero Trust, Connected and Your internet is protected. Open your web browser and point it to your **router's IP** at 192.168.0.1 and if all went well, LuCi opens (in case you have it installed).

## One final note

You may notice that ICMP **ping** doesn't work. This is normal and you cannot do anything about it because we enabled TCP and UDP, while **ICMP** used by ping is unavailable as a feature on `cloudflared`.

If you see a message “failed to dial to edge with quic” this is a known issue [https://github.com/openwrt/packages/issues/23596](https://github.com/openwrt/packages/issues/23596 "https://github.com/openwrt/packages/issues/23596"). The UDP and QUIC are not so important unless you are on mobile internet with many packet loses.

## See also

- [Support forum](https://community.cloudflare.com/t/openwrt-support/610306 "https://community.cloudflare.com/t/openwrt-support/610306")
- [Tunnel general-purpose parameters](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/configure-tunnels/tunnel-run-parameters/ "https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/configure-tunnels/tunnel-run-parameters/")
- [config.yml file parameters](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/configure-tunnels/local-management/configuration-file/ "https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/configure-tunnels/local-management/configuration-file/")
- [install-cloudflared.sh](https://github.com/Coralesoft/OpenwrtCloudflare "https://github.com/Coralesoft/OpenwrtCloudflare") Install wizard script
- [How to convert token to JSON](https://github.com/cloudflare/cloudflared/issues/929#issuecomment-2078157277 "https://github.com/cloudflare/cloudflared/issues/929#issuecomment-2078157277")
