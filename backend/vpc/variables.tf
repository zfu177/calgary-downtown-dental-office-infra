
variable "vpc_name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "additional_tags" {
  default     = {}
  description = "Additional resource tags"
  type        = map(string)
}
