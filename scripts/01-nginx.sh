#!/bin/bash

# Update and upgrade the system
apt-get update -y
apt-get upgrade -y

# Install necessary packages
apt-get install nginx -y
apt install -y unzip wget php php-mysqli php-curl php-zip php-xml php-gd php-intl php-mbstring

# Enable and start NGINX
systemctl enable nginx
systemctl start nginx

# Nginx test page
echo "<h1>Hello from $(hostname)</h1>" > /var/www/html/index.html


# Create NGINX virtual host configuration for OpenCart with SSL termination at ALB (using HTTP for backend)

# Here starts the vHost configuration
# cat <<EOF > /etc/nginx/sites-available/opencart.conf
# server {
#     listen 80;
#     server_name ${SERVER_NAME} www.${SERVER_NAME};

#     root /var/www/html/opencart;
#     index index.php index.html index.htm;

#     access_log /var/log/nginx/opencart_access.log;
#     error_log /var/log/nginx/opencart_error.log;

#     # Handle requests
#     location / {
#         try_files \$uri \$uri/ /index.php?\$args;
#     }

#     # Handle PHP files
#     location ~ \.php\$ {
#         include snippets/fastcgi-php.conf;
#         fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
#         fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
#         include fastcgi_params;
#     }

#     # Handle static files (cache them for long periods)
#     location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot|otf)\$ {
#         expires max;
#         log_not_found off;
#     }

#     # Deny access to hidden files (e.g., .htaccess)
#     location ~ /\.ht {
#         deny all;
#     }
# }
# EOF

# # Enable the site by creating a symlink to the sites-enabled directory
# ln -s /etc/nginx/sites-available/opencart.conf /etc/nginx/sites-enabled/opencart.conf

# # Disable the default site
# rm -f /etc/nginx/sites-enabled/default

# # Reload NGINX to apply the changes
# systemctl reload nginx
