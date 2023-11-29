#!/bin/bash -e
yum update && yum upgrade -y

# Install CloudWatch Agent docker, docker compose
yum install -y git docker amazon-cloudwatch-agent vim amazon-ssm-agent
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent
usermod -aG docker ec2-user
systemctl enable docker
systemctl start docker

mkdir -p /usr/local/lib/docker/cli-plugins/
curl -SL https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose


# Configure CloudWatch

cat <<EOF >${cw_config_path}
{
  "agent": {
    "metrics_collection_interval": 30,
    "logfile": "/var/log/amazon-cloudwatch-agent.log"
  },
  "metrics":{
      "namespace":"${metrics_namespace}",
      "append_dimensions":{
         "AutoScalingGroupName":"${auto_scaling_group_name}",
         "InstanceId":"{instance_id}"
      },
      "aggregation_dimensions":[
         [
            "AutoScalingGroupName"
         ]
      ],
      "metrics_collected":{
         "mem":{
            "measurement":[
               {
                  "name":"mem_used_percent",
                  "rename":"MemoryUtilization",
                  "unit":"Percent"
               }
            ],
            "metrics_collection_interval":30
         }
      }
   },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/lib/docker/containers/**.log",
            "log_group_name": "${log_group_name}",
            "log_stream_name": "{instance_id}",
            "timezone": "UTC"
          }
        ]
      }
    },
    "log_stream_name": "{instance_id}"
  }
}
EOF

# load cloudwatch agent config file and start
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config -m ec2 -s \
  -c file:${cw_config_path}

# Clone repository
cd /home/ec2-user && git clone ${git_repository}
cd /home/ec2-user/dental_office
sed -i 's/RUBY_VERSION=.*/RUBY_VERSION=3.0.6/g' Dockerfile
sed -i 's/config.force_ssl =.*/config.force_ssl = false/g' ./config/environments/production.rb

# Create docker compose file

cat <<EOF >compose.yaml
services:
  app:
    build: .
    ports:
      - 80:3000
    environment:
      DATABASE_URL: '${db_url}'
      SECRET_KEY_BASE: '${secret_key_base}'
EOF

chown -R ec2-user:ec2-user /home/ec2-user/dental_office

# Create Systemctl service
cat <<EOF >/etc/systemd/system/dentaloffice.service
[Unit]
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
WantedBy=multi-user.target"
EOF

runuser -l ec2-user -c 'docker compose -f /home/ec2-user/dental_office/compose.yaml build'

systemctl enable dentaloffice
systemctl start dentaloffice

TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/instance-id)

aws autoscaling complete-lifecycle-action \
  --instance-id $INSTANCE_ID \
  --lifecycle-hook-name "${lifecycle_hook_name}" \
  --auto-scaling-group-name "${auto_scaling_group_name}" \
  --lifecycle-action-result CONTINUE

echo "Job is done!"