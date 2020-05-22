# Set define the registry paths that need to be updated
$RegSoftwarePublishing = "HKCU:\Software\Microsoft\Windows\CurrentVersion\WinTrust\Trust Providers\Software Publishing"
$RegInternetSettings = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"

# Disable "Check for publisher's certificate revocation" checkbox in Internet Explorer
Set-ItemProperty $RegSoftwarePublishing -Name "State" -Value 146944 -Type DWord -Force

# Disable "Check for server certificate revocation" checkbox in Internet Explorer
Set-ItemProperty $RegInternetSettings -Name "CertificateRevocation" -Value 0 -Type DWord -Force
