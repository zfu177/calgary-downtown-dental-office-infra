data "aws_ami" "amazon_linux_2" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "block-device-mapping.volume-size"
    values = [8]
  }

  filter {
    name   = "name"
    values = ["al2023-ami-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

data "aws_region" "current" {}

data "aws_availability_zones" "us" {
  filter {
    name   = "region-name"
    values = [data.aws_region.current.name]
  }
}

# Get public subnet IDs

data "aws_subnets" "public" {
  for_each = toset(data.aws_availability_zones.us.zone_ids)

  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  filter {
    name   = "map-public-ip-on-launch"
    values = ["true"]
  }

  filter {
    name   = "availability-zone-id"
    values = ["${each.value}"]
  }
}


# Get my current public IP
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}
