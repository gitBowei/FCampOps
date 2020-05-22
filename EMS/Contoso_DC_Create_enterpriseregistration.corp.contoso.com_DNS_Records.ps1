# Enable use of CredSSP for WinRM on DC (which is the Client)
Enable-WSManCredSSP -role Client -DelegateComputer "*.corp.contoso.com" -Force
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\Credssp\PolicyDefaults\AllowFreshCredentialsDomain" -Name "WSMan" -Value "WSMAN/*.corp.contoso.com"           

# Enable the use of CredSSP for WinRM on EDGE (which is the Server)
Invoke-Command -ComputerName "edge.corp.contoso.com" {
    Enable-WSManCredSSP -role Server -Force
}

# Establish a remote Windows PowerShell session with edge.corp.contoso.com
$AdminPassword = ConvertTo-SecureString -String "Passw0rd" -Force –AsPlainText
$RemoteCreds = New-Object -typename System.Management.Automation.PSCredential -argumentlist "CORP\Administrator", $AdminPassword
$EdgeSession = New-PSSession "edge.corp.contoso.com" -Authentication CredSSP -Credential $RemoteCreds


# Add the intranet.corp.contoso.com DNS A record to DNS zone on DC
# with the IPv4 address of 10.10.0.2, which points to the DC network adapter
# connected to the "CONTOSO" virtual network
Add-DnsServerResourceRecordA -IPv4Address "10.10.0.2" -Name "enterpriseregistration" -ZoneName "corp.contoso.com"

# Add the intranet.corp.contoso.com DNS A record to DNS zone on EDGE
# with the IPv4 address of 131.107.0.100, which points to the EDGE network adapter
# connected to the "EXTRANET" virtual network
Invoke-Command -Session $EdgeSession -ScriptBlock {
    Add-DnsServerResourceRecordA -IPv4Address "131.107.0.100" -Name "enterpriseregistration" -ZoneName "corp.contoso.com"
}

# Remove (end) the remote Windows PowerShell session with edge.corp.contoso.com
Remove-PSSession -Session $EdgeSession
