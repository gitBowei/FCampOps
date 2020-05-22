import-module azure
Import-AzurePublishSettingsFile -PublishSettingsFile 'c:\users\fcamp\Downloads\Plataformas de MSDN-11-5-2015-credentials.publishsettings'

Param(
	[string]$servicename,
	[string]$name,
	[string]$userName,
	[string]$password
)

$servicename = 'CloudDemo001'
#get-AzureVM -ServiceName CloudDemo001 |ft
$name = 'BOGDC01'
$userName = 'sysadmin'
$password = "1234abcd."

$vm = Get-AzureVM -ServiceName $servicename -Name $name

If ($vm.InstanceStatus -ne 'ReadyRole')
{
    Write-Host ("VM is not running. InstanceStatus:" + $vm.instancestatus)        
}
Else
{        
    $port = ($vm.VM.ConfigurationSets.Inputendpoints | Where { $_.LocalPort -eq 5986 }).Port
    $vip = ($vm.VM.ConfigurationSets.Inputendpoints | Where { $_.LocalPort -eq 5986 }).Vip
    $uri = ('https://' + $vip + ':' + $port)
        
    $Credential = New-Object System.Management.Automation.PSCredential($username, $(ConvertTo-SecureString -String $password -AsPlainText -Force))
	$SessionOption = New-PSSessionOption -SkipCACheck -SkipCNCheck -NoMachineProfile
	$PSSession = New-PSSession -ConnectionUri $uri -Credential $Credential -SessionOption $SessionOption
    
    Enter-PSSession $PSSession	
}

-------------------------------------------------------

Stop-AzureVM -ServiceName CloudDemo001 -Name BOGDC01
-------------------------------------------------------
Function Get-Uptime {
<#
.SYNOPSIS 
        Displays Uptime since last reboot
.PARAMETER  Computername
.EXAMPLE
 Get-Uptime Server1
.EXAMPLE
 "Server1", "Server2"|Get-Uptime
.EXAMPLE
 (Get-Uptime Sever1)."Time Since Last Reboot"
#>
 [CmdletBinding()]
 Param (
 [Parameter(Mandatory=$True,ValueFromPipeline=$true,Position=0)]
        [STRING[]]$Computername
        )
 
 Begin {Write-Verbose "Version 1.00"}
        
 Process {
        $Now=Get-Date
        $LastBoot=[System.Management.ManagementDateTimeConverter]::ToDateTime((Get-WmiObject win32_operatingsystem -ComputerName $computername).lastbootuptime)
        $Result=@{ "Server"=$($Computername);
                   "Last Reboot"=$LastBoot;
                   "Time Since Reboot"="{0} Days {1} Hours {2} Minutes {3} Seconds" -f ($Now - $LastBoot).days, `
                        ($Now - $LastBoot).hours,($Now - $LastBoot).minutes,($Now - $LastBoot).seconds}
        Write-Output (New-Object psobject -Property $Result|select Server, "Last Reboot", "Time Since Reboot")
        }
}

-------------------------------------------------------------------
#Habilitar PowerShellWebAccess en W2012

Install-WindowsFeature –Name WindowsPowerShellWebAccess -IncludeManagementTools
Install-PswaWebApplication 
Add-PswaAuthorizationRule -UserName sysadmin -ComputerName BOGDC01 -ConfigurationName windows.Powershell

#Remove-WindowsFeature –Name WindowsPowerShellWebAccess -IncludeManagementTools
#Uninstall-PswaWebApplication –webApplicationName PSWA 
#Remove-PswaAuthorizationRule -id 2

Get-PswaAuthorizationRule
-------------------------------------------------------------------

function Get-SysinternalsTools {
    <#
    .Synopsis
       Downloads the Sysinternals tools to the Machine
    .DESCRIPTION
       Downloads the Sysinternals tools to a specified directory using Bits Transfer.
    .PARAMETER Path
        Path to save the sysinternals executables.
    .EXAMPLE
       Get-SysinternalsTools -Path 'C:\Sysinternals' -Verbose -DownloadProtocol HTTP
    .EXAMPLE
       Get-SysinternalsTools -Path 'C:\Sysinternals' -DownloadProtocol SMB -Verbose
    #>
	
	[CmdletBinding()]
	
	Param
	(
		
		[Parameter(Mandatory = $true,
				   ValueFromPipeline = $true,
				   ValueFromPipelineByPropertyName = $true,
				   ValueFromRemainingArguments = $false,
				   Position = 0,
				   HelpMessage = "Enter the path to wich you want to save the file.")]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[System.String]$Path,
		
		[Parameter(Mandatory = $true,
				   Position = 0,
				   HelpMessage = "Select the protocol you wish to use to Download the Tools")]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[ValidateSet('SMB', 'HTTP')]
		$DownloadProtocol
		
	)
	
	Begin {
		
		Write-Verbose -Message "Verifing if the webclient service is currently running..."
		
		if ((Get-Service -Name webclient).Status -eq 'Running') {
			
			Write-Verbose -Message "Webclient service if running, will continue now."
			
		}
		else {
			
			Write-Verbose -Message "Webclient service not running..."
			
			try {
				Write-Verbose -Message "Trying to start the service..."
				
				$start_service = $true
				
				Start-Service -Name 'webclient' -ErrorAction 'Stop'
				
			}
			catch {
				
				$start_service = $false
				
				Write-Error -Message "Couldn't start the webclient service"
				
			}
			finally {
				
				Write-Verbose -Message "Sucessfully Started the service"
				
			}
			if (-not ($start_service)) {
				
				return
				
			}
		}
		
		Write-Verbose -Message "Verifing if the provided path exists..."
		
		if (-not (Test-Path -Path $Path)) {
			
			Write-Verbose -Message "Provided path does not exist..."
			
			Write-Verbose -Message "Trying to create the folder"
			
			Try {
				$folder_Creation = $true
				
				New-Item $Path -ItemType Directory -Force -ErrorAction 'Stop'
				
			}
			Catch {
				
				$folder_Creation = $false
				
				Write-Verbose -Message "Error Creating the folder"
				Write-Error -Message "Can't create the folder... Will exit now"
				
				return
				
				
			}
			
			if ($folder_Creation) {
				
				Write-Verbose -Message "Sucessfully Created the folder"
				
			}
			
		}
		
	}
	
	Process {
		
		if ($DownloadProtocol -eq 'SMB') {
			
			Write-Verbose -Message 'Selected download protocol is SMB'
			
			$progParam = @{
				
				Activity = "Downloading Sysinternals executables"
				CurrentOperation = '\\live.sysinternals.com\tools'
				Status = "Querying top level Tools"
				PercentComplete = 0
				
			}
			
			Write-Progress @progParam
			
			Write-Verbose -Message "Begin listing tools"
			
			try {
				
				$listing_status = $true
				
				$TotalItems = Get-Childitem -Path '\\live.sysinternals.com\tools' -Recurse -ErrorAction 'Stop'
				
			}
			catch {
				
				$listing_status = $false
				
				Write-Error -Message "Error listing the files, please verify your conectivity"
				
			}
			if (-not ($listing_status)) {
				
				break
				
			}
			
			Write-Verbose -Message "Tools sucessfully listed"
			
			Write-Verbose -Message "Will Begin the Download now"
			
			Write-Verbose -Message "Initializing loop counter"
			
			$i = 0
			
			foreach ($item in $TotalItems) {
				
				#calculate percentage
				Write-Verbose -Message "Calculating current percentage..."
				
				$i++
				
				[int]$percent = ($i / $TotalItems.count) * 100
				
				Write-Verbose -Message "Currently on $percent%..."
				
				[String]$FileName = $item.Name
				
				[String]$Source = $Item.FullName
				
				[String]$Destination = $Path
				
				$progParam.CurrentOperation = "Downloading file: $FileName"
				$progParam.Status = "Downloading from '\\live.sysinternals.com'"
				$progParam.PercentComplete = $percent
				
				Write-Progress @progParam
				
				Write-Verbose -Message "Begin downloading $FileName"
				
				try {
					
					$Download_Status = $true
					
					Start-BitsTransfer -Source $Source -Destination $Destination -DisplayName $FileName -Priority 'High' -Description "Downloading tool..." -ErrorAction 'Stop'
					
				}
				catch {
					
					Write-Error -Message "Error Downloading $FileName..."
					
				}
				
				if ($Download_Status) {
					
					Write-Verbose -Message "Sucessfully downloaded $FileName"
					
				}
				
				Start-Sleep -Milliseconds 200
				
				Write-Verbose -Message "Sucessfully Download the Tools"
			}
		}
		if ($DownloadProtocol -eq 'HTTP') {
			
			Write-Verbose -Message 'Selected download protocol is HTTP'
			
			$progParam = @{
				
				Activity = "Downloading Sysinternals executables"
				CurrentOperation = 'http://live.sysinternals.com\tools'
				Status = "Querying top level Tools"
				PercentComplete = 0
				
			}
			
			Write-Progress @progParam
			
			Write-Verbose -Message "Begin listing tools"
			
			try {
				
				$listing_status = $true
				
				$TotalItems = (Invoke-WebRequest -Uri 'http://live.sysinternals.com' -ErrorAction 'Stop').links
				
			}
			catch {
				
				$listing_status = $false
				Write-Error -Message "Error listing the files, please verify your conectivity"
				
				
			}
			if (-not ($listing_status)) {
				
				break
				
			}
			
			Write-Verbose -Message "Tools sucessfully listed"
			
			Write-Verbose -Message "Will Begin the Download now"
			
			Write-Verbose -Message "Initializing loop counter"
			
			$i = 0
			
			foreach ($item in $TotalItems) {
				
				#calculate percentage
				Write-Verbose -Message "Calculating current percentage..."
				
				$i++
				
				[int]$percent = ($i / $TotalItems.count) * 100
				
				Write-Verbose -Message "Currently on $percent%..."
				
				[String]$FileName = $Item.InnerText
				
				[String]$Source = "http://live.sysinternals.com/$($Item.innerText)"
				
				[String]$Destination = $Path
				
				$progParam.CurrentOperation = "Downloading file: $FileName"
				$progParam.Status = "Downloading from 'http://live.sysinternals.com'"
				$progParam.PercentComplete = $percent
				
				Write-Progress @progParam
				
				Write-Verbose -Message "Begin downloading $FileName from $Source..."
				
				
				
				try {
					
					$Download_Status = $true
					
					Start-BitsTransfer -Source $Source -Destination $Destination -DisplayName $FileName -Priority 'High' -Description "Downloading tool..." -ErrorAction 'Stop' -TransferType Download
					
				}
				catch {
					
					Write-Error -Message "Error Downloading $FileName..."
					
				}
				
				if ($Download_Status) {
					
					Write-Verbose -Message "Sucessfully downloaded $FileName"
					
				}
				
				Start-Sleep -Milliseconds 200
				
				Write-Verbose -Message "Sucessfully Download the Tools"
				
			}
			
		}
		
		
	}
	
	End {
	}
	
}

----------------------------------------

#Install and run BGInfo at startup using registry method as described here:
#http://forum.sysinternals.com/bginfo-at-startup_topic2081.html
#Setup 
#1. Download BgInfo http://technet.microsoft.com/en-us/sysinternals/bb897557
#2. Create a bginfo folder and copy bginfo.exe
#3. Create a bginfo.bgi file by running bginfo.exe and saving a bginfo.bgi file and placing in same directory as bginfo

if (Test-Path "C:\WINDOWS\system32\bginfo")
{ remove-item -path "C:\WINDOWS\system32\bginfo" -Recurse }

#Change \\Z001\d$\sw\bginfo to your SW distrib share
copy-item \\10.27.9.67\shared\bginfo -Destination C:\Windows\system32 -Recurse

Set-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -name "BgInfo" -value  "C:\WINDOWS\system32\bginfo\Bginfo.exe C:\WINDOWS\system32\bginfo\bginfo.bgi /TIMER:0 /NOLICPROMPT"