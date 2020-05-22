<#
NAME
 Get-ExchangeDAGReplicationReport.ps1
AUTHOR
 Zachary Loeber
DATE
 11/16/2012
EMAIL
 zloeber@gmail.com
SITE(S)
 http://gallery.technet.microsoft.com/scriptcenter/Exchange-DAG-Replication-d8e99705
 http://www.the-little-things.net
COMMENT 
Generates a color coded HTML report of Database replication status in Exchange 2010
  
The resulting report contains 2 sections; the current mounted databases, and the database replication status
The database replication attributes displayed are:
 Server Name
 Database Name
 Active Copy State
 Copy Queue Length
 Replay Queue Length
 Content Index State
You can optionally change replay and copy queue warning (yellow) and alert (red) thresholds.
This script is based on two others which I mashed together:
 Script: Exchange 2010 Architecture Report
 Author: Franck Nérot
 Site: http://gallery.technet.microsoft.com/scriptcenter/Exchange-2010-Architecture-9368ff56/view/Discussions#content
   
 Script: Test Exchange Server Health
 Author: Paul Cunningham
 Site: http://exchangeserverpro.com
VERSION HISTORY
0.2 - 11/19/2012
  - Added more DAG copy status codes from
    http://technet.microsoft.com/en-us/library/dd351258.aspx
  - Added the CI database crawling code
0.1 - 11/16/2012
      - Initial version
#>
#region Parameters
[CmdletBinding()]
param
(
 [Parameter(Position=0,Mandatory=$false,ValueFromPipeline=$false,ValueFromPipelineByPropertyName=$true)]
 [String]$EmailRelay = ".",  
 [Parameter(Position=1,Mandatory=$false,ValueFromPipeline=$false,ValueFromPipelineByPropertyName=$true)]
 [String]$EmailSender='systemreport@localhost',
 [Parameter(Position=2,Mandatory=$false,ValueFromPipeline=$false,ValueFromPipelineByPropertyName=$true)]
 [String]$EmailRecipient='default@yourdomain.com',
 [Parameter(Position=3,Mandatory=$false,ValueFromPipeline=$false,ValueFromPipelineByPropertyName=$true)]
 [Bool[]]$SendMail=$false,
 [Parameter(Position=4,Mandatory=$false,ValueFromPipeline=$false,ValueFromPipelineByPropertyName=$true)]
 [Bool[]]$SaveReport=$true,
 [Parameter(Position=5,Mandatory=$false,ValueFromPipeline=$false,ValueFromPipelineByPropertyName=$true)]
 [String]$ReportName=".\ExchangeDAGReplicationReport.html"
)
#endregion Parameters
#region Module/Snapin/Dot Sourcing
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010 -ErrorAction SilentlyContinue
# REQUIREMENTS
#endregion Module/Snapin/Dot Sourcing
 
#region Help
<#
.SYNOPSIS
   Generates a color coded HTML report of Database replication status in Exchange 2010
  
.DESCRIPTION
 The resulting report contains 2 sections; the current mounted databases, and the database replication status
 The database replication attributes displayed are:
  Server Name
  Database Name
  Active Copy State
  Copy Queue Length
  Replay Queue Length
  Content Index State
 
 You can optionally change replay and copy queue warning (yellow) and alert (red) thresholds.
.PARAMETER EmailRelay
Server to send email report though. Not a requirement and ignored if SendMail is false.
If SendMail is true and this is not set it defaults to the localhost.
.PARAMETER EmailSender
Not required. If SendMail is true and this is not set it defaults to systemreport@localhost
.PARAMETER EmailRecipient
Not required. SendMail is true this will need to be modified. By default this is set to be default@yourdomain.com
.PARAMETER SendMail
Not required. By default this is false.
.PARAMETER SaveReport
Not required. By default this is false.
.PARAMETER ReportName
Not required. By default this is set to ExchangeDAGReplicationReport.html
.EXAMPLE
 Save a report in the current location (default name is ExchangeDAGReplicationReport.html)
    .\Get-ExchangeDAGReplicationReport.ps1 -SaveReport $true
.LINK
http://www.the-little-things.net
.LINK
http://gallery.technet.microsoft.com/scriptcenter/Exchange-DAG-Replication-d8e99705
#>
#endregion help
#region Functions
function Get-ScriptDirectory
{
 if($hostinvocation -ne $null)
 {
  Split-Path $hostinvocation.MyCommand.path
 }
 else
 {
  Split-Path $script:MyInvocation.MyCommand.Path
 }
}
function Get-TableHeader
{
 param
 (
  [Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)] 
  [Alias('DAG Name')]
  [String]$DAGName
 )
 $htmltableheader = "<h3>$DAGName Health</h3>
     <p>
     <table>
     <tr>
     <th>Server</th>"
 
 ## Put meat of function here
 
 $htmltableheader += "</tr>"
 return $htmltableheader
}
#endregion functions
#region Configuration
## Environment Specific - Change these if you like ##
$ReplayQueueWarn = 20
$ReplayQueueAlert = 50
$CopyQueueWarn = 20
$CopyQueueAlert = 50
# For the most part just leave these alone
$now = Get-Date           #Used for timestamps
$date = $now.ToShortDateString()      #Short date format for email message subject
$pass = "Green"
$warn = "Yellow"
$fail = "Red"
$htmlHead="<html>
   
   BODY{font-family: Arial; font-size: 8pt;}
   H1{font-size: 16px;}
   H2{font-size: 14px;}
   H3{font-size: 12px;}
   TABLE{border: 1px solid black; border-collapse: collapse; font-size: 8pt;}
   TH{border: 1px solid black; background: #dddddd; padding: 5px; color: #000000;}
   TD{border: 1px solid black; padding: 5px; }
   td.pass{background: #7FFF00;}
   td.warn{background: #FFE600;}
   td.fail{background: #FF0000; color: #ffffff;}
   
   <body>
   <h1 align=""center"">Exchange 2010 DAG Database Replication Report</h1>
   <h3 align=""center"">Generated: $now</h3>"
$htmlMountedDatabases = "<h3>Exchange 2010 Mounted Database Summary</h3>
    <p>
    <table>
    <tr>
    <th>Database</th>
    <th>Status</th>
    <th>Active Database Copy</th>
    <th>Activation Suspended</th>
    <th>Outgoing Connections</th>
    </tr>"
$htmlDatabaseCopies = "<h3>Exchange 2010 DAG Database Replication Status</h3>
     <p>
     <table>
     <tr>
     <th>Server Name</th>
     <th>Database Name</th>
     <th>Active Copy</th>
     <th>State</th>
     <th>Copy Queue Length</th>
     <th>Replay Queue Length</th>
     <th>Content Index State</th>
     </tr>"
$htmlTail = "</table></p>
   </body>
   </html>"
$MountedDatabases = [PSObject]@()
$ReplicatedDatabases = [PSObject]@()
#endregion configuration
#region Main Script
#Set recipient scope
if (!(Get-ADServerSettings).ViewEntireForest)
{
 Set-ADServerSettings -ViewEntireForest $true -WarningAction SilentlyContinue
}
# Mounted Databases
$MDCSCSS = get-mailboxserver | where-object{$_.AdminDisplayVersion.major -ge "14" -AND $_.DatabaseAvailabilityGroup -ne $null} | Get-MailboxDatabaseCopyStatus -ConnectionStatus | ?{$_.activecopy -eq "True"}
foreach($MDCSCS in $MDCSCSS)
{
 #Custom object properties
 $serverObj = New-Object PSObject
 $serverObj | Add-Member NoteProperty -Name "Database" -Value $MDCSCS.Name
 $serverObj | Add-Member NoteProperty -Name "Status" -Value $MDCSCS.Status
 $serverObj | Add-Member NoteProperty -Name "ActiveDatabaseCopy" -Value $MDCSCS.ActiveCopy
 $serverObj | Add-Member NoteProperty -Name "ActivationSuspended" $MDCSCS.ActivationSuspended
 $serverObj | Add-Member NoteProperty -Name "OutgoingConnections" -Value $MDCSCS.OutgoingConnections
 $MountedDatabases += $serverObj
}
# Replicated Databases
$MailboxDatabasesList = (Get-MailboxDatabase -status | where-object{$_.ReplicationType -eq "Remote"} | sort Name | Get-MailboxDatabaseCopyStatus)
foreach($Database in $MailboxDatabasesList)
{
 $serverObj = New-Object PSObject
 $serverObj | Add-Member NoteProperty -Name "ServerName" -Value $Database.MailboxServer
 $serverObj | Add-Member NoteProperty -Name "DatabaseName" -Value $Database.DatabaseName
 $serverObj | Add-Member NoteProperty -Name "ActiveCopy" -Value $Database.ActiveCopy.ToString()
 $serverObj | Add-Member NoteProperty -Name "Status" $Database.Status.ToString()
 $serverObj | Add-Member NoteProperty -Name "ReplayQueueLength" -Value $Database.ReplayQueueLength
 $serverObj | Add-Member NoteProperty -Name "CopyQueueLength" -Value $Database.CopyQueueLength
 $serverObj | Add-Member NoteProperty -Name "ContentIndexState" -Value $Database.ContentIndexState
 $ReplicatedDatabases += $serverObj
}
# Generate the mounted databases report
foreach ($Mounted in $MountedDatabases)
{
 $htmltablerow = "<tr>"
 $htmltablerow = $htmltablerow + "<td>$($Mounted.Database)</td>"
 $htmltablerow = $htmltablerow + "<td>$($Mounted.Status)</td>"
 $htmltablerow = $htmltablerow + "<td>$($Mounted.ActiveDatabaseCopy)</td>"
 $htmltablerow = $htmltablerow + "<td>$($Mounted.ActivationSuspended)</td>"
 $htmltablerow = $htmltablerow + "<td>$($Mounted.OutgoingConnections)</td>"
 $htmlMountedDatabases += $htmltablerow
}
$htmlMountedDatabases += "</table></p>"
# Generate the database copy report
foreach ($reportline in $ReplicatedDatabases)
{
 $htmltablerow = "<tr>"
 $htmltablerow += "<td>$($reportline.ServerName)</td>"
 $htmltablerow += "<td>$($reportline.DatabaseName)</td>"
 $htmltablerow += "<td>$($reportline.ActiveCopy)</td>"    
     
 switch ($($reportline.Status))
 {
  "Healthy" {$htmltablerow += "<td class=""pass"">$($reportline.Status)</td>"}
  "Mounted" {$htmltablerow += "<td class=""pass"">$($reportline.Status)</td>"}
  "Seeding" {$htmltablerow += "<td class=""warn"">$($reportline.Status)</td>"}
  "SeedingSource" {$htmltablerow += "<td class=""warn"">$($reportline.Status)</td>"}
  "Suspended" {$htmltablerow += "<td class=""fail"">$($reportline.Status)</td>"}
  "ServiceDown" {$htmltablerow += "<td class=""fail"">$($reportline.Status)</td>"}
  "Initializing" {$htmltablerow += "<td class=""warn"">$($reportline.Status)</td>"}
  "Resynchronizing" {$htmltablerow += "<td class=""warn"">$($reportline.Status)</td>"}
  "Dismounted" {$htmltablerow += "<td class=""fail"">$($reportline.Status)</td>"}
  "Mounting" {$htmltablerow += "<td class=""warn"">$($reportline.Status)</td>"}
  "Dismounting" {$htmltablerow += "<td class=""fail"">$($reportline.Status)</td>"}
  "DisconnectedAndHealthy" {$htmltablerow += "<td class=""warn"">$($reportline.Status)</td>"}
  "DisconnectedAndResynchronizing" {$htmltablerow += "<td class=""warn"">$($reportline.Status)</td>"}
  "FailedAndSuspended" {$htmltablerow += "<td class=""fail"">$($reportline.Status)</td>"}
  "SinglePageRestore" {$htmltablerow += "<td class=""warn"">$($reportline.Status)</td>"}
  default {$htmltablerow += "<td class=""fail"">$($reportline.Status)</td>"}
 }
 
 # Copy queue checks
 if ($($reportline."CopyQueueLength") -ge $CopyQueueAlert)
 {
  $htmltablerow += "<td class=""fail"">$($reportline.CopyQueueLength)</td>"  
 }
 elseif ($($reportline."CopyQueueLength") -ge $CopyQueueWarn)
 {
  $htmltablerow += "<td class=""warn"">$($reportline.CopyQueueLength)</td>" 
 }
 else
 {
  $htmltablerow += "<td class=""pass"">$($reportline.CopyQueueLength)</td>" 
 }
 
 # Replay queue checks
 if ($($reportline."ReplayQueueLength") -ge $ReplayQueueAlert)
 {
  $htmltablerow += "<td class=""fail"">$($reportline.ReplayQueueLength)</td>"  
 }
 elseif ($($reportline."ReplayQueueLength") -ge $ReplayQueueWarn)
 {
  $htmltablerow += "<td class=""warn"">$($reportline.ReplayQueueLength)</td>" 
 }
 else
 {
  $htmltablerow += "<td class=""pass"">$($reportline.ReplayQueueLength)</td>" 
 }
 
 switch ($($reportline.ContentIndexState))
 {
  "Healthy" {$htmltablerow += "<td class=""pass"">$($reportline.ContentIndexState)</td>"}
  "Crawling" {$htmltablerow += "<td class=""warn"">$($reportline.ContentIndexState)</td>"}
  default {$htmltablerow += "<td class=""fail"">$($reportline.ContentIndexState)</td>"}
 }
 $htmltablerow +="</tr>"
 $htmlDatabaseCopies += $htmltablerow 
}
#  Final Report
$ReportOutput = $htmlHead + $htmlMountedDatabases + $htmlDatabaseCopies + $htmltail
if ($SendMail -or $SaveReport)
{
 # Send an email
 if ($SendMail)
 {
  $HTMLmessage = $ReportOutput | Out-String
  $email=
  @{
   From = $EmailSender
   To = $EmailRecipient
 #  CC = "EMAIL@EMAIL.COM"
   Subject = "Exchange DAG Database Replication Report"
   SMTPServer = $EmailRelay
   Body = $HTMLmessage
   Encoding = ([System.Text.Encoding]::UTF8)
   BodyAsHTML = $true
  }
  Send-MailMessage @email
  Sleep -Milliseconds 200
 }
 
 # Save a report
 if ($SaveReport)
 {
  $ReportOutput | Out-File $ReportName
 }
}
else
{
   Return $HTMLmessage
}
#endregion Main Script
