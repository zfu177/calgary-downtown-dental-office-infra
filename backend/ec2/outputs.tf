output "ec2_public_dns" {
  value = aws_instance.web.public_dns
}

output "ssh_cmmand" {
  value = "ssh -i PRIVATE_KEY ec2-user@${aws_instance.web.public_dns}"
}

output "ssm_document_name" {
  value = var.document_name
}

output "send_ssm_command" {
  value = "aws ssm send-command --document-name ${var.document_name} --region ${var.region} --targets Key=tag:Service,Values=${var.service_name}"
}
