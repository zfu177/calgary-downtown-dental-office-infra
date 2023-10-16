resource "aws_security_group" "rds" {
  name        = "rds-default-sg"
  description = "Allow inbound traffic from ec2"
  vpc_id      = var.vpc_id

  ingress {
    description     = "3306 from ec2"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.source_security_group_id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(var.additional_tags, {
    Name = "rds-default-sg"
  })
}
