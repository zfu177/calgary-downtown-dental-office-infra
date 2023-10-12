variable "administrator" {
  type = string
}

variable "environment" {
  type = string
}


variable "service_name" {
  type    = string
  default = "dental_office"
}

variable "public_key" {
  type = string
}

variable "vpc_id" {
  type    = string
  default = "vpc-0cfc992e72fac8cde"
}

variable "subnet_id" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "iam_instance_profile" {
  type    = string
  default = "LabInstanceProfile"
}

variable "document_name" {
  type    = string
  default = "update_code"
}
