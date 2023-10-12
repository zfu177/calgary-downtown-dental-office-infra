
# Security Group 
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name          = "allow_ssh"
    Administrator = var.administrator
    Terraform     = true
  }
}

# Create Key Pair
resource "aws_key_pair" "admin" {
  key_name   = "admin-key"
  public_key = var.public_key
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.admin.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  subnet_id              = try(var.subnet_id, data.aws_subnets.default.ids[0])
  user_data              = file("user_data.sh")
  iam_instance_profile   = var.iam_instance_profile

  root_block_device {
    volume_size = 8
  }

  tags = {
    Name          = "${var.service_name}"
    Environment   = var.environment
    Administrator = var.administrator
    Terraform     = true
  }
}
