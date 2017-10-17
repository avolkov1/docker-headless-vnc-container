#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Install Paraview"
apt-get update 
sudo apt-get install -y paraview python-vtk

# Cleanup
apt-get clean -y
