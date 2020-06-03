#requires -version 5

<#
.SYNOPSIS
Install PowerShell Dependencies

.DESCRIPTION
Terraform Create-Infrastructure script to automate the steps of azure infrastructure creation of each directory per environment
List of environments : dev, qa, stage and prod.
The environment, mode and prefix can be configured in config.yaml 


.EXAMPLE 
- For DeploymentMethod Deploy_1 or Deploy_2  
.\Create-Infrastructure.ps1 -TFCommand init -SecretsFilePath .\secrets.yaml -ConfigurationPath .\config.yaml -DeploymentMethod deploy_1
.\Create-Infrastructure.ps1 -TFCommand init -SecretsFilePath .\secrets.yaml -ConfigurationPath .\config.yaml -DeploymentMethod deploy_2

.EXAMPLE
.\Create-Infrastructure.ps1 -TFCommand plan -SecretsFilePath .\secrets.yaml -ConfigurationPath .\config.yaml -DeploymentMethod deploy_1
.\Create-Infrastructure.ps1 -TFCommand plan -SecretsFilePath .\secrets.yaml -ConfigurationPath .\config.yaml -DeploymentMethod deploy_2

.EXAMPLE 
- Using the default value of vNetAddressSpace 
.\Create-Infrastructure.ps1 -TFCommand apply -SecretsFilePath .\secrets.yaml -ConfigurationPath .\config.yaml -DeploymentMethod deploy_1
.\Create-Infrastructure.ps1 -TFCommand apply -SecretsFilePath .\secrets.yaml -ConfigurationPath .\config.yaml -DeploymentMethod deploy_2

.EXAMPLE 
- When getvnetaddress flag is enabled, it will fetch the address space from the storage account comparing to the vnet address spaces in subscription
.\Create-Infrastructure.ps1 -TFCommand apply -SecretsFilePath .\secrets.yaml -ConfigurationPath .\config.yaml -DeploymentMethod deploy_1 -getvnetaddress
.\Create-Infrastructure.ps1 -TFCommand apply -SecretsFilePath .\secrets.yaml -ConfigurationPath .\config.yaml -DeploymentMethod deploy_2 -getvnetaddress

.EXAMPLE
.\Create-Infrastructure.ps1 -TFCommand apply-all -SecretsFilePath .\secrets.yaml -ConfigurationPath .\config.yaml -DeploymentMethod deploy_1 
.\Create-Infrastructure.ps1 -TFCommand apply-all -SecretsFilePath .\secrets.yaml -ConfigurationPath .\config.yaml -DeploymentMethod deploy_2

.EXAMPLE
.\Create-Infrastructure.ps1 -TFCommand apply-all -SecretsFilePath .\secrets.yaml -ConfigurationPath .\config.yaml -DeploymentMethod deploy_1 -getvnetaddress
.\Create-Infrastructure.ps1 -TFCommand apply-all -SecretsFilePath .\secrets.yaml -ConfigurationPath .\config.yaml -DeploymentMethod deploy_2 -getvnetaddress

.EXAMPLE
.\Create-Infrastructure.ps1 -DestroyMode deploy_1 -TFCommand destroy -ConfigurationPath .\config.yaml <Select var file when pop up window is open>
.\Create-Infrastructure.ps1 -DestroyMode deploy_2 -TFCommand destroy -ConfigurationPath .\config.yaml <Select var file when pop up window is open>
.\Create-Infrastructure.ps1 -DestroyMode all -TFCommand destroy -ConfigurationPath .\config.yaml <Select var file when pop up window is open>

.EXAMPLE
.\Create-Infrastructure.ps1 -TFCommand output -ConfigurationPath .\config.yaml -DeploymentMethod deploy_1 
.\Create-Infrastructure.ps1 -TFCommand output -ConfigurationPath .\config.yaml -DeploymentMethod deploy_2

.NOTES
Add secrets.yaml to the .gitignore
Separate Config_<env>.yaml can be used for each environment <env> = dev|qa|stage|prod
It is recommended to add the yaml file to .gitignore file as it contains azure keys.
#>

param(
    [Parameter(Mandatory = $false, HelpMessage = "Configuration file path" , ParameterSetName = "Apply")][parameter(ParameterSetName = "DestroyMode")]
    [string] $ConfigurationPath,
    [Parameter(Mandatory = $false, HelpMessage = "Secrets file path" , ParameterSetName = "Apply")][parameter(ParameterSetName = "DestroyMode")]
    [string] $SecretsFilePath,
    [Parameter(Mandatory = $false, HelpMessage = "Terraform command: Init | Apply | plan | destroy", ParameterSetName = "Apply")][parameter(ParameterSetName = "DestroyMode")][validateset("init", "plan", "apply", "output", "destroy", "apply-all")]
    [string] $TFCommand,
    [Parameter(Mandatory = $false, HelpMessage = "Deployment Method deploy_1 | deploy_2", ParameterSetName = "Apply")][validateset("deploy_1", "deploy_2")]
    [string] $DeploymentMethod,
    [parameter(Mandatory = $false, HelpMessage = "Force switch", ParameterSetName = "Apply")]
    [switch]$force,
    [parameter(Mandatory = $false, HelpMessage = "Get Vnet Address Space switch", ParameterSetName = "Apply")][parameter(ParameterSetName = "DestroyMode")]
    [switch]$getvnetaddress,
    [parameter(Mandatory = $false, HelpMessage = "Create ssh tunneling", ParameterSetName = "Apply")]
    [switch]$createtunnel,
    [parameter(Mandatory = $true, HelpMessage = "Destroy Command All|Deploy_1|Deploy_2", ParameterSetName = "DestroyMode")][validateset("all", "deploy_1", "deploy_2")]
    $DestroyMode
)


#------------------------------------------------------------[LogSetup]------------------------------------------------------------

. "$PSScriptRoot/../PackerTemplates/Scripts/Write-Log.ps1"

$ScriptName = "$([System.IO.Path]::GetFileNameWithoutExtension($PSCommandPath))"

#---------------------------------------------------------[Initializations]--------------------------------------------------------
Import-Module powershell-yaml

function Get-Configuration {
    param(
        [Parameter(Mandatory = $true)][string]$ConfigurationPath
    )
    try {
        $content = Get-Content -Raw -Path $ConfigurationPath
        $configuration = $content | ConvertFrom-YAML
        $configuration
        $secrets
    }
    catch {
        write-host "Exception Message: $($_.Exception.Message)" -ForegroundColor Red        
    }
}

#----------------------------------------------------------[Declarations]----------------------------------------------------------
#----- Setting Directories
$configuration = Get-Configuration -ConfigurationPath $ConfigurationPath
$secrets = Get-Configuration -ConfigurationPath $SecretsFilePath
$script:TFDirectory = "$PSScriptRoot"

#----- Reading yaml file
$environment = $configuration.initialconfiguration.environment.ToLower()
$mode = $configuration.initialconfiguration.mode
$prefix = $configuration.initialconfiguration.prefix
$vnet_storage_account_name = $configuration.initialconfiguration.vnet_storage_account_name
$vnet_resource_group_name = $configuration.initialconfiguration.vnet_resource_group_name
$VnetTableName = $configuration.initialconfiguration.VnetTableName

$vNetAddressSpace = $configuration.azure.vNetAddressSpace
$location = $configuration.azure.location
$custom_image_name = $configuration.azure.custom_image_name
$custom_image_resource_group_name = $configuration.azure.custom_image_resource_group_name
$jasper_image_name = $configuration.azure.jasper_image_name
$jasper_image_resource_group_name = $configuration.azure.jasper_image_resource_group_name
$vertex_image_name = $configuration.azure.vertex_image_name
$vertex_image_resource_group_name = $configuration.azure.vertex_image_resource_group_name
$master_key_vault_name = $configuration.azure.master_key_vault_name

$JasperImage = $configuration.vmconfiguration.jsp_vm_count
$VertexImage = $configuration.vmconfiguration.vtx_vm_count

$storage_account_name = "ecbaasenv$environment$prefix"
$resource_group_name = "e-$prefix-$environment"
$rg_key_vault_name = "$prefix-$environment-vault"

$subscription_id = $secrets.keys.subscription_id
$client_id = $secrets.keys.client_id
$client_secret = $secrets.keys.client_secret
$tenant_id = $secrets.keys.tenant_id
$object_id = $secrets.keys.object_id
$source_stg_account_ssh_env = $secrets.keys.SourceStorageAccountSSHkeysURL
$source_stg_key_ssh_env = $secrets.keys.SourceStorageAccountKey
$admin_password = $secrets.keys.admin_password
$jb_admin_password = $secrets.keys.jb_admin_password

$SelectDeploymentMethod = @{
    'deploy_1' = 'deploy_2';
    'deploy_2' = 'deploy_1'
}

#----- Log file path based on mode and environment

if (!$LogFilePath) {
    $LogFilePath = "$env:SystemDrive/logs/$($ScriptName).$mode.$environment.{yyyy-MM-dd}.log"
}

#-----------------------------------------------------------[Functions]------------------------------------------------------------
#----- Get un-allocated vnet ip within the subscription
#----- Pre-requisite for this is storage account and table should be created containing address spaces which is used to compared within subscription.
function Check-Values {
    param (
        [Parameter(Mandatory = $true)][string]$client_id,
        [Parameter(Mandatory = $true)][string]$client_secret,
        [Parameter(Mandatory = $true)][string]$tenant_id,
        [Parameter(Mandatory = $true)][string]$subscription_id,
        [parameter(Mandatory = $true)][string]$vnet_storage_account_name,
        [parameter(Mandatory = $true)][string]$vnet_resource_group_name,
        [parameter(Mandatory = $true)][string]$custom_image_name,
        [parameter(Mandatory = $true)][string]$custom_image_resource_group_name,
        [parameter(Mandatory = $true)][string]$jasper_image_name,
        [parameter(Mandatory = $true)][string]$jasper_image_resource_group_name,
        [parameter(Mandatory = $true)][string]$vertex_image_name,
        [parameter(Mandatory = $true)][string]$vertex_image_resource_group_name,
        [parameter(Mandatory = $true)][string]$JasperImage,
        [parameter(Mandatory = $true)][string]$VertexImage,
        [parameter(Mandatory = $true)][string]$VnetTableName
    )
    try {
        "Logging into Azure Subscription..." | Write-Log -UseHost -Path $LogFilePath
        $credentials = New-Object System.Management.Automation.PSCredential ($client_id, (ConvertTo-SecureString $client_Secret -AsPlainText -Force)) -ErrorAction Stop
        $oAuth = Login-AzAccount -ServicePrincipal -TenantId $tenant_id -Subscription $subscription_id -Credential $Credentials -WarningAction Ignore -ErrorAction Stop
    }
    catch {
        write-host "Exception Message: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
    if ($oAuth) {
        "Checking ECB image info" | Write-Log -UseHost -Path $LogFilePath
        Get-AzImage -ResourceGroupName $custom_image_resource_group_name -ImageName $custom_image_name -ErrorAction Stop
        if ($JasperImage -gt 0) {
            "Checking jasper image info" | Write-Log -UseHost -Path $LogFilePath
            Get-AzImage -ResourceGroupName $jasper_image_resource_group_name -ImageName $jasper_image_name -ErrorAction Stop
        }
        if ($VertexImage -gt 0) {
            "Checking vertex image info" | Write-Log -UseHost -Path $LogFilePath
            Get-AzImage -ResourceGroupName $vertex_image_resource_group_name -ImageName $vertex_image_name -ErrorAction Stop
        }
        if ($getvnetaddress) {
            "Checking vnet storage account table details" | Write-Log -UseHost -Path $LogFilePath            
            $TableName = "$VnetTableName"
            Get-AzStorageAccount -ResourceGroupName $vnet_resource_group_name -Name $vnet_storage_account_name -ErrorAction Stop
            Get-AzTableTable -resourceGroup $vnet_resource_group_name -tableName $TableName -storageAccountName $vnet_storage_account_name -ErrorAction Stop
        }
        "Checking $master_key_vault_name vault info" | Write-Log -UseHost -Path $LogFilePath 
        Get-AzKeyVaultSecret -VaultName $master_key_vault_name -Verbose -ErrorAction stop
    }
}

function GetVNetDetails {
    param(
        [parameter(Mandatory = $true)][string]$vnet_storage_account_name,
        [parameter(Mandatory = $true)][string]$vnet_resource_group_name,
        [parameter(Mandatory = $true)][string]$VnetTableName
    )
    try {
        if ($environment -eq 'Dev' -or $environment -eq 'QA' -or $environment -eq 'Stage' -or $environment -eq 'Prod') {
            #collecting Storage Table details
            $table = @()
            $tableobj = @()
            $TableName = "$VnetTableName"
            $Ctx = (Get-AzStorageAccount -ResourceGroupName $vnet_resource_group_name -Name $vnet_storage_account_name).Context
            $table = Get-AzTableTable -resourceGroup $vnet_resource_group_name -tableName $TableName -storageAccountName $vnet_storage_account_name -ErrorAction Stop
            $tableobj = Get-AzTableRow -table $table -ErrorAction Stop
            
            #collecting Azure Virtual network Information
            $vnetObj = (Get-AzVirtualNetwork -WarningAction Ignore).AddressSpace.AddressPrefixes
        
            foreach ($value in $tableobj) {
                if (Get-AzVirtualNetwork -Name "$prefix-vnet-$environment" -ResourceGroupName $resource_group_name -ErrorAction SilentlyContinue -WarningAction Ignore) {                
                    $existingaddress = (Get-AzVirtualNetwork -Name "$prefix-vnet-$environment" -ResourceGroupName $resource_group_name -WarningAction Ignore).AddressSpace.AddressPrefixes
                    return $existingaddress
                    break
                }
                elseif ($value.VnetAddressPrefix -notin $vnetObj) {
                    return $value.VnetAddressPrefix
                    break
                }
            }
        }
        else {
            "getting vnet ip address - skipped" | Write-Log -UseHost -Path $LogFilePath
        }
    }
    catch {
        write-host "Exception Message: $($_.Exception.Message)" -ForegroundColor Red
    }
}

#----- Creates a Resource Group and Storage account if it doesn't exists
function Create-StorageAccount {
    param (
        [Parameter(Mandatory = $true)][string]$prefix,
        [Parameter(Mandatory = $true)][string]$client_id,
        [Parameter(Mandatory = $true)][string]$client_secret,
        [Parameter(Mandatory = $true)][string]$tenant_id,
        [Parameter(Mandatory = $true)][string]$subscription_id,
        [Parameter(Mandatory = $true)][string]$mode,
        [Parameter(Mandatory = $true)][string]$environment, 
        [Parameter(Mandatory = $true)][string]$location,
        [Parameter(Mandatory = $true)][string]$DeploymentMethod,
        $configuration,
        $secrets
    )
    if (!(Get-AzResourceGroup -Name $resource_group_name -ErrorAction SilentlyContinue)) {
        "Creating new rg $resource_group_name....." | Write-Log -UseHost -Path $LogFilePath
        New-AzResourceGroup -Name $resource_group_name -Location $location -Tag @{environment = "$environment"; prefix = "$prefix" } -ErrorAction SilentlyContinue -Verbose
    }
    else {
        "Resource Group exists - Getting details" | Write-Log -UseHost -Path $LogFilePath
    }

    if (Get-AzResourceGroup -Name $resource_group_name) {
        $oStorage = Get-AzStorageAccount -ResourceGroupName $resource_group_name -Name $storage_account_name -ErrorAction SilentlyContinue

        if (!($oStorage)) {
            "Creating new storage account $storage_account_name in rg $resource_group_name" | Write-Log -UseHost -Path $LogFilePath
            $oStorage = New-AzStorageAccount -ResourceGroupName $resource_group_name -Name $storage_account_name -Tag @{environment = "$environment"; prefix = "$prefix" } -SkuName Standard_LRS -Location $location -Verbose -ErrorAction Stop
            $oStorageContainer = New-AzRmStorageContainer -Name $prefix -ResourceGroupName $resource_group_name -StorageAccountName $storage_account_name
            $oStorageKeys = Get-AzStorageAccountKey -ResourceGroupName $resource_group_name -Name $storage_account_name
        }
        else {
            "Storage account exists - Getting details" | Write-Log -UseHost -Path $LogFilePath
        }

        "Getting storage account $storage_account_name info..." | Write-Log -UseHost -Path $LogFilePath
        if (Get-AzStorageAccount -ResourceGroupName $resource_group_name -Name $storage_account_name) {
                    
            $oStorage = Get-AzStorageAccount -ResourceGroupName $resource_group_name -Name $storage_account_name -ErrorAction SilentlyContinue
            $oStorageContainer = Get-AzRmStorageContainer -Name $prefix -ResourceGroupName $resource_group_name -StorageAccountName $storage_account_name -ErrorAction SilentlyContinue
            $oStorageKeys = Get-AzStorageAccountKey -ResourceGroupName $resource_group_name -Name $storage_account_name -ErrorAction SilentlyContinue
        }
        $access_key = $oStorageKeys.GetValue(0).value
        $secrets.keys.Add('access_key', $access_key)
        $configuration.initialconfiguration
        $secrets.keys
    }
}

#----- Terraform init downloads the required modules and setup the backend for storage account
Function Initiate-Configuration {
    param (
        [Parameter(Mandatory = $true)][string]$mode,
        [Parameter(Mandatory = $true)][string]$environment,
        [Parameter(Mandatory = $true)][string]$DeploymentMethod,
        $configuration,
        $secrets
    )

    #----- This command downloads the required providers
    terraform init
    
    #----- Generate Varfile    
    try {
        "Performing the operation 'Output to file' on target $script:TFDirectory\Variables\$mode\$prefix-$mode-$environment-$DeploymentMethod.tfvars.json" | Write-Log -UseHost -Path $LogFilePath
        $configuration.values | ForEach-Object { $jsonobj += $_ }
        $jsonobj | ConvertTo-Json | Out-File -Encoding Oem "$script:TFDirectory\Variables\$mode\$prefix-$mode-$environment-$DeploymentMethod.tfvars.json" -Force
    }
    catch {
        Write-Host "Exception Message: $($_.Exception.Message)"
        Exit 1
    }

    $configuration
    $secrets
    Set-Location "$script:TFDirectory/$mode/$environment"

    foreach ($subdirectory in $((Get-ChildItem -Directory .).Name)) {
        if ($(Get-ChildItem -Directory $subdirectory) -eq $null -or $force) {
            Push-Location ./$subdirectory
            $lstgname = "$storage_account_name"
            $lconname = "$prefix"
            $laccesskey = "$($secrets.keys.access_key)"

            "Initializing Configuration of $subdirectory" | Write-Log -UseHost -Path $LogFilePath
            terraform init -backend-config="storage_account_name=$lstgname" `
                -backend-config="container_name=$lconname" `
                -backend-config="access_key=$laccesskey" `
                -backend-config="key=$environment-$subdirectory.tfstate" `
                -plugin-dir ..\..\..\.\.terraform\plugins\windows_amd64\ | Write-Log -UseTee -Path $LogFilePath
            Pop-Location 
        }
        else {
            "Terrafrom Already Initiated" | Write-Log -UseHost -Path $LogFilePath
        }
    }
    Set-Location "$script:TFDirectory"
}

#----- Terraform plan - Use case here is vnet_subnet has to be created first to see plan of ecb-deploy_1 | ecb-deploy_2 | mssql_jh.
Function Plan-Configuration {
    param(
        [Parameter(Mandatory = $true)][string]$mode,
        [Parameter(Mandatory = $true)][string]$environment,
        [Parameter(Mandatory = $true)][string]$DeploymentMethod,
        [Parameter(Mandatory = $true)][string]$vnet_storage_account_name,
        [Parameter(Mandatory = $true)][string]$vnet_resource_group_name,
        $configuration,
        $secrets
    )

    Set-Location "$script:TFDirectory/$mode/$environment"
    $variable = "$script:TFDirectory/variables/$mode"
    $variable

    if ($getvnetaddress) {
        [System.Collections.ArrayList]$subdirectories = $((Get-ChildItem -Directory .).Name)
        [string]$removevalue = $subdirectories -match $SelectDeploymentMethod[$DeploymentMethod]
        $subdirectories.Remove($removevalue)

        "Getting address space for vnet..." | Write-Log -UseHost -Path $LogFilePath

        $vnet_address = GetVNetDetails -vnet_storage_account_name $vnet_storage_account_name -vnet_resource_group_name $vnet_resource_group_name -VnetTableName $VnetTableName

        "vnet address space = $vnet_address" | Write-Log -UseHost -Path $LogFilePath

        foreach ($subdirectory in $subdirectories) {
            Push-Location ./$subdirectory

            "planning Configuration of $subdirectory" | Write-Log -UseHost -Path $LogFilePath
            terraform plan `
                -var-file "$variable/$prefix-$mode-$environment-$DeploymentMethod.tfvars.json" `
                -var "prefix=$prefix" `
                -var "environment=$environment" `
                -var "vnet_address_space=$vnet_address" `
                -var "client_id=$client_id" `
                -var "client_secret=$client_secret" `
                -var "tenant_id=$tenant_id" `
                -var "object_id=$object_id" `
                -var "subscription_id=$subscription_id" `
                -var "admin_password=$admin_password" `
                -var "jb_admin_password=$jb_admin_password" `
                -var "location=$location" | Write-Log -UseTee -Path $LogFilePath
            Pop-Location
        }
        Set-Location "$script:TFDirectory"
    }
    else {
        [System.Collections.ArrayList]$subdirectories = $((Get-ChildItem -Directory .).Name)
        [string]$removevalue = $subdirectories -match $SelectDeploymentMethod[$DeploymentMethod]
        $subdirectories.Remove($removevalue)

        foreach ($subdirectory in $subdirectories) {
            Push-Location ./$subdirectory

            "planning Configuration of $subdirectory" | Write-Log -UseHost -Path $LogFilePath
            terraform plan `
                -var-file "$variable/$prefix-$mode-$environment-$DeploymentMethod.tfvars.json" `
                -var "prefix=$prefix" `
                -var "environment=$environment" `
                -var "vnet_address_space=$vNetAddressSpace" `
                -var "client_id=$client_id" `
                -var "client_secret=$client_secret" `
                -var "tenant_id=$tenant_id" `
                -var "object_id=$object_id" `
                -var "subscription_id=$subscription_id" `
                -var "admin_password=$admin_password" `
                -var "jb_admin_password=$jb_admin_password" `
                -var "location=$location" | Write-Log -UseTee -Path $LogFilePath
            Pop-Location
        }
        Set-Location "$script:TFDirectory"
    }
}

#----- Terraform apply Command
Function Apply-Configuration {
    param(
        [Parameter(Mandatory = $true)][string]$mode,
        [Parameter(Mandatory = $true)][string]$environment,
        [Parameter(Mandatory = $true)][string]$DeploymentMethod,
        [Parameter(Mandatory = $true)][string]$vnet_storage_account_name,
        [Parameter(Mandatory = $true)][string]$vnet_resource_group_name,
        $configuration,
        $secrets
    )
    
    Set-Location "$script:TFDirectory/$mode/$environment"
    $variable = "$script:TFDirectory/variables/$mode"
    $variable

    if ($getvnetaddress) {
        [System.Collections.ArrayList]$subdirectories = $((Get-ChildItem -Directory .).Name)
        [string]$removevalue = $subdirectories -match $SelectDeploymentMethod[$DeploymentMethod]
        $subdirectories.Remove($removevalue)

        "Getting address space for vnet..." | Write-Log -UseHost -Path $LogFilePath

        $vnet_address = GetVNetDetails -vnet_storage_account_name $vnet_storage_account_name -vnet_resource_group_name $vnet_resource_group_name -VnetTableName $VnetTableName

        "vnet address space = $vnet_address" | Write-Log -UseHost -Path $LogFilePath

        foreach ($subdirectory in $subdirectories) {
            Push-Location ./$subdirectory

            "applying Configuration of $subdirectory" | Write-Log -UseHost -Path $LogFilePath
            terraform apply -auto-approve `
                -var-file "$variable/$prefix-$mode-$environment-$DeploymentMethod.tfvars.json" `
                -var "prefix=$prefix" `
                -var "environment=$environment" `
                -var "vnet_address_space=$vnet_address" `
                -var "client_id=$client_id" `
                -var "client_secret=$client_secret" `
                -var "tenant_id=$tenant_id" `
                -var "object_id=$object_id" `
                -var "subscription_id=$subscription_id" `
                -var "admin_password=$admin_password" `
                -var "jb_admin_password=$jb_admin_password" `
                -var "location=$location" | Write-Log -UseTee -Path $LogFilePath
            Pop-Location
        }
        Set-Location "$script:TFDirectory"
    }
    else {
        [System.Collections.ArrayList]$subdirectories = $((Get-ChildItem -Directory .).Name)
        [string]$removevalue = $subdirectories -match $SelectDeploymentMethod[$DeploymentMethod]
        $subdirectories.Remove($removevalue)

        foreach ($subdirectory in $subdirectories) {
            Push-Location ./$subdirectory

            "applying Configuration of $subdirectory" | Write-Log -UseHost -Path $LogFilePath
            terraform apply -auto-approve `
                -var-file "$variable/$prefix-$mode-$environment-$DeploymentMethod.tfvars.json" `
                -var "prefix=$prefix" `
                -var "environment=$environment" `
                -var "vnet_address_space=$vNetAddressSpace" `
                -var "client_id=$client_id" `
                -var "client_secret=$client_secret" `
                -var "tenant_id=$tenant_id" `
                -var "object_id=$object_id" `
                -var "subscription_id=$subscription_id" `
                -var "admin_password=$admin_password" `
                -var "jb_admin_password=$jb_admin_password" `
                -var "location=$location" | Write-Log -UseTee -Path $LogFilePath
            Pop-Location
        }
        Set-Location "$script:TFDirectory"
    }
}

#----- Terraform destroy Command based on the environment.
function Destroy-Configuration {
    param (
        $mode,
        $DestroyMode,
        $environment,
        $DeploymentMethod,
        $configuration,
        $secrets
    )
    
    Set-Location "$script:TFDirectory/$mode/$environment"
    $variable = "$script:TFDirectory/variables/$mode"
    $variable
    $Varfile = (Get-ChildItem -Path $variable -File | Out-GridView -PassThru).FullName

    if ($getvnetaddress.IsPresent) {

        "Getting address space for vnet..." | Write-Log -UseHost -Path $LogFilePath

        $vnet_address = GetVNetDetails -vnet_storage_account_name $vnet_storage_account_name -vnet_resource_group_name $vnet_resource_group_name -VnetTableName $VnetTableName

        "vnet address space = $vnet_address" | Write-Log -UseHost -Path $LogFilePath
        
        if ($DestroyMode -eq "All") {
            [System.Collections.ArrayList]$subdirectories = $((Get-ChildItem -Directory .).Name)

            foreach ($subdirectory in ($subdirectories | Sort-Object -Descending)) {
                Push-Location ./$subdirectory

                "Destroying Configuration of $subdirectory" | Write-Log -UseHost -Path $LogFilePath
                terraform destroy -auto-approve `
                    -var-file "$Varfile" `
                    -var "prefix=$prefix" `
                    -var "environment=$environment" `
                    -var "vnet_address_space=$vnet_address" `
                    -var "client_id=$client_id" `
                    -var "client_secret=$client_secret" `
                    -var "tenant_id=$tenant_id" `
                    -var "object_id=$object_id" `
                    -var "subscription_id=$subscription_id" `
                    -var "admin_password=$admin_password" `
                    -var "jb_admin_password=$jb_admin_password" `
                    -var "location=$location" | Write-Log -UseTee -Path $LogFilePath
                Pop-Location
            }
            Set-Location "$script:TFDirectory"
        }
        if ($DestroyMode -ne "All") {
            [System.Collections.ArrayList]$subdirectories = $((Get-ChildItem -Directory .).Name)
            [string]$removedirectory = $subdirectories -match $DestroyMode
            # $subdirectories.Remove($removevalue)

            foreach ($subdirectory in $removedirectory) {
                Push-Location ./$subdirectory

                "Destroying Configuration of $subdirectory" | Write-Log -UseHost -Path $LogFilePath
                terraform destroy -auto-approve `
                    -var-file "$Varfile" `
                    -var "prefix=$prefix" `
                    -var "environment=$environment" `
                    -var "vnet_address_space=$vnet_address" `
                    -var "client_id=$client_id" `
                    -var "client_secret=$client_secret" `
                    -var "tenant_id=$tenant_id" `
                    -var "object_id=$object_id" `
                    -var "subscription_id=$subscription_id" `
                    -var "admin_password=$admin_password" `
                    -var "jb_admin_password=$jb_admin_password" `
                    -var "location=$location" | Write-Log -UseTee -Path $LogFilePath
                Pop-Location
            }
            Set-Location "$script:TFDirectory"
        }
    }

    if (!($getvnetaddress)) {
        if ($DestroyMode -eq "All") {
            [System.Collections.ArrayList]$subdirectories = $((Get-ChildItem -Directory .).Name)

            foreach ($subdirectory in ($subdirectories | Sort-Object -Descending)) {
                Push-Location ./$subdirectory

                "Destroying Configuration of $subdirectory" | Write-Log -UseHost -Path $LogFilePath
                terraform destroy -auto-approve `
                    -var-file "$Varfile" `
                    -var "prefix=$prefix" `
                    -var "environment=$environment" `
                    -var "vnet_address_space=$vNetAddressSpace" `
                    -var "client_id=$client_id" `
                    -var "client_secret=$client_secret" `
                    -var "tenant_id=$tenant_id" `
                    -var "object_id=$object_id" `
                    -var "subscription_id=$subscription_id" `
                    -var "admin_password=$admin_password" `
                    -var "jb_admin_password=$jb_admin_password" `
                    -var "location=$location" | Write-Log -UseTee -Path $LogFilePath
                Pop-Location
            }
            Set-Location "$script:TFDirectory"
        }
        if ($DestroyMode -ne "All") {
            [System.Collections.ArrayList]$subdirectories = $((Get-ChildItem -Directory .).Name)
            [string]$removedirectory = $subdirectories -match $DestroyMode
            # $subdirectories.Remove($removevalue)

            foreach ($subdirectory in $removedirectory) {
                Push-Location ./$subdirectory

                "Destroying Configuration of $subdirectory" | Write-Log -UseHost -Path $LogFilePath
                terraform destroy -auto-approve `
                    -var-file "$Varfile" `
                    -var "prefix=$prefix" `
                    -var "environment=$environment" `
                    -var "vnet_address_space=$vNetAddressSpace" `
                    -var "client_id=$client_id" `
                    -var "client_secret=$client_secret" `
                    -var "tenant_id=$tenant_id" `
                    -var "object_id=$object_id" `
                    -var "subscription_id=$subscription_id" `
                    -var "admin_password=$admin_password" `
                    -var "jb_admin_password=$jb_admin_password" `
                    -var "location=$location" | Write-Log -UseTee -Path $LogFilePath
                Pop-Location
            }
            Set-Location "$script:TFDirectory"
        }
    }
}

#----- Terraform output command
function Output-Configuration {
    param (
        [Parameter(Mandatory = $true)][string]$mode,
        [Parameter(Mandatory = $true)][string]$environment,
        [Parameter(Mandatory = $true)][string]$DeploymentMethod,
        $configuration,
        $secrets
    )

    # $configuration = Get-Configuration -ConfigurationPath $ConfigurationPath
    # Create-StorageAccount -prefix $prefix -mode $mode -environment $environment -location $location -client_id $client_id -client_secret $client_secret -tenant_id $tenant_id -subscription_id $subscription_id -configuration $configuration -secrets $secrets -DeploymentMethod $DeploymentMethod

    Set-Location "$script:TFDirectory/$mode/$environment"
    
    $directory = $((Get-ChildItem -Directory .).Name) -match $DeploymentMethod
    Push-Location ./$directory

    "Executing terraform Output - Getting access_key of new storage account" | Write-Log -UseHost -Path $LogFilePath

    terraform output -json > output.json

    if (Get-AzStorageAccount -ResourceGroupName $resource_group_name -Name $storage_account_name) {
        $oStorageKeys = Get-AzStorageAccountKey -ResourceGroupName $resource_group_name -Name $storage_account_name -ErrorAction SilentlyContinue
    }
    $access_key = $oStorageKeys.GetValue(0).value
    
    # $secrets
    # $laccesskey = "$($secrets.keys.access_key)"
    $dir = Get-Location 
    Set-Location "$script:TFDirectory/files"
    
    "Executing .\JsonToYaml.ps1 script..." | Write-Log -UseHost -Path $LogFilePath
    if (Test-Path -Path "$dir\output.json") {
        .\JsonToYaml.ps1 -jsonpath "$dir\output.json" | Write-Log -UseHost -Path $LogFilePath
    }
    else {
        exit 1
    }

    "Executing .\azcopy.ps1 script | Copying sshkeys and environment-configuration file to new storage account $Storage_account_name..." | Write-Log -UseHost -Path $LogFilePath
    .\azcopy.ps1 -SourceStorageAccountSSHkeysURL $source_stg_account_ssh_env -SourceStorageAccountKey $source_stg_key_ssh_env -DestinationStorageAccountName $Storage_account_name -DestinationStoraAccountKey $access_key | Write-Log -UseTee -Path $LogFilePath
    
    "Executing .\CopyVaultAddIdentity.ps1 script..." | Write-Log -UseHost -Path $LogFilePath
    .\VaultCopyAddIdentity.ps1 -ResourceGroupName $resource_group_name -RGKeyvaultName $rg_key_vault_name -MasterKeyvaultName $master_key_vault_name -LogFilePath $LogFilePath 
    
    "Removing Permission to ApplicationID in Key Vault" | Write-Log -UseHost -Path $LogFilePath
    $spobject_id = (Get-AzADServicePrincipal -ApplicationId "$client_id").Id
    Remove-AzKeyVaultAccessPolicy -VaultName $rg_key_vault_name -ResourceGroupName $resource_group_name -ObjectId $spobject_id

    if ($createtunnel) {
        "Executing .\Setup-ssh-Tunnel.ps1 script..." | Write-Log -UseHost -Path $LogFilePath
        .\Setup-ssh-Tunnel.ps1 -Prefix $prefix -SourceRGName $resource_group_name -SourceStorageAccName $vnet_storage_account_name -SubscriptionId $subscription_id -StorageAccountKey  $source_stg_key_ssh_env -StorageAccountURL $source_stg_account_ssh_env -LogFilePath $LogFilePath
    }
    
    Pop-Location
    Set-Location "$script:TFDirectory"
}


#-----------------------------------------------------------[Execution]------------------------------------------------------------


#----- Get Start Time
$startDTM = (Get-Date)

if ($TFCommand -eq 'init') {
    Check-Values -client_id $client_id -client_secret $client_secret -tenant_id $tenant_id -subscription_id $subscription_id -vnet_storage_account_name $vnet_storage_account_name -vnet_resource_group_name $vnet_resource_group_name -custom_image_name $custom_image_name -custom_image_resource_group_name $custom_image_resource_group_name -jasper_image_name $jasper_image_name -jasper_image_resource_group_name $jasper_image_resource_group_name -vertex_image_name $vertex_image_name -vertex_image_resource_group_name $vertex_image_resource_group_name -JasperImage $JasperImage -VertexImage $VertexImage -VnetTableName $VnetTableName -ErrorAction Stop
    Create-StorageAccount -prefix $prefix -mode $mode -environment $environment -location $location -client_id $client_id -client_secret $client_secret -tenant_id $tenant_id -subscription_id $subscription_id -configuration $configuration -secrets $secrets -DeploymentMethod $DeploymentMethod    
    Initiate-Configuration -mode $mode -environment $environment -configuration $configuration -DeploymentMethod $DeploymentMethod -secrets $secrets
}

elseif ($TFCommand -eq 'plan') {
    Plan-Configuration -mode $mode -environment $environment -configuration $configuration -DeploymentMethod $DeploymentMethod -vnet_storage_account_name $vnet_storage_account_name -vnet_resource_group_name $vnet_resource_group_name
}

elseif ($TFCommand -eq 'apply') {
    Apply-Configuration -mode $mode -environment $environment -configuration $configuration -DeploymentMethod $DeploymentMethod -vnet_storage_account_name $vnet_storage_account_name -vnet_resource_group_name $vnet_resource_group_name
}

elseif ($TFCommand -eq 'destroy') {
    Destroy-Configuration -mode $mode -DestroyMode $DestroyMode -environment $environment -DeploymentMethod $DeploymentMethod -configuration $configuration
}

elseif ($TFCommand -eq 'output') {
    Output-Configuration -mode $mode -environment $environment -DeploymentMethod $DeploymentMethod -secrets $secrets
}

elseif ($TFCommand -eq 'apply-all') {
    Check-Values -client_id $client_id -client_secret $client_secret -tenant_id $tenant_id -subscription_id $subscription_id -vnet_storage_account_name $vnet_storage_account_name -vnet_resource_group_name $vnet_resource_group_name -custom_image_name $custom_image_name -custom_image_resource_group_name $custom_image_resource_group_name -jasper_image_name $jasper_image_name -jasper_image_resource_group_name $jasper_image_resource_group_name -vertex_image_name $vertex_image_name -vertex_image_resource_group_name $vertex_image_resource_group_name -JasperImage $JasperImage -VertexImage $VertexImage -VnetTableName $VnetTableName -ErrorAction Stop
    Create-StorageAccount -prefix $prefix -mode $mode -environment $environment -location $location -client_id $client_id -client_secret $client_secret -tenant_id $tenant_id -subscription_id $subscription_id -configuration $configuration -secrets $secrets -DeploymentMethod $DeploymentMethod
    Initiate-Configuration -mode $mode -environment $environment -configuration $configuration -secrets $secrets -DeploymentMethod $DeploymentMethod
    Apply-Configuration -mode $mode -environment $environment -configuration $configuration -deploymentMethod $DeploymentMethod -vnet_storage_account_name $vnet_storage_account_name -vnet_resource_group_name $vnet_resource_group_name
    Output-Configuration -mode $mode -environment $environment -DeploymentMethod $DeploymentMethod -secrets $SecretsFilePath
}
 
#----- Get End Time
$endDTM = (Get-Date)

# Echo Time elapsed
"Total Elapsed Time: $(($endDTM-$startDTM).totalseconds) seconds" | Write-Log -UseHost -Path $LogFilePath

