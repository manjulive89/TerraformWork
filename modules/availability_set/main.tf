variable "availabilityset_name" {}

variable "resource_group_name" {}

variable "count" {}

data "azurerm_resource_group" "ECB_Resource_Group" {
  name = "${var.resource_group_name}"
}

resource "azurerm_availability_set" "ECB-VM-AVSET" {
  count                        = "${var.count > 0 && var.availabilityset_name != "" ? 1 : 0 }"
  platform_fault_domain_count  = 3
  platform_update_domain_count = 5
  name                         = "${var.availabilityset_name}-AVSet"
  location                     = "${data.azurerm_resource_group.ECB_Resource_Group.location}"
  resource_group_name          = "${data.azurerm_resource_group.ECB_Resource_Group.name}"
  managed                      = true
}

output "avset_name" {
  value = "${azurerm_availability_set.ECB-VM-AVSET.*.name}"
}
