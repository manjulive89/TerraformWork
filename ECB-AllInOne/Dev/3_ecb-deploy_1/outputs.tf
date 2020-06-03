#----- Outputs of private IP, private dns name, no:of VM in a profile and vm name.
#----- ECB AllInOne Server
output "ECB" {
  value = {
    vmname  = "${module.ECB.vm_name}"
    ip      = "${module.ECB.network_interface_ECB_private_ip}"
    dnsname = "${module.ECB.private_ip_dns_name}"
    count   = "${length(module.ECB.vm_name)}"
    nicname = "${module.ECB.vm_nic_name}"
  }
}

#----- Jasper Server
output "Jasper" {
  value = {
    vmname  = "${module.Jasper.vm_name}"
    ip      = "${module.Jasper.network_interface_Jasper_private_ip}"
    dnsname = "${module.Jasper.private_ip_dns_name}"
    count   = "${length(module.Jasper.vm_name)}"
    nicname = "${module.Jasper.vm_nic_name}"
  }
}

#----- Vertex Server
output "Vertex" {
  value = {
    vmname  = "${module.Vertex.vm_name}"
    ip      = "${module.Vertex.network_interface_Vertex_private_ip}"
    dnsname = "${module.Vertex.private_ip_dns_name}"
    count   = "${length(module.Vertex.vm_name)}"
    nicname = "${module.Vertex.vm_nic_name}"
  }
}
