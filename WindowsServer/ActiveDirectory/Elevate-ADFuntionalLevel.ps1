Import-Module Active Directory
$Domain = Get-ADDomain
Set-ADDomainMode -Identity $Domain -domainMode Windows2008R2Domain -confirm:$false
Get-ADForest
set-adforestmode –identity “netbiosname” windows2008R2Forest –confirm:$false