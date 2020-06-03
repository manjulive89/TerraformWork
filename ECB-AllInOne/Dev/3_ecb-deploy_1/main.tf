module "ECB" {
  source                           = "../../.././modules/ecbimageLB"
  environment                      = "${var.environment}"
  virtual_machine_name             = "${local.ecb_virtual_machine_name}"
  virtual_network_name             = "${local.virtual_network_name}"
  subnet_name                      = "${local.ecb_subnet_name}"
  resource_group_name              = "${local.resource_group_name}"
  prefix                           = "${var.prefix}"
  custom_image_name                = "${var.custom_image_name}"
  custom_image_resource_group_name = "${var.custom_image_resource_group_name}"
  availabilityset_name             = "${local.ecb_avset_name}-AVSet"
  count                            = "${var.ecb_vm_count}"
  vm_size                          = "${var.ecb_vm_size}"
  admin_username                   = "${var.admin_username}"
  admin_password                   = "${var.admin_password}"
  lb_attach                        = "${var.lb_attach}"
  subscription_id                  = "${var.subscription_id}"
  lbname                           = "${local.ecb_lb_name}-lb"
  managed_disk_type                = "${var.ecb_managed_disk_type}"
}

module "ECB-LB-DETACH" {
  source               = "../../.././modules/Lb_RemoveVM"
  virtual_machine_name = ["${module.ECB.vm_name}"]
  resource_group_name  = "${local.resource_group_name}"
  lb_detach            = "${var.lb_detach}"
  nic_lb_Name          = ["${module.ECB.vm_nic_name}"]
  subscription_id      = "${var.subscription_id}"
  client_id            = "${var.client_id}"
  client_secret        = "${var.client_secret}"
  tenant_id            = "${var.tenant_id}"
}

module "Jasper" {
  source                           = "../../.././modules/jasper_image"
  environment                      = "${var.environment}"
  virtual_machine_name             = "${local.jsp_virtual_machine_name}"
  virtual_network_name             = "${local.virtual_network_name}"
  subnet_name                      = "${local.jsp_subnet_name}"
  resource_group_name              = "${local.resource_group_name}"
  prefix                           = "${var.prefix}"
  jasper_image_name                = "${var.jasper_image_name}"
  jasper_image_resource_group_name = "${var.jasper_image_resource_group_name}"
  availabilityset_name             = "${local.jsp_avset_name}-AVSet"
  count                            = "${var.jsp_vm_count}"
  vm_size                          = "${var.jsp_vm_size}"
  jasper_disk_size                 = "${var.jasper_disk_size}"
  admin_username                   = "${var.admin_username}"
  admin_password                   = "${var.admin_password}"
  lb_attach                        = "${var.lb_attach}"
  subscription_id                  = "${var.subscription_id}"
  lbname                           = "${local.jsp_lb_name}-lb"
  managed_disk_type                = "${var.jsp_managed_disk_type}"
  managed_data_disk_type           = "${var.jsp_managed_data_disk_type}"
}

module "Jasper-LB-DETACH" {
  source               = "../../.././modules/Lb_RemoveVM"
  virtual_machine_name = ["${module.Jasper.vm_name}"]
  resource_group_name  = "${local.resource_group_name}"
  lb_detach            = "${var.lb_detach}"
  nic_lb_Name          = ["${module.Jasper.vm_nic_name}"]
  subscription_id      = "${var.subscription_id}"
  client_id            = "${var.client_id}"
  client_secret        = "${var.client_secret}"
  tenant_id            = "${var.tenant_id}"
}

module "Vertex" {
  source                           = "../../.././modules/vertex_image"
  environment                      = "${var.environment}"
  virtual_machine_name             = "${local.vtx_virtual_machine_name}"
  virtual_network_name             = "${local.virtual_network_name}"
  subnet_name                      = "${local.vtx_subnet_name}"
  resource_group_name              = "${local.resource_group_name}"
  prefix                           = "${var.prefix}"
  vertex_image_name                = "${var.vertex_image_name}"
  vertex_image_resource_group_name = "${var.vertex_image_resource_group_name}"
  availabilityset_name             = "${local.vtx_avset_name}-AVSet"
  count                            = "${var.vtx_vm_count}"
  vm_size                          = "${var.vtx_vm_size}"
  # Vertex_disk_size                 = "${var.vertex_disk_size}"
  admin_username                   = "${var.admin_username}"
  admin_password                   = "${var.admin_password}"
  lb_attach                        = "${var.lb_attach}"
  subscription_id                  = "${var.subscription_id}"
  lbname                           = "${local.vtx_lb_name}-lb"
  managed_disk_type                = "${var.vtx_managed_disk_type}"
}

module "Vertex-LB-DETACH" {
  source               = "../../.././modules/Lb_RemoveVM"
  virtual_machine_name = ["${module.Vertex.vm_name}"]
  resource_group_name  = "${local.resource_group_name}"
  lb_detach            = "${var.lb_detach}"
  nic_lb_Name          = ["${module.Vertex.vm_nic_name}"]
  subscription_id      = "${var.subscription_id}"
  client_id            = "${var.client_id}"
  client_secret        = "${var.client_secret}"
  tenant_id            = "${var.tenant_id}"
}
