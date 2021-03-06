#Load Exchange PS Snapin
If (@(Get-PSSnapin -Registered | Where-Object {$_.Name -eq "Microsoft.Exchange.Management.PowerShell.E2010"} ).count -eq 1) {
    If (@(Get-PSSnapin | Where-Object {$_.Name -eq "Microsoft.Exchange.Management.PowerShell.E2010"} ).count -eq 0) {
         Write-Host "Loading Exchange Snapin Please Wait...."; Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010}
         } 

#Load Exchange PS Snapin
If (@(Get-PSSnapin -Registered | Where-Object {$_.Name -eq "Microsoft.Exchange.Management.PowerShell.Admin"} ).count -eq 1){ 
    If (@(Get-PSSnapin | Where-Object {$_.Name -eq "Microsoft.Exchange.Management.PowerShell.Admin"} ).count -eq 0) {
        Write-Host "Loading Exchange Snapin Please Wait...."; Add-PSSnapin Microsoft.Exchange.Management.PowerShell.Admin}
        }

Write-Host "`n`n`t`t Export Mailbox To PST `n`n"

#Variables
$path = "\\file\share"
$admin = [Environment]::UserName

$list=Read-Host "Do you want to read from a file? (Y/N)"
IF ($list -eq "N") { 
	$user = Read-Host "Enter A User Name"
       Add-MailboxPermission -Identity $user -User $admin -AccessRights  FullAccess
	   Export-Mailbox $user -PSTFolderPath $path\$user.pst -Confirm:$false
       
}
IF ($list -eq "Y") {
    $file = Read-Host "Enter File Path/Name"
	$users = Get-Content $file
	Foreach ($user in $users) {
       #Add-MailboxPermission -Identity $user -User $admin -AccessRights  FullAccess
	   Export-Mailbox $user -PSTFolderPath $path\$user.pst -Confirm:$false
	}
}