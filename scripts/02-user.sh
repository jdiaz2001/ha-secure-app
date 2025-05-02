#!/bin/bash

useradd -m -s /bin/bash "$NEW_USERNAME"
echo "$NEW_USERNAME:$NEW_PASSWORD" | chpasswd
usermod -aG sudo "$NEW_USERNAME"

sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl restart ssh
