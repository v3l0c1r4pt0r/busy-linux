FROM ubuntu:latest

RUN apt-get update -y && apt-get install -y \
  # for donwloading CC and sources \
  wget \
  # for cloning repos \
  git

RUN wget 'https://github.com/v3l0c1r4pt0r/cc-factory/releases/download/x86_64-gcc10.2.0-linux5.9.13-uclibc1.0.36-1/x86_64-gcc10.2.0-linux5.9.13-uclibc1.0.36-1.tar.gz' && \
  tar -xvf x86_64-gcc10.2.0-linux5.9.13-uclibc1.0.36-1.tar.gz -C / && \
  rm x86_64-gcc10.2.0-linux5.9.13-uclibc1.0.36-1.tar.gz

ENV PATH "${PATH}:/opt/x86_64-linux-uclibc/bin"
