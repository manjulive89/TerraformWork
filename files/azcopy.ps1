<#
    .SYNOPSIS
        azcopy

    .DESCRIPTION
        Upload environment-configuration.yaml and ssh keys to newly created storage account

    .EXAMPLE
        PS C:\> .\azcopy.ps1 -ResourceGroupName 'KeyvaultRG' -RGKeyvaultName 'KeyvaultName' -MasterKeyvaultName 'MasterVault'

    .NOTES
        Pre-req for this script is to run JsonToYaml.ps1 script
#>

param (
    [Parameter(Mandatory = $true)][string]$SourceStorageAccountSSHkeysURL,
    [Parameter(Mandatory = $true)][string]$SourceStorageAccountKey,
    [Parameter(Mandatory = $true)][string]$DestinationStorageAccountName,
    [Parameter(Mandatory = $true)][string]$DestinationStoraAccountKey
)

#-----Install azcopy
$azcopyurl = "https://azcopy.azureedge.net/azcopy-8-1-0/MicrosoftAzureStorageAzCopy_netcore_x64.msi"
$filename = "$env:Userprofile\downloads\MicrosoftAzureStorageAzCopy_netcore_x64.msi"
(New-Object System.Net.WebClient).DownloadFile($azcopyurl, "$filename") 
try {
    if (Test-Path -Path "$filename") {
        Start-Process -FilePath "$env:systemroot\system32\msiexec.exe" -ArgumentList "/i $filename /quiet" -wait
    }
}
catch {
    write-host "Exception Message: $($_.Exception.Message)" -ForegroundColor Red
}

#-----Upload environment-configuration.yaml file to newly created storage account
try {
    # if (Test-Path -Path $JsonOutputFileLocation) {
    #     $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent
    #     . "$PSScriptRoot\JsonToYaml.ps1" -jsonpath $JsonOutputFileLocation
    # }
    # else {
    #     exit 1
    # }
    if (Test-Path -Path ".\environment-configuration.yaml") {
        Write-Host("Uploading yaml to File storage")
        & 'C:\Program Files (x86)\Microsoft SDKs\Azure\AzCopy\AzCopy.exe' /Source:. /Dest:https://$DestinationStorageAccountName.blob.core.windows.net/environment-configuration /DestKey:$DestinationStoraAccountKey /S /Pattern:environment-configuration.yaml /V /Y
    }
    else {
        Write-Host "environment-configuration.yaml file missing"
        exit 1
    }

#-----Copy SSHkeys from source storage account to newly created storage account
    if ((Test-Path -Path "C:\Program Files (x86)\Microsoft SDKs\Azure\AzCopy\AzCopy.exe") -or (Test-Path -Path "C:\Program Files\Microsoft SDKs\Azure\AzCopy\AzCopy.exe" )) {
        Write-Host("Copying sshkeys to File storage")
        & 'C:\Program Files (x86)\Microsoft SDKs\Azure\AzCopy\AzCopy.exe' /Source:$SourceStorageAccountSSHkeysURL /Dest:https://$DestinationStorageAccountName.blob.core.windows.net/ssh /SourceKey:$SourceStorageAccountKey /DestKey:$DestinationStoraAccountKey /S /V /Y
    }
    else {
        Write-Host "sshkeys doesn't exist on storage account"
        exit 1
        
    }    
}
catch {
    write-host "Exception Message: $($_.Exception.Message)" -ForegroundColor Red
}
