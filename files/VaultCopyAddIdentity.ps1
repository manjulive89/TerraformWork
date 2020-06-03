<#
    .SYNOPSIS
        VaultCopyAddIdentity

    .DESCRIPTION
        This script adds permission to systemassigned VM identity and copies the data from master to slave key vault

    .EXAMPLE
        PS C:\> .\VaultCopyAddIdentity.ps1 -ResourceGroupName 'KeyvaultRG' -RGKeyvaultName 'KeyvaultName' -MasterKeyvaultName 'MasterVault'

    .NOTES
        Before running this script user has to login to azure command - "az login" and select the subscription
#>

param(
    [parameter(Mandatory = $true)]$ResourceGroupName,
    [parameter(Mandatory = $true)]$RGKeyvaultName,
    [parameter(Mandatory = $true)]$MasterKeyvaultName,
    [Parameter(Mandatory = $false)][string]$LogFilePath,
    [parameter(Mandatory = $false)]$EnvironmentYamlFile = ".\environment-configuration.yaml"
)

#----------------------------------------------------------[Declarations]----------------------------------------------------------

. "$PSScriptRoot/../../PackerTemplates/Scripts/Write-Log.ps1"

#----------------------------------------------------------[Functions]----------------------------------------------------------

function Get-EnvironmentYaml {
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

function AddVMinAccessPolicy {

    $vmnames = Get-EnvironmentYaml -Path "$EnvironmentYamlFile"

    foreach ($vmname in $vmnames.Servers.Keys) {
        $VMObjectId = (Get-AzVM -Name $vmname -ResourceGroupName $ResourceGroupName).Identity.PrincipalId
        $oKeyvault = (Get-AzKeyVault -VaultName $RGKeyvaultName -ResourceGroupName $ResourceGroupName).AccessPoliciesText
        if ($oKeyvault -match $VMObjectId) {
            "VM $vmname with identity is already added into the vault" | Write-Log -UseHost -level WARN -Path $LogFilePath
        }
        else {
            "Setting AccessPolicy permissions for $vmname" | Write-Log -UseHost -level INFO -Path $LogFilePath
            Set-AzKeyVaultAccessPolicy -VaultName $RGKeyvaultName -ResourceGroupName $ResourceGroupName -ObjectId $VMObjectId -PermissionsToSecrets get, list, set -BypassObjectIdValidation -Verbose -ErrorAction Stop
        }
    }
}

function AzVaultCopy {

    if (Get-AzKeyVaultSecret -VaultName $MasterKeyvaultName -ErrorAction stop) {
        
        $secrets = (Get-AzKeyVaultSecret -VaultName $MasterKeyvaultName).Name | Write-Log -UseHost -level INFO -Path $LogFilePath

        $secrets.ForEach{
            Set-AzKeyVaultSecret -VaultName $RGKeyvaultName -Name $_ `
                -SecretValue (Get-AzKeyVaultSecret -VaultName $MasterKeyvaultName -Name $_).SecretValue -ErrorAction Stop | Write-Log -UseHost -level INFO -Path $LogFilePath
        }
    }
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------

try {
    "Adding systemassigned identity vm's to the $RGKeyvaultName access_policy" | Write-Log -UseHost -level INFO -Path $LogFilePath
    AddVMinAccessPolicy
    "Copying the data from master $MasterKeyvaultName to RG $RGKeyvaultName key vault" | Write-Log -UseHost -level INFO -Path $LogFilePath
    AzVaultCopy
    "Copied the above keys/secrets/certificates" | Write-Log -UseHost -level INFO -Path $LogFilePath
}
catch {
    "$_.Exception" | Write-Log -UseHost -level ERROR -Path $LogFilePath
}
