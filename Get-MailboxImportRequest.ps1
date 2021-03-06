# .Synopsis
#   Use the Get-MailboxImportRequestProgress cmdlet to view detailed information about pst import progress.
# .Description
#   The Get-MailboxImportRequestProgress cmdlet displays statistics on imports currently in progress that help determine if a import is likely to complete successfully. To accureately evaluate the current progress of an import examine the durration it has been running and the number of times the estimated number of items have been transferred.
#
#   The following may indicate an import is stalled and will neither Complete or Fail:
#   * Item % is over 200
#   * ItemsLeft is -2000 or lower
#   * BytesTransferred is under 1MB and Durration is over 2 hours
#
#   Using ScanPST may repair the damange to the pst and allow it to complete successfully. Otherwise, the only other option is to use the full Outlook client.
#
# .Example
#   Get-MailboxImportRequest -Status InProgress|Get-MailboxImportRequestProgress
# .Example
#   Get-MailboxImportRequestProgress|ft -auto
[CmdletBinding()]
PARAM (
	[parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]$Identity
)

BEGIN {
	# We need this because 2.0 broke adding default properties the old way.
	# https://connect.microsoft.com/PowerShell/feedback/details/487938/v2-0-rtm-defining-default-properties-for-custom-objects-no-longer-works
	Function Set-DefaultProperties {
		PARAM (
			[string]$name,
			[string[]]$DefaultProperties
		)

		$xml = "<?xml version='1.0' encoding='utf-8' ?><Types><Type>"
		$xml += "<Name>$($name)</Name>"
		$xml += "<Members><MemberSet><Name>PSStandardMembers</Name><Members>"
		$xml += "<PropertySet><Name>DefaultDisplayPropertySet</Name><ReferencedProperties>"

		foreach( $default in $DefaultProperties ) {
			$xml += "<Name>$($default)</Name>"
		}

		$xml += "</ReferencedProperties></PropertySet></Members></MemberSet></Members>"
		$xml += "</Type></Types>"

		$file = "$($env:Temp)\$name.ps1xml"

		Out-File -FilePath $file -Encoding "UTF8" -InputObject $xml -Force

		$typeLoaded = $host.Runspace.RunspaceConfiguration.Types | where { $_.FileName -eq  $file }

		if( $typeLoaded -ne $null ) {
			Write-Verbose "Type Loaded"
			Update-TypeData
		}
		else {
			Update-TypeData $file
		}
	}
	
	# Define the default property set
	$customObjectName = ’Microsoft.Exchange.MailboxReplicationService.MailboxImportRequest#Progress’
	Set-DefaultProperties -Name $customObjectName @(‘TargetAlias','StatusDetail','BytesTransferred','ItemsTransferred','ItemsLeft','Item %','Total %','Durration')
}

PROCESS
{
	# Mailbox Import requests were piped in
	if($_)
	{
		if($_.Identity.GetType() -eq [Microsoft.Exchange.MailboxReplicationService.RequestJobObjectId] -or $_.Identity.GetType() -eq [Microsoft.Exchange.MailboxReplicationService.RequestIndexEntryObjectId])
		{
			$temp = $_|Get-MailboxImportRequestStatistics|select @{n="ItemsLeft";e={$_.estimatedtransferitemcount - $_.itemstransferred}},@{n="Item %";e={[int]($_.itemstransferred/$_.estimatedtransferitemcount * 100)}},@{n="Total %";e={$_.percentcomplete}},@{n="Durration";e={$_.TotalInProgressDuration}},*
		} else { Write-Warning "Invalid Mailbox Import Request ID"; return }

	# We just want all imports in progress
	} else {
		$temp = Get-MailboxImportRequest -status InProgress|Get-MailboxImportRequestStatistics|select @{n="ItemsLeft";e={$_.estimatedtransferitemcount - $_.itemstransferred}},@{n="Item %";e={[int]($_.itemstransferred/$_.estimatedtransferitemcount * 100)}},@{n="Total %";e={$_.percentcomplete}},@{n="Durration";e={$_.TotalInProgressDuration}},*
	}

	# Define the default property set
	$temp |% {
		$_.PSObject.TypeNames.Insert(0,$customObjectName)
	}
	$temp
}