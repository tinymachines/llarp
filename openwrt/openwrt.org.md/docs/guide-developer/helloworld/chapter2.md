← [Previous Chapter](/docs/guide-developer/helloworld/chapter1 "docs:guide-developer:helloworld:chapter1")  

 [Next Chapter](/docs/guide-developer/helloworld/chapter3 "docs:guide-developer:helloworld:chapter3") →

# Creating a simple “Hello, world!” application

This is the second chapter in the “Hello, world!” for OpenWrt article series. At this point, you should've already accomplished the following tasks:

- Commissioned your development environment
- Prepared, configured and built the tools and the cross-compilation toolchain
- Configured the PATH environment variable.

If you missed one or more of these steps, review the previous chapters.

## Creating the source code directory and files

A good practice in software development is to keep things separate from each other, and only provide enough connecting points for different pieces of a software composition to operate together. This approach is known as a separation of concerns.

In order to maintain this approach, we place the source code of our application into a directory of its own, separate from the OpenWrt build system. We name the source code directory after our application, 'helloworld' and create it under the home directory of the user build user:

```
cd /home/buildbot
mkdir helloworld
cd helloworld
```

Now, we create the sole source code file for our application, called 'helloworld.c':

```
touch helloworld.c
```

Using your favorite text editor, paste the following content into the newly-created file:

[helloworld.c](/_export/code/docs/guide-developer/helloworld/chapter2?codeblock=2 "Download Snippet")

```
#include <stdio.h>
 
int main(void)
{
    printf("\nHello, world!\n\n");
    return 0;
}
```

## Compiling, linking and testing the application

After creating the source code files for our Next, we ensure our application can be built and executed by the native compilation tools on the development environment:

```
gcc -c -o helloworld.o helloworld.c -Wall
gcc -o helloworld helloworld.o
```

The first command compiles the 'helloworld.c' source file into an object file, and the second command links the object file with the necessary startup files and default libraries to produce an executable called 'helloworld'. To execute the application, issue the following command:

```
./helloworld
```

You should be greeted by the text “Hello, world!”. If this did not happen, or if you encounter errors when running the above compilation and linking commands, ensure the content of your source file is correct and that you have the native compilation tools installed for your environment.

## Conclusion

In this chapter, we created a simple executable application using the native compilation tools available in the development environment. We also skimmed on one of the basic principles of software development; the separation of concerns.

← [Previous Chapter](/docs/guide-developer/helloworld/chapter1 "docs:guide-developer:helloworld:chapter1")  

[Helloworld overview](/docs/guide-developer/helloworld/start "docs:guide-developer:helloworld:start")  

 [Next Chapter](/docs/guide-developer/helloworld/chapter3 "docs:guide-developer:helloworld:chapter3") →
