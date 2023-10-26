locals {
  db_credential = {
    username             = var.db_username
    password             = var.db_password
    host                 = module.rds_mysql.db_instance_address
    port                 = 3306
    dbname               = var.db_name
    dbInstanceIdentifier = var.service_name

  }
}

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
  name       = "${var.service_name}-subnet-group"
  subnet_ids = data.aws_subnets.private_subnet.ids

  tags = merge(var.additional_tags, {
    Name = "${var.service_name}-subnet-group"
  })
}

resource "aws_ssm_parameter" "db_credential" {
  name        = "/${var.service_name}/${var.environment}/database/credential"
  description = "The database credential of ${var.service_name}"
  type        = "SecureString"
  value       = jsonencode(local.db_credential)

  tags = var.additional_tags
}

module "rds_mysql" {
  source = "terraform-aws-modules/rds/aws"

  identifier = var.service_name

  create_db_option_group    = false
  create_db_parameter_group = false

  # All available versions: http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_MySQL.html#MySQL.Concepts.VersionMgmt
  engine               = "mysql"
  engine_version       = "8.0"
  family               = "mysql8.0" # DB parameter group
  major_engine_version = "8.0"      # DB option group
  instance_class       = var.instance_class

  allocated_storage = var.allocated_storage

  manage_master_user_password = false

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = 3306

  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  maintenance_window = "Sat:00:00-Sat:03:00"
  backup_window      = "03:00-06:00"

  backup_retention_period = 1
  storage_encrypted       = false


  skip_final_snapshot = true
  tags                = var.additional_tags
}
