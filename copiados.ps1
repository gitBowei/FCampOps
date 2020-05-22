Get-Date
write-host -ForegroundColor red "-----------------------replicas"
write-host -ForegroundColor green bogsmb110p12104
Get-MailboxDatabaseCopyStatus -Server bogsmb110p12104 | group-Object status | ft
write-host -ForegroundColor green bogsmb110p14101
Get-MailboxDatabaseCopyStatus -Server bogsmb110p14101 | group-Object status | ft
write-host -ForegroundColor red "**********************************************"
write-host -ForegroundColor green bogsmb110p12103
Get-MailboxDatabaseCopyStatus -Server bogsmb110p12103 | group-Object status | ft
write-host -ForegroundColor green bogsmb110p14100
Get-MailboxDatabaseCopyStatus -Server bogsmb110p14100 | group-Object status | ft
#write-host -ForegroundColor green bogsmb110p12101
#Get-MailboxDatabaseCopyStatus -Server bogsmb110p12101 | group-Object status | ft
write-host -ForegroundColor red "-----------------------indices"
write-host -ForegroundColor green bogsmb110p12104
Get-MailboxDatabaseCopyStatus -Server bogsmb110p12104 | group-Object ContentIndexstate | ft
write-host -ForegroundColor green bogsmb110p14101
Get-MailboxDatabaseCopyStatus -Server bogsmb110p14101 | group-Object ContentIndexstate | ft
write-host -ForegroundColor red "**********************************************"
write-host -ForegroundColor green bogsmb110p12103
Get-MailboxDatabaseCopyStatus -Server bogsmb110p12103 | group-Object ContentIndexstate | ft
write-host -ForegroundColor green bogsmb110p14100
Get-MailboxDatabaseCopyStatus -Server bogsmb110p14100 | group-Object ContentIndexstate | ft
#write-host -ForegroundColor green bogsmb110p12101
#Get-MailboxDatabaseCopyStatus -Server bogsmb110p12101 | group-Object ContentIndexstate | ft
