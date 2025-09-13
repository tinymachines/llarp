← [Previous Chapter](/docs/guide-developer/helloworld/chapter7 "docs:guide-developer:helloworld:chapter7")  

 [start](/docs/guide-developer/helloworld/chapter8 "docs:guide-developer:helloworld:chapter8") →

# Patching your application: Editing existing files

This is the seventh chapter in the “Hello, world!” for OpenWrt article series. At this point, you should've already accomplished the following tasks:

- Commissioned your development environment
- Prepared, configured and built the tools and the cross-compilation toolchain
- Configured the `PATH` environment variable
- Created a simple “Hello, world!” application using native compilation tools
- Created a local package feed for your application
- Created a package manifest file for your application
- Included your new package feed into the OpenWrt build system
- Updated the package index, and installed your package from the feed
- Built, deployed and tested the application on your target device
- Migrated your application to use GNU make
- Tested building your application using GNU make
- Updated the package manifest to use GNU make as a build tool
- Prepared the source code, and created a patch to add new files to the package

If you missed one or more of these steps, review the previous chapters.

## Creating the second patch

Our first patch that we created in our previous chapter added two new files, and implemented a new function called `add`. However, this function is not being called yet, so the functionality it provides is going to waste.

In order to utilize the functionality, we create an additional patch which modifies the `helloworld.c` file. First, we prepare the source codes for patching, and create a new patch context:

```
cd /home/buildbot/source
make package/helloworld/{clean,prepare} QUILT=1
cd build_dir/target-.../helloworld-1.0/
quilt push -a
quilt new 101-use_module.patch
```

Our task is to modify the `helloworld.c` file, so we issue the following command to add the file into the patch context, and open it for editing:

```
quilt edit helloworld.c
```

Note that since the file already exists, it is not necessary to add the file into the patch context using `quilt add`. In the previous chapter, we intentionally used this command to highlight the difference between adding a file and editing an existing file.

Let's modify the source file to include our header file, and call the new function:

[helloworld.c](/_export/code/docs/guide-developer/helloworld/chapter8?codeblock=2 "Download Snippet")

```
#include <stdio.h>
#include "functions.h"
 
int main(void)
{
    int result = add(2, 3);
 
    printf("\nHello, world!\nThe sum is '%d'", result);
    return 0;     
}
```

Save your changes, review them using `quilt diff` and move them to the patch context using `quilt refresh`.

Finally navigate back to the back to the root folder of the OpenWrt build system and update the package with our new patch. To do so, issue:

```
cd /home/buildbot/source
make package/helloworld/update
```

## Conclusion

In this chapter, we created a second patch that edits existing files in order to take our newly added `add` function into use. We then finalized the patch and migrated it into the package proper.

This concludes the “Hello, world!” for OpenWrt article series.

← [Previous Chapter](/docs/guide-developer/helloworld/chapter7 "docs:guide-developer:helloworld:chapter7")  

[Helloworld overview](/docs/guide-developer/helloworld/start "docs:guide-developer:helloworld:start")  

 [start](/docs/guide-developer/helloworld/chapter8 "docs:guide-developer:helloworld:chapter8") →
