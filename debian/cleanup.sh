#!/bin/bash

echo "Starting Cleaning Up"
echo "========================================"
sudo apt-get -f install
sudo apt-get autoremove
sudo apt-get -y autoclean
sudo apt-get -y clean
echo "========================================"
