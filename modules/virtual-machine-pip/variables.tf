variable "prefix" {
  description = "Please enter you zsignum entered in terraform vnet_subnet deployment"
  type        = "string"
}

variable "admin_username" {
  description = "Administartor username"
  default     = "Developer"
}

variable "admin_password" {
  description = "Administartor password"
  default     = ""
}

variable "virtual_machine_name" {
  type    = "string"
  default = ""
}

variable "subnet_name" {
  type = "string"
}

variable "virtual_network_name" {
  type = "string"
}

variable "resource_group_name" {
  type = "string"
}

variable "vm_size" {
  default = ""
}

variable "environment" {}

variable "count" {}
