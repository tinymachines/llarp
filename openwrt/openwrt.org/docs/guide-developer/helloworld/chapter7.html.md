← [Previous Chapter](/docs/guide-developer/helloworld/chapter6 "docs:guide-developer:helloworld:chapter6")  

 [Next Chapter](/docs/guide-developer/helloworld/chapter8 "docs:guide-developer:helloworld:chapter8") →

# Patching your application: Adding new files

This is the seventh chapter in the “Hello, world!” for OpenWrt article series. At this point, you should've already accomplished the following tasks:

- Commissioned your development environment
- Prepared, configured and built the tools and the cross-compilation toolchain
- Configured the PATH environment variable
- Created a simple “Hello, world!” application using native compilation tools
- Created a local package feed for your application
- Created a package manifest file for your application
- Included your new package feed into the OpenWrt build system
- Updated the package index, and installed your package from the feed
- Built, deployed and tested the application on your target device
- Migrated your application to use GNU make
- Tested building your application using GNU make
- Updated the package manifest to use GNU make as a build tool

If you missed one or more of these steps, review the previous chapters.

## About patches

During the life cycle of an application, from the initial design until the application is decommissioned, it often requires changes or fixes to the original source code or associated files in order to operate correctly. Changing the application source code is especially common when using when porting software to run on a different computer architecture. In the OpenWrt build system, this change management is accomplished with a tool called Quilt.

There is an [existing page](/docs/guide-developer/toolchain/use-patches-with-buildsystem "docs:guide-developer:toolchain:use-patches-with-buildsystem") in the OpenWrt wiki describing the tool in more detail. **Please review at least the first section in this page**, as there is crucial information on how the create a `.quiltrc` file, which ensures that the patches you create follow the established standards of the OpenWrt build system.

At this point it is a good idea to ensure that Quilt can be found from the PATH environment variable. The OpenWrt build system installs the 'quilt' tool into the 'bin' directory under the target-independent tools' folder. We added this directory to our path in the [first chapter](/docs/guide-developer/helloworld/chapter1#adjusting_the_path_variable "docs:guide-developer:helloworld:chapter1"). To ensure that you can invoke the tool, you can simply issue:

```
quilt --version
```

## Preparing the source code

Creating a patch in the OpenWrt build system is very straightforward, but before we can start applying patches, we need to prepare our source code using a special option. We do so with the following commands:

```
cd /home/buildbot/source/
make package/helloworld/{clean,prepare} QUILT=1
```

Note that when invoking 'make' with the `QUILT=1` argument, the source code is **not** intended for building final packages. The argument creates additional folders and files into the build directory, and these files may confuse the build process.

Our final preparation step is to navigate into the build directory where the source codes reside, and ensure that all existing patches are applied:

```
cd build_dir/target-.../helloworld-1.0/
quilt push -a
```

The `quilt push` command does not do anything at this point, since our application does not yet contain any patches. However, issuing these commands is something you would do each time you start working on a package that has multiple authors, who might've submitted patches that you are not aware of.

## Creating the first patch

We now begin patching our application. To do so, we must first create a `patch context` for Quilt:

```
quilt new 100-add_module_files.patch
```

The name of the patch comes from the conventions of the OpenWrt build system. The names usually begin with a free ordinal number, followed by a short description of what they do. The ordinal numbers have a specific meaning in some contexts, but oftentimes you can simply use a numbering starting from '000'.

The author of this article chose the number '100' to signify that this patch adds new functionality to the existing source code base, and that this functionality has not yet been integrated into the original source code (upstream).

The output of the command shows that this patch file was created and is now at the top of the Quilt's `patch stack`.

In this patch, we will add new functionality for our “Hello, world!” application. The functionality will be split into two different files, a header file and a C source file. Our first task is to instruct 'quilt' to start tracking these files in the current patch context:

```
quilt add functions.c
quilt add functions.h
```

We then begin editing the files, one by one, using the following commands:

```
touch functions.c
quilt edit functions.c
```

Write the following content into the new file:

[functions.c](/_export/code/docs/guide-developer/helloworld/chapter7?codeblock=6 "Download Snippet")

```
int add(int a, int b)
{
    return a + b;
}
```

Create the second file and begin modifying it with the following commands:

```
touch functions.h
quilt edit functions.h
```

Write the following content into the file:

[functions.h](/_export/code/docs/guide-developer/helloworld/chapter7?codeblock=8 "Download Snippet")

```
int add(int, int);
```

At this point we should review the changes that Quilt has recorded so far by issuing `quilt diff`. From the command output, we can observe that two completely new files have been added, and their new content is being shown.

Since we are satisfied with these changes, we can issue `quilt refresh` to accept these changes as content of the patch.

## Including the first patch into the package

In the OpenWrt build system, patches are created and modified in the source code directory, and then migrated over to the package that they belong to. In order for us to migrate the patch data that we just created into the package proper, we issue the following commands:

```
cd /home/buildbot/source
make package/helloworld/update
```

At this point, we can review our handiwork by checking the content of our package feed folder, and the content of our original source code folder:

```
ls -la /home/buildbot/mypackages/examples/helloworld
ls -la /home/buildbot/helloworld
```

As we can see, the OpenWrt build system migrated our newly-created patch file into the folder where the package manifest is. The original source code folder remains completely unaware of our changes.

Now, we need to modify `mypackages/examples/helloworld/Makefile` to copy the patch to the build directory. The earlier version used the `cp` command without the `-r` option. We need to add the `-r` option to copy directories.

[Makefile](/_export/code/docs/guide-developer/helloworld/chapter7?codeblock=11 "Download Snippet")

```
define Build/Prepare
		mkdir -p $(PKG_BUILD_DIR)
		cp $(SOURCE_DIR)/* $(PKG_BUILD_DIR) -r
		$(Build/Patch)
endef
```

We can ensure that our new patch is applied correctly during the build process:

```
cd /home/buildbot/source
make package/helloworld/{clean,prepare}
ls -la build_dir/target-<arch>_<subarch>_<clib>_<clibversion>/
```

We observe that the patches were applied, and the new files are present in the build directory.

## Conclusion

In this chapter, we scratched the surface of the OpenWrt build system's patching framework. We created a new patch, added two new files into the patch context, added content for the files and updated the patch context to reflect these changes. We then updated the package to migrate the newly-created patch over to the folder where the package manifest file resides.

← [Previous Chapter](/docs/guide-developer/helloworld/chapter6 "docs:guide-developer:helloworld:chapter6")  

[Helloworld overview](/docs/guide-developer/helloworld/start "docs:guide-developer:helloworld:start")  

 [Next Chapter](/docs/guide-developer/helloworld/chapter8 "docs:guide-developer:helloworld:chapter8") →
