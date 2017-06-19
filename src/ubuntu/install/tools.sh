#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Install some common tools for further installation"
apt-get update 
apt-get install -y vim wget net-tools sudo terminator tmux git \
  python-virtualenv virtualenvwrapper
apt-get clean -y
