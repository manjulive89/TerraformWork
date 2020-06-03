terraform {
  required_version = "~>0.11.8"
}

provider "azurerm" {
  version         = "~>1.27.0"
}

provider "null" {
  version = "~>2.1.0"
}

provider "azuread" {
  version = "~>0.6.0"
}
