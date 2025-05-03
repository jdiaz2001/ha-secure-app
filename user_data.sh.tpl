#!/bin/bash

# Set environment variables for use in scripts
export NEW_USERNAME="${username}"
export NEW_PASSWORD="${password}"
export EFS_ID="${efs_id}"
export DB_ENDPOINT="${db_endpoint}"
export SERVER_NAME="${server_name}"

# --- Run Scripts ---
echo "Exporting Logs to CloudWatch"
${logs_script}

echo "Creating user"
${user_script}

echo "Running NGINX setup"
${nginx_script}

echo "Installing MariaDB client"
${rds_script}

#echo "Configuring NGINX virtual host for OpenCart"
#${opencart_script}

echo "Mounting EFS"
${efs_script}

echo "Running system update"
${update_script}

