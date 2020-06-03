variable "environment" {
  default = "Prod"
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

#----- Set to "true" to add vm's to the backend pool else put "false"
variable "lb_attach" {
  default = "true"
}

#----- Set to "true" to REMOVE VM's from the backend pool else put "false" to not Trigger
variable "lb_detach" {
  default = "false"
}

#----- Count of VM for each Profile
variable "mvw_vm_count" {
  default = 1
  type    = "string"
}

variable "prp_vm_count" {
  default = 1
  type    = "string"
}

variable "api_vm_count" {
  default = 1
  type    = "string"
}

variable "is_vm_count" {
  default = 1
  type    = "string"
}

variable "ws_vm_count" {
  default = 1
  type    = "string"
}

variable "sep_vm_count" {
  default = 1
  type    = "string"
}

variable "jsp_vm_count" {
  default = 1
  type    = "string"
}

variable "jasper_disk_size" {
  default = "1023"
}

variable "vtx_vm_count" {
  default = 0
  type = "string"
}

#-----Virtual Machine Size for each profile
variable "api_vm_size" {
  default = "Standard_D2_v3"
}

variable "is_vm_size" {
  default = "Standard_D2_v3"
}

variable "mvw_vm_size" {
  default = "Standard_D2_v3"
}

variable "prp_vm_size" {
  default = "Standard_D2_v3"
}

variable "sep_vm_size" {
  default = "Standard_D2_v3"
}

variable "jsp_vm_size" {
  default = "Standard_D2_v3"
}

variable "ws_vm_size" {
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

#----- Set Vm names as deployment 2
variable "IntegrationServerVMName" {
  default = "sapi2"
}

variable "MetraViewVMName" {
  default = "mview2"
}

variable "PrimaryPipelineVMName" {
  default = "ratea2"
}

variable "SecondaryPipelineVMName" {
  default = "rateb2"
}

variable "RestAPIVMName" {
  default = "rapi2"
}

variable "WebServerVMName" {
  default = "ecb2"
}

variable "JasperVMName" {
  default = "jaspr2"
}

variable "VertexVMName" {
  default = "vtx2"
}

#------ Loadbalancer name which are to assocaited to the  profile
variable "IntegrationServerLBName" {
  default = "sapi"
}

variable "MetraViewLBName" {
  default = "mview"
}

variable "PrimaryPipelineLBName" {
  default = "ratea"
}

variable "SecondaryPipelineLBName" {
  default = "rateb"
}

variable "RestAPILBName" {
  default = "rapi"
}

variable "WebServerLBName" {
  default = "ecb"
}

variable "JasperLBName" {
  default = "jaspr"
}

variable "VertexLBName" {
  default = "vtx"
}

#-----Set availability names matching your profile names
variable "IntegrationServer_AvSet_Name" {
  default = "sapi"
}

variable "WebServer_AvSet_Name" {
  default = "ecb"
}

variable "MetraView_AvSet_Name" {
  default = "mview"
}

variable "RestAPI_AvSet_Name" {
  default = "rapi"
}

variable "Jasper_AvSet_Name" {
  default = "jaspr"
}

variable "Vertex_AvSet_Name" {
  default = "vtx"
}

variable "PRP_AvSet_Name" {
  default = "ratea"
}

variable "SEP_AvSet_Name" {
  default = "rateb"
}

#----- Managed disk types
variable "prp_managed_disk_type" {
  default = "Standard_LRS"
}

variable "sep_managed_disk_type" {
  default = "Standard_LRS"
}

variable "api_managed_disk_type" {
  default = "Standard_LRS"
}

variable "mvw_managed_disk_type" {
  default = "Standard_LRS"
}

variable "ws_managed_disk_type" {
  default = "Standard_LRS"
}

variable "is_managed_disk_type" {
  default = "Standard_LRS"
}

variable "jsp_managed_disk_type" {
  default = "Standard_LRS"
}

variable "jsp_managed_data_disk_type" {
  default = "Standard_LRS"
}

variable "vtx_managed_disk_type" {}
