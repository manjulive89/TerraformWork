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

variable "custom_image_name" {
  description = "Image name you want to deploy"
  type        = "string"
}

variable "custom_image_resource_group_name" {
  description = "The Image Resource group name"
  type        = "string"
}

variable "jasper_image_name" {
  description = "Jasper Image name you want to deploy"
  type        = "string"
}

variable "jasper_image_resource_group_name" {
  description = "Jasper Image Resource group name"
  type        = "string"
}

variable "vertex_image_name" {
  description = "Vertex Image name you want to deploy"
  type        = "string"
}

variable "vertex_image_resource_group_name" {
  description = "Vertex Image Resource group name"
  type        = "string"
}

#-----Change the size of the jasper data disk which will be attached to the vm.
variable "jasper_disk_size" {
  default = "1023"
}

variable "prefix" {
  description = "Please enter you zsignum entered in terraform vnet_subnet deployment"
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
}

variable "Enable_AutoShutDownVM_time_zone" {
  description = "Time zone Input ex: Eastern Standard Time, India Standard Time"
  type        = "string"
}

#----- Set to "true" to add vm's to the backend pool else put "false"
variable "lb_attach" {
  default = "true"
}

#----- Set to "true" to REMOVE VM's from the backend pool else put "false" to not Trigger
variable "lb_detach" {
  default = "false"
}

#-----Count of VM
variable "ecb_vm_count" {
  default = 1
  type    = "string"
}

variable "jsp_vm_count" {
  default = 1
  type    = "string"
}

variable "vtx_vm_count" {
  default = 0
  type    = "string"
}

#-----Virtual Machine Size for each profile
variable "ecb_vm_size" {
  default = "Standard_D8_v3"
}

variable "sql_vm_size" {
  default = "Standard_D2_v3"
}

variable "jb_vm_size" {
  default = "Standard_ds2_v2"
}

variable "jsp_vm_size" {
  default = "Standard_D2_v3"
}

variable "vtx_vm_size" {
  default = "Standard_D2_v3"
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

#----- Set Vm names as deployment 1
variable "ECBServerVMName" {
  default = "aio1"
}

variable "JasperVMName" {
  default = "jaspr1"
}

variable "VertexVMName" {
  default = "vtx1"
}

#------ Loadbalancer name which are to assocaited to the  profile
variable "ECB_AllInOne_LB_Name" {
  default = "aio"
}

variable "JasperLBName" {
  default = "jaspr"
}

variable "VertexLBName" {
  default = "vtx"
}

#-----Set availability names matching your profile names
variable "ECB_AllInOne_AvSet_Name" {
  default = "aio"
}

variable "Jasper_AvSet_Name" {
  default = "jaspr"
}

variable "Vertex_AvSet_Name" {
  default = "vtx"
}

#----- Managed disk types
variable "ecb_managed_disk_type" {
  default = "Standard_LRS"
}

variable "jsp_managed_disk_type" {
  default = "Standard_LRS"
}

variable "jsp_managed_data_disk_type" {
  default = "Standard_LRS"
}

variable "vtx_managed_disk_type" {}
