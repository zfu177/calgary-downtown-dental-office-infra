variable "environment" {
  type = string
}

variable "bucket_name" {
  type = string
}

variable "service_name" {
  type = string
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "public_key" {
  type = string
}

variable "additional_tags" {
  default     = {}
  description = "Additional resource tags"
  type        = map(string)
}

variable "vpc_id" {
  type = string
}


variable "db_username" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}


