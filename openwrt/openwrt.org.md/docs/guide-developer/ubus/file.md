# ubus file

**Package: rpcd**

With plugin `rpcd-mod-file` enabled:

Path Procedure Signature Description `file` `read` `{ “path”: “String”, “base64”: Boolean }` Read a file contents. The file path is encoded in Base64 if the `base64` param set to “true” `file` `write` `{ “path”: “String”, “data”: “String”, “append”: Boolean, “mode”: Integer, “base64”: Boolean }` Write a `data` to a file by `path`. The file path is encoded in Base64 if the `base64` param set to “true”. If the `append` param is “true” then file is not overwritten but the new content is added to the end of the file. The `mode` param if specified represent file permission mode. `file` `list` `{ “path”: “String” }` ? `file` `stat` `{ “path”: “String” }` ? `file` `md5` `{ “path”: “String” }` ? `file` `exec` `{ “command”: “String”, “params”: “Array”, “env”: “Table” }` ?
