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
      "runCommand" : [ "runuser -l ec2-user -c 'cd ~/dental_office && git pull'" ]
    }
  } ]
}
DOC

  tags = var.additional_tags
}
