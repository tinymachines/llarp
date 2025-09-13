## Honeypots

Running honeypots on OpenWrt allows for detection of network intrusions and automatically alerting the owner of the incident. It is also possible to automatically isolate the offending device on the WiFi network. Currently [OpenCanary](https://opencanary.readthedocs.io/en/latest/ "https://opencanary.readthedocs.io/en/latest/") has been confirmed working on OpenWrt as a honeypot. It is important to isolate the honeypots from the rest of the network and OpenWrt itself, thus here we document how to deploy it in a separate firewall zone and to run it in a Docker container.

## Installation

First, you have to setup [OpenWrt as a Docker host](/docs/guide-user/virtualization/docker_host "docs:guide-user:virtualization:docker_host"). Pay particular attention to install `dockerd` and `docker-compose` before installing `luci-app-dockerman`. It is recommended to attach an [external storage](/docs/guide-user/storage/usb-drives "docs:guide-user:storage:usb-drives") to store your Docker containers, thus after you installed Docker, under the Configuration tab you can specify your external storage as Docker Root Dir.

While the `luci-app-dockerman` provides a WebUI to pull Docker images, it is recommended to ssh into OpenWrt and pull the image by running `docker pull thinkst/opencanary`.

Now in LuCI navigate to the Containers and click Add. Name the container opencanary and pick `thinkst/opencanary:latest` as the Docker Image. Under Bind mount add the config from your external storage device to the container, for example `/mnt/opencanary/.opencanary.conf:/root/.opencanary.conf`, and make sure to click on the + sign next to it! Leave all other options unselected and use the defaults (interactive/tty/exposed ports).

Once the container is configured you need to create an OpenCanary configuration file at `/mnt/opencanary/.opencanary.conf` according the [OpenCanary documentation](https://opencanary.readthedocs.io/en/latest/starting/configuration.html "https://opencanary.readthedocs.io/en/latest/starting/configuration.html"). It is easiest by logging into OpenWrt using SSH and editing the file using nano (`opkg install nano`). Here is a simple example configuration that enables an FTP honeypot and logs to the stdout of the Docker container:

```
{
    "device.node_id": "openwrt",
    "ip.ignorelist": [ ],
    "ftp.enabled": true,
    "ftp.port": 21,
    "ftp.banner": "FTP server ready",
    "logger": {
        "class": "PyLogger",
        "kwargs": {
            "formatters": {
                "plain": {
                    "format": "%(message)s"
                }
            },
            "handlers": {
                "console": {
                    "class": "logging.StreamHandler",
                    "stream": "ext://sys.stdout"
                }
            }
        }
     }
}
```

At this point you can start the Container through Docker → Containers → select opencanary → Start.

To control how traffic reaches the Honeypot, edit the firewall rules under Network → Firewall and click on Edit for the docker Zone. Specify Input as Drop, Output as accept, Forward as drop. Select MSS clamping and allow forwarding to the `lan` zone. Leave everything else with defaults and click Save. Now, under Network → Firewall → Port forwards click on Add. Name the rule “ftp honeypot”, source zone `lan`, external port 21, destination zone “docker” and write the container's IP into the custom field (for example 172.17.0.2). The first time you add a rule for your honeypot the container's IP won't be in the list, in subsequent firewall rules you should be able to find it in the list.

If you are not sure which IP is your honeypot's IP, go to Docker → Containers → click on Edit next to the opencanary container. Now under the “Inspect” tab you can see the detailed configuration of your container, that will list the IP (for example, “IPAddress”: “172.17.0.2”).

You can verify your honeypot is working at this point by try to connect to OpenWrt's IP address from the lan on port 21. You can find the containers log at Docker → Containers → click on Edit next to the opencanary container. Under the Logs tab you should see something like “stdout: {“dst\_host”: “172.17.0.2”, “dst\_port”: 21, “local\_time”: “2024-03-14 15:05:16.064212”, “local\_time\_adjusted”: “2024-03-14 15:05:16.064348”, “logdata”: {“PASSWORD”: “test”, “USERNAME”: “test”}, “logtype”: 2000, “node\_id”: “openwrt”, “src\_host”: “192.168.1.232”, “src\_port”: 30266, “utc\_time”: “2024-03-14 15:05:16.064305”}” for every FTP connection that happened to the honeypot.

OpenCanary has a wide variety of honeypots you can deploy. For each new honeypot you configure make sure you setup the corresponding Port forward rule. It is also recommended to [configure e-mail alerts](https://opencanary.readthedocs.io/en/latest/alerts/email.html "https://opencanary.readthedocs.io/en/latest/alerts/email.html") in the OpenCanary configuration as checking the docker container logs manually is far from ideal.

## Making honeypots appear on other IPs

So far we've deployed honeypot services that appeared as open ports on the router's IP. You can also make the OpenCanary honeypots appear on other IPs on your lan so they look more real. To do this you have to configure a new interface to listen to additional IP addresses. Go to Network → Interfaces → Add new interface. Name it according to the service it will provide, for example honeypot-ftp and under Protocol choose “Static address” and for device “Alias interface @lan”. Click “Create interface”. In the next settings menu specify the IP Address, for example 192.168.1.22 and netmask 255.255.255.255 (ie. /32). Under firewall settings place this interface into the lan zone.

Now go to Network → Firewall → Port forwards and create a new rule by clicking Add. Enter the port the honeypot will listen to (for example 21), Source zone is lan and destination zone is docker, destination IP is the opencanary container's IP. Now click on Advanced and under External IP Address select the new IP address you created (192.168.1.22 for example). Click Save and then Save &amp; Apply. Now the new IP will only listen to connections to the honeypots.

## Dropping WiFi clients that connect to honeypots

It is possible to integrate OpenCanary more tightly with the services OpenWrt provides. For example, we can automatically drop WiFi clients that attempt to connect to honeypot services. OpenCanary provides a WebHook alert capability that can be used to call into OpenWrt's [RPC daemon system](/docs/techref/rpcd "docs:techref:rpcd").

We'll create a new rpcd service that listens for OpenCanary WebHooks, look up the offending IP address and adding it's MAC address to each WiFi interface's MAC blacklist. First, go to Network → Wireless and click on Edit for your WiFi interface. Under the MAC filter tab select “Allow all except listed”.

Now create the file /usr/libexec/rpcd/opencanary with the following content, make sure to change AUTH\_TOKEN to something unique:

[/usr/libexec/rpcd/opencanary](/_export/code/docs/guide-user/services/honeypots?codeblock=1 "Download Snippet")

```
#!/bin/sh
 
AUTH_TOKEN="specify_a_unique_string_here"
 
. /lib/functions.sh
. /usr/share/libubox/jshn.sh
 
case "$1" in
        list)
                echo '{ "add": { "magic": "str", "message": "str" } }'
        ;;
        call)
                case "$2" in
                        add)
                                # read the arguments
                                read -r input;
                                json_load "$input"
                                json_get_var message "message"
                                json_get_var magic "magic"
                                json_cleanup
 
                                [[ "${magic}" != "${AUTH_TOKEN}" ]] && echo '{"opencanary":"denied"}' && exit 0
                                [[ -z "${message}" ]] && echo '{"opencanary":"invalid message"}' && exit 0
 
                                logger -t "opencanary" "$message"
 
                                json_load "$message"
                                json_get_var ip "src_host"
                                json_cleanup
 
                                [[ -z "${ip}" ]] && exit 0
 
                                mac=$(cat /proc/net/arp | grep "${ip} " | head -n1 | awk '{ print $4 }')
 
                                [[ -z "${mac}" ]] && echo '{"opencanary":"invalid mac"}' && exit 0
 
                                # log the call
                                logger -t "opencanary quarantine" "$ip" "$mac"
 
                                # quarantine the mac
                                for iface in default_radio0 default_radio1 # List all affected wifi-ifaces here
                                do
                                        uci add_list wireless."$iface".maclist="$mac"
                                done
 
                                uci commit wireless
                                wifi
                        ;;
                esac
        ;;
esac
```

To make this script accessible through OpenWrt's [REST API with UBUS](/docs/techref/ubus#access_to_ubus_over_http "docs:techref:ubus") we need to create an authorization so this interface can be called by our container. We can't easily make OpenCanary authanticate itself according the regular UBUS authentication schemes, so the interface requires a “magic” field to be passed by the caller, which is effectively the authorization token to interact with the interface (the magic &amp; AUTH\_TOKEN variables in the previous script).

Create the file `/usr/share/rpcd/acl.d/opencanary.json` with the following content:

[/usr/share/rpcd/acl.d/opencanary.json](/_export/code/docs/guide-user/services/honeypots?codeblock=2 "Download Snippet")

```
{
        "unauthenticated": {
                "description": "Allow access to OpenCanary script",
                "read": {
                        "ubus": {
                                "opencanary": [ "add" ]
                        }
                }
        }
}
```

This method allows anyone to call the interface but only with the correct MAGIC tag will the interface do anything. Now add the following to the OpenCanary configuration:

```
    "logger": {
        "class": "PyLogger",
        "kwargs": {
            "formatters": {
                "plain": {
                    "format": "%(message)s"
                }
            },
            "handlers": {
                "console": {
                    "class": "logging.StreamHandler",
                    "stream": "ext://sys.stdout"
                },
                "Webhook": {
                        "class": "opencanary.logger.WebhookHandler",
                        "url": "https://172.17.0.1/ubus",
                        "method": "POST",
                        "data": { "jsonrpc": "2.0", "id": 1, "method": "call", "params": ["00000000000000000000000000000000", "opencanary", "add",{"magic":"specify_a_unique_string_here", "message": "%(message)s"}] },
                        "status_code": 200,
                        "verify": false,
                        "headers": { "Content-Type": "application/json" }
                }
            }
        }
    }
```

Make sure you have OpenWrt's IP in the url field as seen from inside the docker container and that you specify the AUTH\_TOKEN string you have in the rpcd script in the “magic” field.

Add a firewall traffic rule under Network → Firewall → Traffic rules. Name: opencanary webhook, Source zone: docker, source address: container's IP (for example 172.17.0.2), destination zone: Input, destination IP: openwrt's IP (for example 172.17.0.1), destination port: 443, action: accept.

Restart rpcd with `/etc/init.d/rpcd restart` and then restart the OpenCanary container. Now connection attempts to the honeypots will show up in the OpenWrt system log and offending clients from WiFi network will automatically be added to the MAC blacklist.
