# SIP daemon for Lantiq devices with owsip

The aim of this project is to provide a working [SIP](https://en.wikipedia.org/wiki/Session%20Initiation%20Protocol "https://en.wikipedia.org/wiki/Session Initiation Protocol") daemon for [Lantiq SoCs](/docs/techref/hardware/soc/soc.lantiq "docs:techref:hardware:soc:soc.lantiq") with MIPS CPU.

owsip utilizes available [FXS](https://en.wikipedia.org/wiki/Foreign%20exchange%20service%20%28telecommunications%29 "https://en.wikipedia.org/wiki/Foreign exchange service (telecommunications)") hardware ports for making calls.

## Known Problems / missing features

- fails to work on units with more than 32MiB RAM
- only the primary voice channel works
- handling for incoming calls, while making calls does not exist
- missing answering machine
- missing fax
- missing srtp/ssl login
- missing kpi - kernel acceleration

## Using owsip

Once owsip is only and registered you can start to make and answer calls. SIP can dial landline and sip numbers. Currently a number dialed on a key pad is interpreted as a landline. If you want to call a sip account, you need to add a contact entry for this. To dial a contact, simply press the “\*” key followed by the “code” sequence. Note that owsip can do keypad letter → number conversion (for example → 3926753).

The “#” key is also mapped to handle dial backends, however “contact” is the only backend we currently have. it is mapped to “#1code”.

### Common Options

Name Type Required Default Description `name` string yes owsip the daemon announces this name `backend` string yes ltq\_tapi tell the daemon which backend to use `log_level` int yes 3 verbosity `interface` string yes nas0 bound to this interface, if unsure use nas0 `local_port` int yes 5060 define port for SIP `rtp_port` int yes 4000 define port for RTP `outbound` string no *(none)* outbound proxy server, define like &lt;sip:192.168.1.1:9060;lr;transport=udp&gt; `cid` string no *(none)* enable support for CID. Possible valued: telecordia, etsi\_fsk, etsi\_dtmf, sin, ntt, kpn\_dtmf and kpn\_dtmf\_fsk `locale` string no *(none)* currently supporting only germany and croatia `revert` int no 0 switch FXS port0 ↔ port1 (work around 2nd port not working)

### STUN Section

This section describes our STUN server.

Name Type Required Default Description `host` string no *(none)* STUN host `port` int no *(none)* STUN port

### Account Section

This section describes our SIP credentials/server.

Name Type Required Default Description `realm` string yes *(none)* SIP realm to connect to `username` string yes *(none)* SIP username `password` string yes *(none)* SIP password `disabled` string no 0 by default accounts are enabled `port` int yes -1 bind account to a specific port `default` int no 0 use account as default one

### Port Section

This section describes a physical FXS port.

Name Type Required Default Description `id` int yes 0 the physical port described by the section `noring` int no 0 if set to 1 the phone will never ring `nodial` int no 0 if set to 1 then port may not dial numbers `led` string no *(none)* set to sysfs path of the led matching the port

### Contact Section

This section describes a contact for short dial.

Name Type Required Default Description `desc` string yes *(none)* the name of the contact `code` string yes *(none)* the short dial code to match (0-9a-zA-Z) `dial` string yes *(none)* the actual number to dial `type` string yes *(none)* sip/realm `account` string no *(none)* the account to use when making the call

### Relay Section

This section describes a relay on the pcb that activates the fxs port

Name Type Required Default Description `gpio` int yes *(none)* gpio to use `value` int yes *(none)* value to set gpio to

### Configuration

The owsip configuration file is located at /etc/conf/telephony. This is the default configuration:

```
config general
        option 'name'           'owsip'
        option 'backend'        'ltq_tapi'
        option 'ossdev'         0
        option 'log_level'      3
        option 'interface'      'nas0'
        option 'local_port'     5060
        option 'rtp_port'       4000
        option 'locale'         'germany'
        option 'revert'         0

config account 'fxs1'
        option 'realm'          'myrealm1.com'
        option 'username'       'myuser1'
        option 'password'       'mypass1'
        option 'disabled'       1

config account 'fxs2'
        option 'realm'          'myrealm2.com'
        option 'username'       'myuser2'
        option 'password'       'mypass2'
        option 'disabled'       1

config stun
        option 'host'           'stun.myrealm.com'
        option 'port'           '3478'

config 'relay' 'relay_31'
        option 'gpio'           '31'
        option 'value'          '1'

config 'port' 'port0'
        option 'id'             '0'
        option 'led'            'soc:green:fxs1'
        option 'noring'         '0'
        option 'nodial'         '0'

config 'contact'
        option 'desc'           'example contact description'
        option 'code'           'example'
        option 'dial'           '0123456789'
        option 'type'           'realm'
```
