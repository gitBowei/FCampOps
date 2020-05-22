$Log = “System” 
$Type = “Warning” 
$LogEntries = Get-EventLog $Log $LogEntries | ForEach-Object { If ($_.EntryType –eq $Type) { Write-Output “The following was found in the event log” Write-Output $_.TimeGenerated Write-Output $_.Source Write-Output $_.Message } }
