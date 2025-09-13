← [Previous Chapter](/docs/guide-developer/helloworld/chapter3 "docs:guide-developer:helloworld:chapter3")  

 [Next Chapter](/docs/guide-developer/helloworld/chapter5 "docs:guide-developer:helloworld:chapter5") →

# Including your package feed into OpenWrt build system

This is the fourth chapter in the “Hello, world!” for OpenWrt article series. At this point, you should've already accomplished the following tasks:

- Commissioned your development environment
- Prepared, configured and built the tools and the cross-compilation toolchain
- Configured the PATH environment variable
- Created a simple “Hello, world!” application using native compilation tools
- Created a local package feed for your application
- Created a package manifest file for your application

If you missed one or more of these steps, review the previous chapters.

## Including the new package feed into the OpenWrt build system

The OpenWrt build system uses a specific file called `feeds.conf` which indicates the package feeds that will be made available during the firmware configuration stage. In order for the package containing the application to be made visible in the first place, it is necessary to include the new package feed into this file.

By default, this file does not exist in the OpenWrt source code directory, so it is necessary to create it:

```
cd /home/buildbot/source
touch feeds.conf
```

Modify the file with the text editor to specify the local package feed:

```
src-link mypackages /home/buildbot/mypackages
```

## Updating and installing feeds

Now that the new feed is defined, we can instruct the build system to update its package index based on the information available in this feed, and to make all packages in this feed available in the configuration menu. This can be achieved by issuing the following commands:

```
cd /home/buildbot/source
./scripts/feeds update mypackages
./scripts/feeds install -a -p mypackages
```

If the last step completes successfully, you should see the response below as the script finds the feed for our new package and adds it to the index:

```
Installing package 'helloworld' from mypackages
```

Note that whenever you modify the package manifest file, the feeds system will automatically detect this, and will perform an update on your behalf before completing other commands such as 'make menuconfig' or before building a package.

## Conclusion

In this chapter, we created a feed configuration file called 'feeds.conf', adding our local package feed into the file. We then updated the package index from this feed and installed all packages available in this feed, ready to be included in the firmware configuration.

← [Previous Chapter](/docs/guide-developer/helloworld/chapter3 "docs:guide-developer:helloworld:chapter3")  

[Helloworld overview](/docs/guide-developer/helloworld/start "docs:guide-developer:helloworld:start")  

 [Next Chapter](/docs/guide-developer/helloworld/chapter5 "docs:guide-developer:helloworld:chapter5") →
