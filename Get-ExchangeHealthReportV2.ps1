<#
NAME
	Get-MailboxReport.ps1 
VERSION
	2.1
AUTHOR
	Marius Samartean
DATE CREATED
	1/20/2013
LAST MODIFIED BY
	Marius Samartean
LAST MODIFIED ON
	6/21/2013
EMAIL
	marius.samartean@gmail.com
SITE(S)
	www.openPowershell.com (in work)

DESCRIPTION  
	Creates an ample easy-to-read HTML Monitoring report for the Exchange servers in your organization, and highlights the problems found.
	The HTML auto-refreshes, so provided you schedule the script to run every few minutes you can have a free monitoring console for your Exchange environment in your browser.
	
	Use the bottom table in the report to find a more detailed explanation for your Performance Monitor failures.
	
	General
		- Uptime
		- Disk usage, Processor Time, Available Memory, Pages/Sec(Memory), Time in GC(Garbage Collection)
		- Network usage, Packets outbound Errors, LDAP Search Time(spike), LDAP Search Time(average)
	Mailbox servers
		- MAPI Test per server
		- Mailflow Test per server
		- I/O DB Writes Latency
	CAS servers
		- RPC Requests
		- RPC Averaged Latency
		- OWA Average Search Time
	Hub Transport Servers
		- Checks the Transport Queues
		- Poison Messages queue
		- Version Buckets Allocated
	UM servers
		- UM Success Rate
	DAG and Non-Replicated Databases
		- Databases Health status
		- Databases Backup status
		- Copy/Replay queues
		- Content Index State
		- Verifies the Database activation based in Activation preference
		
VERSION HISTORY

2.1		- Added CAS, HT, UM and I/O DB Writes Latency server performance counters
2.0		- Replaced the Failures List with Hover-to-Info feature; simplified HTML coding; improved look and feel
1.3.1	- Fixed a bug on the functions, sometimes the booleans return don't work, changed the variables to strings
1.3		- Optimized the script to run faster
1.2.1	- Fixed a bug on the Test-Mailflow part
1.2 	- Added "Time in GC", "Network usage" counters and Non-Replicated DB health check
1.1.2 	- Fixed a bug on the Hub Transport queues check
1.1.1 	- Fixed a bug on the DB health part
1.1 	- Added the Failures List table
#>

#region Parameters
Param(
	[Parameter(Position=1,Mandatory = $False,HelpMessage = "The email address you want the report to be sent to...")]
	# Make sure you add valid addresses and SMTP address here if you want to get an email with the report
		[string]$EmailRecipients = '',
	[Parameter(Position=2,Mandatory = $False,HelpMessage = "The email address you want the report to be received from...")]
		[string]$EmailSender = "monitor@openpowershell.com",
	[Parameter(Position=3,Mandatory = $False,HelpMessage = "The SMTP server you want to send the email through...")]
		[string]$EmailRelay = "1.2.3.4"
  )
#endregion Parameters

#region Configuration
# Report path, saved after the script is done in the same location
[string]$HTMLReport = "C:\scripts_production\Reports\report.html"
[string]$HTMLFailureList = "C:\scripts_production\Reports\FList.html"

# Thresholds
[int]$QueueWarn = 20					# Copy/Replay queues logs warning threshold.
[int]$QueueAlert = 50					# Copy/Replay queues logs alert threshold.
[int]$WarnHTQueue = 100					# Hub Transport queues warning threshold.
[int]$FailHTQueue = 250					# Hub Transport queues fail threshold.
[int]$UptimeWarn = 23					# in Hours. Server uptime threshold.
[int]$Bkpthreshold = 48					# in Hours. Depends on your backup policy.

# Number of past samples to be kept for averaging counters. If script is run every 10 minutes, 5 samples is optimal.
[int]$SamplesNumber = 5
<# Averages are dependent on multiple runs of this script, as it records the values in .hist files.
The $SamplesNumber variable determines how many old values kept in these .hist files are taken into consideration when calculating the average, 
plus the current value.
The current value becomes the most recent past value and so on...#>

# PerfMon thresholds
[int]$LDAPspikethreshold = 100			# The LDAP search time spike should be under 100 milliseconds.
[int]$LDAPaveragethreshold = 50			# The average LDAP search time value should be under 50 milliseconds.
[int]$NetworkBytesThreshold = 9			# in MB/s. For a 1000-megabits per second (Mbps) network adapter, threshold should be set to around 9 MB/s.
[int]$NetworkOutboundErrors = 0			# Should be 0 at all times.
[int]$TimeinGCthreshold = 10			# Should be below 10% on average.
[int]$MemoryPagesThreshold = 1000		# Should be below 1,000 on average.
[int]$AvailableMemoryMBThreshold = 100	# Should remain above 100 MB at all times.
[int]$ProcessorTimeThreshold = 75		# Should be less than 75% on average.
[int]$DiskThreshold = 90				# Everything under 90% disk utilization should be good.
[int]$OWAsearchTimeThreshold = 5000		# Should be less than 5,000 milliseconds (ms) at all times.
[int]$RPClatencyThreshold = 25			# Should be below 25 ms.
[int]$RPCrequestsThreshold = 40			# Shouldn't be over 40.
[int]$VersionBucketsThreshold = 200		# Should be less than 200 at all times.
[int]$PoisonQueuesThreshold = 0			# Should be 0 at all times.
[int]$DBwritesLatencyThreshold = 50		# Should be 50 ms on average.
[int]$UMsuccessThreshold = 95			# Should be greater or equal to 95%.

# PerfMon counters
$perfProcessorTime = "\Processor(_Total)\% Processor Time"
$perfAvailableMemory = "\Memory\Available Mbytes"
$perfMemoryPages = "\Memory\Pages/Sec"
$perfTimeinGC = "\.NET CLR Memory(*)\% Time in GC"
$perfTotalBytes = "\Network Interface(*)\Bytes Total/sec"
$perfOutboundErrors = "\Network Interface(*)\Packets Outbound Errors"
$perfLDAPSearchTime = "\MSExchange ADAccess Domain Controllers(*)\LDAP Search Time"
$perfOWAsearchTime = "MSExchange OWA\Average Search Time"
$perfRPCrequests = "MSExchange RpcClientAccess\RPC Requests"
$perfRPClatency = "MSExchange RpcClientAccess\RPC Averaged Latency"
$perfPoisonQueues = "\MSExchangeTransport Queues(_total)\Poison Queue Length"
$perfVersionBuckets = "MSExchange Database ==> Instances(edgetransport/Transport Mail Database)\Version buckets allocated"
$perfDBwritesLatency = "MSExchange Database ==> Instances(Information Store/_Total)\I/O Database Writes Average Latency"
$perfUMsuccess = "MSExchangeUMAvailability\% of Messages Successfully Processed Over the Last Hour"

# Script constants and variables - usually they don't need to be touched
$now = Get-Date									# Date to mark the script start
$date = Get-Date -format MMM-dd-yyyy			# Date format for email message subject
[String]$pass = "Green"
[String]$warn = "Yellow"
[String]$fail = "Red"
$BackupsList = [PSObject]@()						
$servers = get-ExchangeServer | sort			# Gets the servers
$databasesList = Get-MailboxDatabase -Status	# Gets the databases
[Bool]$bolFailover = $False						
[String]$dbError = $null
#Booleans for each health check
[bool]$buli = $False
[bool]$bulii = $False
[bool]$buliii = $False
[bool]$buliv = $False

$databasesList | ForEach {
	$db = $_.Name
	$ServerNow = $_.Server.Name
	$ServerShould = $_.ActivationPreference | ?{$_.Value -eq 1}

	# Compare the server where the DB is currently active to the server where it should be
	If ($ServerNow -ne $ServerShould.Key)
	{
		$dbError += "<tr><td class=""Warn"" colspan=""7"">`n$db on $ServerNow should be mounted on $($ServerShould.Key)!</td></tr> "
		$buli = $True
	}
}

if(!$dbError){ $dbError = "<tr><td class=""Pass"" colspan=""7"">All replicated databases are mounted on their primary servers.</td></tr>"}

# Starting building the tables
$htmlDatabaseCopies = "<p>
					<table border=""0"" cellpadding=""1.5"" width=""100%"" style=""font-size:8pt;font-family:Arial,sans-serif"">
					<tr>
					<th colspan=""7"">DAG & Replicated Databases Health Check</th>
					</tr>
					<tr>
					<th>Server Name</th>
					<th>Database Name</th>
					<th>Active Copy</th>
					<th>State</th>
					<th>Copy Queue Length</th>
					<th>Replay Queue Length</th>
					<th>Content Index State</th>
					</tr>"
$htmlDatabase = "<p>
					<table border=""0"" cellpadding=""1.5"" width=""100%"" style=""font-size:8pt;font-family:Arial,sans-serif"">
					<tr>
					<th colspan=""4"">Non-Replicated Databases Health Check</th>
					</tr>
					<tr>
					<th>Server Name</th>
					<th>Database Name</th>
					<th>State</th>
					<th>Content Index State</th>
					</tr>"
$htmlHTqueues = "	<p>
					<table border=""0"" cellpadding=""1.5"" width=""100%"" style=""font-size:8pt;font-family:Arial,sans-serif"">
					<tr>
					<th colspan=""5"">Hub Transport Queues Check</th>
					</tr>
					<tr>
					<th>Identity</th>
					<th>Delivery Type</th>
					<th>Status</th>
					<th>Message Count</th>
					<th>Next Hop</th>
					</tr>"
$htmlBackupList = "	<p>
					<table border=""0"" cellpadding=""1.5"" width=""100%"" style=""font-size:8pt;font-family:Arial,sans-serif"">
					<tr>
					<th colspan=""5"">Databases Backup Check</th>
					</tr>
					<tr>
					<th>Server or DAG</th>
					<th>Database</th>
					<th>Last Backup (Hrs Ago)</th>
					<th>Last Full Backup</th>
					<th>Last Incremental Backup</th>
					</tr>"
$htmlPerfcheck = "<p>
					<table border=""0"" cellpadding=""1.5"" width=""100%"" style=""font-size:8pt;font-family:Arial,sans-serif"">
					<tr>
					<th colspan=""20"">Exchange Performance Check</th>
					</tr>
					<tr>
					<th width=""10%"">Server</th>
					<th width=""4.5%"">Uptime</th>
					<th width=""4.5%"">Disk Usage</th>
					<th width=""4.5%"">Processor Time</th>
					<th width=""4.5%"">Available Memory</th>
					<th width=""4.5%"">Pages/Sec (Memory)</th>
					<th width=""4.5%"">Time in GC</th>
					<th width=""4.5%"">Network Usage</th>
					<th width=""4.5%"">Packets Outbound Errors</th>
					<th width=""4.5%"">LDAP Search Time (spike)</th>
					<th width=""4.5%"">LDAP Search Time (average)</th>
					<th width=""4.5%"">MAPI Test</th>
					<th width=""4.5%"">Mailflow Test</th>
					<th width=""4.5%"">I/O DB Writes Latency</th>
					<th width=""4.5%"">RPC Requests</th>
					<th width=""4.5%"">RPC Averaged Latency</th>
					<th width=""4.5%"">OWA Average Search Time</th>
					<th width=""4.5%"">Poison Messages</th>
					<th width=""4.5%"">Version Buckets Allocated</th>
					<th width=""4.5%"">UM Success Rate</th>
					</tr>"

$MountedDatabases = [PSObject]@()
$ReplicatedDatabases = [PSObject]@()
$nonReplicatedDatabases = [PSObject]@()
$QueuesInfo = [PSObject]@()

#endregion configuration

#region Functions
# The functions' names indicate their role 

function check-DiskUsage ($computername) {
	$data = Get-WmiObject -Class Win32_logicaldisk -filter "drivetype=3" -computer $computername
	# String-Boolean workaround
	[string]$booli = "No"
	[string]$WarningText = "All good."
	foreach ($drive in $data)
	{
		$diskUsage = (($drive.Size - $drive.Freespace)/$drive.Size)*100
		if ($diskUsage -gt $DiskThreshold)
		{
			$booli = "Yes"
			$WarningText += "Drive $($drive.DeviceID) on $computername has a disk usage of $diskUsage%."
		}
	}
	return $booli,$WarningText
}

function check-Mailflow ($computername) {
	# String-Boolean workaround
	[string]$booli = "No"
	[string]$WarningText = "Mailflow pass."
	[string]$result = (Test-Mailflow $computername -AutoDiscoverTargetMailboxServer).testmailflowresult
	if($result -ne "Success")
	{
		$booli = "Yes"
		$WarningText = "Mailflow test failed for this server($computername), the result received is: $result."
	}
	return $booli,$WarningText
}

function check-MAPIconnectivity($computername) {
	$MAPItestressults = Test-MapiConnectivity -server $computername
	# String-Boolean workaround
	[string]$booli = "No"
	[string]$WarningText = $null
	foreach ($result in $MAPItestressults)
	{
		if ($result.Result.Value -ne "Success")
		{
			$booli = "Yes"
			$WarningText += "MAPI connectivity test failed with $($result.database) database on $($result.mailboxserver) and got this error $($result.error)."
		}
	}	
	return $booli,$WarningText
}

function get-ProcessorTime($computername) {
	[int]$total = 0
	# String-Boolean workaround
	[string]$booli = "No"
	[string]$WarningText = "All good."
	[int]$average = 0
	$HistPath = "C:\TEMP\DATA\$($Computername)_proclog.hist"
	
	# Verifies if the log file exists... if not, it'll create one
	if(!(Test-Path $HistPath)){
		if(!(Test-Path C:\TEMP\DATA))
		{
			New-Item C:\TEMP\DATA -type directory
		}
		New-Item $HistPath -Type File
		for($i=($SamplesNumber+1);$i -gt 0;$i--){
			$i | Out-File $HistPath -Append
		}
	}
	$list = Get-Content $HistPath
	if(($SamplesNumber+1) -gt $list.count){
		for($i=$list.count;$i -lt ($SamplesNumber+1);$i++){
			$i | Out-File $HistPath -Append
		}
		$list = Get-Content $HistPath
	}
	$list[$SamplesNumber] = $list[$SamplesNumber-1]
    for ($i=($SamplesNumber - 1);$i -gt 0;$i--)
    {
		$total += $list[$i]
		$list[$i] = $list[$i-1]
	}
	$total += $list[0]
	$sample = ((Get-counter -ComputerName $computername -Counter $perfProcessorTime).countersamples[0]).cookedvalue
	$total += $sample
	$list[0] = $sample
	$average = $total/($SamplesNumber + 1)
	
	if($average -gt $ProcessorTimeThreshold)
	{
		$WarningText = "$computername has a high Processor Time with an average for the last $SamplesNumber checks of $average%. "
		$booli = "Yes"
	}
    
	$list | Out-File $HistPath
	return $booli,$WarningText
}

function get-AvailableMemory($computername){
	# String-Boolean workaround
    [string]$booli = "No"
	[string]$WarningText = "All good."
    $sample = ((Get-counter -ComputerName $computername -Counter $perfAvailableMemory).countersamples[0]).cookedvalue
	
	if($sample -le $AvailableMemoryMBThreshold)
	{
		$WarningText = "$computername has just $sample MB of memory free. "
		$booli = "Yes"
	}
        
	return $booli,$WarningText
}

function get-OWAsearchTime($computername){
	# String-Boolean workaround
    [string]$booli = "No"
	[string]$WarningText = "All good."
    $sample = ((Get-counter -ComputerName $computername -Counter $perfOWAsearchTime).countersamples[0]).cookedvalue
	
	if($sample -ge $OWAsearchTimeThreshold)
	{
		$WarningText = "$computername had an average search time in OWA of $sample ms."
		$booli = "Yes"
	}
        
	return $booli,$WarningText
}

function get-RPClatency($computername){
	# String-Boolean workaround
    [string]$booli = "No"
	[string]$WarningText = "All good."
    $sample = ((Get-counter -ComputerName $computername -Counter $perfRPClatency).countersamples[0]).cookedvalue
	
	if($sample -ge $RPClatencyThreshold)
	{
		$WarningText = "$computername had an averaged latency for the last 1024 packets of $sample ms."
		$booli = "Yes"
	}
        
	return $booli,$WarningText
}

function get-RPCrequests($computername){
	# String-Boolean workaround
    [string]$booli = "No"
	[string]$WarningText = "All good."
    $sample = ((Get-counter -ComputerName $computername -Counter $perfRPCrequests).countersamples[0]).cookedvalue
	
	if($sample -ge $RPCrequestsThreshold)
	{
		$WarningText = "$computername is processing a number of $sample RPC client requests."
		$booli = "Yes"
	}
        
	return $booli,$WarningText
}

function get-PoisonQueues($computername){
	# String-Boolean workaround
    [string]$booli = "No"
	[string]$WarningText = "All good."
    $sample = ((Get-counter -ComputerName $computername -Counter $perfPoisonQueues).countersamples[0]).cookedvalue
	
	if($sample -ne $PoisonQueuesThreshold)
	{
		$WarningText = "The poison queue on the $computername server is not empty! It has $sample messages in it."
		$booli = "Yes"
	}
        
	return $booli,$WarningText
}

function get-UMsuccess($computername){
	# String-Boolean workaround
    [string]$booli = "No"
	[string]$WarningText = "All good."
    $sample = ((Get-counter -ComputerName $computername -Counter $perfUMsuccess).countersamples[0]).cookedvalue
	
	if($sample -lt $UMsuccessThreshold)
	{
		$WarningText = "The percentage of messages that were successfully processed by the Unified Messaging service on $computername over the last hour was of $sample% only."
		$booli = "Yes"
	}
        
	return $booli,$WarningText
}

function get-VersionBuckets($computername){
	# String-Boolean workaround
    [string]$booli = "No"
	[string]$WarningText = "All good."
    $sample = ((Get-counter -ComputerName $computername -Counter $perfVersionBuckets).countersamples[0]).cookedvalue
	
	if($sample -ge $VersionBucketsThreshold)
	{
		$WarningText = "The total number of Version Buckets allocated is $sample on the $computername HT server."
		$booli = "Yes"
	}
        
	return $booli,$WarningText
}

function get-DBwritesLatency($computername){
	# String-Boolean workaround
    [string]$booli = "No"
	[string]$WarningText = "All good."
    $sample = ((Get-counter -ComputerName $computername -Counter $perfDBwritesLatency).countersamples[0]).cookedvalue
	
	if($sample -ge $DBwritesLatencyThreshold)
	{
		$WarningText = "The average length of time, $sample ms, per database write operation is too high for this server($computername)."
		$booli = "Yes"
	}
        
	return $booli,$WarningText
}

function get-MemoryPages($computername){
	[int]$total = 0
	[int]$average = 0
	$HistPath = "C:\TEMP\DATA\$($Computername)_memlog.hist"
	
	if(!(Test-Path $HistPath)){
		if(!(Test-Path C:\TEMP\DATA))
		{
			New-Item C:\TEMP\DATA -type directory
		}
		New-Item $HistPath -Type File
		for($i=($SamplesNumber+1);$i -gt 0;$i--){
			$i | Out-File $HistPath -Append
		}
	}
	$list = Get-Content $HistPath
	if(($SamplesNumber+1) -gt $list.count){
		for($i=$list.count;$i -lt ($SamplesNumber+1);$i++){
			$i | Out-File $HistPath -Append
		}
		$list = Get-Content $HistPath
	}
	# String-Boolean workaround
	[string]$booli = "No"
	[string]$WarningText = "All good."
	$list[$SamplesNumber] = $list[$SamplesNumber-1]
    for ($i=($SamplesNumber - 1);$i -gt 0;$i--)
    {
		$total += $list[$i]
		$list[$i] = $list[$i-1]
	}
	$sample = ((Get-counter -ComputerName $computername -Counter $perfMemoryPages).countersamples[0]).cookedvalue
	$total += $sample
	$total += $list[0]
	$list[0] = $sample
	$average = $total/($SamplesNumber + 1)
	
	if($average -gt $MemoryPagesThreshold)
	{
		$WarningText = "$computername has a high Memory Pages/sec utilization with an average for the last $($SamplesNumber + 1) checks of $average. "
		$booli = "Yes"
	}
    $list | Out-File $HistPath
	return $booli,$WarningText
}

function get-TimeinGC($computername){
	# String-Boolean workaround
	[string]$booli = "No"
	[string]$WarningText = "These Garbage Collection issues were found for this server($computername):"
	$Samples = (Get-counter -ComputerName $computername -Counter $perfTimeinGC).countersamples
	
	# Sometimes it fails from the first time
	if(!$samples){(Get-counter -ComputerName $computername -Counter $perfTimeinGC).countersamples}
	foreach($Sample in $Samples){
		[int]$average = 0
		[int]$total = 0
		[string]$GCInstance = $Sample.Path
		
		# It created a log file for every GC instance on the server
		$GCInstance = $GCInstance.Replace("\","")
		$GCInstance = $GCInstance.Replace("% time in gc","")
		$GCInstance = $GCInstance.Replace(" ","")
		$HistPath = "C:\TEMP\DATA\GC\$($GCInstance)_GClog.hist"
		if(!(Test-Path $HistPath)){
			if(!(Test-Path C:\TEMP\DATA\GC))
			{
				New-Item C:\TEMP\DATA\GC -type directory
			}
			New-Item $HistPath -Type File
			for($i=($SamplesNumber+1);$i -gt 0;$i--){
				$i | Out-File $HistPath -Append
			}
		}
		$list = Get-Content $HistPath
		if(($SamplesNumber+1) -gt $list.count){
			for($i=$list.count;$i -lt ($SamplesNumber+1);$i++){
				$i | Out-File $HistPath -Append
			}
			$list = Get-Content $HistPath
		}
		$list[$SamplesNumber] = $list[$SamplesNumber-1]
		for ($i=($SamplesNumber - 1);$i -gt 0;$i--)
	    {
			$total += $list[$i]
			$list[$i] = $list[$i-1]
		}
		$total += $Sample.cookedvalue
		$total += $list[0]
		$list[0] = $Sample.cookedvalue
		$average = $total/($SamplesNumber + 1)
		if($average -gt $TimeinGCthreshold)
		{
			$InstanceWarning = $Sample.InstanceName
			$WarningText += " $InstanceWarning with a GC average for the last $($SamplesNumber + 1) checks of $average%."
			$booli = "Yes"
		}
	    $list | Out-File $HistPath
	}
	return $booli,$WarningText
}

function get-NetworkBytes($computername){
	# String-Boolean workaround
    [string]$booli = "No"
	$sample = (Get-counter -ComputerName $computername -Counter $perfTotalBytes).countersamples
	[int]$Count = ($sample | Measure-Object).count
	[string]$WarningText = "These NICs seem to be over-utilised on $computername: "
    for ($i=0; $i -lt $Count; $i++)
    {
		[int]$CookedValue = ($sample[$i].CookedValue)/1MB
		if($CookedValue -gt $NetworkBytesThreshold)
		{
			$InstanceWarning = $sample[$i].InstanceName
			$WarningText += " $InstanceWarning with $CookedValue MB/s. "
			$booli = "Yes"
		}
    }
	return $booli,$WarningText
}

function check-OutboundErrors($computername){
    [string]$booli = "No"
	$samples = (Get-counter -ComputerName $computername -Counter $perfOutboundErrors).countersamples
	[string]$WarningText = $null
    foreach ($sample in $Samples)
    {
		[int]$CookedValue = $sample.CookedValue
		if($CookedValue -gt $NetworkOutboundErrors)
		{
			$InstanceWarning = $sample.InstanceName
			$WarningText += "$computername had $CookedValue network outbound packets errors on $InstanceWarning. "
			$booli = "Yes"
		}
    }
    return $booli,$WarningText
}

function get-LDAPSearchTime($computername){
	# String-Boolean workaround
    [string]$booli = "No"
	[string]$boolii = "No"
	[string]$WarningText = "Check our these LDAP spikes on $computername: "
	[string]$WarningText1 = "Check our these LDAP search time averages(last $($samplesNumber+1) checks) on $computername: "
	[int]$total = 0
	[int]$average = 0
	$Samples = (Get-counter -ComputerName $computername -Counter $perfLDAPSearchTime).countersamples
	foreach($Sample in $Samples){
		[string]$LDAPInstance = $Sample.InstanceName
		$HistPath = "C:\TEMP\DATA\LDAP\$($LDAPInstance)_LDAPlog.hist"
		if(!(Test-Path $HistPath)){
			if(!(Test-Path 'C:\TEMP\DATA\LDAP')){
				New-Item 'C:\TEMP\DATA\LDAP' -Type Directory 
			}
			New-Item $HistPath -Type File
			for($i=($SamplesNumber+1);$i -gt 0;$i--){
				$i | Out-File $HistPath -Append
			}
		}
		$list = Get-Content $HistPath
		if(($SamplesNumber+1) -gt $list.count){
			for($i=$list.count;$i -lt ($SamplesNumber+1);$i++){
				$i | Out-File $HistPath -Append
			}
			$list = Get-Content $HistPath
		}
		$list[$SamplesNumber] = $list[$SamplesNumber-1]
		for ($i=($SamplesNumber - 1);$i -gt 0;$i--)
	    {
			$total += $list[$i]
			$list[$i] = $list[$i-1]
		}
		if($sample.CookedValue -gt $LDAPspikethreshold)
		{	
			$timp = Get-Date -format HH:mm:ss
			[int]$CookedValue = $sample.CookedValue
			$WarningText += " LDAP search time spike of $CookedValue ms with DC $LDAPInstance at $timp."
			$booli = "Yes"
		}
		$total += $sample.CookedValue
		$total += $list[0]
		$list[0] = $sample.CookedValue
		$average = $total/($SamplesNumber + 1)
		if($average -gt $LDAPaveragethreshold)
		{
			$WarningText1 += " LDAP search time average of $average ms with DC $LDAPInstance."
			$boolii = "Yes"
		}
	    $list | Out-File $HistPath
	}
    return $booli,$boolii,$WarningText,$WarningText1
}
#endregion functions

#region Sourcing
#Loads the Exchange PS snapin
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010 -ErrorAction SilentlyContinue

#endregion Sourcing

#region Main Script

$MailboxDatabasesList = ($databasesList | Get-MailboxDatabaseCopyStatus)

foreach($Database in $MailboxDatabasesList)
{
	# Builds the replicated DB array...
	if((Get-MailboxDatabase $Database.DatabaseName).ReplicationType -eq "Remote"){
		$dbObj = New-Object PSObject
		$dbObj | Add-Member NoteProperty -Name "ServerName" -Value $Database.MailboxServer
		$dbObj | Add-Member NoteProperty -Name "DatabaseName" -Value $Database.DatabaseName
		$dbObj | Add-Member NoteProperty -Name "ActiveCopy" -Value $Database.ActiveCopy.ToString()
		$dbObj | Add-Member NoteProperty -Name "Status" -Value $Database.Status.ToString()
		$dbObj | Add-Member NoteProperty -Name "CopyQueueLength" -Value $Database.CopyQueueLength
		$dbObj | Add-Member NoteProperty -Name "ReplayQueueLength" -Value $Database.ReplayQueueLength
		$dbObj | Add-Member NoteProperty -Name "ContentIndexState" -Value $Database.ContentIndexState
		$ReplicatedDatabases += $dbObj
	}
	# ...and those non-replicated
	else{
		$dbObj = New-Object PSObject
		$dbObj | Add-Member NoteProperty -Name "ServerName" -Value $Database.MailboxServer
		$dbObj | Add-Member NoteProperty -Name "DatabaseName" -Value $Database.DatabaseName
		$dbObj | Add-Member NoteProperty -Name "Status" -Value $Database.Status.ToString()
		$dbObj | Add-Member NoteProperty -Name "ContentIndexState" -Value $Database.ContentIndexState
		$nonReplicatedDatabases += $dbObj
	}
}

$oddeven = 0

# Generates the DAG table
foreach ($database in $ReplicatedDatabases)
{
	if(($database.Status -ne "Healthy" -and $database.Status -ne "Mounted") -or ($database.CopyQueueLength -gt $QueueWarn) -or ($database.ReplayQueueLength -gt $QueueWarn) -or ($database.ContentIndexState -ne "Healthy"))
	{
		$buli = $True
		$htmltablerow ="<tr"
			if ($oddeven)
			{
				$htmltablerow += " style=""background-color:#F1EFE2"""
				$oddeven=0
			} else
			{
				$oddeven=1
			}
		$htmltablerow += ">"
		$htmltablerow += "<td>$($database.ServerName)</td>"
		$htmltablerow += "<td>$($database.DatabaseName)</td>"
		$htmltablerow += "<td>$($database.ActiveCopy)</td>"				
		
		switch ($($database.Status))
		{
			"Healthy" {$htmltablerow += "<td class=""Pass"" align=""center"">$($database.Status)</td>"}
			"Mounted" {$htmltablerow += "<td class=""Pass"" align=""center"">$($database.Status)</td>"}
			"Seeding" {$htmltablerow += "<td class=""Warn"" align=""center"">$($database.Status)</td>";}
			"SeedingSource" {$htmltablerow += "<td class=""Warn"" align=""center"">$($database.Status)</td>";}
			"Suspended" {$htmltablerow += "<td class=""Fail"" align=""center"">$($database.Status)</td>";}
			"ServiceDown" {$htmltablerow += "<td class=""Fail"" align=""center"">$($database.Status)</td>";}
			"Initializing" {$htmltablerow += "<td class=""Warn"" align=""center"">$($database.Status)</td>";}
			"Resynchronizing" {$htmltablerow += "<td class=""Warn"" align=""center"">$($database.Status)</td>";}
			"Dismounted" {$htmltablerow += "<td class=""Fail"" align=""center"">$($database.Status)</td>";}
			"Mounting" {$htmltablerow += "<td class=""Warn"" align=""center"">$($database.Status)</td>";}
			"Dismounting" {$htmltablerow += "<td class=""Fail"" align=""center"">$($database.Status)</td>";}
			"DisconnectedAndHealthy" {$htmltablerow += "<td class=""Warn"" align=""center"">$($database.Status)</td>";}
			"DisconnectedAndResynchronizing" {$htmltablerow += "<td class=""Warn"" align=""center"">$($database.Status)</td>";}
			"FailedAndSuspended" {$htmltablerow += "<td class=""Fail"" align=""center"">$($database.Status)</td>";}
			"SinglePageRestore" {$htmltablerow += "<td class=""Warn"" align=""center"">$($database.Status)</td>";}
			default {$htmltablerow += "<td class=""Fail"" align=""center"">$($database.Status)</td>";}
		}
		
		# Copy queue checks
		if ($($database.CopyQueueLength) -gt $QueueAlert)
		{
			$htmltablerow += "<td class=""Fail"" align=""center"">$($database.CopyQueueLength)</td>"
		}
		elseif ($($database.CopyQueueLength) -gt $QueueWarn)
		{
			$htmltablerow += "<td class=""Warn"" align=""center"">$($database.CopyQueueLength)</td>"
		}
		else
		{
			$htmltablerow += "<td class=""Pass"" align=""center"">$($database.CopyQueueLength)</td>"	
		}
		
		# Replay queue checks
		if ($($database.ReplayQueueLength) -gt $QueueAlert)
		{
			$htmltablerow += "<td class=""Fail"" align=""center"">$($database.ReplayQueueLength)</td>"
		}
		elseif ($($database.ReplayQueueLength) -gt $QueueWarn)
		{
			$htmltablerow += "<td class=""Warn"" align=""center"">$($database.ReplayQueueLength)</td>"
		}
		else
		{
			$htmltablerow += "<td class=""Pass"" align=""center"">$($database.ReplayQueueLength)</td>"	
		}
		switch ($($database.ContentIndexState))
		{
			"Healthy" {$htmltablerow += "<td class=""Pass"" align=""center"">$($database.ContentIndexState)</td>"}
			"Crawling" {$htmltablerow += "<td class=""Warn"" align=""center"">$($database.ContentIndexState)</td>"}
			default {$htmltablerow += "<td class=""Fail"" align=""center"">$($database.ContentIndexState)</td>"}
		}
		$htmltablerow +="</tr>"
		$htmlDatabaseCopies += $htmltablerow
	}
}
$htmlDatabaseCopies += $dbError
# If no problems were found, it'll display an empty table mentioning that
if (!$buli)
{
	$htmlDatabaseCopies = "<table border=""0"" cellpadding=""1.5"" width=""100%"" style=""font-size:8pt;font-family:Arial,sans-serif"">
							<tr>
							<th>DAG & Replicated Databases Health Check</th>
							</tr>
							<tr><td class=""pass"">All replicated databases are mounted on their primary servers.</td></tr>
							<tr><td class=""pass"">All passive database copies are healthy.</td></tr>
							<tr><td class=""pass"">Copy/Replay queues are under the defined threshold.</td></tr>
							<tr><td class=""pass"">Content Index State is healthy for each replicated database.</td></tr>"
		
}
$htmlDatabaseCopies += "</table></p>"

$oddeven = 0

foreach ($database in $nonReplicatedDatabases)
{
	if(($database.Status -ne "Healthy" -and $database.Status -ne "Mounted") -or ($database.ContentIndexState -ne "Healthy"))
	{
		$buliv = $True
		$htmltablerow ="<tr"
			if ($oddeven)
			{
				$htmltablerow += " style=""background-color:#F1EFE2"""
				$oddeven=0
			} else
			{
				$oddeven=1
			}
		$htmltablerow += ">"
		$htmltablerow += "<td>$($database.ServerName)</td>"
		$htmltablerow += "<td>$($database.DatabaseName)</td>"		
		
		switch ($($database.Status))
		{
			"Healthy" {$htmltablerow += "<td class=""Pass"" align=""center"">$($database.Status)</td>"}
			"Mounted" {$htmltablerow += "<td class=""Pass"" align=""center"">$($database.Status)</td>"}
			"Seeding" {$htmltablerow += "<td class=""Warn"" align=""center"">$($database.Status)</td>";}
			"SeedingSource" {$htmltablerow += "<td class=""Warn"" align=""center"">$($database.Status)</td>";}
			"Suspended" {$htmltablerow += "<td class=""Fail"" align=""center"">$($database.Status)</td>";}
			"ServiceDown" {$htmltablerow += "<td class=""Fail"" align=""center"">$($database.Status)</td>";}
			"Initializing" {$htmltablerow += "<td class=""Warn"" align=""center"">$($database.Status)</td>";}
			"Resynchronizing" {$htmltablerow += "<td class=""Warn"" align=""center"">$($database.Status)</td>";}
			"Dismounted" {$htmltablerow += "<td class=""Fail"" align=""center"">$($database.Status)</td>";}
			"Mounting" {$htmltablerow += "<td class=""Warn"" align=""center"">$($database.Status)</td>";}
			"Dismounting" {$htmltablerow += "<td class=""Fail"" align=""center"">$($database.Status)</td>";}
			"DisconnectedAndHealthy" {$htmltablerow += "<td class=""Warn"" align=""center"">$($database.Status)</td>";}
			"DisconnectedAndResynchronizing" {$htmltablerow += "<td class=""Warn"" align=""center"">$($database.Status)</td>";}
			"FailedAndSuspended" {$htmltablerow += "<td class=""Fail"" align=""center"">$($database.Status)</td>";}
			"SinglePageRestore" {$htmltablerow += "<td class=""Warn"" align=""center"">$($database.Status)</td>";}
			default {$htmltablerow += "<td class=""Fail"" align=""center"">$($database.Status)</td>";}
		}
		
		switch ($($database.ContentIndexState))
		{
			"Healthy" {$htmltablerow += "<td class=""Pass"" align=""center"">$($database.ContentIndexState)</td>"}
			"Crawling" {$htmltablerow += "<td class=""Warn"" align=""center"">$($database.ContentIndexState)</td>"}
			default {$htmltablerow += "<td class=""Fail"" align=""center"">$($database.ContentIndexState)</td>"}
		}
		$htmltablerow +="</tr>"
		$htmlDatabase += $htmltablerow
	}
}
if (!$buliv)
{
	$htmlDatabase = "<table border=""0"" cellpadding=""1.5"" width=""100%"" style=""font-size:8pt;font-family:Arial,sans-serif"">
							<tr>
							<th>Non-Replicated Databases Health Check</th>
							</tr>
							<tr><td class=""pass"">All non-replicated databases are mounted or healthy.</td></tr>
							<tr><td class=""pass"">Content Index State is healthy for each non-replicated database.</td></tr>"
		
}
$htmlDatabase += "</table></p>"

$QueueList = ($servers | Where { $_.isHubTransportServer -eq $true } | get-queue)
foreach($Queue in $QueueList)
{
	$qObj = New-Object PSObject
	$qObj | Add-Member NoteProperty -Name "Identity" -Value $Queue.Identity
	$qObj | Add-Member NoteProperty -Name "DeliveryType" -Value $Queue.DeliveryType
	$qObj | Add-Member NoteProperty -Name "Status" -Value $Queue.Status.ToString()
	$qObj | Add-Member NoteProperty -Name "MessageCount" -Value $Queue.MessageCount
	$qObj | Add-Member NoteProperty -Name "NextHopDomain" -Value $Queue.NextHopDomain
	$QueuesInfo += $qObj
}
$oddeven=0
foreach ($line in $QueuesInfo)
{
	if($line.MessageCount -gt $WarnHTQueue -or ($line.Status -ne "Ready" -and $line.Status -ne "Active"))
	{
		$bulii = $True
		$htmltablerow="<tr "
			if ($oddeven)
			{
				$htmltablerow+=" style=""background-color:#F1EFE2"""
				$oddeven=0
			} else
			{
				$oddeven=1
			}
		$htmltablerow += ">"
		$htmltablerow += "<td>$($line.Identity)</td>"
		$htmltablerow += "<td>$($line.DeliveryType)</td>"
		if ($line.Status -eq "Ready"){
			$htmltablerow += "<td class=""Pass"" align=""center"">$($line.Status)</td>"	
		}
		else
		{
			$htmltablerow += "<td class=""Fail"" align=""center"">$($line.Status)</td>"
		}
		if($line.MessageCount -gt $FailHTQueue)
		{
			$htmltablerow += "<td class=""Fail"" align=""center"">$($line.MessageCount)</td>"
		}
		elseif($line.MessageCount -gt $WarnHTQueue)
		{
			$htmltablerow += "<td class=""Warn"" align=""center"">$($line.MessageCount)</td>"
		}
		else
		{
			$htmltablerow += "<td class=""Pass"" align=""center"">$($line.MessageCount)</td>"
		}
		$htmltablerow += "<td>$($line.NextHopDomain)</td>"
		$htmltablerow +="</tr>"
		$htmlHTQueues += $htmltablerow
	}
	
}

if (!$bulii)
{	
	$htmlHTqueues = "<table border=""0"" cellpadding=""1.5"" width=""100%"" style=""font-size:8pt;font-family:Arial,sans-serif"">
					<tr>
					<th>Hub Transport Queues Check</th>
					</tr>"
	$htmlHTQueues += "<tr><td class=""pass"">Transport queues are Ready or Active.</td></tr>"
	$htmlHTQueues += "<tr><td class=""pass"">Transport queues are under the warning threshold of $WarnHTQueue on all transport servers.</td></tr>"
}
$htmlHTQueues += "</table></p>"

foreach ($db in $databasesList)
{
	if ($db.LastFullBackup -eq $null -and $db.LastIncrementalBackup -eq $null){[String]$ago = "Never"}
	elseif ($db.LastFullBackup -eq $null){
		[int]$ago = ($now - $db.LastIncrementalBackup).TotalHours
		$ago = "{0:N0}" -f $ago}
	elseif ($db.LastIncrementalBackup -eq $null){
		[int]$ago = ($now - $db.LastFullBackup).TotalHours
		$ago = "{0:N0}" -f $ago}
	elseif (($now - $db.LastFullBackup).TotalHours -gt ($now - $db.LastIncrementalBackup).TotalHours){
		[int]$ago = ($now - $db.LastIncrementalBackup).TotalHours
		$ago = "{0:N0}" -f $ago}
	else{
		[int]$ago = ($now - $db.LastFullBackup).TotalHours
		$ago = "{0:N0}" -f $ago}
	
	$dbObj = New-Object PSObject
	$dbObj | Add-Member NoteProperty -Name "Server" -Value $db.MasterServerOrAvailabilityGroup
	$dbObj | Add-Member NoteProperty -Name "Database" -Value $db.name
	$dbObj | Add-Member NoteProperty -Name "HrsAgo" -Value $ago
	$dbObj | Add-Member NoteProperty -Name "LastFullBackup" -Value $db.LastFullBackup
	$dbObj | Add-Member NoteProperty -Name "LastIncrementalBackup" -Value $db.LastIncrementalBackup
	$BackupsList += $dbObj
}

$oddeven=0

foreach ($line in $BackupsList)
{
	if($line.HrsAgo -gt $Bkpthreshold -or $line.HrsAgo -eq "Never")
	{
		$buliii = $True
		$htmltablerow="<tr "
			if ($oddeven)
			{
				$htmltablerow+=" style=""background-color:#F1EFE2"""
				$oddeven=0
			}
			else
			{
				$oddeven=1
			}
		$htmltablerow += ">"
		$htmltablerow += "<td>$($line.Server)</td>"
		$htmltablerow += "<td>$($line.Database)</td>"
		$htmltablerow += "<td class=""Fail"" align=""center"">$($line.HrsAgo)</td>"	
		$htmltablerow += "<td>$($line.LastFullBackup)</td>"
		$htmltablerow += "<td>$($line.LastIncrementalBackup)</td>"
		$htmltablerow += "</tr>"
		$htmlBackupList += $htmltablerow
	}
}
if (!$buliii)
{
	$htmlBackupList = "
					<table border=""0"" cellpadding=""1.5"" width=""100%"" style=""font-size:8pt;font-family:Arial,sans-serif"">
					<tr>
					<th>Databases Backup Check</th>
					</tr>"
	$htmlBackupList += "<tr><td class=""pass"">All databases have been backed up in the last $Bkpthreshold hours.</td></tr>"
}
$htmlBackupList += "</table></p>"

[bool]$oddeven= $false

# Each Exchange server's performance check
foreach($server in $servers)
{
	$ping = new-object System.Net.NetworkInformation.Ping
	$result = $ping.send($server)
	
	# If the ping fails, it'll try one more time in case it's a false positive
	if ($result -eq $null)
	{
		$pingagain = new-object System.Net.NetworkInformation.Ping
		$result = $pingagain.send($server)
		if($result -eq $null){$result = "error"}
	}
	else
	{$result = $result.status.ToString()}
	
	# If the server is not responsing, it's not going to pass through the other checks
	if ($result –ne "Success")
	{
		#Server is not reachable
		$htmlPerfcheck += "<tr "
			if ($oddeven)
			{
				$htmlPerfcheck+=" style=""background-color:#F1EFE2"""
				$oddeven=$false
			} else
			{
				$oddeven=$true
			}
		$htmlPerfcheck += ">"
		$htmlPerfcheck += "<td class=""fail""; colspan=""19"">$Server failed to respond to ping.</td></tr>"
	}
	else
	{
		$htmlPerfcheck += "<tr "
		if ($oddeven)
		{
			$htmlPerfcheck+=" style=""background-color:#F1EFE2"""
			$oddeven=$false
		} else
		{
			$oddeven=$true
		}
		$htmlPerfcheck += ">"
		$htmlPerfcheck += "<td>$server</td>"
		
		$laststart = [System.Management.ManagementDateTimeconverter]::ToDateTime((Get-WmiObject -Class Win32_OperatingSystem -computername $server).LastBootUpTime)
		[int]$uptime = (New-TimeSpan $laststart $now).TotalHours
		[int]$uptime = "{0:N0}" -f $uptime
		if ($uptime -ge $UptimeWarn) 
		{
			$htmlPerfcheck += "<td class=""Pass"" align=""center"">Pass</td>"
		}
		else 
		{ 
			$htmlPerfcheck += "<td class=""Fail"" align=""center"" title=""$server is running for the last $uptime hours only."">Fail</td>"
		}
		$var = check-DiskUsage -computername $server
		if($var[0] -eq "No"){
			$htmlPerfcheck += "<td class=""Pass"" align=""center"">Pass</td>"
		}
		else
		{
			$val = $var[1]
			$htmlPerfcheck += "<td class=""Fail"" align=""center"" title=""$val"">Fail</td>"
		}
		$var = get-ProcessorTime -computername $server
		if($var[0] -eq "No"){
			$htmlPerfcheck += "<td class=""Pass"" align=""center"">Pass</td>"
		}
		else
		{
			$val = $var[1]
			$htmlPerfcheck += "<td class=""Fail"" align=""center"" title=""$val"">Fail</td>"
		}
		$var = get-AvailableMemory -computername $server
		if($var[0] -eq "No"){
			$htmlPerfcheck += "<td class=""Pass"" align=""center"">Pass</td>"
		}
		else
		{
			$val = $var[1]
			$htmlPerfcheck += "<td class=""Fail"" align=""center"" title=""$val"">Fail</td>"
		}
		$var = get-MemoryPages -computername $server
		if($var[0] -eq "No"){
			$htmlPerfcheck += "<td class=""Pass"" align=""center"">Pass</td>"
		}
		else
		{
			$val = $var[1]
			$htmlPerfcheck += "<td class=""Fail"" align=""center"" title=""$val"">Fail</td>"
		}
		$var = get-TimeinGC -computername $server
		if($var[0] -eq "No"){
			$htmlPerfcheck += "<td class=""Pass"" align=""center"">Pass</td>"
		}
		else
		{
			$val = $var[1]
			$htmlPerfcheck += "<td class=""Fail"" align=""center"" title=""$val"">Fail</td>"
		}
		$var = get-NetworkBytes -computername $server
		if($var[0] -eq "No"){
			$htmlPerfcheck += "<td class=""Pass"" align=""center"">Pass</td>"
		}
		else
		{
			$val = $var[1]
			$htmlPerfcheck += "<td class=""Fail"" align=""center"" title=""$val"">Fail</td>"
		}
		$var = check-OutboundErrors -computername $server
		if($var[0] -eq "No"){
			$htmlPerfcheck += "<td class=""Pass"" align=""center"">Pass</td>"
		}
		else
		{
			$val = $var[1]
			$htmlPerfcheck += "<td class=""Fail"" align=""center"" title=""$val"">Fail</td>"
		}
		$var = get-LDAPSearchTime -computername $server
		if($var[0] -eq "No"){
			$htmlPerfcheck += "<td class=""Pass"" align=""center"">Pass</td>"
		}
		else
		{
			$val = $var[2]
			$htmlPerfcheck += "<td class=""Fail"" align=""center"" title=""$val"">Fail</td>"
		}
		if($var[1] -eq "No"){
			$htmlPerfcheck += "<td class=""Pass"" align=""center"">Pass</td>"
		}
		else
		{
			$val = $var[3]
			$htmlPerfcheck += "<td class=""Fail"" align=""center"" title=""$val"">Fail</td>"
		}
		[bool]$bulvi = $false
		if ($server.isMailboxServer){
			foreach($db in $databaseslist){
				if($db.MountedOnServer -eq $Server.Fqdn){$bulvi = $true}
			}
		}
		if ($bulvi)
		{
			$var = check-MAPIconnectivity -computername $server
			if ($var[0] -eq "No"){
				$htmlPerfcheck += "<td class=""Pass"" align=""center"">Pass</td>"
			}
			else
			{
				$val = $var[1]
				$htmlPerfcheck += "<td class=""Fail"" align=""center"" title=""$val"">Fail</td>"
			}
			
			$var = check-Mailflow -computername $server
			if ($var[0] -eq "No"){
				$htmlPerfcheck += "<td class=""Pass"" align=""center"">Pass</td>"
			}
			else
			{
				$val = $var[1]
				$htmlPerfcheck += "<td class=""Fail"" align=""center"" title=""$val"">Fail</td>"
			}
			$var = get-DBwritesLatency -computername $server
			if ($var[0] -eq "No"){
				$htmlPerfcheck += "<td class=""Pass"" align=""center"">Pass</td>"
			}
			else
			{
				$val = $var[1]
				$htmlPerfcheck += "<td class=""Fail"" align=""center"" title=""$val"">Fail</td>"
			}
			
		}
		elseif($server.isMailboxServer)
		{
			$htmlPerfcheck += "<td class=""Fail"" align=""center"" title=""There is no database mounted on the mailbox server($server) so MAPI Connectivity test couldn't be done."">Fail</td>"
			$htmlPerfcheck += "<td class=""Fail"" align=""center"" title=""There is no database mounted on the mailbox server($server) so Mailflow test couldn't be done."">Fail</td>"
			
			$var = get-DBwritesLatency -computername $server
			if ($var[0] -eq "No"){
				$htmlPerfcheck += "<td class=""Pass"" align=""center"">Pass</td>"
			}
			else
			{
				$val = $var[1]
				$htmlPerfcheck += "<td class=""Fail"" align=""center"" title=""$val"">Fail</td>"
			}
		}
		else
		{
			$htmlPerfcheck += "<td align=""center"" title=""This check is not compatible with this server role."">N/A</td><td align=""center"" title=""This check is not compatible with this server role."">N/A</td><td align=""center"" title=""This check is not compatible with this server role."">N/A</td>"
		}
		
		if ($server.isClientAccessServer)
		{
			$var = get-RPCrequests -computername $server
			if ($var[0] -eq "No"){
				$htmlPerfcheck += "<td class=""Pass"" align=""center"">Pass</td>"
			}
			else
			{
				$val = $var[1]
				$htmlPerfcheck += "<td class=""Fail"" align=""center"" title=""$val"">Fail</td>"
			}
			
			$var = get-RPClatency -computername $server
			if ($var[0] -eq "No"){
				$htmlPerfcheck += "<td class=""Pass"" align=""center"">Pass</td>"
			}
			else
			{
				$val = $var[1]
				$htmlPerfcheck += "<td class=""Fail"" align=""center"" title=""$val"">Fail</td>"
			}
			
			$var = get-OWAsearchTime -computername $server
			if ($var[0] -eq "No"){
				$htmlPerfcheck += "<td class=""Pass"" align=""center"">Pass</td>"
			}
			else
			{
				$val = $var[1]
				$htmlPerfcheck += "<td class=""Fail"" align=""center"" title=""$val"">Fail</td>"
			}
		}
		else
		{
			$htmlPerfcheck += "<td align=""center"" title=""This check is not compatible with this server role."">N/A</td><td align=""center"" title=""This check is not compatible with this server role."">N/A</td><td align=""center"" title=""This check is not compatible with this server role."">N/A</td>"
		}
		
		if ($server.isHubTransportServer)
		{
			$var = get-PoisonQueues -computername $server
			if ($var[0] -eq "No"){
				$htmlPerfcheck += "<td class=""Pass"" align=""center"">Pass</td>"
			}
			else
			{
				$val = $var[1]
				$htmlPerfcheck += "<td class=""Fail"" align=""center"" title=""$val"">Fail</td>"
			}
			
			$var = get-VersionBuckets -computername $server
			if ($var[0] -eq "No"){
				$htmlPerfcheck += "<td class=""Pass"" align=""center"">Pass</td>"
			}
			else
			{
				$val = $var[1]
				$htmlPerfcheck += "<td class=""Fail"" align=""center"" title=""$val"">Fail</td>"
			}		
		}
		else
		{
			$htmlPerfcheck += "<td align=""center"" title=""This check is not compatible with this server role."">N/A</td><td align=""center"" title=""This check is not compatible with this server role."">N/A</td>"
		}
		if ($server.isUnifiedMessagingServer)
		{
			$var = get-UMsuccess -computername $server
			if ($var[0] -eq "No"){
				$htmlPerfcheck += "<td class=""Pass"" align=""center"">Pass</td>"
			}
			else
			{
				$val = $var[1]
				$htmlPerfcheck += "<td class=""Fail"" align=""center"" title=""$val"">Fail</td>"
			}
		}
		else
		{
			$htmlPerfcheck += "<td align=""center"" title=""This check is not compatible with this server role."">N/A</td>"
		}
		$htmlPerfcheck +="</tr>"
	}
}

$htmlPerfcheck += "</table></p>"

#  Final Report
$ReportTime = Get-Date

# Remove the <meta> line in the next string variable ($htmlHead) if you don't want the HTML to auto-refresh

$htmlHead="<html>
			<meta http-equiv=""refresh"" content=""30;url=report.html"">
			<style>
			BODY{font-family: Arial; font-size: 8pt;}
			H1{font-size: 16px;}
			H2{font-size: 14px;}
			H3{font-size: 12px;}
			TH{border: 0px; background: #DCD8C0; padding: 0px; color: #000000;}
			TD{border: 0px; padding: 1px; }
			td.pass{background: #99CC99;}
			td.passeven{background: #8FBF8F;}
			td.warn{background: #FFCC00;}
			td.fail{background: #CC0000; color: #ffffff;}
			</style>
			<title>Exchange Monitor</title>
			<body>
			<h3 style=""color:#C0C0C0;"">v2.1 (7/22/2013)</h3>
			<h1 align=""center"">Microsoft Exchange Health Check</h1>
			<h2 align=""center"">Report generated: $ReportTime (CET)</h2>"
$ReportOutput = $htmlHead + $htmlDatabaseCopies + $htmlDatabase + $htmlHTQueues + $htmlBackupList + $htmlPerfcheck

if ($buli -or $bulii -or $buliii -or $buliv){$bolFailover = $true}

# If a problem is found, it'll warn you in the email subject.
if ($bolFailover) { $subject= "Exchange Health Report $date. WARNING!"
}
else { $subject="Exchange Health Report $date"}

$ReportOutput += "</table>
			<font font-family: Arial; font-size: 8pt;><i>Note: Hold your mouse over the Fail box to get details about the error.</i></font>
			<br>
			<br>
			<font font-family: Arial; font-size: 8pt;>This report took $(((Get-Date) - $now).TotalSeconds) seconds to be generated.</font>
			</p>
			</body>
			</html>"

$HTMLmessage = $ReportOutput | Out-String
$HTMLmessage | Out-File $HTMLReport

if($EmailRecipients){Send-MailMessage -Attachments $HTMLReport -To $EmailRecipients -From $EmailSender -Subject $subject -BodyAsHtml $HTMLmessage -SmtpServer $EmailRelay}

#endregion Main Script