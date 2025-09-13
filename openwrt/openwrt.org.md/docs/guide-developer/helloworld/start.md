# "Hello, world!" for OpenWrt

Welcome to the “Hello, world!” -article series for OpenWrt. This article series walks you through the basics of developing new software for your router. We will start with an extremely simple application that does (almost) nothing, and slowly evolve it throughout the series. Each individual chapter in this series will introduce an additional concept, and once you've gone through all the chapters, you should feel much more comfortable foraging into the world of OpenWrt development.

All the source code example files in this series are written in the C programming language. While the outlining concepts i.e. creating new packages, specifying source code location, using build tools and creating installable packages are applicable to any other programming language as well, explicit examples for other programming languages besides [C](https://web.archive.org/web/20190327113416/https://c-language.com/ "https://web.archive.org/web/20190327113416/https://c-language.com/") are not provided.

Command examples in this article series use the Bash command interpreter when inside the development environment, and the Ash command interpreter when operating on the target device.

## Requirements

In order to proceed alongside this article series, the following requirements should be met:

- Basic understanding of a Linux operating system, preferably one of the [supported distributions](/docs/guide-developer/toolchain/install-buildsystem "docs:guide-developer:toolchain:install-buildsystem") for running the OpenWrt build system
- Access to the Internet (for downloading the source code of the build system, or the OpenWrt SDK for your target device)
- Basic understanding of the [C programming language](http://fresh2refresh.com/c-programming/c-basic-program/ "http://fresh2refresh.com/c-programming/c-basic-program/")
- Basic understanding of the [GNU make](https://www.gnu.org/software/make/manual/make.html "https://www.gnu.org/software/make/manual/make.html") system
- Knowledge on how to create and commission virtual machines, or access to a dedicated computer running a suitable Linux distribution
- Your target device **should already be supported** by the OpenWrt build system

If you feel unsure on any of the above topics, feel free to follow the links in order to find some basic information.

The author of this article chose to use a Debian 8 Linux distribution as the development environment for this article, running inside a VirtualBox virtual machine. You are free to choose an alternative virtualization platform, or even run the environment on a dedicated physical computer. Note that you should be familiar with the environment that you are operating in, and be able to perform basic file system operations (creating and deleting files) and be familiar with using a text editor of choice in your environment.

## List of topics

This article series will cover the following topics:

- [**Preparing your OpenWrt build system for use**](/docs/guide-developer/helloworld/chapter1 "docs:guide-developer:helloworld:chapter1")
  
  - [Preparing, configuring and building the necessary tools](/docs/guide-developer/helloworld/chapter1#preparing_configuring_and_building_the_necessary_tools "docs:guide-developer:helloworld:chapter1")
  - [Adjusting the PATH variable](/docs/guide-developer/helloworld/chapter1#adjusting_the_path_variable "docs:guide-developer:helloworld:chapter1")
  - [Conclusion](/docs/guide-developer/helloworld/chapter1#conclusion "docs:guide-developer:helloworld:chapter1")
- [**Creating a simple “Hello, world!” application**](/docs/guide-developer/helloworld/chapter2 "docs:guide-developer:helloworld:chapter2")
  
  - [Creating the source code directory and files](/docs/guide-developer/helloworld/chapter2#creating_the_source_code_directory_and_files "docs:guide-developer:helloworld:chapter2")
  - [Compiling, linking and testing the application](/docs/guide-developer/helloworld/chapter2#compiling_linking_and_testing_the_application "docs:guide-developer:helloworld:chapter2")
  - [Conclusion](/docs/guide-developer/helloworld/chapter2#conclusion "docs:guide-developer:helloworld:chapter2")
- [**Creating a package from your application**](/docs/guide-developer/helloworld/chapter3 "docs:guide-developer:helloworld:chapter3")
  
  - [Creating a package feed for your packages](/docs/guide-developer/helloworld/chapter3#creating_a_package_feed_for_your_packages "docs:guide-developer:helloworld:chapter3")
  - [Creating the package manifest file](/docs/guide-developer/helloworld/chapter3#creating_the_package_manifest_file "docs:guide-developer:helloworld:chapter3")
  - [Conclusion](/docs/guide-developer/helloworld/chapter3#conclusion "docs:guide-developer:helloworld:chapter3")
- [**Including your package feed into OpenWrt build system**](/docs/guide-developer/helloworld/chapter4 "docs:guide-developer:helloworld:chapter4")
  
  - [Including the new package feed into the OpenWrt build system](/docs/guide-developer/helloworld/chapter4#including_the_new_package_feed_into_the_openwrt_build_system "docs:guide-developer:helloworld:chapter4")
  - [Updating and installing feeds](/docs/guide-developer/helloworld/chapter4#updating_and_installing_feeds "docs:guide-developer:helloworld:chapter4")
  - [Conclusion](/docs/guide-developer/helloworld/chapter4#conclusion "docs:guide-developer:helloworld:chapter4")
- [**Building, deploying and testing your application**](/docs/guide-developer/helloworld/chapter5 "docs:guide-developer:helloworld:chapter5")
  
  - [Building the package](/docs/guide-developer/helloworld/chapter5#building_the_package "docs:guide-developer:helloworld:chapter5")
  - [Deploying and testing your package](/docs/guide-developer/helloworld/chapter5#deploying_and_testing_your_package "docs:guide-developer:helloworld:chapter5")
  - [Removing your package](/docs/guide-developer/helloworld/chapter5#removing_your_package "docs:guide-developer:helloworld:chapter5")
  - [Conclusion](/docs/guide-developer/helloworld/chapter5#conclusion "docs:guide-developer:helloworld:chapter5")
- [**Migrating to use GNU make in your application**](/docs/guide-developer/helloworld/chapter6 "docs:guide-developer:helloworld:chapter6")
  
  - [Why use GNU make ?](/docs/guide-developer/helloworld/chapter6#why_use_gnu_make "docs:guide-developer:helloworld:chapter6")
  - [Creating a Makefile](/docs/guide-developer/helloworld/chapter6#creating_a_makefile "docs:guide-developer:helloworld:chapter6")
  - [Testing the Makefile using native tools](/docs/guide-developer/helloworld/chapter6#testing_the_makefile_using_native_tools "docs:guide-developer:helloworld:chapter6")
  - [Modifying the package manifest, and testing the build](/docs/guide-developer/helloworld/chapter6#modifying_the_package_manifest_and_testing_the_build "docs:guide-developer:helloworld:chapter6")
  - [Conclusion](/docs/guide-developer/helloworld/chapter6#conclusion "docs:guide-developer:helloworld:chapter6")
- [**Patching your application: Adding new files**](/docs/guide-developer/helloworld/chapter7 "docs:guide-developer:helloworld:chapter7")
  
  - [About patches](/docs/guide-developer/helloworld/chapter7#about_patches "docs:guide-developer:helloworld:chapter7")
  - [Preparing the source code](/docs/guide-developer/helloworld/chapter7#preparing_the_source_code "docs:guide-developer:helloworld:chapter7")
  - [Creating the first patch](/docs/guide-developer/helloworld/chapter7#creating_the_first_patch "docs:guide-developer:helloworld:chapter7")
  - [Including the first patch into the package](/docs/guide-developer/helloworld/chapter7#including_the_first_patch_into_the_package "docs:guide-developer:helloworld:chapter7")
  - [Conclusion](/docs/guide-developer/helloworld/chapter7#conclusion "docs:guide-developer:helloworld:chapter7")
- [**Patching your application: Editing existing files**](/docs/guide-developer/helloworld/chapter8 "docs:guide-developer:helloworld:chapter8")
  
  - [Creating the second patch](/docs/guide-developer/helloworld/chapter8#creating_the_second_patch "docs:guide-developer:helloworld:chapter8")
  - [Conclusion](/docs/guide-developer/helloworld/chapter8#conclusion "docs:guide-developer:helloworld:chapter8")
