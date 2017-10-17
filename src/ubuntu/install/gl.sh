#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Install packages for OpenGL apps"
apt-get update 
apt-get install -y freeglut3 freeglut3-dev mesa-utils

# VirtualGL
echo "Install VirtualGL"
wget -P /tmp https://downloads.sourceforge.net/project/virtualgl/2.5.2/virtualgl_2.5.2_amd64.deb
dpkg -i /tmp/virtualgl*.deb && rm /tmp/virtualgl*.deb

# Cleanup
apt-get clean -y
