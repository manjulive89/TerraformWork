variable "location" {
  default = "East US"
}

variable "environment" {
  default = "QA"
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

variable "prefix" {
  description = "Please enter PREFIX, which is used in rg and storage account creation"
  type        = "string"
}

variable "vnet_address_space" {
  description = "Adress Space of the Vnet"
  type        = "string"
}

#-----Set profiles count before deploying vm's and should match the count in other deployments
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

variable "vtx_vm_count" {
  default = 0
  type    = "string"
}

#-----Set LB names matching the profile of vm deployment
variable "IntegrationServerLBName" {
  default = "sapi"
}

variable "JumpHostLBName" {
  default = "jumpbox"
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

variable "SqlLBName" {
  default = "sql-db"
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

# variable "subnet_name" {
#   type    = "string"
#   default = ""
# }

