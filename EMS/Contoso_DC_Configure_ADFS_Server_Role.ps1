# Configure AD FS server farm

# Import the AD FS Windows PowerShell module
Import-Module ADFS

# Get the certificate used by the AD FS configuration process (adfs.corp.contoso.com)
$CertThumb = Get-ChildItem –Path "cert:\LocalMachine\My" | where {$_.subject -like 'cn=adfs*'}

# Configure the first (only) AD FS server in the AD FS server farm
Install-AdfsFarm -CertificateThumbprint $($CertThumb.thumbprint) -FederationServiceDisplayName "Contoso LTD AD FS" -FederationServiceName "adfs.corp.contoso.com" -GroupServiceAccountIdentifier "CORP\FsGmsa$" -OverwriteConfiguration

# Wait (loop) until the configuration process is complete 
# (the Get-AdfsCertificate cmdlet returns the certificate)
do {
       Start-Sleep -Seconds 60
       $teststring = Get-AdfsCertificate -ErrorAction SilentlyContinue

} until ($teststring)

