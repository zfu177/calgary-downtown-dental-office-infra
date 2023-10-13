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

variable "identifier" {
  type    = string
  default = "dental-office"
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "instance_class" {
  type    = string
  default = "db.t2.micro"
}

variable "allocated_storage" {
  type    = number
  default = 20
}

variable "source_security_group_id" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "db_subnet_group_name" {
  type = string
}

variable "db_name" {
  type    = string
  default = "dental_office_development"
}

variable "username" {
  type    = string
  default = "dev1"
}
