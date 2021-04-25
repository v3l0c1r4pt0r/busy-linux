FROM ubuntu:latest

RUN apt-get update -y && apt-get install -y \
  # for donwloading CC and sources \
  wget \
  # for cloning repos \
  git
