data "azurerm_resource_group" "ECB_Resource_Group" {
  name = "${var.resource_group_name}"
}

data "azurerm_subnet" "ECB_Virtual_Network_Subnet" {
  name                 = "${var.subnet_name}"
  virtual_network_name = "${var.virtual_network_name}"
  resource_group_name  = "${data.azurerm_resource_group.ECB_Resource_Group.name}"
}

resource "azurerm_lb" "azlb" {
  count               = "${var.count > 0 ? 1:0 }"
  name                = "${var.lbname}"
  resource_group_name = "${data.azurerm_resource_group.ECB_Resource_Group.name}"
  location            = "${var.location}"

  frontend_ip_configuration {
    name                 = "${var.lbname}-FIP"
    public_ip_address_id = "${var.lb_type == "public" ? join("",azurerm_public_ip.azlb.*.id) : ""}"
    subnet_id            = "${data.azurerm_subnet.ECB_Virtual_Network_Subnet.id}"
  }

  tags {
    "prefix"      = "${var.prefix}"
    "environment" = "${var.environment}"
  }
}

resource "azurerm_public_ip" "azlb" {
  count                        = "${var.lb_type == "public" && var.count > 0 ? 1 : 0}"
  name                         = "${var.lbname}-publicIP"
  location                     = "${var.location}"
  resource_group_name          = "${data.azurerm_resource_group.ECB_Resource_Group.name}"
  public_ip_address_allocation = "${var.public_ip_address_allocation}"
}

resource "azurerm_lb_backend_address_pool" "azlb" {
  count               = "${var.count > 0 ? 1 : 0}"
  resource_group_name = "${var.resource_group_name}"
  loadbalancer_id     = "${azurerm_lb.azlb.id}"
  name                = "${var.lbname}-BEP"
}

resource "azurerm_lb_probe" "azlb" {
  count               = "${var.count > 0 ? length(var.lb_port) :0}"
  resource_group_name = "${data.azurerm_resource_group.ECB_Resource_Group.name}"
  loadbalancer_id     = "${azurerm_lb.azlb.id}"
  name                = "${element(keys(var.lb_port), count.index)}"
  protocol            = "${element(var.lb_port["${element(keys(var.lb_port), count.index)}"], 1)}"
  port                = "${element(var.lb_port["${element(keys(var.lb_port), count.index)}"], 2)}"
  interval_in_seconds = "5"
  number_of_probes    = "2"
}

resource "azurerm_lb_rule" "azlb" {
  count                          = "${var.count > 0 ? length(var.lb_port) : 0}"
  resource_group_name            = "${data.azurerm_resource_group.ECB_Resource_Group.name}"
  loadbalancer_id                = "${azurerm_lb.azlb.id}"
  name                           = "${element(keys(var.lb_port), count.index)}"
  protocol                       = "${element(var.lb_port["${element(keys(var.lb_port), count.index)}"], 1)}"
  frontend_port                  = "${element(var.lb_port["${element(keys(var.lb_port), count.index)}"], 0)}"
  backend_port                   = "${element(var.lb_port["${element(keys(var.lb_port), count.index)}"], 2)}"
  frontend_ip_configuration_name = "${var.lbname}-FIP"
  enable_floating_ip             = false
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.azlb.id}"
  idle_timeout_in_minutes        = 5
  probe_id                       = "${element(azurerm_lb_probe.azlb.*.id,count.index)}"
  depends_on                     = ["azurerm_lb_probe.azlb"]
}

output "lb_backendpool_id" {
  value = "${azurerm_lb_backend_address_pool.azlb.*.id}"
}
