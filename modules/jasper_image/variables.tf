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

variable "jasper_image_name" {
  description = "Image name you want to deploy"
  type        = "string"
}

variable "jasper_image_resource_group_name" {
  description = "The Image Resource group name"
  type        = "string"
}

variable "jasper_disk_size" {}

variable "virtual_machine_name" {
  type    = "string"
  default = ""
}

variable "availabilityset_name" {
  type    = "string"
  default = ""
}

variable "count" {
  default = 1
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

variable "lb_backendpool_id" {
  default = ""
}

variable "vm_size" {
  default = "Standard_ds2_v2"
}

variable "environment" {}

variable "lb_attach" {}

variable "lbname" {}

variable "subscription_id" {}

variable "managed_disk_type" {}
variable "managed_data_disk_type" {}
