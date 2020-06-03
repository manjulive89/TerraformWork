#----- Subnet names
output "aag_Subnet_Name" {
  value = "${module.aag_NSG.Subnet_Names}"
}

output "Public_Subnet_Name" {
  value = "${module.Public_NSG.Subnet_Names}"
}

output "Internal_Subnet_Name" {
  value = "${module.Internal_NSG.Subnet_Names}"
}

output "Private_Subnet_Name" {
  value = "${module.Private_NSG.Subnet_Names}"
}

output "Jump_Subnet_Name" {
  value = "${module.Jump_NSG.Subnet_Names}"
}

# output "is_lb_id" {
#   value = "${module.IS-VM-LB.lb_backendpool_id}"
# }


# output "ws_lb_id" {
#   value = "${module.WS-VM-LB.lb_backendpool_id}"
# }


# output "api_lb_id" {
#   value = "${module.API-VM-LB.lb_backendpool_id}"
# }


# output "mvw_lb_id" {
#   value = "${module.MVW-VM-LB.lb_backendpool_id}"
# }


# output "jsp_lb_id" {
#   value = "${module.Jasper-VM-LB.lb_backendpool_id}"
# }

