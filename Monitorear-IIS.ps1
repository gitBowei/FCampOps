#Monitorear un IIS Web Sites & AppPools con PS

Install-WindowsFeature -Name Web-WMI
$Servers = 'Server01'
Invoke-Command -ComputerName $Servers {
    Import-Module -Name WebAdministration
    $Websites  = Get-Website | Where-Object serverAutoStart -eq $true
    foreach ($Website in $Websites) {
        switch ($Website) {
            {(Get-WebAppPoolState -Name $_.applicationPool).Value -eq 'Stopped'} {Start-WebAppPool -Name $_.applicationPool}
            {$_.State -eq 'Stopped'} {Start-Website -Name $Website.Name}
        }
    }
}