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
apt-get install docker-ce
apt-get clean -y
