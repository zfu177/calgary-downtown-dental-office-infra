# Create Key Pair
resource "aws_key_pair" "admin" {
  key_name   = var.key_name
  public_key = var.public_key
  tags       = var.additional_tags
}

resource "aws_cloudwatch_log_group" "server_log" {
  name              = "/app/${var.environment}/dentalOffice"
  retention_in_days = 7
  tags              = var.additional_tags
}

data "aws_ssm_parameter" "db_url" {
  name            = var.db_url_ssm_parameter_name
  with_decryption = true
}

resource "random_password" "secret_key_base" {
  length  = 16
  special = false
}

data "template_file" "user_data" {
  template = file("user_data.sh.tpl")

  vars = {
    environment     = var.environment
    log_group_name  = "/app/${var.environment}/dentalOffice"
    git_repository  = "https://github.com/gabrielsantos-bvc/dental_office.git"
    cw_config_path  = "/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json"
    db_url          = data.aws_ssm_parameter.db_url.value
    secret_key_base = random_password.secret_key_base.result
  }
}

resource "aws_launch_template" "web" {
  name = var.service_name
  iam_instance_profile {
    name = var.instance_profile_name == "" ? aws_iam_instance_profile.ec2_profile[0].name : var.instance_profile_name
  }

  image_id               = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.admin.key_name
  user_data              = base64encode(data.template_file.user_data.rendered)
  vpc_security_group_ids = [aws_security_group.ec2.id]

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.additional_tags, {
      Name = var.service_name
    })
  }

  depends_on = [aws_cloudwatch_log_group.server_log]
}


resource "aws_autoscaling_group" "web" {
  availability_zones = data.aws_availability_zones.us.names
  desired_capacity   = 1
  max_size           = 2
  min_size           = 1

  launch_template {
    id      = aws_launch_template.web.id
    version = aws_launch_template.web.latest_version
  }

  target_group_arns = [aws_lb_target_group.app_tg.arn]

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["tag"]
  }
}

data "aws_instance" "web" {

  filter {
    name   = "tag:Service"
    values = ["${var.service_name}"]
  }

  filter {
    name   = "tag:Environment"
    values = ["${var.environment}"]
  }

  filter {
    name   = "instance-state-name"
    values = ["running", "pending"]
  }

  depends_on = [aws_autoscaling_group.web]
}
