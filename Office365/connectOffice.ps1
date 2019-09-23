Import-Module ActiveDirectory


Import-Module ADSync


ImportSystemModules


add-pssnapin Microsoft.Exchange.Management.PowerShell.E2010


Import-Module MSOnline



　


(Get-ADDomainController -Filter *).Name | Foreach-Object {repadmin /syncall $_ (Get-ADDomain).DistinguishedName /e /A | Out-Null}; Start-Sleep 10; Get-ADReplicationPartnerMetadata -Target "$env:userdnsdomain" -Scope Domain | Select-Object Server, LastReplicationSuccess


Start-ADSyncSyncCycle -PolicyType Delta


$CredO365 = Get-Credential


Connect-MsolService -Credential $credO365


$SesionO365 = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell -Credential $CredO365 -Authentication Basic -AllowRedirection


Import-PSSession $SesionO365 -AllowClobber 
