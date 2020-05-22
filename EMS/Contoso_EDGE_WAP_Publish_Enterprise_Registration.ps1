# Get the thumbprint for the adfs.corp.contoso.com certificate
$SSLCert =Get-ChildItem –Path "cert:\LocalMachine\My" | Where-Object {$_.subject -like 'cn=adfs.corp.contoso.com*'}
$ThumbADFS = $SSLCert.Thumbprint

# Publish the claims-aware web app through the Web Application Proxy
Add-WebApplicationProxyApplication -BackendServerUrl 'https://enterpriseregistration.corp.contoso.com/EnrollmentServer/' -ExternalCertificateThumbprint $ThumbADFS -ExternalUrl 'https://enterpriseregistration.corp.contoso.com/EnrollmentServer/' -Name 'Enterprise Registration' -ExternalPreAuthentication PassThrough

