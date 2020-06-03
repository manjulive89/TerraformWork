function RemoveVMfromBackendPool {
    param(
        [parameter(Mandatory = $true)] [string] $vm_lb_Name,    
        [parameter(Mandatory = $true)] [string] $rg_lb_Name,
        [parameter(Mandatory = $true)] [string] $nic_lb_Name,
        [parameter(Mandatory = $true)] [string] $Subscription_id,
        [parameter(Mandatory = $true)] [string] $Client_id,
        [parameter(Mandatory = $true)] [string] $client_secret,
        [parameter(Mandatory = $true)] [string] $tenant_id,
        [parameter(Mandatory = $true)] [string] $lb_detach
    )
    Try {   
        $credentials = New-Object System.Management.Automation.PSCredential ($client_id, (ConvertTo-SecureString $client_Secret -AsPlainText -Force))
        Login-AzAccount -ServicePrincipal -TenantId $tenant_id -Subscription $subscription_id -Credential $Credentials

        If ( $lb_detach -eq 'true' ) {
            Write-Output "About to take $vm_lb_Name out of Load balancer back end pool"
            # $nic_lb_Name = $nicName
            $nic = Get-AzNetworkInterface -ResourceGroupName $rg_lb_Name -Name $nic_lb_Name
            $nic.IpConfigurations[0].LoadBalancerBackendAddressPools = $null
            Set-AzNetworkInterface -NetworkInterface $nic
            Write-Output "Done - removed $vm_lb_Name from backend pool"
        }
        else {
            Write-Output "VM's Removing from Backendpool - Skipped"
        }
    }
    catch { write-host "Exception Message: $($_.Exception.Message)" -ForegroundColor Red }
}
