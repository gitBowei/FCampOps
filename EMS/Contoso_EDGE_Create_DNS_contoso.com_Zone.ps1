$AddZoneName = "contoso.com"
$DelZoneName = "corp.contoso.com"

# Remove the contoso.com zone if it already exists
If (Get-DnsServerZone -Name $AddZoneName -ErrorAction Ignore) {
    Remove-DnsServerZone -Name $AddZoneName -Force
}

# Remove the corp.contoso.com zone if it already exists
If (Get-DnsServerZone -Name $DelZoneName -ErrorAction Ignore) {
    Remove-DnsServerZone -Name $DelZoneName -Force
}

# Create the contoso.com zone
Add-DnsServerPrimaryZone -Name $AddZoneName -ZoneFile "contoso.com.dns"
Add-DnsServerResourceRecordA -ZoneName $AddZoneName -Name "remote" -IPv4Address "131.107.0.100"
