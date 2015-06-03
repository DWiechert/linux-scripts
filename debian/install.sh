#!/bin/bash

if [ "$#" -ne 2 ]; then
	echo "Must provide both the ppa and program to install."
	exit 1
fi

echo "Started Installing $2"
echo "========================================"
sudo add-apt-repository -y $1
sudo apt-get update
sudo apt-get install -y $2
echo "========================================"
echo "Finished Installing $2"
