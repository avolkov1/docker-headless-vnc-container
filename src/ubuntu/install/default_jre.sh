#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Install Default JRE"
apt-get update 
apt-get install -y default-jre
apt-get clean -y

