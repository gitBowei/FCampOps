# +------------------------------------------------------+
# | Script Name: 2010_health_check_html.ps1              |
# | Version: 1.4                                         |
# | Author: Frank Tanner III                             |
# | PowerShell Version: 2.0                              |
# |------------------------------------------------------|
# | The purpose of this script is to perform the daily   |
# | Microsoft Exchange Server 2010 health checks and     |
# | e-mail the results in an HTML format.                |
# |------------------------------------------------------|
# | Change Log                                           |
# |                                                      |
# | 1.0 - Initial Script Creation                        |
# | 1.1 - Miscellaneous code cleanup.                    |
# | 1.2 - Added additional warning levels to some        |
# |       sections.                                      |
# |       Split the replication status out to its own    |
# |       function.                                      |
# |       Changed the table width from a fixed value of  |
# |       900px to be 95% of page size.                  |
# | 1.3 - Changed warning and critical thresholds for    |
# |       mailbox database sizes.                        |
# |       Miscellaneous report formatting.               |
# |       Chanded warning threshold for copy queue       |
# |       length.                                        |
# |       Miscellaneous code cleanup.                    |
# | 1.4 - Changed database size warning threshold to     |
# |       200GB and the critical threshold to 250GB.     |
# +------------------------------------------------------+
Param ([string[]] $EmailTo = "no-reply@example.com")

# +---------------------------------+
# | Load Snapins and Functions      |
# +---------------------------------+
# Test for PowerShell Version
If ($host.version.major -lt 2) {
   Write-Host "You must be running PowerShell version 2.0 or later.  Exiting..." -Foregroundcolor Yellow
}

# Load the Microsoft Exchange Server 2010 PowerShell Snapin
If ((Get-PSSnapin -Name Microsoft.Exchange.Management.PowerShell.E2010 -ErrorAction SilentlyContinue) -eq $Null) {
    Add-PsSnapin Microsoft.Exchange.Management.PowerShell.E2010
}

# +---------------------------------+
# | Variables                       |
# +---------------------------------+
# The variable $exscripts is built into the Exchange Management Shell and points to the directory where Microsoft supplied PowerShell scripts are.
$output_file = "g:\audit\exchange_health_check.html"
$email_body = " "
$email_from = "no-reply@example.com"
$email_subject = "Daily Microsoft Exchange 2010 Server Environment Health Check $current_date_time"

# HTML Reports Variables
$report_background = "#006699" # background of the html reports (shade of blue)
$report_font_color = "#000000" # report font color (black)
$table_background = "#FFFFFF" # background of the report tables (white)
$table_header_background = "#3333FF" # background of the report table header (shade of blue)
$table_header_text = "#FFFFFF" # report table header text (white)
$column_header_background = "#CCCCCC" # background of the report table column headers (light grey)
$informational_color = "#00CC99" # informational highlighted information (grey-green)
$good_color = "#00CC00" # good highlighted information (green)
$warning_color = "#FFFF00" # warning highlighted information (yellow)
$warn_crit_color = "#FFA500" # critical-warning highlighted information (orange)
$critical_color = "#FF0000" # critical highlighted information (red)
$exemption_color = "#BCF5A9" # exempted information (light grey)

# Microsoft Exchange Threshold Variables
# Backup Thresholds
$incremental_backup_warning = [DateTime]::Now.AddDays(-1)
$incremental_backup_critical = [DateTime]::Now.AddDays(-3)
$full_backup_critical = [DateTime]::Now.AddDays(-8)
# Database Thresholds
$database_size_warn = 200
$database_size_crit = 250
# Mailbox Database Replication Thresholds
$copy_queue_length_warn = 1
$copy_queue_length_crit = 5
$replay_queue_length_warn = 5
$replay_queue_length_crit = 10
# MAPI Thresholds
$mapi_latency_warn = 75
$mapi_latency_crit = 100
# Transport Queue Thesholds
$transport_queue_warn = 25
$transport_queue_crit = 50


# +---------------------------------+
# | Functions                       |
# +---------------------------------+
Function check_database_backup_status {
	# Table Header Information
	Write-Output "<table border = '1' cellspacing = '1' cellpadding = '1' width = '90%' bgcolor = '$table_background' align = 'center'>" | Out-File "$output_file" -Append -Encoding ASCII
	Write-Output "  <tr>" | Out-File "$output_file" -Append -Encoding ASCII
	Write-Output "    <td colspan = '4' bgcolor = '$table_header_background'><center><font color = '$table_header_text'><b>Mailbox Database Backup Status</b></font></center></td>" | Out-File "$output_file" -Append -Encoding ASCII
	Write-Output "  </tr>" | Out-File "$output_file" -Append -Encoding ASCII
	# Column Header Information
	$back_color = "$table_background"
	Write-Output "  <tr bgcolor = '$column_header_background'>" | Out-File "$output_file" -Append -Encoding ASCII
	Write-Output "    <td align='center'><b>Database Name</b></td>" | Out-File "$output_file" -Append -Encoding ASCII
	Write-Output "    <td align='center'><b>Last Incremental Backup</b></td>" | Out-File "$output_file" -Append -Encoding ASCII
	Write-Output "    <td align='center'><b>Last Full Backup</b></td>" | Out-File "$output_file" -Append -Encoding ASCII
	Write-Output "    <td align='center'><b>Backup in Progress</b></td>" | Out-File "$output_file" -Append -Encoding ASCII
	Write-Output "  </tr>" | Out-File "$output_file" -Append -Encoding ASCII
	# Table Row Data
	$backup_status = Get-MailboxDatabase -Status | Where {$_.ExchangeVersion -like "*0.10*"} | Sort-Object Name
	$backup_status | ForEach-Object {
	$back_color = "$table_background"
		If ($_.LastIncrementalBackup -le $incremental_backup_warning) {
			$back_color = "$warning_color"
		}
		ElseIf (($_.LastIncrementalBackup -le $incremental_backup_critical) -or ($_.LastFullBackup -le $full_backup_critical)) {
			$back_color = "$critical_color"
		}
		If ((-not $_.LastIncrementalBackup) -or (-not $_.LastFullBackup)) {
            $back_color = "$table_background"
		}
		If ($_.BackupInProgress) {
			$back_color = "$informational_color"
		}
		If ($_.CircularLoggingEnabled) {
			$back_color = "$exemption_color"
		}
		Write-Output "  <tr bgcolor = '$back_color'>"
		Write-Output "    <td>"$_.Name"</td>"
		If (-not $_.LastIncrementalBackup) {
			Write-Output "    <td align='center'>-</td>"
		}
		Else {
			Write-Output "    <td>"$_.LastIncrementalBackup"</td>"
		}
		If (-not $_.LastFullBackup) {
			Write-Output "    <td align='center'>-</td>"
		}
		Else {
			Write-Output "    <td>"$_.LastFullBackup"</td>"
		}
		Write-Output "    <td>"$_.BackupInProgress"</td>"
		Write-Output "  </tr>"
	} | Out-File $output_file -Append -Encoding Ascii
	Write-Output "</table><br>" | Out-File "$output_file" -Append -Encoding ASCII
}

Function check_database_mount_status {
	# Table Header Information
	Write-Output "<table border = '1' cellspacing = '1' cellpadding = '1' width = '90%' bgcolor = '$table_background' align = 'center'>" | Out-File "$output_file" -Append -Encoding ASCII
	Write-Output "  <tr>" | Out-File "$output_file" -Append -Encoding ASCII
	Write-Output "    <td colspan = '4' bgcolor = '$table_header_background'><center><font color = '$table_header_text'><b>Mailbox Database Mount Status</b></font></center></td>" | Out-File "$output_file" -Append -Encoding ASCII
	Write-Output "  </tr>" | Out-File "$output_file" -Append -Encoding ASCII
	# Column Header Information
	$back_color = "$table_background"
	Write-Output "  <tr bgcolor = '$column_header_background'>" | Out-File "$output_file" -Append -Encoding ASCII
	Write-Output "    <td align='center'><b>Database Name</b></td>" | Out-File "$output_file" -Append -Encoding ASCII
	Write-Output "    <td align='center'><b>Mounted on Server</b></td>" | Out-File "$output_file" -Append -Encoding ASCII
	Write-Output "    <td align='center'><b>Mount Status</b></td>" | Out-File "$output_file" -Append -Encoding ASCII
	Write-Output "    <td align='center'><b>Mount at Startup</b></td>" | Out-File "$output_file" -Append -Encoding ASCII
	Write-Output "  </tr>" | Out-File "$output_file" -Append -Encoding ASCII
	# Table Row Data
	$mount_status = Get-MailboxDatabase -Status | Where {$_.ExchangeVersion -like "*0.10*"} | Sort-Object Name
	$mount_status | ForEach-Object {
		$back_color = "$table_background"
		If (-not $_.Mounted) {
			$back_color = "$critical_color"
		}
		Write-Output "  <tr bgcolor = '$back_color'>"
		Write-Output "    <td>"$_.Name"</td>"
		Write-Output "    <td>"$_.Server.Name"</td>"
		Write-Output "    <td>"$_.Mounted"</td>"
		Write-Output "    <td>"$_.MountAtStartup"</td>"
		Write-Output "  </tr>"
	} | Out-File $output_file -Append -Encoding Ascii
	Write-Output "</table><br>" | Out-File "$output_file" -Append -Encoding ASCII
}

Function check_database_statistics {
	# Table Header Information
	Write-Output "<table border = '1' cellspacing = '1' cellpadding = '1' width = '90%' bgcolor = '$table_background' align = 'center'>" | Out-File "$output_file" -Append -Encoding ASCII
	Write-Output "  <tr>" | Out-File "$output_file" -Append -Encoding ASCII
	Write-Output "    <td colspan = '8' bgcolor = '$table_header_background'><center><font color = '$table_header_text'><b>Mailbox Database Statistics</b></font></center></td>" | Out-File "$output_file" -Append -Encoding ASCII
	Write-Output "  </tr>" | Out-File "$output_file" -Append -Encoding ASCII
	# Column Header Information
	$back_color = "$table_background"
	Write-Output "  <tr bgcolor = '$column_header_background'>" | Out-File "$output_file" -Append -Encoding ASCII
	Write-Output "    <td align='center'><b>Database Name</b></td>" | Out-File "$output_file" -Append -Encoding ASCII
	Write-Output "    <td align='center'><b>Activation Preference</b></td>" | Out-File "$output_file" -Append -Encoding ASCII
	Write-Output "    <td align='center'><b>Exclude from Automatic Provisioning</b></td>" | Out-File "$output_file" -Append -Encoding ASCII
	Write-Output "    <td align='center'><b>Circular Logging Enabled</b></td>" | Out-File "$output_file" -Append -Encoding ASCII
	Write-Output "    <td align='center'><b>Database Size<br>(in GB)</b></td>" | Out-File "$output_file" -Append -Encoding ASCII
	Write-Output "    <td align='center'><b>Database Whitespace<br>(in GB)</b></td>" | Out-File "$output_file" -Append -Encoding ASCII
	Write-Output "    <td align='center'><b>Mailbox Count</b></td>" | Out-File "$output_file" -Append -Encoding ASCII
	Write-Output "    <td align='center'><b>Average Mailbox Size<br>(in MB)</b></td>" | Out-File "$output_file" -Append -Encoding ASCII
	Write-Output "  </tr>" | Out-File "$output_file" -Append -Encoding ASCII
	# Table Row Data
	$mailbox_databases = Get-MailboxDatabase -Status | Sort-Object Name
	ForEach ($mailbox_database in $mailbox_databases) {
		$database_size = $mailbox_database.DatabaseSize
		$mailbox_count = @(Get-Mailbox -Database $mailbox_database.Name).Count
		$average_mailbox_size = Get-MailboxStatistics -Database $mailbox_database.Name | %{$_.TotalItemSize.Value.ToMB()} | Measure-Object -Average
		$database_size_rounded = [System.Math]::Round($database_size.ToGB(),2)
		$whitespace_size_rounded = [System.Math]::Round($mailbox_database.AvailableNewMailboxSpace.ToGB(),2)
		$average_mailbox_size_rounded = [System.Math]::Round($average_mailbox_size.Average,2)
		$activation_preference = $mailbox_database.ActivationPreference
		If ($database_size_rounded -ge $database_size_crit) {
			$back_color = "$critical_color"
		}
		ElseIf ($database_size_rounded -ge $database_size_warn) {
			$back_color = "$warning_color"
		}
		ElseIf (($mailbox_database.IsExcludedFromProvisioning) -or ($mailbox_database.CircularLoggingEnabled)) {
			$back_color = "$exemption_color"
		}
		Else {
			$back_color = "$table_background"
		}
		Write-Output "  <tr bgcolor = '$back_color'>" | Out-File $output_file -Append -Encoding Ascii
		Write-Output "    <td>"$mailbox_database.Name"</td>" | Out-File $output_file -Append -Encoding Ascii
		Write-Output "    <td>"$activation_preference"</td>" | Out-File $output_file -Append -Encoding Ascii
		Write-Output "    <td>"$mailbox_database.IsExcludedFromProvisioning"</td>" | Out-File $output_file -Append -Encoding Ascii
		Write-Output "    <td>"$mailbox_database.CircularLoggingEnabled"</td>" | Out-File $output_file -Append -Encoding Ascii
		Write-Output "    <td align='center'>"$database_size_rounded"</td>" | Out-File $output_file -Append -Encoding Ascii
		Write-Output "    <td align='center'>"$whitespace_size_rounded"</td>" | Out-File $output_file -Append -Encoding Ascii
		Write-Output "    <td align='center'>"$mailbox_count"</td>" | Out-File $output_file -Append -Encoding Ascii
		Write-Output "    <td align='center'>"$average_mailbox_size_rounded"</td>" | Out-File $output_file -Append -Encoding Ascii
		Write-Output "  </tr>" | Out-File $output_file -Append -Encoding Ascii
	}
	Write-Output "</table><br>" | Out-File "$output_file" -Append -Encoding ASCII
}

Function check_mapi_connectivity {
	# Table Header Information
	Write-Output "<table border = '1' cellspacing = '1' cellpadding = '1' width = '90%' bgcolor = '$table_background' align = 'center'>" | Out-File "$output_file" -Append -Encoding ASCII
	Write-Output "  <tr>" | Out-File "$output_file" -Append -Encoding ASCII
	Write-Output "    <td colspan = '4' bgcolor = '$table_header_background'><center><font color = '$table_header_text'><b>MAPI Connectivity Status</b></font></center></td>" | Out-File "$output_file" -Append -Encoding ASCII
	Write-Output "  </tr>" | Out-File "$output_file" -Append -Encoding ASCII
	# Column Header Information
	$back_color = "$table_background"
	Write-Output "  <tr bgcolor = '$column_header_background'>" | Out-File "$output_file" -Append -Encoding ASCII
	Write-Output "    <td align='center'><b>Database Name</b></td>" | Out-File "$output_file" -Append -Encoding ASCII
	Write-Output "    <td align='center'><b>Latency (in MS)</b></td>" | Out-File "$output_file" -Append -Encoding ASCII
	Write-Output "    <td align='center'><b>Result</b></td>" | Out-File "$output_file" -Append -Encoding ASCII
	Write-Output "    <td align='center'><b>Error</b></td>" | Out-File "$output_file" -Append -Encoding ASCII
	Write-Output "  </tr>" | Out-File "$output_file" -Append -Encoding ASCII
	# Table Row Data
	$mapi_status = Get-MailboxServer | Where {$_.AdminDisplayVersion -match "14."} | Test-MAPIConnectivity | Sort-Object Server, Database
	$mapi_status | ForEach-Object {
		If ($_.Latency.TotalMilliseconds -ge $mapi_latency_crit) {
			$back_color = "$critical_color"
		}
		ElseIf ($_.Latency.TotalMilliseconds -ge $mapi_latency_warn) {
			$back_color = "$warning_color"
		}
		ElseIf ($_.Result.Value -notmatch "Success") {
			$back_color = "$critical_color"
		}
		Else {
			$back_color = "$table_background"
		}
		Write-Output "  <tr bgcolor = '$back_color'>"
		Write-Output "    <td>"$_.Database"</td>"
		Write-Output "    <td align='center'>"$_.Latency.TotalMilliseconds"</td>"
		Write-Output "    <td>"$_.Result.Value"</td>"
		If (-not $_.Error) {
			Write-Output "    <td align='center'>-</td>"
		}
		Else {
            Write-Output "    <td>"$_.Error"</td>"
		}
		Write-Output "  </tr>"
	} | Out-File $output_file -Append -Encoding Ascii
	Write-Output "</table><br>" | Out-File "$output_file" -Append -Encoding ASCII
}

Function check_replication_health {
	# Table Header Information
	Write-Output "<table border = '1' cellspacing = '1' cellpadding = '1' width = '90%' bgcolor = '$table_background' align = 'center'>" | Out-File "$output_file" -Append -Encoding ASCII
	Write-Output "  <tr>" | Out-File "$output_file" -Append -Encoding ASCII
	Write-Output "    <td colspan = '3' bgcolor = '$table_header_background'><center><font color = '$table_header_text'><b>Replication Health</b></font></center></td>" | Out-File "$output_file" -Append -Encoding ASCII
	Write-Output "  </tr>" | Out-File "$output_file" -Append -Encoding ASCII
	# Table Row Data
	$server_list = Get-MailboxServer | Where {$_.AdminDisplayVersion -match "14."} | Sort-Object Name
	ForEach ($server in $server_list) {
		# Server Header Information
		Write-Output "  <tr>" | Out-File "$output_file" -Append -Encoding ASCII
		Write-Output "    <td colspan = '3' bgcolor = '$table_header_background'><center><font color = '$table_header_text'><b>"$server"</b></font></center></td>" | Out-File "$output_file" -Append -Encoding ASCII
		Write-Output "  </tr>" | Out-File "$output_file" -Append -Encoding ASCII
		# Column Header Information
		$back_color = "$table_background"
		Write-Output "  <tr bgcolor = '$column_header_background'>" | Out-File "$output_file" -Append -Encoding ASCII
		Write-Output "    <td align='center'><b>Replication Health Check</b></td>" | Out-File "$output_file" -Append -Encoding ASCII
		Write-Output "    <td align='center'><b>Replication Health Result</b></td>" | Out-File "$output_file" -Append -Encoding ASCII
		Write-Output "    <td align='center'><b>Replication Health Error</b></td>" | Out-File "$output_file" -Append -Encoding ASCII
		Write-Output "  </tr>" | Out-File "$output_file" -Append -Encoding ASCII
		$replication_checks = Test-ReplicationHealth -Server "$server"
		ForEach ($replication_check in $replication_checks) {
			$back_color = "$table_background"
			If ($replication_check.Result -match "Failed") {
				$back_color = "$critical_color"
			}
			Write-Output "  <tr bgcolor = '$back_color'>" | Out-File $output_file -Append -Encoding Ascii
			Write-Output "    <td>"$replication_check.Check"</td>" | Out-File $output_file -Append -Encoding Ascii
			Write-Output "    <td>"$replication_check.Result.Value"</td>" | Out-File $output_file -Append -Encoding Ascii
			If (-not $replication_check.Error) {
				Write-Output "    <td align='center'>-</td>" | Out-File $output_file -Append -Encoding Ascii
			}
			Else {
            	Write-Output "    <td>"$replication_check.Error"</td>" | Out-File $output_file -Append -Encoding Ascii
			}
			Write-Output "  </tr>" | Out-File $output_file -Append -Encoding Ascii
		}
	}
	Write-Output "</table><br>" | Out-File "$output_file" -Append -Encoding ASCII
}

Function check_replication_status {
	# Table Header Information
	Write-Output "<table border = '1' cellspacing = '1' cellpadding = '1' width = '90%' bgcolor = '$table_background' align = 'center'>" | Out-File "$output_file" -Append -Encoding ASCII
	Write-Output "  <tr>" | Out-File "$output_file" -Append -Encoding ASCII
	Write-Output "    <td colspan = '6' bgcolor = '$table_header_background'><center><font color = '$table_header_text'><b>Replication Status</b></font></center></td>" | Out-File "$output_file" -Append -Encoding ASCII
	Write-Output "  </tr>" | Out-File "$output_file" -Append -Encoding ASCII
	# Table Row Data
	$server_list = Get-MailboxServer | Where {$_.AdminDisplayVersion -match "14."} | Sort-Object Name
	ForEach ($server in $server_list) {
		# Table Header Information
		Write-Output "  <tr>" | Out-File "$output_file" -Append -Encoding ASCII
		Write-Output "    <td colspan = '6' bgcolor = '$table_header_background'><center><font color = '$table_header_text'><b>"$server"</b></font></center></td>" | Out-File "$output_file" -Append -Encoding ASCII
		Write-Output "  </tr>" | Out-File "$output_file" -Append -Encoding ASCII
		# Column Header Information
		$back_color = "$table_background"
		Write-Output "  <tr bgcolor = '$column_header_background'>" | Out-File "$output_file" -Append -Encoding ASCII
		Write-Output "    <td align='center'><b>Database Name</b></td>" | Out-File "$output_file" -Append -Encoding ASCII
		Write-Output "    <td align='center'><b>Status</b></td>" | Out-File "$output_file" -Append -Encoding ASCII
		Write-Output "    <td align='center'><b>Copy Queue Length</b></td>" | Out-File "$output_file" -Append -Encoding ASCII
		Write-Output "    <td align='center'><b>Replay Queue Length</b></td>" | Out-File "$output_file" -Append -Encoding ASCII
		Write-Output "    <td align='center'><b>Last Inspected Log Time</b></td>" | Out-File "$output_file" -Append -Encoding ASCII
		Write-Output "    <td align='center'><b>Content Index State</b></td>" | Out-File "$output_file" -Append -Encoding ASCII
		Write-Output "  </tr>" | Out-File "$output_file" -Append -Encoding ASCII
		$copy_status =  Get-MailboxDatabaseCopyStatus -Server "$server" | Sort-Object DatabaseName
		ForEach ($status in $copy_status) {
			$back_color = "$table_background"
			If (($status.Status -match "Failed") -or ($status.ContentIndexState -notmatch "Healthy")) {
				$back_color = "$critical_color"
			}
			If (($status.CopyQueueLength -gt $copy_queue_length_warn) -or ($status.ReplayQueueLength -gt $replay_queue_length_warn)) {
				$back_color = "$warning_color"
			}
			ElseIf (($status.CopyQueueLength -gt $copy_queue_length_crit) -or ($status.ReplayQueueLength -gt $replay_queue_length_crit)) {
				$back_color = "$critical_color"
			}
			Write-Output "  <tr bgcolor = '$back_color'>" | Out-File $output_file -Append -Encoding Ascii
			Write-Output "    <td>"$status.DatabaseName"</td>" | Out-File $output_file -Append -Encoding Ascii
			Write-Output "    <td>"$status.Status"</td>" | Out-File $output_file -Append -Encoding Ascii
			Write-Output "    <td align='center'>"$status.CopyQueueLength"</td>" | Out-File $output_file -Append -Encoding Ascii
			Write-Output "    <td align='center'>"$status.ReplayQueueLength"</td>" | Out-File $output_file -Append -Encoding Ascii
			If (-not $status.LastInspectedLogTime) {
				Write-Output "    <td align='center'>-</td>" | Out-File $output_file -Append -Encoding Ascii
			}
			Else {
            	Write-Output "    <td>"$status.LastInspectedLogTime"</td>" | Out-File $output_file -Append -Encoding Ascii
			}
			Write-Output "    <td>"$status.ContentIndexState"</td>" | Out-File $output_file -Append -Encoding Ascii
			Write-Output "  </tr>" | Out-File $output_file -Append -Encoding Ascii
		}
	}
	Write-Output "</table><br>" | Out-File "$output_file" -Append -Encoding ASCII
}

Function check_server_health {
	# Table Header Information
	Write-Output "<table border = '1' cellspacing = '1' cellpadding = '1' width = '90%' bgcolor = '$table_background' align = 'center'>" | Out-File "$output_file" -Append -Encoding ASCII
	Write-Output "  <tr>" | Out-File "$output_file" -Append -Encoding ASCII
	Write-Output "    <td colspan = '4' bgcolor = '$table_header_background'><center><font color = '$table_header_text'><b>Server Service Status</b></font></center></td>" | Out-File "$output_file" -Append -Encoding ASCII
	Write-Output "  </tr>" | Out-File "$output_file" -Append -Encoding ASCII
	# Table Row Data
	$exchange_server_list = Get-ExchangeServer | Where {$_.AdminDisplayVersion -match "14."} | Sort-Object ServerRole, Name
	ForEach ($exchange_server in $exchange_server_list) {
		Write-Output "  <tr>" | Out-File "$output_file" -Append -Encoding ASCII
		Write-Output "    <td colspan = '4' bgcolor = '$table_header_background'><center><font color = '$table_header_text'><b>"$exchange_server"</b></font></center></td>" | Out-File "$output_file" -Append -Encoding ASCII
		Write-Output "  </tr>" | Out-File "$output_file" -Append -Encoding ASCII
		# Column Header Information
		$back_color = "$table_background"
		Write-Output "  <tr bgcolor = '$column_header_background'>" | Out-File "$output_file" -Append -Encoding ASCII
		Write-Output "    <td align='center'><b>Server Role</b></td>" | Out-File "$output_file" -Append -Encoding ASCII
		Write-Output "    <td align='center'><b>Required Services Running</b></td>" | Out-File "$output_file" -Append -Encoding ASCII
		Write-Output "    <td align='center'><b>Services Running</b></td>" | Out-File "$output_file" -Append -Encoding ASCII
		Write-Output "    <td align='center'><b>Services Stopped</b></td>" | Out-File "$output_file" -Append -Encoding ASCII
		Write-Output "  </tr>" | Out-File "$output_file" -Append -Encoding ASCII
		$server_roles = Test-ServiceHealth -Server $exchange_server | Select-Object Role,RequiredServicesRunning,@{Name="ServicesRunning";Expression={[string]::join("<br>",($_.ServicesRunning))}},@{Name="ServicesNotRunning";Expression={[string]::join("<br>",($_.ServicesNotRunning))}}
		ForEach ($server_role in $server_roles) {
			$back_color = "$table_background"
			If (-not $server_role.RequiredServicesRunning) {
				$back_color = "$critical_color"
			}
			Write-Output "  <tr bgcolor = '$back_color'>" | Out-File $output_file -Append -Encoding Ascii
			If (-not $server_role.Role) {
				Write-Output "    <td>-</td>" | Out-File $output_file -Append -Encoding Ascii
			}
			Else {
				Write-Output "    <td>"$server_role.Role"</td>" | Out-File $output_file -Append -Encoding Ascii
			}
			If (-not $server_role.RequiredServicesRunning) {
				Write-Output "    <td align='center'>-</td>" | Out-File $output_file -Append -Encoding Ascii
			}
			Else {
				Write-Output "    <td >"$server_role.RequiredServicesRunning"</td>" | Out-File $output_file -Append -Encoding Ascii
			}
			If (-not $server_role.ServicesRunning) {
				Write-Output "    <td align='center'>-</td>" | Out-File $output_file -Append -Encoding Ascii
			}
			Else {
				Write-Output "    <td>"$server_role.ServicesRunning"</td>" | Out-File $output_file -Append -Encoding Ascii
			}
			If (-not $server_role.ServicesNotRunning) {
				Write-Output "    <td align='center'>-</td>" | Out-File $output_file -Append -Encoding Ascii
			}
			Else {
				Write-Output "    <td>"$server_role.ServicesNotRunning"</td>" | Out-File $output_file -Append -Encoding Ascii
			}
			Write-Output "  </tr>" | Out-File $output_file -Append -Encoding Ascii
		}
	}
	Write-Output "</table><br>" | Out-File "$output_file" -Append -Encoding ASCII
}

Function check_transport_queues {
	# Table Header Information
	Write-Output "<table border = '1' cellspacing = '1' cellpadding = '1' width = '90%' bgcolor = '$table_background' align = 'center'>" | Out-File "$output_file" -Append -Encoding ASCII
	Write-Output "  <tr>" | Out-File "$output_file" -Append -Encoding ASCII
	Write-Output "    <td colspan = '5' bgcolor = '$table_header_background'><center><font color = '$table_header_text'><b>Mail Transport Queues</b></font></center></td>" | Out-File "$output_file" -Append -Encoding ASCII
	Write-Output "  </tr>" | Out-File "$output_file" -Append -Encoding ASCII
	# Table Row Data
	$transport_servers = Get-ExchangeServer | Where {$_.AdminDisplayVersion -match "14." -and $_.ServerRole -match "Transport"} | Sort-Object Name
	ForEach ($transport_server in $transport_servers) {
		Write-Output "  <tr>" | Out-File "$output_file" -Append -Encoding ASCII
		Write-Output "    <td colspan = '5' bgcolor = '$table_header_background'><center><font color = '$table_header_text'><b>"$transport_server"</b></font></center></td>" | Out-File "$output_file" -Append -Encoding ASCII
		Write-Output "  </tr>" | Out-File "$output_file" -Append -Encoding ASCII
		# Column Header Information
		$back_color = "$table_background"
		Write-Output "  <tr bgcolor = '$column_header_background'>" | Out-File "$output_file" -Append -Encoding ASCII
    	Write-Output "    <td align='center'><b>Queue Name</b></td>" | Out-File $output_file -Append -Encoding Ascii
    	Write-Output "    <td align='center'><b>Delivery Type</b></td>" | Out-File $output_file -Append -Encoding Ascii
    	Write-Output "    <td align='center'><b>Queue Status</b></td>" | Out-File $output_file -Append -Encoding Ascii
    	Write-Output "    <td align='center'><b>Queue Message Count</b></td>" | Out-File $output_file -Append -Encoding Ascii
    	Write-Output "    <td align='center'><b>Next Hop Domain</b></td>" | Out-File $output_file -Append -Encoding Ascii
		Write-Output "  </tr>" | Out-File "$output_file" -Append -Encoding ASCII
		$transport_queues = Get-Queue -Server "$transport_server" | Sort-Object Identity
		ForEach ($transport_queue in $transport_queues) {
			If ($transport_queue.MessageCount -ge $transport_queue_crit) {
				$back_color = "$critical_color"
			}
			ElseIf ($transport_queue.MessageCount -ge $transport_queue_warn) {
				$back_color = "$warning_color"
			}
			Else {
				$back_color = "$table_background"
			}
			Write-Output "  <tr bgcolor = '$back_color'>" | Out-File $output_file -Append -Encoding Ascii
			Write-Output "    <td>"$transport_queue.Identity.RowID"</td>" | Out-File $output_file -Append -Encoding Ascii
			Write-Output "    <td>"$transport_queue.DeliveryType"</td>" | Out-File $output_file -Append -Encoding Ascii
			Write-Output "    <td>"$transport_queue.Status"</td>" | Out-File $output_file -Append -Encoding Ascii
			Write-Output "    <td align='center'>"$transport_queue.MessageCount"</td>" | Out-File $output_file -Append -Encoding Ascii
			Write-Output "    <td>"$transport_queue.NextHopDomain"</td>" | Out-File $output_file -Append -Encoding Ascii
			Write-Output "  </tr>" | Out-File $output_file -Append -Encoding Ascii
		}
	}
	Write-Output "</table><br>" | Out-File "$output_file" -Append -Encoding ASCII
}

Function format_html_header {
	# Report Page Header
    Write-Output "<html>" | Out-File $output_file -Append -Encoding Ascii
    Write-Output "<head><title>Daily Microsoft Exchange 2010 Server Environment Health Check "$current_date"</title></head>" | Out-File $output_file -Append -Encoding Ascii
    Write-Output "<body bgcolor = '$report_background'>" | Out-File $output_file -Append -Encoding Ascii
    Write-Output "<font face = 'Times New Roman'>" | Out-File $output_file -Append -Encoding Ascii
	# Report Name Table Information
    Write-Output "<table border = '1' cellspacing = '1' cellpadding = '1' width = '90%' bgcolor = '$table_background' align = 'center'>" | Out-File $output_file -Append -Encoding Ascii
    Write-Output "  <tr>" | Out-File $output_file -Append -Encoding Ascii
    Write-Output "    <td colspan = '1' bgcolor = '$table_background'><center><font color = '$report_font_color'><h1>Daily Microsoft Exchange 2010 Server Environment Health Check "$current_date"</h1></font></center></td>" | Out-File $output_file -Append -Encoding Ascii
    Write-Output "  </tr>" | Out-File $output_file -Append -Encoding Ascii
    Write-Output "</table><br>" | Out-File $output_file -Append -Encoding Ascii
}

Function format_html_footer {
	# Report Page Footer
    Write-Output "</font>" | Out-File $output_file -Append -Encoding Ascii
    Write-Output "</body>" | Out-File $output_file -Append -Encoding Ascii
    Write-Output "</html>" | Out-File $output_file -Append -Encoding Ascii
}

# +---------------------------------+
# | Main                            |
# +---------------------------------+
If ((Test-Path -Path "$output_file")) {
	Del "$output_file"
}

format_html_header
check_server_health
Write-Output "<hr>" | Out-File $output_file -Append -Encoding Ascii
check_database_mount_status
Write-Output "<hr>" | Out-File $output_file -Append -Encoding Ascii
check_database_statistics
Write-Output "<hr>" | Out-File $output_file -Append -Encoding Ascii
check_database_backup_status
Write-Output "<hr>" | Out-File $output_file -Append -Encoding Ascii
check_replication_health
check_replication_status
Write-Output "<hr>" | Out-File $output_file -Append -Encoding Ascii
check_mapi_connectivity
Write-Output "<hr>" | Out-File $output_file -Append -Encoding Ascii
check_transport_queues
format_html_footer

If ($EmailTo -ne $email_from) {
	$email_body = Get-Content "$output_file" | Out-String
	Send-MailMessage -From $email_from -To $EmailTo -Subject "Daily Microsoft Exchange 2010 Server Environment Health Check $current_date" -BodyAsHTML -Body $email_body -SMTPServer $smtp_server -Attachments "$exchange_drive_information"
	Del "$output_file"
}

Exit 0
