resource "null_resource" "ECB-VM-AutoShutdown" {
  triggers = {
    Enable_AutoShutDown = "${var.Enable_AutoShutDown}"
  }

  count = "${length(var.virtual_machine_name)}"

  provisioner "local-exec" {
    command     = ". \"..\\..\\..\\files\\AutoShutdownVM.ps1\";Enable-AzureRmVMAutoShutdown -ResourceGroupName ${var.resource_group_name} -ShutdownTime ${var.local_time} -TimeZone '${var.local_time_zone}' -Email ${var.Email} -Enable_AutoShutDown ${var.Enable_AutoShutDown} -status ${var.NotificationStatus} -VirtualMachineName ${var.virtual_machine_name[count.index]} -Subscription_id ${var.subscription_id} -Client_id ${var.client_id} -client_secret ${var.client_secret} -tenant_id ${var.tenant_id}"
    interpreter = ["powershell", "-command"]
  }
}
