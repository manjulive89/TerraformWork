variable "local_time" {
  description = "Time in 24 hr format Input ex: 1900 (7pm)"
  type        = "string"
}

variable "local_time_zone" {
  description = "Time zone Input ex: Eastern Standard Time, India Standard Time"
  type        = "string"
}

variable "virtual_machine_name" {
  type = "list"
}

variable "resource_group_name" {
  description = "Time zone Input ex: Eastern Standard Time, India Standard Time"
  type        = "string"
}

variable "subscription_id" {}
variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}
variable "Email" {}
variable "NotificationStatus" {}
variable "Enable_AutoShutDown" {}
