resource "azurerm_virtual_machine_extension" "test" {
  name                 = "${local.sql_machine_name}-e"
  location             = "East US"
  resource_group_name  = "${data.azurerm_resource_group.ECB_Resource_Group.name}"
  virtual_machine_name = "${azurerm_virtual_machine.ECB_SQL_VM1.name}"
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
        "fileUris": ["https://saecbartifacts.blob.core.windows.net/files/SQLroleaddscript.ps1"],
        "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -File SQLroleaddscript.ps1"
    }
   SETTINGS
  
  protected_settings = <<PROTECTED_SETTINGS
    {
        "storageAccountName": "",
        "storageAccountKey": ""
    }
   PROTECTED_SETTINGS
  }
  