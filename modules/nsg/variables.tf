variable "subnet_name" {}

variable "virtual_network_name" {}

variable "address_prefix" {}

variable "nsg_rules" {
  description = "Protocols to be used for lb health probes and rules. [frontend_port, protocol, backend_port]"
  default     = {}
}

variable "resource_group_name" {}
variable "prefix" {}
variable "environment" {}
