# Setting up usteer and band-steering

[usteer](https://git.openwrt.org/project/usteer.git "https://git.openwrt.org/project/usteer.git") is a daemon for sharing wifi client information amongst APs on the same network, and can be used for band steering.

This can be useful for improved WiFi performance when you have a network with multiple APs. Especially on EAP networks, it is highly recommended to set up [802.11r](/docs/guide-user/network/wifi/basic#fast_bss_transition_options_80211r "docs:guide-user:network:wifi:basic") also.

## WiFi Roaming

An summary of WiFi roaming technologies can be found on the [roaming](/docs/guide-user/network/wifi/roaming "docs:guide-user:network:wifi:roaming") page.

## Prerequisites

The following items are prerequisite to set up usteer:

- One or more OpenWrt based APs (and routers)
- install the full version of wpad
- usteer package installed on each

## Setting up usteer

To set up usteer:

- configure 802.11k and 802.11v on all WiFi AP-nodes.
- install and configure required packages for usteer
- reboot all nodes (or just restart the network if no wpad packages have been changed).

### Configure 802.11k and 802.11v on all AP-nodes

SSH into each of your wifi/AP nodes and add the following config-lines in `/etc/config/wireless` to each of your SSIDs:

```
      option bss_transition '1'
      option ieee80211k '1'
```

### Install and configure required packages

We need to install usteer. This is as simple as:

```
 opkg update && opkg install usteer
```

At this point you have all the packages you need, but they may be in need of additional configuration.

### Configuring usteer

usteer's config-file */etc/config/usteer* specifies which interface it will listen on for other nodes. By default this is *lan*.

#### Config options

Name Type Required Default Description *network* string yes *lan* The network interface for inter-AP communication *syslog* boolean yes 1 Log messages to syslog (0/1) *ipv6* boolean yes 0 Use IPv6 for remote exchange *debug\_level* integer yes 2 Minimum level of logged messages. 0 = Fatal, 1 = Info, 2 = Verbose, 3 = some debug messages, 4 = network packet information, 5 = all debug messages *max\_neighbour\_reports* integer no 8 Maximum number of neighbor reports set for a node *sta\_block\_timeout* integer no 30000 Maximum amount of time (ms) a station may be blocked due to policy decisions *local\_sta\_timeout* integer no 120000 Maximum amount of time (ms) a local unconnected station is tracked *measurement\_report\_timeout* integer no 120000 Maximum amount of time (ms) a measurement report is stored *local\_sta\_update* integer no 1000 Local station information update interval (ms) *max\_retry\_band* integer no 5 Maximum number of consecutive times a station may be blocked by policy *seen\_policy\_timeout* integer no 30000 Maximum idle time of a station entry (ms) to be considered for policy decisions *load\_balancing\_threshold* integer no 0 Minimum number of stations delta between APs before load balancing policy is active *band\_steering\_threshold* integer no 5 Minimum number of stations delta between bands before band steering policy is active. Only used if [load\_balancing\_threshold is set](https://github.com/openwrt/usteer/blob/e218150979b40a1b3c59ad0aaa3bbb943814db1e/policy.c#L32-L33 "https://github.com/openwrt/usteer/blob/e218150979b40a1b3c59ad0aaa3bbb943814db1e/policy.c#L32-L33"). *remote\_update\_interval* integer no 1000 Interval (ms) between sending state updates to other APs *remote\_node\_timeout* integer no 10 Number of remote update intervals after which a remote-node is deleted *assoc\_steering* boolean no 0 Allow rejecting assoc requests for steering purposes (0/1) *probe\_steering* boolean no 0 Allow ignoring probe requests for steering purposes (0/1) *min\_connect\_snr* integer no 0 Minimum signal-to-noise ratio or signal level (dBm) to allow connections *min\_snr* integer no *0* Minimum signal-to-noise ratio or signal level (dBm) to remain connected *min\_snr\_kick\_delay* integer no 5000 Timeout after which a station with snr &lt; min\_snr will be kicked *roam\_process\_timeout* integer no 5000 Timeout (in ms) after which a association following a disassociation is not seen as a roam *roam\_scan\_snr* integer no 0 Minimum signal-to-noise ratio or signal level (dBm) before attempting to trigger client scans for roam *roam\_scan\_tries* integer no 3 Maximum number of client roaming scan trigger attempts *roam\_scan\_timeout* integer no 0 Retry scanning when roam\_scan\_tries is exceeded after this timeout (in ms). In case this option is set to 0, the client is kicked instead *roam\_scan\_interval* integer no 10000 Minimum time (ms) between client roaming scan trigger attempts *roam\_trigger\_snr* integer no 0 Minimum signal-to-noise ratio or signal level (dBm) before attempting to trigger forced client roaming *roam\_trigger\_interval* integer no 60000 Minimum time (ms) between client roaming trigger attempts *roam\_kick\_delay* integer no 100 Timeout (in 100ms beacon intervals) for client roam requests *signal\_diff\_threshold* integer no 0 Minimum signal strength difference until AP steering policy is active *initial\_connect\_delay* integer no 0 Initial delay (ms) before responding to probe requests (to allow other APs to see packets as well) *load\_kick\_enabled* boolean no 0 Enable kicking client on excessive channel load (0/1) *load\_kick\_threshold* integer no 75 Minimum channel load (%) before kicking clients *load\_kick\_delay* integer no 10000 Minimum amount of time (ms) that channel load is above threshold before starting to kick clients *load\_kick\_min\_clients* integer no 10 Minimum number of connected clients before kicking based on channel load *load\_kick\_reason\_code* integer no 5 Reason code on client kick based on channel load (default: WLAN\_REASON\_DISASSOC\_AP\_BUSY) *band\_steering\_interval* integer no 120000 Attempting to steer clients to a higher frequency-band every n ms. A value of 0 disables band-steering. *band\_steering\_min\_snr* integer no -60 Minimal SNR or absolute signal a device has to maintain over band\_steering\_interval to be steered to a higher frequency band. *link\_measurement\_interval* integer no 30000 Interval (ms) the device is sent a link-measurement request to help assess the bi-directional link quality. Setting the interval to 0 disables link-measurements. *node\_up\_script* string no *blank* Script to run after bringing up a node *event\_log\_types* list no *blank* Message types to include in log. Available types: probe\_req\_accept probe\_req\_deny, auth\_req\_accept, auth\_req\_deny, assoc\_req\_accept, assoc\_req\_deny, load\_kick\_trigger, load\_kick\_reset, load\_kick\_min\_clients, load\_kick\_no\_client, load\_kick\_client, signal\_kick *ssid\_list* list no *blank* List of SSIDs to enable steering on

After making any change, reload usteer:

```
  /etc/init.d/usteer reload
```

Again, do this on all nodes in your network.

#### Config recommendation

The default settings are best most environments but many users overdo optimizations. The following settings are enough to support roaming and band steering.

- roam\_scan\_snr '-65'
- signal\_diff\_threshold '8'

#### Config gotchas

- For AP steering to take effect, *signal\_diff\_threshold* needs to be set to a value greater than 0.
- *roam\_scan\_snr* needs to be set to trigger client scans for roaming.
- If *roam\_scan\_snr* is unset and *roam\_trigger\_snr* is set, then *roam\_scan\_snr* will take the value of *roam\_trigger\_snr*.
- *band\_steering\_threshold* and *load\_balancing\_threshold* is used during roaming to optimize selection of the target AP as it adds additional parameters to RSSI comparison. It is not related to band steering feature that's move a sticky client from 2,4Ghz to 5Ghz.
- *band\_steering\_threshold* does not take effect unless *load\_balancing\_threshold* is also set to a value greater than 0.

### LuCI

If you prefer to configure usteer using Luci, there is one app available:

```
  opkg update && opkg install luci-app-usteer
```

The app shows too information about nodes, clients, signal, etc. that can help to adjust correctly the configuration of usteer and verify that is working correctly.

### Issues with Intel Wifi cards and potentially other vendors

According to the [OpenWrt development mailing list](https://forum.openwrt.org/t/bss-transition-request-ignored-by-intel-ax201wifi-card-client/210537 "https://forum.openwrt.org/t/bss-transition-request-ignored-by-intel-ax201wifi-card-client/210537"), some devices (like some Intel Wifi cards, Apple devices) tends to ignore roaming requests as the current implementation of Usteer sends no disassociation timer in the transition frame. The transition requests is handled like a tip not like a request. If you experience your computer sticks to access points and/or frequencies you can think of using [dawn](/docs/guide-user/network/wifi/dawn "docs:guide-user:network:wifi:dawn") until the fix is merged into the main repository.

### Ubus interface

usteer has a ubus interface that can be accessed by:

```
  ubus call usteer <command> [args]
```

#### Ubus commands

Name Arguments Description *local\_info* none Prints local wifi network information *remote\_hosts* none Prints information about remote usteer instances *remote\_info* none Prints remote wifi network information (same as *local\_info*, but for remote APs) *connected\_clients* none Prints clients that are connected to local wifi interfaces *get\_clients* none Prints all clients from all APs (local and remote) *get\_client\_info* MAC address (json) Prints information about a specific client, including capabilities and information about roaming attempts *get\_config* none Prints the local configuration *set\_config* yes (json) *Details required* *update\_config* yes (json) *Details required* *set\_node\_data* yes (json) *Details required* *delete\_node\_data* yes (json) *Details required*

#### local\_info

```
root@AccessPoint:~# ubus call usteer local_info
{
	"hostapd.wlan1-1": {
		"bssid": "11:22:33:44:55:66",
		"freq": 2412,
		"n_assoc": 0,
		"noise": -95,
		"load": 5,
		"max_assoc": 0,
		"roam_events": {
				"source": 0,
				"target": 0
		},
		"rrm_nr": [
			"11:22:33:44:55:66",
			"OpenWrtSSID",
			"<hex string>"
		]
	}
}
```

#### remote\_hosts

```
root@AccessPoint:~# ubus call usteer remote_hosts
{
      "192.168.1.1": {
		"id": -525792052
      }
}
```

#### remote\_info

```
root@AccessPoint:~# ubus call usteer remote_info
{
      "192.168.1.1#hostapd.wlan0": {
		"bssid": "11:22:33:44:55:66",
		"freq": 5180,
		"n_assoc": 6,
		"noise": -107,
		"load": 3,
		"max_assoc": 0,
		"roam_events": {
			"source": 0,
			"target": 0
		},
		"rrm_nr": [
			"11:22:33:44:55:66",
			"OpenWrtSSID 5GHz",
			"<hex string>"
		]
      },
      "192.168.1.1#hostapd.wlan1": {
		"bssid": "11:22:33:44:55:67",
		"freq": 2412,
		"n_assoc": 7,
		"noise": -90,
		"load": 13,
		"max_assoc": 0,
		"roam_events": {
			"source": 0,
			"target": 0
		},
		"rrm_nr": [
			"11:22:33:44:55:67",
			"OpenWrtSSID",
			"<hex string>"
		]
      }
}
```

#### connected\_clients

```
root@AccessPoint:~# ubus call usteer connected_clients
{
      "hostapd.wlan0": {
		"aa:bb:cc:dd:ee:ff": {
			"signal": -91,
			"created": 604990289,
			"seen": 610827895,
			"last_connected": 610827895,
			"snr-kick": {
				"seen-below": 0
			},
			"load-kick": {
				"count": 0
			},
			"roam-state-machine": {
				"tries": 0,
				"event": 0,
				"kick": 0,
				"scan_start": 0,
				"scan_timeout_start": 0
			},
			"bss-transition-response": {
				"status-code": 0,
				"timestamp": 0
			},
			"beacon-measurement-modes": [
				
			],
			"bss-transition-management": false,
			"measurements": [
				
			]
		},
		...
		"aa:bb:cc:dd:ee:fe": {
			"signal": -81,
			"created": 600282172,
			"seen": 610827895,
			"last_connected": 610827895,
			"snr-kick": {
				"seen-below": 0
			},
			"load-kick": {
				"count": 0
			},
			"roam-state-machine": {
				"tries": 0,
				"event": 0,
				"kick": 0,
				"scan_start": 0,
				"scan_timeout_start": 0
			},
			"bss-transition-response": {
				"status-code": 0,
				"timestamp": 0
			},
			"beacon-measurement-modes": [
				
			],
			"bss-transition-management": false,
			"measurements": [
				
			]
		}
      },
      "hostapd.wlan1": {
		"aa:bb:cc:dd:ee:fd": {
			"signal": -58,
			"created": 600282173,
			"seen": 610827901,
			"last_connected": 610827896,
			"snr-kick": {
				"seen-below": 0
			},
			"load-kick": {
				"count": 0
			},
			"roam-state-machine": {
				"tries": 0,
				"event": 0,
				"kick": 0,
				"scan_start": 0,
				"scan_timeout_start": 0
			},
			"bss-transition-response": {
				"status-code": 0,
				"timestamp": 0
			},
			"beacon-measurement-modes": [
				
			],
			"bss-transition-management": false,
			"measurements": [
				
			]
		}
      }
}
```

#### get\_clients

```
root@AccessPoint:~# ubus call usteer get_clients
{
	"aa:bb:cc:dd:ee:ff": {
		"192.168.1.1#hostapd.wlan0": {
			"connected": true,
			"signal": -77
		}
	},
	...
	"aa:bb:cc:dd:ee:fe": {
		"192.168.1.1#hostapd.wlan1": {
			"connected": false,
			"signal": -74
		},
		"hostapd.wlan1-1": {
			"connected": false,
			"signal": -86
		}
	},
	"aa:bb:cc:dd:ee:fd": {
		"192.168.1.1#hostapd.wlan0": {
			"connected": false,
			"signal": -70
		},
		"192.168.1.1#hostapd.wlan1": {
			"connected": false,
			"signal": -81
		},
		"hostapd.wlan1-1": {
			"connected": false,
			"signal": -76
		}
	},
	...
	"aa:bb:cc:dd:ee:fc": {
		"hostapd.wlan0": {
			"connected": true,
			"signal": -74
		}
	}
}
```

#### get\_client\_info

A host that is connected locally

```
root@AccessPoint:~# ubus call usteer get_client_info "{'address':'aa:bb:cc:dd:ee:ff'}"
{
	"2ghz": true,
	"5ghz": true,
	"nodes": {
		"hostapd.wlan0": {
			"connected": true,
			"signal": -54,
			"stats": {
				"probe": {
					"requests": 5,
					"blocked_cur": 0,
					"blocked_total": 0
				},
				"assoc": {
					"requests": 5,
					"blocked_cur": 0,
					"blocked_total": 0
				},
				"auth": {
					"requests": 5,
					"blocked_cur": 0,
					"blocked_total": 0
				}
			}
		}
	}
}
```

A host that is connected remotely

```
root@AccessPoint:~# ubus call usteer get_client_info "{'address':'aa:bb:cc:dd:ee:fe'}"
{
	"2ghz": true,
	"5ghz": false,
	"nodes": {
		"192.168.1.32#hostapd.wlan1": {
			"connected": true,
			"signal": -38,
			"stats": {
				"probe": {
					"requests": 0,
					"blocked_cur": 0,
					"blocked_total": 0
				},
				"assoc": {
					"requests": 0,
					"blocked_cur": 0,
					"blocked_total": 0
				},
				"auth": {
					"requests": 0,
					"blocked_cur": 0,
					"blocked_total": 0
				}
			}
		}
	}
}
```

#### get\_config

```
root@AccessPoint:~# ubus call usteer get_config
{
	"syslog": true,
	"debug_level": 2,
	"ipv6": true,
	"local_mode": false,
	"sta_block_timeout": 30000,
	"local_sta_timeout": 120000,
	"local_sta_update": 1000,
	"max_neighbor_reports": 8,
	"max_retry_band": 5,
	"seen_policy_timeout": 30000,
	"measurement_report_timeout": 120000,
	"load_balancing_threshold": 0,
	"band_steering_threshold": 5,
	"remote_update_interval": 5000,
	"remote_node_timeout": 12,
	"assoc_steering": false,
	"min_connect_snr": 0,
	"min_snr": 0,
	"min_snr_kick_delay": 5000,
	"steer_reject_timeout": 60000,
	"roam_process_timeout": 5000,
	"roam_scan_snr": 0,
	"roam_scan_tries": 3,
	"roam_scan_timeout": 0,
	"roam_scan_interval": 10000,
	"roam_trigger_snr": 0,
	"roam_trigger_interval": 60000,
	"roam_kick_delay": 10000,
	"signal_diff_threshold": 0,
	"initial_connect_delay": 0,
	"load_kick_enabled": false,
	"load_kick_threshold": 75,
	"load_kick_delay": 10000,
	"load_kick_min_clients": 10,
	"load_kick_reason_code": 5,
	"band_steering_interval": 20000,
	"band_steering_min_snr": -60,
	"link_measurement_interval": 30000,
	"interfaces": [
		"mesh0",
		"mesh1"
	],
	"event_log_types": [
		
	],
	"ssid_list": [
		"OpenWrtSSID",
		"OpenWrtSSID 5GHz"
	]
}
```

#### set\_config

```
Details required
```

#### update\_config

```
Details required
```

#### set\_node\_data

```
Details required
```

#### delete\_node\_data

```
Details required
```
