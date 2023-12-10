output "ssm_document_name" {
  value = var.document_name
}

output "send_ssm_command" {
  value = "aws ssm send-command --document-name ${var.document_name} --targets Key=tag:Service,Values=${var.service_name}"
}

output "alb_dns" {
  value = aws_lb.app_lb.dns_name
}

output "ssm_run_document_credential" {
  value = aws_ssm_parameter.user_credentials.name
}
