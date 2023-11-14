output "ec2_public_dns" {
  value = data.aws_instance.web.public_dns
}

output "ssm_document_name" {
  value = var.document_name
}

output "send_ssm_command" {
  value = "aws ssm send-command --document-name ${var.document_name} --targets Key=tag:Service,Values=${var.service_name}"
}
