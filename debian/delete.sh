#!/bin/bash

if [ "$#" -ne 1 ]; then
	echo "Must provide the program to delete."
	exit 1
fi

echo "Started Deleting $1"
echo "========================================"
sudo apt-get -y --purge remove $1
sudo apt-get -y --purge autoremove
echo "========================================"
echo "Finished Deleting $1"
