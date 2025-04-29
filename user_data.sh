#!/bin/bash
sudo apt-get update -y
sudo apt-get install nginx -y
sudo systemctl enable nginx
sudo systemctl start nginx
echo "<h1>Hello from $(hostname)</h1>" | sudo tee /var/www/html/index.html

# Change ubuntu user password
    echo 'ubuntu:${var.ubuntu_password}' | sudo chpasswd