#----- Outputs of private IP, private dns name, no:of VM in a profile and vm name.
#----- JumpHost
output "JB_vm_name" {
  value = "${module.JBox.vm_name}"
}

output "JB_public_ip_address" {
  description = "The actual ip address allocated for the resource."
  value       = "${module.JBox.public_ip_address}"
}

#----- MSSQL Server
output "SQL_vm_name" {
  value = "${module.SQL.vm_name}"
}

output "SQL_private_ip" {
  description = "private ip addresses of the vm nics"
  value       = "${module.SQL.network_interface_ECB_private_ip}"
}

output "SQL_private_ip_dns_name" {
  description = "fqdn to connect to the first vm provisioned."
  value       = "${module.SQL.private_ip_dns_name}"
}

#----- Key Vault
output "Key_Vault_name" {
  value = "${module.AzVault.vault_name}"
}
