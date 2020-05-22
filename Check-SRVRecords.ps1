## CallTower PowerShell DNS Checker, This script checks all that you have all your DNS entries in place and displays the final route for DNS lookups.
##
## Usage .\Check-SRVRecords.ps1 -domain calltower.com 
##

Param($domain=(Get-WmiObject win32_computersystem).Domain)

$cnameresult = Resolve-DnsName sip.$domain -Server 8.8.8.8 -ErrorAction SilentlyContinue
$lyncdiscoverresult = Resolve-DnsName lyncdiscover.$domain -Server 8.8.8.8 -ErrorAction SilentlyContinue
$federationresult = Resolve-DnsName _sipfederationtls._tcp.$domain -Type SRV -Server 8.8.8.8 -ErrorAction SilentlyContinue
$siptlsresult = Resolve-DnsName _sip._tls.$domain -Type SRV -Server 8.8.8.8 -ErrorAction SilentlyContinue
$notfound = "`tDNS Entry Not Found"

Write-Host "`r`nCNAME Result" -ForegroundColor Cyan
if ($cnameresult) { 
    Write-Host "`tsip.$domain $(@(foreach ($result in $cnameresult.namehost){ '-> '+$result }))" -ForegroundColor Magenta
} else { 
    Write-Host $notfound -ForegroundColor Red
}

Write-Host "`r`nLyncDiscover Result" -ForegroundColor Cyan
if ($lyncdiscoverresult) {
    Write-Host "`tlyncdiscover.$domain $(@(foreach ($result in $lyncdiscoverresult.namehost){ '-> '+$result }))" -ForegroundColor Yellow
} else { 
    Write-Host $notfound -ForegroundColor Red
}

Write-Host "`r`nFederation Result" -ForegroundColor Cyan
if ($federationresult) {
    Write-Host "`t$($federationresult.NameTarget)" -ForegroundColor Green
} else { 
    Write-Host $notfound -ForegroundColor Red
}

Write-Host "`r`nSIP TLS Result" -ForegroundColor Cyan
if ($siptlsresult) {
    Write-Host "`t$($siptlsresult.NameTarget)" -ForegroundColor Green
} else { 
    Write-Host $notfound -ForegroundColor Red
}