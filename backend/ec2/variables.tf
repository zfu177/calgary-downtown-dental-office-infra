variable "service_name" {
  type    = string
  default = "dental-office"
}

variable "public_key" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "document_name" {
  type    = string
  default = "update-code"
}

variable "additional_tags" {
  default     = {}
  description = "Additional resource tags"
  type        = map(string)
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "security_group_id" {
  type = string
}

variable "db_credential_ssm_parameter_arn" {
  type = string
}
