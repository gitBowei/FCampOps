<#

 NAME: Invoke-BPAModeling.ps1

 AUTHOR: Jan Egil Ring
 EMAIL: jer@powershell.no

 COMMENT: Script to invoke Best Practices Analyzer on remote computers.
          Requires Windows Server 2008 R2 on target computers, and Windows PowerShell 2.0 on the computer running the script from.
          
          For more details, see the following blog-post:
          http://blog.powershell.no/2010/08/17/invoke-best-practices-analyzer-on-remote-servers-using-powershell

 You have a royalty-free right to use, modify, reproduce, and
 distribute this script file in any way you find useful, provided that
 you agree that the creator, owner above has no warranty, obligations,
 or liability for such use.

 VERSION HISTORY:
 1.0 16.08.2010 - Initial release
 
#>

#requires -version 2

#Import Active Directory module
Import-Module ActiveDirectory

#Initial variables, these must be customized
$servers = Get-ADComputer -LDAPFilter "(operatingsystem=*Windows Server 2008 R2*)" | select name,dnshostname
$SMTPServer = "smtp.domain.local"
$CSVReport = $true
$CSVReportPath = "\\server\share\BPAReports\"
$HTMLReport = $true
$HTMLReportPath = "\\server\share\BPAReports\"
$EMailReport = $true
$EMailReportTo = "it-operations@domain.local"
$EMailReportFrom = "bpa@domain.local"
$ReportAllSevereties = $false
$TotalComputers = ($servers | Measure-Object).Count
$CurrentComputer = 1


foreach ($server in $servers) {

$servername = $server.name

#Display progress
Write-Progress -Activity "Invoking BPA-model $BestPracticesModelId..." -Status "Current server: $servername" -Id 1 -PercentComplete (($CurrentComputer/$TotalComputers) * 100)

try {
Invoke-Command -Computer $server.dnshostname -ArgumentList $servername,$SMTPServer,$CSVReport,$CSVReportPath,$HTMLReport,$HTMLReportPath,$EMailReport,$EMailReportTo,$EMailReportFrom,$ReportAllSevereties -ScriptBlock {
param (
$servername,
$SMTPServer,
$CSVReport,
$CSVReportPath,
$HTMLReport,
$HTMLReportPath,
$EMailReport,
$EMailReportTo,
$EMailReportFrom,
$ReportAllSevereties)

#Import Server Manager module
Import-Module ServerManager

$ModelsToRun = @()

if ((Get-WindowsFeature Application-Server).Installed) {
$ModelsToRun += "Microsoft/Windows/ApplicationServer"
}

if ((Get-WindowsFeature AD-Certificate).Installed) {
$ModelsToRun += "Microsoft/Windows/CertificateServices"
}

if ((Get-WindowsFeature DHCP).Installed) {
$ModelsToRun += "Microsoft/Windows/DHCP"
}

if ((Get-WindowsFeature AD-Domain-Services).Installed) {
$ModelsToRun += "Microsoft/Windows/DirectoryServices"
}

if ((Get-WindowsFeature DNS).Installed) {
$ModelsToRun += "Microsoft/Windows/DNSServer"
}

if ((Get-WindowsFeature File-Services).Installed) {
$ModelsToRun += "Microsoft/Windows/FileServices"
}

if ((Get-WindowsFeature Hyper-V).Installed) {
$ModelsToRun += "Microsoft/Windows/Hyper-V"
}

if ((Get-WindowsFeature NPAS).Installed) {
$ModelsToRun += "Microsoft/Windows/NPAS"
}

if ((Get-WindowsFeature Remote-Desktop-Services).Installed) {
$ModelsToRun += "Microsoft/Windows/TerminalServices"
}

if ((Get-WindowsFeature Web-Server).Installed) {
$ModelsToRun += "Microsoft/Windows/WebServer"
}

if ((Get-WindowsFeature OOB-WSUS).Installed) {
$ModelsToRun += "Microsoft/Windows/WSUS"
}

foreach ($BestPracticesModelId in $ModelsToRun) {

#Path-variables
$date = Get-Date -Format "dd-MM-yy_HH-mm"
$BPAName = $BestPracticesModelId.Replace("Microsoft/Windows/","")
$CSVPath = $CSVReportPath+$servername+"-"+$BPAName+"-"+$date+".csv"
$HTMLPath = $HTMLReportPath+$servername+"-"+$BPAName+"-"+$date+".html"

#HTML-header
$Head = "
<title>BPA Report for $BestPracticesModelId on $servername</title>
<style type='text/css'> 
   table  { border-collapse: collapse; width: 700px } 
   body   { font-family: Arial } 
   td, th { border-width: 2px; border-style: solid; text-align: left; 
padding: 2px 4px; border-color: black } 
   th     { background-color: grey } 
   td.Red { color: Red } 
</style>" 

#Import Best Practices module
Import-Module BestPractices

#Invoke BPA Model
Invoke-BpaModel -BestPracticesModelId $BestPracticesModelId | Out-Null

#Include all severeties in BPA Report if enabled. If not, only errors and warnings are reported.
if ($ReportAllSevereties) {
$BPAResults = Get-BpaResult -BestPracticesModelId $BestPracticesModelId
}
else
{
$BPAResults = Get-BpaResult -BestPracticesModelId $BestPracticesModelId | Where-Object {$_.Severity -eq "Error" -or $_.Severity -eq “Warning” }
}

#Send BPA Results to CSV-file if enabled
if ($BPAResults -and $CSVReport) {
$BPAResults | ConvertTo-Csv -NoTypeInformation | Out-File -FilePath $CSVPath
}

#Send BPA Results to HTML-file if enabled
if ($BPAResults -and $HTMLReport) {
$BPAResults | ConvertTo-Html -Property Severity,Category,Title,Problem,Impact,Resolution,Help -Title "BPA Report for $BestPracticesModelId on $servername" -Body "BPA Report for $BestPracticesModelId on server $servername <HR>" -Head $head | Out-File -FilePath $HTMLPath
}

#Send BPA Results to e-mail if enabled
if ($BPAResults -and $EMailReport) {
$CSVReportAttachment = $env:temp+"\"+$servername+"-"+$BPAName+"-"+$date+".csv"
$HTMLReportAttachment = $env:temp+"\"+$servername+"-"+$BPAName+"-"+$date+".html"
$BPAResults | ConvertTo-Csv -NoTypeInformation | Out-File -FilePath $CSVReportAttachment
$BPAResults | ConvertTo-Html -Property Severity,Category,Title,Problem,Impact,Resolution,Help -Title "BPA Report for $BestPracticesModelId on $servername" -Body "BPA Report for $BestPracticesModelId on server $servername <HR>" -Head $head | Out-File -FilePath $HTMLReportAttachment
Send-MailMessage -From $EMailReportFrom -SmtpServer $SMTPServer -To $EMailReportTo -Subject "BPA Results for $servername"  -Body "The BPA Result for $BestPracticesModelId on $servername are attached to this message" -Attachment $CSVReportAttachment,$HTMLReportAttachment
Remove-Item $CSVReportAttachment
Remove-Item $HTMLReportAttachment
}
}
}
}

#Catch PS Remoting transport errors
catch [PSRemotingTransportException]{
Write-Host "Unable to connect to $servername. The following error occured:" -ForegroundColor red -BackgroundColor black
Write-Host ($error[0]).errordetails.message -ForegroundColor red -BackgroundColor black
}

#Catch other errors (errors from remote scriptblock commands won`t be captured here, they will be returned like default)
catch {
Write-Host "An error occured when connecting to $servername. The following error occured:" -ForegroundColor red -BackgroundColor black
Write-Host ($error[0]).errordetails.message -ForegroundColor red -BackgroundColor black
}

#Increase current computer variable for Write-Progress
$CurrentComputer ++
}