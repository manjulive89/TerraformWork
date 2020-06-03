variable "lbname" {
  type        = "string"
  description = "The azure Intername Loadbalancer Name"
}

variable "lb_type" {
  type = "string"
}

variable "resource_group_name" {
  type = "string"
}

variable "location" {
  type = "string"
}

variable "public_ip_address_allocation" {
  type    = "string"
  default = "dynamic"
}

variable "lb_port" {
  description = "Protocols to be used for lb health probes and rules. [frontend_port, protocol, backend_port]"
  default     = {}
}

variable "count" {}

variable "subnet_name" {}

variable "virtual_network_name" {}

variable "prefix" {}
variable "environment" {}
