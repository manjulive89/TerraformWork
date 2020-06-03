data "azurerm_resource_group" "Resource_group" {
  name = "${var.resource_group_name}"
}

data "azurerm_subnet" "Virtual_Network_Subnet" {
  name                 = "${var.subnet_name}"
  resource_group_name  = "${data.azurerm_resource_group.Resource_group.name}"
  virtual_network_name = "${var.virtual_network_name}"
}

data "azurerm_storage_account" "Diag_StorageAccount" {
  name                = "ecbaasenv${lower(var.environment)}${lower(var.prefix)}"
  resource_group_name = "${var.resource_group_name}"
}

resource "azurerm_public_ip" "VM_Public_ip" {
  count               = "${var.count}"
  name                = "${var.virtual_machine_name}-nic-pip"
  resource_group_name = "${data.azurerm_resource_group.Resource_group.name}"
  location            = "${data.azurerm_resource_group.Resource_group.location}"
  allocation_method   = "Static"

  tags {
    "prefix"      = "${var.prefix}"
    "environment" = "${var.environment}"
  }
}

resource "azurerm_network_interface" "VM_Nic" {
  count               = "${var.count}"
  name                = "${var.virtual_machine_name}-nic"
  location            = "${data.azurerm_resource_group.Resource_group.location}"
  resource_group_name = "${data.azurerm_resource_group.Resource_group.name}"

  ip_configuration {
    name                          = "${var.virtual_machine_name}-nic-ip"
    subnet_id                     = "${data.azurerm_subnet.Virtual_Network_Subnet.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.VM_Public_ip.id}"
  }

  tags {
    "prefix"      = "${var.prefix}"
    "environment" = "${var.environment}"
  }
}

resource "azurerm_virtual_machine" "VM" {
  count                 = "${var.count}"
  name                  = "${var.virtual_machine_name}"
  location              = "${data.azurerm_resource_group.Resource_group.location}"
  resource_group_name   = "${data.azurerm_resource_group.Resource_group.name}"
  network_interface_ids = ["${azurerm_network_interface.VM_Nic.*.id}"]
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
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.virtual_machine_name}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
    os_type           = "windows"
  }

  os_profile {
    computer_name  = "${var.virtual_machine_name}"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
  }

  boot_diagnostics {
    enabled     = true
    storage_uri = "${data.azurerm_storage_account.Diag_StorageAccount.primary_blob_endpoint}"
  }

  os_profile_windows_config {
    provision_vm_agent        = true
    enable_automatic_upgrades = true
  }
}

output "vm_name" {
  value = "${azurerm_virtual_machine.VM.*.name}"
}

output "public_ip_address" {
  description = "The actual ip address allocated for the resource."
  value       = "${azurerm_public_ip.VM_Public_ip.*.ip_address}"
}
