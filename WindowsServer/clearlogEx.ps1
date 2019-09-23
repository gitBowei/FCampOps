

Set-Executionpolicy RemoteSigned

$days=1 #You can change the number of days here

$IISLogPath="J:\inetpub\logs\LogFiles\"

$ExchangeLoggingPath="C:\Program Files\Microsoft\Exchange Server\V15\Logging\"

Write-Host "Removing IIS and Exchange logs; keeping last" $days "days"

Function CleanLogfiles($TargetFolder)

{

    if (Test-Path $TargetFolder) {

        $Now = Get-Date

        $LastWrite = $Now.AddDays(-$days)

        $Files = Get-ChildItem $TargetFolder -Include *.log,*.blg -Recurse | Where {$_.LastWriteTime -le "$LastWrite"}

        foreach ($File in $Files)

            {Write-Host "Deleting file $File" -ForegroundColor "Red"; Remove-Item $File -ErrorAction SilentlyContinue | out-null}

       }

Else {

    Write-Host "The folder $TargetFolder doesn't exist! Check the folder path!" -ForegroundColor "red"

    }

}

CleanLogfiles($IISLogPath)

CleanLogfiles($ExchangeLoggingPath)

The above script runs in PowerShell and will delete logs on the server that you are running the script on.

The following version of the same script will get all the Exchange 2013 servers in the organization and then delete the logs (older than 30 days) across all the servers for you from one machine. You run this second script from Exchange Management Shell (run as administrator) and need remote file access to C$ (or whichever folder you set in the script) to all the servers Exchange 2013 servers.

Set-Executionpolicy RemoteSigned

$days=30 #You can change the number of days here

$ExchangeInstallRoot = "C"

$IISLogPath="inetpub\logs\LogFiles\"

$ExchangeLoggingPath="Program Files\Microsoft\Exchange Server\V15\Logging\"

Write-Host "Removing IIS and Exchange logs; keeping last" $days "days"

Function CleanLogfiles($TargetFolder)

{

    $TargetServerFolder = "\\$E15Server\$ExchangeInstallRoot$\$TargetFolder"

    Write-Host $TargetServerFolder

    if (Test-Path $TargetServerFolder) {

        $Now = Get-Date

        $LastWrite = $Now.AddDays(-$days)

        $Files = Get-ChildItem $TargetServerFolder -Include *.log,*.blg -Recurse | Where {$_.LastWriteTime -le "$LastWrite"}

        foreach ($File in $Files)

            {

               # Write-Host "Deleting file $File" -ForegroundColor "Red"

                Remove-Item $File -ErrorAction SilentlyContinue | out-null}

        }

Else {

    Write-Host "The folder $TargetServerFolder doesn't exist! Check the folder path!" -ForegroundColor "red"

    }

}

$Ex2013 = Get-ExchangeServer | Where {$_.IsE15OrLater -eq $true}

foreach ($E15Server In $Ex2013) {

    CleanLogfiles($IISLogPath)

    CleanLogfiles($ExchangeLoggingPath)

    }