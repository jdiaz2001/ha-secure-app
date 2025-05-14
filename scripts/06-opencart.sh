#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Redirect all output to cloud-init-output.log and console
exec > >(tee -a /var/log/cloud-init-output.log | logger -t user-data -s 2>/dev/console) 2>&1

# Variables
OPENCART_VERSION="4.0.2.3"
DB_HOST="$DB_ENDPOINT"                      # Injected by Terraform
SERVER="$SERVER_NAME"                       # Injected by Terraform
DB_NAME="opencart"
DB_USER="$DB_USERNAME"                      # Injected by Terraform
DB_PASS="$DB_PASSWORD"                      # Injected by Terraform
ADMIN_USER="admin"
ADMIN_PASS="$NEW_PASSWORD"                  # Injected by Terraform
ADMIN_EMAIL="testemail@gmail.com"
INSTALL_DIR="/mnt/efs/www/html/opencart"  
WEB_USER="www-data"
MAX_RETRIES=30
RETRY_DELAY=10

# Wait for EFS to be mounted
echo "Waiting for EFS mount at ${INSTALL_DIR}"
for ((i=1; i<=MAX_RETRIES; i++)); do
    if mountpoint -q "/mnt/efs"; then
        echo "EFS is mounted."
        break
    else
        echo "Attempt $i: EFS not mounted yet. Retrying in ${RETRY_DELAY}s..."
        sleep ${RETRY_DELAY}
    fi

    if [ "$i" -eq "$MAX_RETRIES" ]; then
        echo "ERROR: EFS not mounted after $MAX_RETRIES attempts."
        exit 1
    fi
done

# Wait for MySQL to be ready
echo "Waiting for MySQL at ${DB_HOST} to become available"
for ((i=1;i<=MAX_RETRIES;i++)); do
    if mysqladmin ping -h${DB_HOST} -u${DB_USER} -p${DB_PASS} --silent; then
        echo "MySQL is available."
        break
    else
        echo "Attempt $i: MySQL not available yet. Retrying in ${RETRY_DELAY}s..."
        sleep ${RETRY_DELAY}
    fi

    if [ "$i" -eq "$MAX_RETRIES" ]; then
        echo "ERROR: MySQL not available after $MAX_RETRIES attempts."
        exit 1
    fi
done

# Download and Install OpenCart
echo "Downloading OpenCart ${OPENCART_VERSION}"
wget -q "https://github.com/opencart/opencart/releases/download/${OPENCART_VERSION}/opencart-${OPENCART_VERSION}.zip" -O /tmp/opencart.zip

echo "Extracting OpenCart"
unzip -q /tmp/opencart.zip -d /tmp/opencart
cp -r /tmp/opencart/opencart-${OPENCART_VERSION}/upload/* "${INSTALL_DIR}"
cp "${INSTALL_DIR}/config-dist.php" "${INSTALL_DIR}/config.php"
cp "${INSTALL_DIR}/admin/config-dist.php" "${INSTALL_DIR}/admin/config.php"

echo "Setting permissions for Opencart Folder"
chown -R ${WEB_USER}:${WEB_USER} "${INSTALL_DIR}"
chmod -R 755 "${INSTALL_DIR}"

echo "Creating database if not exists"
mysql -h${DB_HOST} -u${DB_USER} -p${DB_PASS} -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"

echo "Install Opencart"
PHP_SCRIPT="${INSTALL_DIR}/install/cli_install.php"

php "$PHP_SCRIPT" install \
  --username "${ADMIN_USER}" \
  --email "${ADMIN_EMAIL}" \
  --password "${ADMIN_PASS}" \
  --http_server "http://${SERVER}/opencart/" \
  --db_driver mysqli \
  --db_hostname "${DB_HOST}" \
  --db_username "${DB_USER}" \
  --db_password "${DB_PASS}" \
  --db_database "${DB_NAME}" \
  --db_port 3306 \
  --db_prefix oc_

echo "Cleaning up Instalation files"
rm -rf "${INSTALL_DIR}/install"

echo "Moving storage directory"
mv "${INSTALL_DIR}/system/storage/" /mnt/efs/www/

echo "OpenCart installation complete!"
