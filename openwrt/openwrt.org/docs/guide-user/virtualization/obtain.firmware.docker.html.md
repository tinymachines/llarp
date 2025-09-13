# Docker OpenWrt Image Generation

See also [Docker OpenWrt Image](/docs/guide-user/virtualization/docker_openwrt_image "docs:guide-user:virtualization:docker_openwrt_image")

You can use a premade [Docker](https://www.docker.io/ "https://www.docker.io/") image to build yourself an OpenWrt firmware image. A list of known such Docker images (see instructions how to use them on their pages):

- [Official OpenWRT Docker images](https://github.com/openwrt/docker "https://github.com/openwrt/docker") which can be pulled from [Docker hub](https://hub.docker.com/r/openwrt "https://hub.docker.com/r/openwrt")
- [noonien/docker-openwrt-buildroot](https://github.com/noonien/docker-openwrt-buildroot "https://github.com/noonien/docker-openwrt-buildroot")
- [galalmounir/openwrt-image-builder](https://github.com/galalmounir/openwrt-image-builder "https://github.com/galalmounir/openwrt-image-builder")
- *wlan slovenija* [image generator](https://github.com/wlanslovenija/firmware-core "https://github.com/wlanslovenija/firmware-core")
- Roll your own using either Alpine or Debian containerfiles.

## Building OpenWRT using Docker

First, an image needs to be obtained. Lets start with the most basic example, where a custom container is build. This can be skipped by instead pulling one of the OpenWRT containers from a container registry.

Alpine Container

Alpine Container

[Containerfile-alpine](/_export/code/docs/guide-user/virtualization/obtain.firmware.docker?codeblock=0 "Download Snippet")

```
FROM docker.io/alpine:latest

ENV GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
WORKDIR /workdir

RUN apk add --no-cache \
    'argp-standalone' \
    'asciidoc' \
    'bash' \
    'bc' \
    'binutils' \
    'bzip2' \
    'cdrkit' \
    'coreutils' \
    'diffutils' \
    'elfutils-dev' \
    'findutils' \
    'flex' \
    'g++' \
    'gawk' \
    'gcc' \
    'gettext' \
    'git' \
    'grep' \
    'gzip' \
    'intltool' \
    'libxslt' \
    'linux-headers' \
    'make' \
    'musl-fts-dev' \
    'musl-libintl' \
    'musl-obstack-dev' \
    'ncurses-dev' \
    'openssl-dev' \
    'patch' \
    'perl' \
    'python3-dev' \
    'rsync' \
    'tar' \
    'unzip' \
    'util-linux' \
    'wget' \
    'zlib-dev' \
    'py3-distutils-extra' \
    'py3-setuptools' \
  && \
  addgroup 'buildbot' && \
  adduser -s '/bin/bash' -G 'buildbot' -D 'buildbot'

USER buildbot
```

Debian Container

Debian Container

[Containerfile-debian](/_export/code/docs/guide-user/virtualization/obtain.firmware.docker?codeblock=1 "Download Snippet")

```
FROM docker.io/debian:stable-slim

ENV GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
WORKDIR /workdir

RUN apt-get update && apt-get install --no-install-recommends --no-install-suggests --yes \
    'build-essential' \
    'ca-certificates' \
    'clang' \
    'flex' \
    'bison' \
    'g++' \
    'gawk' \
    'gcc-multilib' \
    'gettext' \
    'git' \
    'libncurses5-dev' \
    'libssl-dev' \
    'python3-distutils' \
    'rsync' \
    'unzip' \
    'zlib1g-dev' \
    'file' \
    'wget' \
  && \
  rm -f -r '/var/lib/apt/' && \
  rm -f -r '/var/cache/apt/' && \
  useradd -m -s '/bin/bash' -U 'buildbot'

USER buildbot
```

After placing (either) downloading either/both of these files, a OpenWRT repository is needed. After cloning or downloading the OpenWRT repository it might be a thought to create a dedicated worktree, when not wanting to build using master.

```
cd <openwrt repo>; git worktree add ../openwrt-<branch name> -b <branch name>; cd ../openwrt-<branch name>
```

. This will create a new git branch and check it out on a worktree.

Next, the container is to be built, using either **podman** or **docker**.

Note, while not strictly necessary, we don't want to copy all of the repository files into the container context. Doing so won't hurt or break anything, but it wastes space and costs time and won't even be accessible when running the container.

To avoid copying needless files, a *.dockerignore* file is used, which can be either in the same location as the *Dockerfile* or in the current working directory.

```
echo "*" > .dockerignore
```

Building the container is as simple as:

```
docker build --rm --tag openwrt:alpine --file <path-to-containerfile>/Containerfile-alpine <path-to-openwrt>
```

The tag can be named whatever of course, dated or likewise. The container only occasionally has to be rebuild, when 'host dependencies' are changed or updated.

Finally, the container can be used to launch a build environment

```
docker run --interactive --rm --tty --ulimit 'nofile=1024:262144' --volume "$(pwd):/workdir" --workdir '/workdir' openwrt:alpine /bin/bash
<hostname>:/workdir$
```

From here, any normal OpenWRT command can be used as expected (\`make menuconfig\` etc). It is recommended to create an alias such as

```
alias make='make -j10 V=sc'
```

to build more verbose with multiple jobs, but this is completely optional.

## OpenWrt Cloud Builder API

To facilitate easy sharing, reuse, and swapping of builders and testing out of new firmwares in the wider OpenWrt community, the [following standard is proposed](https://github.com/wlanslovenija/firmware-core#openwrt-cloud-builder-api "https://github.com/wlanslovenija/firmware-core#openwrt-cloud-builder-api").

## Project specific OpenWrt Buildroot

To facilitate sharing an project specific OpenWrt buildroot in such a way non Docker or Linux experts can understand. [https://github.com/Doodle3D/openwrt-buildroot-example](https://github.com/Doodle3D/openwrt-buildroot-example "https://github.com/Doodle3D/openwrt-buildroot-example")
