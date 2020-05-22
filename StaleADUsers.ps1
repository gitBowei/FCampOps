Get-ADUser -Filter {(PwdLastSet -lt $DaysAgo) -or (LastLogonTimeSTamp -lt $DaysAgo)} -Properties PwdLastSet,LastLogonTimeStamp,Description |
Select-Object -Property DistinguishedName, SamAccountName, Enabled,Description, `
@{Name="PwdLastSet";Expression={[datetime]::FromFileTime($_.PwdLastSet)}}, `
@{Name="LastLogonTimeStamp";Expression={[datetime]::FromFileTime($_.LastLogonTimeStamp)}} | 
Export-Csv -Path possible_stale_users.csv -NoTypeInformation