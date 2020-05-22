$DaysAgo=(Get-Date).AddDays(-90) 
Get-ADComputer -Filter {(PwdLastSet -lt $DaysAgo) -or (LastLogonTimeSTamp -lt $DaysAgo)} -Properties PwdLastSet,LastLogonTimeStamp,Description,OperatingSystem |
Select-Object -Property DistinguishedName,Name,Enabled,Description,OperatingSystem, `
@{Name="PwdLastSet";Expression={[datetime]::FromFileTime($_.PwdLastSet)}}, `
@{Name="LastLogonTimeStamp";Expression={[datetime]::FromFileTime($_.LastLogonTimeStamp)}} | 
Export-Csv -Path possible_stale_computers.csv -NoTypeInformation 