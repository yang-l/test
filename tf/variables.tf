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

variable "gh_owner" {
  type    = string
  default = "yang-l"
}

variable "gh_repo" {
  type    = string
  default = "test"
}

variable "gh_branch" {
  type    = string
  default = "main"
}

variable "gh_oauth_token" {
  type    = string
  default = "REPLACE_ME"
}
