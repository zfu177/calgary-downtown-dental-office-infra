# Get private subnet Ids
data "aws_subnets" "default" {
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
  name       = var.identifier
  subnet_ids = try(var.private_subnet_ids, data.aws_subnets.default.ids)

  tags = {
    Name          = "${var.identifier}-subnet-group"
    Service       = "${var.service_name}"
    Environment   = var.environment
    Administrator = var.administrator
    Terraform     = true
  }
}

module "db_default" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "${var.identifier}-default"

  create_db_option_group    = false
  create_db_parameter_group = false

  # All available versions: http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_MySQL.html#MySQL.Concepts.VersionMgmt
  engine               = "mysql"
  engine_version       = "8.0"
  family               = "mysql8.0" # DB parameter group
  major_engine_version = "8.0"      # DB option group
  instance_class       = var.instance_class

  allocated_storage = var.allocated_storage

  db_name  = var.db_name
  username = var.username
  port     = 3306

  db_subnet_group_name   = try(var.db_subnet_group_name, aws_db_subnet_group.default.name)
  vpc_security_group_ids = [aws_security_group.rds.id]

  maintenance_window = "Sat:00:00-Sat:03:00"
  backup_window      = "03:00-06:00"

  backup_retention_period = 1

  tags = {
    Service       = "${var.service_name}"
    Environment   = var.environment
    Administrator = var.administrator
    Terraform     = true
  }
}
