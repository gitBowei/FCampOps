##CMD Switch 
#PowerShell Cmdlet 
#Module Version

#DCPROMO 
Install-ADDSForest
Install-ADDSDomain
Install-ADDSDomainController
Uninstall-ADDSDomainController
#ADDSDeployment 2012

#CSVDE 
Get-ADObject | Export-CSV 
#ActiveDirectory 2008 R2

#CSVDE i 
Import-CSV | New-ADObject 
#ActiveDirectory 2008 R2

#DSGET computer 
Get-ADComputer 
#ActiveDirectory 2008 R2

#DSGET contact 
Get-ADObject -LDAPFilter '(objectClass=contact)' 
#ActiveDirectory 2008 R2

#DSGET subnet 
Get-ADReplicationSubnet 
#ActiveDirectory 2012

#DSGET group 
Get-ADGroup 
#ActiveDirectory 2008 R2

#DSGET ou 
Get-ADOrganizationalUnit 
#ActiveDirectory 2008 R2

#DSGET site 
Get-ADReplicationSite 
#ActiveDirectory 2012

#DSGET server 
Get-ADDomainController 
#ActiveDirectory 2008 R2

#DSGET user 
Get-ADUser 
#ActiveDirectory 2008 R2

#DSGET quota 
Get-ADObject -SearchBase (Get-ADDomain).QuotasContainer -Filter * 
#ActiveDirectory 2008 R2

#DSGET partition 
Get-ADObject -SearchBase (Get-ADForest).PartitionsContainer -LDAPFilter '(objectClass=crossRef)' 
#ActiveDirectory 2008 R2

#DSQUERY computer 
Get-ADComputer
Search-ADAccount
#ActiveDirectory 2008 R2

#DSQUERY contact 
Get-ADObject -LDAPFilter '(objectClass=contact)' 
#ActiveDirectory 2008 R2

#DSQUERY subnet 
Get-ADReplicationSubnet 
#ActiveDirectory 2012

#DSQUERY group 
Get-ADGroup 
#ActiveDirectory 2008 R2

#DSQUERY ou 
Get-ADOrganizationalUnit 
#ActiveDirectory 2008 R2

#DSQUERY site 
Get-ADReplicationSite 
#ActiveDirectory 2012

#DSQUERY server 
Get-ADDomainController 
#ActiveDirectory 2008 R2

#DSQUERY user 
Get-ADUser
Search-ADAccount
#ActiveDirectory 2008 R2

#DSQUERY quota 
Get-ADObject -SearchBase (Get-ADDomain).QuotasContainer -Filter * 
#ActiveDirectory 2008 R2

#DSQUERY partition 
Get-ADObject -SearchBase (Get-ADForest).PartitionsContainer -LDAPFilter '(objectClass=crossRef)' 
#ActiveDirectory 2008 R2

#DSQUERY * 
Get-ADObject 
#ActiveDirectory 2008 R2

#DSADD computer 
New-ADComputer 
#ActiveDirectory 2008 R2

#DSADD contact 
New-ADObject -Type contact 
#ActiveDirectory 2008 R2

#DSADD group 
New-ADGroup 
#ActiveDirectory 2008 R2

#DSADD ou 
New-ADOrganizationalUnit 
#ActiveDirectory 2008 R2

#DSADD user 
New-ADUser 
#ActiveDirectory 2008 R2

#DSADD quota
#DSMOVE 
Move-ADObject
Rename-ADObject
#ActiveDirectory 2008 R2

#DSMOD computer 
Set-ADComputer 
#ActiveDirectory 2008 R2

#DSMOD contact 
Set-ADObject 
#ActiveDirectory 2008 R2

#DSMOD group 
Set-ADGroup 
#ActiveDirectory 2008 R2

#DSMOD ou 
Set-ADOrganizationalUnit 
#ActiveDirectory 2008 R2

#DSMOD server 
Set-ADObject 
#ActiveDirectory 2008 R2

#DSMOD user 
Set-ADUser 
#ActiveDirectory 2008 R2

#DSMOD quota 
Set-ADObject 
#ActiveDirectory 2008 R2

#DSMOD partition 
Set-ADObject 
#ActiveDirectory 2008 R2

#DSRM 
Remove-ADComputer
Remove-ADGroup
Remove-ADGroupMember
Remove-ADUser
Remove-ADOrganizationalUnit
Remove-ADObject
#ActiveDirectory 2008 R2

#DSACLS 
Get-ACL
Set-ACL
#Microsoft.PowerShell.Security 2008 R2

#REPADMIN /FailCache 
Get-ADReplicationFailure 
#ActiveDirectory 2012

#REPADMIN /Queue 
Get-ADReplicationQueueOperation 
#ActiveDirectory 2012

#REPADMIN /ReplSingleObj 
Sync-ADObject 
#ActiveDirectory 2012

#REPADMIN /ShowConn 
Get-ADReplicationConnection 
#ActiveDirectory 2012

#REPADMIN /ShowObjMeta 
Get-ADReplicationAttributeMetadata 
#ActiveDirectory 2012

#REPADMIN /ReplSummary 
Get-ADReplicationPartnerMetadata 
#ActiveDirectory 2012

#REPADMIN /ShowUTDVec 
Get-ADReplicationUpToDatenessVectorTable 
#ActiveDirectory 2012

#REPADMIN /SiteOptions 
Set-ADReplicationSite 
#ActiveDirectory 2012

#REPADMIN /ShowAttr 
Get-ADObject 
#ActiveDirectory 2008 R2

#REPADMIN /SetAttr 
Set-ADObject 
#ActiveDirectory 2008 R2

#REPADMIN /PRP 
Get-ADDomainControllerPasswordReplicationPolicy
Add-ADDomainControllerPasswordReplicationPolicy
Remove-ADDomainControllerPasswordReplicationPolicy
Get-ADAccountResultantPasswordReplicationPolicy
Get-ADDomainControllerPasswordReplicationPolicyUsage
#ActiveDirectory 2008 R2

#NLTEST SC_RESET 
Test-ComputerSecureChannel -Repair 
#Microsoft.PowerShell.Management 2012

#NLTEST SC_VERIFY 
Test-ComputerSecureChannel 
#Microsoft.PowerShell.Management 2012

#NLTEST SC_CHANGE_PWD 
Reset-ComputerMachinePassword 
#Microsoft.PowerShell.Management 2012

#NLTEST DCLIST 
Get-ADDomainController 
#ActiveDirectory 2008 R2

#NLTEST DCNAME 
Get-ADDomain | Select-Object PDCEmulator 
#ActiveDirectory 2008 R2

#NLTEST DSGETDC 
Get-ADDomainController 
#ActiveDirectory 2008 R2

#NLTEST PARENTDOMAIN 
(Get-WMIObject Win32_ComputerSystem).Domain

#NLTEST DOMAIN_TRUSTS 
Get-ADTrust 
#ActiveDirectory 2012

#NLTEST SHUTDOWN 
Stop-Computer 
#Microsoft.PowerShell.Management 2008 R2

#NETDOM ADD 
Add-Computer 
#Microsoft.PowerShell.Management 2012

#NETDOM COMPUTERNAME 
Rename-Computer 
#Microsoft.PowerShell.Management 2012

#NETDOM JOIN 
Add-Computer 
#Microsoft.PowerShell.Management 2012

#NETDOM MOVE 
Add-Computer 
#Microsoft.PowerShell.Management 2012

#NETDOM RESETPWD 
Reset-ComputerMachinePassword 
#Microsoft.PowerShell.Management 2012

#NETDOM REMOVE 
Remove-Computer 
#Microsoft.PowerShell.Management 2012

#NETDOM RENAMECOMPUTER 
Rename-Computer 
#Microsoft.PowerShell.Management 2012

#NETDOM RESET 
Test-ComputerSecureChannel -Repair 
#Microsoft.PowerShell.Management 2012

#NETDOM VERIFY 
Test-ComputerSecureChannel 
#Microsoft.PowerShell.Management 2012

#NETDOM QUERY WORKSTATION 
Get-ADComputer -Filter "operatingSystem -notlike '*server*'" 
#ActiveDirectory 2008 R2

#NETDOM QUERY SERVER 
Get-ADComputer -Filter "operatingSystem -like '*server*'" 
#ActiveDirectory 2008 R2

#NETDOM QUERY DC 
Get-ADDomainController 
#ActiveDirectory 2008 R2

#NETDOM QUERY OU 
Get-ADOrganizationalUnit 
#ActiveDirectory 2008 R2

#NETDOM QUERY PDC 
Get-ADDomain | Select-Object PDCEmulator 
#ActiveDirectory 2008 R2

#NETDOM QUERY FSMO 
Get-ADForest | Select-Object DomainNamingMaster, SchemaMaster
Get-ADDomain | Select-Object InfrastructureMaster, PDCEmulator, RIDMaster
#ActiveDirectory 2008 R2

#NETDOM QUERY TRUST 
Get-ADTrust 
#ActiveDirectory 2012

#GPUPDATE 
Invoke-GPUpdate 
#GroupPolicy 2012

#GPRESULT 
Get-GPResultantSetOfPolicy 
#GroupPolicy 2008 R2

#PING 
Test-Connection 
#Microsoft.PowerShell.Management 2008 R2

#IPCONFIG 
Get-NetIPConfiguration 
#NetTCPIP 2012

#IPCONFIG /ALL 
Get-NetIPConfiguration -Detailed 
#NetTCPIP 2012

#IPCONFIG /FLUSHDNS 
Clear-DnsClientCache 
#DnsClient 2012

#IPCONFIG /DISPLAYDNS 
Get-DnsClientCashe 
#DnsClient 2012

#IPCONFIG /REGISTERDNS 
Register-DnsClient 
#DnsClient 2012

#NETSTAT a 
Get-NetTCPConnection 
#NetTCPIP 2012

#NETSTAT r 
Get-NetRoute 
#NetTCPIP 2012

#NSLOOKUP 
Resolve-DNSName 
#DNSClient 2012

#DNSCMD /Info 
Get-DnsServer 
#DNSServer 2012

#DNSCMD /Config 
Set-DnsServer 
#DNSServer 2012

#DNSCMD /EnumZones 
Get-DnsServerZone 
#DNSServer 2012

#DNSCMD /Statistics 
Get-DnsServerStatistics
Clear-DnsServerStatistics
#DNSServer 2012

#DNSCMD /ClearCache 
Clear-DnsServerCache 
#DNSServer 2012

#DNSCMD /StartScavenging 
Start-DnsServerScavenging 
#DNSServer 2012

#DNSCMD /ResetForwarders 
Get-DnsServerForwarder
Set-DnsServerForwarder
Add-DnsServerForwarder
Remove-DnsServerForwarder
Set-DnsServerConditionalForwarderZone
Add-DnsServerConditionalForwarderZone
#DNSServer 2012

#DNSCMD /ZoneInfo 
Get-DnsServerZone 
#DNSServer 2012

#DNSCMD /ZoneAdd 
Add-DnsServerPrimaryZone
Add-DnsServerSecondaryZone
Add-DnsServerStubZone
#DNSServer 2012

#DNSCMD /ZoneDelete 
Remove-DnsServerZone 
#DNSServer 2012

#DNSCMD /ZoneResetScavengeServers 
Get-DnsServerScavenging
Set-DnsServerScavenging
#DNSServer 2012

#DNSCMD /ZoneResetMasters 
Set-DnsServerSecondaryZone 
#DNSServer 2012

#DNSCMD /ZoneExport 
Export-DnsServerZone 
#DNSServer 2012

#DNSCMD /RecordAdd 
Add-DnsServerResourceRecord
Add-DnsServerResourceRecordA
Add-DnsServerResourceRecordAAAA
Add-DnsServerResourceRecordCName
Add-DnsServerResourceRecordDS
Add-DnsServerResourceRecordMX
Add-DnsServerResourceRecordPtr
#DNSServer 2012

#DNSCMD /RecordDelete 
Remove-DnsServerResourceRecord 
#DNSServer 2012

#DNSCMD /AgeAllRecords 
Set-DnsServerResourceRecordAging 
#DNSServer 2012

#DNSCMD /ZonePrint 
Get-DnsServerResourceRecord 
#DNSServer 2012

#DNSCMD /TrustAnchorAdd 
Add-DnsServerTrustAnchor 
#DNSServer 2012

#DNSCMD /TrustAnchorDelete 
Remove-DnsServerTrustAnchor 
#DNSServer 2012

#DNSCMD /EnumTrustAnchors 
Get-DnsServerTrustAnchor 
#DNSServer 2012
