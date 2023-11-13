resource "aws_ssm_document" "update_code" {
  name          = var.document_name
  document_type = "Command"

  content = <<DOC
{
  "schemaVersion" : "2.2",
  "description" : "Update code repo",
  "mainSteps" : [ {
    "action" : "aws:runShellScript",
    "name" : "update",
    "inputs" : {
      "workingDirectory": "/home/ec2-user/dental_office",
      "runCommand" : [ 
        "runuser -l ec2-user -c 'git pull",
        "runuser -l ec2-user -c 'sed -i 's/RUBY_VERSION=.*/RUBY_VERSION=3.0.6/g' Dockerfile'",
        "runuser -l ec2-user -c 'sed -i 's/config.force_ssl =.*/config.force_ssl = false/g' ./config/environments/production.rb'",
        "runuser -l ec2-user -c 'docker compose build'",
        "systemctl restart docker-compose-app"
        ]
    }
  } ]
}
DOC

  tags = var.additional_tags
}
