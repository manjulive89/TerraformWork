<#
    .SYNOPSIS
        JsonToYaml

    .DESCRIPTION
        Conevert output.json to environment-configuration.yaml with the required keys and values (vm names, ips etc.)

    .EXAMPLE
        PS C:\> .\JsonToYaml.ps1 -ResourceGroupName 'KeyvaultRG' -RGKeyvaultName 'KeyvaultName' -MasterKeyvaultName 'MasterVault'

    .NOTES
        Pre-req for this script is to have output.json from Terraform
#>

param (
    [parameter(Mandatory = $true)][string]$jsonpath
)

if (Get-Module -ListAvailable -Name powershell-yaml) {
    Write-Host "powershell-yaml Module exists"
} 
else {
    Write-Host "powershell-yaml Module does not exist"
    Install-Module powershell-yaml -Scope CurrentUser -Force
}
if (Get-Module -Name powershell-yaml) {
    Write-Host "Module is already imported (i.e. its cmdlets are available to be used.)"
}
else {
    Write-Host "Module is NOT imported (must be installed before importing)."
    Import-Module powershell-yaml -Global
}

$object = Get-Content $jsonpath -raw -ErrorAction Stop | ConvertFrom-Json

"{`n" > .\output1.json
"`"servers`":" >> .\output1.json
"{`n" >> .\output1.json

$keynames = $object | Get-Member | ? { $_.MemberType -eq "NoteProperty" } | % { $_.Name }

foreach ($keyname in $keynames) {

    if ($object.API.value.vmname -match 'rapi') {
        for ($i = 0; $i -lt $($object.API.value.vmname).count; $i++) {
            $testobject += @"
        "$($object.API.value.vmname[$i])":{
            "profile":"ECB-API-Primary",
            "ip": "$($object.API.value.ip[$i])"
        },
"@
        }
    }

    if ($object.PRP.value.vmname -match 'ratea') {
        for ($i = 0; $i -lt $($object.PRP.value.vmname).count; $i++) {
            $testobject += @"
        "$($object.PRP.value.vmname[$i])":{
            "profile":"PrimaryPipeline",
            "ip":"$($object.PRP.value.ip[$i])"
        },
"@
        }
    }

    if ($object.SEP.value.vmname -match 'rateb') {
        for ($i = 0; $i -lt $($object.SEP.value.vmname).count; $i++) {
            $testobject += @"
        "$($object.SEP.value.vmname[$i])":{
            "profile":"SecondaryPipeline",
            "ip":"$($object.SEP.value.ip[$i])"
    },
"@
        }
    }
    
    if ($object.WS.value.vmname -match 'ecb') {
        for ($i = 0; $i -lt $($object.WS.value.vmname).count; $i++) {
            $testobject += @"
        "$($object.WS.value.vmname[$i])":{
            "profile":"PrivilegedVM",
            "ip":"$($object.WS.value.ip[$i])"
    },
"@
        }
    }

    if ($object.IS.value.vmname -match 'sapi') {
        for ($i = 0; $i -lt $($object.IS.value.vmname).count; $i++) {
            $testobject += @"
       "$($object.IS.value.vmname[$i])":{
            "profile":"IntegrationVM",
            "ip":"$($object.IS.value.ip[$i])"
    },
"@
        }
    }

    if ($object.MVW.value.vmname -match 'mview') {
        for ($i = 0; $i -lt $($object.MVW.value.vmname).count; $i++) {
            $testobject += @"
        "$($object.MVW.value.vmname[$i])":{
            "profile":"MetraView",
            "ip":"$($object.MVW.value.ip[$i])"
    },
"@
        }
    }

    if ($object.Jasper.value.vmname -match 'reprt') {
        for ($i = 0; $i -lt $($object.Jasper.value.vmname).count; $i++) {
            $testobject += @"
        "$($object.Jasper.value.vmname[$i])":{
            "profile":"JasperVM",
            "ip":"$($object.Jasper.value.ip[$i])"
    },
"@
        }
    }

    if ($object.Vertex.value.vmname -match 'vtx') {
        for ($i = 0; $i -lt $($object.Vertex.value.vmname).count; $i++) {
            $testobject += @"
        "$($object.Vertex.value.vmname[$i])":{
            "profile":"VertexQ",
            "ip":"$($object.Vertex.value.ip[$i])"
    },
"@
        }
    }

    if ($object.ECB.value.vmname -match 'aio') {
        for ($i = 0; $i -lt $($object.ECB.value.vmname).count; $i++) {
            $testobject += @"
        "$($object.ECB.value.vmname[$i])":{
            "profile":"ECB-All-In-One",
            "ip":"$($object.ECB.value.ip[$i])"
    },
"@
        }
    }

}

$testobject >> .\output1.json
"`n}" >> .\output1.json
"`n}" >> .\output1.json

$jsonobj = Get-Content .\output1.json -raw

$output = $jsonobj -replace '(?ms)(.+)(},)(.+)', '$1}$3' 

$output > output1.json
$oReadObj = Get-content -raw .\output1.json | ConvertFrom-Json

ForEach ($item in $oReadObj) {
    $filename = "environment-configuration.yaml"
    $item | ConvertTo-YAML > $filename
    Write-Host ("Json To Yaml Converted:$filename")
}
