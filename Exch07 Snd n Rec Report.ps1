# Get the start date for the tracking log search
$Start = (Get-Date -Hour 00 -Minute 00 -Second 00).AddDays(-1)

# Get the end date for the tracking log search
$End = (Get-Date -Hour 23 -Minute 59 -Second 59).AddDays(-1)

#Create a date for the csv file that this will get spit into
$date = get-date -Format MM-dd-yyyy

# Declare an array to store the results
$Results = @()

# Get the SEND events from the message tracking logs
$Sent = Get-MessageTrackingLog -Server <Server Name Ommited Needs Updated> -Start $Start -End $End -resultsize unlimited | Where { $_.EventID -eq 'Send' -or $_.EventID -eq 'Deliver' }

# Get the RECEIVE events from the message tracking logs
$Received = Get-MessageTrackingLog -Server <Server Name Ommited Needs Updated> -Start $Start -End $End -resultsize unlimited | Where { $_.EventID -eq 'Receive' -or $_.EventID -eq 'TRANSFER' }

# Get the mailboxes we want to report on
#For in case I need to one day work with multiple DB's: $Mailboxes = Get-Mailbox -Database "EXCHANGE01\SG1\DB1"
$Mailboxes = Get-Mailbox

# Set up the counters for the progress bar
$Total = $Mailboxes.Count
$Count = 1

# Sort the mailboxes and pipe them to a For-Each loop
$Mailboxes | Sort-Object DisplayName | ForEach-Object {
	# Update the progress bar
	$PercentComplete = $Count / $Total * 100
	Write-Progress -Activity "Message Tracking Log Search" -Status "Processing mailboxes" -percentComplete $PercentComplete

	# Declare a custom object to store the data
	$Stats = "" | Select-Object Name,Sent,Received

	# Get the email address for the mailbox
	$Email = $_.WindowsEmailAddress.ToString()

	# Set the Name property of our object to the mailbox's display name
	$Stats.Name = $_.DisplayName

	# Set the Sent property to the number of messages sent
	$Stats.Sent = ($Sent | Where-Object { ($_.EventId -eq "Send" -or $_.EventID -eq "Deliver") -and ($_.Sender -eq $email) }).Count

	# Set the Received property to the number of messages received
	$Stats.Received = ($Received | Where-Object { ($_.EventId -eq "RECEIVE") -and ($_.Recipients -match $email) }).Count

	# Add the statistics for this mailbox to our results array
	$Results += $Stats

	# Increment the progress bar counter
	$Count += 1
}

# Output the results
$Results | Export-CSV C:\Net_Admin_Stuff\usage_reports\send_receive_log\send_receive_log-$date.csv -NoType