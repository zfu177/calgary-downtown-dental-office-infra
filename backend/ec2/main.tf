# Create Key Pair
resource "aws_key_pair" "admin" {
  key_name   = var.key_name
  public_key = var.public_key
  tags       = var.additional_tags
}

resource "aws_cloudwatch_log_group" "server_log" {
  name              = "/${var.service_name}/${var.environment}/server-logs"
  retention_in_days = 7
  tags              = var.additional_tags
}

resource "aws_launch_template" "web" {
  name = var.service_name
  iam_instance_profile {
    name = try(var.instance_profile_name, aws_iam_instance_profile.ec2_profile[*].name)
  }

  image_id               = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.admin.key_name
  user_data              = filebase64("user_data.sh")
  vpc_security_group_ids = [var.security_group_id]

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.additional_tags, {
      Name = var.service_name
    })
  }
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

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["tag"]
  }
}
