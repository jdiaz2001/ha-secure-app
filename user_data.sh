#!/bin/bash

# Update and install Nginx
apt-get update -y
apt-get install nginx -y
systemctl enable nginx
systemctl start nginx
echo "<h1>Hello from $(hostname)</h1>" > /var/www/html/index.html

# Set ubuntu user password
echo "ubuntu=${ubuntu_password}" | chpasswd

# Allow SSH password authentication
sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config

# Ensure cloud-init allows SSH password login
cat <<EOF > /etc/cloud/cloud.cfg.d/99-ssh-password-auth.cfg
disable_root: false
ssh_pwauth: true
EOF

# Restart SSH to apply config
systemctl restart ssh
