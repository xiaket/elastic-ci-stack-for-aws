#!/bin/bash
set -eu -o pipefail

FIRECRACKER_VERSION=0.16.0
FIRECTL_VERSION=0.1.0

# This performs a manual install of Firecracker.

echo "Downloading firecracker..."
curl -Lo firecracker https://github.com/firecracker-microvm/firecracker/releases/download/v${FIRECRACKER_VERSION}/firecracker-v${FIRECRACKER_VERSION}
chmod +x firecracker
sudo mv firecracker /usr/bin/firecracker

echo "Downloading firectl..."
curl -Lo firectl https://firectl-release.s3.amazonaws.com/firectl-v${FIRECTL_VERSION}
sudo chmod +x firectl
sudo mv firectl /usr/bin/firectl

