#Consultar la Queue, y crea los mailboxdatabasecopy

$mailboxserver15= get-mailboxserver |where-object {$_.admindisplayversion -match "15.0"}

while($i -lt 9999) {start-sleep -seconds 10; write-host -foregroundcolor yellow ---------------------------; foreach ($server in $mailboxserver15) {Write-host -ForegroundColor green $server.name; get-queue -Server $server.name |Where-Object {$_.status ne "ready"} |sort-object messagecount}}
(get-MoveRequest -moveStatus failed).count
(get-MoveRequest -moveStatus inprogress).count
Get-MailboxDatabase -Status | Where-Object {$_.mountedonserver -match "BOGSMB110P14100"} | Add-MailboxDatabaseCopy -MailboxServer BOGSMB110P12103 -Confirm:$false
while($i -lt 9999) {start-sleep -seconds 10; write-host -foregroundcolor yellow ---------------------------; {Write-host -ForegroundColor green; get-process -name setup}}