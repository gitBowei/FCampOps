#Original by mjolinor - 02/24/2011 
#Modified by SNapEl - 14 Aug 2015 
 
#requires -version 2.0 
 
Param( 
  [Int]$StartSearch = 1, 
  [String]$TargetEmailAddress = $NULL 
) 
 
Add-PSSnapin *exchange* 
 
$today = get-date 
$rundate = $($today.adddays(-1))#.toshortdatestring() 
 
$startsearchdate = $($today.adddays(-1*$StartSearch)).toshortdatestring() 
 
$outfile_date = ($today.adddays(-1)).tostring("yyyy_MM_dd") 
$outfile = "EmailStats_" + $outfile_date + "_" + $StartSearch + "Days.csv" 
 
#$dl_stat_file = "DistListStats_" + $outfile_date + "_" + $StartSearch + "Days.csv" 
$dl_stat_file = "MTDistListStat.csv" 
 
$accepted_domains = Get-AcceptedDomain |% {$_.domainname.domain} 
[regex]$dom_rgx = "`(?i)(?:" + (($accepted_domains |% {"@" + [regex]::escape($_)}) -join "|") + ")$" 
 
$mbx_servers = Get-ExchangeServer |? {$_.serverrole -match "Mailbox"}|% {$_.fqdn} 
[regex]$mbx_rgx = "`(?i)(?:" + (($mbx_servers |% {"@" + [regex]::escape($_)}) -join "|") + ")\>$" 
 
$msgid_rgx = "^\<.+@.+\..+\>$" 
 
$hts = Get-TransportService | % {$_.name} 
 
$MaxThreads = $hts.count 
$RunspacePool = [RunspaceFactory]::CreateRunspacePool(1,$MaxThreads) 
$Jobs = @() 
$messagetrackinglogresults = @() 
 
$TotalLogsCollected = 0 
 
$exch_addrs = @{} 
 
$msgrec = @{} 
$bytesrec = @{} 
 
$msgrec_exch = @{} 
$bytesrec_exch = @{} 
 
$msgrec_smtpext = @{} 
$bytesrec_smtpext = @{} 
 
$total_msgsent = @{} 
$total_bytessent = @{} 
$unique_msgsent = @{} 
$unique_bytessent = @{} 
 
$total_msgsent_exch = @{} 
$total_bytessent_exch = @{} 
$unique_msgsent_exch = @{} 
$unique_bytessent_exch = @{} 
 
$total_msgsent_smtpext = @{} 
$total_bytessent_smtpext = @{} 
$unique_msgsent_smtpext=@{} 
$unique_bytessent_smtpext = @{} 
 
$dl = @{} 
$dlSince = @{} 
$dlLastUsed = @{} 
$dlPreviousSince = @{} 
$dlPreviousLastUsed = @{} 
 
$obj_table = { 
@" 
Date = $($rundate.toshortdatestring()) 
User = $($address.split("@")[0]) 
Domain = $($address.split("@")[1]) 
Sent Items Total = $(0 + $total_msgsent[$address]) 
Sent MB Total = $("{0:F2}" -f $($total_bytessent[$address]/1mb)) 
Received Items Total = $(0 + $msgrec[$address]) 
Received MB Total = $("{0:F2}" -f $($bytesrec[$address]/1mb)) 
Average Total Items per Day = $("{0:F2}" -f $((0 + $total_msgsent[$address] + $msgrec[$address])/$StartSearch)) 
Average Total MB per Day = $("{0:F2}" -f $((($bytesrec[$address]/1mb) + ($total_bytessent[$address]/1mb))/$StartSearch)) 
Sent Items Internal = $(0 + $total_msgsent_exch[$address]) 
Sent Internal MB = $("{0:F2}" -f $($total_bytessent_exch[$address]/1mb)) 
Sent Items External = $(0 + $total_msgsent_smtpext[$address]) 
Sent External MB = $("{0:F2}" -f $($total_bytessent_smtpext[$address]/1mb)) 
Received Items Internal = $(0 + $msgrec_exch[$address]) 
Received Internal MB = $("{0:F2}" -f $($bytesrec_exch[$address]/1mb)) 
Received Items External = $(0 + $msgrec_smtpext[$address]) 
Received External MB = $("{0:F2}" -f $($bytesrec_smtpext[$address]/1mb)) 
Sent Unique Items Total = $(0 + $unique_msgsent[$address]) 
Sent Unique MB Total = $("{0:F2}" -f $($unique_bytessent[$address]/1mb)) 
Sent Internal Unique Items  = $(0 + $unique_msgsent_exch[$address])  
Sent Internal Unique MB = $("{0:F2}" -f $($unique_bytessent_exch[$address]/1mb)) 
Sent External Unique Items = $(0 + $unique_msgsent_smtpext[$address]) 
Sent External Unique MB = $("{0:F2}" -f $($unique_bytessent_smtpext[$address]/1mb)) 
"@ 
} 
 
$props = $obj_table.ToString().Split("`n")|% {if ($_ -match "(.+)="){$matches[1].trim()}} 
 
$stat_recs = @() 
 
function time_pipeline { 
    param ( 
        [int]$increment  = 1000 
    ) 
    begin{$i=0;$timer = [diagnostics.stopwatch]::startnew();$previousSecond=0} 
    process { 
        $i++ 
        #if (!($i % $increment)){Write-host “`r$ht - Processed $i at $($timer.elapsed.totalseconds) seconds"} 
        if ($timer.elapsed.Seconds -notlike $previousSecond){ 
            Write-Progress -Activity "Summarizing Message Tracking Logs" -status “Processed $i records at $(if($timer.elapsed.Hours){"$($timer.elapsed.Hours) Hours "})$(if($timer.elapsed.Minutes){"$($timer.elapsed.Minutes) Mins "})$(if($timer.elapsed.Seconds){"$($timer.elapsed.Seconds) Seconds"})” -PercentComplete (($i / $messagetrackinglogresults.count)  * 100) 
            $previousSecond = $timer.elapsed.Seconds 
        } 
 
        $_ 
    } 
    end { 
        write-host “Processed $i log records in $(if($timer.elapsed.Hours){"$($timer.elapsed.Hours) Hours "})$(if($timer.elapsed.Minutes){"$($timer.elapsed.Minutes) Mins "})$(if($timer.elapsed.Seconds){"$($timer.elapsed.Seconds) Secs"}else{"$($timer.elapsed.milliseconds) ms"})” 
        Write-Host "   Average rate: $([int]($i/$timer.elapsed.totalseconds)) log recs/sec.`n" 
    } 
} 
 
$MTScriptBlock = { 
     
    Param( 
        $MTTargetServer = $NULL, 
        $MTstartsearchdate = $NULL, 
        $MTTargetSender = $NULL, 
        $MTTargetRecipient = $NULL 
    ) 
 
    Add-PSSnapin *Exchange* 
    get-messagetrackinglog -EventID "Deliver" -Server $MTTargetServer -Start "$MTstartsearchdate 00:00:00" -End "$MTstartsearchdate 23:59:59" -Sender $MTTargetSender -Recipients $MTTargetRecipient -resultsize unlimited 
    get-messagetrackinglog -EventID "Receive" -Server $MTTargetServer -Start "$MTstartsearchdate 00:00:00" -End "$MTstartsearchdate 23:59:59" -Sender $MTTargetSender -Recipients $MTTargetRecipient -resultsize unlimited 
    get-messagetrackinglog -EventID "Expand" -Server $MTTargetServer -Start "$MTstartsearchdate 00:00:00" -End "$MTstartsearchdate 23:59:59" -Sender $MTTargetSender -Recipients $MTTargetRecipient -resultsize unlimited 
} 
 
$ProcessEmailStats = { 
    if ($_.eventid -eq "DELIVER" -and $_.source -eq "STOREDRIVER"){ 
     
        if ($_.messageid -match $mbx_rgx -and $_.sender -match $dom_rgx) { 
             
            $total_msgsent[$_.sender] += $_.recipientcount 
            $total_bytessent[$_.sender] += ($_.recipientcount * $_.totalbytes) 
            $total_msgsent_exch[$_.sender] += $_.recipientcount 
            $total_bytessent_exch[$_.sender] += ($_.totalbytes * $_.recipientcount) 
         
            foreach ($rcpt in $_.recipients){ 
                $exch_addrs[$rcpt] ++ 
                $msgrec[$rcpt] ++ 
                $bytesrec[$rcpt] += $_.totalbytes 
                $msgrec_exch[$rcpt] ++ 
                $bytesrec_exch[$rcpt] += $_.totalbytes 
            } 
        } 
 
        else { 
            if ($_messageid -match $messageid_rgx){ 
                foreach ($rcpt in $_.recipients){ 
                    $msgrec[$rcpt] ++ 
                    $bytesrec[$rcpt] += $_.totalbytes 
                    $msgrec_smtpext[$rcpt] ++ 
                    $bytesrec_smtpext[$rcpt] += $_.totalbytes 
                } 
            } 
         
        } 
                 
    } 
     
     
    if ($_.eventid -eq "RECEIVE" -and $_.source -eq "STOREDRIVER"){ 
        $exch_addrs[$_.sender] ++ 
        $unique_msgsent[$_.sender] ++ 
        $unique_bytessent[$_.sender] += $_.totalbytes 
         
        if ($_.recipients -match $dom_rgx){ 
            $unique_msgsent_exch[$_.sender] ++ 
            $unique_bytessent_exch[$_.sender] += $_.totalbytes 
        } 
 
        if ($_.recipients -notmatch $dom_rgx){ 
            $ext_count = ($_.recipients -notmatch $dom_rgx).count 
            $unique_msgsent_smtpext[$_.sender] ++ 
            $unique_bytessent_smtpext[$_.sender] += $_.totalbytes 
            $total_msgsent[$_.sender] += $ext_count 
            $total_bytessent[$_.sender] += ($ext_count * $_.totalbytes) 
            $total_msgsent_smtpext[$_.sender] += $ext_count 
             $total_bytessent_smtpext[$_.sender] += ($ext_count * $_.totalbytes) 
        } 
    } 
     
 
    if ($_.eventid -eq "expand"){ 
         
        if($dl[$_.relatedrecipientaddress]) { 
             if(($($_.TimeStamp).date -lt $dlPreviousSince[$_.relatedrecipientaddress]) -or ($($_.TimeStamp).date -gt $dlPreviousLastUsed[$_.relatedrecipientaddress])) { 
                $dl[$_.relatedrecipientaddress] ++ 
            } 
        } 
        else { 
            $dl[$_.relatedrecipientaddress] ++ 
        } 
 
        if (!$dlSince[$_.relatedrecipientaddress]) { 
            $dlSince[$_.relatedrecipientaddress] = $_.TimeStamp 
            $dlLastUsed[$_.relatedrecipientaddress] = $_.TimeStamp 
        } 
        elseif ($_.TimeStamp -lt $dlSince[$_.relatedrecipientaddress]){ 
            $dlSince[$_.relatedrecipientaddress] = $_.TimeStamp 
        } 
        elseif ($_.TimeStamp -gt $dlSince[$_.relatedrecipientaddress]){ 
            $dlLastUsed[$_.relatedrecipientaddress] = $_.TimeStamp 
        } 
    } 
 
} 
 
if (Test-Path $dl_stat_file){ 
    $DL_stats = Import-Csv $dl_stat_file 
    $dl_list = $dl_stats | % {$_.address} 
 
    $DL_stats | % { 
        $dl[$_.address] = [int]$_.used 
        $dlPreviousSince[$_.address] = [DateTime]::ParseExact($_.Since,"dd/MM/yyyy",[System.Globalization.CultureInfo]::InvariantCulture) 
        $dlPreviousLastUsed[$_.address] = [DateTime]::ParseExact($_.lastused,"dd/MM/yyyy",[System.Globalization.CultureInfo]::InvariantCulture) 
        $dlSince[$_.address] = $dlPreviousSince[$_.address] 
        $dlLastUsed[$_.address] = $dlPreviousLastUsed[$_.address] 
    } 
} 
else { 
    $dl_list = @() 
    $DL_stats = @() 
} 
 
$RunspacePool.Open() 
 
$timer = [diagnostics.stopwatch]::startnew() 
$StartSearchCounter = 0 
Do { 
 
    $Jobs = @() 
    $StartSearchCounter++ 
    $startsearchdate = $($today.adddays(-1*$StartSearchCounter)).toshortdatestring() 
     
    #Do search 
                 
    If ($TargetEmailAddress -like $NULL) { 
        ForEach ($ht in $hts) { 
 
            Write-Host "Starting Runspace - Processing $ht" 
            Write-Host "Retrieving all mailboxes statistics for $startsearchdate, the past $StartSearchCounter days" 
 
            $MTParam = @{ 
                "MTTargetServer" = $ht; 
                "MTstartsearchdate" = $startsearchdate; 
            } 
 
            $Job = [powershell]::Create().AddScript($MTScriptBlock) 
         
            foreach ($key in $MTParam.Keys) { 
                $Job.AddParameter($key,$MTParam.$key) | Out-Null 
            } 
 
            $Job.RunspacePool = $RunspacePool 
            $Jobs += New-Object PSObject -Property @{ 
                Pipe = $Job 
                Result = $Job.BeginInvoke() 
            } 
        } 
    } 
    Else { 
        $outfile = "UserEmailStats_" + $outfile_date + "_" + $StartSearch + "Days.csv" 
 
        ForEach ($ht in $hts) { 
 
            Write-Host "Starting Runspace - Processing $ht" 
            write-host "Retrieving $TargetEmailAddress sender statistics for $startsearchdate, the past $StartSearchCounter days" 
 
            $MTParam = @{ 
                "MTTargetServer" = $ht; 
                "MTstartsearchdate" = $startsearchdate; 
                "MTTargetSender" = $TargetEmailAddress; 
                "MTTargetRecipient" = $NULL; 
            } 
 
            $Job = [powershell]::Create().AddScript($MTScriptBlock) 
         
            foreach ($key in $MTParam.Keys) { 
                $Job.AddParameter($key,$MTParam.$key) | Out-Null 
            } 
 
            $Job.RunspacePool = $RunspacePool 
            $Jobs += New-Object PSObject -Property @{ 
                Pipe = $Job 
                Result = $Job.BeginInvoke() 
            } 
        } 
        ForEach ($ht in $hts) { 
             
            Write-Host "Starting Runspace - Processing $ht" 
            write-host "Retrieving $TargetEmailAddress recipient statistics for $startsearchdate, the past $StartSearchCounter days" 
 
            $MTParam = @{ 
                "MTTargetServer" = $ht; 
                "MTstartsearchdate" = $startsearchdate; 
                "MTTargetSender" = $NULL; 
                "MTTargetRecipient" = $TargetEmailAddress; 
            } 
 
            $Job = [powershell]::Create().AddScript($MTScriptBlock) 
         
            foreach ($key in $MTParam.Keys) { 
                $Job.AddParameter($key,$MTParam.$key) | Out-Null 
            } 
 
            $Job.RunspacePool = $RunspacePool 
            $Jobs += New-Object PSObject -Property @{ 
                Pipe = $Job 
                Result = $Job.BeginInvoke() 
            } 
        } 
    } 
 
    If ($messagetrackinglogresults.Count -gt 0) { 
        write-host "Concurrently generating mailbox statistics for $($($today.adddays(-1*($StartSearchCounter-1))).toshortdatestring())" 
        $messagetrackinglogresults | time_pipeline 100 | %{ &$ProcessEmailStats } 
         
        write-host "Generation Complete." 
        $messagetrackinglogresults = @() 
    } 
 
    Do { 
        Write-Progress -Activity "Waiting for Jobs to Complete" -status “Runtime: $(if($timer.elapsed.Hours){"$($timer.elapsed.Hours) Hours "})$(if($timer.elapsed.Minutes){"$($timer.elapsed.Minutes) Mins "})$(if($timer.elapsed.Seconds){"$($timer.elapsed.Seconds) Seconds"})” 
        Start-Sleep -Seconds 1 
    } While ( $Jobs.Result.IsCompleted -contains $false ) 
 
    Write-Host "Jobs completed!"  
 
    ForEach ($Job in $Jobs) { 
        $messagetrackinglogresults += $Job.Pipe.EndInvoke($Job.Result) 
        $Job.Pipe.Dispose() 
    } 
 
    $TotalLogsCollected += $messagetrackinglogresults.count 
 
    Write-Host $messagetrackinglogresults.count "message tracking logs collected" 
    Write-Host "Total Logs:" $TotalLogsCollected 
         
    If ($StartSearchCounter -eq $StartSearch) { 
        write-host "Generating mailbox statistics for final job collection for $startsearchdate" 
        $messagetrackinglogresults | time_pipeline 100 | %{ &$ProcessEmailStats } 
 
        write-host "Generation Complete." 
        $messagetrackinglogresults = @() 
    } 
} While ( $StartSearchCounter -lt $StartSearch ) 
 
foreach ($address in $exch_addrs.keys){ 
 
    $stat_rec = (new-object psobject -property (ConvertFrom-StringData (&$obj_table))) 
    $stat_recs += $stat_rec | select $props 
} 
 
$stat_recs | export-csv $outfile -notype  
 
$RunspacePool.Close() | Out-Null 
$RunspacePool.Dispose() | Out-Null 
 
If ($TargetEmailAddress -like $NULL) { 
    $DL_stats | % { 
        if ($dl[$_.address]){ 
         
            $_.used = [int]$dl[$_.address] 
 
            if ([DateTime]::ParseExact($_.lastused,"dd/MM/yyyy",[System.Globalization.CultureInfo]::InvariantCulture) -lt $dlLastUsed[$_.address]){ 
                $_.lastused = $dlLastUsed[$_.address].ToShortDateString() 
            } 
            if ([DateTime]::ParseExact($_.Since,"dd/MM/yyyy",[System.Globalization.CultureInfo]::InvariantCulture) -gt $dlSince[$_.address]){ 
                $_.Since = $dlSince[$_.address].toshortdatestring() 
            } 
        } 
    } 
 
    $dl.keys |% { 
        if ($dl_list -notcontains $_){ 
            $new_rec = "" | select Address,Used,Since,LastUsed 
            $new_rec.address = $_ 
            $new_rec.used = $dl[$_] 
            $new_rec.Since = $dlSince[$_].ToShortDateString() 
            $new_rec.lastused = $dlLastUsed[$_].ToShortDateString() 
            $dl_stats += @($new_rec) 
        } 
    } 
 
    $dl_stats | Export-Csv $dl_stat_file -NoTypeInformation -force 
} 
 
$TotalRunTime = (get-date) - $today 
 
Write-Host "`nRun time was $(if($TotalRunTime.Hours){"$($TotalRunTime.Hours) Hours "})$(if($TotalRunTime.Minutes){"$($TotalRunTime.Minutes) Mins "})$(if($TotalRunTime.Seconds){"$($TotalRunTime.Seconds) Seconds"})" 
Write-Host $TotalLogsCollected "message tracking logs processed" 
Write-Host "Email stats file is $outfile" 
Write-Host "DL usage stats file is $dl_stat_file" 