terraform {
  required_version = "~>0.11.8"

  backend "azurerm" {
    # container_name = "ecb1-tfstate"
    # key            = "ecb1-terraform.tfstate"
  }
}

provider "azurerm" {
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  tenant_id       = "${var.tenant_id}"
}

locals {
  resource_group_name      = "e-${var.prefix}-${var.environment}"
  virtual_network_name     = "${var.prefix}-vnet-${var.environment}"
  aag_subnet_name          = "${var.prefix}-vnet-aag-snet"
  api_subnet_name          = "${var.prefix}-vnet-public-snet"
  mvw_subnet_name          = "${var.prefix}-vnet-public-snet"
  jsp_subnet_name          = "${var.prefix}-vnet-internal-snet"
  vtx_subnet_name          = "${var.prefix}-vnet-internal-snet"
  prp_subnet_name          = "${var.prefix}-vnet-internal-snet"
  is_subnet_name           = "${var.prefix}-vnet-internal-snet"
  sep_subnet_name          = "${var.prefix}-vnet-internal-snet"
  ws_subnet_name           = "${var.prefix}-vnet-internal-snet"
  sql_subnet_name          = "${var.prefix}-vnet-private-snet"
  jb_subnet_name           = "${var.prefix}-vnet-jump-snet"
  is_virtual_machine_name  = "${var.prefix}${var.IntegrationServerVMName}"
  mvw_virtual_machine_name = "${var.prefix}${var.MetraViewVMName}"
  prp_virtual_machine_name = "${var.prefix}${var.PrimaryPipelineVMName}"
  api_virtual_machine_name = "${var.prefix}${var.RestAPIVMName}"
  sep_virtual_machine_name = "${var.prefix}${var.SecondaryPipelineVMName}"
  ws_virtual_machine_name  = "${var.prefix}${var.WebServerVMName}"
  jsp_virtual_machine_name = "${var.prefix}${var.JasperVMName}"
  vtx_virtual_machine_name = "${var.prefix}${var.VertexVMName}"
  is_lb_name               = "${var.prefix}${var.IntegrationServerLBName}"
  mvw_lb_name              = "${var.prefix}${var.MetraViewLBName}"
  api_lb_name              = "${var.prefix}${var.RestAPILBName}"
  ws_lb_name               = "${var.prefix}${var.WebServerLBName}"
  jsp_lb_name              = "${var.prefix}${var.JasperLBName}"
  vtx_lb_name              = "${var.prefix}${var.VertexLBName}"
  is_avset_name            = "${var.prefix}${var.IntegrationServer_AvSet_Name}"
  ws_avset_name            = "${var.prefix}${var.WebServer_AvSet_Name}"
  mvw_avset_name           = "${var.prefix}${var.MetraView_AvSet_Name}"
  api_avset_name           = "${var.prefix}${var.RestAPI_AvSet_Name}"
  prp_avset_name           = "${var.prefix}${var.PRP_AvSet_Name}"
  sep_avset_name           = "${var.prefix}${var.SEP_AvSet_Name}"
  jsp_avset_name           = "${var.prefix}${var.Jasper_AvSet_Name}"
  vtx_avset_name           = "${var.prefix}${var.Vertex_AvSet_Name}"
}
