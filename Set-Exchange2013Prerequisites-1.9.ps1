<#  
.SYNOPSIS
   	Configures the necessary prerequisites to install Exchange 2013 CU7+ on a Windows Server 2008 R2 or 2012 (R2) server.

.DESCRIPTION  
    Installs all required Windows 2008 R2 or 2012 (R2) components, the filter pack, and configures service startup settings. Provides options for disabling TCP/IP v6, downloading latest Update Rollup, etc.  First the script will determine the version of the OS you are running and then provide the correct menu items.

.NOTES  
    Version      		: 1.9 - Added a way to disable SSL 3.0 and RC4 encryption.
    Change Log			: 1.8 - Added PowerManagement
				: 1.7 - Removed old versions of .NET (performance isue) and Windows Framework 3.0, added Edge Transport check and Office 201 SP2 Filter Pack
				: 1.6 - Added support for Windows 2012 R2, added options for Edge Role installation and cleaned up old items
				: 1.5 - Added support for Exchange 2013 RTM CU1, additional error suppression
				: 1.4 - Added support for Exchange 2013 RTM
				: 1.3 - Fixed Reboot for Windows Server 2012 RTM
				: 1.2 - fixed install commands for Windows Server 2012.  Split CAS/MX role install.
				: 1.1 - Added Windows Server 2012 Preview support
				: 1.0 - Created script for Windows Server 2008 R2 installs
    Wish list			: better comment based help
				: static port mapping
				: event log logging
    Rights Required		: Local admin on server
    Sched Task Req'd		: No
    Exchange Version		: 2013
    Author       		: Just A UC Guy [JAUCG]
    Email/Blog/Twitter	        : ( ) 	http://justaucguy.wordpress.com/
    Dedicated Blog		: http://justaucguy.wordpress.com/
    Disclaimer   		: You are on your own.  This was not written by, support by, or endorsed by Microsoft.
    Info Stolen from 		: Anderson Patricio, Bhargav Shukla and Pat Richard [Exchange 2010 script]
    				: http://msmvps.com/blogs/andersonpatricio/archive/2009/11/13/installing-exchange-server-2010-pre-requisites-on-windows-server-2008-r2.aspx
				: http://www.bhargavs.com/index.php/powershell/2009/11/script-to-install-exchange-2010-pre-requisites-for-windows-server-2008-r2/
.LINK  
[TBD]

.EXAMPLE
	.\Set-Exchange2013Prerequisites-1-9.ps1

.INPUTS
	None. You cannot pipe objects to this script.
#>
#Requires -Version 2.0
param(
	[parameter(ValueFromPipeline=$false, ValueFromPipelineByPropertyName=$false, Mandatory=$false)] 
	[string] $strFilenameTranscript = $MyInvocation.MyCommand.Name + " " + (hostname)+ " {0:yyyy-MM-dd hh-mmtt}.log" -f (Get-Date),
	[parameter(ValueFromPipeline=$false, ValueFromPipelineByPropertyName=$true, Mandatory=$false)] 
	[string] $TargetFolder = "c:\Install",
	# [string] $TargetFolder = $Env:Temp
	[parameter(ValueFromPipeline=$false, ValueFromPipelineByPropertyName=$false, Mandatory=$false)] 
	[bool] $WasInstalled = $false,
	[parameter(ValueFromPipeline=$false, ValueFromPipelineByPropertyName=$false, Mandatory=$false)] 
	[bool] $RebootRequired = $false,
	[parameter(ValueFromPipeline=$false, ValueFromPipelineByPropertyName=$false, Mandatory=$false)] 
	[string] $opt = "None",
	[parameter(ValueFromPipeline=$false, ValueFromPipelineByPropertyName=$false, Mandatory=$false)] 
	[bool] $HasInternetAccess = ([Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]'{DCB00C01-570F-4A9B-8D69-199FDBA5723B}')).IsConnectedToInternet)
)

Start-Transcript -path .\$strFilenameTranscript | Out-Null
$error.clear()
# Detect correct OS here and exit if no match (we intentionally truncate the last character to account for service packs)

# ******************************************************
# *	This section is for the Windows 2008 R2 SP1 OS *
# ******************************************************

if ((Get-WMIObject win32_OperatingSystem).Version -match '6.1.7601'){
#
# 	From old Windows 2008 script
#

Clear-Host
Pushd
# determine if BitsTransfer is already installed
if ((Get-Module BitsTransfer).installed -eq $true){
	[bool] $WasInstalled = $true
}else{
	[bool] $WasInstalled = $false
}
[string] $menu = @'

	***********************************************************
	Exchange Server 2013 [On Windows 2008 R2] - Features script
	***********************************************************
	
	Please select an option from the list below.
	
	1) Install Client Access Server prerequisites - STEP 1 [Includes 30 & 31]
	2) Install Client Access Server prerequisites - STEP 2
	3) Install Mailbox and or CAS/Mailbox prerequisites - STEP 1 [Includes 30 & 31]
	4) Install Mailbox and or CAS/Mailbox prerequisites - STEP 2
	5) Install Edge Transport Server prerequisites

	10) Launch Windows Update
	11) Check Prerequisites for CAS role
	12) Check Prerequisites for Mailbox role or Cas/Mailbox roles
	13) Check Prerequisites for Edge role

	20) Install - One Off - STEP 1 - Windows Components	
	21) Install - One Off - STEP 2 - .NET 4.5.2
	22) Install - One Off - STEP 3 - Windows Management Framework 4.0
	23) Install - One Off - STEP 4 - Unified Communications Managed API 4.0
	24) Install - One Off - STEP 6 - WinIDFoundation
	25) Install - One Off - STEP 7 - KB2619234 (Hotfix)
	26) Install - One Off - STEP 8 - KB2533623
	27) Install - One Off - Step 9 - Final Cleanup

	30) Set Power Plan to High Performance
	31) Disable Power Management for NICs
	32) Disable SSL 3.0 Support     ** NEW **
	33) Disable RC4 Support     ** NEW **
    	
	98) Restart the Server
	99) Exit

Select an option.. [1-99]?
'@

# Mailbox requirements - Part 1
function check-prereqset1 {
    # .NET 4.5.2
	$val = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full" -Name "Release"
	if($val.Release -lt "379893") {
		write-host ".NET 4.5.2 is " -nonewline 
		write-host "not installed!" -ForegroundColor red
	}
	else {
		write-host ".NET 4.5.2 is " -nonewline
		write-host "installed." -ForegroundColor green
	}

    # Windows Management Framework 4.0 - Check - Needed for CU3+
	$wmf = $PSVersionTable.psversion
	if ($wmf.major -ge "4") {
    	Write-Host "Windows Management Framework 4.0 is " -nonewline 
	    write-host "installed." -ForegroundColor green
	} else {
	write-host "Windows Management Framework 4.0 is " -nonewline 
	write-host "not installed!" -ForegroundColor red
	}

    # Microsoft Unified Communications Managed API 4.0, Core Runtime 64-bit 
    $val = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{41D635FE-4F9D-47F7-8230-9B29D6D42D31}" -Name "DisplayVersion" -erroraction silentlycontinue
    if($val.DisplayVersion -ne "5.0.8308.0"){
        if($val.DisplayVersion -ne "5.0.8132.0"){
            if ((Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{A41CBE7D-949C-41DD-9869-ABBD99D753DA}") -eq $false) {
                write-host "No version of Microsoft Unified Communications Managed API 4.0, Core Runtime 64-bit is " -nonewline 
                write-host "not installed!" -ForegroundColor red
                write-host "Please install the newest UCMA 4.0 from http://www.microsoft.com/en-us/download/details.aspx?id=34992." 
            }else {
            write-host "The Preview version of Microsoft Unified Communications Managed API 4.0, Core Runtime 64-bit is " -nonewline 
            write-host "installed." -ForegroundColor red
            write-host "This is the incorrect version of UCMA. "  -nonewline -ForegroundColor red
            write-host "Please install the newest UCMA 4.0 from http://www.microsoft.com/en-us/download/details.aspx?id=34992." 
            }
        } else {
        write-host "The wrong version of Microsoft Unified Communications Managed API 4.0, Core Runtime 64-bit is " -nonewline
        write-host "installed." -ForegroundColor red
        write-host "This is the incorrect version of UCMA. "  -nonewline -ForegroundColor red 
        write-host "Please install the newest UCMA 4.0 from http://www.microsoft.com/en-us/download/details.aspx?id=34992." 
        }   
    } else {
         write-host "The correct version of Microsoft Unified Communications Managed API 4.0, Core Runtime 64-bit is " -nonewline
         write-host "installed." -ForegroundColor green
    }

     # Windows Identity Foundation
	$hotfix1 = Get-HotFix -id KB974405 -ErrorAction SilentlyContinue
    	if ($hotfix1 -match "KB974405") {
	Write-Host "Windows Identity Foundation is " -nonewline 
	write-host "installed." -ForegroundColor green}
	else {
	Write-Host "Windows Identity Foundation is " -nonewline 
	write-host "not installed!" -ForegroundColor red
	}

     # Association Cookie/GUID used by RPC over HTTP Hotfix
	$hotfix1 = Get-HotFix -id KB2619234 -ErrorAction SilentlyContinue
	if ($hotfix1 -match "KB2619234") {
    	Write-Host "Association Cookie/GUID used by RPC over HTTP Hotfix is " -nonewline 
	write-host "installed." -ForegroundColor green
    } else {
	Write-Host "`nAssociation Cookie/GUID used by RPC over HTTP Hotfix is " -nonewline 
	write-host "not installed!" -ForegroundColor red
	}

     # Insecure library loading could allow remote code execution
	$hotfix1 = Get-HotFix -id KB2533623 -ErrorAction SilentlyContinue
	if ($hotfix1 -match "KB2533623") {
    	Write-Host "Insecure library loading could allow remote code execution is " -nonewline 
	write-host "installed." -ForegroundColor green
    } else {
	Write-Host "Insecure library loading could allow remote code execution is " -nonewline 
	write-host "not installed!" -ForegroundColor red
	}

     # Check for C++ Install and ASP .NEt
	# Old C++ Info
    # $directory = get-item "C:\ProgramData\Package Cache\{5b2d190f-406e-49cf-8fea-1c3fc6777778}" -ErrorAction SilentlyContinue
    $directory = get-item "C:\ProgramData\Package Cache\{15134cb0-b767-4960-a911-f2d16ae54797}" -ErrorAction SilentlyContinue
        # Old C++ Info
    	# if ($directory -match "{5b2d190f-406e-49cf-8fea-1c3fc6777778}") {
        if ($directory -match "{15134cb0-b767-4960-a911-f2d16ae54797}") {
		write-host "Microsoft Visual C++ has " -nonewline
		write-host "not been uninstalled!" -ForegroundColor red
	} else {
		write-host "Microsoft Visual C++ has been " -nonewline
		write-host "uninstalled!" -ForegroundColor green
	}
	write-host "Make sure you registered ASP .Net as well.  See here " -nonewline
	write-host "http://technet.microsoft.com/en-us/library/bb691354(v=exchg.150).aspx" -ForegroundColor yellow
}

# Mailbox requirements - Part 2
function check-prereqset2 {

     # Office 2010 Filter Pack
	if ((Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{95140000-2000-0409-1000-0000000FF1CE}") -eq $false){
	write-host "Office 2010 Filter Pack is " -nonewline 
	write-host "not installed!" -ForegroundColor red
	}
	else {
	write-host "Office 2010 Filter Pack is " -nonewline 
	write-host "installed." -ForegroundColor green
	}

     # Office 2010 SP2 Filter Pack
	$val = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{95140000-2000-0409-1000-0000000FF1CE}" -Name "DisplayVersion" -erroraction silentlycontinue
	if($val.DisplayVersion -ne "14.0.7015.1000"){
	write-host "Office 2010 SP2 Filter Pack is " -nonewline 
	write-host "not installed!" -ForegroundColor red
	}
	else {
	write-host "Office 2010 SP2 Filter Pack is " -nonewline 
	write-host "installed." -ForegroundColor green
	}
}

# Mailbox or CAS/Mailbox Windows Feature requirements - Part 2
function check-prereqset3 {
	$values = @("Desktop-Experience","NET-Framework","NET-HTTP-Activation","RPC-over-HTTP-proxy","RSAT-Clustering","RSAT-Web-Server","WAS-Process-Model","Web-Asp-Net","Web-Basic-Auth","Web-Client-Auth","Web-Digest-Auth","Web-Dir-Browsing","Web-Dyn-Compression","Web-Http-Errors","Web-Http-Logging","Web-Http-Redirect","Web-Http-Tracing","Web-ISAPI-Ext","Web-ISAPI-Filter","Web-Lgcy-Mgmt-Console","Web-Metabase","Web-Mgmt-Console","Web-Mgmt-Service","Web-Net-Ext","Web-Request-Monitor","Web-Server","Web-Stat-Compression","Web-Static-Content","Web-Windows-Auth","Web-WMI")
	foreach ($item in $values){
	$val = get-Windowsfeature $item
	If ($val.installed -eq $true){
	write-host "The Windows Feature"$item" is " -nonewline 
	write-host "installed." -ForegroundColor green
	}else{
	write-host "The Windows Feature"$item" is " -nonewline 
	write-host "not installed!" -ForegroundColor red
	}
	}
	
}

# CAS Windows Feature requirements - SET 1
function check-prereqset4 {
	$values = @("Desktop-Experience","NET-Framework","NET-HTTP-Activation","RPC-over-HTTP-proxy","RSAT-Clustering","RSAT-Web-Server","WAS-Process-Model","Web-Asp-Net","Web-Basic-Auth","Web-Client-Auth","Web-Digest-Auth","Web-Dir-Browsing","Web-Dyn-Compression","Web-Http-Errors","Web-Http-Logging","Web-Http-Redirect","Web-Http-Tracing","Web-ISAPI-Ext","Web-ISAPI-Filter","Web-Lgcy-Mgmt-Console","Web-Metabase","Web-Mgmt-Console","Web-Mgmt-Service","Web-Net-Ext","Web-Request-Monitor","Web-Server","Web-Stat-Compression","Web-Static-Content","Web-Windows-Auth","Web-WMI")
	foreach ($item in $values){
	$val = get-Windowsfeature $item
	If ($val.installed -eq $true){
	write-host "The Windows Feature"$item" is " -nonewline 
	write-host "installed." -ForegroundColor green
	}else{
	write-host "The Windows Feature"$item" is " -nonewline 
	write-host "not installed!" -ForegroundColor red
	}
	}	
}

# Edge Transport requirement check
function check-prereqset5 {
	
     # Windows Feature AD LightWeight Services
	$values = @("ADLDS")
	foreach ($item in $values){
		$val = get-Windowsfeature $item
		If ($val.installed -eq $true){
			write-host "The Windows Feature"$item" is " -nonewline 
			write-host "installed." -ForegroundColor green
		}else{
			write-host "The Windows Feature"$item" is " -nonewline 
			write-host "not installed!" -ForegroundColor red
		}
	}

    # .NET 4.5.2 [for CU7+]
	$val = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full" -Name "Release"
	if($val.Release -lt "379893") {
		write-host ".NET 4.5.2 is " -nonewline 
		write-host "not installed!" -ForegroundColor red
	}
	else {
		write-host ".NET 4.5.2 is " -nonewline
		write-host "installed." -ForegroundColor green
	}

    # Windows Management Framework 4.0 - Check - Needed for CU3+
	$wmf = $PSVersionTable.psversion
	if ($wmf.major -ge "4") {
    	Write-Host "Windows Management Framework 4.0 is " -nonewline 
	    write-host "installed." -ForegroundColor green
	} else {
	write-host "Windows Management Framework 4.0 is " -nonewline 
	write-host "not installed!" -ForegroundColor red
	}
}

# Final Cleanup - C++ and register ASP .NET
function Cleanup-Final {
    # Old C++ from old UCMA
    # [STRING] $targetFolder2 = "C:\ProgramData\Package Cache\{5b2d190f-406e-49cf-8fea-1c3fc6777778}"
    [STRING] $targetFolder2 = "C:\ProgramData\Package Cache\{15134cb0-b767-4960-a911-f2d16ae54797}"
	Set-Location $targetfolder2
	[string]$expression = ".\vcredist_x64.exe /q /uninstall /norestart"
	Invoke-Expression $expression
	c:\Windows\Microsoft.NET\Framework64\v4.0.30319\aspnet_regiis.exe -ir -enable
	iisreset
}

# Install Office filter pack and SP2
function Install-FilterPack{
    # Office filter pack & SP2
   if ((Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{95140000-2000-0409-1000-0000000FF1CE}") -eq $false){
    	GetIt "http://download.microsoft.com/download/0/A/2/0A28BBFA-CBFA-4C03-A739-30CCA5E21659/FilterPack64bit.exe"
    	Set-Location $targetfolder
    	[string]$expression = ".\FilterPack64bit.exe /quiet /norestart /log:$targetfolder\FilterPack64bit.log"
    	Write-Host "File: FilterPack64bit.exe installing..." -NoNewLine
    	Invoke-Expression $expression
    	Start-Sleep -Seconds 2
    	Write-Host "`nOffice filter pack is now installed" -Foregroundcolor Green
    }else{
    	Write-Host "`nOffice filter pack already installed" -Foregroundcolor Green}
     $val = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{95140000-2000-0409-1000-0000000FF1CE}" -Name "DisplayVersion" -erroraction silentlycontinue
     if($val.DisplayVersion -ne "14.0.7015.1000"){
	GetIt "http://download.microsoft.com/download/D/C/A/DCA32A51-6954-4814-8838-422BD3F508F8/filterpacksp2010-kb2687447-fullfile-x64-en-us.exe"
    	Set-Location $targetfolder
    	[string]$expression = ".\filterpacksp2010-kb2687447-fullfile-x64-en-us.exe /quiet /norestart /log:$targetfolder\FilterPack64bit.log"
    	Write-Host "File: filterpacksp2010-kb2687447-fullfile-x64-en-us.exe installing..." -NoNewLine
    	Invoke-Expression $expression
    	Start-Sleep -Seconds 20
	Write-Host "`nOffice filter pack SP2 is now installed" -Foregroundcolor Green
	}
     else {
	Write-Host "`nOffice filter pack SP2 already installed" -Foregroundcolor Green
    	}
} # end Install-FilterPack

# Function - .NET 4.5.2 [for CU7 +]
function Install-DotNET452{
    # .NET 4.5.2
	$val = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full" -Name "Release"
	if ($val.Release -lt "379893") {
    		GetIt "http://download.microsoft.com/download/E/2/1/E21644B5-2DF2-47C2-91BD-63C560427900/NDP452-KB2901907-x86-x64-AllOS-ENU.exe"
	    	Set-Location $targetfolder
    		[string]$expression = ".\NDP452-KB2901907-x86-x64-AllOS-ENU.exe /quiet /norestart /l* $targetfolder\DotNET452.log"
	    	Write-Host "File: NDP452-KB2901907-x86-x64-AllOS-ENU.exe installing..." -NoNewLine
    		Invoke-Expression $expression
    		Start-Sleep -Seconds 20
    		Write-Host "`n.NET 4.5.2 is now installed" -Foregroundcolor Green
	} else {
    		Write-Host "`n.NET 4.5.2 already installed" -Foregroundcolor Green
    }
} # end Install-DotNET452

# Function - Windows Management Framework 4.0 - Install - Needed for CU3+
function Install-WinMgmtFW4{
    # Windows Management Framework 4.0
	$wmf = $PSVersionTable.psversion
	if ($wmf.major -eq "4") {
	    	Write-Host "`nWindows Management Framework 4.0 is already installed" -Foregroundcolor Green
	} else {
	    	GetIt "http://download.microsoft.com/download/3/D/6/3D61D262-8549-4769-A660-230B67E15B25/Windows8-RT-KB2799888-x64.msu"
    		Set-Location $targetfolder
	    	[string]$expression = ".\Windows8-RT-KB2799888-x64.msu /quiet /norestart"
	    	Write-Host "File: Windows8-RT-KB2799888-x64 installing..." -NoNewLine
	    	Invoke-Expression $expression
    		Start-Sleep -Seconds 20
		$wmf = $PSVersionTable.psversion
	
	    	if ($wmf.major -ge "4") {Write-Host "`b`b`b`b`b`b`b`b`b`b`b`b`binstalled!   " -Foregroundcolor Green} else {Write-Host "`b`b`b`b`b`b`b`b`b`b`b`b`bFAILED!" -Foregroundcolor Red}
    }
} # end Install-WinMgmtFW4

# Install Microsoft Unified Communications Managed API 4.0, Core Runtime 64-bit
	function Install-NewWinUniComm4{
		GetIt "http://download.microsoft.com/download/2/C/4/2C47A5C1-A1F3-4843-B9FE-84C0032C61EC/UcmaRuntimeSetup.exe"
 	   	Set-Location $targetfolder
   	 	[string]$expression = ".\UcmaRuntimeSetup.exe /quiet /norestart /l* $targetfolder\WinUniComm4.log"
    		Write-Host "File: UcmaRuntimeSetup.exe installing..." -NoNewLine
    		Invoke-Expression $expression
    		Start-Sleep -Seconds 20
		$val = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{41D635FE-4F9D-47F7-8230-9B29D6D42D31}" -Name "DisplayVersion" -erroraction silentlycontinue
		if($val.DisplayVersion -ne "5.0.8308.0"){
		Write-Host "`nMicrosoft Unified Communications Managed API 4.0 is now installed" -Foregroundcolor Green
		}
        } # end Install-NewWinUniComm4

# Uninstall Microsoft Unified Communications Managed API 4.0, Core Runtime 64-bit
	function UnInstall-WinUniComm4{
		GetIt "http://download.microsoft.com/download/2/C/4/2C47A5C1-A1F3-4843-B9FE-84C0032C61EC/UcmaRuntimeSetup.exe"
 	   	Set-Location $targetfolder
  	  	[string]$expression = ".\UcmaRuntimeSetup.exe /quiet /norestart /l* $targetfolder\WinUniComm4.log"
  	  	Write-Host "File: UcmaRuntimeSetup.exe uninstalling..." -NoNewLine
   	 	Invoke-Expression $expression
  	  	Start-Sleep -Seconds 20
		if ((Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{41D635FE-4F9D-47F7-8230-9B29D6D42D31}") -eq $false){
			write-host "Microsoft Unified Communications Managed API 4.0, Core Runtime 64-bit is " -nonewline 
			write-host "been uninstalled!" -ForegroundColor red
		}
	} # end Uninstall-WinUniComm4

# New Function - Microsoft Unified Communications Managed API 4.0, Core Runtime 64-bit --> COMPLETE - needed for CAS and MBX roles
	function Install-WinUniComm4{
  # Microsoft Unified Communications Managed API 4.0, Core Runtime 64-bit
	$val = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{41D635FE-4F9D-47F7-8230-9B29D6D42D31}" -Name "DisplayVersion" -erroraction silentlycontinue
	  if($val.DisplayVersion -ne "5.0.8308.0"){
	   if($val.DisplayVersion -ne "5.0.8132.0"){
		if ((Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{A41CBE7D-949C-41DD-9869-ABBD99D753DA}") -eq $false) {
		    	Write-Host "`nMicrosoft Unified Communications Managed API 4.0 is not installed.  Downloading and installing now."
			Install-NewWinUniComm4
		} else {
	    	Write-Host "`nAn old version of Microsoft Unified Communications Managed API 4.0 is installed."
		UnInstall-WinUniComm4
		Write-Host "`nMicrosoft Unified Communications Managed API 4.0 has been uninstalled.  Downloading and installing now."
		Install-NewWinUniComm4
		}
	   } else {
	   Write-Host "`nThe Preview version of Microsoft Unified Communications Managed API 4.0 is installed."
	   UnInstall-WinUniComm4
	   Write-Host "`nMicrosoft Unified Communications Managed API 4.0 has been uninstalled.  Downloading and installing now."
	   Install-NewWinUniComm4
	   }
	  } else {
  	  write-host "The correct version of Microsoft Unified Communications Managed API 4.0, Core Runtime 64-bit is " -nonewline
	  write-host "installed." -ForegroundColor green
	  }
    } # end Install-WinUniComm4

# New Function - Windows Identity Foundation - needed for CAS and MBX roles
function Install-WinIDFoundation{
    # Windows Identity Foundation
	$hotfix1 = Get-HotFix -id KB974405 -ErrorAction SilentlyContinue
    	if ($hotfix1 -match "KB974405") {
	Write-Host "`nWindows Identity Foundation is already installed" -Foregroundcolor Green
	}else{
    	GetIt "http://Download.microsoft.com/download/D/7/2/D72FD747-69B6-40B7-875B-C2B40A6B2BDD/Windows6.1-KB974405-x64.msu"
    	Set-Location $targetfolder
    	[string]$expression = ".\Windows6.1-KB974405-x64.msu /quiet /norestart"
    	Write-Host "File: Windows6.1-KB974405-x64.msu installing..." -NoNewLine
    	Invoke-Expression $expression
    	Start-Sleep -Seconds 20
	Write-Host "`nWindows Identity Foundation is now installed" -Foregroundcolor Green	
    }
} # end Install-WinIDFoundation

# New Function - Association Cookie/GUID used by RPC over HTTP Hotfix - needed for CAS and MBX roles
function Install-hotfix1{
    # Association Cookie/GUID used by RPC over HTTP Hotfix
	$hotfix1 = Get-HotFix -id KB2619234 -ErrorAction SilentlyContinue
    if ($hotfix1 -match "KB2619234") {
    	Write-Host "`nAssociation Cookie/GUID used by RPC over HTTP Hotfix is already installed" -Foregroundcolor Green
	}else{
    	GetIt "http://hotfixv4.microsoft.com/Windows 7/Windows Server2008 R2 SP1/sp2/Fix381274/7600/free/437879_intl_x64_zip.exe"
	write-host "Click Continue on the Hotfix self-extractor and type in c:\install for the directory.  Then at the PowerShell prompt type in c:\install as well."
	Start-Sleep -Seconds 5
#	UnZipIt "437879_intl_x64_zip.exe" "Windows6.1-KB2619234-v2-x64.msu"
    	Set-Location $targetfolder
    	[string]$expression = ".\437879_intl_x64_zip.exe"
	Invoke-Expression $expression
	$hotfixdir = Read-Host 'Enter the target directory you used for the hotfix extraction.'
    	Set-Location $hotfixdir
    	[string]$expression = ".\Windows6.1-KB2619234-v2-x64.msu /quiet /norestart"
    	Write-Host "File: Windows6.1-KB2619234-v2-x64.msu installing..." -NoNewLine
    	Invoke-Expression $expression
    	Start-Sleep -Seconds 20
    	Write-Host "`nAssociation Cookie/GUID used by RPC over HTTP Hotfix is now installed" -Foregroundcolor Green
    }
} # end Install-hotfix1

# New Function - Insecure library loading could allow remote code execution - needed for CAS and MBX roles
function Install-KB2533623{
    # Insecure library loading could allow remote code execution
	$hotfix1 = Get-HotFix -id KB2533623 -ErrorAction SilentlyContinue
    if ($hotfix1 -match "KB2533623") {
    	Write-Host "`nInsecure library loading could allow remote code execution is already installed" -Foregroundcolor Green
	}else{
    	GetIt "http://download.microsoft.com/download/0/B/D/0BD4C49B-92F8-4BD3-A835-8E8A8CDA2A30/Windows6.1-KB2533623-x64.msu"
    	Set-Location $targetfolder
#    	[string]$expression = ".\Windows6.1-KB2533623-x64.msu /quiet /norestart"
    	[string]$expression = ".\Windows6.1-KB2533623-x64.msu"
    	Write-Host "File: Windows6.1-KB2533623-x64.msu installing..." -NoNewLine
    	Invoke-Expression $expression
    	Start-Sleep -Seconds 20
    	Write-Host "`nInsecure library loading could allow remote code execution is now installed" -Foregroundcolor Green
    }
} # end Install-KB2533623

# Keep this one
function Install-PDFFilterPack{
    # adobe ifilter
    if ((Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{5EA12CF3-8162-47F6-ACAF-45AD03EFB08F}") -eq $false){
    	GetIt "http://download.adobe.com/pub/adobe/acrobat/win/9.x/PDFiFilter64installer.zip"
    	UnZipIt "PDFiFilter64installer.zip" "PDFFilter64installer.msi"
    	Set-Location $targetfolder
    	[string]$expression = ".\PDFFilter64installer.msi /quiet /norestart /l* $targetfolder\PDFiFilter64Installer.log"
    	Write-Host "File: PDFFilter64installer.msi installing..." -NoNewLine
    	Invoke-Expression $expression
    	Start-Sleep -Seconds 20
    	if ((Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{5EA12CF3-8162-47F6-ACAF-45AD03EFB08F}") -eq $true){Write-Host "`b`b`b`b`b`b`b`b`b`b`b`b`binstalled!   " -Foregroundcolor Green}else{Write-Host "`b`b`b`b`b`b`b`b`b`b`b`b`bFAILED!" -Foregroundcolor Red}
    }else{
    	Write-Host "`nPDF filter pack already installed" -Foregroundcolor Green
    }
} # end Install-PDFFilterPack

# Keep this one
function Configure-PDFFilterPack	{
	# Adobe iFilter Directory Path
	$iFilterDirName = "C:\Program Files\Adobe\Adobe PDF IFilter 9 for 64-bit platforms\bin"
	
	# Get the original path environment variable
	$original = (Get-ItemProperty "HKLM:SYSTEM\CurrentControlSet\Control\Session Manager\Environment" Path).Path
	
	# Add the ifilter path
	Set-ItemProperty "HKLM:SYSTEM\CurrentControlSet\Control\Session Manager\Environment" Path -value ( $original + ";" + $iFilterDirName )
	$CLSIDKey = "HKLM:\SOFTWARE\Microsoft\ExchangeServer\V14\MSSearch\CLSID"
	$FiltersKey = "HKLM:\SOFTWARE\Microsoft\ExchangeServer\v14\MSSearch\Filters"
	
	# Filter DLL Locations
	$pdfFilterLocation = "PDFFilter.dll"
	
	# Filter GUIDs
	$PDFGuid = "{E8978DA6-047F-4E3D-9C78-CDBE46041603}"
	
	# Create CLSIDs
	Write-Host "Creating CLSIDs..."
	New-Item -Path $CLSIDKey -Name $PDFGuid -Value $pdfFilterLocation -Type String
	
	# Set Threading model
	Write-Host "Setting threading model..."
	New-ItemProperty -Path "$CLSIDKey\$PDFGuid" -Name "ThreadingModel" -Value "Both" -Type String
	
	# Set Flags
	Write-Host "Setting Flags..."
	New-ItemProperty -Path "$CLSIDKey\$PDFGuid" -Name "Flags" -Value "1" -Type Dword
	
	# Create Filter Entries
	Write-Host "Creating Filter Entries..."
	
	# These are the entries for commonly exchange formats
	New-Item -Path $FiltersKey -Name ".pdf" -Value $PDFGuid -Type String
	Write-Host "Registry subkeys created. If this server holds the Hub Transport Role, the Network Service will need to have read access to the following registry keys:`n$CLSIDKey\$PDFGuid`n$FiltersKey\.pdf" -ForegroundColor Green
} # end function Configure-PDFFilterPack

# Keep this one --> Needed for CAS role only servers
function Set-RunOnce{
	# Sets the NetTCPPortSharing service for automatic startup before the first reboot
	# by using the old RunOnce registry key (because the service doesn't yet exist, or we could
	# use 'Set-Service')
	$hostname = (hostname)
	$RunOnceCommand1 = "sc \\$hostname config NetTcpPortSharing start= auto"
	if (Get-ItemProperty -Name "NetTCPPortSharing" -path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce' -ErrorAction SilentlyContinue) { 
	  Write-host "Registry key HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce\NetTCPPortSharing already exists." -ForegroundColor yellow
		Set-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" -Name "NetTCPPortSharing" -Value $RunOnceCommand1 | Out-Null
	} else { 
	  New-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" -Name "NetTCPPortSharing" -Value $RunOnceCommand1 -PropertyType "String" | Out-Null
	} 
} # end Set-RunOnce	

# Keep this one
function GetIt ([string]$sourcefile)	{
	if ($HasInternetAccess){
		# check if BitsTransfer is installed
		if ((Get-Module BitsTransfer) -eq $null){
			Write-Host "BitsTransfer: Installing..." -NoNewLine
			Import-Module BitsTransfer	
			Write-Host "`b`b`b`b`b`b`b`b`b`b`b`b`binstalled!   " -ForegroundColor Green
		}
		[string] $targetfile = $sourcefile.Substring($sourcefile.LastIndexOf("/") + 1) 
		if (Test-Path $targetfolder){
			Write-Host "Folder: $targetfolder exists."
		} else{
			Write-Host "Folder: $targetfolder does not exist, creating..." -NoNewline
			New-Item $targetfolder -type Directory | Out-Null
			Write-Host "`b`b`b`b`b`b`b`b`b`b`bcreated!   " -ForegroundColor Green
		}
		if (Test-Path "$targetfolder\$targetfile"){
			Write-Host "File: $targetfile exists."
		}else{	
			Write-Host "File: $targetfile does not exist, downloading..." -NoNewLine
			Start-BitsTransfer -Source "$SourceFile" -Destination "$targetfolder\$targetfile"
			Write-Host "`b`b`b`b`b`b`b`b`b`b`b`b`b`bdownloaded!   " -ForegroundColor Green
		}
	}else{
		Write-Host "Internet Access not detected. Please resolve and try again." -foregroundcolor red
	}
} # end GetIt

# Keep this one
function UnZipIt ([string]$source, [string]$target){
	if (Test-Path "$targetfolder\$target"){
		Write-Host "File: $target exists."
	}else{
		Write-Host "File: $target doesn't exist, unzipping..." -NoNewLine
		$sh = new-object -com shell.application
		$zipfolder = $sh.namespace("$targetfolder\$source") 
		$item = $zipfolder.parsename("$target")      
		$targetfolder2 = $sh.namespace("$targetfolder")       
		Set-Location $targetfolder
		$targetfolder2.copyhere($item)
		Write-Host "`b`b`b`b`b`b`b`b`b`b`b`bunzipped!   " -ForegroundColor Green
		Remove-Item $source
	}
} # end UnZipIt

# Keep this one
function Remove-IPv6	{
	$error.clear()
	Write-Host "TCP/IP v6......................................................[" -NoNewLine
	Write-Host "removing" -ForegroundColor yellow -NoNewLine
	Write-Host "]" -NoNewLine
	Set-ItemProperty -path HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters -name DisabledComponents -value 0xffffffff -type dword
	if ($error){
		Write-Host "`b`b`b`b`b`b`b`bfailed!" -ForegroundColor red -NoNewLine
	}else{
		Write-Host "`b`b`b`b`b`b`b`b`bdone!" -ForegroundColor green -NoNewLine
	}
	Write-Host "]    "
	$global:boolRebootRequired = $true
} # end function Remove-IPv6

# Keep this one
function Get-ModuleStatus { 
	param	(
		[parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Mandatory=$true, HelpMessage="No module name specified!")] 
		[string]$name
	)
	if(!(Get-Module -name "$name")) { 
		if(Get-Module -ListAvailable | ? {$_.name -eq "$name"}) { 
			Import-Module -Name "$name" 
			# module was imported
			return $true
		} else {
			# module was not available
			return $false
		}
	}else {
		# module was already imported
		# Write-Host "$name module already imported"
		return $true
	}
} # end function Get-ModuleStatus

# Keep this one
function New-FileDownload {
	param (
		[parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Mandatory=$true, HelpMessage="No source file specified")] 
		[string]$SourceFile,
    [parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Mandatory=$false, HelpMessage="No destination folder specified")] 
    [string]$DestFolder,
    [parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Mandatory=$false, HelpMessage="No destination file specified")] 
    [string]$DestFile
	)
	# I should clean up the display text to be consistent with other functions
	$error.clear()
	if (!($DestFolder)){$DestFolder = $TargetFolder}
	Get-ModuleStatus -name BitsTransfer
	if (!($DestFile)){[string] $DestFile = $SourceFile.Substring($SourceFile.LastIndexOf("/") + 1)}
	if (Test-Path $DestFolder){
		Write-Host "Folder: `"$DestFolder`" exists."
	} else{
		Write-Host "Folder: `"$DestFolder`" does not exist, creating..." -NoNewline
		New-Item $DestFolder -type Directory
		Write-Host "Done! " -ForegroundColor Green
	}
	if (Test-Path "$DestFolder\$DestFile"){
		Write-Host "File: $DestFile exists."
	}else{
		if ($HasInternetAccess){
			Write-Host "File: $DestFile does not exist, downloading..." -NoNewLine
			Start-BitsTransfer -Source "$SourceFile" -Destination "$DestFolder\$DestFile"
			Write-Host "Done! " -ForegroundColor Green
		}else{
			Write-Host "Internet access not detected. Please resolve and try again." -ForegroundColor red
		}
	}
} # end function New-FileDownload

function CheckPowerPlan {
	$HighPerf = powercfg -l | %{if($_.contains("High performance")) {$_.split()[3]}}
	$CurrPlan = $(powercfg -getactivescheme).split()[3]
	if ($CurrPlan -eq $HighPerf) {
		write-host " ";write-host "The power plan now is set to " -nonewline;write-host "High Performance." -foregroundcolor green;write-host " "
	}
}

function highperformance {
	$HighPerf = powercfg -l | %{if($_.contains("High performance")) {$_.split()[3]}}
	$CurrPlan = $(powercfg -getactivescheme).split()[3]
	if ($CurrPlan -ne $HighPerf) {
		powercfg -setactive $HighPerf
		CheckPowerPlan
	} else {
		if ($CurrPlan -eq $HighPerf) {
			write-host " ";write-host "The power plan is already set to " -nonewline;write-host "High Performance." -foregroundcolor green;write-host " "
		}
	}
}

function PowerMgmt {
	$NICs = Get-WmiObject -Class Win32_NetworkAdapter|Where-Object{$_.PNPDeviceID -notlike "ROOT\*" -and $_.Manufacturer -ne "Microsoft" -and $_.ConfigManagerErrorCode -eq 0 -and $_.ConfigManagerErrorCode -ne 22} 
	Foreach($NIC in $NICs) {
		$NICName = $NIC.Name
		$DeviceID = $NIC.DeviceID
		If([Int32]$DeviceID -lt 10) {
			$DeviceNumber = "000"+$DeviceID 
		} Else {
			$DeviceNumber = "00"+$DeviceID
		}
		$KeyPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002bE10318}\$DeviceNumber"
  
		If(Test-Path -Path $KeyPath) {
			$PnPCapabilities = (Get-ItemProperty -Path $KeyPath).PnPCapabilities
			If($PnPCapabilities -eq 0){Set-ItemProperty -Path $KeyPath -Name "PnPCapabilities" -Value 24 | Out-Null
				write-host " " ;write-host "Changed the NIC Power Management settings.";write-host " ";write-host "A reboot is REQUIRED!" -foregroundcolor red;write-host " ";$NICRebootRequired = $true}
			If($PnPCapabilities -eq $null){Set-ItemProperty -Path $KeyPath -Name "PnPCapabilities" -Value 24 | Out-Null
				write-host " " ;write-host "Changed the NIC Power Management settings.";write-host " ";write-host "A reboot is REQUIRED!" -foregroundcolor red;write-host " ";$NICRebootRequired = $true}
			If($PnPCapabilities -eq 24) {write-host " ";write-host "Power Management has already been " -NoNewline;write-host "disabled" -ForegroundColor Green;write-host " "}
   		 } 
 	 } 
 }

function DisableRC4 {
	# Define Registry keys to look for
	$base = Get-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\" -erroraction silentlycontinue
	$val1 = Get-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 128/128\" -erroraction silentlycontinue
	$val2 = Get-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 40/128\" -erroraction silentlycontinue
	$val3 = Get-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 56/128\" -erroraction silentlycontinue
	
	# Define Values to add
	$registryBase = "Ciphers"
	$registryPath1 = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 128/128\"
	$registryPath2 = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 40/128\"
	$registryPath3 = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 56/128\"
	$Name = "Enabled"
	$value = "0"
	$ssl = 0
	$checkval1 = Get-Itemproperty -Path "$registrypath1" -name $name -erroraction silentlycontinue
	$checkval2 = Get-Itemproperty -Path "$registrypath2" -name $name -erroraction silentlycontinue
	$checkval3 = Get-Itemproperty -Path "$registrypath3" -name $name -erroraction silentlycontinue
    
# Formatting for output
	write-host " "

# Add missing registry keys as needed
	If ($base -eq $null) {
		$key = (get-item HKLM:\).OpenSubKey("SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL", $true)
		$key.CreateSubKey('Ciphers')
		$key.Close()
	} else {
		write-host "The " -nonewline;write-host "Ciphers" -ForegroundColor green -NoNewline;write-host " Registry key already exists."
	}

	If ($val1 -eq $null) {
		$key = (get-item HKLM:\).OpenSubKey("SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers", $true)
		$key.CreateSubKey('RC4 128/128')
		$key.Close()
	} else {
		write-host "The " -nonewline;write-host "Ciphers\RC4 128/128" -ForegroundColor green -NoNewline;write-host " Registry key already exists."
	}

	If ($val2 -eq $null) {
		$key = (get-item HKLM:\).OpenSubKey("SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers", $true)
		$key.CreateSubKey('RC4 40/128')
		$key.Close()
		New-ItemProperty -Path $registryPath2 -Name $name -Value $value
	} else {
		write-host "The " -nonewline;write-host "Ciphers\RC4 40/128" -ForegroundColor green -NoNewline;write-host " Registry key already exists."
	}

	If ($val3 -eq $null) {
		$key = (get-item HKLM:\).OpenSubKey("SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers", $true)
		$key.CreateSubKey('RC4 56/128')
		$key.Close()
	} else {
		write-host "The " -nonewline;write-host "Ciphers\RC4 56/128" -ForegroundColor green -NoNewline;write-host " Registry key already exists."
	}
	
# Add the enabled value to disable RC4 Encryption
	If ($checkval1.enabled -ne "0") {
		try {
			New-ItemProperty -Path $registryPath1 -Name $name -Value $value -force;$ssl++
		} catch {
			$SSL--
		} 
	} else {
		write-host "The registry value " -nonewline;write-host "Enabled" -ForegroundColor green -NoNewline;write-host " exists under the RC4 128/128 Registry Key.";$ssl++
	}
	If ($checkval2.enabled -ne "0") {
		write-host $checkval2
		try {
			New-ItemProperty -Path $registryPath2 -Name $name -Value $value -force;$ssl++
		} catch {
			$SSL--
		} 
	} else {
		write-host "The registry value " -nonewline;write-host "Enabled" -ForegroundColor green -NoNewline;write-host " exists under the RC4 40/128 Registry Key.";$ssl++
	}
	If ($checkval3.enabled -ne "0") {
		try {
			New-ItemProperty -Path $registryPath3 -Name $name -Value $value -force;$ssl++
		} catch {
			$SSL--
		} 
	} else {
		write-host "The registry value " -nonewline;write-host "Enabled" -ForegroundColor green -NoNewline;write-host " exists under the RC4 56/128 Registry Key.";$ssl++
	}

# SSL Check totals
	If ($ssl -eq "3") {
		write-host " ";write-host "RC4 " -ForegroundColor yellow -NoNewline;write-host "is completely disabled on this server.";write-host " "
	} 
	If ($ssl -lt "3"){
		write-host " ";write-host "RC4 " -ForegroundColor yellow -NoNewline;write-host "only has $ssl part(s) of 3 disabled.  Please check the registry to manually to add these values";write-host " "
	}
} # End of Disable RC4 function

function DisableSSL3 {
    $TestPath1 = Get-Item -Path "HKLM:\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0" -erroraction silentlycontinue
    $TestPath2 = Get-Item -Path "HKLM:\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Server" -erroraction silentlycontinue
    $registrypath = "HKLM:\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Server"
    $Name = "Enabled"
	$value = "0"
    $checkval1 = Get-Itemproperty -Path "$registrypath" -name $name -erroraction silentlycontinue

# Check for SSL 3.0 Reg Key
	If ($TestPath1 -eq $null) {
		$key = (get-item HKLM:\).OpenSubKey("System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols", $true)
		$key.CreateSubKey('SSL 3.0')
		$key.Close()
	} else {
		write-host "The " -nonewline;write-host "SSL 3.0" -ForegroundColor green -NoNewline;write-host " Registry key already exists."
	}

# Check for SSL 3.0\Server Reg Key
	If ($TestPath2 -eq $null) {
		$key = (get-item HKLM:\).OpenSubKey("System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0", $true)
		$key.CreateSubKey('Server')
		$key.Close()
	} else {
		write-host "The " -nonewline;write-host "SSL 3.0\Servers" -ForegroundColor green -NoNewline;write-host " Registry key already exists."
	}

# Add the enabled value to disable SSL 3.0 Support
	If ($checkval1.enabled -ne "0") {
		try {
			New-ItemProperty -Path $registryPath -Name $name -Value $value -force;$ssl++
		} catch {
			$SSL--
		} 
	} else {
		write-host "The registry value " -nonewline;write-host "Enabled" -ForegroundColor green -NoNewline;write-host " exists under the SSL 3.0\Server Registry Key."
	}
} # End of Disable SSL 3.0 function

Do { 	
	if ($NICRebootRequired -eq $true){Write-Host "`t`t`t`t`t`t`t`t`t`n`t`t`t`tREBOOT REQUIRED!`t`t`t`n`t`t`t`t`t`t`t`t`t`n" -backgroundcolor red -foregroundcolor black}
	if ($RebootRequired -eq $true){Write-Host "`t`t`t`t`t`t`t`t`t`n`t`t`t`tREBOOT REQUIRED!`t`t`t`n`t`t`t`t`t`t`t`t`t`n`t`tDO NOT INSTALL EXCHANGE BEFORE REBOOTING!`t`t`n`t`t`t`t`t`t`t`t`t" -backgroundcolor red -foregroundcolor black}
	if ($opt -ne "None") {Write-Host "Last command: "$opt -foregroundcolor Yellow}	
	$opt = Read-Host $menu

	switch ($opt)    {
		1 {# 	Prep CAS - Step 1
			Get-ModuleStatus -name ServerManager
			highperformance
			PowerMgmt
			Add-WindowsFeature Desktop-Experience, NET-Framework, NET-HTTP-Activation, RPC-over-HTTP-proxy, RSAT-Clustering, RSAT-Web-Server, WAS-Process-Model, Web-Asp-Net, Web-Basic-Auth, Web-Client-Auth, Web-Digest-Auth, Web-Dir-Browsing, Web-Dyn-Compression, Web-Http-Errors, Web-Http-Logging, Web-Http-Redirect, Web-Http-Tracing, Web-ISAPI-Ext, Web-ISAPI-Filter, Web-Lgcy-Mgmt-Console, Web-Metabase, Web-Mgmt-Console, Web-Mgmt-Service, Web-Net-Ext, Web-Request-Monitor, Web-Server, Web-Stat-Compression, Web-Static-Content, Web-Windows-Auth, Web-WMI
			$RebootRequired = $true
		}
		2 {# 	Prep CAS - Step 2
			Get-ModuleStatus -name ServerManager
			Set-RunOnce
			Install-DotNET452
			Install-WinMgmtFW4
			Install-WinUniComm4
			Install-WinIDFoundation
			Install-hotfix1
			Install-KB2533623
			Cleanup-Final
			$RebootRequired = $true
		}
		3 {# 	Prep Mailbox or CAS/Mailbox - Step 1
			Get-ModuleStatus -name ServerManager
			highperformance
			PowerMgmt
			Add-WindowsFeature Desktop-Experience, NET-Framework, NET-HTTP-Activation, RPC-over-HTTP-proxy, RSAT-Clustering, RSAT-Web-Server, WAS-Process-Model, Web-Asp-Net, Web-Basic-Auth, Web-Client-Auth, Web-Digest-Auth, Web-Dir-Browsing, Web-Dyn-Compression, Web-Http-Errors, Web-Http-Logging, Web-Http-Redirect, Web-Http-Tracing, Web-ISAPI-Ext, Web-ISAPI-Filter, Web-Lgcy-Mgmt-Console, Web-Metabase, Web-Mgmt-Console, Web-Mgmt-Service, Web-Net-Ext, Web-Request-Monitor, Web-Server, Web-Stat-Compression, Web-Static-Content, Web-Windows-Auth, Web-WMI
			$RebootRequired = $true
		}
		4 {# 	Prep Mailbox or CAS/Mailbox - Step 2
			Get-ModuleStatus -name ServerManager
			Set-RunOnce
			Install-DotNET452
			Install-WinUniComm4
			Install-FilterPack
			Install-WinIDFoundation
			Install-hotfix1
			Install-WinMgmtFW4
	    		Start-Sleep -Seconds 5
			Install-KB2533623
			Cleanup-Final
			$RebootRequired = $true
		}
	  	5 {#	Prep Exchange Transport
			Import-Module ServerManager
			Add-WindowsFeature NET-Framework, ADLDS
			Install-DotNET452
			Install-WinMgmtFW4
		}
	  	10 {#	Windows Update
			Invoke-Expression "$env:windir\system32\wuapp.exe startmenu"
		}
		11 {# 	CAS Requirement Check
			check-prereqset1
			check-prereqset4
		}
		12 {#	Mailbox or CAS/Mailbox Requirement Check
			check-prereqset1
			check-prereqset2
			check-prereqset3
		}
		13 {#	Edge Transport Requirement Check
			check-prereqset5
		}
		20 {#	Step 1 - One Off - Windows Components
			Get-ModuleStatus -name ServerManager
			Set-RunOnce
			Add-WindowsFeature Desktop-Experience, NET-Framework, NET-HTTP-Activation, RPC-over-HTTP-proxy, RSAT-Clustering, RSAT-Web-Server, WAS-Process-Model, Web-Asp-Net, Web-Basic-Auth, Web-Client-Auth, Web-Digest-Auth, Web-Dir-Browsing, Web-Dyn-Compression, Web-Http-Errors, Web-Http-Logging, Web-Http-Redirect, Web-Http-Tracing, Web-ISAPI-Ext, Web-ISAPI-Filter, Web-Lgcy-Mgmt-Console, Web-Metabase, Web-Mgmt-Console, Web-Mgmt-Service, Web-Net-Ext, Web-Request-Monitor, Web-Server, Web-Stat-Compression, Web-Static-Content, Web-Windows-Auth, Web-WMI
		}
		21 {#	Install - One Off - .NET 4.5.2
			Install-DotNET452
		}
		22 {#	Install - One Off - Windows Management Framework 4.0
			Install-WinMgmtFW4
		}
		23 {#	Install - One Off - Unified Communications Managed API 4.0
			Install-WinUniComm4
		}
		24 {#	Install - One Off - WinIDFoundation
			Install-WinIDFoundation
		}
		25 {#	Install - One Off - KB2619234 (Hotfix)
			Get-ModuleStatus -name ServerManager
			Set-RunOnce
			Install-hotfix1
		}
		26 {#	Install - One Off - KB2533623
			Install-KB2533623
		}
		27 {#	Final Cleanup and reboot
			Get-ModuleStatus -name ServerManager
			Cleanup-Final
		}
		30 { # Set power plan to High Performance as per Microsoft
			highperformance
		}
		31 { # Disable Power Management for NICs.		
			PowerMgmt
		}
		32 { # Disable SSL 3.0 Support
			DisableSSL3
		}
		33 { # Disable RC4 Support		
			DisableRC4
		}
		98 {#	Exit and restart
			Stop-Transcript
			Restart-Computer 
		}
		99 {#	Exit
			if (($WasInstalled -eq $false) -and (Get-Module BitsTransfer)){
				Write-Host "BitsTransfer: Removing..." -NoNewLine
				Remove-Module BitsTransfer
				Write-Host "`b`b`b`b`b`b`b`b`b`b`bremoved!   " -ForegroundColor Green
			}
			popd
			Write-Host "Exiting..."
			Stop-Transcript
		}
		default {Write-Host "You haven't selected any of the available options. "}
	}
} while ($opt -ne 99)

#
#	From old Windows 2012 script
#

# *******************************************************
# *	This section is for the Windows 2012 / 2012 R2 *
# *******************************************************
}else{
if ((Get-WMIObject win32_OperatingSystem).Version -notmatch '6.2'){
	if ((Get-WMIObject win32_OperatingSystem).Version -notmatch '6.3'){
	Write-Host "`nThis script requires a version of Windows Server 2008 or 2012, which this is not. Exiting...`n" -ForegroundColor Red
	Exit
	}
}
Clear-Host
Pushd
# determine if BitsTransfer is already installed
if ((Get-Module BitsTransfer).installed -eq $true){
	[bool] $WasInstalled = $true
}else{
	[bool] $WasInstalled = $false
}
[string] $menu = @'

	******************************************************************
	Exchange Server 2013 [On Windows 2012 / 2012 R2] - Features script
	******************************************************************
	
	Please select an option from the list below.
	
	1) Install Client Access Server prerequisites - Step 1 [Includes 30 & 31]
	2) Install Client Access Server prerequisites - Step 2
	3) Install Mailbox and or CAS/Mailbox prerequisites - Step 1 [Includes 30 & 31]
	4) Install Mailbox and or CAS/Mailbox prerequisites - Step 2
	5) Install Edge Transport Server prerequisites

	10) Launch Windows Update
	11) Check Prerequisites for CAS role
	12) Check Prerequisites for Mailbox role or Cas/Mailbox roles
	13) Check Prerequisites for Edge role

	20) Install - One Off - STEP 1 - Windows Components - CAS role
	21) Install - One Off - STEP 1 - Windows Components - Mailbox (or CAS/Mailbox) Role	
	22) Install - One Off - STEP 4 - Unified Communications Managed API 4.0
	23) Install - One Off - Step 9 - Final Cleanup - Mailbox or CAS/Mailbox

	30) Set Power Plan to High Performance
	31) Disable Power Management for NICs
	32) Disable SSL 3.0 Support     ** NEW **
	33) Disable RC4 Support     ** NEW **
    	
	98) Restart the Server
	99) Exit

Select an option.. [1-99]?
'@


# Mailbox requirements - Part 1
function check-prereqset1 {

    # .NET 4.5.2
	$val = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full" -Name "Release"
	if($val.Release -lt "379893") {
		write-host ".NET 4.5.2 is " -nonewline 
		write-host "not installed!" -ForegroundColor red
	}
	else {
		write-host ".NET 4.5.2 is " -nonewline
		write-host "installed." -ForegroundColor green
	}

    # Windows Management Framework 4.0 - Check - Needed for CU3+
	$wmf = $PSVersionTable.psversion
	if ($wmf.major -ge "4") {
    	Write-Host "Windows Management Framework 4.0 is " -nonewline 
	    write-host "installed." -ForegroundColor green
	} else {
	write-host "Windows Management Framework 4.0 is " -nonewline 
	write-host "not installed!" -ForegroundColor red
	}

     # Microsoft Unified Communications Managed API 4.0, Core Runtime 64-bit 
         $val = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{41D635FE-4F9D-47F7-8230-9B29D6D42D31}" -Name "DisplayVersion" -erroraction silentlycontinue
         if($val.DisplayVersion -ne "5.0.8308.0"){
            if($val.DisplayVersion -ne "5.0.8132.0"){
         	if ((Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{A41CBE7D-949C-41DD-9869-ABBD99D753DA}") -eq $false) {
         		write-host "No version of Microsoft Unified Communications Managed API 4.0, Core Runtime 64-bit is " -nonewline 
         		write-host "not installed!" -ForegroundColor red
         		write-host "Please install the newest UCMA 4.0 from http://www.microsoft.com/en-us/download/details.aspx?id=34992." 
         	}else {
         	write-host "The Preview version of Microsoft Unified Communications Managed API 4.0, Core Runtime 64-bit is " -nonewline 
         	write-host "installed." -ForegroundColor red
                  	write-host "This is the incorrect version of UCMA. "  -nonewline -ForegroundColor red
                    	write-host "Please install the newest UCMA 4.0 from http://www.microsoft.com/en-us/download/details.aspx?id=34992." 
                  	}
            } else {
            write-host "The wrong version of Microsoft Unified Communications Managed API 4.0, Core Runtime 64-bit is " -nonewline
            write-host "installed." -ForegroundColor red
            write-host "This is the incorrect version of UCMA. "  -nonewline -ForegroundColor red 
            write-host "Please install the newest UCMA 4.0 from http://www.microsoft.com/en-us/download/details.aspx?id=34992." 
            }   
         } else {
         write-host "The correct version of Microsoft Unified Communications Managed API 4.0, Core Runtime 64-bit is " -nonewline
         write-host "installed." -ForegroundColor green
         }

     # Check for C++ Install and ASP .NEt
        # Old C++
        #$directory = get-item "C:\ProgramData\Package Cache\{5b2d190f-406e-49cf-8fea-1c3fc6777778}" -ErrorAction SilentlyContinue
        $directory = get-item "C:\ProgramData\Package Cache\{15134cb0-b767-4960-a911-f2d16ae54797}" -ErrorAction SilentlyContinue
        # Old C++
    	# if ($directory -match "{5b2d190f-406e-49cf-8fea-1c3fc6777778}") {
        if ($directory -match "{15134cb0-b767-4960-a911-f2d16ae54797}") {
		write-host "Microsoft Visual C++ has " -nonewline
		write-host "been removed!" -ForegroundColor green
	}else{
		write-host "Microsoft Visual C++ has " -nonewline
		write-host "not been removed!" -ForegroundColor red
	}
}

# Function - .NET 4.5.2 [for CU7 +]
function Install-DotNET452{
    # .NET 4.5.2
	$val = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full" -Name "Release"
	if ($val.Release -lt "379893") {
    		GetIt "http://download.microsoft.com/download/E/2/1/E21644B5-2DF2-47C2-91BD-63C560427900/NDP452-KB2901907-x86-x64-AllOS-ENU.exe"
	    	Set-Location $targetfolder
    		[string]$expression = ".\NDP452-KB2901907-x86-x64-AllOS-ENU.exe /quiet /norestart /l* $targetfolder\DotNET452.log"
	    	Write-Host "File: NDP452-KB2901907-x86-x64-AllOS-ENU.exe installing..." -NoNewLine
    		Invoke-Expression $expression
    		Start-Sleep -Seconds 20
    		Write-Host "`n.NET 4.5.2 is now installed" -Foregroundcolor Green
	} else {
    		Write-Host "`n.NET 4.5.2 already installed" -Foregroundcolor Green
    }
} # end Install-DotNET452

# Function - Windows Management Framework 4.0 - Install - Needed for CU3+
function Install-WinMgmtFW4{
    # Windows Management Framework 4.0
	$wmf = $PSVersionTable.psversion
	if ($wmf.major -eq "4") {
	    	Write-Host "`nWindows Management Framework 4.0 is already installed" -Foregroundcolor Green
	} else {
	    	GetIt "http://download.microsoft.com/download/3/D/6/3D61D262-8549-4769-A660-230B67E15B25/Windows8-RT-KB2799888-x64.msu"
    		Set-Location $targetfolder
	    	[string]$expression = ".\Windows8-RT-KB2799888-x64.msu /quiet /norestart"
	    	Write-Host "File: Windows8-RT-KB2799888-x64 installing..." -NoNewLine
	    	Invoke-Expression $expression
    		Start-Sleep -Seconds 20
		$wmf = $PSVersionTable.psversion
	
	    	if ($wmf.major -ge "4") {Write-Host "`b`b`b`b`b`b`b`b`b`b`b`b`binstalled!   " -Foregroundcolor Green} else {Write-Host "`b`b`b`b`b`b`b`b`b`b`b`b`bFAILED!" -Foregroundcolor Red}
    }
} # end Install-WinMgmtFW4

# Mailbox requirements - Part 2
function check-prereqset2 {

     # Office 2010 Filter Pack
	if ((Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{95140000-2000-0409-1000-0000000FF1CE}") -eq $false){
	write-host "Office 2010 Filter Pack is " -nonewline 
	write-host "not installed!" -ForegroundColor red
	}
	else {
	write-host "Office 2010 Filter Pack is " -nonewline 
	write-host "installed." -ForegroundColor green
	}

     # Office 2010 SP2 Filter Pack
	$val = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{95140000-2000-0409-1000-0000000FF1CE}" -Name "DisplayVersion" -erroraction silentlycontinue
	if($val.DisplayVersion -ne "14.0.7015.1000"){
	write-host "Office 2010 SP2 Filter Pack is " -nonewline 
	write-host "not installed!" -ForegroundColor red
	}
	else {
	write-host "Office 2010 SP2 Filter Pack is " -nonewline 
	write-host "installed." -ForegroundColor green
	}
}

# Mailbox or CAS/Mailbox Windows Feature requirements - Part 2
function check-prereqset3 {
	$values = @("AS-HTTP-Activation","Desktop-Experience","NET-Framework-45-Features","RPC-over-HTTP-proxy","RSAT-Clustering","RSAT-Clustering-CmdInterface","Web-Mgmt-Console","WAS-Process-Model","Web-Asp-Net45","Web-Basic-Auth","Web-Client-Auth","Web-Digest-Auth","Web-Dir-Browsing","Web-Dyn-Compression","Web-Http-Errors","Web-Http-Logging","Web-Http-Redirect","Web-Http-Tracing","Web-ISAPI-Ext","Web-ISAPI-Filter","Web-Lgcy-Mgmt-Console","Web-Metabase","Web-Mgmt-Console","Web-Mgmt-Service","Web-Net-Ext45","Web-Request-Monitor","Web-Server","Web-Stat-Compression","Web-Static-Content","Web-Windows-Auth","Web-WMI","Windows-Identity-Foundation")
	foreach ($item in $values){
	$val = get-Windowsfeature $item
	If ($val.installed -eq $true){
	write-host "The Windows Feature"$item" is " -nonewline 
	write-host "installed." -ForegroundColor green
	}else{
	write-host "The Windows Feature"$item" is " -nonewline 
	write-host "not installed!" -ForegroundColor red
	}
	}	
}

# CAS specific requirements - SET 1
function check-prereqset4 {
	$values = @("AS-HTTP-Activation","Desktop-Experience","NET-Framework-45-Features","RPC-over-HTTP-proxy","RSAT-Clustering","Web-Mgmt-Console","WAS-Process-Model","Web-Asp-Net45","Web-Basic-Auth","Web-Client-Auth","Web-Digest-Auth","Web-Dir-Browsing","Web-Dyn-Compression","Web-Http-Errors","Web-Http-Logging","Web-Http-Redirect","Web-Http-Tracing","Web-ISAPI-Ext","Web-ISAPI-Filter","Web-Lgcy-Mgmt-Console","Web-Metabase","Web-Mgmt-Console","Web-Mgmt-Service","Web-Net-Ext45","Web-Request-Monitor","Web-Server","Web-Stat-Compression","Web-Static-Content","Web-Windows-Auth","Web-WMI","Windows-Identity-Foundation")
	foreach ($item in $values){
	$val = get-Windowsfeature $item
	If ($val.installed -eq $true){
	write-host "The Windows Feature"$item" is " -nonewline 
	write-host "installed." -ForegroundColor green
	}else{
	write-host "The Windows Feature"$item" is " -nonewline 
	write-host "not installed!" -ForegroundColor red
	}
	}
	write-host ""
	write-host "Make sure to open port 139 in the Windows firewall:"
	write-host "http://technet.microsoft.com/en-us/library/bb691354(v=exchg.150).aspx" -Foregroundcolor yellow
}

# Edge Transport requirement check
function check-prereqset5 {
	
     # Windows Feature AD LightWeight Services
	$values = @("ADLDS")
	foreach ($item in $values){
		$val = get-Windowsfeature $item
		If ($val.installed -eq $true){
			write-host "The Windows Feature"$item" is " -nonewline 
			write-host "installed." -ForegroundColor green
		}else{
			write-host "The Windows Feature"$item" is " -nonewline 
			write-host "not installed!" -ForegroundColor red
		}
	}

    # .NET 4.5.2 [for CU7+]
	$val = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full" -Name "Release"
	if($val.Release -lt "379893") {
		write-host ".NET 4.5.2 is " -nonewline 
		write-host "not installed!" -ForegroundColor red
	}
	else {
		write-host ".NET 4.5.2 is " -nonewline
		write-host "installed." -ForegroundColor green
	}

    # Windows Management Framework 4.0 - Check - Needed for CU3+
	$wmf = $PSVersionTable.psversion
	if ($wmf.major -ge "4") {
    	Write-Host "Windows Management Framework 4.0 is " -nonewline 
	    write-host "installed." -ForegroundColor green
	} else {
	write-host "Windows Management Framework 4.0 is " -nonewline 
	write-host "not installed!" -ForegroundColor red
	}
}

# Add a firewall rule for CAS role - Port 
function Add-FirewallRule {
   param( 
      $name,
      $tcpPorts,
      $appName = $null,
      $serviceName = $null
   )
    $fw = New-Object -ComObject hnetcfg.fwpolicy2 
    $rule = New-Object -ComObject HNetCfg.FWRule
        
    $rule.Name = $name
    if ($appName -ne $null) { $rule.ApplicationName = $appName }
    if ($serviceName -ne $null) { $rule.serviceName = $serviceName }
    $rule.Protocol = 6 #NET_FW_IP_PROTOCOL_TCP
    $rule.LocalPorts = $tcpPorts
    $rule.Enabled = $true
    $rule.Grouping = "@firewallapi.dll,-23255"
    $rule.Profiles = 7 # all
    $rule.Action = 1 # NET_FW_ACTION_ALLOW
    $rule.EdgeTraversal = $false
    
    $fw.Rules.Add($rule)
}

# Final Cleanup - C++ and register ASP .NET
function Cleanup-Final {
    # Old C++ from the old UCMA
	# [STRING] $targetFolder2 = "C:\ProgramData\Package Cache\{5b2d190f-406e-49cf-8fea-1c3fc6777778}"
    [STRING] $targetFolder2 = "C:\ProgramData\Package Cache\{15134cb0-b767-4960-a911-f2d16ae54797}"
	Set-Location $targetfolder2
	[string]$expression = ".\vcredist_x64.exe /q /uninstall /norestart"
	Invoke-Expression $expression
}

# Keep this one
function Install-FilterPack{
    # Office filter pack & SP2
   if ((Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{95140000-2000-0409-1000-0000000FF1CE}") -eq $false){
    	GetIt "http://download.microsoft.com/download/0/A/2/0A28BBFA-CBFA-4C03-A739-30CCA5E21659/FilterPack64bit.exe"
    	Set-Location $targetfolder
    	[string]$expression = ".\FilterPack64bit.exe /quiet /norestart /log:$targetfolder\FilterPack64bit.log"
    	Write-Host "File: FilterPack64bit.exe installing..." -NoNewLine
    	Invoke-Expression $expression
    	Start-Sleep -Seconds 2
    	Write-Host "`nOffice filter pack is now installed" -Foregroundcolor Green
    }else{
    	Write-Host "`nOffice filter pack already installed" -Foregroundcolor Green}
     $val = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{95140000-2000-0409-1000-0000000FF1CE}" -Name "DisplayVersion" -erroraction silentlycontinue
     if($val.DisplayVersion -ne "14.0.7015.1000"){
	GetIt "http://download.microsoft.com/download/D/C/A/DCA32A51-6954-4814-8838-422BD3F508F8/filterpacksp2010-kb2687447-fullfile-x64-en-us.exe"
    	Set-Location $targetfolder
    	[string]$expression = ".\filterpacksp2010-kb2687447-fullfile-x64-en-us.exe /quiet /norestart /log:$targetfolder\FilterPack64bit.log"
    	Write-Host "File: filterpacksp2010-kb2687447-fullfile-x64-en-us.exe installing..." -NoNewLine
    	Invoke-Expression $expression
    	Start-Sleep -Seconds 20
	Write-Host "`nOffice filter pack SP2 is now installed" -Foregroundcolor Green
	}
     else {
	Write-Host "`nOffice filter pack SP2 already installed" -Foregroundcolor Green
    	}
} # end Install-FilterPack

    # Install Microsoft Unified Communications Managed API 4.0, Core Runtime 64-bit
	function Install-NewWinUniComm4{
		GetIt "http://download.microsoft.com/download/2/C/4/2C47A5C1-A1F3-4843-B9FE-84C0032C61EC/UcmaRuntimeSetup.exe"
 	   	Set-Location $targetfolder
   	 	[string]$expression = ".\UcmaRuntimeSetup.exe /quiet /norestart /l* $targetfolder\WinUniComm4.log"
    		Write-Host "File: UcmaRuntimeSetup.exe installing..." -NoNewLine
    		Invoke-Expression $expression
    		Start-Sleep -Seconds 20
		$val = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{41D635FE-4F9D-47F7-8230-9B29D6D42D31}" -Name "DisplayVersion" -erroraction silentlycontinue
		if($val.DisplayVersion -ne "5.0.8308.0"){
		Write-Host "`nMicrosoft Unified Communications Managed API 4.0 is now installed" -Foregroundcolor Green}
        } # end Install-NewWinUniComm4

    # Uninstall Microsoft Unified Communications Managed API 4.0, Core Runtime 64-bit
	function UnInstall-WinUniComm4{
		GetIt "http://download.microsoft.com/download/2/C/4/2C47A5C1-A1F3-4843-B9FE-84C0032C61EC/UcmaRuntimeSetup.exe"
 	   	Set-Location $targetfolder
  	  	[string]$expression = ".\UcmaRuntimeSetup.exe /quiet /norestart /l* $targetfolder\WinUniComm4.log"
  	  	Write-Host "File: UcmaRuntimeSetup.exe uninstalling..." -NoNewLine
   	 	Invoke-Expression $expression
  	  	Start-Sleep -Seconds 20
		if ((Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{41D635FE-4F9D-47F7-8230-9B29D6D42D31}") -eq $false){
			write-host "Microsoft Unified Communications Managed API 4.0, Core Runtime 64-bit is " -nonewline 
			write-host "been uninstalled!" -ForegroundColor red
		}
	} # end Uninstall-WinUniComm4

    # New Function - Microsoft Unified Communications Managed API 4.0, Core Runtime 64-bit --> COMPLETE - needed for CAS and MBX roles
	function Install-WinUniComm4{
    # Microsoft Unified Communications Managed API 4.0, Core Runtime 64-bit
	$val = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{41D635FE-4F9D-47F7-8230-9B29D6D42D31}" -Name "DisplayVersion" -erroraction silentlycontinue
	  if($val.DisplayVersion -ne "5.0.8308.0"){
	   if($val.DisplayVersion -ne "5.0.8132.0"){
		if ((Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{A41CBE7D-949C-41DD-9869-ABBD99D753DA}") -eq $false) {
		    	Write-Host "`nMicrosoft Unified Communications Managed API 4.0 is not installed.  Downloading and installing now."
			Install-NewWinUniComm4
		} else {
	    	Write-Host "`nAn old version of Microsoft Unified Communications Managed API 4.0 is installed."
		UnInstall-WinUniComm4
		Write-Host "`nMicrosoft Unified Communications Managed API 4.0 has been uninstalled.  Downloading and installing now."
		Install-NewWinUniComm4
		}
	   } else {
	   Write-Host "`nThe Preview version of Microsoft Unified Communications Managed API 4.0 is installed."
	   UnInstall-WinUniComm4
	   Write-Host "`nMicrosoft Unified Communications Managed API 4.0 has been uninstalled.  Downloading and installing now."
	   Install-NewWinUniComm4
	   }
	  } else {
	  write-host "The correct version of Microsoft Unified Communications Managed API 4.0, Core Runtime 64-bit is " -nonewline
	  write-host "installed." -ForegroundColor green
	  }
    } # end Install-WinUniComm4

# Keep this one
function Install-PDFFilterPack{
    # adobe ifilter
    if ((Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{5EA12CF3-8162-47F6-ACAF-45AD03EFB08F}") -eq $false){
    	GetIt "http://download.adobe.com/pub/adobe/acrobat/win/9.x/PDFiFilter64installer.zip"
    	UnZipIt "PDFiFilter64installer.zip" "PDFFilter64installer.msi"
    	Set-Location $targetfolder
    	[string]$expression = ".\PDFFilter64installer.msi /quiet /norestart /l* $targetfolder\PDFiFilter64Installer.log"
    	Write-Host "File: PDFFilter64installer.msi installing..." -NoNewLine
    	Invoke-Expression $expression
    	Start-Sleep -Seconds 20
    	if ((Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{5EA12CF3-8162-47F6-ACAF-45AD03EFB08F}") -eq $true){Write-Host "`b`b`b`b`b`b`b`b`b`b`b`b`binstalled!   " -Foregroundcolor Green}else{Write-Host "`b`b`b`b`b`b`b`b`b`b`b`b`bFAILED!" -Foregroundcolor Red}
    }else{
    	Write-Host "`nPDF filter pack already installed" -Foregroundcolor Green
    }
} # end Install-PDFFilterPack

# Keep this one
function Configure-PDFFilterPack	{
	# Adobe iFilter Directory Path
	$iFilterDirName = "C:\Program Files\Adobe\Adobe PDF IFilter 9 for 64-bit platforms\bin"
	
	# Get the original path environment variable
	$original = (Get-ItemProperty "HKLM:SYSTEM\CurrentControlSet\Control\Session Manager\Environment" Path).Path
	
	# Add the ifilter path
	Set-ItemProperty "HKLM:SYSTEM\CurrentControlSet\Control\Session Manager\Environment" Path -value ( $original + ";" + $iFilterDirName )
	$CLSIDKey = "HKLM:\SOFTWARE\Microsoft\ExchangeServer\V14\MSSearch\CLSID"
	$FiltersKey = "HKLM:\SOFTWARE\Microsoft\ExchangeServer\v14\MSSearch\Filters"
	
	# Filter DLL Locations
	$pdfFilterLocation = "PDFFilter.dll"
	
	# Filter GUIDs
	$PDFGuid = "{E8978DA6-047F-4E3D-9C78-CDBE46041603}"
	
	# Create CLSIDs
	Write-Host "Creating CLSIDs..."
	New-Item -Path $CLSIDKey -Name $PDFGuid -Value $pdfFilterLocation -Type String
	
	# Set Threading model
	Write-Host "Setting threading model..."
	New-ItemProperty -Path "$CLSIDKey\$PDFGuid" -Name "ThreadingModel" -Value "Both" -Type String
	
	# Set Flags
	Write-Host "Setting Flags..."
	New-ItemProperty -Path "$CLSIDKey\$PDFGuid" -Name "Flags" -Value "1" -Type Dword
	
	# Create Filter Entries
	Write-Host "Creating Filter Entries..."
	
	# These are the entries for commonly exchange formats
	New-Item -Path $FiltersKey -Name ".pdf" -Value $PDFGuid -Type String
	Write-Host "Registry subkeys created. If this server holds the Hub Transport Role, the Network Service will need to have read access to the following registry keys:`n$CLSIDKey\$PDFGuid`n$FiltersKey\.pdf" -ForegroundColor Green
} # end function Configure-PDFFilterPack

# Keep this one --> Needed for CAS role only servers
function Set-RunOnce{
	# Sets the NetTCPPortSharing service for automatic startup before the first reboot
	# by using the old RunOnce registry key (because the service doesn't yet exist, or we could
	# use 'Set-Service')
	$hostname = (hostname)
	$RunOnceCommand1 = "sc \\$hostname config NetTcpPortSharing start= auto"
	if (Get-ItemProperty -Name "NetTCPPortSharing" -path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce' -ErrorAction SilentlyContinue) { 
	  Write-host "Registry key HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce\NetTCPPortSharing already exists." -ForegroundColor yellow
		Set-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" -Name "NetTCPPortSharing" -Value $RunOnceCommand1 | Out-Null
	} else { 
	  New-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" -Name "NetTCPPortSharing" -Value $RunOnceCommand1 -PropertyType "String" | Out-Null
	} 
} # end Set-RunOnce	

# Keep this one
function GetIt ([string]$sourcefile)	{
	if ($HasInternetAccess){
		# check if BitsTransfer is installed
		if ((Get-Module BitsTransfer) -eq $null){
			Write-Host "BitsTransfer: Installing..." -NoNewLine
			Import-Module BitsTransfer	
			Write-Host "`b`b`b`b`b`b`b`b`b`b`b`b`binstalled!   " -ForegroundColor Green
		}
		[string] $targetfile = $sourcefile.Substring($sourcefile.LastIndexOf("/") + 1) 
		if (Test-Path $targetfolder){
			Write-Host "Folder: $targetfolder exists."
		} else{
			Write-Host "Folder: $targetfolder does not exist, creating..." -NoNewline
			New-Item $targetfolder -type Directory | Out-Null
			Write-Host "`b`b`b`b`b`b`b`b`b`b`bcreated!   " -ForegroundColor Green
		}
		if (Test-Path "$targetfolder\$targetfile"){
			Write-Host "File: $targetfile exists."
		}else{	
			Write-Host "File: $targetfile does not exist, downloading..." -NoNewLine
			Start-BitsTransfer -Source "$SourceFile" -Destination "$targetfolder\$targetfile"
			Write-Host "`b`b`b`b`b`b`b`b`b`b`b`b`b`bdownloaded!   " -ForegroundColor Green
		}
	}else{
		Write-Host "Internet Access not detected. Please resolve and try again." -foregroundcolor red
	}
} # end GetIt

# Keep this one
function UnZipIt ([string]$source, [string]$target){
	if (Test-Path "$targetfolder\$target"){
		Write-Host "File: $target exists."
	}else{
		Write-Host "File: $target doesn't exist, unzipping..." -NoNewLine
		$sh = new-object -com shell.application
		$zipfolder = $sh.namespace("$targetfolder\$source") 
		$item = $zipfolder.parsename("$target")      
		$targetfolder2 = $sh.namespace("$targetfolder")       
		Set-Location $targetfolder
		$targetfolder2.copyhere($item)
		Write-Host "`b`b`b`b`b`b`b`b`b`b`b`bunzipped!   " -ForegroundColor Green
		Remove-Item $source
	}
} # end UnZipIt

# Keep this one
function Remove-IPv6	{
	$error.clear()
	Write-Host "TCP/IP v6......................................................[" -NoNewLine
	Write-Host "removing" -ForegroundColor yellow -NoNewLine
	Write-Host "]" -NoNewLine
	Set-ItemProperty -path HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters -name DisabledComponents -value 0xffffffff -type dword
	if ($error){
		Write-Host "`b`b`b`b`b`b`b`bfailed!" -ForegroundColor red -NoNewLine
	}else{
		Write-Host "`b`b`b`b`b`b`b`b`bdone!" -ForegroundColor green -NoNewLine
	}
	Write-Host "]    "
	$global:boolRebootRequired = $true
} # end function Remove-IPv6

# Keep this one
function Get-ModuleStatus { 
	param	(
		[parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Mandatory=$true, HelpMessage="No module name specified!")] 
		[string]$name
	)
	if(!(Get-Module -name "$name")) { 
		if(Get-Module -ListAvailable | ? {$_.name -eq "$name"}) { 
			Import-Module -Name "$name" 
			# module was imported
			return $true
		} else {
			# module was not available
			return $false
		}
	}else {
		# module was already imported
		# Write-Host "$name module already imported"
		return $true
	}
} # end function Get-ModuleStatus

# Keep this one
function New-FileDownload {
	param (
		[parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Mandatory=$true, HelpMessage="No source file specified")] 
		[string]$SourceFile,
    [parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Mandatory=$false, HelpMessage="No destination folder specified")] 
    [string]$DestFolder,
    [parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Mandatory=$false, HelpMessage="No destination file specified")] 
    [string]$DestFile
	)
	# I should clean up the display text to be consistent with other functions
	$error.clear()
	if (!($DestFolder)){$DestFolder = $TargetFolder}
	Get-ModuleStatus -name BitsTransfer
	if (!($DestFile)){[string] $DestFile = $SourceFile.Substring($SourceFile.LastIndexOf("/") + 1)}
	if (Test-Path $DestFolder){
		Write-Host "Folder: `"$DestFolder`" exists."
	} else{
		Write-Host "Folder: `"$DestFolder`" does not exist, creating..." -NoNewline
		New-Item $DestFolder -type Directory
		Write-Host "Done! " -ForegroundColor Green
	}
	if (Test-Path "$DestFolder\$DestFile"){
		Write-Host "File: $DestFile exists."
	}else{
		if ($HasInternetAccess){
			Write-Host "File: $DestFile does not exist, downloading..." -NoNewLine
			Start-BitsTransfer -Source "$SourceFile" -Destination "$DestFolder\$DestFile"
			Write-Host "Done! " -ForegroundColor Green
		}else{
			Write-Host "Internet access not detected. Please resolve and try again." -ForegroundColor red
		}
	}
} # end function New-FileDownload

function CheckPowerPlan {
	$HighPerf = powercfg -l | %{if($_.contains("High performance")) {$_.split()[3]}}
	$CurrPlan = $(powercfg -getactivescheme).split()[3]
	if ($CurrPlan -eq $HighPerf) {
		write-host " ";write-host "The power plan now is set to " -nonewline;write-host "High Performance." -foregroundcolor green;write-host " "
	}
}

function highperformance {
	$HighPerf = powercfg -l | %{if($_.contains("High performance")) {$_.split()[3]}}
	$CurrPlan = $(powercfg -getactivescheme).split()[3]
	if ($CurrPlan -ne $HighPerf) {
		powercfg -setactive $HighPerf
		CheckPowerPlan
	} else {
		if ($CurrPlan -eq $HighPerf) {
			write-host " ";write-host "The power plan is already set to " -nonewline;write-host "High Performance." -foregroundcolor green;write-host " "
		}
	}
}


function PowerMgmt {
	$NICs = Get-WmiObject -Class Win32_NetworkAdapter|Where-Object{$_.PNPDeviceID -notlike "ROOT\*" -and $_.Manufacturer -ne "Microsoft" -and $_.ConfigManagerErrorCode -eq 0 -and $_.ConfigManagerErrorCode -ne 22} 
	Foreach($NIC in $NICs) {
		$NICName = $NIC.Name
		$DeviceID = $NIC.DeviceID
		If([Int32]$DeviceID -lt 10) {
			$DeviceNumber = "000"+$DeviceID 
		} Else {
			$DeviceNumber = "00"+$DeviceID
		}
		$KeyPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002bE10318}\$DeviceNumber"
  
		If(Test-Path -Path $KeyPath) {
			$PnPCapabilities = (Get-ItemProperty -Path $KeyPath).PnPCapabilities
			If($PnPCapabilities -eq 0){Set-ItemProperty -Path $KeyPath -Name "PnPCapabilities" -Value 24 | Out-Null
				write-host "Changed the NIC Power Management settings.";write-host " ";write-host "A reboot is REQUIRED!" -foregroundcolor red;write-host " "}
			If($PnPCapabilities -eq $null){Set-ItemProperty -Path $KeyPath -Name "PnPCapabilities" -Value 24 | Out-Null
				write-host "Changed the NIC Power Management settings.";write-host " ";write-host "A reboot is REQUIRED!" -foregroundcolor red;write-host " "}
			If($PnPCapabilities -eq 24) {write-host " ";write-host "Power Management has already been " -NoNewline;write-host "disabled" -ForegroundColor Green;write-host " "}
   		 } 
 	 } 
 }

function DisableRC4 {
	# Define Registry keys to look for
	$base = Get-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\" -erroraction silentlycontinue
	$val1 = Get-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 128/128\" -erroraction silentlycontinue
	$val2 = Get-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 40/128\" -erroraction silentlycontinue
	$val3 = Get-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 56/128\" -erroraction silentlycontinue
	
	# Define Values to add
	$registryBase = "Ciphers"
	$registryPath1 = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 128/128\"
	$registryPath2 = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 40/128\"
	$registryPath3 = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 56/128\"
	$Name = "Enabled"
	$value = "0"
	$ssl = 0
	$checkval1 = Get-Itemproperty -Path "$registrypath1" -name $name -erroraction silentlycontinue
	$checkval2 = Get-Itemproperty -Path "$registrypath2" -name $name -erroraction silentlycontinue
	$checkval3 = Get-Itemproperty -Path "$registrypath3" -name $name -erroraction silentlycontinue
    
# Formatting for output
	write-host " "

# Add missing registry keys as needed
	If ($base -eq $null) {
		$key = (get-item HKLM:\).OpenSubKey("SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL", $true)
		$key.CreateSubKey('Ciphers')
		$key.Close()
	} else {
		write-host "The " -nonewline;write-host "Ciphers" -ForegroundColor green -NoNewline;write-host " Registry key already exists."
	}

	If ($val1 -eq $null) {
		$key = (get-item HKLM:\).OpenSubKey("SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers", $true)
		$key.CreateSubKey('RC4 128/128')
		$key.Close()
	} else {
		write-host "The " -nonewline;write-host "Ciphers\RC4 128/128" -ForegroundColor green -NoNewline;write-host " Registry key already exists."
	}

	If ($val2 -eq $null) {
		$key = (get-item HKLM:\).OpenSubKey("SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers", $true)
		$key.CreateSubKey('RC4 40/128')
		$key.Close()
		New-ItemProperty -Path $registryPath2 -Name $name -Value $value
	} else {
		write-host "The " -nonewline;write-host "Ciphers\RC4 40/128" -ForegroundColor green -NoNewline;write-host " Registry key already exists."
	}

	If ($val3 -eq $null) {
		$key = (get-item HKLM:\).OpenSubKey("SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers", $true)
		$key.CreateSubKey('RC4 56/128')
		$key.Close()
	} else {
		write-host "The " -nonewline;write-host "Ciphers\RC4 56/128" -ForegroundColor green -NoNewline;write-host " Registry key already exists."
	}
	
# Add the enabled value to disable RC4 Encryption
	If ($checkval1.enabled -ne "0") {
		try {
			New-ItemProperty -Path $registryPath1 -Name $name -Value $value -force;$ssl++
		} catch {
			$SSL--
		} 
	} else {
		write-host "The registry value " -nonewline;write-host "Enabled" -ForegroundColor green -NoNewline;write-host " exists under the RC4 128/128 Registry Key.";$ssl++
	}
	If ($checkval2.enabled -ne "0") {
		write-host $checkval2
		try {
			New-ItemProperty -Path $registryPath2 -Name $name -Value $value -force;$ssl++
		} catch {
			$SSL--
		} 
	} else {
		write-host "The registry value " -nonewline;write-host "Enabled" -ForegroundColor green -NoNewline;write-host " exists under the RC4 40/128 Registry Key.";$ssl++
	}
	If ($checkval3.enabled -ne "0") {
		try {
			New-ItemProperty -Path $registryPath3 -Name $name -Value $value -force;$ssl++
		} catch {
			$SSL--
		} 
	} else {
		write-host "The registry value " -nonewline;write-host "Enabled" -ForegroundColor green -NoNewline;write-host " exists under the RC4 56/128 Registry Key.";$ssl++
	}

# SSL Check totals
	If ($ssl -eq "3") {
		write-host " ";write-host "RC4 " -ForegroundColor yellow -NoNewline;write-host "is completely disabled on this server.";write-host " "
	} 
	If ($ssl -lt "3"){
		write-host " ";write-host "RC4 " -ForegroundColor yellow -NoNewline;write-host "only has $ssl part(s) of 3 disabled.  Please check the registry to manually to add these values";write-host " "
	}
} # End of Disable RC4 function

function DisableSSL3 {
    $TestPath1 = Get-Item -Path "HKLM:\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0" -erroraction silentlycontinue
    $TestPath2 = Get-Item -Path "HKLM:\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Server" -erroraction silentlycontinue
    $registrypath = "HKLM:\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Server"
    $Name = "Enabled"
	$value = "0"
    $checkval1 = Get-Itemproperty -Path "$registrypath" -name $name -erroraction silentlycontinue

# Check for SSL 3.0 Reg Key
	If ($TestPath1 -eq $null) {
		$key = (get-item HKLM:\).OpenSubKey("System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols", $true)
		$key.CreateSubKey('SSL 3.0')
		$key.Close()
	} else {
		write-host "The " -nonewline;write-host "SSL 3.0" -ForegroundColor green -NoNewline;write-host " Registry key already exists."
	}

# Check for SSL 3.0\Server Reg Key
	If ($TestPath2 -eq $null) {
		$key = (get-item HKLM:\).OpenSubKey("System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0", $true)
		$key.CreateSubKey('Server')
		$key.Close()
	} else {
		write-host "The " -nonewline;write-host "SSL 3.0\Servers" -ForegroundColor green -NoNewline;write-host " Registry key already exists."
	}

# Add the enabled value to disable SSL 3.0 Support
	If ($checkval1.enabled -ne "0") {
		try {
			New-ItemProperty -Path $registryPath -Name $name -Value $value -force;$ssl++
		} catch {
			$SSL--
		} 
	} else {
		write-host "The registry value " -nonewline;write-host "Enabled" -ForegroundColor green -NoNewline;write-host " exists under the SSL 3.0\Server Registry Key."
	}
} # End of Disable SSL 3.0 function


Do { 	
	if ($RebootRequired -eq $true){Write-Host "`t`t`t`t`t`t`t`t`t`n`t`t`t`tREBOOT REQUIRED!`t`t`t`n`t`t`t`t`t`t`t`t`t`n`t`tDO NOT INSTALL EXCHANGE BEFORE REBOOTING!`t`t`n`t`t`t`t`t`t`t`t`t" -backgroundcolor red -foregroundcolor black}
	if ($opt -ne "None") {Write-Host "Last command: "$opt -foregroundcolor Yellow}	
	$opt = Read-Host $menu

	switch ($opt)    {
		1 {# 	Prep CAS - Step 1
			Get-ModuleStatus -name ServerManager
			Set-RunOnce
			highperformance
			PowerMgmt
			Add-WindowsFeature AS-HTTP-Activation, Desktop-Experience, NET-Framework-45-Features, RPC-over-HTTP-proxy, RSAT-Clustering, Web-Mgmt-Console, WAS-Process-Model, Web-Asp-Net45, Web-Basic-Auth, Web-Client-Auth, Web-Digest-Auth, Web-Dir-Browsing, Web-Dyn-Compression, Web-Http-Errors, Web-Http-Logging, Web-Http-Redirect, Web-Http-Tracing, Web-ISAPI-Ext, Web-ISAPI-Filter, Web-Lgcy-Mgmt-Console, Web-Metabase, Web-Mgmt-Console, Web-Mgmt-Service, Web-Net-Ext45, Web-Request-Monitor, Web-Server, Web-Stat-Compression, Web-Static-Content, Web-Windows-Auth, Web-WMI, Windows-Identity-Foundation
			Add-FirewallRule "Exchange Server 2013 - CAS" "139" $null $null
			$RebootRequired = $true
		}
		2 {#	Prep CAS - Step 2
			Get-ModuleStatus -name ServerManager
			Install-DotNET452
			Install-WinMgmtFW4
			Install-WinUniComm4
			Cleanup-Final
			$RebootRequired = $false
		}
		3 {# 	Prep Mailbox or CAS/Mailbox - Step 1
			Get-ModuleStatus -name ServerManager
			Set-RunOnce
			highperformance
			PowerMgmt
			Add-WindowsFeature AS-HTTP-Activation, Desktop-Experience, NET-Framework-45-Features, RPC-over-HTTP-proxy, RSAT-Clustering, RSAT-Clustering-CmdInterface, Web-Mgmt-Console, WAS-Process-Model, Web-Asp-Net45, Web-Basic-Auth, Web-Client-Auth, Web-Digest-Auth, Web-Dir-Browsing, Web-Dyn-Compression, Web-Http-Errors, Web-Http-Logging, Web-Http-Redirect, Web-Http-Tracing, Web-ISAPI-Ext, Web-ISAPI-Filter, Web-Lgcy-Mgmt-Console, Web-Metabase, Web-Mgmt-Console, Web-Mgmt-Service, Web-Net-Ext45, Web-Request-Monitor, Web-Server, Web-Stat-Compression, Web-Static-Content, Web-Windows-Auth, Web-WMI, Windows-Identity-Foundation
			$RebootRequired = $true
		}
		4 {#	Prep Mailbox or CAS/Mailbox - Step 2
			Install-FilterPack
			Install-DotNET452
			Install-WinMgmtFW4
			Install-WinUniComm4
			Cleanup-Final
			$RebootRequired = $false
		}
	  	5 {#	Prep Exchange Transport
			Install-windowsfeature ADLDS
			Install-DotNET452
			Install-WinMgmtFW4
		}
	  	10 {#	Windows Update
			Invoke-Expression "$env:windir\system32\wuapp.exe startmenu"
		}
		11 {# 	CAS Requirement Check
			check-prereqset1
			check-prereqset4
		}
		12 {#	Mailbox or CAS/Mailbox Requirement Check
			check-prereqset1
			check-prereqset2
			check-prereqset3
		}
		13 {#	Edge Transport Requirement Check
			check-prereqset5
		}
		20 {#	Step 1 - One Off - Windows Components - CAS
			Get-ModuleStatus -name ServerManager
			Add-WindowsFeature AS-HTTP-Activation, Desktop-Experience, NET-Framework-45-Features, RPC-over-HTTP-proxy, RSAT-Clustering, Web-Mgmt-Console, WAS-Process-Model, Web-Asp-Net45, Web-Basic-Auth, Web-Client-Auth, Web-Digest-Auth, Web-Dir-Browsing, Web-Dyn-Compression, Web-Http-Errors, Web-Http-Logging, Web-Http-Redirect, Web-Http-Tracing, Web-ISAPI-Ext, Web-ISAPI-Filter, Web-Lgcy-Mgmt-Console, Web-Metabase, Web-Mgmt-Console, Web-Mgmt-Service, Web-Net-Ext45, Web-Request-Monitor, Web-Server, Web-Stat-Compression, Web-Static-Content, Web-Windows-Auth, Web-WMI, Windows-Identity-Foundation
		}
		21 {#	Step 1 - One Off - Windows Components - Mailbox or CAs/Mailbox
			Get-ModuleStatus -name ServerManager
			Add-WindowsFeature AS-HTTP-Activation, Desktop-Experience, NET-Framework-45-Features, RPC-over-HTTP-proxy, RSAT-Clustering, Web-Mgmt-Console, WAS-Process-Model, Web-Asp-Net45, Web-Basic-Auth, Web-Client-Auth, Web-Digest-Auth, Web-Dir-Browsing, Web-Dyn-Compression, Web-Http-Errors, Web-Http-Logging, Web-Http-Redirect, Web-Http-Tracing, Web-ISAPI-Ext, Web-ISAPI-Filter, Web-Lgcy-Mgmt-Console, Web-Metabase, Web-Mgmt-Console, Web-Mgmt-Service, Web-Net-Ext45, Web-Request-Monitor, Web-Server, Web-Stat-Compression, Web-Static-Content, Web-Windows-Auth, Web-WMI, Windows-Identity-Foundation
		}
		22 {#	Install - One Off - Unified Communications Managed API 4.0
			Install-WinUniComm4
		}
		23 {#	Final Cleanup and reboot
			Get-ModuleStatus -name ServerManager
			Cleanup-Final
		}
		30 { # Set power plan to High Performance as per Microsoft
			highperformance
		}
		31 { # Disable Power Management for NICs.		
			PowerMgmt
		}
		32 { # Disable SSL 3.0 Support
			DisableSSL3
		}
		33 { # Disable RC4 Support		
			DisableRC4
		}
		98 {#	Exit and restart
			Stop-Transcript
			restart-computer -computername localhost -force
		}
		99 {#	Exit
			if (($WasInstalled -eq $false) -and (Get-Module BitsTransfer)){
				Write-Host "BitsTransfer: Removing..." -NoNewLine
				Remove-Module BitsTransfer
				Write-Host "`b`b`b`b`b`b`b`b`b`b`bremoved!   " -ForegroundColor Green
			}
			popd
			Write-Host "Exiting..."
			Stop-Transcript
		}
		default {Write-Host "You haven't selected any of the available options. "}
	}
} while ($opt -ne 99)
}