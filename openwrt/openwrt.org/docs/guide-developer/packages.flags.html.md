# Overriding Build Options

Some packages might require overriding certain build options because we are cross compiling.

The build system allows for several entries under **Advanced configuration options (for developers) &gt; Kernel extra CFLAGS** and **Advanced configuration options (for developers) &gt; Target Options** which will pass the defined flags onto the kernel and packages respectively.

## Autotools: Autoconf

**CONFIGURE\_VARS**

1. Override ac\_cv\_* variables that are normally set during autoconf ./configure phase.
2. override pkgconfig configure vars

Example: Some packages check for features (header files) and do not offer -enable/-with or -disable/-without configure options (to be written into \_ARGS). Search for the configure variable in config.log and preset it in CONFIGURE\_VARS.

```
      CONFIGURE_VARS += \
              ac_cv_header_regex_h=no
```

**CONFIGURE\_ARGS**

1. Add options/test after ./configure

![:!:](/lib/images/smileys/exclaim.svg) Looking into config.log can help

## Compiler flags

Available compiler flags are handled in rules.mk

```
TARGET_CFLAGS:=$(TARGET_OPTIMIZATION)$(if $(CONFIG_DEBUG), -g3) $(EXTRA_OPTIMIZATION)
TARGET_CXXFLAGS = $(TARGET_CFLAGS)
TARGET_ASFLAGS_DEFAULT = $(TARGET_CFLAGS)
TARGET_ASFLAGS = $(TARGET_ASFLAGS_DEFAULT)
TARGET_CPPFLAGS:=-I$(STAGING_DIR)/usr/include -I$(STAGING_DIR)/include
TARGET_LDFLAGS:=-L$(STAGING_DIR)/usr/lib -L$(STAGING_DIR)/lib
```

Typically you should only add additional options to compile flags.

```
TARGET_CFLAGS+= -Wall
```

Example: Support multiple library versions via .../usr/lib/libname-v1/ or .../usr/lib/libname-v2/ and select them.

![:!:](/lib/images/smileys/exclaim.svg) BUG CXXFLAGS can contain wrong options because GCC/G++ accept different ones.

## Make

MAKE\_VARS in include/package-defaults.mk

```
MAKE_VARS = \
        CFLAGS="$(TARGET_CFLAGS) $(EXTRA_CFLAGS) $(TARGET_CPPFLAGS) $(EXTRA_CPPFLAGS)" \
        CXXFLAGS="$(TARGET_CXXFLAGS) $(EXTRA_CXXFLAGS) $(TARGET_CPPFLAGS) $(EXTRA_CPPFLAGS)" \
        LDFLAGS="$(TARGET_LDFLAGS) $(EXTRA_LDFLAGS)"
```

MAKE\_FLAGS

```
MAKE_FLAGS = \
        $(TARGET_CONFIGURE_OPTS) \
        CROSS="$(TARGET_CROSS)" \
        ARCH="$(ARCH)"
```

## CMake

include/cmake.mk

CMAKE\_OPTIONS

CMAKE\_HOST\_OPTIONS

## Scons

SCONS\_VARS are set in include/scons.mk

```
SCONS_VARS = \
        CC="$(TARGET_CC_NOCACHE)" \
        CXX="$(TARGET_CXX_NOCACHE)" \
        CFLAGS="$(TARGET_CFLAGS) $(EXTRA_CFLAGS)" \
        CXXFLAGS="$(TARGET_CFLAGS) $(EXTRA_CFLAGS)" \
        CPPFLAGS="$(TARGET_CPPFLAGS) $(EXTRA_CPPFLAGS)" \
        LDFLAGS="$(TARGET_LDFLAGS) $(EXTRA_LDFLAGS)" \
        DESTDIR="$(PKG_INSTALL_DIR)"
```

SCONS\_OPTIONS have no default set.

scons is only used by a few packages: [iotivity](https://github.com/openwrt/packages/blob/master/net/iotivity/Makefile "https://github.com/openwrt/packages/blob/master/net/iotivity/Makefile") smartsnmpd
