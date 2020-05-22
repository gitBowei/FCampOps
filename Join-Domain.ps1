Function Join-Domain {
    param(
            [string]$domain=$(read-host "Please specify the domain to join"),
            [System.Management.Automation.PSCredential]$Credential = $(Get-Credential)
            )

$CS = Get-WmiObject Win32_ComputerSystem
$CS.JoinDomainOrWorkgroup($Domain,$Credential.GetNetworkCredential().Password,$Credential.UserName,$null,3)

}