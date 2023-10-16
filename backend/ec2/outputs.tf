output "ec2_public_dns" {
  value = aws_instance.web.public_dns
}

output "ssm_document_name" {
  value = var.document_name
}

output "security_group_id" {
  value = aws_security_group.web.id
}
