variable "service_name" {
  type        = string
  description = "Naming convention prefix"
  default     = "server"
}

variable "vpc_cidr_base" {
  default = "10.0"
}

variable "az_count" {
  default = "3"
}
