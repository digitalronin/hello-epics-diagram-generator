#!/bin/bash

set -euo pipefail

main() {
  apt
  make_swap
  install_packages
}

apt() {
  apt-get -y update
  apt-get -y upgrade
}

make_swap() {
  dd if=/dev/zero of=/var/swap.img bs=1024k count=2000
  chmod 600 /var/swap.img
  mkswap /var/swap.img
  swapon /var/swap.img
  echo "/var/swap.img none swap sw 0 0" >> /etc/fstab
}

install_packages() {
  apt-get install -y \
    build-essential \
    software-properties-common \
    git \
    graphviz \
    ruby \
    ruby-dev \
    ruby-bundler
}

main
