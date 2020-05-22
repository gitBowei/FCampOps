﻿Function Connect-ExOnline{
$cred= get-credential -Credential Licencias@BolsaMercantil.com.co

Write-Output "Getting the Exchange Online Cmdlets"
$session= New-PSSession -ConnectionUri https://ps.outlook.com/powershell -ConfigurationName Microsoft.Exchange -Credential $cred -Authentication Basic -AllowRedirection
Import-PSSession $session
}