variable "service_name" {
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
  description = "The security group id which allows to access RDS"
  type        = string
}

variable "vpc_id" {
  type    = string
  default = "vpc-0cfc992e72fac8cde"
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

variable "additional_tags" {
  default     = {}
  description = "Additional resource tags"
  type        = map(string)
}
