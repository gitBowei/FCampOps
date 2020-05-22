# Script to configure AD FS and Workplace Join
# Run this script on the DC virtual machine

# Enable use of CredSSP for WinRM on DC (which is the Client)
Enable-WSManCredSSP -role Client -DelegateComputer "*.corp.contoso.com" -Force
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\Credssp\PolicyDefaults\AllowFreshCredentialsDomain" -Name "WSMan" -Value "WSMAN/*.corp.contoso.com"           

# Enable the use of CredSSP for WinRM on EDGE (which is the Server)
Invoke-Command -ComputerName "edge.corp.contoso.com" {
    Enable-WSManCredSSP -role Server -Force
}

# Establish a remote PowerShell session with edge.corp.contoso.com
$AdminPassword = ConvertTo-SecureString -String "Passw0rd" -Force –AsPlainText
$RemoteCreds = New-Object -typename System.Management.Automation.PSCredential -argumentlist "CORP\Administrator", $AdminPassword
$EdgeSession = New-PSSession "edge.corp.contoso.com" -Authentication CredSSP -Credential $RemoteCreds

#####################################################################################################################
# Prepare AD FS prerequisites

# Add the adfs.corp.contoso.com DNS A record to DNS zone on DC
Add-DnsServerResourceRecordA -IPv4Address "10.10.0.2" -Name "adfs" -ZoneName "corp.contoso.com"

# Create corp.contoso.com DNS zone on EDGE (if required) aand then add the adfs.corp.contoso.com DNS A record to DNS zone on EDGE
Invoke-Command -Session $EdgeSession -ScriptBlock {

    . 'C:\DemoContent\Contoso_EDGE_Create_DNS_corp.contoso.com_Zone.ps1'
    Add-DnsServerResourceRecordA -IPv4Address "131.107.0.100" -Name "adfs" -ZoneName "corp.contoso.com"
}

# Create Group Managed Service Account

Add-KdsRootKey –EffectiveTime (Get-Date).AddHours(-10)
New-ADServiceAccount "FsGmsa" -DNSHostName "adfs.corp.contoso.com" -ServicePrincipalNames "http/adfs.corp.contoso.com"

# Create certificate that is used for for ADFS and Device Registration service
Restart-Service -InputObject certsvc

# Request Certs from our Corp CA
$ADFSCertCommonName = "adfs.corp.contoso.com"
$CertTemplate = "CorpWebServer"
$PersonalCertificateStore = "Cert:\LocalMachine\My"

# Request and store a new certificate based on the "CorpWebServer" certificate template with a SubjectName of "CN=intranet.corp.contoso.com"

$NewCert = Get-Certificate -Template $CertTemplate -SubjectName $("CN=$ADFSCertCommonName") -DnsName "adfs.corp.contoso.com","enterpriseregistration.corp.contoso.com" -CertStoreLocation $PersonalCertificateStore

#####################################################################################################################
# Configure AD FS farm

Import-Module ADFS

#get the ADFS certificate
$thumb = Get-ChildItem –Path "cert:\LocalMachine\My" | where {$_.subject -like 'cn=adfs*'}

# If running the whole script we need to wait a moment
# Start-Sleep -Seconds 60

Install-AdfsFarm -CertificateThumbprint $($thumb.thumbprint) -FederationServiceDisplayName "Contoso LTD AD FS" -FederationServiceName "adfs.corp.contoso.com" -GroupServiceAccountIdentifier "CORP\FsGmsa$" -OverwriteConfiguration

# This loop will ensure that the script will keep trying when the WID isn't yet startable
do {
       Start-Sleep -Seconds 60
       $teststring = Get-AdfsCertificate

} until ($teststring)

# Easy to test it works, open this URL on the DC if you like, it should say you are not signed in: https://adfs.corp.contoso.com/adfs/ls/IdpInitiatedSignon.aspx

#####################################################################################################################
# Configure the claims aware app web site
# Add-DnsServerResourceRecordA -IPv4Address 10.10.0.2 -Name intranet -ZoneName corp.contoso.com
Add-DnsServerResourceRecordA -IPv4Address "10.10.0.3" -Name "intranet" -ZoneName "corp.contoso.com"

# Set SSL bindings for the default site
New-WebBinding -Name "Default Web Site" -Protocol "https" -IPAddress "10.10.0.3" -Port 443 -HostHeader "intranet.corp.contoso.com"
$SSLCert =Get-ChildItem –Path "cert:\LocalMachine\My" | Where-Object {$_.subject -like 'cn=intranet*'}
New-Item "IIS:SslBindings\10.10.0.3!443" -value $SSLCert

# Add the Claimapp sample directory to the Default Website
New-Item 'IIS:\Sites\Default Web Site\Claimapp' -Type Application -PhysicalPath "C:\inetpub\claimapp"

# need to change the claimapp bindings
Set-ItemProperty "IIS:\Sites\Default Web Site\Claimapp" -name "applicationPool" -value ".NET v2.0" -Force

# Set the .NET v2.0 pool to load user profile
$AppPool = (Get-ChildItem "IIS:\AppPools" | where {$_.Name -eq (".NET v2.0")} ) 
$AppPool.processModel.loadUserProfile = $true
$AppPool | Set-Item

# User FedUtil.exe to configure the claimapp to trust AD FS for auth
& 'C:\Program Files (x86)\Windows Identity Foundation SDK\v3.5\FedUtil.exe' /silent C:\DemoContent\ClaimAppSTSConfig.xml /output c:\fed.txt

Start-Sleep -Seconds 120

# Add relying party trust for claimapp
$IssuanceTransformRule = '@RuleName = "All Claims" c:[] => issue(claim = c);'
$IssuanceAuthorizationRule = '@RuleTemplate = "AllowAllAuthzRule"  => issue(Type = "http://schemas.microsoft.com/authorization/claims/permit", Value = "true");'

Add-AdfsRelyingPartyTrust -Name "intranet.corp.contoso.com" -MetadataUrl "https://intranet.corp.contoso.com/claimapp/FederationMetadata/2007-06/FederationMetadata.xml" -IssuanceTransformRules $IssuanceTransformRule -IssuanceAuthorizationRules $IssuanceAuthorizationRule -MonitoringEnabled $true -AutoUpdateEnabled $true

# You should now be able to test claim app and be prompted for authentication, authentication should show claims on DC https://intranet.corp.contoso.com/claimapp/

# Enable initialize and enable the Device Registration Service
Initialize-ADDeviceRegistration -ServiceAccountName "CORP\FsGmsa$" -Force
Start-Sleep -Seconds 20
Enable-AdfsDeviceRegistration

# Enable global authuthentication for devices
Set-AdfsGlobalAuthenticationPolicy -DeviceAuthenticationEnabled $True


#####################################################################################################################
# Deploy the Web Appplication Proxy server feature

# Export the ADFS and Intranet certificates for use on EDGE
$mypwd = ConvertTo-SecureString -String "Passw0rd" -Force –AsPlainText
$adfsCert = Get-ChildItem –Path "cert:\LocalMachine\My" | where {$_.subject -like 'cn=adfs*'}
$intranetCert = Get-ChildItem –Path "cert:\LocalMachine\My" | where {$_.subject -like 'cn=intranet*'}
Export-PfxCertificate -cert $adfsCert -FilePath "c:\adfs.pfx" -Password $mypwd
Export-PfxCertificate -cert $intranetCert -FilePath "c:\intranet.pfx" -Password $mypwd

# Copy the exported certificates to EDGE
Copy-Item "c:\*.pfx" "\\edge.corp.contoso.com\c$"

# Set credentials for the remote session authentication by using CredSSP for WinRM
$AdminPassword = ConvertTo-SecureString -String "Passw0rd" -Force –AsPlainText
$RemoteCreds = New-Object -typename System.Management.Automation.PSCredential -argumentlist "CORP\Administrator", $AdminPassword

# Import the ADFS and intranet certificates on EDGE in a remote session
Invoke-Command -Session $EdgeSession -ScriptBlock {
    $mypwd = ConvertTo-SecureString -String "Passw0rd" -Force –AsPlainText
    Import-PfxCertificate -FilePath "c:\adfs.pfx" -CertStoreLocation "cert:\LocalMachine\My" -Password $mypwd
    Import-PfxCertificate -FilePath "c:\intranet.pfx" -CertStoreLocation "cert:\LocalMachine\My" -Password $mypwd
}

#Add public facing DNS record for the claims-aware web app on EDGE
Invoke-Command -Session $EdgeSession -ScriptBlock {
    Add-DnsServerResourceRecordA -IPv4Address "131.107.0.100" -Name "intranet" -ZoneName "corp.contoso.com"
}

# Configure Kerberos Constrained Delegation to allow EDGE to use certs issued to DC for http
setspn.exe -S http/edge.corp.contoso.com edge
setspn.exe -S http/edge edge
Set-ADComputer -Identity "CN=EDGE,OU=Servers,OU=Accounts,DC=corp,DC=contoso,DC=com" -Replace @{"msDS-AllowedToDelegateTo"="http/DC","http/DC.corp.contoso.com","http/dc.corp.contoso.com/CORP","http/dc.corp.contoso.com/corp.contoso.com","http/DC/CORP"} -Server "dc.corp.contoso.com"
Set-ADAccountControl -Identity "CN=EDGE,OU=Servers,OU=Accounts,DC=corp,DC=contoso,DC=com" -TrustedForDelegation $false -TrustedToAuthForDelegation $false

#####################################################################################################################
# Configure Web Appliation Proxy feature on EDGE
Invoke-Command -Session $EdgeSession -ScriptBlock {
    # Install the Web Application Proxy server feature
    Install-WindowsFeature "Web-Application-Proxy" -IncludeManagementTools

    # Get the thumbprints for the adfs.corp.contoso.com and intranet.corp.contoso.com certificates
    $thumbADFS = Get-ChildItem –Path "cert:\LocalMachine\My" | where {$_.subject -like 'cn=adfs*'}
    $thumbIntranet = Get-ChildItem –Path "cert:\LocalMachine\My" | where {$_.subject -like 'cn=intranet*'}

    $AdminPassword = ConvertTo-SecureString -String "Passw0rd" -Force –AsPlainText
    $Creds = New-Object -Typename System.Management.Automation.PSCredential -Argumentlist "CORP\Administrator", $AdminPassword

    Install-WebApplicationProxy -FederationServiceTrustCredential $Creds -CertificateThumbprint $($thumbADFS.thumbprint) -FederationServiceName "adfs.corp.contoso.com"

    # Publish the claims-aware web app through the Web Application Proxy
    Add-WebApplicationProxyApplication -BackendServerUrl "https://intranet.corp.contoso.com/claimapp/" -ExternalCertificateThumbprint $($thumbIntranet.Thumbprint) -ExternalUrl "https://intranet.corp.contoso.com/claimapp/" -Name "Intranet" -ExternalPreAuthentication ADFS -ADFSRelyingPartyName "intranet.corp.contoso.com"
}

# Add enterpriseregistration.corp.contoso.com DNS A record to DNS zone on DC
Add-DnsServerResourceRecordA -IPv4Address "10.10.0.2" -Name "enterpriseregistration" -ZoneName "corp.contoso.com"

# Add enterpriseregistration.corp.contoso.com DNS A record to DNS zone on EDGE
Invoke-Command -Session $EdgeSession -ScriptBlock {
    Add-DnsServerResourceRecordA -IPv4Address "131.107.0.100" -Name "enterpriseregistration" -ZoneName "corp.contoso.com"
}

# End the remote PowerShell session with EDGE
Remove-PSSession -Session $EdgeSession
