output "db_instance_address" {
  value = module.db_default.db_instance_address
}

output "db_instance_master_user_secret_arn" {
  value = module.db_default.db_instance_master_user_secret_arn
}

output "db_instance_cloudwatch_log_groups" {
  value = module.db_default.db_instance_cloudwatch_log_groups
}
