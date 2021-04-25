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

# KERNEL STAGE
FROM dev AS kernel

WORKDIR /root

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
