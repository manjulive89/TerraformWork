data "azurerm_resource_group" "ECB_Resource_Group" {
  name = "${var.resource_group_name}"
}

# data "azuread_user" "user_name" {
#   count               = "${var.user_principal_name != "" ? 1 : 0}"
#   user_principal_name = "${var.user_principal_name}"
# }

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "azvault" {
  name                        = "${var.key_vault_name}"
  location                    = "${data.azurerm_resource_group.ECB_Resource_Group.location}"
  resource_group_name         = "${data.azurerm_resource_group.ECB_Resource_Group.name}"
  enabled_for_disk_encryption = false
  tenant_id                   = "${var.tenant_id}"

  sku {
    name = "standard"
  }

  tags = {
    "prefix"      = "${var.prefix}"
    "environment" = "${var.environment}"
  }
}

resource "azurerm_key_vault_access_policy" "user_access_policy" {
  # count        = "${var.user_principal_name != "" ? 1 : 0}"
  count        = "${var.object_id != "" ? 1 : 0}"
  key_vault_id = "${azurerm_key_vault.azvault.id}"
  tenant_id    = "${data.azurerm_client_config.current.tenant_id}"
  object_id    = "${var.object_id}"

  key_permissions = ["${var.user_key_permissions}"]

  secret_permissions = ["${var.user_secret_permissions}"]

  certificate_permissions = ["${var.user_certificate_permissions}"]
}

resource "azurerm_key_vault_access_policy" "application_access_policy" {
  key_vault_id = "${azurerm_key_vault.azvault.id}"
  tenant_id    = "${data.azurerm_client_config.current.tenant_id}"
  object_id    = "${data.azurerm_client_config.current.service_principal_object_id}"

  key_permissions = ["${var.application_key_permissions}"]

  secret_permissions = ["${var.application_secret_permissions}"]

  certificate_permissions = ["${var.application_certificate_permissions}"]
}

output "vault_name" {
  value = "${azurerm_key_vault.azvault.name}"
}
