$AddZoneName = "corp.contoso.com"
$DelZoneName = "contoso.com"

# Remove the corp.contoso.com zone if it already exists
If (Get-DnsServerZone -Name $AddZoneName -ErrorAction Ignore) {
    Remove-DnsServerZone -Name $AddZoneName -Force
}

# Remove the contoso.com zone if it already exists
If (Get-DnsServerZone -Name $DelZoneName -ErrorAction Ignore) {
    Remove-DnsServerZone -Name $DelZoneName -Force
}

# Create the corp.contoso.com zone
Add-DnsServerPrimaryZone -Name $AddZoneName -ZoneFile "corp.contoso.com.dns"
