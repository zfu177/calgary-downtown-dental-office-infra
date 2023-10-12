output "ec2_public_dns" {
  value = aws_instance.web.public_dns
}

output "ssm_document_name" {
  value = var.document_name
}
