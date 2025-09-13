# ubus uci

**Package: rpcd**

```
# ubus -v list uci
'uci' @4eb774a8
	"configs":{}
	"get":{"config":"String","section":"String","option":"String","type":"String","match":"Table","ubus_rpc_session":"String"}
	"state":{"config":"String","section":"String","option":"String","type":"String","match":"Table","ubus_rpc_session":"String"}
	"add":{"config":"String","type":"String","name":"String","values":"Table","ubus_rpc_session":"String"}
	"set":{"config":"String","section":"String","type":"String","match":"Table","values":"Table","ubus_rpc_session":"String"}
	"delete":{"config":"String","section":"String","type":"String","match":"Table","option":"String","options":"Array","ubus_rpc_session":"String"}
	"rename":{"config":"String","section":"String","option":"String","name":"String","ubus_rpc_session":"String"}
	"order":{"config":"String","sections":"Array","ubus_rpc_session":"String"}
	"changes":{"config":"String","ubus_rpc_session":"String"}
	"revert":{"config":"String","ubus_rpc_session":"String"}
	"commit":{"config":"String","ubus_rpc_session":"String"}
	"apply":{"rollback":"Boolean","timeout":"Integer","ubus_rpc_session":"String"}
	"confirm":{"ubus_rpc_session":"String"}
	"rollback":{"ubus_rpc_session":"String"}
	"reload_config":{}
```

The “ubus uci” section of this documentation is severely outdated and incomplete. It is only useful nowadays as a starting point for someone to actually rewrite it to match reality.

Path Procedure Signature Description `uci` `configs` `{ }`

List all available configs

Example:

```
# ubus call uci configs '{"ubus_rpc_session":"2db687f321a60414e77677bbb5dd6d6f"}'
{
	"configs": [
		"dhcp",
		"dropbear",
		"firewall",
		"luci",
		"network",
		"radius",
		"rpcd",
		"system",
		"ubootenv",
		"ucitrack",
		"uhttpd",
		"wireless"
	]
}
```

`uci` `get` `{ “config”: “config”, “section”: “sname”, “type”: “type”, “option”: “oname” }`

Return the requested uci value(s), all arguments are optional.

1. When called without argument or with empty object: return an array of package names in the `configs` field
2. When called with `config` set: return an object containing all sections containing all options in a field named after the package
3. When called with `config` and `type` set: return an object containing all sections of type `type` containing all options in a field named after the package
4. When called with `config` and `sname` set: return an object containing all options of the section in a field named after the section
5. When called with `config` and `type` and `oname` set: return an object containing the value of each option named `oname` within a section of type `type` in a field named after the matched section
6. When called with `package` and `sname` and `oname` set: return the result string in a field named `oname` in case of options or an array of result strings in a field named `oname` in case of list options

Return messages:

1. `{ “config”: { “sname1”: { “.type”: “type1”, “option1”: “value1”, “option2”: [ “value2.1”, ... ], ... }, ... } }`
2. `{ “config”: { “sname1”: { “.type”: “type”, “option1”: “value1”, “option2”: [ “value2.1”, ... ], ... }, ... } }`
3. `{ “sname”: { “.type”: “type”, “option1”: “value1”, “option2”: [ “value2.1”, ... ], ... } }`
4. `{ “sectionname1”: “value1”, “sectionname2”: [ “value2.1”, ... ], ... }`
5. 1. `{ “oname”: “value1” }`
   2. `{ “oname”: [ “value1.1”, ... ] }`

Example:

```
# ubus call uci get '{"ubus_rpc_session":"2db687f321a60414e77677bbb5dd6d6f", "config":"wireless", "section":"wifinet2"}'
{
	"values": {
		".anonymous": false,
		".type": "wifi-iface",
		".name": "wifinet2",
		"device": "radio0",
		"mode": "ap",
		"ssid": "ilwf-guest",
		"encryption": "sae-mixed",
		"key": "XXXX",
		"network": "lan",
		"disabled": "0"
	}
```

`uci` `state` `{ “config”: “config”, “section”: “sname”, “type”: “tname”, “option”: “oname” }` `uci` `set` `{ “config”: “config”, “section”: “sname”, “type”: “tname”, “values”: “array_of_values” }`

Set the given value(s), the option argument is optional.

1. When called with `config` and `sname` and `array_of_values` set: add a new section `sname` in `config` and set it to the type given in `tname`
2. When called with `config` and `sname`, `oname` and `array_of_values` set `array_of_values` as values in `sname`

The call does not produce any data, instead it returns with the following status codes:

1. If there already is a section called `sname`: `UBUS_STATUS_INVALID_ARGUMENT` else: `UBUS_STATUS_OK`
2. If there is no section `sname` or if `value` is neither a string nor an array: `UBUS_STATUS_INVALID_ARGUMENT` else: `UBUS_STATUS_OK`

Example:

```
# ubus call uci set '{"ubus_rpc_session":"2db687f321a60414e77677bbb5dd6d6f", "config":"wireless", "section":"wifinet2", "values":{"disabled":"1"}}'
# ubus call uci get '{"ubus_rpc_session":"2db687f321a60414e77677bbb5dd6d6f", "config":"wireless", "section":"wifinet2"}'
{
	"values": {
		".anonymous": false,
		".type": "wifi-iface",
		".name": "wifinet2",
		"device": "radio0",
		"mode": "ap",
		"ssid": "ilwf-guest",
		"encryption": "sae-mixed",
		"key": "XXXXXXXX",
		"network": "lan",
		"disabled": "1"
	}
}
```

`uci` `add` `{ “config”: “config”, “type”: “type” }`

Add new anonymous section of given type.

1. When called with `config` and `type` set: Add a new anonymous section of type `type`.

Return message:

1. `{ “section”: “sectionname” }`

`uci` `delete` `{ “config”: “config”, “section”: “sname”, “type”: “type”, “option”: “oname” }`

Delete the given value(s) or section(s), the option and type arguments are optional.

1. When called with `config` and `type` set: delete all sections of type `type` in `config`
2. When called with `config` and `sname` set: delete the section named `sname` in `config`
3. When called with `config`, `type` and `oname` set: delete the option named `oname` within each section of type `type` in `package`
4. When called with `config`, `sname` and `oname` set: delete the option named `oname` in section `sname` of `package`

The call does not result in any data, instead it returns the following status codes:

1. If no section of type `type` was found: `UBUS_STATUS_NOT_FOUND` else: `UBUS_STATUS_OK`
2. If no section named `sname` was found: `UBUS_STATUS_NOT_FOUND` else: `UBUS_STATUS_OK`
3. If no options named `oname` within sections of type `type` where found: `UBUS_STATUS_NOT_FOUND` else: `UBUS_STATUS_OK`
4. If the option named `oname` within named section `sname` was not found: `UBUS_STATUS_NOT_FOUND` else: `UBUS_STATUS_OK`

`uci` `rename` `{“config”:“String”,“section”:“String”,“option”:“String”,“name”:“String” }` `uci` `order` `{“config”:“String”,“sections”:“Array” }` `uci` `changes` `{“config”:“String” }` `uci` `revert` `{“config”:“String” }` `uci` `commit` `{“config”:“String” }` `uci` `apply` `{“rollback”:“Boolean”,“timeout”:“Integer” }` `uci` `confirm` `{ }` `uci` `rollback` `{ }` `uci` `reload_config` `{ }`
