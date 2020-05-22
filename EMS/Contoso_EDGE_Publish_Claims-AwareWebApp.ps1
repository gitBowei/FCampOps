# Publish the claims-aware web app through the Web Application Proxy
Add-WebApplicationProxyApplication -BackendServerUrl "https://intranet.corp.contoso.com/claimapp/" -ExternalCertificateThumbprint $($thumbIntranet.Thumbprint) -ExternalUrl "https://intranet.corp.contoso.com/claimapp/" -Name "Intranet" -ExternalPreAuthentication ADFS -ADFSRelyingPartyName "intranet.corp.contoso.com"
