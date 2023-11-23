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
      "runCommand" : [
        "su - ec2-user -c 'cd /home/ec2-user/dental_office && git pull'",
        "su - ec2-user -c 'cd /home/ec2-user/dental_office && sed -i \"s/RUBY_VERSION=.*/RUBY_VERSION=3.0.6/g\" Dockerfile'",
        "su - ec2-user -c 'cd /home/ec2-user/dental_office && sed -i \"s/config.force_ssl =.*/config.force_ssl = false/g\" ./config/environments/production.rb'",
        "su - ec2-user -c 'cd /home/ec2-user/dental_office && docker compose build'",
        "systemctl restart dentaloffice"
        ]
    }
  } ]
}
DOC

  tags = var.additional_tags
}