##Elevar el nivel funcional de un dominio desde powershell

Import-Module Active Directory
Get-ADDomain
Set-ADDomainMode -Identity “Dominio” -domainMode Windows2008R2Domain -confirm:$false
Get-ADForest
set-adforestmode –identity “netbiosname” windows2008R2Forest –confirm:$false
