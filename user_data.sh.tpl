#!/bin/bash

# Set environment variables for use in scripts
export NEW_USERNAME="${username}"
export NEW_PASSWORD="${password}"
export DB_USERNAME="${db_username}"
export DB_PASSWORD="${db_password}"
export EFS_ID="${efs_id}"
export DB_ENDPOINT="${db_endpoint}"
export SERVER_NAME="${server_name}"
export INSTALL_FOLDER="${install_folder}"

# Order in which scripts are run

echo "Exporting Logs to CloudWatch"
${logs_script}

echo "Creating user"
${user_script}

echo "Running Apache setup"
${apache_script}

echo "Mounting EFS"
${efs_script}

echo "Installing MariaDB client"
${rds_script}

echo "Installing OpenCart"
${opencart_script}

echo "Modifying Config files OpenCart"
${oc_config_script}

echo "Running system update"
${update_script}

