#!/bin/bash
# Update the system and install Nginx
apt-get update -y
apt-get install nginx -y
systemctl enable nginx
systemctl start nginx
echo "<h1>Hello from $(hostname)</h1>" > /var/www/html/index.html

# Create user
useradd -m -s /bin/bash ${username}
echo "${username}:${password}" | chpasswd
usermod -aG sudo ${username}

# Enable password authentication in SSH
sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl restart ssh

# Install dependencies
apt-get install -y git binutils curl build-essential libssl-dev pkg-config \
    libprotobuf-dev protobuf-compiler cmake

# Install Rust (this will include 'cargo'), automatically proceeding with the default option
# this error was encounter when intalling efs-utils on ubuntu 24.04
export CARGO_HOME=/root/.cargo
export PATH=$CARGO_HOME/bin:$PATH
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source /root/.cargo/env

# Check if cargo is installed
if ! command -v cargo &> /dev/null; then
    # If cargo is not found, source the environment file to make it available
    source /root/.cargo/env
fi

# Install amazon-efs-utils from source (official method for Ubuntu)
git clone https://github.com/aws/efs-utils /tmp/efs-utils
cd /tmp/efs-utils
./build-deb.sh

# Install the built EFS-utils package
apt install -y ./build/amazon-efs-utils*deb

# Create mount directory
mkdir -p /mnt/efs

# Mount the EFS file system
mount -t efs -o tls ${efs_id}:/ /mnt/efs
