resource "aws_security_group" "rds" {
  name        = "${var.service_name}-${var.environment}-rds-sg"
  description = "Allow inbound traffic from ec2"
  vpc_id      = var.vpc_id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(var.additional_tags, {
    Name = "${var.service_name}-${var.environment}-rds-sg"
  })
}

resource "aws_security_group_rule" "allow_ec2" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ec2.id
  security_group_id        = aws_security_group.rds.id
}

# Security Group 
resource "aws_security_group" "ec2" {
  name        = "${var.service_name}-ec2-sg"
  description = "Allow SSH, HTTP, HTTPS inbound traffic"
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

  tags = merge(var.additional_tags, {
    Name = "${var.service_name}-${var.environment}-ec2-sg"
  })
}
