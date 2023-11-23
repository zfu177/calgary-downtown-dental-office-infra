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
