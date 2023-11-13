# Create Key Pair
resource "aws_key_pair" "admin" {
  key_name   = "admin-key"
  public_key = var.public_key
  tags       = var.additional_tags
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.admin.key_name
  vpc_security_group_ids = [var.security_group_id]
  subnet_id              = data.aws_subnets.public.ids[0]
  user_data              = file("user_data.sh")
  iam_instance_profile   = try(var.instance_profile_name, aws_iam_instance_profile.ec2_profile[*].name)

  root_block_device {
    volume_size = 8
  }

  tags = merge(var.additional_tags, {
    Name = var.service_name
  })
}
