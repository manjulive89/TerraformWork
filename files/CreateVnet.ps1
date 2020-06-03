function azurelogin {
    param(
        [parameter(Mandatory = $true)]$subscription_id,
        [parameter(Mandatory = $true)]$client_id,
        [parameter(Mandatory = $true)]$client_secret,
        [parameter(Mandatory = $true)]$tenant_id
    )
    try {
        #$credentials= ConvertTo-SecureString -AsPlainText $client_secret -Force
        $Credential = New-Object System.Management.Automation.PSCredential ($client_id, (ConvertTo-SecureString $client_Secret -AsPlainText -Force))
        Login-AzAccount -ServicePrincipal -TenantId $tenant_id -Subscription $subscription_id -Credential $Credential -ErrorAction Stop
    }
    catch {
        write-host "Exception Message: $($_.Exception.Message)" -ForegroundColor Red
    }
}
azurelogin -subscription_id $env:TF_VAR_subscription_id -client_id $env:TF_VAR_client_id -client_secret $env:TF_VAR_client_Secret -tenant_id $env:TF_VAR_tenant_id
function GetVNetDetails {
    param(
        [parameter(Mandatory = $true)]$storage_account_name,
        [parameter(Mandatory = $true)]$resource_group_name
    )
    try {
        #collecting Storage Table details
        $table = @()
        $tableobj = @()
        $TableName = 'VNETDETAILS'
        $Ctx = (Get-AzStorageAccount -ResourceGroupName $resource_group_name -Name $storage_account_name).Context
        $table = Get-AzTableTable -Context $Ctx -Name $TableName -ErrorAction Stop
        $tableobj = Get-AzTableRow -table $table -ErrorAction Stop
        #collecting Azure Virtual network Information
        $vnetObj = (Get-AzVirtualNetwork).AddressSpace.AddressPrefixes
        
        foreach ($value in $tableobj) {
            if (-not($value.VnetAddressPrefix -in $vnetObj)) {
                return $value.VnetAddressPrefix
                break
            }
        }
    }
    catch {
        write-host "Exception Message: $($_.Exception.Message)" -ForegroundColor Red
    }
}
$address = GetVNetDetails -storage_account_name $env:TF_VAR_storage_account_name -resource_group_name $env:TF_VAR_resource_group_name
[Environment]::SetEnvironmentVariable( "vnet_address_space", "$address", "user" )
