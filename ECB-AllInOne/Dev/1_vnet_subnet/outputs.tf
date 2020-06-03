#----- Subnet names
output "aag_Subnet_Name" {
  value = "${module.aag_NSG.Subnet_Names}"
}

output "Public_Subnet_Name" {
  value = "${module.Public_NSG.Subnet_Names}"
}

output "Private_Subnet_Name" {
  value = "${module.Private_NSG.Subnet_Names}"
}

output "Jump_Subnet_Name" {
  value = "${module.Jump_NSG.Subnet_Names}"
}
