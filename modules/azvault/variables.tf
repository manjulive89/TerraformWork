variable "prefix" {
  description = "Please enter you zsignum entered in terraform vnet_subnet deployment"
  type        = "string"
}

variable "resource_group_name" {
  type = "string"
}

variable "key_vault_name" {}

variable "user_principal_name" {}

variable "tenant_id" {}

variable "environment" {}

variable "user_key_permissions" {
  type = "list"
}

variable "user_secret_permissions" {
  type = "list"
}

variable "user_certificate_permissions" {
  type = "list"
}

variable "application_key_permissions" {
  type = "list"
}

variable "application_secret_permissions" {
  type = "list"
}

variable "application_certificate_permissions" {
  type = "list"
}

variable "object_id" {
  
}
