#!/bin/bash

# Update and upgrade the system
echo "Updating and upgrading the system..."
apt-get update -y
apt-get upgrade -y

# Install necessary packages
echo "Installing essential packages..."
apt-get install -y apache2 unzip wget software-properties-common

# Enable and start Apache
systemctl enable apache2
systemctl start apache2

# Add the PHP repository for the latest PHP versions

echo "Adding PHP repository..."
add-apt-repository ppa:ondrej/php -y
apt-get update -y

# Install PHP and required extensions
echo "Installing PHP 8.1 and extensions..."
apt-get install -y php8.1 libapache2-mod-php8.1 php8.1-mysql php8.1-curl php8.1-gd php8.1-xml php8.1-mbstring php8.1-zip

# Enable Apache modules
echo "Enabling required Apache modules..."
a2enmod php8.1 rewrite

# Create Apache virtual host configuration
echo "Creating Apache virtual host configuration..."
cat <<EOF > /etc/apache2/sites-available/opencart.conf
<VirtualHost *:80>
    ServerName ${SERVER_NAME}
    ServerAlias www.${SERVER_NAME}

    DocumentRoot ${INSTALL_FOLDER}
    <Directory ${INSTALL_FOLDER}>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/opencart_error.log
    CustomLog \${APACHE_LOG_DIR}/opencart_access.log combined
</VirtualHost>
EOF

# Disable the default site and enable OpenCart
echo "Enabling Apache Site..."
a2dissite 000-default.conf
a2ensite opencart.conf

# Restart Apache to apply changes
echo "Restarting Apache Service..."
systemctl restart apache2

echo "Apache with OpenCart configuration SUCCESSFULLY!"
