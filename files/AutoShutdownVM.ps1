<#
    .SYNOPSIS
        Enable-AzureRmVMAutoShutdown

    .DESCRIPTION
        Enable Azure RM Virtual Machine Auto-Shutdown.

    .PARAMETER  ResourceGroupName  
        Resource group name. 

    .PARAMETER  VirtualMachineName
        Virtual Machine name.

    .PARAMETER  ShutdownTime 
        Set Auto-Shutdown time 24 format (ex : 2000 = 20:00).

    .PARAMETER  TimeZone
        Set Time Zone.

    .EXAMPLE
        PS C:\> Enable-AzureRmVMAutoShutdown -ResourceGroupName 'MyRGName' -VirtualMachineName 'MyVMName'

    .EXAMPLE
        PS C:\> Enable-AzureRmVMAutoShutdown -ResourceGroupName 'MyRGName' -VirtualMachineName 'MyVMName' -ShutdownTime 2000 -TimeZone 'Romance Standard Time'

    .EXAMPLE
        PS C:\> Enable-AzureRmVMAutoShutdown -ResourceGroupName 'MyRGName' -VirtualMachineName 'MyVMName' -ShutdownTime 2000 -TimeZone 'Romance Standard Time -Subscription_id $$env:TF_VAR_Subscription_id -Client_id $$env:TF_VAR_client_id -client_secret $$env:TF_VAR_client_secret -tenant_id $$env:TF_VAR_tenant_id'

    .INPUTS
        System.String,System.Int32

    .OUTPUTS
        Microsoft.DevTestLab/Schedules

    .NOTES
        Author: Naveen
        Date: 10/19/2018
#>

Function Enable-AzureRmVMAutoShutdown {
    [CmdletBinding()]
    Param 
    (
        [Parameter(Mandatory = $true)] 
        [string] $ResourceGroupName,
        [Parameter(Mandatory = $true)]
        [string] $VirtualMachineName,
        [parameter(Mandatory = $true)]
        [string] $Subscription_id,
        [parameter(Mandatory = $true)]
        [string] $Client_id,
        [parameter(Mandatory = $true)]
        [string] $client_secret,
        [parameter(Mandatory = $true)]
        [string] $tenant_id,
        [parameter(Mandatory = $true)]
        [string] $Email,
        [parameter(Mandatory = $true)]
        [string] $Enable_AutoShutDown,
        [parameter(Mandatory = $true)]
        [string] $status,
        [int] $ShutdownTime = 1900,
        [string] $TimeZone = 'India Standard Time'
    )
    
    Try {
        if ($Enable_AutoShutDown -eq 'true') {
            $credentials = New-Object System.Management.Automation.PSCredential ($client_id, (ConvertTo-SecureString $client_Secret -AsPlainText -Force))

            Login-AzAccount -ServicePrincipal -TenantId $tenant_id -Subscription $subscription_id -Credential $Credentials
            $Location = (Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VirtualMachineName).Location
            $SubscriptionId = (Get-AzContext).Subscription.SubscriptionId
            $VMResourceId = (Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VirtualMachineName).Id
            $ScheduledShutdownResourceId = "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/microsoft.devtestlab/schedules/shutdown-computevm-$VirtualMachineName"

            $Properties = @{ }
            $Properties.Add('status', 'Enabled')
            $Properties.Add('taskType', 'ComputeVmShutdownTask')
            $Properties.Add('dailyRecurrence', @{'time' = $ShutdownTime })
            $Properties.Add('timeZoneId', $TimeZone)
            if ($status -eq 'Enable') {
                $Properties.Add('notificationSettings', @{status = 'Enabled'; timeInMinutes = 30; emailRecipient = $Email })            
            }
            else {
                $Properties.Add('notificationSettings', @{status = 'Disabled'; timeInMinutes = 15 })
            }
            $Properties.Add('targetResourceId', $VMResourceId)

            New-AzResource -Location $Location -ResourceId $ScheduledShutdownResourceId -Properties $Properties -Force
        }
        elseif ($Enable_AutoShutDown -eq 'false') {
            $credentials = New-Object System.Management.Automation.PSCredential ($client_id, (ConvertTo-SecureString $client_Secret -AsPlainText -Force))

            Login-AzAccount -ServicePrincipal -TenantId $tenant_id -Subscription $subscription_id -Credential $Credentials
            $Location = (Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VirtualMachineName).Location
            $SubscriptionId = (Get-AzContext).Subscription.SubscriptionId
            $VMResourceId = (Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VirtualMachineName).Id
            $ScheduledShutdownResourceId = "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/microsoft.devtestlab/schedules/shutdown-computevm-$VirtualMachineName"

            $Properties = @{ }
            $Properties.Add('status', 'Disabled')
            $Properties.Add('taskType', 'ComputeVmShutdownTask')
            $Properties.Add('dailyRecurrence', @{'time' = $ShutdownTime })
            $Properties.Add('timeZoneId', $TimeZone)
            $Properties.Add('notificationSettings', @{status = 'Disabled'; timeInMinutes = 15 })            
            $Properties.Add('targetResourceId', $VMResourceId)

            New-AzResource -Location $Location -ResourceId $ScheduledShutdownResourceId -Properties $Properties -Force
        }
        else {
            Write-Host "Autoshutdown - Skipped"
        }
    }
    Catch { Write-Error $_ }
}
