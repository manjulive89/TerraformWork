terraform {
  required_version = "~>0.11.8"

  backend "azurerm" {
    container_name = "mssql-jb-tfstate"
    key            = "mssql-jb-terraform.tfstate"
  }
}

provider "azurerm" {
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  tenant_id       = "${var.tenant_id}"
}

provider "azuread" {}

locals {
  resource_group_name                 = "e-${var.prefix}-${var.environment}"
  virtual_network_name                = "${var.prefix}-vnet-${var.environment}"
  sql_subnet_name                     = "${var.prefix}-vnet-private-snet"
  jb_subnet_name                      = "${var.prefix}-vnet-jump-snet"
  JB_virtual_machine_name             = "${var.prefix}${var.JumpHostVMName}"
  sql_virtual_machine_name            = "${var.prefix}${var.SqlVMName}"
  az_key_vault_name                   = "${var.prefix}-${var.environment}-vault"
  user_key_permissions                = ["get", "list", "update", "create", "import", "Delete", "Recover", "backup", "restore"]
  user_secret_permissions             = ["get", "list", "set", "delete", "recover", "backup", "restore"]
  user_certificate_permissions        = ["backup", "create", "delete", "deleteissuers", "get", "getissuers", "import", "list", "listissuers", "managecontacts", "managecontacts", "manageissuers", "recover", "restore", "setissuers", "update"]
  application_key_permissions         = ["get", "list", "update", "create", "import", "delete", "recover", "backup", "restore"]
  application_secret_permissions      = ["get", "list", "set", "delete", "recover", "backup", "restore"]
  application_certificate_permissions = ["backup", "create", "delete", "deleteissuers", "get", "getissuers", "import", "list", "listissuers", "managecontacts", "managecontacts", "manageissuers", "recover", "restore", "setissuers", "update"]
}
