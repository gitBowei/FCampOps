#
$Session = New-PSSession -ConfigurationName Microsoft.Exchange `
-ConnectionUri http://tlex01/PowerShell/ `
-Authentication Kerberos `
Import-PSSession $Session
#
Get-Mailbox –ResultSize Unlimited | Out-File C:\report.txt
#
Get-Mailbox -OrganizationalUnit 'contoso.com/Sales Users/Phoenix'
#
Get-Mailbox -Database DB1 | Set-Mailbox -Office Headquarters
#
Get-Mailbox | Where-Object{$_.MaxSendSize -eq 10mb}
#
New-Mailbox -UserPrincipalName jsmith@contoso.com `
-FirstName John `
-LastName Smith `
-Alias jsmith `
-Database DB1 `
-Password $password
#
Get-Mailbox -ResultSize Unlimited | 
  Select-Object DisplayName,ServerName,Database | 
    Export-Csv c:\mbreport.csv -NoTypeInformation


#
    Set-Mailbox testuser –MaxSendSize 5mb –MaxReceiveSize 5mb
#
Enable-Mailbox testuser -Archive
#
Remove-Mailbox testuser -Confirm:$false
#
Set-Mailbox -id testuser –Office Sales
#
Get-User | 
  Where-Object{$_.title -eq "Exchange Admin"} | Foreach-Object{
      Add-RoleGroupMember -Identity "Organization Management" `
      -Member $_.name
  }
#
Get-User | 
  ?{$_.title -eq "Exchange Admin"} | %{
    Add-RoleGroupMember -Identity "Organization Management" `
    -Member $_.name
  }
#
Get-User | 
  where{$_.title -eq "Exchange Admin"} | foreach{
    Add-RoleGroupMember -Identity "Organization Management" `
    -Member $_.name
  }
#
$mailbox = Get-Mailbox testuser
$mailbox | Get-Member
$mailbox.MaxSendSize
$mailbox.MaxSendSize.Value
$mailbox.MaxSendSize.Value.ToMB()
#
$email = "testuser@contoso.com"
$email.length
$email.Split("@")
#
$name = "Bob"
"The user name is $name"
#
$mailbox = Get-Mailbox testuser
"The email address is $mailbox.PrimarySmtpAddress"
"The email address is $($mailbox.PrimarySmtpAddress)"
#
[string]$a = 32
#
Get-Mailbox testuser | Format-Table name,alias
Get-Mailbox testuser | fl * | Out-File c:\mb.txt
Get-MailboxDatabase | sort name | ft name
Get-MailboxDatabase | sort name -desc | ft name
#
$servers = "EX1","EX2","EX3"
$hashtable = @{}
$hashtable["server1"] = 1
$hashtable["server2"] = 2
$hashtable["server3"] = 3
$hashtable = @{server1 = 1; server2 = 2; server3 = 3}
$hashtable = @{
  server1 = 1
  server2 = 2
  server3 = 3
}
$servers[2]="EX4"
$servers += "EX5"
$servers.Count
$servers | ForEach-Object {"Server Name: $_"}
$servers -contains "EX1"
$hashtable
$hashtable.GetEnumerator() | sort value
#
$parameters = @{
  Title = "Manager"
  Department = "Sales"
  Office = "Headquarters"
}
Set-User testuser @parameters
#
$mailbox = Get-Mailbox testuser
$mailbox.EmailAddresses += "testuser@contoso.com"
Set-Mailbox testuser -EmailAddresses $mailbox.EmailAddresses
#
$mailbox.EmailAddresses -= "testuser@contoso.com"
Set-Mailbox testuser -EmailAddresses $mailbox.EmailAddresses
#
foreach($mailbox in Get-Mailbox) {$mailbox.Name}
Get-Mailbox | ForEach-Object {$_.Name}
Get-Mailbox | %{$_.Name}
#
Get-MailboxDatabase -Status | %{
  $DBName = $_.Name
  $whiteSpace = $_.AvailableNewMailboxSpace.ToMb()
  "The $DBName database has $whiteSpace MB of total white space"
}
#
param(
  $name,
  $maxsendsize,
  $maxreceivesize,
  $city,
  $state,
  $title,
  $department
)

Set-Mailbox -Identity $name `
-MaxSendSize $maxsendsize `
-MaxReceiveSize $maxreceivesize

Set-User -Identity $name `
-City $city `
-StateOrProvince $state `
-Title $title `
-Department $department

Add-DistributionGroupMember -Identity DL_Sales `
-Member $name
#
C:\Update-SalesMailbox.ps1 -name testuser `
-maxsendsize 25mb `
-maxreceivesize 25mb `
-city Phoenix `
-state AZ `
-title Manager `
-department Sales
#
foreach($i in Get-Mailbox -OrganizationalUnit contoso.com/sales) {
  c:\Update-SalesMailbox.ps1 -name $i.name `
  -maxsendsize 100mb `
  -maxreceivesize 100mb `
  -city Phoenix `
  -state AZ `
  -title 'Sales Rep' `
  -department Sales
}
#
$DB1 = Get-MailboxDatabase DB1 -Status
#
if($DB1.DatabaseSize -gt 5gb) {
  "The Database is larger than 5gb"
}
#
if($DB1.DatabaseSize -gt 5gb) {
  "The Database is larger than 5gb"
}
elseif($DB1.DatabaseSize -gt 10gb) {
  "The Database is larger than 10gb"
}
#
if($DB1.DatabaseSize -gt 5gb) {
  "The Database is larger than 5gb"
}
elseif($DB1.DatabaseSize -gt 10gb) {
  "The Database is larger than 10gb"
}
else {
  "The Database is not larger than 5gb or 10gb"
}
#
switch($DB1.DatabaseSize) {
  {$_ -gt 5gb}  {"Larger than 5gb"; break}
  {$_ -gt 10gb} {"Larger than 10gb"; break}
  {$_ -gt 15gb} {"Larger than 15gb"; break}
  {$_ -gt 20gb} {"Larger than 20gb"; break}
  Default       {"Smaller than 5gb"}
}
#
if((Get-MailboxDatabase DB1 -Status).DatabaseSize -gt 5gb) {
  "The database is larger than 5gb"
}
#
$number = 3

switch ($number) {
  1 {"One" ; break}
  2 {"Two" ; break}
  3 {"Three" ; break}
  4 {"Four" ; break}
  5 {"Five" ; break}
  Default {"No matches found"}
}
#
foreach ($mailbox in Get-Mailbox) {
  if($mailbox.office -eq "Sales") {
   Set-Mailbox $mailbox -ProhibitSendReceiveQuota 5gb `
   -UseDatabaseQuotaDefaults $false
  }
  elseif($mailbox.office -eq "Accounting") {
   Set-Mailbox $mailbox -ProhibitSendReceiveQuota 2gb `
   -UseDatabaseQuotaDefaults $false
  }
  else {
   Set-Mailbox $mailbox -UseDatabaseQuotaDefaults $true
  }
}
#
$mailboxes | 
  Select-Object Name,
    Database,
    @{name="Title";expression={(Get-User $_.Name).Title}},
    @{name="Dept";expression={(Get-User $_.Name).Department}}
#
$mailboxes | %{
  New-Object PSObject -Property @{
    Name = $_.Name
    Database = $_.Database
    Title = (Get-User $_.Name).Title
    Dept = (Get-User $_.Name).Department
  }
}
#
$mailboxes | %{
  $obj = New-Object PSObject
  $obj | Add-Member NoteProperty Name $_.Name
  $obj | Add-Member NoteProperty Database $_.Database
  $obj | Add-Member NoteProperty Title (Get-User $_.Name).Title
  $obj | Add-Member NoteProperty Dept (Get-User $_.Name).Department
  Write-Output $obj
}
#
$mailboxes | 
  Select-Object Name,
    Database,
    @{n="Title";e={(Get-User $_.Name).Title}},
    @{n="Dept";e={(Get-User $_.Name).Department}} | 
      Export-CSV –Path C:\report.csv -NoType
#
$mailboxes | 
  Select-Object Name,
    Database,
    @{n="Title";e={(Get-User $_.Name).Title}},
    @{n="Dept";e={(Get-User $_.Name).Department}}
#
$mailboxes | %{
  $obj = "" | Select-Object Name,Database,Title,Dept
  $obj.Name = $_.Name
  $obj.Database = $_.Database
  $obj.Title = (Get-User $_.Name).Title
  $obj.Dept = (Get-User $_.Name).Department
  Write-Output $obj
}
#
Get-Mailbox | %{
  New-Object PSObject -Property @{
    Name = $_.Name
    Database = $_.Database
    Title = (Get-User $_.Name).Title
    Dept = (Get-User $_.Name).Department
  }
}
#
function Get-MailboxList {
  param($name)
  Get-Mailbox $name | fl Name,Alias,ServerName
}
#
function Get-MailboxName {
  process {
    "Mailbox Name: $($_.Name)"
  }
}
#
$credential = Get-Credential
$session = New-PSSession -ConfigurationName Microsoft.Exchange `
-ConnectionUri http://mail.contoso.com/PowerShell/ `
-Credential $credential
Import-PSSession $session
#
$user = "contoso\administrator"
$pass = ConvertTo-SecureString -AsPlainText P@ssw0rd01 -Force
$credential = New-Object System.Management.Automation.PSCredential `
-ArgumentList $user,$pass
#
$user = Read-Host "Please enter your username"
$pass = Read-Host "Please enter your password" -AsSecureString
$credential = New-Object System.Management.Automation.PSCredential `
-ArgumentList $user,$pass
#
[byte[]]$data = Get-Content -Path "C:\certificates\ExportedCert.pfx" `
-Encoding Byte `
-ReadCount 0

$password = Get-Credential

Import-ExchangeCertificate –FileData $data –Password $password
#
Export-RecipientDataProperty -Identity dsmith -Picture | %{ 
  $_.FileData | Add-Content C:\pics\dsmith.jpg -Encoding Byte
}
#
$mailboxes = Get-Mailbox -Database DB1
$mailboxes | %{
  New-InboxRule -Name Attach `
  -Mailbox $_ `
  -HasAttachment $true `
  -MarkImportance High
}
#
foreach($i in Get-Mailbox –Database DB1) {
  New-InboxRule -Name Attach `
  -Mailbox $i `
  -HasAttachment $true `
  -MarkImportance High
}
#
Set-AdServerSettings -ViewEntireForest $true
#
Set-AdServerSettings -RecipientViewRoot corp.contoso.com
#
Set-AdServerSettings -ViewEntireForest $true `
-SetPreferredDomainControllers dc1.contoso.com `
-PreferredGlobalCatalog dc1.contoso.com
#
Set-AdServerSettings -ViewEntireForest $true `
-SetPreferredDomainControllers dc1.contoso.com `
-PreferredGlobalCatalog dc1.contoso.com
#
Get-Mailbox | Select-Object Name,Alias | 
  Export-CSV c:\report.csv –NoType
#
Get-Mailbox | Select-Object Name,Alias | 
  Export-CSV c:\report.csv –NoType
#
Get-Mailbox | 
  Select-Object Name,@{n="Email";e={$_.EmailAddresses -Join ";"}} | 
    Export-CSV c:\report.csv -NoType
#
Get-Mailbox | 
  select-Object Name,
    @{n="Email";
      e={($_.EmailAddresses | %{$_.SmtpAddress}) -Join ";"}
     } | Export-CSV c:\report.csv -NoType
#
Send-MailMessage -To user1@contoso.com `
-From administrator@contoso.com `
-Subject "Test E-mail" `
-Body "This is just a test" `
-SmtpServer ex01.contoso.com
#
Send-MailMessage -To support@contoso.com `
-From powershell@contoso.com `
-Subject "Mailbox Report for $((Get-Date).ToShortDateString())" `
-Body "Please review the attached mailbox report." `
-Attachments c:\report.csv `
-SmtpServer ex01.contoso.com
#
[string]$report = Get-MailboxDatabase | 
  Get-MailboxStatistics| ?{!$_.DisconnectDate} | 
    Sort-Object TotalItemSize -Desc | 
      Select-Object DisplayName,Database,TotalItemSize -First 10 | 
        ConvertTo-Html

Send-MailMessage -To support@contoso.com `
-From powershell@contoso.com `
-Subject "Mailbox Report for $((Get-Date).ToShortDateString())" `
-Body $report `
-BodyAsHtml `
-SmtpServer ex01.contoso.com
#Scripting 
Param($Path)
if(Test-Path $Path) {
  switch -wildcard ($env:computername) {
    "*-EX-*" {$role = "CA,MB" ; break}
    "*-MB-*"  {$role = "MB" ; break}
    "*-CA-*"  {$role = "CA" ; break}
  }
  $setup = Join-Path $Path "setup.exe"
  Invoke-Expression "$setup /mode:install /r:$role / `
IAcceptExchangeServerLicenseTerms /InstallWindowsComponents"
}
else {
  Write-Host "Invalid Media Path!"
}

#
$password = ConvertTo-SecureString -AsPlainText P@ssw0rd -Force

New-Mailbox -UserPrincipalName dave@contoso.com `
-Alias dave `
-Database DAGDB1 `
-Name DaveJones `
-OrganizationalUnit Sales `
-Password $password `
-FirstName Dave `
-LastName Jones `
-DisplayName 'Dave Jones'
#
Set-Mailbox -Identity dave `
-UseDatabaseQuotaDefaults $false `
-ProhibitSendReceiveQuota 5GB `
-IssueWarningQuota 4gb
#
Disable-Mailbox -Identity dave -Confirm:$false
#
New-Mailbox -UserPrincipalName dave@contoso.com `
-Alias dave `
-Database DAGDB1 `
-Name DaveJones `
-OrganizationalUnit Sales `
-Password (ConvertTo-SecureString -AsPlainText P@ssw0rd -Force) `
-FirstName Dave `
-LastName Jones `
-DisplayName 'Dave Jones'
#
Enable-Mailbox steve -Database DAGDB1
#
Get-User -RecipientTypeDetails User | 
  Enable-Mailbox -Database DAGDB1
#
Get-Mailbox -OrganizationalUnit contoso.com/sales | 
  Set-Mailbox -UseDatabaseQuotaDefaults $false `
  -ProhibitSendReceiveQuota 5GB `
  -IssueWarningQuota 4gb
#
$pass = Read-Host "Enter Password" -AsSecureString
#
New-Mailbox -Name Dave -UserPrincipalName dave@contoso.com `
-Password (Get-Credential).password
#
Set-User –Identity dave –Office IT –City Seattle –State Washington
#Contacts
New-MailContact -Alias rjones `
-Name "Rob Jones" `
-ExternalEmailAddress rob@fabrikam.com `
-OrganizationalUnit sales
#
New-MailUser -Name 'John Davis' `
-Alias jdavis `
-UserPrincipalName jdavis@contoso.com `
-FirstName John `
-LastName Davis `
-Password (ConvertTo-SecureString -AsPlainText P@ssw0rd -Force) `
-ResetPasswordOnNextLogon $false `
-ExternalEmailAddress jdavis@fabrikam.com
#
Set-Contact -Identity rjones `
-Title 'Sales Contractor' `
-Company Fabrikam `
-Department Sales
#
Set-User -Identity jdavis `
-Title 'Sales Contractor' `
-Company Fabrikam `
-Department Sales
#Distribution lists
New-DistributionGroup -Name Sales
#
Get-Mailbox -OrganizationalUnit Sales | 
  Add-DistributionGroupMember -Identity Sales
#
New-DynamicDistributionGroup -Name Accounting `
-Alias Accounting `
-IncludedRecipients MailboxUsers,MailContacts `
-OrganizationalUnit Accounting `
-ConditionalDepartment accounting,finance `
-RecipientContainer contoso.com
#
Add-DistributionGroupMember -Identity Sales -Member administrator 
#Resource mailboxes
New-Mailbox -Name "CR23" -DisplayName "Conference Room 23" `
-UserPrincipalName CR23@contoso.com -Room
#
Set-CalendarProcessing CR23 -AutomateProcessing AutoAccept
#
Set-CalendarProcessing -Identity CR23 `
-AddAdditionalResponse $true `
-AdditionalResponse 'For Assistance Contact Support at Ext. #3376'
#
Set-CalendarProcessing -Identity CR23 `
-ResourceDelegates "joe@contoso.com","steve@contoso.com" `
-AutomateProcessing None
#
Set-ResourceConfig -ResourcePropertySchema 'Room/Whiteboard'
#
Set-Mailbox -Identity CR23 -ResourceCustom Whiteboard
#
Get-Mailbox conf* | Set-Mailbox -Type Room
#
Set-SendConnector Internet -Enabled $false
#Import from CSV
$pass = ConvertTo-SecureString -AsPlainText P@ssw0rd01 -Force
Import-CSV C:\Mailboxes.CSV | % {
  New-Mailbox -Name $_.Name `
  -Alias $_.Alias `
  -UserPrincipalName $_.UserPrincipalName `
  -OrganizationalUnit $_.OrganizationalUnit `
  -Password $pass `
  -ResetPasswordOnNextLogon $true
}
#
Import-CSV C:\Mailboxes.CSV | % {
  $pass = ConvertTo-SecureString -AsPlainText $_.Password -Force
  
  New-Mailbox -Name $_.Name `
  -Alias $_.Alias `
  -UserPrincipalName $_.UserPrincipalName `
  -Password $pass
}
#
Import-CSV C:\NewMailboxes.csv | % {
  New-Mailbox -Name $_.Name `
  -FirstName $_.FirstName `
  -LastName $_.LastName `
  -Alias $_.Alias `
  -UserPrincipalName $_.UserPrincipalName `
  -Password (ConvertTo-SecureString -AsPlainText P@ssw0rd -Force) `
  -OrganizationalUnit $_.OrganizationalUnit `
  -Database DB1

  Set-User -Identity $_.Name `
  -City $_.City `
  -StateOrProvince $_.State `
  -Title $_.Title `
  -Department $_.Department

  Add-DistributionGroupMember -Identity DL_Sales `
  -Member $_.Name

  Add-DistributionGroupMember -Identity DL_Marketing `
  -Member $_.Name
}
#
Get-Mailbox -Filter {Office -eq 'Sales'}
#
New-DynamicDistributionGroup -Name DL_Accounting `
-RecipientFilter {
  (Department -eq 'Accounting') -and 
  (RecipientType -eq 'UserMailbox')
}
#
Get-Mailbox | ?{$_.Office -eq 'Sales'}
#
get-excommand | ?{$_.parameters.keys -eq 'filter'}
#
get-excommand | ?{$_.parameters.keys -eq 'recipientfilter'}
#
New-DynamicDistributionGroup -Name DL_Accounting `
-IncludedRecipients MailboxUsers `
-ConditionalDepartment Accounting
#
$office = "sales"
Get-Mailbox -Filter {Office -eq $office}
#
$office = "sales"
Get-Mailbox -Filter "Office -eq '$office'"
#adding recipient email address
Set-Mailbox dave -EmailAddresses @{add='dave@west.contoso.com'}
#
Set-Mailbox dave -EmailAddresses @{
  add='dave@east.contoso.com',
  'dave@west.contoso.com',
  'dave@corp.contoso.com'
}
#
Set-Mailbox dave -EmailAddresses @{remove='dave@west.contoso.com'}
#
Set-Mailbox dave -EmailAddresses @{
  remove='dave@east.contoso.com',
  'dave@corp.contoso.com'
}
#
Set-Mailbox dave -EmailAddresses @{
  '+'='dave@east.contoso.com'
  '-'='dave@west.contoso.com'
}
#
foreach($i in Get-Mailbox -OrganizationalUnit Sales) {
  Set-Mailbox $i -EmailAddresses @{
    add="$($i.alias)@west.contoso.com"
  }
}
#
foreach($i in Get-Mailbox -ResultSize Unlimited) {
  $i.EmailAddresses | 
    ?{$_.SmtpAddress -like '*@corp.contoso.com'} | %{
      Set-Mailbox $i -EmailAddresses @{remove=$_}
    }
}
#Hide recipients from address list
Set-Mailbox dave –HiddenFromAddressListsEnabled $true
#
Get-Mailbox -Filter {HiddenFromAddressListsEnabled -eq $true}
#Recipient moderation
Set-DistributionGroup -Identity Executives `
-ModerationEnabled $true `
-ModeratedBy administrator `
-SendModerationNotifications Internal
#
Set-Mailbox -Identity dave `
-ModerationEnabled $true `
-ModeratedBy administrator `
-SendModerationNotifications Internal
#
get-excommand | ?{$_.parameters.keys -eq 'ModerationEnabled'}
#
Set-DistributionGroup -Identity Executives `
-BypassModerationFromSendersOrMembers bob@contoso.com
#
$exclude = Get-Mailbox –Filter {Office –eq 'San Diego'} | 
  Select-Object -ExpandProperty alias

Set-DistributionGroup -Identity Executives `
-BypassModerationFromSendersOrMembers $exclude
#Message delivery restriction
Set-DistributionGroup -Identity Sales `
-AcceptMessagesOnlyFrom 'Bob Smith','John Jones'
#
Set-DistributionGroup -Identity Sales `
-AcceptMessagesOnlyFromSendersOrMembers Marketing,bob@contoso.com
#
get-excommand | ?{$_.parameters.keys -eq 'AcceptMessagesOnlyFrom'}
#
$finance = Get-Mailbox -Filter {Office -eq 'Finance'}

Set-DistributionGroup -Identity Sales `
-AcceptMessagesOnlyFrom $finance
#
Set-DistributionGroup -Identity Sales `
-AcceptMessagesOnlyFromSendersOrMembers $null
#
Set-DistributionGroup -Identity Executives `
-RejectMessagesFromSendersOrMembers HourlyEmployees
#
Set-DistributionGroup -Identity HelpDesk `
-RequireSenderAuthenticationEnabled $false
#AutoReply and OOF
Get-MailboxAutoReplyConfiguration dave
#
Set-MailboxAutoReplyConfiguration dave -AutoReplyState Disabled
#
Set-MailboxAutoReplyConfiguration dave `
-AutoReplyState Scheduled `
-StartTime 2/11/2013 `
-EndTime 2/17/2013 `
-ExternalMessage "I will be out of the office this week"
#
Set-MailboxAutoReplyConfiguration dave `
-ExternalMessage (Get-Content C:\oof.html)
#
Get-Mailbox –ResultSize Unlimited | 
  Get-MailboxAutoReplyConfiguration | 
    ?{$_.AutoReplyState -ne "Disabled"} | 
      Select Identity,AutoReplyState,StartTime,EndTime
#Server side inbox rules
New-InboxRule -Name Sales -Mailbox dave `
-From sales@contoso.com `
-MarkImportance High
#
Set-InboxRule -Identity Sales -Mailbox dave -MarkImportance Low
#
Disable-InboxRule -Identity Sales -Mailbox dave
#
Remove-InboxRule -Identity Sales -Mailbox dave -Confirm:$false
#
New-InboxRule -Name "Delete Rule" `
-Mailbox dave `
-SubjectOrBodyContainsWords "Delete Me" `
-DeleteMessage $true
#
New-InboxRule -Name "Redirect to Andrew" `
-Mailbox dave `
-MyNameInToOrCcBox $true `
-RedirectTo "Andrew Castaneda" `
-ExceptIfFrom "Alfonso Mcgowan" `
-StopProcessingRules $true
#
$sales = Get-Mailbox -OrganizationalUnit contoso.com/sales
$sales | %{
  New-InboxRule -Name Junk `
  -Mailbox $_.alias `
  -SubjectContainsWords "[Spam]" `
  -MoveToFolder "$($_.alias):\Junk Email"
}
#Managing Mailbox Folder Permissions
Set-MailboxFolderPermission -Identity dave:\Calendar `
-User Default `
-AccessRights Reviewer
#
$mailboxes = Get-Mailbox -ResultSize Unlimited
$mailboxes | %{
  $calendar = Get-MailboxFolderPermission "$($_.alias):\Calendar" `
  -User Default
  
  if(!($calendar.AccessRights)) {
    Add-MailboxFolderPermission "$($_.alias):\Calendar" `
    -User Default -AccessRights Reviewer	
  }
  
  if($calendar.AccessRights -ne "Reviewer") {
    Set-MailboxFolderPermission "$($_.alias):\Calendar" `
    -User Default -AccessRights Reviewer
  }
}
#Importing user photo into active directory
Regsvr32 schmmgmt.dll
Import-RecipientDataProperty -Identity dave `
-Picture `
-FileData (
  [Byte[]](
    Get-Content -Path C:\dave.jpg `
    -Encoding Byte `
    -ReadCount 0
  )
)
#Update de OAB w/Photo
$oab = Get-OfflineAddressBook 'Default Offline Address Book'
$oab.ConfiguredAttributes.Remove('thumbnailphoto,indicator')

Set-OfflineAddressBook 'Default Offline Address Book' `
-ConfiguredAttributes $oab.ConfiguredAttributes
#
$oab = Get-OfflineAddressBook 'Default Offline Address Book'
$oab.ConfiguredAttributes.Add('thumbnailphoto,value')

Set-OfflineAddressBook 'Default Offline Address Book' `
-ConfiguredAttributes $oab.ConfiguredAttributes
#
Update-OfflineAddressBook 'Default Offline Address Book'
#
$photos = Get-ChildItem \\server01\employeephotos -Filter *.jpg

foreach($i in $photos) {
[Byte[]]$data = gc -Path $i.fullname -Encoding Byte -ReadCount 0
  Import-RecipientDataProperty $i.basename -Picture -FileData $data
}
#Reporting Mailbox size
Get-MailboxDatabase | Get-MailboxStatistics | 
  ?{!$_.DisconnectDate} | 
    Select-Object DisplayName,TotalItemSize
#
Get-MailboxDatabase | Get-MailboxStatistics | 
  ?{!$_.DisconnectDate} | 
    Select-Object DisplayName,TotalItemSize | 
      Export-CSV c:\mbreport.csv -NoType
#
Get-MailboxDatabase | Get-MailboxStatistics | 
  ?{!$_.DisconnectDate} | 
    Select-Object DisplayName,
    @{n="SizeMB";e={$_.TotalItemSize.value.ToMb()}} | 
      Sort-Object SizeMB -Desc
#Move Request
New-MoveRequest –Identity testuser –TargetDatabase DB2
#
Get-Mailbox -Database DB1 | New-MoveRequest –TargetDatabase DB2
#
Get-MoveRequest | 
  ?{$_.Status -ne 'Completed'} | 
    Get-MoveRequestStatistics | 
      select DisplayName,PercentComplete,BytesTransferred
#
while($true) {
  Get-MoveRequest| ?{$_.Status -ne 'Completed'}
  Start-Sleep 5
  Clear-Host
}
#
Remove-MoveRequest -Identity testuser -Confirm:$false
#
Get-MoveRequest -ResultSize Unlimited | 
  Remove-MoveRequest -Confirm:$false
#
New-MoveRequest testuser -TargetDatabase DB2
#
New-MoveRequest testuser -TargetDatabase DB2 -PrimaryOnly
#
New-MoveRequest testuser -ArchiveOnly -ArchiveTargetDatabase DB2
#
$mailboxes = Get-Mailbox `
-RecipientTypeDetails UserMailbox `
-Database DB1 |
 Get-MailboxStatistics |
  ?{$_.TotalItemSize -gt 2gb}
$mailboxes | %{
  New-MoveRequest -Identity $_.DisplayName `
  -BatchName 'Large Mailboxes' `
  -TargetDatabase DB2
}
#
Get-MoveRequest -BatchName 'Large Mailboxes'
#
New-MoveRequest -Identity testuser `
-BadItemLimit 100 `
-AcceptLargeDataLoss `
-TargetDatabase DB2
#Mailbox move email notification
New-MigrationBatch –Name Batch01 `
–CSVData ([System.IO.File]::ReadAllBytes("C:\localmove.csv")) `
–Local -TargetDatabase DB2 `
–NotificationEmails 'administrator@contoso.com','jonand@contoso.com' `
-AutoStart
Get-MigrationUser | Get-MigrationUserStatistics | ft –Autosize

Complete-MigrationBatch –Identity Batch01
#
New-MigrationBatch –Name Batch02 `
–CSVData ([System.IO.File]::ReadAllBytes("C:\localmove.csv")) `
–Local -TargetDatabase DB2 `
–NotificationEmails 'administrator@contoso.com','testuser@contoso.com' `
–AutoStart -AutoComplete
#
New-ManagementRoleAssignment –Role "Mailbox Import Export" `
-User administrator
#
New-MailboxExportRequest –Mailbox testuser `
–Filepath \\contoso-ex01\export\testuser.pst
#
New-MailboxExportRequest -Mailbox testuser `
-IncludeFolders "Sent Items" `
-FilePath \\contoso-ex01\export\testuser_sent.pst `
-ExcludeDumpster
#
New-MailboxExportRequest -Mailbox testuser `
-ContentFilter {Received -lt "09/01/2010"} `
-FilePath \\contoso-ex01\export\testuser_archive.pst `
-ExcludeDumpster `
-IsArchive
#
Get-MailboxExportRequest -Mailbox testuser -Status Failed
#
foreach($i in Get-MailboxExportRequest) {
  Get-MailboxExportRequestStatistics $i | 
    select-object SourceAlias,Status,PercentComplete
}
#
New-MailboxImportRequest -Mailbox sysadmin `
-TargetRootFolder "Recover" `
-FilePath \\contoso-ex01\export\testuser_sent.pst
#
param($Path, $BatchName)
  foreach($i in Get-Mailbox -ResultSize Unlimited) {
    $filepath = Join-Path -Path $Path -ChildPath "$($i.alias).pst"
    New-MailboxExportRequest -Mailbox $i `
    -FilePath $filepath `
    -BatchName $BatchName
}
#
$batch = "Export for (Get-Date).ToShortDateString()"
.\Export.ps1 -Path \\contoso\ex01\export -BatchName$batch
#
Get-MailboxExportRequestStatistics | 
  ?{$_.BatchName -eq "Export for 11/20/2012"} | 
    select SourceAlias,Status,PercentComplete
#Delete mesagges from mailboxes
New-ManagementRoleAssignment –Role "Mailbox Import Export" `
-User administrator
#
Search-Mailbox -Identity testuser `
-SearchQuery "Subject:'Your mailbox is full'" `
-DeleteContent `
-Force
#
Search-Mailbox -Identity testuser `
-SearchQuery "Subject:'free ipad'" `
-DoNotIncludeArchive `
-SearchDumpster:$false `
-DeleteContent `
-Force
#
Get-Mailbox |
  Search-Mailbox -SearchQuery "from:spammer@contoso.com" `
  -EstimateResultOnly | Export-CSV C:\report.csv -NoType
#
Search-Mailbox -Identity testuser `
-SearchQuery "Subject:'Accounting Reports'" `
-TargetMailbox sysadmin `
-TargetFolder "Delete Log" `
-LogOnly `
-LogLevel Full
#
Get-Mailbox -ResultSize Unlimited | 
  Search-Mailbox -SearchQuery 'from:spammer@contoso.com' `
  -DeleteContent -Force
#Managing disconnected mailboxes
Connect-Mailbox -Identity 'Test User' `
-Database DB1 `
-User 'contoso\tuser1009' `
-Alias tuser1009
#
Get-MailboxDatabase | 
  Get-MailboxStatistics | 
    ?{$_.DisconnectDate} | 
      fl DisplayName,MailboxGuid,LegacyExchangeDN,DisconnectDate
#
Get-MailboxDatabase | 
  Get-MailboxStatistics | 
    ?{$_.DisconnectDate -and $_.IsArchiveMailbox -eq $false} | 
      fl DisplayName,MailboxGuid,LegacyExchangeDN,DisconnectDate
#
function Get-DisconnectedMailbox {
  param(
  [String]$Name = '*',
  [Switch]$Archive
  )
  
  $databases = Get-MailboxDatabase
  $databases  | %{
    $db = Get-Mailboxstatistics -Database $_ | 
      ?{$_.DisconnectDate -and $_.IsArchiveMailbox -eq $Archive}
 
    $db | ?{$_.displayname -like $Name} |
      Select DisplayName,
        MailboxGuid,
        Database,
        DisconnectReason
    }
}
#
Remove-StoreMailbox -Identity 1c097bde-edec-47df-aa4e-535cbfaa13b4 `
-Database DB1 `
-MailboxState Disabled `
-Confirm:$false
#
$mb = Get-MailboxDatabase | 
  Get-MailboxStatistics | 
    ?{$_.DisconnectDate}

foreach($i in $mb) {
  Remove-StoreMailbox -Identity $i.MailboxGuid `
  -Database $i.Database `
  -MailboxState $i.DisconnectReason.ToString() `
  -Confirm:$false
}
#Generating mailbox folder reports
Get-MailboxFolderStatistics -Identity testuser -FolderScope All | 
  select Name,ItemsInFolder,FolderSize | 
    Export-CSV C:\MB_Report.csv -NoType
#
function Get-MailboxDeletedItemStats {
  param([string]$id)
  
  $folder = Get-MailboxFolderStatistics $id `
  -FolderScope DeletedItems
  
  $deletedFolder = $folder.FolderSize.ToMb()
  $mb = (Get-MailboxStatistics $id).TotalItemSize.value.ToMb()

  if($deletedFolder -gt 0 -and $mb -gt 0) {
    $percentDeleted = "{0:P0}" -f ($deletedFolder / $mb)
  }
  else {
    $percentDeleted = "{0:P0}" -f 0
  }

  New-Object PSObject -Property @{
    Identity = $id
    MailboxSizeMB = $mb
    DeletedItems = $folder.ItemsInFolder
    DeletedSizeMB = $deletedFolder
    PercentDeleted = $percentDeleted
  }
}
#
foreach($mailbox in (Get-Mailbox -ResultSize Unlimited)) {
  Get-MailboxDeletedItemStats $mailbox
}
#Reporting on mailbox creation time
Get-Mailbox -ResultSize Unlimited | 
  ?{$_.WhenMailboxCreated –ge (Get-Date).AddDays(-7)} | 
    Select DisplayName, WhenMailboxCreated, Database | 
      Export-CSV C:\mb_report.CSV -NoType
#
$_.WhenMailboxCreated –ge (Get-Date).AddDays(-7)
#
Get-Mailbox | ?{$_.WhenMailboxCreated.Month-eq 10}
#
Get-Mailbox | ?{
  ($_.WhenMailboxCreated.DayOfWeek -eq "Monday") -and `
  ($_.WhenMailboxCreated.Month -eq 10)
}
#Checking mailbox logon statistics
Get-MailboxServer | 
 Get-LogonStatistics | 
   Select UserName,ApplicationId,ClientVersion,LastAccessTime
#
Get-LogonStatistics -Identity testuser | Format-List *
#
Get-LogonStatistics -Database DB1
#Setting storage quotas for mailboxes
Set-Mailbox -Identity testuser `
-IssueWarningQuota 1024mb `
-ProhibitSendQuota 1536mb `
-ProhibitSendReceiveQuota 2048mb `
-UseDatabaseQuotaDefaults $false
#
Get-User -RecipientTypeDetails UserMailbox `
-Filter {Title -eq 'Manager'} | 
  Set-Mailbox -IssueWarningQuota 2048mb `
  -ProhibitSendQuota 2560mb `
  -ProhibitSendReceiveQuota 3072mb `
  -UseDatabaseQuotaDefaults $false
#Finding inactive mailboxes
$mailboxes = Get-Mailbox -ResultSize Unlimited
$mailboxes | ?{
  (Get-MailboxStatistics $_).LastLogonTime -and `
  (Get-MailboxStatistics $_).LastLogonTime -le `
  (Get-Date).AddDays(-90)
}
#
Get-User -ResultSize Unlilimited -RecipientTypeDetails UserMailbox | 
  ?{$_.UserAccountControl -match 'AccountDisabled'}
#Detecting and fixing corrupt mailboxes
New-MailboxRepairRequest -Mailbox testuser `
-CorruptionType SearchFolder `
-DetectOnly
New-MailboxRepairRequest -Mailbox testuser `
-CorruptionType ProvisionedFolder `
-DetectOnly
New-MailboxRepairRequest -Mailbox testuser `
-CorruptionType FolderView `
-DetectOnly
New-MailboxRepairRequest -Mailbox testuser `
-CorruptionType AggregateCounts `
-DetectOnly
#
New-MailboxRepairRequest -Mailbox testuser `
-CorruptionType SearchFolder

New-MailboxRepairRequest -Mailbox testuser `
-CorruptionType ProvisionedFolder

New-MailboxRepairRequest -Mailbox testuser `
-CorruptionType FolderView

New-MailboxRepairRequest -Mailbox testuser `
-CorruptionType AggregateCounts
#
Get-Mailbox -OrganizationalUnit "OU=Sales,DC=contoso,DC=com" | 
  New-MailboxRepairRequest `
  -CorruptionType SearchFolder `
  –DetectOnly
#
$repair = New-MailboxRepairRequest -Mailbox testuser `
-CorruptionType SearchFolder
#
Get-EventLog -LogName Application -ComputerName ex01 | ?{
  ('4003','4004','4006','4008','9017','9018' -contains $_.EventID) -and `
  ($_.Message -match $repair.RequestID)
}
#Restoring deleted items from mailboxes
New-ManagementRoleAssignment –Role "Mailbox Import Export" `
-User administrator
#
Search-Mailbox -Identity testuser `
-SearchQuery "subject:'Expense Report'" `
-TargetMailbox restoremailbox `
-TargetFolder "Test Restore" `
-SearchDumpsterOnly
#
Search-Mailbox -Identity testuser `
-SearchQuery "received:>11/25/2012" `
-TargetMailbox administrator `
-TargetFolder "Testuser Restore" `
-SearchDumpsterOnly
#Managing public folder mailboxes
New-Mailbox –Name PF_Master_Hierarchy –Alias PF_Master_Hierarchy `
–Database DB1 –OrganizationalUnit "CN=Users,DC=contoso,DC=com" `
–PublicFolder –Database DB1

New-PublicFolder "Top Folder" –Path "\"

New-PublicFolder "AMER" –Path "\Top Folder"

New-PublicFolder "USA" –Path "\Top Folder\AMER"

New-PublicFolder "Projects" –Path "\Top Folder\AMER\USA"

Enable-MailPublicFolder –Identity "\Top Folder\AMER\USA\Projects"
#
Set-OrganizationConfig –DefaultPublicFolderIssueWarningQuota 5GB
#Reporting on public folder statistics
Get-Mailbox –PublicFolder | Get-MailboxStatistics | ft `
DisplayName,TotalItemSize -AutoSize

Get-PublicFolderStatistics | ft Name,ItemCount,TotalItemSize,TotalDeleted `
ItemSize,FolderPath,MailboxOwnerId -AutoSize

Get-Mailbox –PublicFolder | Get-MailboxStatistics | Select `
DisplayName,TotalItemSize | Export-CSV C:\pf_hierarchy.csv -Notype

Get-PublicFolderStatistics | Select Name,ItemCount,TotalItemSize, `
TotalDeletedItemSize,FolderPath,MailboxOwnerId | Export-CSV C:\pf.csv -Notype
#
Set-OrganizationConfig –DefaultPublicFolderIssueWarningQuota 5GB `
–DefaultPublicFolderProhibitPostQuota 10GB
#Managing user access to public folders
Get-PublicFolder –Recurse | Get-PublicFolderClientPermission

Remove-PublicFolderClientPermission –Identity "\" –User Default

Remove-PublicFolderClientPermission –Identity "\Top Folder" –User Default

Add-PublicFolderClientPermission –Identity "\" –User Default `
–AccessRights Reviewer

Add-PublicFolderClientPermission –Identity "\Top Folder" –User Default `
–AccessRights Reviewer
#
Add-PublicFolderClientPermission –Identity "\Top Folder" –User "PF_Top Folder_Owner" –AccessRights Owner

Add-PublicFolderClientPermission –Identity "\Top Folder\AMER\USA\Projects" –User "PF_AMER_USA_Projects_Owner" –AccessRights Owner
#Reporting on distribution group membership
foreach($i in Get-DistributionGroup -ResultSize Unlimited) {
  Get-DistributionGroupMember $i -ResultSize Unlimited | 
    Select-Object @{n="Member";e={$_.Name}},
      RecipientType,
      @{n="Group";e={$i.Name}}
}
#
$report=foreach($i in Get-DistributionGroup -ResultSize Unlimited) {
  Get-DistributionGroupMember $i -ResultSize Unlimited | 
    Select-Object @{n="Member";e={$_.Name}},
      RecipientType,
      @{n="Group";e={$i.Name}}
}

$report | Export-CSV c:\GroupMembers.csv -NoType
#Adding members to a distribution group from an external file
Get-Content c:\temp\users.txt | ForEach-Object {
  Add-DistributionGroupMember –Identity Sales -Member $_
}
#
Import-Csv C:\temp\users.csv | ForEach-Object {
  Add-DistributionGroupMember Sales -Member $_.EmailAddress
}
#Previewing dynamic distribution group membership
$legal= Get-DynamicDistributionGroup -Identity legal
Get-Recipient -RecipientPreviewFilter $legal.RecipientFilter
#
Get-Recipient -RecipientPreviewFilter "Department -eq 'Legal'"
#
function Get-DynamicDistributionGroupMember {
  param(
  [Parameter(Mandatory=$true)]
  $Identity
  )

  $group = Get-DynamicDistributionGroup -Identity $Identity
  Get-Recipient -RecipientPreviewFilter $group.RecipientFilter
  
}
#Excluding hidden recipients from a dynamic distribution group
New-DynamicDistributionGroup -Name TechSupport `
-RecipientContainer contoso.com/TechSupport `
-RecipientFilter {
  HiddenFromAddressListsEnabled -ne $true
}
#
New-DynamicDistributionGroup -Name Marketing `
-RecipientContainer contoso.com/Marketing `
-RecipientFilter {
  EmailAddresses -like '*marketing*'
}
#
Set-DynamicDistributionGroup -Identity Marketing `
-RecipientFilter {
  (EmailAddresses -like '*marketing*') -and 
  (HiddenFromAddressListsEnabled -ne $true)
}
#Converting and upgrading distribution groups
Get-DistributionGroup -ResultSize Unlimited `
-RecipientTypeDetails MailNonUniversalGroup | 
  Set-Group -Universal
#
Get-DistributionGroup –ResultSize Unlimited | 
  Set-DistributionGroup –ForceUpgrade
#
Get-Group –ResultSize Unlimited `
-RecipientTypeDetails NonUniversalGroup `
–OrganizationalUnit Sales | 
  Where-Object {$_.GroupType -match 'global'} | 
    Set-Group -Universal
#Allowing managers to modify group membership
New-ManagementRoleAssignment -Role MyDistributionGroups `
-Policy "Default Role Assignment Policy"
#
Set-DistributionGroup Sales -ManagedBy bobsmith
#
New-ManagementRole -Name MyDGCustom -Parent MyDistributionGroups
#
Remove-ManagementRoleEntry MyDGCustom\New-DistributionGroup
Remove-ManagementRoleEntry MyDGCustom\Remove-DistributionGroup
#
New-ManagementRoleAssignment -Role MyDGCustom `
-Policy "Default Role Assignment Policy"
#Removing disabled user accounts from distribution groups
$groups = Get-DistributionGroup -ResultSize Unlimited

foreach($group in $groups){
 Get-DistributionGroupMember $group | 
  ?{$_.RecipientType -like '*User*' -and $_.ResourceType -eq $null} | 
   Get-User | ?{$_.UserAccountControl -match 'AccountDisabled'} | 
    Remove-DistributionGroupMember $group -Confirm:$false
}
#
$groups = Get-DistributionGroup -ResultSize Unlimited

$report = foreach($group in $groups){
 Get-DistributionGroupMember $group | 
  ?{$_.RecipientType -like '*User*' -and $_.ResourceType -eq $null} | 
   Get-User | ?{$_.UserAccountControl -match 'AccountDisabled'} | 
     Select-Object Name,RecipientType,@{n='Group';e={$group}}
}

$report | Export-CSV c:\disabled_group_members.csv -NoType
#Working with distribution group naming policies
Set-OrganizationConfig -DistributionGroupNamingPolicy `
"DL_<GroupName>"
#
Set-OrganizationConfig -DistributionGroupNamingPolicy `
"<Department>_<GroupName>_<StateOrProvince>"
#
Set-OrganizationConfig `
-DistributionGroupNameBlockedWordsList badword1,badword2
#
Set-OrganizationConfig `
-DistributionGroupDefaultOU "contoso.com/Test"
#
New-DistributionGroup -Name Accounting -IgnoreNamingPolicy
#Working with distribution group membership approval
Set-DistributionGroup -Identity CompanyNews `
-MemberJoinRestriction Open `
-MemberDepartRestriction Open
#
Set-DistributionGroup -Identity AllEmployees `
-ManagedBy dave@contoso.com,john@contoso.com
#
New-AddressList -Name 'All Sales Users' `
-RecipientContainer contoso.com/Sales `
-IncludedRecipients MailboxUsers
#
New-AddressList -Name MobileUsers `
-RecipientContainer contoso.com `
-RecipientFilter {
  HasActiveSyncDevicePartnership -ne $false
}
#
New-AddressList -Name MobileUsers `
-RecipientContainer contoso.com `
-RecipientFilter {
  (HasActiveSyncDevicePartnership -ne $false) -and 
  (Phone -ne $null)
}
#Exporting address list membership to a CSV file
$allusers = Get-AddressList "All Users"
Get-Recipient -RecipientPreviewFilter $allusers.RecipientFilter | 
  Select-Object DisplayName,Database | 
    Export-Csv -Path c:\allusers.csv -NoTypeInformation
#
$allusers = Get-AddressList "All Users"
Get-Recipient -RecipientPreviewFilter $allusers.RecipientFilter | 
  Select-Object DisplayName,
    @{n="EmailAddresses";e={$_.EmailAddresses -join ";"}} | 
      Export-Csv -Path c:\allusers.csv -NoTypeInformation
#
$GAL = Get-GlobalAddressList "Default Global Address List"
Get-Recipient -RecipientPreviewFilter $GAL.RecipientFilter | 
  Select-Object DisplayName,
    @{n="EmailAddresses";e={$_.EmailAddresses -join ";"}} | 
      Export-Csv -Path c:\GAL.csv -NoTypeInformation
#Configuring hierarchical address books
$objDomain = [ADSI]''
$objOU = $objDomain.Create('organizationalUnit', 'ou=HAB')
$objOU.SetInfo()
#
New-DistributionGroup -Name ContosoRoot `
-DisplayName ContosoRoot `
-Alias ContosoRoot `
-OrganizationalUnit contoso.com/HAB `
-SamAccountName ContosoRoot `
-Type Distribution `
-IgnoreNamingPolicy
#
Set-OrganizationConfig -HierarchicalAddressBookRoot ContosoRoot
#
Add-DistributionGroupMember -Identity ContosoRoot -Member Executives
Add-DistributionGroupMember -Identity ContosoRoot -Member Finance 
Add-DistributionGroupMember -Identity ContosoRoot -Member Sales
#
Set-Group -Identity ContosoRoot -IsHierarchicalGroup $true
Set-Group Executives -IsHierarchicalGroup $true -SeniorityIndex 100
Set-Group Finance -IsHierarchicalGroup $true -SeniorityIndex 50
Set-Group Sales -IsHierarchicalGroup $true -SeniorityIndex 75
#Managing the mailbox databases
New-MailboxDatabase -Name DB4 `
-EdbFilePath E:\Databases\DB4\DB4.edb `
-LogFolderPath E:\Databases\DB4 `
-Server EX01
#
Mount-Database -Identity DB4
#
Set-MailboxDatabase -Identity DB4 -Name Database4
#
Remove-MailboxDatabase -Identity Database4 `
-Confirm:$false
#
New-MailboxDatabase -Name DB10 -Server EX01 | Mount-Database
#
Set-MailboxDatabase -Identity DB1 -IsExcludedFromProvisioning $true
#
@data = Import-CSV .\DBs.csv
foreach($row in $data) {
  $DBName = $row.DBName
  $LogPath = 'E:\' + $DBName + '\Logs'
  $DBPath = 'E:\' + $DBName + '\Database\' + $DBName + '.edb'
  $Server = $row.Server
New-MailboxDatabase –Name $DBName –Server $Server `
–Edbfilepath $DBPath `
–Logfolderpath $LogPath
}

foreach($row in $data) {
    $DBName = $row.DBName
Mount-Database $DBName
}
#Moving databases and logs to another location
Move-DatabasePath -Identity DB1 `
-EdbFilePath E:\Databases\DB1\DB1.edb `
-LogFolderPath E:\Databases\DB1 `
-Confirm:$false `
-Force
#
Dismount-Database -Identity DB2 -Confirm:$false
#
Move-DatabasePath -Identity DB2 `
-EdbFilePath F:\Databases\DB2\DB2.edb `
-LogFolderPath F:\Databases\DB2 `
-ConfigurationOnly `
-Confirm:$false `
-Force
#
Mount-Database -Identity DB2
#
foreach($i in Get-MailboxDatabase -Server EX01) {
  $DBName = $i.Name

  Move-DatabasePath -Identity $DBName `
  -EdbFilePath "S:\Database\$DBName\$DBName.edb" `
  -LogFolderPath "S:\Database\$DBName" `
  -Confirm:$false `
  -Force
}
#Configuring the mailbox database limits
Set-MailboxDatabase -Identity DB1 `
-IssueWarningQuota 2gb `
-ProhibitSendQuota 2.5gb `
-ProhibitSendReceiveQuota 3gb
#
Set-MailboxDatabase -Identity DB1 -DeletedItemRetention 30
#
Set-MailboxDatabase -Identity DB1 -MailboxRetention 90
#
Set-MailboxDatabase -Identity DB1 `
-RetainDeletedItemsUntilBackup $true
#
Get-MailboxDatabase | Set-MailboxDatabase `
-IssueWarningQuota 2gb `
-ProhibitSendQuota 2.5gb `
-ProhibitSendReceiveQuota 3gb `
-DeletedItemRetention 30 `
-MailboxRetention 90 `
-RetainDeletedItemsUntilBackup $true
#Reporting on mailbox database size
Get-MailboxDatabase -Status | select-object Name,DatabaseSize
#
Get-MailboxDatabase -Status | 
  select-object Name,Server,DatabaseSize,Mounted | 
    Export-CSV –Path c:\databasereport.csv -NoTypeInformation
#
Get-MailboxDatabase -Status | 
  Select-Object Name,
    @{n="DatabaseSize";e={$_.DatabaseSize.ToMb()}}
#Finding the total number of mailboxes in a database
@(Get-Mailbox -Database DB1).count
#
Get-Mailbox -Database DB1 | Measure-Object
#
(Get-Mailbox -Database DB1 | Measure-Object).Count
#
Get-Mailbox -Database DB1 | 
  Measure-Object | 
    Select-Object -ExpandProperty Count
#
Measure-Command -Expression {@(Get-Mailbox -Database DB1).Count}
#
Get-MailboxDatabase | 
  Select-Object Name,
    @{n="TotalMailboxes";e={@(Get-Mailbox -Database $_).count}}
#Determining the average mailbox size per database
Get-MailboxStatistics -Database DB1 | 
  ForEach-Object {$_.TotalItemSize.value.ToMB()} | 
    Measure-Object -Average | 
     Select-Object –ExpandProperty Average
#
Get-MailboxStatistics -Database DB1 | 
 Where-Object{!$_.DisconnectDate -and !$_.IsArchive} | 
  ForEach-Object {$_.TotalItemSize.value.ToMB()} | 
   Measure-Object -Average | 
    Select-Object –ExpandProperty Average
#
$MBAvg = Get-MailboxStatistics -Database DB1 | 
  ForEach-Object {$_.TotalItemSize.value.ToMB()} | 
    Measure-Object -Average | 
     Select-Object –ExpandProperty Average
[Math]::Round($MBAvg,2)
#
foreach($DB in Get-MailboxDatabase) {
  Get-MailboxStatistics -Database $DB |
    ForEach-Object{$_.TotalItemSize.value.ToMB()} |
      Measure-Object -Average |
        Select-Object @{n="Name";e={$DB.Name}},
         @{n="AvgMailboxSize";e={[Math] `
            ::Round($_.Average,2)}} | Sort-Object ` 
              AvgMailboxSize -Desc
}
# Reporting on database backup status
Get-MailboxDatabase -Identity DB1 -Status | fl Name,LastFullBackup
#
Get-MailboxDatabase -Status | 
  ?{$_.LastFullBackup -le (Get-Date).AddDays(-1)} | 
    Select-object Name,LastFullBackup
#
Get-MailboxDatabase -Status | ForEach-Object {
  if(!$_.LastFullBackup) {
    $LastFull = "Never"
  }
  else {
    $LastFull = $_.LastFullBackup
  }
  New-Object PSObject -Property @{
    Name = $_.Name
    LastFullBackup = $LastFull
    DaysSinceBackup = if($LastFull-is [datetime]) {
      (New-TimeSpan $LastFull).Days
    }
    Else {
      $LastFull
    }
  }
}
#Restoring data from a recovery database
New-MailboxDatabase -Name RecoveryDB `
-EdbFilePath E:\Recovery\DB1\DB1.edb `
-LogFolderPath E:\Recovery\DB01 `
-Recovery `
-Server MBX1
#
Eseutil /mh .\DB1.edb
Eseutil /R E02 /D
Mount-Database -Identity RecoveryDB
#
Get-MailboxStatistics –Database RecoveryDB | fl DisplayName,MailboxGUID,LegacyDN
#
New-MailboxRestoreRequest -SourceDatabase RecoveryDB `
-SourceStoreMailbox "Joe Smith" `
-TargetMailbox joe.smith
#
Get-MailboxStatistics -Database RecoveryDB |
  fl DisplayName,MailboxGUID,LegacyDN
#
$mailboxes = Get-MailboxStatistics -Database RecoveryDB
foreach($mailbox in $mailboxes) {
  New-MailboxRestoreRequest -SourceDatabase RecoveryDB `
  -SourceStoreMailbox $mailbox.DisplayName `
  -TargetMailbox $mailbox.DisplayName  
}
#Managing Client Access
Set-CasMailbox -Identity 'Dave Smith' `
-OWAEnabled $false `
-ActiveSyncEnabled $false `
-PopEnabled $false `
-ImapEnabled $false
#
Get-Mailbox -Filter {Office -eq 'Sales'} | 
  Set-CasMailbox -OWAEnabled $false `
  -ActiveSyncEnabled $false `
  -PopEnabled $true `
  -ImapEnabled $true
#
Get-Mailbox -RecipientTypeDetails UserMailbox | 
  Set-CasMailbox -OWAEnabled $true `
  -ActiveSyncEnabled $false `
  -PopEnabled $false `
  -ImapEnabled $false `
  -MAPIEnabled $false
  #
  param(
  $name,
  $password,
  $upn,
  $alias,
  $first,
  $last
)

$pass = ConvertTo-SecureString -AsPlainText $password -Force

$mailbox = New-Mailbox -UserPrincipalName $upn `
-Alias $alias `
-Name "$first $last" `
-Password $pass `
-FirstName $first `
-LastName $last

Set-CasMailbox -Identity $mailbox `
-OWAEnabled $false `
-ActiveSyncEnabled $false `
-PopEnabled $false `
-ImapEnabled $false `
-MAPIBlockOutlookRpcHttp $true
#
.\New-MailboxScript.ps1 -first John -last Smith -alias jsmith -password P@ssw0rd01 -upn jsmith@contoso.com
#Setting internal and external CAS URLs
Set-OwaVirtualDirectory -Identity 'CAS1\owa (Default Web Site)' `
-ExternalUrl https://mail.contoso.com/owa
#
Get-OwaVirtualDirectory -Server cas1 | fl ExternalUrl
#
Set-EcpVirtualDirectory -Identity 'CAS1\ecp (Default Web Site)' `
-ExternalUrl https://mail.contoso.com/ecp
#
Get-EcpVirtualDirectory -Server cas1 | 
  Set-EcpVirtualDirectory -ExternalUrl https://mail.contoso.com/ecp
#
Set-ClientAccessServer -Identity cas1 `
-AutoDiscoverServiceInternalUri `
https://mail.contoso.com/Autodiscover/Autodiscover.xml
#
Set-OABVirtualDirectory -Identity "cas1\oab (Default Web Site)" `
-ExternalUrl https://mail.contoso.com/oab
#
Set-ActivesyncVirtualDirectory -Identity `
"cas1\Microsoft-Server-ActiveSync (Default Web Site)" `
-ExternalURL https://mail.contoso.com/Microsoft-Server-Activesync
#
Set-WebServicesVirtualDirectory -Identity `
"cas1\EWS (Default Web Site)" `
-ExternalUrl https://mail.contoso.com/ews/exchange.asmx
#Managing Outlook Anywhere settings
Set-OutlookAnywhere –Identity 'CAS1\Rpc (Defautl Web Site)' `
-ExternalHostname mail.contoso.com `
-ExternalClientRequireSsl $true `-InternalHostname mail.contoso.com `
-InternalClientRequireSsl $true `-ExternalClientAuthenticationMethod Basic `-InternalClientAuthenticationMethod Ntlm `
-SSLOffloading $false
#
Get-OutlookAnywhere | fl ServerName,ExternalHostname, InternalHostname
#
Set-OutlookAnywhere -Identity 'CAS1\Rpc (Default Web Site)' `
-ExternalHostname 'outlook.contoso.com'
#Blocking Outlook clients from connecting to Exchange
Set-CASMailbox -Identity dsmith -MAPIBlockOutlookRpcHttp $true
#
Set-CASMailbox -Identity dsmith `
-MAPIBlockOutlookNonCachedMode $true
#
Get-CASMailbox -Resultsize Unlimited | 
  Set-CASMailbox -MAPIBlockOutlookVersions '-11.9.9'
#
Get-CASMailbox -ResultSize Unlimited | 
  ?{$_.MAPIBlockOutlookVersions}
#
Set-CASMailbox dsmith -MAPIBlockOutlookVersions $null
#
Get-CASMailbox -ResultSize Unlimited | 
  Set-CASMailbox -MAPIBlockOutlookVersions $null
#
Get-CASMailbox | Where-Object{$_.MAPIBlockOutlookNonCachedMode}
#
Get-CASMailbox | Where-Object{$_.MAPIBlockOutlookRpcHttp}
#
Get-CASMailbox -OrganizationalUnit contoso.com/Sales | 
  Set-CASMailbox -MAPIBlockOutlookRpcHttp $true
#
Get-CASMailbox -OrganizationalUnit contoso.com/Sales | 
  Set-CASMailbox -MAPIBlockOutlookRpcHttp $false
#
Set-CASMailbox dsmith -MAPIBlockOutlookVersions '-5.9.9;7.0.0-11.9.9'
#
Set-RpcClientAccess -Server cas1 `
-BlockedClientVersions '-5.9.9;7.0.0-13.9.9'
#Reporting on active OWA and RPC connections
Get-Counter –Counter '\\tlex01\MSExchange OWA\Current Users'
#
Get-Counter '\\tlex01\MSExchange RpcClientAccess\User Count'
#
Get-Counter 'MSExchange OWA\Current Unique Users' `
-ComputerName tlex01,tlex02
#
Get-Counter -ListSet *owa* -ComputerName cas1 | 
  Select-Object -expand paths
#
function Get-ActiveUsers {
  [CmdletBinding()]
  param(
    [Parameter(Position=0, 
      ValueFromPipelineByPropertyName=$true, 
      Mandatory=$true)]
    [string[]]
    $Name
  )

  process {
    $Name | %{
      $RPC = Get-Counter "\MSExchange RpcClientAccess\User Count" `
      -ComputerName $_
      
      $OWA = Get-Counter "\MSExchange OWA\Current Unique Users" `
      -ComputerName $_
      
      New-Object PSObject -Property @{
        Server = $_
        'RPC Client Access' = $RPC.CounterSamples[0].CookedValue
#Controlling ActiveSync device access
get-ActiveSyncOrganizationSettings –DefaultAccessLevel `
Quarantine –AdminMailRecipients administrator@contoso.com
#
Set-CASMailbox -Identity dsmith `
-ActiveSyncAllowedDeviceIDs BAD73E6E02156460E800185977C03182
#
Set-ActiveSyncOrganizationSettings –DefaultAccessLevel Quarantine `
–AdminMailRecipients helpdesk@contoso.com `
-UserMailInsert 'Call the Help Desk for immediate assistance'
#
Get-ActiveSyncDevice | 
  ?{$_.DeviceAccessState -eq 'Quarantined'} | 
      fl UserDisplayName,DeviceAccessState,DeviceID
#
New-ActiveSyncDeviceAccessRule –QueryString PocketPC `
–Characteristic DeviceModel `
–AccessLevel Allow
#Reporting on ActiveSync devices
Get-ActiveSyncDeviceStatistics -Mailbox dsmith
#
Get-ActiveSyncDeviceStatistics -Mailbox dsmith | 
  select LastSuccessSync,Status,DevicePhoneNumber,DeviceType
#
Get-ActiveSyncDeviceStatistics -Mailbox dsmith | 
  select LastSuccessSync,Status,DevicePhoneNumber,DeviceType | 
      Export-CSV -Path c:\report.csv -NoType
#
$dev = Get-ActiveSyncDevice | ?{$_.DeviceAccessState -eq 'Allowed'}
$dev | ForEach-Object {
  $mailbox = $_.UserDisplayName
  $stats = Get-ActiveSyncDeviceStatistics –Identity $_
  $stats | Select-Object @{n="Mailbox";e={$mailbox}},
    LastSuccessSync,
    Status,
    DevicePhoneNumber,
    DeviceType
}
#
$mbx = Get-CASMailbox | ?{$_.HasActiveSyncDevicePartnership}
$mbx | ForEach-Object {
  $mailbox = $_.Name
  $stats = Get-ActiveSyncDeviceStatistics -Mailbox $mailbox
  $stats | Select-Object @{n="Mailbox";e={$mailbox}},
    LastSuccessSync,
    Status,
    DevicePhoneNumber,
    DeviceType
}
#
Export-ActiveSyncLog `
-Filename C:\inetpub\logs\LogFiles\W3SVC1\u_ex121214.log `
-OutputPath c:\report
#
$path = "C:\inetpub\logs\LogFiles\W3SVC1\"
Get-ChildItem -Path $path -Filter u_ex1212*.log | %{
  Export-ActiveSyncLog -Filename $_.fullname `
  -OutputPrefix $_.basename `
  -OutputPath c:\report
}
#Managing Transport Service
$Session = New-PSSession -ConfigurationName Microsoft.Exchange `
-ConnectionUri http://tlex01/PowerShell/ `
-Authentication Kerberos
Import-PSSession $Session
#Managing connectors
New-SendConnector -Name Internet `
-Usage Internet `
-AddressSpaces 'SMTP:*;1' `
-IsScopedConnector $false `
-DNSRoutingEnabled $false `
-SmartHosts smtp.contoso.com `
-SmartHostAuthMechanism None `
-UseExternalDNSServersEnabled $false `
-SourceTransportServers mb1
#
New-ReceiveConnector -Name 'Inbound from DMZ' `
-Usage 'Custom' `
-Bindings '192.168.1.245:25' `
-Fqdn mail.contoso.com `
-RemoteIPRanges '172.16.23.0/24' `
-PermissionGroups AnonymousUsers `
-Server cas1
#
Set-SendConnector -Identity Internet `
-AddressSpaces 'SMTP:*.litwareinc.com;5','SMTP:corp.contoso.com;10'
#
Get-SendConnector -Identity Internet | Format-List
#
Set-SendConnector -Identity Internet -Enabled $false
#
Remove-SendConnector -Identity Internet -Confirm:$false
#
Set-ReceiveConnector -Identity 'cas1\Inbound from DMZ' `
-Banner '220 SMTP OK' `
-MaxInboundConnection 2500 `
-ConnectionInactivityTimeout '00:02:30'
#
Get-ReceiveConnector -Identity 'cas1\Inbound from DMZ' | 
  Format-List
#
Set-ReceiveConnector -Identity 'cas1\Inbound from DMZ' `
-Enabled $false
#
Remove-ReceiveConnector -Identity 'cas1\Inbound from DMZ' `
-Confirm:$false
#Configuring transport limits
Set-Mailbox -Identity dsmith `
-MaxSendSize 10mb `
-MaxReceiveSize 10mb `
-RecipientLimits 100
#
Get-Mailbox -OrganizationalUnit contoso.com/Marketing | 
  Set-Mailbox -MaxSendSize 10mb `
  -MaxReceiveSize 20mb `
  -RecipientLimits 100
#
Set-TransportConfig -MaxReceiveSize 10mb `
-MaxRecipientEnvelopeLimit 1000 `
-MaxSendSize 10mb
#
Set-ReceiveConnector -Identity CAS1\Internet `
-MaxMessageSize 20mb `
-MaxRecipientsPerMessage 100
#
Get-ReceiveConnector -Identity *\Internet | 
  Set-ReceiveConnector -MaxMessageSize 20mb `
  -MaxRecipientsPerMessage 100
#
Set-SendConnector -Identity Internet -MaxMessageSize 5mb
#Allowing application servers to relay mail
New-ReceiveConnector -Name Relay `
-Usage Custom `
-Bindings '192.168.1.245:25' `
-Fqdn mail.contoso.com `
-RemoteIPRanges 192.168.1.110 `
-Server CAS1 `
-PermissionGroups ExchangeServers `
-AuthMechanism TLS, ExternalAuthoritative
#
New-ReceiveConnector -Name Relay `
-Usage Custom `
-Bindings '192.168.1.245:25' `
-Fqdn mail.contoso.com `
-RemoteIPRanges 192.168.1.110 `
-Server CAS1 `
-PermissionGroups AnonymousUsers
#
Get-ReceiveConnector CAS1\Relay | 
  Add-ADPermission -User "NT AUTHORITY\ANONYMOUS LOGON" `
  -ExtendedRights ms-Exch-SMTP-Accept-Any-Recipient
#
Set-ContentFilterConfig –BypassedSenders sending-user@contoso.com
Set-ContentFilterConfig –BypassedSenderDomains contoso.com
#Managing transport rules and settings
New-TransportRule -Name Confidential `
-Enabled $true `
-SubjectContainsWords Confidential `
-BlindCopyTo Administrator@contoso.com
#
New-TransportRule -Name ITSupport `
-Enabled $true `
-HeaderMatchesMessageHeader X-Department `
-HeaderMatchesPatterns ITSupport `
-AddToRecipients administrator@contoso.com
#
New-TransportRule -Name ITSupport `
-Enabled $true `
-HeaderMatchesMessageHeader X-Department `
-HeaderMatchesPatterns ITSupport `
-ExceptIfFrom administrator@contoso.com `
-AddToRecipients administrator@contoso.com
#
(Get-TransportRule Confidential).Conditions | Format-List
#
Get-TransportRule | Where-Object {$_.SubjectContainsWords}
#
Set-TransportRule –Identity Confidential `
-BlindCopyTo sysadmin@contoso.com
#
Set-TransportRule –Identity Confidential `
-BlindCopyTo $null `
-RedirectMessageTo sysadmin@contoso.com 
#
Set-TransportRule -Identity ITSupport -Priority 0
#
Disable-TransportRule -Identity Confidential -Confirm:$false
#
Enable-TransportRule -Identity Confidential
#
Remove-TransportRule -Identity Confidential -Confirm:$false
#
Get-DlpPolicyTemplate | select Name
#
New-DlpPolicy –Name "Block Credit Card" –Template "U.S. Financial Data" `
–Mode Enforce
#
New-TransportRule -Name "Override CEO" `
-DlpPolicy "Block Credit Card" `
-From "ceo@contoso.com" `
-SetHeaderName "X-Ms-Exchange-Organization-Dlp-SenderOverrideJustification" `
-SetHeaderValue "TransportRule override" `
-SetAuditSeverity Medium
#
Get-TransportRule | ?{$_.MessageContainsDataClassifications `
-notlike ""} | Set-TransportRule -GenerateIncidentReport dlp@contoso.com `
-IncidentReportOriginalMail IncludeOriginalMail
#Creating a basic disclaimer
New-TransportRule –Name Signature –ApplyHtmlDisclaimerLocation Append `
  –ApplyHtmlDisclaimerText "Best Regards<br><br>%%displayName%% |
    %% title %%<br>%%company%% | %%department%%<br>%%streetAddress%%<br>" `
      –FromScope InOrganization
#Working with custom DSN messages
New-SystemMessage -DSNCode 5.1.1 `
-Text "The mailbox you tried to send an e-mail message to 
does not exist. Please contact the Help Desk at extension 
4112 for assistance." `
-Internal $true `
-Language En
#
New-SystemMessage -DSNCode 5.1.1 `
-Text "The mailbox you tried to send an e-mail message to 
does not exist. Please visit the  
<a href='http://support.contoso.com'>help desk site</a>
forassitance" `
-Internal $true `
-Language En
#
Get-SystemMessage -Original
#
Set-SystemMessage -Identity 'en\Internal\5.1.1' `
-Text "Sorry, but this recipient is no longer available 
or does not exist."
#
Remove-SystemMessage -Identity 'en\Internal\5.1.1' -Confirm:$false
#
New-SystemMessage -QuotaMessageType WarningMailbox `
-Text "Your mailbox is getting too large. Please 
 delete some messages to free up space or call 
 the help desk at extention 3391." `
-Language En
#Managing connectivity and protocol logs
Get-TransportService -Identity ex01 | fl ConnectivityLog*
#
Set-TransportService -Identity ex01 `
-ConnectivityLogMaxAge 45 `
-ConnectivityLogMaxDirectorySize 5gb
#
Get-TransportService | 
  Set-TransportService -ConnectivityLogMaxAge 45 `
  -ConnectivityLogMaxDirectorySize 5gb
#
Set-TransportService –Identity mb1 `
-SendProtocolLogMaxAge 45 `
-ReceiveProtocolLogMaxAge 45
#
Set-SendConnector -Identity Internet -ProtocolLoggingLevel Verbose
#
Get-ReceiveConnector -Identity *\Relay | 
  Set-ReceiveConnector -ProtocolLoggingLevel Verbose
#
Set-TransportService -Identity mb1 `
-IntraOrgConnectorProtocolLoggingLevel Verbose
#
$logpath = (Get-TransportService -Identity mb1).ConnectivityLogPath
#
$data = $logs | %{
  Get-Content $_.Fullname | %{
    $IsHeaderParsed = $false
    if($_ -like '#Fields: *' -and !$IsHeaderParsed) {
      $_ -replace '^#Fields: '
      $IsHeaderParsed = $true
    }
    else {
      $_
    }
  } | ConvertFrom-Csv
}

$data | Where-Object{$_.description -like '*fail*'}
#Searching message tracking logs
Get-MessageTrackingLog -Server mb1 `
-Start (Get-Date).AddDays(-1) `
-End (Get-Date) `
-EventId Send
#
Get-TransportService | 
  Get-MessageTrackingLog -Start (Get-Date).AddDays(-1) `
  -End (Get-Date) `
  -EventId Send `
  -Sender dmsith@contoso.com
#
















































