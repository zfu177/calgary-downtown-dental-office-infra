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

# Get my current public IP
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}
