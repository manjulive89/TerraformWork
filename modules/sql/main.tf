locals {
  custom_data_params  = "Param($ComputerName = \"${var.virtual_machine_name}\")"
  custom_data_content = "${local.custom_data_params} ${file("../../.././files/Config-winrm.ps1")}"
}

data "azurerm_subnet" "ECB_Virtual_Network_Subnet02" {
  name                 = "${var.subnet_name}"
  virtual_network_name = "${var.virtual_network_name}"
  resource_group_name  = "${data.azurerm_resource_group.ECB_Resource_Group.name}"
}

data "azurerm_storage_account" "ECB_Diag_StorageAccount" {
  name                = "ecbaasenv${lower(var.environment)}${lower(var.prefix)}"
  resource_group_name = "${data.azurerm_resource_group.ECB_Resource_Group.name}"
}

#resource group to deploy
data "azurerm_resource_group" "ECB_Resource_Group" {
  name = "${var.resource_group_name}"
}

resource "azurerm_network_interface" "ECB_SQL_VM_Nic" {
  name                = "${var.virtual_machine_name}-nic"
  location            = "${data.azurerm_resource_group.ECB_Resource_Group.location}"
  resource_group_name = "${data.azurerm_resource_group.ECB_Resource_Group.name}"

  ip_configuration {
    name                          = "${var.virtual_machine_name}-nic-ip"
    subnet_id                     = "${data.azurerm_subnet.ECB_Virtual_Network_Subnet02.id}"
    private_ip_address_allocation = "dynamic"
  }

  internal_dns_name_label = "${var.virtual_machine_name}"

  tags {
    "prefix"      = "${var.prefix}"
    "environment" = "${var.environment}"
  }
}

resource "azurerm_virtual_machine" "ECB_SQL_VM" {
  name                  = "${var.virtual_machine_name}"
  location              = "${data.azurerm_resource_group.ECB_Resource_Group.location}"
  resource_group_name   = "${data.azurerm_resource_group.ECB_Resource_Group.name}"
  network_interface_ids = ["${azurerm_network_interface.ECB_SQL_VM_Nic.id}"]
  vm_size               = "${var.vm_size}"

  tags {
    "prefix"      = "${var.prefix}"
    "environment" = "${var.environment}"
  }

  # This means the OS Disk will be deleted when Terraform destroys the Virtual Machine
  # NOTE: This may not be optimal in all cases.
  delete_os_disk_on_termination = true

  # This means the Data Disk Disk will be deleted when Terraform destroys the Virtual Machine
  # NOTE: This may not be optimal in all cases.
  delete_data_disks_on_termination = false

  storage_image_reference {
    publisher = "${var.sql_image_publisher}"
    offer     = "${var.sql_image_offer}"
    sku       = "${var.sql_image_sku}"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.virtual_machine_name}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "${var.managed_disk_type}"
  }

  os_profile {
    computer_name  = "${var.virtual_machine_name}"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
    custom_data    = "${local.custom_data_content}"
  }

  boot_diagnostics {
    enabled     = true
    storage_uri = "${data.azurerm_storage_account.ECB_Diag_StorageAccount.primary_blob_endpoint}"
  }

  os_profile_windows_config {
    provision_vm_agent        = true
    enable_automatic_upgrades = true
    timezone                  = "Eastern Standard Time"

    # Auto-Login's required to configure WinRM
    additional_unattend_config {
      pass         = "oobeSystem"
      component    = "Microsoft-Windows-Shell-Setup"
      setting_name = "AutoLogon"
      content      = "<AutoLogon><Password><Value>${var.admin_password}</Value></Password><Enabled>true</Enabled><LogonCount>1</LogonCount><Username>${var.admin_username}</Username></AutoLogon>"
    }

    # Unattend config is to enable basic auth in WinRM, required for the provisioner stage.
    additional_unattend_config {
      pass         = "oobeSystem"
      component    = "Microsoft-Windows-Shell-Setup"
      setting_name = "FirstLogonCommands"
      content      = "${file("../../.././files/FirstLogonCommands.xml")}"
    }
  }
}

output "vm_name" {
  value = "${azurerm_virtual_machine.ECB_SQL_VM.name}"
}

output "network_interface_ECB_private_ip" {
  description = "private ip addresses of the vm nics"
  value       = "${azurerm_network_interface.ECB_SQL_VM_Nic.*.private_ip_address}"
}

output "private_ip_dns_name" {
  description = "fqdn to connect to the first vm provisioned."
  value       = "${azurerm_network_interface.ECB_SQL_VM_Nic.*.internal_dns_name_label}"
}
