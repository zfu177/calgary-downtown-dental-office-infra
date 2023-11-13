#!/bin/bash -ex
yum update && yum upgrade -y

# Install CloudWatch Agent docker, docker compose
yum install -y git docker amazon-cloudwatch-agent vim
usermod -aG docker ec2-user
systemctl enable docker
systemctl start docker

mkdir -p /usr/local/lib/docker/cli-plugins/
curl -SL https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose


# Configure CloudWatch
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
            "file_path": "/var/lib/docker/containers/**.log",
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
cd /home/ec2-user && git clone https://github.com/gabrielsantos-bvc/dental_office.git
cd /home/ec2-user/dental_office
sed -i 's/RUBY_VERSION=.*/RUBY_VERSION=3.0.6/g' Dockerfile
sed -i 's/config.force_ssl =.*/config.force_ssl = false/g' ./config/environments/production.rb

DB_URL=$(aws ssm get-parameter --name /clcm3102-group1-dental-office/production/database_url --with-decryption --query "Parameter.Value")

echo 'services:
  app:
    build: .
    ports:
      - 80:3000
    environment:
      DATABASE_URL: '${DB_URL}'
      SECRET_KEY_BASE: abcdefg
' > compose.yaml

chown -R ec2-user:ec2-user /home/ec2-user/dental_office

echo '[Unit]
Description=Docker Compose Application Service
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/home/ec2-user/dental_office
ExecStart=/usr/bin/docker compose up -d
ExecStop=/usr/bin/docker compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target' > /etc/systemd/system/docker-compose-app.service

systemctl enable docker-compose-app
systemctl start docker-compose-app
