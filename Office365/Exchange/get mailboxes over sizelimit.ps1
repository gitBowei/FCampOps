# -------------------------------------------------------------------------------
# Script: Get-MailboxesOverSizeLimit.ps1
# Author: Chris Brown
# Date: 04/04/2011 10:41:00
# Keywords:
# comments:
#
# Versioning
# 04/04/2011  CJB  Initial Script
#
# -------------------------------------------------------------------------------
 
# &#9829; &#9830; &#9827; &#9824; &#9829; &#9830; &#9827; &#9824; &#9829; &#9830; &#9827; &#9824; &#9829; &#9830; &#9827; &#9824; &#9829; &#9830; &#9827; &#9824; &#9829; &#9830; &#9827; &#9824; &#9829; &#9830; &#9827; &#9824; &#9829; &#9830; &#9827; &#9824; &#9829; &#9830; &#9827; &#9824; &#9829; &#9830; &#9827; &#9824; 
#                           ~ ~ ~ Variables ~ ~ ~ 
# ~~ Mail Server Details ~~
$SmtpServer = "mailserver.yourdomain.local"
$FromAddress = "alerts@yourdomain.com"
$ToAddress = "HelpDesk@yourdomain.com"
$Subject = "[Exchange] Mailboxes over size limits"
#
#
# &#9829; &#9830; &#9827; &#9824; &#9829; &#9830; &#9827; &#9824; &#9829; &#9830; &#9827; &#9824; &#9829; &#9830; &#9827; &#9824; &#9829; &#9830; &#9827; &#9824; &#9829; &#9830; &#9827; &#9824; &#9829; &#9830; &#9827; &#9824; &#9829; &#9830; &#9827; &#9824; &#9829; &#9830; &#9827; &#9824; &#9829; &#9830; &#9827; &#9824; 
 
if ( (Get-PSSnapin -Name Microsoft.Exchange.Management.PowerShell.E2010 -ErrorAction SilentlyContinue) -eq $null) {
        Write-Verbose "Exchange 2010 snapin is not loaded. Loading it now."
        try { Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010; Write-Verbose "Loaded Exchange 2010 snapin" }
        catch { Write-Error "Could not load Exchange 2010 snapins!"; }
}
 
$overLimit = Get-Mailbox -ResultSize unlimited| Get-MailboxStatistics -WarningAction SilentlyContinue | Where {"ProhibitSend","MailboxDisabled" -contains $_.StorageLimitStatus}
 
if ($overLimit.Count -gt 0) {
        $mailBody = $overLimit | ft DisplayName,TotalItemSize,StorageLimitStatus | Out-String
        Send-MailMessage -Body $mailBody.ToString() -From $FromAddress -SmtpServer $SmtpServer -Subject $Subject -To $toAddress
} else {
        "No results"
}

