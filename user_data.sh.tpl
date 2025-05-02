#!/bin/bash

# Set environment variables for use in scripts
export NEW_USERNAME="${username}"
export NEW_PASSWORD="${password}"
export EFS_ID="${efs_id}"
export DB_ENDPOINT="${db_endpoint}"

# --- Run Scripts ---
echo "Running NGINX setup"
${nginx_script}

echo "Creating user"
${user_script}

echo "Mounting EFS"
${efs_script}

echo "Installing MariaDB client"
${rds_script}

echo "Running system update"
${update_script}
