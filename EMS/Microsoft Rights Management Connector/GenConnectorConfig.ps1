<#
.SYNOPSIS
    Set the registry keys or generate files that can be used to set registry keys to point services at the RMS connector.
.DESCRIPTION
    This command is used to configure registry settings on machines with specific services to point those services at the RMS connector or to create RegEdit files that can be used on machines with these services to configure their registry.  The command can also be used to generate a GPO script that can be used by an Active Direcotry adminsitrator to create a GPO that can be applied to a specific class of machines.
.PARAMETER ConnectorUri
    Required. This is the URI that points at the connector service (e.g.  "http://MyConnector")
.PARAMETER CreateRegEditFiles
    Create a set of RegEdit (.reg) files that can be used on the appropriate machine to configure the registry to point its services at the RMS connector. 
.PARAMETER CreateGPOScript
    Create a PowerShell Script that can be used by an administrator to create a GPO that can be used with the Group Policy Editor to apply required registry settings to a class of machines.
.PARAMETER SetExchange2010
    Configure the registry settings on the current machine to point the 2010 Exchange service at the RMS connector for IRM protection.
.PARAMETER SetExchange2013
    Configure the registry settings on the current machine to point the 2013 Exchange service at the RMS connector for IRM protection.
.PARAMETER SetSharePoint2010
    Configure the registry settings on the current machine to point the 2010 Sharepoint service at the RMS connector for IRM protection.
.PARAMETER SetSharePoint2013
    Configure the registry settings on the current machine to point the 2013 Sharepoint service at the RMS connector for IRM protection.
.PARAMETER SetFCI2012
    Configure the registry settings on the current machine to point the File Server Resource Manager’s File Classification Infrastructure’s RMS protection capabilities in a Windows Server 2012 or Windows Server 2012 R2 file server to the RMS connector for IRM protection.
.PARAMETER OutPath
    The directory location to output the registry files and/or the GPO generation script file.
.EXAMPLE
    Update the registry on the local computer to point the Exchange 2010 IRM configuration to RMS connector.

    .\GenConnectorConfig.ps1 -ConnectorUri http://MyConnector -SetExchange2010
 
.EXAMPLE   
    Generate all the possible RegEdit files that can be used to configure the registry of machines that have services that work with the RMS connector. 

    .\GenConnectorConfig.ps1 -ConnectorUri http://MyConnector -CreateRegEditFiles
 
.EXAMPLE   
    Generate the CreateConnectorRedirectGPOs.ps1 file that can be used by an administrator to create all the GPOs that are needed to configure machines that have services that work with the RMS connector.  Once created, you will need to link the GPOs and target them to the desired objects in Active directory (e.g. the Exchange and SharePoint servers you want to configure).

    .\GenConnectorConfig.ps1 -ConnectorUri http://MyConnector -CreateGPOScript
      
#>

Param(
        [Parameter(Mandatory=$true)] 
        [string] 
        $ConnectorUri, 

        [Parameter(Mandatory=$false)] 
        [Switch]         
        $CreateRegEditFiles,

        [Parameter(Mandatory=$false)] 
        [Switch]         
        $CreateGPOScript,

        [Parameter(Mandatory=$false)] 
        [Switch]         
        $SetExchange2010,

        [Parameter(Mandatory=$false)] 
        [Switch]         
        $SetExchange2013,

        [Parameter(Mandatory=$false)] 
        [Switch]         
        $SetSharePoint2010,

        [Parameter(Mandatory=$false)] 
        [Switch]         
        $SetSharePoint2013,

        [Parameter(Mandatory=$false)] 
        [Switch]         
        $SetFCI2012,

        [Parameter(Mandatory=$false)] 
        [string] 
        $OutPath

)


######

function CreateRegEditFile([string] $RegFilePath)
{
    New-Item $RegFilePath -type file -Force | Out-Null
    Add-Content -Encoding Unicode -Path $RegFilePath -Value "Windows Registry Editor Version 5.00"
    Add-Content -Encoding Unicode -Path $RegFilePath -Value ""
}


function WriteMSDRMServiceLocation([string] $RegFilePath, [string] $RootUri)
{
    Add-Content -Encoding Unicode -Path $RegFilePath -Value "[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSDRM\ServiceLocation\Activation]"
    Add-Content -Encoding Unicode -Path $RegFilePath -Value "@=`"$RootUri/_wmcs/certification`""
    Add-Content -Encoding Unicode -Path $RegFilePath -Value ""
    Add-Content -Encoding Unicode -Path $RegFilePath -Value "[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSDRM\ServiceLocation\EnterprisePublishing]"
    Add-Content -Encoding Unicode -Path $RegFilePath -Value "@=`"$RootUri/_wmcs/licensing`""
    Add-Content -Encoding Unicode -Path $RegFilePath -Value ""
}

function WriteMSIPCServiceLocation([string] $RegFilePath, [string] $RootUri)
{
    Add-Content -Encoding Unicode -Path $RegFilePath -Value "[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSIPC\ServiceLocation\EnterpriseCertification]"
    Add-Content -Encoding Unicode -Path $RegFilePath -Value "@=`"$RootUri/_wmcs/certification`""
    Add-Content -Encoding Unicode -Path $RegFilePath -Value ""
    Add-Content -Encoding Unicode -Path $RegFilePath -Value "[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSIPC\ServiceLocation\EnterprisePublishing]"
    Add-Content -Encoding Unicode -Path $RegFilePath -Value "@=`"$RootUri/_wmcs/licensing`""
    Add-Content -Encoding Unicode -Path $RegFilePath -Value ""
}

function WriteMSIPCLicensingRedirection([string] $RegFilePath, [string] $ConnectorUri, [string] $RmsoUri)
{
    Add-Content -Encoding Unicode -Path $RegFilePath -Value "[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSIPC\ServiceLocation\LicensingRedirection]"
    Add-Content -Encoding Unicode -Path $RegFilePath -Value "`"$RmsoUri/_wmcs/licensing`"=`"$ConnectorUri/_wmcs/licensing`""
    Add-Content -Encoding Unicode -Path $RegFilePath -Value ""
}

function WriteExchange2013RegFile([string] $RegFilePath, [string] $ConnectorUri, [string] $RmsoUri)
{
    CreateRegEditFile $RegFilePath

    WriteMSDRMServiceLocation $RegFilePath $RmsoUri

    Add-Content -Encoding Unicode -Path $RegFilePath -Value "[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\ExchangeServer\V15\IRM\CertificationServerRedirection]"
    Add-Content -Encoding Unicode -Path $RegFilePath -Value "`"$RmsoUri`"=`"$ConnectorUri`""
    Add-Content -Encoding Unicode -Path $RegFilePath -Value ""
    Add-Content -Encoding Unicode -Path $RegFilePath -Value "[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\ExchangeServer\V15\IRM\LicenseServerRedirection]"
    Add-Content -Encoding Unicode -Path $RegFilePath -Value "`"$RmsoUri`"=`"$ConnectorUri`""
    Add-Content -Encoding Unicode -Path $RegFilePath -Value ""
}

function WriteExchange2010RegFile([string] $RegFilePath, [string] $ConnectorUri, [string] $RmsoUri)
{
    CreateRegEditFile $RegFilePath

    WriteMSDRMServiceLocation $RegFilePath $RmsoUri

    Add-Content -Encoding Unicode -Path $RegFilePath -Value "[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\ExchangeServer\V14\IRM\CertificationServerRedirection]"
    Add-Content -Encoding Unicode -Path $RegFilePath -Value "`"$RmsoUri`"=`"$ConnectorUri`""
    Add-Content -Encoding Unicode -Path $RegFilePath -Value ""
    Add-Content -Encoding Unicode -Path $RegFilePath -Value "[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\ExchangeServer\V14\IRM\LicenseServerRedirection]"
    Add-Content -Encoding Unicode -Path $RegFilePath -Value "`"$RmsoUri`"=`"$ConnectorUri`""
    Add-Content -Encoding Unicode -Path $RegFilePath -Value ""
}

function WriteSharePoint2013RegFile([string] $RegFilePath, [string] $ConnectorUri, [string] $RmsoUri)
{
    CreateRegEditFile $RegFilePath

    WriteMSIPCServiceLocation $RegFilePath $ConnectorUri

    WriteMSIPCLicensingRedirection $RegFilePath $ConnectorUri $RmsoUri
}

function WriteSharePoint2010RegFile([string] $RegFilePath, [string] $ConnectorUri, [string] $RmsoUri)
{
    CreateRegEditFile $RegFilePath

    WriteMSDRMServiceLocation $RegFilePath $ConnectorUri
}

function WriteFCI2012RegFile([string] $RegFilePath, [string] $ConnectorUri, [string] $RmsoUri)
{
    CreateRegEditFile $RegFilePath

    WriteMSDRMServiceLocation $RegFilePath $ConnectorUri
}

function WriteGPOScript([string] $GpoScriptFilePath, [string] $ConnectorUri, [string] $RmsoUri)
{
    New-Item $GpoScriptFilePath -type file -Force | Out-Null

    Add-Content -Path $GpoScriptFilePath -Value "Import-Module GroupPolicy"
    Add-Content -Path $GpoScriptFilePath -Value "New-GPO –Name `"AAD RM Connector activation settings for FCI2012`" -Comment `"This GPO was created through a script built by the AAD RM Connector to enable the configuration of activation settings needed for IRM functionality through AAD RM in the registry of servers running the File Classification Infrastructure on Windows Server 2012`""
    Add-Content -Path $GpoScriptFilePath -Value "Set-GPRegistryValue -Name `"AAD RM Connector activation settings for FCI2012`" –Key `"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSDRM\ServiceLocation\Activation`" -ValueName `"(default)`" -Value `"$ConnectorUri/_wmcs/certification`" -Type String -Additive"
    Add-Content -Path $GpoScriptFilePath -Value "Set-GPRegistryValue -Name `"AAD RM Connector activation settings for FCI2012`" –Key `"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSDRM\ServiceLocation\EnterprisePublishing`" -ValueName `"(default)`" -Value `"$ConnectorUri/_wmcs/licensing`" -Type String -Additive"
    Add-Content -Path $GpoScriptFilePath -Value ""
    Add-Content -Path $GpoScriptFilePath -Value "New-GPO –Name `"AAD RM Connector activation settings for SharePoint 2013`" -Comment `"This GPO was created through a script built by the AAD RM Connector to enable the configuration of activation settings needed for IRM functionality through AAD RM in the registry of servers running SharePoint 2013`""
    Add-Content -Path $GpoScriptFilePath -Value "Set-GPRegistryValue -Name `"AAD RM Connector activation settings for SharePoint 2013`" –Key `"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSIPC\ServiceLocation\EnterpriseCertification`" -ValueName `"(default)`" -Value `"$ConnectorUri/_wmcs/certification`" -Type String -Additive"
    Add-Content -Path $GpoScriptFilePath -Value "Set-GPRegistryValue -Name `"AAD RM Connector activation settings for SharePoint 2013`" –Key `"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSIPC\ServiceLocation\EnterprisePublishing`" -ValueName `"(default)`" -Value `"$ConnectorUri/_wmcs/licensing`" -Type String -Additive"
    Add-Content -Path $GpoScriptFilePath -Value "Set-GPRegistryValue -Name `"AAD RM Connector activation settings for SharePoint 2013`" –Key `"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSIPC\ServiceLocation\LicensingRedirection`" -ValueName `"$RmsoUri/_wmcs/licensing`" -Value `"$ConnectorUri/_wmcs/licensing`" -Type String -Additive"
    Add-Content -Path $GpoScriptFilePath -Value ""
    Add-Content -Path $GpoScriptFilePath -Value "New-GPO –Name `"AAD RM Connector redirection settings for SharePoint 2010`" -Comment `"This GPO was created through a script built by the AAD RM Connector to enable the configuration of redirection settings needed for IRM functionality through AAD RM in the registry of servers running SharePoint 2010`""
    Add-Content -Path $GpoScriptFilePath -Value "Set-GPRegistryValue -Name `"AAD RM Connector redirection settings for SharePoint 2010`" –Key `"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSDRM\ServiceLocation\Activation`" -ValueName `"(default)`" -Value `"$ConnectorUri/_wmcs/certification`" -Type String -Additive"
    Add-Content -Path $GpoScriptFilePath -Value "Set-GPRegistryValue -Name `"AAD RM Connector redirection settings for SharePoint 2010`" –Key `"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSDRM\ServiceLocation\EnterprisePublishing`" -ValueName `"(default)`" -Value `"$ConnectorUri/_wmcs/licensing`" -Type String -Additive"
    Add-Content -Path $GpoScriptFilePath -Value ""
    Add-Content -Path $GpoScriptFilePath -Value "New-GPO –Name `"AAD RM Connector redirection settings for Exchange 2013`" -Comment `"This GPO was created through a script built by the AAD RM Connector to enable the configuration of redirection settings needed for IRM functionality through AAD RM in the registry of servers running Exchange 2013`""
    Add-Content -Path $GpoScriptFilePath -Value "Set-GPRegistryValue -Name `"AAD RM Connector redirection settings for Exchange 2013`" –Key `"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSDRM\ServiceLocation\Activation`" -ValueName `"(default)`" -Value `"$RmsoUri/_wmcs/certification`" -Type String -Additive"
    Add-Content -Path $GpoScriptFilePath -Value "Set-GPRegistryValue -Name `"AAD RM Connector redirection settings for Exchange 2013`" –Key `"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSDRM\ServiceLocation\EnterprisePublishing`" -ValueName `"(default)`" -Value `"$RmsoUri/_wmcs/licensing`" -Type String -Additive"
    Add-Content -Path $GpoScriptFilePath -Value "Set-GPRegistryValue -Name `"AAD RM Connector redirection settings for Exchange 2013`" –Key `"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\ExchangeServer\V15\IRM\LicenseServerRedirection`" -ValueName `"$RmsoUri`" -Value `"$ConnectorUri`" -Type String -Additive"
    Add-Content -Path $GpoScriptFilePath -Value "Set-GPRegistryValue -Name `"AAD RM Connector redirection settings for Exchange 2013`" –Key `"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\ExchangeServer\V15\IRM\CertificationServerRedirection`" -ValueName `"$RmsoUri`" -Value `"$ConnectorUri`" -Type String -Additive"
    Add-Content -Path $GpoScriptFilePath -Value ""
    Add-Content -Path $GpoScriptFilePath -Value "New-GPO –Name `"AAD RM Connector redirection settings for Exchange 2010`" -Comment `"This GPO was created through a script built by the AAD RM Connector to enable the configuration of redirection settings needed for IRM functionality through AAD RM in the registry of servers running Exchange 2010`""
    Add-Content -Path $GpoScriptFilePath -Value "Set-GPRegistryValue -Name `"AAD RM Connector redirection settings for Exchange 2010`" –Key `"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSDRM\ServiceLocation\Activation`" -ValueName `"(default)`" -Value `"$RmsoUri/_wmcs/certification`" -Type String -Additive"
    Add-Content -Path $GpoScriptFilePath -Value "Set-GPRegistryValue -Name `"AAD RM Connector redirection settings for Exchange 2010`" –Key `"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSDRM\ServiceLocation\EnterprisePublishing`" -ValueName `"(default)`" -Value `"$RmsoUri/_wmcs/licensing`" -Type String -Additive"
    Add-Content -Path $GpoScriptFilePath -Value "Set-GPRegistryValue -Name `"AAD RM Connector redirection settings for Exchange 2010`" –Key `"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\ExchangeServer\V14\IRM\LicenseServerRedirection`" -ValueName `"$RmsoUri`" -Value `"$ConnectorUri`" -Type String -Additive"
    Add-Content -Path $GpoScriptFilePath -Value "Set-GPRegistryValue -Name `"AAD RM Connector redirection settings for Exchange 2010`" –Key `"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\ExchangeServer\V14\IRM\CertificationServerRedirection`" -ValueName `"$RmsoUri`" -Value `"$ConnectorUri`" -Type String -Additive"
}

function RegisterAndRemoveFile([string] $RegFilePath)
{
    # Start the RegEdit process and elevate privileges if necessary. 
    #
    $job = Start-Process -FilePath "RegEdit.exe" -ArgumentList "-s `"$RegFilePath`"" -Verb RunAs -PassThru

    # Cannot use Wait-Job since if the process is launched as elevated from non-elevated window Wait-Job does not work.
    #
    while($job.HasExited -ne $true)
    {
        Start-Sleep -Milliseconds 500
    }

    Remove-Item "$RegFilePath"
}

function AddSettingsPrompt()
{
    do
    {
        $input = Read-Host "Install settings? [Y/N]"
        if ($input -ieq "Y")
        {
            return $true;
        }

        if ($input -ieq "N")
        {
            return $false;
        }
    } while ($true)
}

function VerifyMSDRMCryptoMode2Update()
{
    $prompt = $false

    $value = (Get-Command "$env:windir\system32\msdrm.dll").FileVersionInfo.FileVersion
    $versions = $value.Split(" ")[0].Split(".")

    if ($versions.Length -ne 4)
    {
        Write-Host "The MSDRM version number does not appear to be valid. (Version: $value)" -ForegroundColor Red
        $prompt = $true
    }
    else
    {
	$version = [version]$value.Split(" ")[0]

        if ($version.Major-lt 6)
        {
            $prompt = $true
        }

        if (($version.Major -eq 6) -and ($version.Minor -eq 0) -and (($version.Build -lt 6002) -or (($version.Build -eq 6002) -and ($version.Revision -lt 22761))))
        {
            $prompt = $true
        }

        if (($version.Major -eq 6) -and ($version.Minor -eq 1) -and (($version.Build -lt 7600) -or (($version.Build -eq 7600) -and ($version.Revision -lt 17000))))
        {
            $prompt = $true
        }
    }

    if ($prompt)
    {
        Write-Host "The version of MSDRM on this machine does not support strong crypto.  In most cases you will need a version of MSDRM that supports strong crypto in order to work with Windows Azure Rights Management through the RMS Connector. Please see the following support article for information about the Windows hotfix to support strong crypto: http://support.microsoft.com/kb/2627272" -ForegroundColor Yellow
    }

    return $prompt
}

function VerifyDependenciesFCI()
{
    if (VerifyMSDRMCryptoMode2Update)
    {
        return AddSettingsPrompt
    }

    return $true
}

function VerifyDependenciesExchange2013()
{
    $value = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\ExchangeServer\v15\Setup" -ErrorAction SilentlyContinue).MsiProductMajor
    if (! $value)
    {
        Write-Host "Exchange 2013 does not appear to be installed on this machine." -ForegroundColor Red
        return AddSettingsPrompt
    }

    if (VerifyMSDRMCryptoMode2Update)
    {
        return AddSettingsPrompt
    }

    return $true
}

function VerifyDependenciesExchange2010()
{
    $value = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\ExchangeServer\v14\Setup" -ErrorAction SilentlyContinue).MsiProductMajor
    if (! $value)
    {
        Write-Host "Exchange 2010 does not appear to be installed on this machine." -ForegroundColor Red
        return AddSettingsPrompt
    }

    if (VerifyMSDRMCryptoMode2Update)
    {
        return AddSettingsPrompt
    }

    return $true
}

function VerifyDependenciesSharePoint2013()
{
    $prompt = $false

    [string] $value = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Shared Tools\Web Server Extensions\15.0" -ErrorAction SilentlyContinue).Version
    if (! $value)
    {
        Write-Host "SharePoint 2013 does not appear to be installed on this machine." -ForegroundColor Red
        $prompt = $true
    }

    $value = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\MSIPC\CurrentVersion" -ErrorAction SilentlyContinue).'(default)'
    if (! $value)
    {
        Write-Host "MSIPC does not appear to be installed on this machine." -ForegroundColor Red
        $prompt = $true
    }
    else
    {
        $versions = $value.Split(".")

        if ($versions.Length -ne 4)
        {
            Write-Host "The MSIPC version number does not appear to be valid. (Version: $value)" -ForegroundColor Red
            $prompt = $true
        }
        else
        {
            $version = [version]$value

            if (($version.Major -lt 1) -or (($version.Major -eq 1) -and ($version.Minor -eq 0) -and ($version.Build -lt 622)) -or (($version.Major -eq 1) -and ($version.Minor -eq 0) -and ($version.Build -eq 622) -and ($version.Revision -lt 34)))
            {
                Write-Host "Please update the version of MSIPC on this machine, the minimum version required is 1.0.622.34.  (Current Version: $value).  The latest supported version can be found at http://www.microsoft.com/en-us/download/details.aspx?id=38396" -ForegroundColor Red
                $prompt = $true
            }
        }
    }

    if ($prompt)
    {
        return AddSettingsPrompt
    }

    return $true
}

function VerifyDependenciesSharePoint2010()
{
    $value = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Shared Tools\Web Server Extensions\14.0" -ErrorAction SilentlyContinue).Version
    if (! $value)
    {
        Write-Host "SharePoint 2010 does not appear to be installed on this machine." -ForegroundColor Red
        return AddSettingsPrompt
    }

    if (VerifyMSDRMCryptoMode2Update)
    {
        return AddSettingsPrompt
    }

    return $true
}

####################################################################
# Main entry point for script


if ($OutPath -eq "")
{
    $OutPath = "."
}

if ($OutPath.EndsWith("\"))
{
    $OutPath = $OutPath.Substring(0, $OutPath.Length - 1)
}

# Remove any extra "/" characters from the end of the Connector Uri if it exists.
#
if ($ConnectorUri.EndsWith("/"))
{
    $ConnectorUri = $ConnectorUri.Substring(0, $ConnectorUri.Length - 1)
}

# Get the Rmso Uri from the connector service Url provided.
#
$WebClient = New-Object System.Net.WebClient
$WebClient.UseDefaultCredentials = $true  # Necessary because the site only allows Window Authenticated users to access it.
$RmsoUri = $WebClient.DownloadString($ConnectorUri + "/_wmcs/GetRmsoUri.aspx")

# Remove any extra "/" characters from the end of the RMSO Uri if it exists.
#
if ($RmsoUri.EndsWith("/"))
{
    $RmsoUri = $RmsoUri.Substring(0, $RmsoUri.Length - 1)
}

#
#
if ($CreateRegEditFiles)
{
    $Exchange2013FileName = $OutPath + "\Exchange2013RedirectionConfiguration.reg"
    WriteExchange2013RegFile $Exchange2013FileName $ConnectorUri $RmsoUri

    $Exchange2010FileName = $OutPath + "\Exchange2010RedirectionConfiguration.reg"
    WriteExchange2010RegFile $Exchange2010FileName $ConnectorUri $RmsoUri

    $SharePoint2013FileName = $OutPath + "\SharePoint2013RedirectionConfiguration.reg"
    WriteSharePoint2013RegFile $SharePoint2013FileName $ConnectorUri $RmsoUri

    $SharePoint2010FileName = $OutPath + "\SharePoint2010RedirectionConfiguration.reg"
    WriteSharePoint2010RegFile $SharePoint2010FileName $ConnectorUri $RmsoUri

    $FCI2012FileName = $OutPath + "\FCI2012RedirectionConfiguration.reg"
    WriteFCI2012RegFile $FCI2012FileName $ConnectorUri $RmsoUri
}

if ($CreateGPOScript)
{
    $GPOScrioptFileName = $OutPath + "\CreateConnectorRedirectGPOs.ps1"
    WriteGPOScript $GPOScrioptFileName $ConnectorUri $RmsoUri
}

if ($SetExchange2013)
{
    if (VerifyDependenciesExchange2013)
    {
        $RegFilePath = $env:TEMP + "\Exchange2013RedirectionConfiguration.reg"
        WriteExchange2013RegFile $RegFilePath $ConnectorUri $RmsoUri
        RegisterAndRemoveFile $RegFilePath
    }
}

if ($SetExchange2010)
{
    if (VerifyDependenciesExchange2010)
    {
        $RegFilePath = $env:TEMP + "\Exchange2010RedirectionConfiguration.reg"
        WriteExchange2010RegFile $RegFilePath $ConnectorUri $RmsoUri
        RegisterAndRemoveFile $RegFilePath
    }
    
}

if ($SetSharePoint2013)
{
    if (VerifyDependenciesSharePoint2013)
    {
        $RegFilePath = $env:TEMP + "\SharePoint2013RedirectionConfiguration.reg"
        WriteSharePoint2013RegFile $RegFilePath $ConnectorUri $RmsoUri
        RegisterAndRemoveFile $RegFilePath
    }
}

if ($SetSharePoint2010)
{
    if (VerifyDependenciesSharePoint2010)
    {
        $RegFilePath = $env:TEMP + "\SharePoint2010RedirectionConfiguration.reg"
        WriteSharePoint2010RegFile $RegFilePath $ConnectorUri $RmsoUri
        RegisterAndRemoveFile $RegFilePath
    }
}

if ($SetFCI2012)
{
    if (VerifyDependenciesFCI)
    {
        $RegFilePath = $env:TEMP + "\FCI2012RedirectionConfiguration.reg"
        WriteFCI2012RegFile $RegFilePath $ConnectorUri $RmsoUri
        RegisterAndRemoveFile $RegFilePath
    }
}

# SIG # Begin signature block
# MIIawQYJKoZIhvcNAQcCoIIasjCCGq4CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUds1lOdwV04rre4hezAFT3INP
# sv+gghWCMIIEwzCCA6ugAwIBAgITMwAAADPlJ4ajDkoqgAAAAAAAMzANBgkqhkiG
# 9w0BAQUFADB3MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4G
# A1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSEw
# HwYDVQQDExhNaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EwHhcNMTMwMzI3MjAwODIz
# WhcNMTQwNjI3MjAwODIzWjCBszELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hp
# bmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jw
# b3JhdGlvbjENMAsGA1UECxMETU9QUjEnMCUGA1UECxMebkNpcGhlciBEU0UgRVNO
# OkY1MjgtMzc3Ny04QTc2MSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFtcCBT
# ZXJ2aWNlMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAyt7KGQ8fllaC
# X9hCMtQIbbadwMLtfDirWDOta4FQuIghCl2vly2QWsfDLrJM1GN0WP3fxYlU0AvM
# /ZyEEXmsoyEibTPgrt4lQEWSTg1jCCuLN91PB2rcKs8QWo9XXZ09+hdjAsZwPrsi
# 7Vux9zK65HG8ef/4y+lXP3R75vJ9fFdYL6zSDqjZiNlAHzoiQeIJJgKgzOUlzoxn
# g99G+IVNw9pmHsdzfju0dhempaCgdFWo5WAYQWI4x2VGqwQWZlbq+abLQs9dVGQv
# gfjPOAAPEGvhgy6NPkjsSVZK7Jpp9MsPEPsHNEpibAGNbscghMpc0WOZHo5d7A+l
# Fkiqa94hLwIDAQABo4IBCTCCAQUwHQYDVR0OBBYEFABYGz7txfEGk74xPTa0rAtd
# MvCBMB8GA1UdIwQYMBaAFCM0+NlSRnAK7UD7dvuzK7DDNbMPMFQGA1UdHwRNMEsw
# SaBHoEWGQ2h0dHA6Ly9jcmwubWljcm9zb2Z0LmNvbS9wa2kvY3JsL3Byb2R1Y3Rz
# L01pY3Jvc29mdFRpbWVTdGFtcFBDQS5jcmwwWAYIKwYBBQUHAQEETDBKMEgGCCsG
# AQUFBzAChjxodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY3Jv
# c29mdFRpbWVTdGFtcFBDQS5jcnQwEwYDVR0lBAwwCgYIKwYBBQUHAwgwDQYJKoZI
# hvcNAQEFBQADggEBAAL/44wD6u9+OLm5fJ87UoOk+iM41AO4alm16uBviAP0b1Fq
# lTp1hegc3AfFTp0bqM4kRxQkTzV3sZy8J3uPXU/8BouXl/kpm/dAHVKBjnZIA37y
# mxe3rtlbIpFjOzJfNfvGkTzM7w6ZgD4GkTgTegxMvjPbv+2tQcZ8GyR8E9wK/EuK
# IAUdCYmROQdOIU7ebHxwu6vxII74mHhg3IuUz2W+lpAPoJyE7Vy1fEGgYS29Q2dl
# GiqC1KeKWfcy46PnxY2yIruSKNiwjFOPaEdHodgBsPFhFcQXoS3jOmxPb6897t4p
# sETLw5JnugDOD44R79ECgjFJlJidUUh4rR3WQLYwggTsMIID1KADAgECAhMzAAAA
# sBGvCovQO5/dAAEAAACwMA0GCSqGSIb3DQEBBQUAMHkxCzAJBgNVBAYTAlVTMRMw
# EQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
# aWNyb3NvZnQgQ29ycG9yYXRpb24xIzAhBgNVBAMTGk1pY3Jvc29mdCBDb2RlIFNp
# Z25pbmcgUENBMB4XDTEzMDEyNDIyMzMzOVoXDTE0MDQyNDIyMzMzOVowgYMxCzAJ
# BgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25k
# MR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xDTALBgNVBAsTBE1PUFIx
# HjAcBgNVBAMTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjCCASIwDQYJKoZIhvcNAQEB
# BQADggEPADCCAQoCggEBAOivXKIgDfgofLwFe3+t7ut2rChTPzrbQH2zjjPmVz+l
# URU0VKXPtIupP6g34S1Q7TUWTu9NetsTdoiwLPBZXKnr4dcpdeQbhSeb8/gtnkE2
# KwtA+747urlcdZMWUkvKM8U3sPPrfqj1QRVcCGUdITfwLLoiCxCxEJ13IoWEfE+5
# G5Cw9aP+i/QMmk6g9ckKIeKq4wE2R/0vgmqBA/WpNdyUV537S9QOgts4jxL+49Z6
# dIhk4WLEJS4qrp0YHw4etsKvJLQOULzeHJNcSaZ5tbbbzvlweygBhLgqKc+/qQUF
# 4eAPcU39rVwjgynrx8VKyOgnhNN+xkMLlQAFsU9lccUCAwEAAaOCAWAwggFcMBMG
# A1UdJQQMMAoGCCsGAQUFBwMDMB0GA1UdDgQWBBRZcaZaM03amAeA/4Qevof5cjJB
# 8jBRBgNVHREESjBIpEYwRDENMAsGA1UECxMETU9QUjEzMDEGA1UEBRMqMzE1OTUr
# NGZhZjBiNzEtYWQzNy00YWEzLWE2NzEtNzZiYzA1MjM0NGFkMB8GA1UdIwQYMBaA
# FMsR6MrStBZYAck3LjMWFrlMmgofMFYGA1UdHwRPME0wS6BJoEeGRWh0dHA6Ly9j
# cmwubWljcm9zb2Z0LmNvbS9wa2kvY3JsL3Byb2R1Y3RzL01pY0NvZFNpZ1BDQV8w
# OC0zMS0yMDEwLmNybDBaBggrBgEFBQcBAQROMEwwSgYIKwYBBQUHMAKGPmh0dHA6
# Ly93d3cubWljcm9zb2Z0LmNvbS9wa2kvY2VydHMvTWljQ29kU2lnUENBXzA4LTMx
# LTIwMTAuY3J0MA0GCSqGSIb3DQEBBQUAA4IBAQAx124qElczgdWdxuv5OtRETQie
# 7l7falu3ec8CnLx2aJ6QoZwLw3+ijPFNupU5+w3g4Zv0XSQPG42IFTp8263Os8ls
# ujksRX0kEVQmMA0N/0fqAwfl5GZdLHudHakQ+hywdPJPaWueqSSE2u2WoN9zpO9q
# GqxLYp7xfMAUf0jNTbJE+fA8k21C2Oh85hegm2hoCSj5ApfvEQO6Z1Ktwemzc6bS
# Y81K4j7k8079/6HguwITO10g3lU/o66QQDE4dSheBKlGbeb1enlAvR/N6EXVruJd
# PvV1x+ZmY2DM1ZqEh40kMPfvNNBjHbFCZ0oOS786Du+2lTqnOOQlkgimiGaCMIIF
# vDCCA6SgAwIBAgIKYTMmGgAAAAAAMTANBgkqhkiG9w0BAQUFADBfMRMwEQYKCZIm
# iZPyLGQBGRYDY29tMRkwFwYKCZImiZPyLGQBGRYJbWljcm9zb2Z0MS0wKwYDVQQD
# EyRNaWNyb3NvZnQgUm9vdCBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkwHhcNMTAwODMx
# MjIxOTMyWhcNMjAwODMxMjIyOTMyWjB5MQswCQYDVQQGEwJVUzETMBEGA1UECBMK
# V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
# IENvcnBvcmF0aW9uMSMwIQYDVQQDExpNaWNyb3NvZnQgQ29kZSBTaWduaW5nIFBD
# QTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALJyWVwZMGS/HZpgICBC
# mXZTbD4b1m/My/Hqa/6XFhDg3zp0gxq3L6Ay7P/ewkJOI9VyANs1VwqJyq4gSfTw
# aKxNS42lvXlLcZtHB9r9Jd+ddYjPqnNEf9eB2/O98jakyVxF3K+tPeAoaJcap6Vy
# c1bxF5Tk/TWUcqDWdl8ed0WDhTgW0HNbBbpnUo2lsmkv2hkL/pJ0KeJ2L1TdFDBZ
# +NKNYv3LyV9GMVC5JxPkQDDPcikQKCLHN049oDI9kM2hOAaFXE5WgigqBTK3S9dP
# Y+fSLWLxRT3nrAgA9kahntFbjCZT6HqqSvJGzzc8OJ60d1ylF56NyxGPVjzBrAlf
# A9MCAwEAAaOCAV4wggFaMA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFMsR6MrS
# tBZYAck3LjMWFrlMmgofMAsGA1UdDwQEAwIBhjASBgkrBgEEAYI3FQEEBQIDAQAB
# MCMGCSsGAQQBgjcVAgQWBBT90TFO0yaKleGYYDuoMW+mPLzYLTAZBgkrBgEEAYI3
# FAIEDB4KAFMAdQBiAEMAQTAfBgNVHSMEGDAWgBQOrIJgQFYnl+UlE/wq4QpTlVnk
# pDBQBgNVHR8ESTBHMEWgQ6BBhj9odHRwOi8vY3JsLm1pY3Jvc29mdC5jb20vcGtp
# L2NybC9wcm9kdWN0cy9taWNyb3NvZnRyb290Y2VydC5jcmwwVAYIKwYBBQUHAQEE
# SDBGMEQGCCsGAQUFBzAChjhodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpL2Nl
# cnRzL01pY3Jvc29mdFJvb3RDZXJ0LmNydDANBgkqhkiG9w0BAQUFAAOCAgEAWTk+
# fyZGr+tvQLEytWrrDi9uqEn361917Uw7LddDrQv+y+ktMaMjzHxQmIAhXaw9L0y6
# oqhWnONwu7i0+Hm1SXL3PupBf8rhDBdpy6WcIC36C1DEVs0t40rSvHDnqA2iA6VW
# 4LiKS1fylUKc8fPv7uOGHzQ8uFaa8FMjhSqkghyT4pQHHfLiTviMocroE6WRTsgb
# 0o9ylSpxbZsa+BzwU9ZnzCL/XB3Nooy9J7J5Y1ZEolHN+emjWFbdmwJFRC9f9Nqu
# 1IIybvyklRPk62nnqaIsvsgrEA5ljpnb9aL6EiYJZTiU8XofSrvR4Vbo0HiWGFzJ
# NRZf3ZMdSY4tvq00RBzuEBUaAF3dNVshzpjHCe6FDoxPbQ4TTj18KUicctHzbMrB
# 7HCjV5JXfZSNoBtIA1r3z6NnCnSlNu0tLxfI5nI3EvRvsTxngvlSso0zFmUeDord
# EN5k9G/ORtTTF+l5xAS00/ss3x+KnqwK+xMnQK3k+eGpf0a7B2BHZWBATrBC7E7t
# s3Z52Ao0CW0cgDEf4g5U3eWh++VHEK1kmP9QFi58vwUheuKVQSdpw5OPlcmN2Jsh
# rg1cnPCiroZogwxqLbt2awAdlq3yFnv2FoMkuYjPaqhHMS+a3ONxPdcAfmJH0c6I
# ybgY+g5yjcGjPa8CQGr/aZuW4hCoELQ3UAjWwz0wggYHMIID76ADAgECAgphFmg0
# AAAAAAAcMA0GCSqGSIb3DQEBBQUAMF8xEzARBgoJkiaJk/IsZAEZFgNjb20xGTAX
# BgoJkiaJk/IsZAEZFgltaWNyb3NvZnQxLTArBgNVBAMTJE1pY3Jvc29mdCBSb290
# IENlcnRpZmljYXRlIEF1dGhvcml0eTAeFw0wNzA0MDMxMjUzMDlaFw0yMTA0MDMx
# MzAzMDlaMHcxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYD
# VQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xITAf
# BgNVBAMTGE1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQTCCASIwDQYJKoZIhvcNAQEB
# BQADggEPADCCAQoCggEBAJ+hbLHf20iSKnxrLhnhveLjxZlRI1Ctzt0YTiQP7tGn
# 0UytdDAgEesH1VSVFUmUG0KSrphcMCbaAGvoe73siQcP9w4EmPCJzB/LMySHnfL0
# Zxws/HvniB3q506jocEjU8qN+kXPCdBer9CwQgSi+aZsk2fXKNxGU7CG0OUoRi4n
# rIZPVVIM5AMs+2qQkDBuh/NZMJ36ftaXs+ghl3740hPzCLdTbVK0RZCfSABKR2YR
# JylmqJfk0waBSqL5hKcRRxQJgp+E7VV4/gGaHVAIhQAQMEbtt94jRrvELVSfrx54
# QTF3zJvfO4OToWECtR0Nsfz3m7IBziJLVP/5BcPCIAsCAwEAAaOCAaswggGnMA8G
# A1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFCM0+NlSRnAK7UD7dvuzK7DDNbMPMAsG
# A1UdDwQEAwIBhjAQBgkrBgEEAYI3FQEEAwIBADCBmAYDVR0jBIGQMIGNgBQOrIJg
# QFYnl+UlE/wq4QpTlVnkpKFjpGEwXzETMBEGCgmSJomT8ixkARkWA2NvbTEZMBcG
# CgmSJomT8ixkARkWCW1pY3Jvc29mdDEtMCsGA1UEAxMkTWljcm9zb2Z0IFJvb3Qg
# Q2VydGlmaWNhdGUgQXV0aG9yaXR5ghB5rRahSqClrUxzWPQHEy5lMFAGA1UdHwRJ
# MEcwRaBDoEGGP2h0dHA6Ly9jcmwubWljcm9zb2Z0LmNvbS9wa2kvY3JsL3Byb2R1
# Y3RzL21pY3Jvc29mdHJvb3RjZXJ0LmNybDBUBggrBgEFBQcBAQRIMEYwRAYIKwYB
# BQUHMAKGOGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2kvY2VydHMvTWljcm9z
# b2Z0Um9vdENlcnQuY3J0MBMGA1UdJQQMMAoGCCsGAQUFBwMIMA0GCSqGSIb3DQEB
# BQUAA4ICAQAQl4rDXANENt3ptK132855UU0BsS50cVttDBOrzr57j7gu1BKijG1i
# uFcCy04gE1CZ3XpA4le7r1iaHOEdAYasu3jyi9DsOwHu4r6PCgXIjUji8FMV3U+r
# kuTnjWrVgMHmlPIGL4UD6ZEqJCJw+/b85HiZLg33B+JwvBhOnY5rCnKVuKE5nGct
# xVEO6mJcPxaYiyA/4gcaMvnMMUp2MT0rcgvI6nA9/4UKE9/CCmGO8Ne4F+tOi3/F
# NSteo7/rvH0LQnvUU3Ih7jDKu3hlXFsBFwoUDtLaFJj1PLlmWLMtL+f5hYbMUVbo
# nXCUbKw5TNT2eb+qGHpiKe+imyk0BncaYsk9Hm0fgvALxyy7z0Oz5fnsfbXjpKh0
# NbhOxXEjEiZ2CzxSjHFaRkMUvLOzsE1nyJ9C/4B5IYCeFTBm6EISXhrIniIh0EPp
# K+m79EjMLNTYMoBMJipIJF9a6lbvpt6Znco6b72BJ3QGEe52Ib+bgsEnVLaxaj2J
# oXZhtG6hE6a/qkfwEm/9ijJssv7fUciMI8lmvZ0dhxJkAj0tr1mPuOQh5bWwymO0
# eFQF1EEuUKyUsKV4q7OglnUa2ZKHE3UiLzKoCG6gW4wlv6DvhMoh1useT8ma7kng
# 9wFlb4kLfchpyOZu6qeXzjEp/w7FW1zYTRuh2Povnj8uVRZryROj/TGCBKkwggSl
# AgEBMIGQMHkxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYD
# VQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xIzAh
# BgNVBAMTGk1pY3Jvc29mdCBDb2RlIFNpZ25pbmcgUENBAhMzAAAAsBGvCovQO5/d
# AAEAAACwMAkGBSsOAwIaBQCggcIwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQw
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFCrM
# ydGYu2YzlrJvnsKkWSp3YXujMGIGCisGAQQBgjcCAQwxVDBSoC6ALABHAGUAbgBD
# AG8AbgBuAGUAYwB0AG8AcgBDAG8AbgBmAGkAZwAuAHAAcwAxoSCAHmh0dHA6Ly93
# d3cuTWljcm9zb2Z0T25saW5lLmNvbTANBgkqhkiG9w0BAQEFAASCAQAJ1EiyAx6m
# KnG3RApH2YXd3o7WNe+bMv5TdR8CKoF66yNmEbPdRwlh1uk0sETtYzh7DnaXunT+
# 9QZn/lkNqBN/reVRA16Mgs2YJ2sCkKyMcwDqTnhc8cQxp9QSWRnNy9fk99THNvNR
# MWZIuo6YhmXGkkbEkrNYOR2ZFs2Q2jWkS0kM/d1zr8q96MZg0om+bAeR7ljO2b4G
# 2sZkMM9LG00d3mhsGlDVYVp4pVpDJkESo07r8rTPH+wjQim7tEU8zh+kW2ePBwj3
# SCHFGCLUXviuq+bA3jhQxsmlNU6GOSJ5MosprSU2KZ5a24U/Ew1q/l9oK6/Ysmq5
# Yu+oehjKFKhCoYICKDCCAiQGCSqGSIb3DQEJBjGCAhUwggIRAgEBMIGOMHcxCzAJ
# BgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25k
# MR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xITAfBgNVBAMTGE1pY3Jv
# c29mdCBUaW1lLVN0YW1wIFBDQQITMwAAADPlJ4ajDkoqgAAAAAAAMzAJBgUrDgMC
# GgUAoF0wGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcN
# MTQwNDE4MTczMTU0WjAjBgkqhkiG9w0BCQQxFgQUQ8cCuaniQ/SKs8eXpJXQ4K+6
# AdUwDQYJKoZIhvcNAQEFBQAEggEAI8rCt93DNYwSU6u2yo6FIxKjaBebXfRrDLn2
# pmt3epOnkc/6hN97My2uwjz1mwKtzGJiWFGksMu1q7Ex7IxgcAWG+aWxn5SOfF9a
# s7FV7yju9b/9aUSDbnd0QT9XyAr2RerJe1qpRkwWFyUff4AfZzYNP/7XXgbU9+SV
# L/alYCOmwqFRmbT2q3yCcJVjo4VX7Ye64/irihwPzO3eElbgtqyG1QA7T7HDy4xR
# KeTc+T0B7vGt9FQB3dqpg7rPllcRXzHc5L2JG7Tr9cZXEoOL6HywCGUottqJIpQj
# PRZFNXR3w3Y9UBFui3D2am03LPwvITxei1Gh0o6shO5zfT/REw==
# SIG # End signature block
