#!/bin/bash

apt-get update -y
apt-get upgrade -y

apt-get install nginx -y
systemctl enable nginx
systemctl start nginx

echo "<h1>Hello from $(hostname)</h1>" > /var/www/html/index.html
