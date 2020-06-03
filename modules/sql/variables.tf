variable "sql_image_publisher" {
  default = "MicrosoftSQLServer"
}

variable "sql_image_offer" {
  default = "SQL2016SP2-WS2016"
}

variable "sql_image_sku" {}

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
  type = "string"
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
  default = "Standard_D2_v3"
}

variable "environment" {}
variable "managed_disk_type" {}
