output "db_instance_address" {
  value = module.rds_mysql.db_instance_address
}

output "db_url_ssm_parameter_arn" {
  value = aws_ssm_parameter.db_url.arn
}

output "db_url_ssm_parameter_name" {
  value = aws_ssm_parameter.db_url.name
}

output "db_instance_cloudwatch_log_groups" {
  value = module.rds_mysql.db_instance_cloudwatch_log_groups
}

output "db_instance_identifier" {
  value = var.service_name
}

output "db_name" {
  value = var.db_name
}

output "db_username" {
  value = var.db_username
}

output "ec2_security_group_id" {
  value = aws_security_group.ec2.id
}
