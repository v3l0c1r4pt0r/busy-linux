# BASE IMAGE FOR ALL STAGES
FROM ubuntu:latest AS dev

RUN apt-get update -y && apt-get install -y \
  # for donwloading CC and sources \
  wget

RUN wget 'https://github.com/v3l0c1r4pt0r/cc-factory/releases/download/x86_64-gcc10.2.0-linux5.9.13-uclibc1.0.36-1/x86_64-gcc10.2.0-linux5.9.13-uclibc1.0.36-1.tar.gz' && \
  tar -xvf x86_64-gcc10.2.0-linux5.9.13-uclibc1.0.36-1.tar.gz -C / && \
  rm x86_64-gcc10.2.0-linux5.9.13-uclibc1.0.36-1.tar.gz

ENV PATH "${PATH}:/opt/x86_64-linux-uclibc/bin"

# KERNEL STAGE
FROM dev AS kernel

WORKDIR /root

RUN apt-get install -y xz-utils

RUN wget 'https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.11.16.tar.xz' && tar -xvf linux-5.11.16.tar.xz && rm linux-5.11.16.tar.xz
