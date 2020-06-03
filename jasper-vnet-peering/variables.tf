variable "prefix" {
    description = "Please enter you zsignum entered in terraform vnet_subnet deployment"
    type = "string"
}
variable "remote_rg" {
    description = "Please enter remote resource group name for vnet peering"
    type = "string"
}
variable "admin_username" {
    description = "Administartor username"
    default = "Developer"
}
variable "admin_password" {
    description = "Administartor password"
    default = "MetraTech$01"
}
variable "client_id" {
  description = "Client identification"
  type = "string"
}
variable "client_secret" {
  description = "Client secret"
  type = "string"
}
variable "tenant_id" {
  description = "tenant id"
  type = "string"
}
variable "subscription_id" {
  description = "subscription identification"
  type = "string"
}
variable "local_time" {
  description = "Time in 24 hr format Input ex: 1900 (7pm)"
  type = "string"
}
variable "local_time_zone" {
  description = "Time zone Input ex: Eastern Standard Time, India Standard Time"
  type = "string"
}
