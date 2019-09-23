## Installing Active Directory ##
#Installing the First Domain Controller in Forest

install-windowsfeature AD-Domain-Services
Import-Module ADDSDeployment
Install-ADDSForest -CreateDnsDelegation:$false -DatabasePath “C:\Windows\NTDS” -DomainMode “Win2012R2” -DomainName “campohenriquez.lab” -DomainNetbiosName “CampoHenriquez” -ForestMode “Win2012R2” -InstallDns:$true -LogPath “C:\Windows\NTDS” -NoRebootOnCompletion:$false -SysvolPath “C:\Windows\SYSVOL” -Force:$true



##Prepare the OS for Exchange installation ## https://blogs.technet.microsoft.com/exchange/2018/07/26/deploy-exchange-server-2019-on-windows-server-core/
Sconfig.exe

Get-NetIPAddress
New-NetIPAddress -InterfaceIndex 6 -IPAddress 192.168.12.123 -PrefixLength 24 -DefaultGateway 192.168.12.100
Set-DNSClientServerAddress -InterfaceIndex 6 -ServerAddress "192.168.12.121"
cscript C:\Windows\System32\Scregedit.wsf /ar 0
Install-WindowsFeature Server-Media-Foundation, RSAT-ADDS

wget https://www.microsoft.com/en-us/download/details.aspx?id=57167
wget https://www.microsoft.com/en-in/download/details.aspx?id=40784
wget https://www.microsoft.com/en-us/download/details.aspx?id=56116

Mount-DiskImage c:\temp\ExchangeServer2019-x64.iso
C:\temp\NDP471-KB4033342-x86-x64-AllOS-ENU.exe /q /log c:\temp\ndp.log
Start Notepad c:\temp\ndp.log
Add-Computer -DomainName campohenriquez.lab -NewName E19Core1 -DomainCredential campohenriquez\administrator
Restart-Computer -Force

.\Setup.exe /m:install /roles:m /IAcceptExchangeServerLicenseTerms /InstallWindowsComponents
start notepad c:\ExchangeSetupLogs\ExchangeSetup.log

