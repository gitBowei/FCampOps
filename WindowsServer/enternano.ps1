$serviceName = ‘campohenriquez’ 
$vmName = ‘nanito’ 
$subName = ‘Plataformas de MSDN’

Set-AzureSubscription –SubscriptionName $subName

# Set variable 
$myVM = Get-AzureVM -ServiceName $serviceName -Name $vmName

# Install the cert for the VM locally 
$WinRMCertificateThumbprint = ($myVM | Select-Object -ExpandProperty VM).DefaultWinRMCertificateThumbprint

(Get-AzureCertificate -ServiceName $serviceName -Thumbprint $WinRMCertificateThumbprint -ThumbprintAlgorithm SHA1).Data | Out-File "${env:TEMP}\cert.tmp"

Import-Certificate -Filepath "$env:TEMP\cert.tmp" -CertStoreLocation 'Cert:\CurrentUser\Root'

Remove-Item "$env:TEMP\cert.tmp"

# Get the URI for PowerShell Remoting
$uri = Get-AzureWinRMUri –Service $serviceName –Name $vmName

# Credentials for the VM 
$cred = Get-Credential

# Open a New Remote PowerShell Session 
Enter-PSSession -ConnectionUri $uri -Credential $cred