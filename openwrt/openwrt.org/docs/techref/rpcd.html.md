# rpcd: OpenWrt ubus RPC daemon for backend server

In OpenWrt we commonly use [ubus](/docs/techref/ubus "docs:techref:ubus") for all kinds of communication. It can provide info from various software as well as request various actions. Nevertheless, not every part of OpenWrt has a daemon that can register itself using `ubus`. For an example `uci` and `opkg` are command-line tools without any background process running all the time.

It would be not efficient to write a daemon for every software like this and run them independently. This is why `rpcd` was developed. It’s a tiny daemon with support for plugins using trivial API. It loads library `.so` files and calls init function of each of them.

The code is published under [ISC license](https://en.wikipedia.org/wiki/ISC_license "https://en.wikipedia.org/wiki/ISC_license") and can be found via git at [https://git.openwrt.org/project/rpcd.git](https://git.openwrt.org/project/rpcd.git "https://git.openwrt.org/project/rpcd.git").

### Default plugins

There are few small plugins distributed with the `rpcd` sources. Two of them (`session` and `uci`) are built-in, others are optional and have to be build as separated `.so` libraries. Apart from that there are other projects providing their own plugins.

## plugin executables

It is possible to expose shell script functionality over ubus by using `rpcd` plugin executables functionality. Executables stored in `/usr/libexec/rpcd/` directory will be run by `rpcd`. Lets look at the following example:

```
mkdir -p /usr/libexec/rpcd
cat << "EOF" > /usr/libexec/rpcd/foo
#!/bin/sh
 
case "$1" in
	list)
		echo '{ "bar": { "arg1": true, "arg2": 32, "arg3": "str" }, "toto": { }, "failme": {} }'
	;;
	call)
		case "$2" in
			bar)
				# read the arguments
				read input;
 
				# optionally log the call
				logger -t "foo" "call" "$2" "$input"
 
				# return json object or an array
				echo '{ "hello": "world" }'
			;;
			toto)
				# return json object
				echo '{ "something": "somevalue" }'
			;;
                        failme)
                                # return invalid
                                echo '{asdf/3454'
                        ;;
		esac
	;;
esac
EOF
chmod +x /usr/libexec/rpcd/foo
service rpcd restart
```

This will create new ubus functions which then can be used (after restarting rpcd):

```
$ ubus -v list foo
'foo' @a9482c5b
	"bar":{"arg1":"Boolean","arg2":"Integer","arg3":"String"}
	"toto":{}
	"failme":{}
 
$ ubus -S call foo bar '{"arg1": true }'
{{"hello":"world"}}
 
$ ubus -S call foo toto
{"something":"somevalue"}
 
$ ubus -S call foo failme
 
$ echo $?
2
```

On startup rpcd will call all executables in `/usr/libexec/rpcd/` with `argv[1]` set to “list”. For a plugin, which responds with a valid list of methods and signatures, ubus method with appropriate arguments will be created. When a method provided by the plugin is about to be invoked, `rpcd` calls the binary with `argv[1]` set to `call` and `argv[2]` set to the invoked method name.

**The actual data is then sent by the `ubus` client via `stdin`.** I.e. if you're testing the script itself, you need to use

```
echo '{"arg1": 42}' | yourscript call yourmethod
```

You *cannot* simply use `yourscript call yourmethod '{“arg1”: 42}`' as you might have expected.

The method signature is a simple object containing `key:value` pairs. The argument type is inferred from the value. If the value is a string (regardless of the contents) it is registered as string, if the value is a bool true or false, its registered as bool, if the value is an integer, it is registered as either int8, int16, int32 or int64 depending on the value i.e. `“foo”: 16` will be `INT16`, `“foo”: 64` will be `INT64`, `“foo”: 8` will be `INT8` and everything else will be `INT32`.

It is enough to issue `service rpcd reload` to make it pick up new plugin executables, that way one does not lose active sessions.

**NOTE:** At least on CC builds, reload is *not* enough, and you must `restart` to pickup new plugins and changes to existing plugins.
