#!/bin/bash

useradd -m -s /bin/bash "$NEW_USERNAME"
echo "$NEW_USERNAME:$NEW_PASSWORD" | chpasswd
usermod -aG sudo "$NEW_USERNAME"

# Set PasswordAuthentication to yes in sshd_config
sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
grep -q '^PasswordAuthentication' /etc/ssh/sshd_config || echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config

# Optional: Add override config file and delete old one
echo "PasswordAuthentication yes" > /etc/ssh/sshd_config.d/60-enable-password-auth.conf
rm -f /etc/ssh/sshd_config.d/60-cloudimg-settings.conf

# Restart SSH service
systemctl restart ssh
