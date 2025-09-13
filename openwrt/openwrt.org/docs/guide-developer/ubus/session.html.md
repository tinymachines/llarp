# ubus session

Path Procedure Signature Description `session` `create` `{ “timeout”: timeout }` Create a new session and return its ID, set the session timeout to `timeout` in seconds (set `0` for no expire) `session` `list` `{ “ubus_rpc_session”: “sid” }` Dump session info specified by `sid`, if no ID is given, list all sessions `session` `grant` `{ “ubus_rpc_session”: “sid”, “scope”: “scope”, “objects”: [ [ “path”, “func” ], ... ] }` Within the session identified by `sid` grant access to all specified procedures `func` in the namespace `path` listed in the `objects` array `session` `revoke` `{ “ubus_rpc_session”: “sid”, “scope”: “scope”, “objects”: [ [ “path”, “func” ], ... ] }` Within the session identified by `sid` revoke access to all specified procedures `func` in the namespace `path` listed in the `objects` array. If `objects` is unset, revoke all access `session` `access` `{ “ubus_rpc_session”: “sid”, “scope”: “scope”, “object”: “path”, “function”: “function” }` Query whether access to the specified `function` in the namespace `path` is allowed `session` `set` `{ “ubus_rpc_session”: “sid”, “values”: { “key”: value, ... } }` Within the session identified by `sid` store the given arbitrary values under their corresponding keys specified in the `values` object `session` `get` `{ “ubus_rpc_session”: “sid”, “keys”: [ “key”, ... ] }` Within the session identified by `sid` retrieve all values associated with the given keys listed in the `keys` array. If the key array is unset, dump all key/value pairs `session` `unset` `{ “ubus_rpc_session”: “sid”, “keys”: [ “key”, ... ] }` Within the session identified by `sid` unset all keys listed in the `keys` array. If the key list is unset, clear all keys `session` `destroy` `{ “ubus_rpc_session”: “sid” }` Terminate the session identified by the given ID `sid` `session` `login` `{ “username”: “username”, “password”: “password”, “timeout”: timeout }` Authenticate with rpcd and create a new session with access rights as specified in the ACLs

**Note:** When using ubus over HTTP, setting `ubus_rpc_session` isn't allowed, it's automatically set to the calling session.

**Note:** Sessions are stored in memory so they will persist as long as `rpcd` is running

### login call description

Use `session.login` to authorize and create a new session. The `timeout` argument is optional, it is set in seconds and by default is 5 minutes (300 seconds). The session timeout is automatically reset on every use.

Return example:

```
{
        "ubus_rpc_session": "948abf19b632c5460384315d69010e09",
        "timeout": 300,
        "expires": 299,
        "acls": {
                "access-group": {
                        "uci-access": [
                                "read",
                                "write"
                        ],
                        "unauthenticated": [
                                "read"
                        ]
                },
                "ubus": {
                        "file": [
                                "*"
                        ],
                        "session": [
                                "access",
                                "login"
                        ]
                },
                "uci": {
                        "*": [
                                "read",
                                "write"
                        ]
                }
        },
        "data": {
                "username": "root"
        }
}
```

To list all active sessions call `session list`.

### Example of manual session creation

Create a session then grant access to all functions of `file` and to the `board` object function of `system` object. Also set a custom attribute `username` to `alice` then check if the sid have an access to `system.reboot` function (and there is npo such access)

```
root@OpenWrt:~# ubus call session create '{"timeout": 3600}'
{
        "ubus_rpc_session": "8c1af812b4b148fcbb92434c74cf61c1",
        "timeout": 3600,
        "expires": 3600,
        "acls": {

        },
        "data": {

        }
}
root@OpenWrt:~# ubus call session grant '{"ubus_rpc_session": "bf11e5cd01cd262ae692600a6a45ccfc", "scope": "write", "objects": [["file", "*"], ["system", "board"]]}'
root@OpenWrt:~# ubus call session set '{"ubus_rpc_session": "bf11e5cd01cd262ae692600a6a45ccfc", "values": { "username": "alice" } }'
root@OpenWrt:~# ubus call session list '{"ubus_rpc_session": "bf11e5cd01cd262ae692600a6a45ccfc"}'
{
        "ubus_rpc_session": "bf11e5cd01cd262ae692600a6a45ccfc",
        "timeout": 3600,
        "expires": 3600,
        "acls": {
                "ubus": {
                        "file": [
                                "*"
                        ],
                        "system": [
                                "board"
                        ]
                }
        },
        "data": {
                "username": "alice"
        }
}
root@OpenWrt:~# ubus call session access '{ "ubus_rpc_session": "bf11e5cd01cd262ae692600a6a45ccfc", "scope": "ubus", "object": "system", "function": "reboot" }'
{
        "access": false
}
```
