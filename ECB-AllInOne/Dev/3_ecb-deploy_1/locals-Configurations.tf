terraform {
  required_version = "~>0.11.8"

  backend "azurerm" {
    container_name = "ecb-tfstate"
    key            = "ecb-terraform.tfstate"
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
  sql_subnet_name          = "${var.prefix}-vnet-private-snet"
  jsp_subnet_name          = "${var.prefix}-vnet-public-snet"
  vtx_subnet_name          = "${var.prefix}-vnet-public-snet"
  ecb_subnet_name          = "${var.prefix}-vnet-public-snet"
  jb_subnet_name           = "${var.prefix}-vnet-jump-snet"
  ecb_virtual_machine_name = "${var.prefix}${var.ECBServerVMName}"
  jsp_virtual_machine_name = "${var.prefix}${var.JasperVMName}"
  vtx_virtual_machine_name = "${var.prefix}${var.VertexVMName}"
  ecb_lb_name              = "${var.prefix}${var.ECB_AllInOne_LB_Name}"
  jsp_lb_name              = "${var.prefix}${var.JasperLBName}"
  vtx_lb_name              = "${var.prefix}${var.VertexLBName}"
  ecb_avset_name           = "${var.prefix}${var.ECB_AllInOne_AvSet_Name}"
  jsp_avset_name           = "${var.prefix}${var.Jasper_AvSet_Name}"
  vtx_avset_name           = "${var.prefix}${var.Vertex_AvSet_Name}"
}
