variable "service_name" {
  type    = string
  default = "server"
}

variable "vpc_cidr_base" {
  type    = string
  default = "10.0"
}

variable "az_count" {
  type    = string
  default = "3"
}

variable "port" {
  type    = number
  default = 8080
}
