Write-Host "Enable HTTP in WinRM.."
winrm quickconfig -force
winrm set winrm/config/client '@{AllowUnencrypted="true"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/client '@{TrustedHosts="*"}'
Write-Host "Enabling Basic Authentication.."
winrm set winrm/config/service/auth '@{Basic="true"}'
New-WSManInstance winrm/config/Listener -SelectorSet @{Address="*";Transport="Http"}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name LocalAccountTokenFilterPolicy -Value 1
netsh advfirewall firewall set rule group="remote administration" new enable=yes
netsh firewall add portopening TCP 5985 "Port 5985"
sc.exe config winrm start=auto
net stop winrm
net start winrm
Write-Host ("View Hidden files and enable file extensions")
$key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
Set-ItemProperty $key Hidden 1
Set-ItemProperty $key HideFileExt 0
# Set NetworkCategory to Private if it is Public
Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private