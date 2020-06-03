# Configure the Microsoft Azure backend during deployment
terraform {
  required_version = "~>0.11.8"

  backend "azurerm" {
    container_name = "vnet-subnet-tfstate"
    key            = "vnet-subnet-terraform.tfstate"
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  tenant_id       = "${var.tenant_id}"
}

locals {
  resource_group_name  = "e-${var.prefix}-${var.environment}"
  virtual_network_name = "${var.prefix}-vnet-${var.environment}"
  ecb_lb_name          = "${var.prefix}${var.ECB_AllInOne_LB_Name}"
  jsp_lb_name          = "${var.prefix}${var.JasperLBName}"
  vtx_lb_name          = "${var.prefix}${var.VertexLBName}"
  ecb_avset_name       = "${var.prefix}${var.ECB_AllInOne_AvSet_Name}"
  jsp_avset_name       = "${var.prefix}${var.Jasper_AvSet_Name}"
  vtx_avset_name       = "${var.prefix}${var.Vertex_AvSet_Name}"

  subnet_names = [
    "${var.prefix}-vnet-aag-snet",
    "${var.prefix}-vnet-jump-snet",
    "${var.prefix}-vnet-private-snet",
    "${var.prefix}-vnet-public-snet",
  ]

  subnet_cidr = ["${split(".",var.vnet_address_space)}"]
}

data "azurerm_resource_group" "ECB_Resource_Group" {
  name = "${local.resource_group_name}"
}

data "azurerm_storage_account" "ECB_Diag_StorageAccount" {
  name                = "ecbaasenv${lower(var.environment)}${lower(var.prefix)}"
  resource_group_name = "${data.azurerm_resource_group.ECB_Resource_Group.name}"
}

resource "azurerm_storage_container" "ECB_sshkeys" {
  name                 = "ssh"
  resource_group_name  = "${data.azurerm_resource_group.ECB_Resource_Group.name}"
  storage_account_name = "${data.azurerm_storage_account.ECB_Diag_StorageAccount.name}"
}

resource "azurerm_storage_container" "ECB_sshkeys_2" {
  name                 = "ssh2"
  resource_group_name  = "${data.azurerm_resource_group.ECB_Resource_Group.name}"
  storage_account_name = "${data.azurerm_storage_account.ECB_Diag_StorageAccount.name}"
}

resource "azurerm_storage_container" "Environment_Configuraion" {
  name                 = "environment-configuration"
  resource_group_name  = "${data.azurerm_resource_group.ECB_Resource_Group.name}"
  storage_account_name = "${data.azurerm_storage_account.ECB_Diag_StorageAccount.name}"
}

resource "azurerm_storage_container" "Environment_Configuraion_2" {
  name                 = "environment-configuration2"
  resource_group_name  = "${data.azurerm_resource_group.ECB_Resource_Group.name}"
  storage_account_name = "${data.azurerm_storage_account.ECB_Diag_StorageAccount.name}"
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "ECB_virtual_Network" {
  name                = "${local.virtual_network_name}"
  address_space       = ["${var.vnet_address_space}"]
  location            = "${data.azurerm_resource_group.ECB_Resource_Group.location}"
  resource_group_name = "${data.azurerm_resource_group.ECB_Resource_Group.name}"

  tags {
    "prefix"      = "${var.prefix}"
    "environment" = "${var.environment}"
  }
}

#-----Module for subnets named in locals
module "aag_NSG" {
  source               = "../../.././modules/nsg"
  environment          = "${var.environment}"
  prefix               = "${var.prefix}"
  subnet_name          = "${local.subnet_names[index(local.subnet_names, "${var.prefix}-vnet-aag-snet")]}"
  virtual_network_name = "${azurerm_virtual_network.ECB_virtual_Network.name}"
  resource_group_name  = "${data.azurerm_resource_group.ECB_Resource_Group.name}"
  address_prefix       = "${local.subnet_cidr[0]}.${local.subnet_cidr[1]}.${index(local.subnet_names, "${var.prefix}-vnet-aag-snet")}.0/24"

  "nsg_rules" {
    http  = ["inbound", "allow", "Tcp", "*", "80", "*", "*"]
    https = ["inbound", "allow", "Tcp", "*", "443", "*", "*"]
  }

  #NSG rules should be definded in the below format
  # Syntax for defining rule
  # http  = ["direction", "access", "Protocol","source_port","destination_port","source_address","destination_address"]
  # example rule
  # http  = ["inbound", "allow", "Tcp","80","80","*","*"]
}

module "Private_NSG" {
  source               = "../../.././modules/nsg"
  environment          = "${var.environment}"
  prefix               = "${var.prefix}"
  subnet_name          = "${local.subnet_names[index(local.subnet_names, "${var.prefix}-vnet-private-snet")]}"
  virtual_network_name = "${azurerm_virtual_network.ECB_virtual_Network.name}"
  resource_group_name  = "${data.azurerm_resource_group.ECB_Resource_Group.name}"
  address_prefix       = "${local.subnet_cidr[0]}.${local.subnet_cidr[1]}.${index(local.subnet_names, "${var.prefix}-vnet-private-snet")}.0/24"

  "nsg_rules" {
    http    = ["inbound", "allow", "Tcp", "*", "80", "*", "*"]
    https   = ["inbound", "allow", "Tcp", "*", "443", "*", "*"]
    sqlrule = ["inbound", "allow", "Tcp", "*", "1433", "*", "*"]
    sqlport = ["inbound", "allow", "Tcp", "*", "135", "*", "*"]
    winrm   = ["inbound", "allow", "Tcp", "*", "5985", "*", "*"]
  }

  #NSG rules should be definded in the below format
  # Syntax for defining rule
  # http  = ["direction", "access", "Protocol","source_port","destination_port","source_address","destination_address"]
  # example rule
  # http  = ["inbound", "allow", "Tcp","80","80","*","*"]
}

module "Public_NSG" {
  source               = "../../.././modules/nsg"
  environment          = "${var.environment}"
  prefix               = "${var.prefix}"
  subnet_name          = "${local.subnet_names[index(local.subnet_names, "${var.prefix}-vnet-public-snet")]}"
  virtual_network_name = "${azurerm_virtual_network.ECB_virtual_Network.name}"
  resource_group_name  = "${data.azurerm_resource_group.ECB_Resource_Group.name}"
  address_prefix       = "${local.subnet_cidr[0]}.${local.subnet_cidr[1]}.${index(local.subnet_names, "${var.prefix}-vnet-public-snet")}.0/24"

  "nsg_rules" {
    http                    = ["inbound", "allow", "Tcp", "*", "80", "*", "*"]
    https                   = ["inbound", "allow", "Tcp", "*", "443", "*", "*"]
    winrm                   = ["inbound", "allow", "Tcp", "*", "5985", "*", "*"]
    metraview-ui            = ["inbound", "allow", "Tcp", "*", "8080", "*", "*"]
    metraview-config        = ["inbound", "allow", "Tcp", "*", "8081", "*", "*"]
    metraview-api           = ["inbound", "allow", "Tcp", "*", "8082", "*", "*"]
    metraview-security      = ["inbound", "allow", "Tcp", "*", "8083", "*", "*"]
    ecb-api-zuul-gateway    = ["inbound", "allow", "Tcp", "*", "8711", "*", "*"]
    ecb-api-billing         = ["inbound", "allow", "Tcp", "*", "8091", "*", "*"]
    ecb-api-customer        = ["inbound", "allow", "Tcp", "*", "8095", "*", "*"]
    ecb-api-foundation      = ["inbound", "allow", "Tcp", "*", "8097", "*", "*"]
    ecb-api-pricing         = ["inbound", "allow", "Tcp", "*", "8099", "*", "*"]
    ecb-api-product-catalog = ["inbound", "allow", "Tcp", "*", "8093", "*", "*"]
    ecb-api-security        = ["inbound", "allow", "Tcp", "*", "8443", "*", "*"]
    ecb-api-config-registry = ["inbound", "allow", "Tcp", "*", "8888", "*", "*"]
    jasper-tomcat           = ["inbound", "allow", "Tcp", "*", "8181", "*", "*"]
    jasper-iis              = ["inbound", "allow", "Tcp", "*", "8182", "*", "*"]
    vertex-6000             = ["inbound", "allow", "Tcp", "*", "6000", "*", "*"]
    vertex-6001             = ["inbound", "allow", "Tcp", "*", "6001", "*", "*"]
    vertex-6002             = ["inbound", "allow", "Tcp", "*", "6002", "*", "*"]
  }

  #NSG rules should be definded in the below format
  # Syntax for defining rule
  # http  = ["direction", "access", "Protocol","source_port","destination_port","source_address","destination_address"]
  # example rule
  # http  = ["inbound", "allow", "Tcp","80","80","*","*"]
}

module "Jump_NSG" {
  source               = "../../.././modules/nsg"
  environment          = "${var.environment}"
  prefix               = "${var.prefix}"
  subnet_name          = "${local.subnet_names[index(local.subnet_names, "${var.prefix}-vnet-jump-snet")]}"
  virtual_network_name = "${azurerm_virtual_network.ECB_virtual_Network.name}"
  resource_group_name  = "${data.azurerm_resource_group.ECB_Resource_Group.name}"
  address_prefix       = "${local.subnet_cidr[0]}.${local.subnet_cidr[1]}.${index(local.subnet_names, "${var.prefix}-vnet-jump-snet")}.0/24"

  "nsg_rules" {
    http    = ["inbound", "allow", "Tcp", "*", "80", "*", "*"]
    https   = ["inbound", "allow", "Tcp", "*", "443", "*", "*"]
    rdprule = ["inbound", "allow", "Tcp", "*", "3389", "*", "*"]
  }

  #NSG rules should be definded in the below format
  # Syntax for defining rule
  # http  = ["direction", "access", "Protocol","source_port","destination_port","source_address","destination_address"]
  # example rule
  # http  = ["inbound", "allow", "Tcp","80","80","*","*"]
}

# output "Subnet_Names" {
#   value = "${azurerm_subnet.ECB_Virtual_Network_Subnets.*.name}"
# }

module "ECB-VM-LB" {
  source               = "../../.././modules/InternalLB"
  environment          = "${var.environment}"
  prefix               = "${var.prefix}"
  count                = "${var.ecb_vm_count > 0 ? 1:0}"
  lbname               = "${local.ecb_lb_name}-lb"
  lb_type              = "private"
  resource_group_name  = "${local.resource_group_name}"
  subnet_name          = "${module.Public_NSG.Subnet_Names}"
  virtual_network_name = "${local.virtual_network_name}"
  location             = "${var.location}"

  ### define Load Balancing rules in the below format
  ### rule_name = [ "fontend_port","protocol","backend_port"]
  "lb_port" {
    http           = ["80", "Tcp", "80"]
    https          = ["443", "Tcp", "443"]
    mv-ui          = ["8080", "Tcp", "8080"]
    mv-config      = ["8081", "Tcp", "8081"]
    mv-api         = ["8082", "Tcp", "8082"]
    mv-security    = ["8083", "Tcp", "8083"]
    api-zg         = ["8711", "Tcp", "8711"]
    api-billing    = ["8091", "Tcp", "8091"]
    api-customer   = ["8095", "Tcp", "8095"]
    api-fndtn      = ["8097", "Tcp", "8097"]
    api-pricing    = ["8099", "Tcp", "8099"]
    api-prdt-ctlg  = ["8093", "Tcp", "8093"]
    api-security   = ["8443", "Tcp", "8443"]
    api-cnfg-rgsty = ["8888", "Tcp", "8888"]
  }
}

module "Jasper-VM-LB" {
  source               = "../../.././modules/InternalLB"
  environment          = "${var.environment}"
  prefix               = "${var.prefix}"
  count                = "${var.jsp_vm_count > 0 ? 1:0}"
  lbname               = "${local.jsp_lb_name}-lb"
  lb_type              = "private"
  resource_group_name  = "${local.resource_group_name}"
  subnet_name          = "${module.Public_NSG.Subnet_Names}"
  virtual_network_name = "${local.virtual_network_name}"
  location             = "${var.location}"

  ### define Load Balancing rules in the below format
  ### rule_name = [ "fontend_port","protocol","backend_port"]
  "lb_port" {
    http       = ["80", "Tcp", "80"]
    https      = ["443", "Tcp", "443"]
    jsp-tomcat = ["8181", "Tcp", "8181"]
    jsp-iis    = ["8182", "Tcp", "8182"]
  }
}

module "Vertex-VM-LB" {
  source               = "../../.././modules/InternalLB"
  environment          = "${var.environment}"
  prefix               = "${var.prefix}"
  count                = "${var.vtx_vm_count > 0 ? 1:0}"
  lbname               = "${local.vtx_lb_name}-lb"
  lb_type              = "private"
  resource_group_name  = "${local.resource_group_name}"
  subnet_name          = "${module.Public_NSG.Subnet_Names}"
  virtual_network_name = "${local.virtual_network_name}"
  location             = "${var.location}"

  ### define Load Balancing rules in the below format
  ### rule_name = [ "fontend_port","protocol","backend_port"]
  "lb_port" {
    http        = ["80", "Tcp", "80"]
    https       = ["443", "Tcp", "443"]
    vertex-6000 = ["6000", "Tcp", "6000"]
    vertex-6001 = ["6001", "Tcp", "6001"]
    vertex-6002 = ["6002", "Tcp", "6002"]
  }
}

module "ECB-VM-AvSet" {
  source               = "../../.././modules/availability_set"
  count                = "${var.ecb_vm_count}"
  availabilityset_name = "${local.ecb_avset_name}"
  resource_group_name  = "${local.resource_group_name}"
}

module "JSP-VM-AvSet" {
  source               = "../../.././modules/availability_set"
  count                = "${var.jsp_vm_count}"
  availabilityset_name = "${local.jsp_avset_name}"
  resource_group_name  = "${local.resource_group_name}"
}

module "VTX-VM-AvSet" {
  source               = "../../.././modules/availability_set"
  count                = "${var.vtx_vm_count}"
  availabilityset_name = "${local.vtx_avset_name}"
  resource_group_name  = "${local.resource_group_name}"
}
