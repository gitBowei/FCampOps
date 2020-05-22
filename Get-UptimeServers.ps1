###------------------------------###
### Author###Biswajit Biswas-----### 
###MCC, MCSA, MCTS, CCNA, SME----###
###Email<bshwjt@gmail.com>-------###
###------------------------------###
Function Get-UptimeServers {   
    param(  
    ## Computers  
    $computers
    )
    $ErrorActionPreference = "SilentlyContinue"
    $uptime = Get-CimInstance Win32_OperatingSystem | select LastBootUpTime  
    $time = Get-WmiObject -Class Win32_OperatingSystem
    $UP = $time.ConvertToDateTime($time.LocalDateTime) – $time.ConvertToDateTime($time.LastBootUpTime)
    $LastReboot =  Get-EventLog -log System | ? EventID -EQ 12 | select username -First 1
    $status = Test-Connection -ComputerName $computers -count 1 
    if ($status.statuscode -eq 0) {
    Write-Host "Reachable" "###"$computers"###" "and Bounced" "###"$uptime"###" "Uptime" "###"$UP"###" "Last Reboot Done by" "###" $LastReboot "###" -foregroundcolor Green
    } else {
    Write-Host "Not Reachable" $computers -ForegroundColor Red
    }
    }
    Get-Content c:\computers.txt | ForEach-Object { Get-UptimeServers -computers $_} 
    Write-Host "I am complete" -foregroundcolor black -backgroundcolor cyan 
    Get-Date
    #End 