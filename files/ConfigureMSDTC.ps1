#Configure MSDTC Settings
  if(!(Stop-Service MSDTC))
  {
  Write-host (" MSDTC is Installing")
  Install-Dtc
  Write-Host ("Setting registry values for MSDTC")
  Set-ItemProperty -Path 'HKLM:\Software\Microsoft\MSDTC\Security' -Name LuTransactions -Value 1
  Set-ItemProperty -Path 'HKLM:\Software\Microsoft\MSDTC\Security' -Name NetworkDtcAccess -Value 1
  Set-ItemProperty -Path 'HKLM:\Software\Microsoft\MSDTC\Security' -Name NetworkDtcAccessInbound -Value 1
  Set-ItemProperty -Path 'HKLM:\Software\Microsoft\MSDTC\Security' -Name NetworkDtcAccessOutbound -Value 1
  Set-ItemProperty -Path 'HKLM:\Software\Microsoft\MSDTC\Security' -Name NetworkDtcClients -Value 1
  Set-ItemProperty -Path 'HKLM:\Software\Microsoft\MSDTC\Security' -Name NetworkDtcAccessTransactions -Value 1
  Set-ItemProperty -Path 'HKLM:\Software\Microsoft\MSDTC\Security' -Name NetworkDtcAccessAdmin -Value 1
  Set-ItemProperty -Path 'HKLM:\Software\Microsoft\MSDTC\Security' -Name NetworkDtcAccessClients -Value 1
  Set-ItemProperty -Path 'HKLM:\Software\Microsoft\MSDTC' -Name AllowOnlySecureRpcCalls -Value 1
  Set-ItemProperty -Path 'HKLM:\Software\Microsoft\MSDTC' -Name FallbackToUnsecureRPCIfNecessary -Value 0
  Set-ItemProperty -Path 'HKLM:\Software\Microsoft\MSDTC' -Name TurnOffRpcSecurity -Value 0
  #AB
  Set-DtcNetworkSetting -AuthenticationLevel NoAuth -XATransactionsEnabled $true -Confirm:$false
  Set-Service MSDTC -StartupType Automatic
  Write-host("Restarting MSDTC Service")
  Restart-Service MSDTC -Force
  }
  
#configure transaction timeout
Write-Host("configure transaction timeout")
$comAdmin = New-Object -comobject COMAdmin.COMAdminCatalog
$lm = $comAdmin.GetCollection("LocalComputer")
$lm.Populate();
Write-Host "The collection is '$lm'"
foreach ($lc in $lm)
{
    Write-Host $lc
    $foo = $lc.Value("TransactionTimeout");
    Write-Host "Current timeout is $foo"
    $lc.Value("TransactionTimeout") = 600;
 }
 $lm.SaveChanges()
Get-NetFirewallRule | Where-object {$_.Displaygroup -eq "Distributed Transaction Coordinator"} | Enable-NetFirewallRule
