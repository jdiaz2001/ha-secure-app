#!/bin/bash

#----- EFS MOUNTING -----
# --- Variables ---
EFS_MOUNT_POINT="/mnt/efs"
INSTALL_DIR="${EFS_MOUNT_POINT}/www/html/opencart"  # Fully resolved install path
WEB_USER="www-data"

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

# Create base mount point
echo "=== Creating EFS mount point at ${EFS_MOUNT_POINT} ==="
mkdir -p "${EFS_MOUNT_POINT}"

# Mount the EFS file system
echo "=== Mounting the EFS file system ==="
mount -t efs -o tls "$EFS_ID":/ "${EFS_MOUNT_POINT}"

# Wait for the mount to be ready
echo "=== Waiting for EFS mount ==="
MAX_RETRIES=30
RETRY_DELAY=5
for ((i=1; i<=MAX_RETRIES; i++)); do
    if mountpoint -q "$EFS_MOUNT_POINT"; then
        echo "EFS successfully mounted at ${EFS_MOUNT_POINT}"
        break
    else
        echo "Attempt $i: EFS not mounted yet. Retrying in $RETRY_DELAY seconds..."
        sleep $RETRY_DELAY
    fi

    if [ "$i" -eq "$MAX_RETRIES" ]; then
        echo "ERROR: EFS not mounted after $MAX_RETRIES attempts."
        exit 1
    fi
done

echo "=== Creating healthcheck file ==="

# Ensure the installation directory exists
if [ ! -d "${INSTALL_DIR}" ]; then
  echo "INSTALL_DIR does not exist: ${INSTALL_DIR}. Creating it now..."
  mkdir -p "${INSTALL_DIR}"
  
  if [ $? -eq 0 ]; then
    echo "INSTALL_DIR created successfully: ${INSTALL_DIR}"
  else
    echo "ERROR: Failed to create INSTALL_DIR: ${INSTALL_DIR}"
    exit 1
  fi
else
  echo "INSTALL_DIR already exists: ${INSTALL_DIR}"
fi

# Now create the healthcheck file
echo "OK" > "${INSTALL_DIR}/healthcheck.html"
echo "Healthcheck file created at ${INSTALL_DIR}/healthcheck.html"


# Optional: Set permissions
# chown -R ${WEB_USER}:${WEB_USER} ${INSTALL_DIR}
# chmod -R 755 ${INSTALL_DIR}
