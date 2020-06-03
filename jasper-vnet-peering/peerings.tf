# Configure the Microsoft Azure Provider
provider "azurerm" {
    subscription_id = "${var.subscription_id}"
    client_id       = "${var.client_id}"
    client_secret   = "${var.client_secret}"
    tenant_id       = "${var.tenant_id}"
}
locals {
virtual_network_name = "${var.prefix}-vnet"
resource_group_name  = "${var.prefix}-rg"
jasper_peering_name = "${var.prefix}-peering"
ecb_peering_name = "${var.remote_rg}-peering"
jasper_vnet_name = "${var.remote_rg}-vnet"
}
data "azurerm_virtual_network" "jasper_vnet" {
  name                = "${local.jasper_vnet_name}"
  resource_group_name = "${var.remote_rg}"
}
data "azurerm_virtual_network" "ecb_vnet" {
  name                = "${local.virtual_network_name}"
  resource_group_name = "${local.resource_group_name}"
}
# ecb vnet peerings
resource "azurerm_virtual_network_peering" "ecb-vnet-peering" {
  name                      = "${local.ecb_peering_name}"
  resource_group_name       = "${local.resource_group_name}"
  virtual_network_name      = "${local.virtual_network_name}"
  remote_virtual_network_id = "${data.azurerm_virtual_network.jasper_vnet.id}"
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit = true
}
# jasper vnet peerings
resource "azurerm_virtual_network_peering" "jasper-vnet-peering" {
  name                      = "${local.jasper_peering_name}"
  resource_group_name       = "${var.remote_rg}"
  virtual_network_name      = "${local.jasper_vnet_name}"
  remote_virtual_network_id = "${data.azurerm_virtual_network.ecb_vnet.id}"
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit = true
}

