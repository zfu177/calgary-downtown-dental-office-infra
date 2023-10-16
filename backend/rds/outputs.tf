output "db_instance_address" {
  value = module.rds_mysql.db_instance_address
}

output "db_instance_master_user_secret_arn" {
  value = module.rds_mysql.db_instance_master_user_secret_arn
}

output "db_instance_cloudwatch_log_groups" {
  value = module.rds_mysql.db_instance_cloudwatch_log_groups
}
