variable "environment" {
  default = "Dev"
}

#----- Setup secrets in the powershell windows as an environment variables
variable "client_id" {
  description = "Client identification"
  type        = "string"
}

variable "client_secret" {
  description = "Client secret"
  type        = "string"
}

variable "tenant_id" {
  description = "tenant id"
  type        = "string"
}

variable "subscription_id" {
  description = "subscription identification"
  type        = "string"
}

variable "object_id" {
  description = "user identification"
  type        = "string"  
}

variable "prefix" {
  description = "Please enter PREFIX, which is used in rg and storage account creation"
  type        = "string"
}

#-----Set Autoshutdown time and time zone
variable "Enable_AutoShutDownVM" {
  default = "true"
}

variable "Enable_AutoShutDownVM_Email" {
  default = "naveen.com"
}

variable "Status_AutoShutDownVM_Notification" {
  default = "Disable"
}

variable "Enable_AutoShutDownVM_time" {
  description = "Time in 24 hr format Input ex: 1900 (7pm)"
  type        = "string"
  default     = "1900"
}

variable "Enable_AutoShutDownVM_time_zone" {
  description = "Time zone Input ex: Eastern Standard Time, India Standard Time"
  type        = "string"
  default     = "Eastern Standard Time"
}

#-----Virtual Machine Size for each profile
variable "sql_vm_size" {
  default = "Standard_D2_v3"
}

variable "jb_vm_size" {
  default = "Standard_ds2_v2"
}

#-----Set username and password for server-profile vm's and jumpbox vm
variable "admin_username" {
  description = "Administartor username"
  default     = "Developer"
}

variable "admin_password" {
  description = "Administartor password"
  default     = ""
}

variable "jb_admin_username" {
  description = "Administartor username"
  default     = "Developer"
}

variable "jb_admin_password" {
  description = "Administartor password"
  default     = ""
}

#----- Set VM Names
variable "JumpHostVMName" {
  default = "jumpbox"
}

variable "SqlVMName" {
  default = "sql-db"
}

#----- Managed disk types
variable "sql_managed_disk_type" {
  default = "Standard_LRS"
}

variable "jb_vm_count" {}

variable "sql_image_sku" {}

variable "azure_user_email_id" {
  default = ""
}
