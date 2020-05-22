 $d = [DateTime]::Today.AddDays(-90)
 $default_log = $env:userprofile + '\Documents\stale_computer_report.csv'
 Foreach($domain in (get-adforest).domains){
 Get-ADComputer  -Filter {(isCriticalSystemObject -eq $False)} -Properties UserAccountControl,`
 PwdLastSet,WhenChanged,SamAccountName,LastLogonTimeStamp,Enabled,admincount,IPv4Address,`
 operatingsystem,operatingsystemversion,serviceprincipalname  -server $domain |
 select @{name='Domain';expression={$domain}}, `
 SamAccountName,operatingsystem,operatingsystemversion,UserAccountControl,Enabled, `
 admincount,IPv4Address, `
 @{Name="Stale";Expression={if((($_.pwdLastSet -lt $d.ToFileTimeUTC()) -and ($_.pwdLastSet -ne 0)`
  -and ($_.LastLogonTimeStamp -lt $d.ToFileTimeUTC()) -and ($_.LastLogonTimeStamp -ne 0)`
  -and ($_.admincount -ne 1) -and ($_.IPv4Address -eq $null)) -and `
  (!($_.serviceprincipalname -like "*MSClusterVirtualServer*"))){$True}else{$False}}}, `
  @{Name="ParentOU";Expression={$_.distinguishedname.Substring($_.samaccountname.Length + 3)}} `
 | export-csv $default_log -append -NoTypeInformation}