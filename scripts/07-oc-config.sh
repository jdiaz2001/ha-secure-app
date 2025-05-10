#!/bin/bash

CONFIG_FILE="${INSTALL_FOLDER}/config.php"

# Backup the original file
cp "$CONFIG_FILE" "$CONFIG_FILE.bak"

# Comment out and add new HTTP/HTTPS_SERVER definitions
sed -i "/define('HTTP_SERVER', 'http:\/\/${SERVER_NAME}\/opencart\/');/ {
    s/^/\/\/ /
    a define('HTTP_SERVER', 'https://${SERVER_NAME}/');
    a define('HTTPS_SERVER', 'https://${SERVER_NAME}/');
}" "$CONFIG_FILE"

# Comment out and add new DIR_STORAGE definition
sed -i "/define('DIR_STORAGE', DIR_SYSTEM . 'storage\/');/ {
    s/^/\/\/ /
    a define('DIR_STORAGE', '/mnt/efs/www/storage/');
}" "$CONFIG_FILE"

echo "Modifications completed. Original file backed up as config.php.bak"

#!/bin/bash

CONFIG_FILE_2="${INSTALL_FOLDER}/admin/config.php"

# Backup the original file
cp "$CONFIG_FILE_2" "$CONFIG_FILE_2.bak"

# Comment and replace HTTP_SERVER
sed -i "/define('HTTP_SERVER', 'http:\/\/${SERVER_NAME}\/opencart\/admin\/');/ {
    s/^/\/\/ /
    a define('HTTP_SERVER', 'https://${SERVER_NAME}/admin/');
}" "$CONFIG_FILE_2"

# Comment and replace HTTP_CATALOG
sed -i "/define('HTTP_CATALOG', 'http:\/\/${SERVER_NAME}\/opencart\/');/ {
    s/^/\/\/ /
    a define('HTTP_CATALOG', 'https://${SERVER_NAME}/');
}" "$CONFIG_FILE_2"

# Comment and replace DIR_STORAGE
sed -i "/define('DIR_STORAGE', DIR_SYSTEM . 'storage\/');/ {
    s/^/\/\/ /
    a define('DIR_STORAGE', '/mnt/efs/www/storage/');
}" "$CONFIG_FILE_2"

echo "Modifications completed for admin/config.php. Backup created as config.php.bak"
