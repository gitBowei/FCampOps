Function Add-XYLIETrustedZone {
    # Define the parameters passed to the script
    Param (
        [Parameter(Mandatory=$true,  HelpMessage="Registry Path")][String] $RegistryPath,        [Parameter(Mandatory=$true,  HelpMessage="Domain Name")][String] $DomainName        # [Parameter(Mandatory=$true,  HelpMessage="Host Name")][String] $HostName    )
   
    $OriginalLocation = Get-Location
    Set-Location $RegistryPath
    if (!(Test-Path $($RegistryPath + "\" +$DomainName))){
        New-Item $DomainName
    }
    Set-Location $DomainName
    #if (!(Test-Path $($RegistryPath + "\" + $DomainName + "\" + $HostName))){
    #    New-Item $HostName
    #}

    #Set-Location $($RegistryPath + "\" + $DomainName + "\" + $HostName)
    New-ItemProperty . -Name https -Value 2 -Type DWORD

    Set-Location $OriginalLocation
}

# Get the current default location
$DomainName = "contoso.com"
$ADFSHost = "adfs"
$IntranetHost = "intranet"

# Set our default location to the registry path were trusted domains are located
$RegDomainsPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains"
$RegEscDomainsPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\EscDomains"

# Set the trusted domains for current user
# Add-XYLIETrustedZone -RegistryPath $RegDomainsPath -DomainName $DomainName -HostName $ADFSHost
# Add-XYLIETrustedZone -RegistryPath $RegDomainsPath -DomainName $DomainName -HostName $IntranetHost
Add-XYLIETrustedZone -RegistryPath $RegDomainsPath -DomainName $DomainName

# Set the trusted domains for Internet Enhanced Security (if running on a server operating system)If (Test-Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}") {    # If Internet Enhanced Security is installed (server operating system), add the trusted domains there as well.
    # Add-XYLIETrustedZone -RegistryPath $RegEscDomainsPath -DomainName $DomainName -HostName $ADFSHost
    # Add-XYLIETrustedZone -RegistryPath $RegEscDomainsPath -DomainName $DomainName -HostName $IntranetHost
    Add-XYLIETrustedZone -RegistryPath $RegEscDomainsPath -DomainName $DomainName
}
