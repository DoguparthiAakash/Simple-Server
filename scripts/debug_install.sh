#!/bin/bash
LOGFILE="/mnt/d/Github_Projects/Simple-Server/install.log"
exec > >(tee -a "$LOGFILE") 2>&1

echo "Starting installation at $(date)"
echo "User: $(whoami)"

echo "Running apt-get update..."
sudo apt-get update

echo "Running apt-get install..."
sudo apt-get install -y golang git make xorriso wget

echo "Checking versions..."
go version
make --version

echo "Installation complete at $(date)"
