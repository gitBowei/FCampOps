function Get-ADGPOReplication { <# .SYN... by Sigifredo Romero

Sigifredo Romero11:01 a. m.
function Get-ADGPOReplication {
<#
.SYNOPSIS
This function retrieve one or all the GPO and report their DSVersions and SysVolVersions (Users and Computers)
.DESCRIPTION
This function retrieve one or all the GPO and report their DSVersions and SysVolVersions (Users and Computers)
.PARAMETER GPOName
Specify the name of the GPO
.PARAMETER All
Specify that you want to retrieve all the GPO (slow if you have a lot of Domain Controllers)
.EXAMPLE
Get-ADGPOReplication -GPOName "Default Domain Policy"
.EXAMPLE
Get-ADGPOReplication -All
.NOTES
Francois-Xavier Cat
@lazywinadmin
lazywinadmin.com



VERSION HISTORY
1.0
Initial version
Adding some more Error Handling
Fix some typo
.link
https://github.com/lazywinadmin/PowerShell
#>
#requires -version 3
[CmdletBinding()]
PARAM (
[parameter(Mandatory = $True, ParameterSetName = "One")]
[String[]]$GPOName,
[parameter(Mandatory = $True, ParameterSetName = "All")]
[Switch]$All
)
BEGIN {
TRY {
if (-not (Get-Module -Name ActiveDirectory)) { Import-Module -Name ActiveDirectory -ErrorAction Stop -ErrorVariable ErrorBeginIpmoAD }
if (-not (Get-Module -Name GroupPolicy)) { Import-Module -Name GroupPolicy -ErrorAction Stop -ErrorVariable ErrorBeginIpmoGP }
}
CATCH {
Write-Warning -Message "[BEGIN] Something wrong happened"
IF ($ErrorBeginIpmoAD) { Write-Warning -Message "[BEGIN] Error while Importing the module Active Directory" }
IF ($ErrorBeginIpmoGP) { Write-Warning -Message "[BEGIN] Error while Importing the module Group Policy" }
$PSCmdlet.ThrowTerminatingError($_)
}
}
PROCESS {
FOREACH ($DomainController in ((Get-ADDomainController -ErrorAction Stop -ErrorVariable ErrorProcessGetDC -filter *).hostname)) {
TRY {
IF ($psBoundParameters['GPOName']) {
Foreach ($GPOItem in $GPOName) {
$GPO = Get-GPO -Name $GPOItem -Server $DomainController -ErrorAction Stop -ErrorVariable ErrorProcessGetGPO



[pscustomobject][ordered] @{
GroupPolicyName = $GPOItem
DomainController = $DomainController
UserVersion = $GPO.User.DSVersion
UserSysVolVersion = $GPO.User.SysvolVersion
ComputerVersion = $GPO.Computer.DSVersion
ComputerSysVolVersion = $GPO.Computer.SysvolVersion
}#PSObject
}#Foreach ($GPOItem in $GPOName)
}#IF ($psBoundParameters['GPOName'])
IF ($psBoundParameters['All']) {
$GPOList = Get-GPO -All -Server $DomainController -ErrorAction Stop -ErrorVariable ErrorProcessGetGPOAll



foreach ($GPO in $GPOList) {
[pscustomobject][ordered] @{
GroupPolicyName = $GPO.DisplayName
DomainController = $DomainController
UserVersion = $GPO.User.DSVersion
UserSysVolVersion = $GPO.User.SysvolVersion
ComputerVersion = $GPO.Computer.DSVersion
ComputerSysVolVersion = $GPO.Computer.SysvolVersion
}#PSObject
}
}#IF ($psBoundParameters['All'])
}#TRY
CATCH {
Write-Warning -Message "[PROCESS] Something wrong happened"
IF ($ErrorProcessGetDC) { Write-Warning -Message "[PROCESS] Error while running retrieving Domain Controllers with Get-ADDomainController" }
IF ($ErrorProcessGetGPO) { Write-Warning -Message "[PROCESS] Error while running Get-GPO" }
IF ($ErrorProcessGetGPOAll) { Write-Warning -Message "[PROCESS] Error while running Get-GPO -All" }
$PSCmdlet.ThrowTerminatingError($_)
}
}#FOREACH
}#PROCESS
}
Import-Module ActiveDirectory
## Define Objects ##
$report = New-Object PSObject -Property @{
ReplicationPartners = $null
LastReplication = $null
FailureCount = $null
FailureType = $null
FirstFailure = $null
# DefaultDomainPolicyGpoStatus = $null
}



$DCs = (Get-ADForest).Domains | % { Get-ADDomainController -Filter * -Server $_ } | select HostName



$PartnerMetaData = Get-ADReplicationPartnerMetadata -Target $DCs[0]

try {
foreach ($_ in $PartnerMetaData) {
## Replication Partners ##
$report.ReplicationPartners += "[$($_.Server.Split(".")[0]): $($_.Partner.split(",")[1].split("=")[1])]"
$report.LastReplication += "[$($_.Server.Split(".")[0]): $($_.LastReplicationSuccess)]"



## Replication Failures ##
if ($_.FailureCount) {
$report.FailureCount += "[$($_.Server.Split(".")[0]): $($_.FailureCount)]"
$report.FailureType += "[$($_.Server.Split(".")[0]): $($_.FailureType)]"
$report.FirstFailure += "[$($_.Server.Split(".")[0]): $($_.FirstFailure)]"
}
else {
$report.FailureCount += "[$($_.Server.Split(".")[0]): 0]"
$report.FailureType += "[$($_.Server.Split(".")[0]): NA]"
$report.FirstFailure += "[$($_.Server.Split(".")[0]): NA]"
}
}



# $report.DefaultDomainPolicyGpoStatus = $(Get-GPO -Name "Default Domain Policy").GpoStatus.ToString()
$report | ConvertTo-Json #|out-string
#Write-Host $JsonReport -NoNewline



}
catch {



# Exception. Don't write anything to STDOUT. We may write to NTLOG

}
$GPOs = Get-ADGPOReplication -GPOName "Default Domain Policy"



#function Compare-GPos($GPO1, $GPO2) {
# $GPOs[0]$GPOs[1] -Property UserVersion, UserSysVolVersion, ComputerVersion, ComputerSysVolVersion
#}



Compare-Object $GPOs[0] $GPOs[1] -Property UserVersion, UserSysVolVersion, ComputerVersion, ComputerSysVolVersion -IncludeEqual|convertto-json






#Get-ADGPOReplication -GPOName "Default Domain Policy" | ConvertTo-Json |out-string
