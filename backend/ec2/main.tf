
# Security Group 
resource "aws_security_group" "web" {
  name        = "allow-ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
  }

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPs from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(var.additional_tags, {
    Name = "allow-ssh"
  })
}

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
  vpc_security_group_ids = [aws_security_group.web.id]
  subnet_id              = try(var.subnet_id, data.aws_subnets.default.ids[0])
  user_data              = file("user_data.sh")
  iam_instance_profile   = var.iam_instance_profile

  root_block_device {
    volume_size = 8
  }

  tags = merge(var.additional_tags, {
    Name = var.service_name
  })
}
