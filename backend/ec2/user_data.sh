#!/bin/bash

yum update && yum upgrade -y

# Install CloudWatch Agent
yum install -y git ruby amazon-cloudwatch-agent

# Install SSM Agent
yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
systemctl start amazon-ssm-agent

ruby -v

cd /root
git clone https://github.com/gabrielsantos-bvc/dental_office.git

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
            "log_group_name": "prod-server.log",
            "timezone": "UTC"
          }
        ]
      }
    },
    "log_stream_name": "/prod/server/prod-server.log"
  }
}' > ${CW_CONFIG_PATH}

# load cloudwatch agent config file and start
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config -m ec2 -s \
  -c file:${CW_CONFIG_PATH}