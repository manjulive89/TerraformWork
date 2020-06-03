data "azurerm_resource_group" "ECB_Resource_Group" {
  name = "${var.resource_group_name}"
}

# Create a virtual network within the resource group

resource "azurerm_subnet" "ECB_Virtual_Network_Subnets" {
  name                      = "${var.subnet_name}"
  resource_group_name       = "${data.azurerm_resource_group.ECB_Resource_Group.name}"
  virtual_network_name      = "${var.virtual_network_name}"
  address_prefix            = "${var.address_prefix}"
  network_security_group_id = "${azurerm_network_security_group.network_security_group.id}"
}

resource "azurerm_network_security_group" "network_security_group" {
  name                = "${var.subnet_name}-nsg"
  resource_group_name = "${data.azurerm_resource_group.ECB_Resource_Group.name}"
  location            = "${data.azurerm_resource_group.ECB_Resource_Group.location}"

  tags {
    "prefix"      = "${var.prefix}"
    "environment" = "${var.environment}"
  }
}

resource "azurerm_network_security_rule" "network_security_rules" {
  count                       = "${length(var.nsg_rules)}"
  name                        = "${element(keys(var.nsg_rules), count.index)}"
  resource_group_name         = "${data.azurerm_resource_group.ECB_Resource_Group.name}"
  network_security_group_name = "${azurerm_network_security_group.network_security_group.name}"
  priority                    = "${count.index+100}"
  direction                   = "${element(var.nsg_rules["${element(keys(var.nsg_rules), count.index)}"], 0)}"
  access                      = "${element(var.nsg_rules["${element(keys(var.nsg_rules), count.index)}"], 1)}"
  protocol                    = "${element(var.nsg_rules["${element(keys(var.nsg_rules), count.index)}"], 2)}"
  source_port_range           = "${element(var.nsg_rules["${element(keys(var.nsg_rules), count.index)}"], 3)}"
  destination_port_range      = "${element(var.nsg_rules["${element(keys(var.nsg_rules), count.index)}"], 4)}"
  source_address_prefix       = "${element(var.nsg_rules["${element(keys(var.nsg_rules), count.index)}"], 5)}"
  destination_address_prefix  = "${element(var.nsg_rules["${element(keys(var.nsg_rules), count.index)}"], 6)}"
}

resource "azurerm_subnet_network_security_group_association" "NSGSUBNET" {
  #  count = "${data.azurerm_subnet.ECB_Virtual_Network_Subnets.network_security_group_id == "" ? 1 : 0 }"
  subnet_id                 = "${azurerm_subnet.ECB_Virtual_Network_Subnets.id}"
  network_security_group_id = "${azurerm_network_security_group.network_security_group.id}"
}

output "Subnet_Names" {
  value = "${azurerm_subnet.ECB_Virtual_Network_Subnets.name}"
}
