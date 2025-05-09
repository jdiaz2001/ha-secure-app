#!/bin/bash

#----- EFS MOUNTING -----

# Install dependencies
apt-get install -y git binutils curl build-essential libssl-dev pkg-config \
    libprotobuf-dev protobuf-compiler cmake

# Install Rust (required for building efs-utils)
echo "=== Install Rust (required for building efs-utils) ==="
export CARGO_HOME=/root/.cargo
export PATH=$CARGO_HOME/bin:$PATH
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source /root/.cargo/env

# Ensure `cargo` is in the environment
if ! command -v cargo &> /dev/null; then
    source /root/.cargo/env
fi

# Install amazon-efs-utils from source
echo "=== Install amazon-efs-utils from source ==="
git clone https://github.com/aws/efs-utils /tmp/efs-utils
cd /tmp/efs-utils
./build-deb.sh
apt install -y ./build/amazon-efs-utils*deb

# Mount the EFS file system
echo "=== Mount the EFS file system ==="
mkdir -p /mnt/efs
mount -t efs -o tls "$EFS_ID":/ /mnt/efs
