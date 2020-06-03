#----- Outputs of private IP, private dns name, no:of VM in a profile and vm name.
#----- Primary Pipeline
output "PRP" {
  value = {
    vmname  = "${module.PRP.vm_name}"
    ip      = "${module.PRP.network_interface_ECB_private_ip}"
    dnsname = "${module.PRP.private_ip_dns_name}"
    count   = "${length(module.PRP.vm_name)}"
  }
}

#----- Secondary Pipeline
output "SEP" {
  value = {
    vmname  = "${module.SEP.vm_name}"
    ip      = "${module.SEP.network_interface_ECB_private_ip}"
    dnsname = "${module.SEP.private_ip_dns_name}"
    count   = "${length(module.SEP.vm_name)}"
  }
}

#----- Integratrion or Soap API Server

output "IS" {
  value = {
    vmname  = "${module.IS.vm_name}"
    ip      = "${module.IS.network_interface_ECB_private_ip}"
    dnsname = "${module.IS.private_ip_dns_name}"
    count   = "${length(module.IS.vm_name)}"
    nicname = "${module.IS.vm_nic_name}"
  }
}

#----- WEb Server ot ECB Server
output "WS" {
  value = {
    vmname  = "${module.WS.vm_name}"
    ip      = "${module.WS.network_interface_ECB_private_ip}"
    dnsname = "${module.WS.private_ip_dns_name}"
    count   = "${length(module.WS.vm_name)}"
    nicname = "${module.WS.vm_nic_name}"
  }
}

#----- Metraview Server
output "MVW" {
  value = {
    vmname  = "${module.MVW.vm_name}"
    ip      = "${module.MVW.network_interface_ECB_private_ip}"
    dns     = "${module.MVW.private_ip_dns_name}"
    count   = "${length(module.MVW.vm_name)}"
    nicname = "${module.MVW.vm_nic_name}"
  }
}

#----- Rest-API
output "API" {
  value = {
    vmname  = "${module.API.vm_name}"
    ip      = "${module.API.network_interface_ECB_private_ip}"
    dnsname = "${module.API.private_ip_dns_name}"
    count   = "${length(module.API.vm_name)}"
    nicname = "${module.API.vm_nic_name}"
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
