variable "virtual_machine_name" {
  type = "list"
}

variable "nic_lb_Name" {
  type = "list"
}

variable "lb_detach" {}
variable "subscription_id" {}
variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}
variable "resource_group_name" {}

resource "null_resource" "ECB-VM-From-BackendPool" {
  triggers = {
    lb_detach = "${var.lb_detach}"
  }

  count = "${length(var.virtual_machine_name)}"

  provisioner "local-exec" {
    command     = ". \"..\\..\\..\\files\\RemoveVMfromBackendPool.ps1\";RemoveVMfromBackendPool -rg_lb_Name ${var.resource_group_name} -vm_lb_Name ${var.virtual_machine_name[count.index]} -nic_lb_Name ${var.nic_lb_Name[count.index]} -lb_detach ${var.lb_detach} -Subscription_id ${var.subscription_id} -Client_id ${var.client_id} -client_secret ${var.client_secret} -tenant_id ${var.tenant_id}"
    interpreter = ["powershell", "-command"]
  }
}
