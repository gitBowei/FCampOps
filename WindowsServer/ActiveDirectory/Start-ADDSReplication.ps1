function Replicate-AllDomainController {
(Get-ADDomainController -Filter *).Name | Foreach-Object {repadmin /syncall $_(Get-ADDomain).DistinguishedName /APed | Out-Null}; Start-Sleep 10; Get-ADReplicationPartnerMetadata -Target "$env:userdnsdomain" -Scope Domain | Select-Object Server, LastReplicationSuccess
}
 
Replicate-AllDomainController