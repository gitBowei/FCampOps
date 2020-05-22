#################################################################################
# 
# The sample scripts are not supported under any Microsoft standard support 
# program or service. The sample scripts are provided AS IS without warranty 
# of any kind. Microsoft further disclaims all implied warranties including, without 
# limitation, any implied warranties of merchantability or of fitness for a particular 
# purpose. The entire risk arising out of the use or performance of the sample scripts 
# and documentation remains with you. In no event shall Microsoft, its authors, or 
# anyone else involved in the creation, production, or delivery of the scripts be liable 
# for any damages whatsoever (including, without limitation, damages for loss of business 
# profits, business interruption, loss of business information, or other pecuniary loss) 
# arising out of the use of or inability to use the sample scripts or documentation, 
# even if Microsoft has been advised of the possibility of such damages
#
#################################################################################

param(
[switch] $Gather,
[switch] $Analyze,
[switch] $ResetStats,
[string] $WorkingDirectory = "",
[string] $LogDirectoryOut = "",
[int]$MaxSampleIntervalVariance = 10,
[int]$MaxMinutesPastTheHour = 15,
[bool]$MonitoringExchange2013 = $true)

### GLOBAL VARIABLES ###
$gatherLogFileName = "LogStats.csv"
### END GLOBAL VARIABLES ###

#Function used to take a snapshot of the current log generation on all configured databases
function GetLogGenerations
{
    #Read our input file of servers and databases
    $targetServersPath = AppendFileNameToDirectory -directory $WorkingDirectory -fileName "TargetServers.txt"
    
    $targetServers = Get-Content -LiteralPath "$($targetServersPath)" -ErrorAction SilentlyContinue

    if ($targetServers -ne $null)
    {
        $logPath = AppendFileNameToDirectory -directory $WorkingDirectory -fileName $gatherLogFileName
                    
        #The log file hasn't been created yet, or a reset was request, so add a header first
        if ($ResetStats -eq $true -or !(Test-Path -LiteralPath $logPath))
        {
            "Log Generation,Time Retrieved,ServerName,DatabaseName" | Out-File -FilePath $logPath -Encoding ASCII
        }
                    
        #Process each server in the list
        foreach ($server in $targetServers)
        {
            #Make sure we're not processing an empty line in the input file
            if ($server.Trim().Length -gt 0)
            {
                #Split the line into multiple columns. The first being the server name, the rest being database names.
                $serverSettings = $server.Split(',')
            
                $serverName = $serverSettings[0].Trim()
                
                #Keep track of whether the server we're processing is 2013, since we'll have to use a different counter
                $is2013Server = $false
            
                #Keep track of all counters on the current server
                $allCounters = $null

                #Get the list of counters for the server. Try 2013 first, if configured.
                if ($MonitoringExchange2013 -eq $true)
                {
                    $allCounters = Get-Counter -ListSet "MSExchangeIS HA Active Database" -ComputerName $serverName -ErrorAction SilentlyContinue
                }

                #Either we failed to connect to the server, or this isn't a 2013 server. Try the 2007/2010 command.
                if ($allCounters -eq $null)
                {
                    $allCounters = Get-Counter -ListSet "MSExchange Database ==> Instances" -ComputerName $serverName -ErrorAction SilentlyContinue
                }
                else
                {
                    $is2013Server = $true
                }
                
                #Got counters. Process them.
                if ($allCounters -ne $null)
                {
                    #Set up the command to filter the counter list to the specific counters we want
                    if ($is2013Server)
                    {
                        $targetCounterCommand = "`$allCounters.PathsWithInstances | where {`$_ -like '*Current Log Generation Number*' -and `$_ -notlike '*_total*'}"
                    }
                    else
                    {
                        $targetCounterCommand = "`$allCounters.PathsWithInstances | where {`$_ -like '*Information Store*Log File Current Generation*' -and `$_ -notlike '*Information Store/_Total*' -and `$_ -notlike '*Information Store/Base instance to*'}"
                    }
                
                    #DB's were specified for this server. Filter on them
                    if ($serverSettings.Count -gt 1)
                    {
                        $dbName = $serverSettings[1].ToLower().Trim()
                        $dbFilterString = " -and (`$_ -like '*$($dbName)*'"  
                    
                        for ($i = 2; $i -lt $serverSettings.Count; $i++)
                        {
                            $dbName = $serverSettings[$i].ToLower().Trim()
                            $dbFilterString += " -or `$_ -like '*$($dbName)*'"                                
                        }
                    
                        $targetCounterCommand = $targetCounterCommand.Replace("}", $dbFilterString + ")}")
                    }
                
                    #Invoke the command and get the counter names of databases we want
                    $targetCounters = Invoke-Expression $targetCounterCommand

                    #Process each counter in the list
                    foreach ($counterName in $targetCounters)
                    {
                        #Parse out the database name from the current counter
                        if ($is2013Server)
                        {
                            $dbNameStartIndex = $counterName.IndexOf("MSExchangeIS HA Active Database(") + "MSExchangeIS HA Active Database(".Length                            
                        }
                        else 
                        {
                            $dbNameStartIndex = $counterName.IndexOf("Instances(Information Store/") + "Instances(Information Store/".Length
                        }
                        
                        $dbNameEndIndex =  $counterName.IndexOf(")", $dbNameStartIndex)
                        $dbName = $counterName.SubString($dbNameStartIndex, $dbNameEndIndex - $dbNameStartIndex)
                
                        #Get the counter's value
                        $counter = Get-Counter "$($counterName)" -ComputerName $serverName -ErrorAction SilentlyContinue
                        
                        if ($counter -ne $null)
                        {
                            $value = $counter.CounterSamples[0].RawValue

                            #Log the value and timestamp
                            "$($value),$([DateTime]::Now),$($serverName),$($dbName)" | Out-File -FilePath $logPath -Append -Encoding ASCII
                        }
                        else
                        {
                            Write-Host -ForegroundColor Red "ERROR: Failed to read perfmon counter from server $($serverName)"
                        }
                    }
                }
                else
                {
                    Write-Host -ForegroundColor Red "ERROR: Failed to get perfmon counters from server $($serverName)"
                }
            }
        }
    }
}

#Function used to Analyze log files which were captured in Gather mode
function AnalyzeLogFiles
{
    $inputLogPath = AppendFileNameToDirectory -directory $WorkingDirectory -fileName $gatherLogFileName
    
    $inputLogFile = Get-Content -LiteralPath "$($inputLogPath)"
    
    #Hash used to store the per database log generation readings. The Key will be a String. The Value will be a List of Strings
    $inputLogHash = @{}
    
    #Loop through the input log file and add the contents to the hash
    for ($i = 1; $i -lt $inputLogFile.Count; $i++)
    {
        $splitLine = $inputLogFile[$i].Split(',')
        
        $logGenPlusTimeStamp = $splitLine[0] + "," + $splitLine[1]
        $serverPlusDb = $splitLine[2] + "-" + $splitLine[3]
        
        #We haven't touched this database yet, so add it to the hashtable with a new List
        if (!($inputLogHash.ContainsKey($serverPlusDb)))
        {
            $inputLogHash.Add($serverPlusDb, (New-Object "System.Collections.Generic.List``1[System.String]"))
        }
        
        $inputLogHash.Item($serverPlusDb).Add($logGenPlusTimeStamp)
    }

    #3 dimensional array to hold results.
    #1st dimension = Log number. Add an extra to total all databases
    #2nd dimension = Hour of day. Add an extra for all day totals
    #3rd dimension[0] is the total of logs created. [1] is the total of actual sample intervals. #[2] is the total number of samples
    $results = New-Object 'object[,,]' ($inputLogHash.Count + 1),25,3
    $logNames = New-Object 'object[]' ($inputLogHash.Count)
    
    #Keep track of the log number since we can't index into a hashtable
    $logNum = -1
    
    #First loop through and process the data from the logs
    foreach ($kvp in $inputLogHash.GetEnumerator())
    {
        #First increment the log number
        $logNum++
        
        #Now get the log name and value
        $logNames[$logNum] = $kvp.Name
        $log = $kvp.Value
                
        #we need at least 2 lines to be able to compare samples
        if ($log.Count -ge 2)
        {
            for ($j = 1; $j -lt $log.Count; $j++)
            {
                $previousSample = $log[$j - 1].Split(',')
                $previousDate = [DateTime]::Parse($previousSample[1])
                
                $currentSample = $log[$j].Split(',')
                $currentDate = [DateTime]::Parse($currentSample[1])
                
                $logGenDifference = $currentSample[0] - $previousSample[0]
                $timeSpan = New-TimeSpan -Start $previousDate -End $currentDate
                
                #Only work on positive log differences
                #Only work on samples taken within maxMinutesPastTheHour minutes past the top of the hour
                #Only work on samples whose interval was within maxSampleIntervalVariance
                if ($logGenDifference -ge 0 -or $currentDate.Minute -le $MaxMinutesPastTheHour -or !($timeSpan.TotalMinutes -gt (60 + $MaxSampleIntervalVariance) -or $timeSpan.TotalMinutes -lt (60 - $MaxSampleIntervalVariance)))
                {
                    #Total this database for this hour
                    $results[$logNum, $previousDate.Hour, 0] += $logGenDifference                    
                    $results[$logNum, $previousDate.Hour, 1] += $timeSpan.TotalSeconds
                    $results[$logNum, $previousDate.Hour, 2]++
                    
                    #Add this database totals to the entire days totals
                    $results[$logNum, 24, 0] += $logGenDifference                    
                    $results[$logNum, 24, 1] += $timeSpan.TotalSeconds
                    $results[$logNum, 24, 2]++
                    
                    #Add to all databases total
                    $results[($inputLogHash.Count), $previousDate.Hour, 0] += $logGenDifference
                    $results[($inputLogHash.Count), $previousDate.Hour, 1] += $timeSpan.TotalSeconds
                    $results[($inputLogHash.Count), $previousDate.Hour, 2]++
                    
                    #Add to all databases totals for the day
                    $results[($inputLogHash.Count), 24, 0] += $logGenDifference
                    $results[($inputLogHash.Count), 24, 1] += $timeSpan.TotalSeconds
                    $results[($inputLogHash.Count), 24, 2]++
                }
                else
                {
                    continue
                }
            }
        }
    }
    
    #Now output the results, and put together our averages for all servers
    for ($i = 0; $i -lt ($inputLogHash.Count + 1); $i++)
    {   
        if ($i -eq $inputLogHash.Count)
        {
            $logName = "AllDatabases"
        }
        else
        {            
            $logName = $logNames[$i]
        }
        
        $logPath = AppendFileNameToDirectory -directory $LogDirectoryOut -fileName "$($logName)-Analyzed.csv"
        
        "Hour,TotalLogsCreated,TotalSampleIntervalSeconds,NumberOfSamples,AverageSample,PercentDailyUsage,AverageSamplePer60Minutes,PercentDailyUsagePer60Minutes" | Out-File -FilePath $logPath -Encoding ASCII
        
        for ($j = 0; $j -lt 24; $j++)
        {
            if ($results[$i,$j,1] -ne $null -and $results[$i,$j,2] -ne $null)
            {
                #(TotalLogsCreated / TotalSampleIntervalTotalSecondss) * 1 hour
                $averageSamplePer60Minutes = ($results[$i,$j,0] / $results[$i,$j,1]) * 3600
                
                #(TotalLogsCreated / TotalSampleIntervalTotalSecondss) * 1 hour * 24 hours
                $averageSamplePer24Hours = ($results[$i,24,0] / $results[$i,24,1]) * 3600 * 24
                
                $percentDailyUsagePer60Minutes = ($averageSamplePer60Minutes / $averageSamplePer24Hours) * 100
                
                #TotalLogsCreated / NumberOfSamples
                $averageSample = $results[$i,$j,0] / $results[$i,$j,2]            
                $averagePer24Hours = $results[$i,24,0] / $results[$i,24,2] * 24
                
                if ($averagePer24Hours -gt 0)
                {
                    $percentDailyUsage = ($averageSample / $averagePer24Hours) * 100
                }
                else
                {
                    $percentDailyUsage = 0
                }            
                
                "$($j),$($results[$i,$j,0]),$($results[$i,$j,1]),$($results[$i,$j,2]),$($averageSample),$($percentDailyUsage),$($averageSamplePer60Minutes),$($percentDailyUsagePer60Minutes)" | Out-File -FilePath $logPath -Append -Encoding ASCII
            }
        }
    }
}

#Used to strip the slash at the end of a file path
function StripTrailingSlash
{
    param($stringIn)
    
    if ($stringIn.EndsWith("\") -or $stringIn.EndsWith("/"))
    {
        $stringIn = $stringIn.Substring(0, ($stringIn.Length - 1))
    }
    
    return $stringIn
}

#Returns a full path (relative or absolute) consisting of the given directory plus the given filename
function AppendFileNameToDirectory
{
    param($directory, $fileName)
    
    if ($directory -eq "")
    {
        return $fileName
    }
    else
    {
        return "$($directory)\$($fileName)"
    }
}

# Function that returns true if the incoming argument is a help request
function IsHelpRequest
{
	param($argument)
	return ($argument -eq "-?" -or $argument -eq "-help");
}

# Function that displays the help related to this script following
# the same format provided by get-help or <cmdletcall> -?
function Usage
{
@"

NAME:
`tGetTransactionLogStats.ps1

SYNOPSIS:
`tUsed to collect and analyze Exchange transaction log generation statistics.
`tDesigned to be run as an hourly scheduled task, on the top of each hour.
`tCan be run against one or more servers and databases.

SYNTAX:
`tGetTransactionLogStats.ps1
`t`t[-Gather]
`t`t[-Analyze]
`t`t[-ResetStats]
`t`t[-WorkingDirectory <StringValue>]
`t`t[-LogDirectoryOut <StringValue>]
`t`t[-MaxSampleIntervalVariance <IntegerValue>]
`t`t[-MaxMinutesPastTheHour <IntegerValue>]
`t`t[-MonitoringExchange2013 <BooleanValue>]

PARAMETERS:
`t-Gather
`t`tSwitch specifying we want to capture current log generations.
`t`tIf this switch is omitted, the -Analyze switch must be used.

`t-Analyze
`t`tSwitch specifying we want to analyze already captured data.
`t`tIf this switch is omitted, the -Gather switch must be used.

`t-ResetStats
`t`tSwitch indicating that the output file, LogStats.csv, should
`t`tbe cleared and reset. Only works if combined with –Gather.

`t-WorkingDirectory
`t`tThe directory containing TargetServers.txt and LogStats.csv.
`t`tIf omitted, the working directory will be the current working
`t`tdirectory of PowerShell (not necessarily the directory the
`t`tscript is in).

`t-LogDirectoryOut
`t`tThe directory to send the output log files from running in
`t`tAnalyze mode to. If omitted, logs will be sent to WorkingDirectory.

`t-MaxSampleIntervalVariance
`t`tThe maximum number of minutes that duraction between two samples can
`t`tvary from 60. If we are past this amount, the sample will be discarded.
`t`t.Defaults to a value of 10.

`t-MaxMinutesPastTheHour
`t`tHow many minutes past the top of the hour a sample can be taken.
`t`tSamples past this amount will be discarded. Defaults to a value of 15.

`t-MonitoringExchange2013
`t`tWhether there are Exchange 2013 servers configured in TargetServers.txt.
`t`tDefaults to `$true. If there are no 2013 servers being monitored, set this
`t`tto `$false to increase performance.


`t-------------------------- EXAMPLES ----------------------------

PS C:\> .\GetTransactionLogStats.ps1 -Gather

PS C:\> .\GetTransactionLogStats.ps1 -Gather -MonitoringExchange2013 `$false

PS C:\> .\GetTransactionLogStats.ps1 -Gather -WorkingDirectory "C:\GetTransactionLogStats" -ResetStats

PS C:\> .\GetTransactionLogStats.ps1 -Analyze

PS C:\> .\GetTransactionLogStats.ps1 -Analyze -LogDirectoryOut "C:\GetTransactionLogStats\LogsOut" -MaxSampleIntervalVariance 5 -MaxMinutesPastTheHour 10
"@
}

####################################################################################################
# Script starts here
####################################################################################################

# Check for Usage Statement Request
$args | foreach { if (IsHelpRequest $_) { Usage; exit; } }

#Do input validation before proceeding
if (($Gather -eq $false -and $Analyze -eq $false) -or ($Gather -eq $true -and $Analyze -eq $true))
{
    Write-Host -ForeGroundColor Red "ERROR: Either the Gather or Analyze switch must be specified, but not both."
}
elseif ($WorkingDirectory -ne "" -and !(Test-Path -LiteralPath $WorkingDirectory))
{
    Write-Host -ForeGroundColor Red "ERROR: Working directory '$($WorkingDirectory)' must be created before proceeding."
}
elseif ($Analyze -eq $true -and $LogDirectoryOut -ne "" -and !(Test-Path -LiteralPath $LogDirectoryOut))
{
    Write-Host -ForeGroundColor Red "ERROR: Output log directory '$($LogDirectoryOut)' must be created before proceeding."
}
elseif ($Analyze -eq $true -and ($MaxSampleIntervalVariance -lt 0 -or $MaxMinutesPastTheHour -lt 0))
{
    Write-Host -ForeGroundColor Red "ERROR: MaxSampleIntervalVariance and MaxMinutesPastTheHour must have non-negative values."
}
else #Made it past input validation
{
    #Massage the log directory string so they're in an expected format when we need them
    $LogDirectoryOut = StripTrailingSlash($LogDirectoryOut)
    $WorkingDirectory = StripTrailingSlash($WorkingDirectory)
     
    #Now do the real work
    if ($Gather -eq $true)
    {
        GetLogGenerations
    }
    else #(Analyze -eq $true)
    {
        AnalyzeLogFiles
    }
}