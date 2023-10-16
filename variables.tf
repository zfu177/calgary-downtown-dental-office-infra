variable "bucket_name" {
  type = string
}

variable "service_name" {
  type = string
}

variable "public_key" {
  type = string
}

variable "additional_tags" {
  default     = {}
  description = "Additional resource tags"
  type        = map(string)
}
