# /* MODULE FOR PRIMARY PIPELINE*/
module "PRP" {
  source                           = "../../.././modules/ecbimage"
  environment                      = "${var.environment}"
  virtual_machine_name             = "${local.prp_virtual_machine_name}"
  virtual_network_name             = "${local.virtual_network_name}"
  subnet_name                      = "${local.prp_subnet_name}"
  resource_group_name              = "${local.resource_group_name}"
  prefix                           = "${var.prefix}"
  custom_image_name                = "${var.custom_image_name}"
  custom_image_resource_group_name = "${var.custom_image_resource_group_name}"
  availabilityset_name             = "${local.prp_avset_name}-AVSet"
  count                            = "${var.prp_vm_count}"
  vm_size                          = "${var.prp_vm_size}"
  admin_username                   = "${var.admin_username}"
  admin_password                   = "${var.admin_password}"
  subscription_id                  = "${var.subscription_id}"
  managed_disk_type                = "${var.prp_managed_disk_type}"
}

# /* MODULE FOR SECONDARY PIPELINE*/
module "SEP" {
  source                           = "../../.././modules/ecbimage"
  environment                      = "${var.environment}"
  virtual_machine_name             = "${local.sep_virtual_machine_name}"
  virtual_network_name             = "${local.virtual_network_name}"
  subnet_name                      = "${local.sep_subnet_name}"
  resource_group_name              = "${local.resource_group_name}"
  prefix                           = "${var.prefix}"
  custom_image_name                = "${var.custom_image_name}"
  custom_image_resource_group_name = "${var.custom_image_resource_group_name}"
  availabilityset_name             = "${local.sep_avset_name}-AVSet"
  count                            = "${var.sep_vm_count}"
  vm_size                          = "${var.sep_vm_size}"
  admin_username                   = "${var.admin_username}"
  admin_password                   = "${var.admin_password}"
  subscription_id                  = "${var.subscription_id}"
  managed_disk_type                = "${var.sep_managed_disk_type}"
}

/* MODULE FOR INTEGRATION SERVER*/
module "IS" {
  source                           = "../../.././modules/ecbimageLB"
  environment                      = "${var.environment}"
  virtual_machine_name             = "${local.is_virtual_machine_name}"
  virtual_network_name             = "${local.virtual_network_name}"
  subnet_name                      = "${local.is_subnet_name}"
  resource_group_name              = "${local.resource_group_name}"
  prefix                           = "${var.prefix}"
  custom_image_name                = "${var.custom_image_name}"
  custom_image_resource_group_name = "${var.custom_image_resource_group_name}"
  availabilityset_name             = "${local.is_avset_name}-AVSet"
  count                            = "${var.is_vm_count}"
  vm_size                          = "${var.is_vm_size}"
  admin_username                   = "${var.admin_username}"
  admin_password                   = "${var.admin_password}"
  lb_attach                        = "${var.lb_attach}"
  subscription_id                  = "${var.subscription_id}"
  lbname                           = "${local.is_lb_name}-lb"
  managed_disk_type                = "${var.is_managed_disk_type}"
}

module "IS-LB-DETACH" {
  source               = "../../.././modules/Lb_RemoveVM"
  virtual_machine_name = ["${module.IS.vm_name}"]
  resource_group_name  = "${local.resource_group_name}"
  lb_detach            = "${var.lb_detach}"
  nic_lb_Name          = ["${module.IS.vm_nic_name}"]
  subscription_id      = "${var.subscription_id}"
  client_id            = "${var.client_id}"
  client_secret        = "${var.client_secret}"
  tenant_id            = "${var.tenant_id}"
}

# /* MODULE FOR WEBSERVER OR PRIVILIGED SERVER*/
module "WS" {
  source                           = "../../.././modules/ecbimageLB"
  environment                      = "${var.environment}"
  virtual_machine_name             = "${local.ws_virtual_machine_name}"
  virtual_network_name             = "${local.virtual_network_name}"
  subnet_name                      = "${local.ws_subnet_name}"
  resource_group_name              = "${local.resource_group_name}"
  prefix                           = "${var.prefix}"
  custom_image_name                = "${var.custom_image_name}"
  custom_image_resource_group_name = "${var.custom_image_resource_group_name}"
  availabilityset_name             = "${local.ws_avset_name}-AVSet"
  count                            = "${var.ws_vm_count}"
  vm_size                          = "${var.ws_vm_size}"
  admin_username                   = "${var.admin_username}"
  admin_password                   = "${var.admin_password}"
  lb_attach                        = "${var.lb_attach}"
  subscription_id                  = "${var.subscription_id}"
  lbname                           = "${local.ws_lb_name}-lb"
  managed_disk_type                = "${var.ws_managed_disk_type}"
}

module "WS-LB-DETACH" {
  source               = "../../.././modules/Lb_RemoveVM"
  virtual_machine_name = ["${module.WS.vm_name}"]
  resource_group_name  = "${local.resource_group_name}"
  lb_detach            = "${var.lb_detach}"
  nic_lb_Name          = ["${module.WS.vm_nic_name}"]
  subscription_id      = "${var.subscription_id}"
  client_id            = "${var.client_id}"
  client_secret        = "${var.client_secret}"
  tenant_id            = "${var.tenant_id}"
}

# /* MODULE FOR METRAVIEW*/
module "MVW" {
  source                           = "../../.././modules/ecbimageLB"
  environment                      = "${var.environment}"
  virtual_machine_name             = "${local.mvw_virtual_machine_name}"
  virtual_network_name             = "${local.virtual_network_name}"
  subnet_name                      = "${local.mvw_subnet_name}"
  resource_group_name              = "${local.resource_group_name}"
  prefix                           = "${var.prefix}"
  custom_image_name                = "${var.custom_image_name}"
  custom_image_resource_group_name = "${var.custom_image_resource_group_name}"
  availabilityset_name             = "${local.mvw_avset_name}-AVSet"
  count                            = "${var.mvw_vm_count}"
  vm_size                          = "${var.mvw_vm_size}"
  admin_username                   = "${var.admin_username}"
  admin_password                   = "${var.admin_password}"
  lb_attach                        = "${var.lb_attach}"
  subscription_id                  = "${var.subscription_id}"
  lbname                           = "${local.mvw_lb_name}-lb"
  managed_disk_type                = "${var.mvw_managed_disk_type}"
}

module "MVW-LB-DETACH" {
  source               = "../../.././modules/Lb_RemoveVM"
  virtual_machine_name = ["${module.MVW.vm_name}"]
  resource_group_name  = "${local.resource_group_name}"
  lb_detach            = "${var.lb_detach}"
  nic_lb_Name          = ["${module.MVW.vm_nic_name}"]
  subscription_id      = "${var.subscription_id}"
  client_id            = "${var.client_id}"
  client_secret        = "${var.client_secret}"
  tenant_id            = "${var.tenant_id}"
}

# /* MODULE FOR REST-API*/
module "API" {
  source                           = "../../.././modules/ecbimageLB"
  environment                      = "${var.environment}"
  virtual_machine_name             = "${local.api_virtual_machine_name}"
  virtual_network_name             = "${local.virtual_network_name}"
  subnet_name                      = "${local.api_subnet_name}"
  resource_group_name              = "${local.resource_group_name}"
  prefix                           = "${var.prefix}"
  custom_image_name                = "${var.custom_image_name}"
  custom_image_resource_group_name = "${var.custom_image_resource_group_name}"
  availabilityset_name             = "${local.api_avset_name}-AVSet"
  count                            = "${var.api_vm_count}"
  vm_size                          = "${var.api_vm_size}"
  admin_username                   = "${var.admin_username}"
  admin_password                   = "${var.admin_password}"
  lb_attach                        = "${var.lb_attach}"
  subscription_id                  = "${var.subscription_id}"
  lbname                           = "${local.api_lb_name}-lb"
  managed_disk_type                = "${var.api_managed_disk_type}"
}

module "API-LB-DETACH" {
  source               = "../../.././modules/Lb_RemoveVM"
  virtual_machine_name = ["${module.API.vm_name}"]
  resource_group_name  = "${local.resource_group_name}"
  lb_detach            = "${var.lb_detach}"
  nic_lb_Name          = ["${module.API.vm_nic_name}"]
  subscription_id      = "${var.subscription_id}"
  client_id            = "${var.client_id}"
  client_secret        = "${var.client_secret}"
  tenant_id            = "${var.tenant_id}"
}

# /* MODULE FOR JASPER IMAGE*/
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

# /* MODULE FOR VERTEX IMAGE*/
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
  # vertex_disk_size                 = "${var.vertex_disk_size}"
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
