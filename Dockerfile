# BASE IMAGE FOR ALL STAGES
FROM ubuntu:latest AS dev

RUN apt-get update -yq && apt-get upgrade -yq && \
  DEBIAN_FRONTEND="noninteractive" apt-get install -yq \
  # for donwloading CC and sources \
  wget \
  # for toolchain cross-compilation \
  gcc g++ make gawk texinfo file m4 patch

RUN wget 'https://github.com/v3l0c1r4pt0r/cc-factory/releases/download/x86_64-gcc10.2.0-linux5.9.13-uclibc1.0.36-1/x86_64-gcc10.2.0-linux5.9.13-uclibc1.0.36-1.tar.gz' && \
  tar -xvf x86_64-gcc10.2.0-linux5.9.13-uclibc1.0.36-1.tar.gz -C / && \
  rm x86_64-gcc10.2.0-linux5.9.13-uclibc1.0.36-1.tar.gz

ENV PATH "${PATH}:/opt/x86_64-linux-uclibc/bin"

WORKDIR /root

# KERNEL STAGE
FROM dev AS kernel

RUN apt-get install -y \
  # for unpacking kernel tarball \
  xz-utils \
  # for compiling \
  flex bison libssl-dev libelf-dev bc

RUN wget 'https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.11.16.tar.xz' && tar -xvf linux-5.11.16.tar.xz && rm linux-5.11.16.tar.xz

ENV CROSS_COMPILE x86_64-linux-uclibc-

WORKDIR /root/linux-5.11.16

RUN make x86_64_defconfig

ARG MAKEFLAGS

RUN make

RUN cp arch/x86/boot/bzImage /root/

# Busybox
FROM dev AS busybox

RUN apt-get install -y \
  # allow running menuconfig for debugging purposes \
  libncurses-dev

RUN wget 'https://www.busybox.net/downloads/busybox-1.33.0.tar.bz2' && tar -xvf busybox-1.33.0.tar.bz2 && rm busybox-1.33.0.tar.bz2

WORKDIR /root/busybox-1.33.0

ENV CROSS_COMPILE x86_64-linux-uclibc-

RUN make defconfig

# switch to static binary
RUN sed -i 's/# CONFIG_STATIC is not set/CONFIG_STATIC=y/g' .config

# reconfigurations comparing to defconfig
# avoid compilation errors due to missing features

# requires utmpx.h
RUN sed -i 's/CONFIG_FEATURE_UTMP=y/CONFIG_FEATURE_UTMP=n/g' .config

# requires netinet/icmp6.h
RUN sed -i 's/CONFIG_PING6=y/CONFIG_PING6=n/g' .config

# fails on missing LONG_BIT define
RUN sed -i 's/CONFIG_SSL_CLIENT=y/CONFIG_SSL_CLIENT=n/g' .config
RUN sed -i 's/CONFIG_FEATURE_WGET_HTTPS=y/CONFIG_FEATURE_WGET_HTTPS=n/g' .config

# requires netinet/ip6.h
RUN sed -i 's/CONFIG_TRACEROUTE6=y/CONFIG_TRACEROUTE6=n/g' .config
RUN sed -i 's/CONFIG_TRACEROUTE=y/CONFIG_TRACEROUTE=n/g' .config
RUN sed -i 's/CONFIG_UDHCPC6=y/CONFIG_UDHCPC6=n/g' .config

# requires __ns_* functions that are missing, failing linking
RUN sed -i 's/CONFIG_NSLOOKUP=y/CONFIG_NSLOOKUP=n/g' .config

# requires mktemp()
RUN sed -i 's/CONFIG_MKTEMP=y/CONFIG_MKTEMP=n/g' .config

RUN make

RUN cp busybox /root/

# Initial ramdisk
FROM scratch AS initramfs

COPY --from=busybox /root/busybox /bin/busybox

# install symlinks to all tools
RUN ["/bin/busybox", "--install", "-s", "/bin"]
