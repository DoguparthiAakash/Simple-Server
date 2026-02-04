#!/bin/bash
set -e

echo "Updating package list..."
sudo apt-get update

echo "Installing development dependencies..."
sudo apt-get install -y golang git make

echo "Environment setup complete."
echo "You can now build the server with: make build"
