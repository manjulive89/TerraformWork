module "API-autoshutdown" {
  source               = "../../.././modules/null_resource"
  local_time           = "${var.Enable_AutoShutDownVM_time}"
  local_time_zone      = "${var.Enable_AutoShutDownVM_time_zone}"
  resource_group_name  = "${local.resource_group_name}"
  virtual_machine_name = ["${module.API.vm_name}"]
  subscription_id      = "${var.subscription_id}"
  client_id            = "${var.client_id}"
  client_secret        = "${var.client_secret}"
  tenant_id            = "${var.tenant_id}"
  Enable_AutoShutDown  = "${var.Enable_AutoShutDownVM}"
  Email                = "${var.Enable_AutoShutDownVM_Email}"
  NotificationStatus   = "${var.Status_AutoShutDownVM_Notification}"
}

module "IS-autoshutdown" {
  source               = "../../.././modules/null_resource"
  local_time           = "${var.Enable_AutoShutDownVM_time}"
  local_time_zone      = "${var.Enable_AutoShutDownVM_time_zone}"
  resource_group_name  = "${local.resource_group_name}"
  virtual_machine_name = ["${module.IS.vm_name}"]
  subscription_id      = "${var.subscription_id}"
  client_id            = "${var.client_id}"
  client_secret        = "${var.client_secret}"
  tenant_id            = "${var.tenant_id}"
  Enable_AutoShutDown  = "${var.Enable_AutoShutDownVM}"
  Email                = "${var.Enable_AutoShutDownVM_Email}"
  NotificationStatus   = "${var.Status_AutoShutDownVM_Notification}"
}

module "Jasper-autoshutdown" {
  source               = "../../.././modules/null_resource"
  local_time           = "${var.Enable_AutoShutDownVM_time}"
  local_time_zone      = "${var.Enable_AutoShutDownVM_time_zone}"
  resource_group_name  = "${local.resource_group_name}"
  virtual_machine_name = ["${module.Jasper.vm_name}"]
  subscription_id      = "${var.subscription_id}"
  client_id            = "${var.client_id}"
  client_secret        = "${var.client_secret}"
  tenant_id            = "${var.tenant_id}"
  Enable_AutoShutDown  = "${var.Enable_AutoShutDownVM}"
  Email                = "${var.Enable_AutoShutDownVM_Email}"
  NotificationStatus   = "${var.Status_AutoShutDownVM_Notification}"
}

module "Vertex-autoshutdown" {
  source               = "../../.././modules/null_resource"
  local_time           = "${var.Enable_AutoShutDownVM_time}"
  local_time_zone      = "${var.Enable_AutoShutDownVM_time_zone}"
  resource_group_name  = "${local.resource_group_name}"
  virtual_machine_name = ["${module.Vertex.vm_name}"]
  subscription_id      = "${var.subscription_id}"
  client_id            = "${var.client_id}"
  client_secret        = "${var.client_secret}"
  tenant_id            = "${var.tenant_id}"
  Enable_AutoShutDown  = "${var.Enable_AutoShutDownVM}"
  Email                = "${var.Enable_AutoShutDownVM_Email}"
  NotificationStatus   = "${var.Status_AutoShutDownVM_Notification}"
}

module "MVW-autoshutdown" {
  source               = "../../.././modules/null_resource"
  local_time           = "${var.Enable_AutoShutDownVM_time}"
  local_time_zone      = "${var.Enable_AutoShutDownVM_time_zone}"
  resource_group_name  = "${local.resource_group_name}"
  virtual_machine_name = ["${module.MVW.vm_name}"]
  subscription_id      = "${var.subscription_id}"
  client_id            = "${var.client_id}"
  client_secret        = "${var.client_secret}"
  tenant_id            = "${var.tenant_id}"
  Enable_AutoShutDown  = "${var.Enable_AutoShutDownVM}"
  Email                = "${var.Enable_AutoShutDownVM_Email}"
  NotificationStatus   = "${var.Status_AutoShutDownVM_Notification}"
}

module "PRP-autoshutdown" {
  source               = "../../.././modules/null_resource"
  local_time           = "${var.Enable_AutoShutDownVM_time}"
  local_time_zone      = "${var.Enable_AutoShutDownVM_time_zone}"
  resource_group_name  = "${local.resource_group_name}"
  virtual_machine_name = ["${module.PRP.vm_name}"]
  subscription_id      = "${var.subscription_id}"
  client_id            = "${var.client_id}"
  client_secret        = "${var.client_secret}"
  tenant_id            = "${var.tenant_id}"
  Enable_AutoShutDown  = "${var.Enable_AutoShutDownVM}"
  Email                = "${var.Enable_AutoShutDownVM_Email}"
  NotificationStatus   = "${var.Status_AutoShutDownVM_Notification}"
}

module "SEP-autoshutdown" {
  source               = "../../.././modules/null_resource"
  local_time           = "${var.Enable_AutoShutDownVM_time}"
  local_time_zone      = "${var.Enable_AutoShutDownVM_time_zone}"
  resource_group_name  = "${local.resource_group_name}"
  virtual_machine_name = ["${module.SEP.vm_name}"]
  subscription_id      = "${var.subscription_id}"
  client_id            = "${var.client_id}"
  client_secret        = "${var.client_secret}"
  tenant_id            = "${var.tenant_id}"
  Enable_AutoShutDown  = "${var.Enable_AutoShutDownVM}"
  Email                = "${var.Enable_AutoShutDownVM_Email}"
  NotificationStatus   = "${var.Status_AutoShutDownVM_Notification}"
}

module "WS-autoshutdown" {
  source               = "../../.././modules/null_resource"
  local_time           = "${var.Enable_AutoShutDownVM_time}"
  local_time_zone      = "${var.Enable_AutoShutDownVM_time_zone}"
  resource_group_name  = "${local.resource_group_name}"
  virtual_machine_name = ["${module.WS.vm_name}"]
  subscription_id      = "${var.subscription_id}"
  client_id            = "${var.client_id}"
  client_secret        = "${var.client_secret}"
  tenant_id            = "${var.tenant_id}"
  Enable_AutoShutDown  = "${var.Enable_AutoShutDownVM}"
  Email                = "${var.Enable_AutoShutDownVM_Email}"
  NotificationStatus   = "${var.Status_AutoShutDownVM_Notification}"
}
