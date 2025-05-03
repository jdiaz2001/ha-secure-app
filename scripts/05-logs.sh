#!/bin/bash
apt-get update -y

# Install dependencies
apt-get install -y unzip curl

# Download and install the CloudWatch Agent
curl -O https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
dpkg -i -E ./amazon-cloudwatch-agent.deb

# Create CloudWatch Agent configuration file
cat > /opt/aws/amazon-cloudwatch-agent/bin/config.json <<EOF
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/syslog",
            "log_group_name": "syslog",
            "log_stream_name": "{instance_id}"
          },
          {
            "file_path": "/var/log/auth.log",
            "log_group_name": "auth.log",
            "log_stream_name": "{instance_id}"
          },
          {
            "file_path": "/var/log/nginx/access.log",
            "log_group_name": "nginx-access.log",
            "log_stream_name": "{instance_id}"
          },
          {
            "file_path": "/var/log/nginx/error.log",
            "log_group_name": "nginx-error.log",
            "log_stream_name": "{instance_id}"
          },
          {
            "file_path": "/var/log/mysql/error.log",
            "log_group_name": "mysql-error.log",
            "log_stream_name": "{instance_id}"
          },
          {
            "file_path": "/var/log/awslogs.log",
            "log_group_name": "awslogs.log",
            "log_stream_name": "{instance_id}"
          },
          {
            "file_path": "/var/log/cloud-init.log",
            "log_group_name": "cloud-init.log",
            "log_stream_name": "{instance_id}"
          },
          {
            "file_path": "/var/log/cloud-init-output.log",
            "log_group_name": "cloud-init-output.log",
            "log_stream_name": "{instance_id}"
          },
          {
            "file_path": "/var/log/dpkg.log",
            "log_group_name": "dpkg.log",
            "log_stream_name": "{instance_id}"
          },
          {
            "file_path": "/var/log/apt/history.log",
            "log_group_name": "apt-history.log",
            "log_stream_name": "{instance_id}"
          },
          {
            "file_path": "/var/log/apt/term.log",
            "log_group_name": "apt-term.log",
            "log_stream_name": "{instance_id}"
          }
        ]
      }
    }
  }
}
EOF

# Start the CloudWatch Agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json \
  -s
