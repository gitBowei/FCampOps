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

# Request Certs from our Corp CA
$ADFSCertCommonName = "adfs.corp.contoso.com"
$CertTemplate = "CorpWebServer"
$PersonalCertificateStore = "Cert:\LocalMachine\My"

# Request and store a new certificate based on the "CorpWebServer" certificate template with a SubjectName of "CN=intranet.corp.contoso.com"

$NewCert = Get-Certificate -Template $CertTemplate -SubjectName $("CN=$ADFSCertCommonName") -DnsName "adfs.corp.contoso.com","enterpriseregistration.corp.contoso.com" -CertStoreLocation $PersonalCertificateStore

# Export the ADFS and Intranet certificates for use on EDGE
$mypwd = ConvertTo-SecureString -String "Passw0rd" -Force –AsPlainText
$adfsCert = Get-ChildItem –Path "cert:\LocalMachine\My" | where {$_.subject -like 'cn=adfs*'}
$intranetCert = Get-ChildItem –Path "cert:\LocalMachine\My" | where {$_.subject -like 'cn=intranet*'}
Export-PfxCertificate -cert $adfsCert -FilePath "c:\adfs.pfx" -Password $mypwd
Export-PfxCertificate -cert $intranetCert -FilePath "c:\intranet.pfx" -Password $mypwd

# Copy the exported certificates to EDGE
Copy-Item "c:\*.pfx" "\\edge.corp.contoso.com\c$"

# Import the ADFS and intranet certificates on EDGE in a remote session
Invoke-Command -Session $EdgeSession -ScriptBlock {
    $mypwd = ConvertTo-SecureString -String "Passw0rd" -Force –AsPlainText
    Import-PfxCertificate -FilePath "c:\adfs.pfx" -CertStoreLocation "cert:\LocalMachine\My" -Password $mypwd
    Import-PfxCertificate -FilePath "c:\intranet.pfx" -CertStoreLocation "cert:\LocalMachine\My" -Password $mypwd
}

