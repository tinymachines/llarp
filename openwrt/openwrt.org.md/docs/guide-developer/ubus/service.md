# ubus service

**Package: procd**

`service` used by init scripts as well to register new services

Path Procedure Signature Description `service` `set` `{“name”:“String”,“script”:“String”,“instances”:“Table”,“triggers”:“Array”,“validate”:“Array”,“autostart”:“Boolean”,“data”:“Table”}` \*TODO* `service` `add` `{“name”:“String”,“script”:“String”,“instances”:“Table”,“triggers”:“Array”,“validate”:“Array”,“autostart”:“Boolean”,“data”:“Table”}` \*TODO* `service` `list` `{“name”:“String”,“verbose”:“Boolean”}` Return a list of all services and their instances. Can be filtered by name `service` `delete` `{“name”:“String”,“instance”:“String”}` Delete instance of a service `service` `update_start` `{“name”:“String”}` \*TODO* `service` `event` `{“type”:“String”,“data”:“Table”}` \*TODO* `service` `validate` `{“package”:“String”,“type”:“String”,“service”:“String”}` \*TODO* `service` `get_data` `{“name”:“String”,“instance”:“String”,“type”:“String”}` \*TODO* `service` `state` `{“spawn”:“Boolean”,“name”:“String”}` \*TODO*
