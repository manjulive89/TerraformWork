variable "location" {
  default = "eastus"
}

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

variable "prefix" {
  description = "Please enter PREFIX, which is used in rg and storage account creation"
  type        = "string"
}

variable "vnet_address_space" {
  description = "Adress Space of the Vnet"
  type        = "string"
}

#-----Set profiles count before deploying vm's and should match the count in other deployments
variable "ecb_vm_count" {
  default = 1
  type    = "string"
}

variable "jsp_vm_count" {
  default = 1
  type    = "string"
}

variable "vtx_vm_count" {
  default = 1
  type    = "string"
}

#-----Set LB names matching the profile of vm deployment
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

# variable "subnet_name" {
#   type    = "string"
#   default = ""
# }

