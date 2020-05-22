Get-ExchangeServer | select name,serverrole,edition,site,*admin*,fqdn | clip
Get-ClientAccessServer | FL *IDEN*,*URI* | clip
get-exchangecertificate | fl | clip
Get-MailboxStatistics –database "Mailbox Database 1535645697 USERS3GB" | Sort-Object LastLogonTime -Descending | Export-CSV E:\Usuarios para mover\Usuarios.csv
Get-IntraOrganizationConfiguration
Get-IntraOrganizationConnector |fl
Test-OAuthConnectivity -Service EWS -TargetUri <External Hostname Authority of your Exchange On-Premises> -Mailbox <Exchange Online Mailbox> -Verbose |fl
Get-Mailbox <Exchange Online Mailbox> |fl
Get-MailUser <On-Premises Mailbox> |fl
Get-OrganizationRelationShip |fl

Get-MailboxStatistics -database "Mailbox Database 1535645697 USERS3GB" | where-object {$_.LastLogonTime –like "08/*/2013*"} | New-MoveRequest -TargetDatabase Usuarios -BatchName "Mailbox Database 1535645697 USERS3GBtoUsuarios" -WhatIf

Get-MailboxDatabase | Get-MailboxStatistics | Sort-Object LastLogonTime -Descending > "C:\Usuarios para eliminar\users.csv"

#New-MoveRequest 
#---------------------------------------------------------------------------------------------------

cd "E:\Usuarios para mover"
Import-Csv ".\Usuarios para mover MD-USERS3GB.csv" | % {New-MoveRequest -Identity $_.UserID -TargetDatabase $_.TargetDB}

#---------------------------------------------------------------------------------------------------

#Directivos_5GB

Get-MailboxStatistics -database "Justicia_VIP10GB" | Sort-Object LastLogonTime -Descending | Export-CSV "E:\Usuarios para mover\Justicia_VIP10GB.csv"

Get-MailboxStatistics -database "Justicia_VIP10GB" | Sort-Object LastLogonTime -Descending | Export-CSV "E:\Usuarios para mover\Usuarios Justicia VIP.csv"

Get-MailboxStatistics –database "Mailbox Database 1535645697 USERS3GB" | Sort-Object LastLogonTime -Descending | Export-CSV "E:\Usuarios para mover\Usuarios.csv"

Get-MailboxStatistics -database "Directivos_5GB-7" | Sort-Object LastLogonTime -Descending | Export-CSV "E:\Usuarios para mover\Directivos_5GB.csv"

#--------------------------------------------------------------------------------------------

Get-MailboxStatistics -Database "Mailbox Database 1535645697 USERS3GB" | Where { $_.DisconnectReason -eq "SoftDeleted" } | Format-List LegacyDN, DisplayName, MailboxGUID, DisconnectReason

Remove-StoreMailbox -Database "Directivos_5GB" -Identity 79bb1563-6d2d-4c35-9934-bb78c9719c19 -MailboxState Softdeleted

Get-MailboxStatistics -Database "Justicia_VIP10GB" | where {$_.DisconnectReason -eq "SoftDeleted"} | foreach {Remove-StoreMailbox -Database $_.database -Identity $_.mailboxguid -MailboxState SoftDeleted}

Get-MailboxStatistics -Database "Justicia_VIP10GB" | Where { $_.DisconnectReason -eq "SoftDeleted" } | Format-List LegacyDN, DisplayName, MailboxGUID, DisconnectReason

Remove-StoreMailbox Database <MAILBOXDATABASE> Identity <MAILBOXGUID> MailboxState Softdeleted

#---------------------------------------------------------------------------------------------------

Get-MailboxStatistics -database "Justicia_VIP10GB" | Sort-Object LastLogonTime -Descending | Export-CSV "E:\Usuarios para mover\Justicia_VIP10GB.csv"

Get-MailboxStatistics -database "Mailbox Database 1535645697 USERS3GB" | Sort-Object LastLogonTime -Descending | Export-CSV "E:\Usuarios para mover\Mailbox Database 1535645697 USERS3GB.csv"

Get-MailboxStatistics -database "Mailbox Database 1535645697 USERS3GB" | Sort-Object LastLogonTime -Descending | Export-CSV "E:\Usuarios para mover\Mailbox Database 1535645697 USERS3GB.csv"

#----------------------------------------------------------------------------------------------------

Get-Mailbox -Arbitration -Database Justicia_VIP10GB | New-MoveRequest -TargetDatabase Usuarios

