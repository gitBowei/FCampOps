# Get the thumbprints for the adfs.corp.contoso.com and intranet.corp.contoso.com certificates
$thumbADFS = Get-ChildItem –Path "cert:\LocalMachine\My" | where {$_.subject -like 'cn=adfs*'}
$thumbIntranet = Get-ChildItem –Path "cert:\LocalMachine\My" | where {$_.subject -like 'cn=intranet*'}

# Create the credentials used to establish the AD FS trust
$AdminPassword = ConvertTo-SecureString -String "Passw0rd" -Force –AsPlainText
$Creds = New-Object -Typename System.Management.Automation.PSCredential -Argumentlist "CORP\Administrator", $AdminPassword

# Configure the Web Applicaiton Proxy feature by using the certificate thumbpringts
# and the credentials in $Creds for adfs.corp.contoso.com
Install-WebApplicationProxy -FederationServiceTrustCredential $Creds -CertificateThumbprint $($thumbADFS.thumbprint) -FederationServiceName "adfs.corp.contoso.com"
