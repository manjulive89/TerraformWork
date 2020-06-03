/*MODULE FOR JUMPBOX*/
module "JBox" {
  source               = "../../.././modules/virtual-machine-pip"
  count                = "${var.jb_vm_count}"
  environment          = "${var.environment}"
  virtual_machine_name = "${local.JB_virtual_machine_name}"
  virtual_network_name = "${local.virtual_network_name}"
  subnet_name          = "${local.jb_subnet_name}"
  resource_group_name  = "${local.resource_group_name}"
  prefix               = "${var.prefix}"
  vm_size              = "${var.jb_vm_size}"
  admin_username       = "${var.jb_admin_username}"
  admin_password       = "${var.jb_admin_password}"
}

/*MODULE FOR SQL DATABASE*/
module "SQL" {
  source               = "../../.././modules/sql"
  environment          = "${var.environment}"
  virtual_machine_name = "${local.sql_virtual_machine_name}"
  virtual_network_name = "${local.virtual_network_name}"
  subnet_name          = "${local.sql_subnet_name}"
  resource_group_name  = "${local.resource_group_name}"
  prefix               = "${var.prefix}"
  vm_size              = "${var.sql_vm_size}"
  admin_username       = "${var.admin_username}"
  admin_password       = "${var.admin_password}"
  managed_disk_type    = "${var.sql_managed_disk_type}"
  sql_image_sku        = "${var.sql_image_sku}"
}

/*MODULE FOR Azure Vault*/
module "AzVault" {
  source                              = "../../.././modules/azvault"
  environment                         = "${var.environment}"
  resource_group_name                 = "${local.resource_group_name}"
  prefix                              = "${var.prefix}"
  key_vault_name                      = "${local.az_key_vault_name}"
  user_principal_name                 = "${var.azure_user_email_id}"
  tenant_id                           = "${var.tenant_id}"
  object_id                           = "${var.object_id}"
  user_key_permissions                = "${local.user_key_permissions}"
  user_secret_permissions             = "${local.user_secret_permissions}"
  user_certificate_permissions        = "${local.user_certificate_permissions}"
  application_key_permissions         = "${local.application_key_permissions}"
  application_secret_permissions      = "${local.application_secret_permissions}"
  application_certificate_permissions = "${local.application_certificate_permissions}"
}
