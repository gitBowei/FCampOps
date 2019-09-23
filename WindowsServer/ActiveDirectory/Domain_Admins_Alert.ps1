$ref=(Get-ADGroupMember -Identity "Domain Admins").Name
Start-Sleep -Seconds 86398
$diff=(Get-ADGroupMember -Identity "Domain Admins").Name
$date=Get-Date -Format F
$result=(Compare-Object -ReferenceObject $ref -DifferenceObject $diff | Where-Object {$_.SideIndicator -eq "=>"} | Select-Object -ExpandProperty InputObject) -join ", "
If ($result)
{Send-MailMessage -From SecurityAlert@domain.com -To p.gruenauer@domain.com -SmtpServer EX01 -Subject "Domain Admin Membership Changes | $result was added to the Group" -Body "This alert was generated at $date" -Priority High}