param (
    [Parameter(Mandatory = $true)][string]$Prefix,
    [Parameter(Mandatory = $true)][string]$SourceRGName,    
    [Parameter(Mandatory = $true)][string]$SourceStorageAccName,
    [Parameter(Mandatory = $true)][string]$SubscriptionId,
    [Parameter(Mandatory = $true)][string]$StorageAccountKey,
    [Parameter(Mandatory = $true)][string]$StorageAccountURL,
    [Parameter(Mandatory = $false)][string]$LogFilePath
)

#----------------------------------------------------------[Declarations]----------------------------------------------------------

[string]$CommonRGName = "CommonRG-JumpBox-Jasper"
[string]$sshTunnelPath = "/ssh-tunnel-keys"
[string]$localKeysPath = "C:\\ssh-keys"

. "$PSScriptRoot/../../PackerTemplates/Scripts/Write-Log.ps1"

#----------------------------------------------------------[Global loading]----------------------------------------------------------


Import-Module powershell-yaml


function Get-ConfigurationYml {
    param(
        [Parameter(Mandatory = $true)][string]$Path
    )
    try {
        $content = Get-Content -Raw -Path $Path
        $data = $content | ConvertFrom-YAML
        return $data
    }
    catch {
        "Exception Message: $($_.Exception.Message)" | Write-Log -UseHost -level ERROR -Path $LogFilePath        
    }
}

function Set-Resource-Group-Peering {

    $SourcePeeringName = $SourceRGName  + "-" + $CommonRGName + "-Peering"
    $DestPeeringName = $CommonRGName  + "-" + $SourceRGName + "-Peering"

    # Set the current subscirption. Otherwise, it might default to other subscriptions and API's might fail
    Get-AzSubscription -SubscriptionId $SubscriptionId | Set-AzContext

    $sourcevnet = Get-AzVirtualNetwork -ResourceGroupName $SourceRGName
    $sourcevnetId = Get-AzVirtualNetwork -ResourceGroupName $SourceRGName | Select-Object -ExpandProperty Id
    $sourcevnetName=$sourcevnet.Name
    $destvnet = Get-AzVirtualNetwork -ResourceGroupName  $CommonRGName
    $destvnetId = Get-AzVirtualNetwork -ResourceGroupName $CommonRGName | Select-Object -ExpandProperty Id
    $destvnetName=$destvnet.Name
    $addressSpace = $sourcevnet.AddressSpace.AddressPrefixes

    $peerings = Get-AzVirtualNetworkPeering -VirtualNetworkName $destvnetName -ResourceGroupName $CommonRGName
    foreach($pr in $peerings){
        $tspace = $pr.RemoteVirtualNetworkAddressSpaceText
        $name = $pr.Name
        if ($tspace.Contains($addressSpace) -or ($name -eq $DestPeeringName)){
            Remove-AzVirtualNetworkPeering -Name $name -VirtualNetworkName $destvnetName -ResourceGroupName $CommonRGName -Force
           "Peering [$DestPeeringName] removed!" |  Write-Log -UseHost -level INFO -Path $LogFilePath 
        }
    }
    $vnetpeering = Get-AzVirtualNetworkPeering -VirtualNetworkName $sourcevnetName -ResourceGroupName $SourceRGName -Name $SourcePeeringName -ErrorAction SilentlyContinue -WarningAction Ignore
    if ($vnetpeering){
        Remove-AzVirtualNetworkPeering -Name $SourcePeeringName -VirtualNetworkName $sourcevnetName -ResourceGroupName $SourceRGName -Force  
    }   
    Add-AzVirtualNetworkPeering -Name $SourcePeeringName -VirtualNetwork $sourcevnet -RemoteVirtualNetworkId  $destvnetId
    #Remove-AzVirtualNetworkPeering -Name $DestPeeringName -VirtualNetworkName $destVnetName -ResourceGroupName $CommonRGName -Force -ErrorAction SilentlyContinue -WarningAction Ignore  
    Add-AzVirtualNetworkPeering -Name $DestPeeringName -VirtualNetwork $destvnet -RemoteVirtualNetworkId  $sourcevnetId
}

function Copy-SSH-Files {

    # Get the base uri and append the ssh-tunnel-keys
    $source_stg_account_ssh_env = [System.Uri] $StorageAccountURL
    $source_stg_account_ssh_env = $source_stg_account_ssh_env.Scheme + "://" + $source_stg_account_ssh_env.Host + $sshTunnelPath
    $source_stg_key_ssh_env = $StorageAccountKey
    & 'C:\Program Files (x86)\Microsoft SDKs\Azure\AzCopy\AzCopy.exe' /Source:"$source_stg_account_ssh_env" /SourceKey:"$source_stg_key_ssh_env" /Dest:"$localKeysPath" /S /V /Y
}


function UpdateRegistryAndLaunchRemoteDesktop {

    $config = Get-ConfigurationYml -Path ".\environment-configuration.yaml"

    foreach($server in $config.servers.Values){
        if (($server["profile"] -eq 'ECB-All-In-One' -or $server["profile"] -eq 'PrimaryPipeline') -and $server.ContainsKey("ip")){
            $ip = $server["ip"]
        }
    }
    if (!$ip){
        "No ECB Server IP found!" | Write-Log -UseHost -level ERROR -Path $LogFilePath
        throw
    }
    else{
        "ECB Server IP = $ip" | Write-Log -UseHost -level INFO -Path $LogFilePath
    }

    "Importing putty session from file..." | Write-Log -UseHost -level WARN -Path $LogFilePath
    $regFile = $localKeysPath + "\ubuntu-ssh-" + $SourceStorageAccName + ".reg"
    Reg Import $regFile

    "Setting value for PortForwardings..." | Write-Log -UseHost -level WARN -Path $LogFilePath
    $regKey = "HKCU:\Software\SimonTatham\PuTTY\Sessions\ubuntu-sshserver-" + $SourceStorageAccName
    Set-ItemProperty  -Path $regKey -Name PortForwardings -Value "L3390=$ip`:3389"

    "Starting putty session..." | Write-Log -UseHost -level WARN -Path $LogFilePath
    $puttyFile = "ubuntu-sshserver-" + $SourceStorageAccName
    putty.exe -load $puttyFile 

    Start-Sleep -s 5
    "Starting RDP session..." | Write-Log -UseHost -level WARN -Path $LogFilePath 
    Mstsc /v:127.0.0.1:3390 
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------

try{
    # Download the .ppk and .reg files from storage account
    "Downloading files from Storage Account..." | Write-Log -UseHost -level WARN -Path $LogFilePath
    Copy-SSH-Files
    
    # Setup the VPN peering between the Common-Resource Group and the newly created resource group
    "Started Resource Groups Peering..." | Write-Log -UseHost -level WARN -Path $LogFilePath
    Set-Resource-Group-Peering 
    "Done Resource Groups Peering..." | Write-Log -UseHost -level WARN -Path $LogFilePath
    
   
    # Update the registry with the appropriate IP address of tunnel, launch putty session to open the tunnel and launch remote desktop
    UpdateRegistryAndLaunchRemoteDesktop
                        
}      
catch {
    "-- $_.Exception" | Write-Log -UseHost -level ERROR -Path $LogFilePath
}
finally {
}
