# libubox

It's one of the core libraries used within openwrt because it's a set of utilities, mostly wrappers, that are present usually in programs and that have been coded in a flexible and reusable way to avoid wasting time.

The library consists mostly on independent functionalities, ones higher level than others.

## libubox/utils.h

Simple utility functions. Endian conversion, bitfield operations, compiler attribute wrapping, sequential memory allocation function (calloc\_a), static array size macro, assertion/bug utility function, clock get time wrapper for apple compatibility, base64 encoding decoding.

## libubox/usock.h

This is a really simple library encouraged to be a wrapper to avoid all those socket api library calls. You can create TCP, UDP and UNIX sockets, clients and servers, ipv4/v6 and non/blocking.

The idea is to call usock() and have your fd returned.

## libubox/uloop.h

The most used part. Uloop is a loop runner for i/o. Gets in charge of polling the different file descriptors you have added to it, gets in charge of running timers, and helps you manage child processes. Supports epoll and kqueue as event running backends.

The fd management part is set up with the uloop\_fd struct, just adding the fd and the callback function you want called when an event arises. The rest of the structure is for internal use.

The timeout management part is mostly prepared to do simple things. If you want to do something complex, you might want to have a look at libubox/runqueue.h which implements interesting functionality on top of uloop.

Timeout structure should be initialized with just the callback and pending=false (timeout={.cb=cb\_func} does the work), and added to uloop using uloop\_timeout\_set(), do not use the other \_add() function because then you will need to set up the time yourself calling time.h functions. \_set() uses \_add() internally.

TBDN: Process management part

## libubox/blob.h

This part is a helper to pass data in binary. There are several supported datatypes, and it creates blobs that could be sent over any socket, as endianess is taken care in the library itself.

The method is to create a type-value chained data, supporting nested data. This part basically covers putting and getting datatypes. Further functionality is implemented in blobmsg.h

## libubox/blobmsg.h

Blobmsg sits on top of blob.h, providing tables and arrays, providing it's own but parallel datatypes.

## libubox/list.h

Utility to create lists. A way to create lists of structures just by adding struct list\_head to your structures. It comes with a lot of iterator macros, with some of them allowing deletion on iteration (the ones ending in \_safe). It also has some list operations like slicing, moving, and inserting in different points. It is a double linked list implementation (just in case). Uses the same API as the one present in the linux kernel.

## libubox/safe-list.h

Uses list.h to provide protection against recursive iteration with deletes.

## libubox/kvlist.h

Key value lists, allowing duplicate elements. Keys are meant to be strings, values can be any datatype, the user has to provide a data measuring function though. If you are using strings or blobs (from blob.h), there are two measuring functions already, kvlist\_strlen and kvlist\_blob\_len respectively.

kvlist.h implementation uses avl.h.

- [Project's git](http://git.openwrt.org/?p=project%2Flibubox.git%3Ba%3Dsummary "http://git.openwrt.org/?p=project/libubox.git;a=summary")
