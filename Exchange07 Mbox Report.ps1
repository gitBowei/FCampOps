#This script is designed to grab mailbox statistics for every user and give a more detailed
#level of output about mailbox statistics in .html format

param(
	[string] $SFileWDir
)

# If there is no optional argument then make a filename for it.
if (!$SFileWDir)
{
	Write-Host "You didn't specify a filename w/dir to save to so I'm going to just make one in this directory"
	Write-Host "Saving the file as GUReport-$date.html"

	# Generate the date var
	$date = get-date -Format MM-dd-yyyy

	# FOR TESTING PURPOSES, CHANGE METHOD ON THIS LATER
	$OUTFILE = "GUReport-$date.html"
}
else
{
	Write-Host "Saving file as $SFileWDir"
	$OUTFILE = $SFileWDir
}
	
# Gather the list of users with mailboxes to check
$UserList = get-user | Sort-Object $_.DisplayName | Where {$_.RecipientType -eq "UserMailbox"}

# Set the page up
Write-Output "<html>" | Out-File $OUTFILE -Append -Encoding Ascii
Write-Output "  <head><title>Mailbox Granular Usage Report "$date"</title></head>" | Out-File $OUTFILE -Append -Encoding Ascii
Write-Output "<body>" | Out-File $OUTFILE -Append -Encoding Ascii
Write-Output "<font face = 'Times New Roman'>" | Out-File $OUTFILE -Append -Encoding Ascii

# Go through the list of users and build out all of their information into html tables
$UserList | ForEach-Object {

	# Generate a table for the user information
	Write-Output "<table border = '1' cellspacing = '1' cellpadding = '1' width = '900'>"
	
	# Heading with the users name
	Write-Output "  <tr>"
	Write-Output "    <td colspan = '4' bgcolor = '#667E7C'><center><font color = 'white'><b>"$_.DisplayName"</b></font></center></td>"
	Write-Output "  </tr>"

	# Heading for each of the columns
	Write-Output "  <tr>"
	Write-Output "    <td><b>Folder Path</b></td>"
	Write-Output "    <td><b>Items In Folder</b></td>"
	Write-Output "    <td><b>Folder Size (MB)</b></td>"
	Write-Output "    <td><b>Folder Size (B)</b></td>"
	Write-Output "  </tr>"
	
	#Generate the users statistics into a variable
	$UserMBS = get-mailboxfolderstatistics -Identity $_.DisplayName | select FolderPath,ItemsInFolder,FolderSize

	# Go through the mailboxstatistics and build it into the $userMBStatsObj
	$UserMBS | ForEach-Object {
	
		# Generate the Folder Size in MB.  Note that I had to change the output to int in order for it to work
		$FolderSizeBytes = $_.FolderSize
		#Need to convert the string to int for it to be divisable.  
		#Remove any characters from the string as it's converted to int.
		[int]$FolderSizeBytesInt = [regex]::Replace($FolderSizeBytes, "B|K", "") #Most entries have a B at the end, some a K for some odd reason...
		[int]$FolderSize = $FolderSizeBytesInt / 1MB

		Write-Output "  <tr>"
		Write-Output "    <td>"$_.FolderPath"</td>"
		Write-Output "    <td>"$_.ItemsInFolder"</td>"
		Write-Output "    <td>"$FolderSize"</td>"
		Write-Output "    <td>"$FolderSizeBytesInt"</td>"
		Write-Output "  </tr>"
	}
	
	#Close the user table information
	Write-Output "</table><br>"

} | Out-File $OUTFILE -Append -Encoding Ascii

Write-Output "</font>" | Out-File $OUTFILE -Append -Encoding Ascii
Write-Output "</body>" | Out-File $OUTFILE -Append -Encoding Ascii
Write-Output "</html>" | Out-File $OUTFILE -Append -Encoding Ascii