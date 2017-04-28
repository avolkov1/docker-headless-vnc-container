#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Install Docker"
apt-get update 
apt-get install -y apt-transport-https ca-certificates curl software-properties-common
apt-get clean -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update 
apt-get install -y docker-ce
apt-get clean -y

echo "Install NVIDIA Docker wrapper"
wget -P /tmp https://github.com/NVIDIA/nvidia-docker/releases/download/v1.0.1/nvidia-docker_1.0.1-1_amd64.deb
dpkg -i /tmp/nvidia-docker*.deb && rm /tmp/nvidia-docker*.deb
ln -s /bin/true /usr/local/bin/nvidia-modprobe
