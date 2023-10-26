variable "service_name" {
  type    = string
  default = "dental-office"
}

variable "environment" {
  type = string
}


variable "instance_class" {
  type    = string
  default = "db.t2.micro"
}

variable "allocated_storage" {
  type    = number
  default = 20
}

variable "vpc_id" {
  type = string
}


variable "db_name" {
  type    = string
  default = "dental_office_development"
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "additional_tags" {
  default     = {}
  description = "Additional resource tags"
  type        = map(string)
}
