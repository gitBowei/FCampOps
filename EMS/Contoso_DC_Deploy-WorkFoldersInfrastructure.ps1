# Script to configure Work Folders infrastructure
# Assumesthat the Contoso_DC_Deploy-WorkplaceJoinInfrastructure script (or equivalent steps) have been run
# Run this script on the DC virtual machine

# Enable use of CredSSP for WinRM on DC as a Client
Enable-WSManCredSSP -Role Client -DelegateComputer "*.corp.contoso.com" -Force
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\Credssp\PolicyDefaults\AllowFreshCredentialsDomain" -Name "WSMan" -Value "WSMAN/*.corp.contoso.com"           

# Enable the use of CredSSP for WinRM on SYNC as a Server
Invoke-Command -ComputerName "sync.corp.contoso.com" {
    Enable-WSManCredSSP -Role Server -Force
}

# Enable the use of CredSSP for WinRM on EDGE as a Server
Invoke-Command -ComputerName "edge.corp.contoso.com" {
    Enable-WSManCredSSP -Role Server -Force
}

# Establish a remote PowerShell session with edge.corp.contoso.com
$AdminPassword = ConvertTo-SecureString -String "Passw0rd" -Force –AsPlainText
$RemoteCreds = New-Object -typename System.Management.Automation.PSCredential -argumentlist "CORP\Administrator", $AdminPassword
$EdgeSession = New-PSSession "edge.corp.contoso.com" -Authentication CredSSP -Credential $RemoteCreds
$SyncSession = New-PSSession "sync.corp.contoso.com" -Authentication CredSSP -Credential $RemoteCreds

# Install the Work Folders server feature on SYNC
Install-WindowsFeature -ComputerName "sync.corp.contoso.com" -Name "FS-SyncShareService" -IncludeAllSubFeature -IncludeManagementTools

# Install the Internet Information Services (IIS) managment tools (including PowerShell module) server feature on SYNC
Install-WindowsFeature -ComputerName "sync.corp.contoso.com" -Name "Web-Mgmt-Console"

# Generate a cert with workfolders.corp.contoso.com as a SAN

# Request workfolders.corp.contoso.com certificate
Invoke-Command -Session $SyncSession -ScriptBlock {
    $CertCommonName = "workfolders.corp.contoso.com"
    $CertTemplate = "CorpWebServer"
    $PersonalCertificateStore = "Cert:\LocalMachine\My"
    $CertPassword = ConvertTo-SecureString -String "Passw0rd" -Force -AsPlainText
    $WFCertFileNamePfx = "work.pfx"

    # Request and store a new certificate based on the "CorpWebServer" certificate template with a SubjectName of "CN=workfolders.corp.contoso.com"
    $NewCert = Get-Certificate -Template $CertTemplate -SubjectName $("CN=$CertCommonName") -CertStoreLocation $PersonalCertificateStore
    # Export the work certificate so it can be imported to EDGE
    Export-PfxCertificate -Cert $NewCert.Certificate.PSPath -FilePath "C:\$WFCertFileNamePfx" -Password $CertPassword | Out-Null

    # Copy the exported certificates to EDGE
    Copy-Item "C:\*.pfx" "\\edge.corp.contoso.com\c$"

    # Bind the certificate to the IIS hostable core instance
    $HWCIPAddress = $(Get-NetIPAddress -AddressFamily IPv4 -PrefixOrigin Dhcp).IPAddress
    New-WebBinding -Name "Default Web Site" -IPAddress $HWCIPAddress -Port 443 -Protocol "https"
    $SSLCert = Get-ChildItem -Path "Cert:\LocalMachine\My" | Where-Object {$_.Subject -like 'cn=work*'}
    New-Item "IIS:SslBindings\$HWCIPAddress!443" -Value $SSLCert

    # Configure the Work Folders setting to use ADFS    Set-SyncServerSetting -ADFSUrl "https://adfs.corp.contoso.com"    # Create the Work Folders share
    New-Item -Path "C:\SalesFolder" -ItemType Directory
    New-SyncShare -Name "SalesFolders" -Path "C:\SalesFolders" –User "CORP\Sales" -RequireEncryption $false –RequirePasswordAutoLock $false -InheritParentFolderPermission -Description "Work Folders sync share for Sales department"
}

Setspn.exe -S http/sync.corp.contoso.com sync
Setspn.exe -S http/sync sync
Set-ADComputer -Identity "CN=SYNC,OU=Servers,OU=Accounts,DC=corp,DC=contoso,DC=com" -Replace @{"msDS-AllowedToDelegateTo"="http/DC","http/DC.corp.contoso.com","http/dc.corp.contoso.com/CORP","http/dc.corp.contoso.com/corp.contoso.com","http/DC/CORP"} -Server "dc.corp.contoso.com"
Set-ADAccountControl -Identity "CN=SYNC,OU=Servers,OU=Accounts,DC=corp,DC=contoso,DC=com" -TrustedForDelegation $false -TrustedToAuthForDelegation $false

# Import the workfolders cert on EDGE
Invoke-Command -Session $EdgeSession -ScriptBlock {
    $mypwd = ConvertTo-SecureString -String "Passw0rd" -Force –AsPlainText
    Import-PfxCertificate -FilePath "C:\work.pfx" -CertStoreLocation "cert:\LocalMachine\My" -Password $mypwd
}

# Import the ADFS PowerShell module
Import-Module ADFS

#Add the Enterprise Sync Relying Party Trust to AD FS
$ECSIdentifier = "https://Windows-Server-Work-Folders/V1"
$ECSDisplayName = "workfolders.corp.contoso.com"

# Declare the variables used to establish the relying party trust
$TransformRuleString = '@RuleTemplate = "LdapClaims" @RuleName = "LDAP Attributes" c:[Type == "http://schemas.microsoft.com/ws/2008/06/identity/claims/windowsaccountname", Issuer == "AD AUTHORITY"] => issue(store = "Active Directory", types = ("http://schemas.xmlsoap.org/ws/2005/05/identity/claims/upn","http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name","http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname","http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname"), query =";userPrincipalName,displayName,sn,givenName;{0}", param = c.Value);'
$AuthorizationRuleString = '@RuleTemplate = "AllowAllAuthzRule" => issue(Type = "http://schemas.microsoft.com/authorization/claims/permit",Value = "true");' ;

Add-ADFSRelyingPartyTrust -Name $ECSDisplayName -Identifier $ECSIdentifier -IssuanceTransformRules $TransformRuleString -IssuanceAuthorizationRules $AuthorizationRuleString -EncryptClaims $false -EnableJWT $true -AllowedClientTypes Public -ErrorVariable Err -ErrorAction Continue

# Add workfolders.corp.contoso.com to DNS on DC
Add-DnsServerResourceRecordCName -Name "workfolders" -HostNameAlias "sync.corp.contoso.com" -ZoneName "corp.contoso.com"

# Add workfolders.corp.contoso.com to DNS on EDGE
Invoke-Command -Session $EdgeSession -ScriptBlock {
    # Add-DnsServerResourceRecordA -IPv4Address "131.107.0.100" -Name "workfolders" -ZoneName "corp.contoso.com"
    Add-DnsServerResourceRecordCName -HostNameAlias "edge.corp.contoso.com" -Name "workfolders" -ZoneName "corp.contoso.com"
}

#Publish the app on the Web Application Proxy on EDGE
Invoke-Command -Session $EdgeSession -ScriptBlock {
    $thumb=Get-ChildItem –Path "cert:\LocalMachine\My" | Where-Object {$_.subject -like 'cn=work*'}
    Add-WebApplicationProxyApplication -BackendServerUrl 'https://workfolders.corp.contoso.com/' -ExternalCertificateThumbprint $thumb.Thumbprint -ExternalUrl "https://workfolders.corp.contoso.com/" -Name "Work Folders" -ExternalPreAuthentication ADFS -ADFSRelyingPartyName "workfolders.corp.contoso.com"

    #Set WorkFolders to use OAuth (ADFS)
    Get-WebApplicationProxyApplication -Name "Work Folders" | Set-WebApplicationProxyApplication  -UseOAuthAuthentication 
}


# End the remote PowerShell session with SYNC
Remove-PSSession -Session $SyncSession

# End the remote PowerShell session with EDGE
Remove-PSSession -Session $EdgeSession
