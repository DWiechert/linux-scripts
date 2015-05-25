#!/bin/bash

echo "Starting Updating"
echo "========================================"
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get -y dist-upgrade
echo "========================================"
echo "Finished Updating"
