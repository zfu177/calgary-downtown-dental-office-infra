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
      "runCommand" : [ "cd /root/dental_office", "git pull" ]
    }
  } ]
}
DOC

  tags = {
    "Administrator" = var.administrator
    "Environment"   = var.environment
    "Service"       = var.service_name
    "Terraform"     = true
  }
}
