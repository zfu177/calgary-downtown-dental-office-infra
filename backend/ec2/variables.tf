variable "service_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "public_key" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "document_name" {
  type = string
}

variable "additional_tags" {
  default     = {}
  description = "Additional resource tags"
  type        = map(string)
}

variable "rds_security_group_id" {
  type = string
}

variable "db_url_ssm_parameter_arn" {
  type = string
}

variable "db_url_ssm_parameter_name" {
  type = string
}

variable "instance_profile_name" {
  type = string
}

variable "key_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "admin_email" {
  type = string
}


variable "public_subnet_ids" {
  type = list(string)
}
