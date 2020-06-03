#import SQL Server module
#Start-Sleep 600
Import-Module SQLPS -DisableNameChecking

$loginName = "developer"
$dbUserName = "developer"
$password = convertto-securestring -asplaintext "MetraTech1" -force
$databasenames = "master"
$roleName = "db_owner"

$server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList "$env:COMPUTERNAME"
$server.Settings.LoginMode = [Microsoft.SqlServer.Management.SMO.ServerLoginMode]::Mixed
$server.Alter()
Restart-Service -Name MSSQLSERVER -Force


# drop login if it exists
if ($server.Logins.Contains($loginName))  
{   
    Write-Host("Login User Already Exist $loginName.")
}

$login = New-Object `
-TypeName Microsoft.SqlServer.Management.Smo.Login `
-ArgumentList $server, $loginName
$login.LoginType = [Microsoft.SqlServer.Management.Smo.LoginType]::sqllogin
$login.PasswordExpirationEnabled = $false
$login.create
$login.Create($password)
$login.AddToRole('sysadmin')
Write-Host("Login $loginName created successfully.")

foreach($databaseToMap in $databasenames)  
{
    $database = $server.Databases[$databaseToMap]
    if ($database.Users[$dbUserName])
    {
        Write-Host("Dropping user $dbUserName on $database.")
        $database.Users[$dbUserName].Drop()
    }

    $dbUser = New-Object `
    -TypeName Microsoft.SqlServer.Management.Smo.User `
    -ArgumentList $database, $dbUserName
    $dbUser.Login = $loginName
    $dbUser.Create()
    Write-Host("User $dbUser created successfully.")

    #assign database role for a new user
    $dbrole = $database.Roles[$roleName]
    $dbrole.AddMember($dbUserName)
    $dbrole.Alter()
    Write-Host("User $dbUser successfully added to $roleName role.")
}
###Firewall enable for SQL
Write-Host("Enable Firewall")
netsh advfirewall firewall add rule name="SQL port 1433" dir=in action=allow protocol=TCP localport=1433
###creating Data Folders
Write-Host("Creating Data Folder \datafiles\01 & 02")
if(!(test-Path -Path "$env:SystemDrive\datafiles"))
{
New-Item -Name "datafiles" -Path "$env:SystemDrive\" -ItemType "directory" -force
}
if(Test-Path -Path "$env:SystemDrive\datafiles")
{
New-Item -Name "01" -Path "$env:SystemDrive\datafiles\" -ItemType "directory" 
}
if(Test-Path -Path "$env:SystemDrive\datafiles")
{
New-Item -Name "02" -Path "$env:SystemDrive\datafiles\" -ItemType "directory" 
}
