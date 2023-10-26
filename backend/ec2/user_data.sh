#!/bin/bash -ex

yum update && yum upgrade -y

# Install CloudWatch Agent
yum install -y git ruby amazon-cloudwatch-agent vim

# Install SSM Agent
yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
systemctl start amazon-ssm-agent

ruby -v

# Configu CloudWatch
export CW_CONFIG_PATH=/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

echo '{
  "agent": {
    "metrics_collection_interval": 30,
    "logfile": "/var/log/amazon-cloudwatch-agent.log"
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/root/dental_office/log/errors.log",
            "log_group_name": "/clcm3102-group1-dental-office/backend/server-logs",
            "timezone": "UTC"
          }
        ]
      }
    },
    "log_stream_name": "dental-office-server-log"
  }
}' > ${CW_CONFIG_PATH}

# load cloudwatch agent config file and start
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config -m ec2 -s \
  -c file:${CW_CONFIG_PATH}

# Clone repository
runuser -l ec2-user -c 'cd ~ && git clone https://github.com/gabrielsantos-bvc/dental_office.git'