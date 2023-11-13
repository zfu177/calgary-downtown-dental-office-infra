# Get private subnets
data "aws_subnets" "private_subnet" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  filter {
    name   = "map-public-ip-on-launch"
    values = ["false"]
  }
}

resource "aws_db_subnet_group" "default" {
  count      = var.db_subnet_group_name == "" ? 1 : 0
  name       = "${var.service_name}-subnet-group"
  subnet_ids = data.aws_subnets.private_subnet.ids

  tags = merge(var.additional_tags, {
    Name = "${var.service_name}-subnet-group"
  })
}

resource "random_password" "password" {
  length  = 16
  special = false
}

resource "aws_ssm_parameter" "db_url" {
  name        = "/${var.service_name}/${var.environment}/database_url"
  description = "The database credential of ${var.service_name}"
  type        = "SecureString"
  value       = "postgres://${var.db_username}:${random_password.password.result}@${module.rds_mysql.db_instance_address}/"

  tags = var.additional_tags
}

module "rds_mysql" {
  source = "terraform-aws-modules/rds/aws"

  identifier = var.service_name

  create_db_option_group    = false
  create_db_parameter_group = false

  # All available versions: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts
  engine               = "postgres"
  engine_version       = "14"
  family               = "postgres14" # DB parameter group
  major_engine_version = "14"         # DB option group
  instance_class       = var.instance_class

  allocated_storage = var.allocated_storage

  manage_master_user_password = false

  db_name  = var.db_name
  username = var.db_username
  password = random_password.password.result
  port     = 5432

  db_subnet_group_name   = try(var.db_subnet_group_name, aws_db_subnet_group.default[*].name)
  vpc_security_group_ids = [aws_security_group.rds.id]

  maintenance_window = "Sat:00:00-Sat:03:00"
  backup_window      = "03:00-06:00"

  backup_retention_period = 1
  storage_encrypted       = false

  skip_final_snapshot = true
  tags                = var.additional_tags
}
