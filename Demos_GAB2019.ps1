$PSVersionTable
Get-WmiObject -Class Win32_OperatingSystem | Format-Table Caption, ServicePackMajorVersion -AutoSize
(Get-ItemProperty -Path 'HKLM:\Software\Microsoft\NET Framework Setup\NDP\v4\Full' -ErrorAction SilentlyContinue).Version -like '4.5*'
$env:computername

New-PSDrive -Name F -PSProvider FileSystem -Root \\Client01\Data -Persist

Get-Module

Get-Module -ListAvailable

Find-Module -Name MSOnline
Find-Module -Name MSOnline | Install-Module -Force
$O365Cred = Get-Credential
Connect-MsolService -Credential $O365Cred
Get-MsolAccountSku
$LicenseSKU = Get-MsolAccountSku |
    Out-GridView -Title 'Select a license plan to assign to users' -OutputMode Single |
    Select-Object -ExpandProperty AccountSkuId

#--------------
$Users = Get-MsolUser -All -UnlicensedUsersOnly |
Out-GridView -Title 'Select users to assign license plan to' -OutputMode Multiple
#--------------
$Users | Set-MsolUser -UsageLocation US
$Users | Set-MsolUserLicense -AddLicenses $LicenseSKU
#--------------
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell-liveid?DelegatedOrg=yourdomain.onmicrosoft.com -Credential $O365Cred -Authentication Basic -AllowRedirection
Import-PSSession -Session $Session
#--------------
(Get-Module ActiveDirectory).ExportedCommands

Get-Command -Module ActiveDirectory
#Crear usuarios Estudiante de uno al diez
1..10 | Foreach-Object {New-ADUser -Name Student$_ -AccountPassword (ConvertTo-SecureString "Pa$$w000rd" -AsPlainText -Force) -UserPrincipalName Student$_@$env:userdnsdomain -ChangePasswordAtLogon 1 -Enabled 1 -Verbose}


cd $PSHome\Modules

cd $Env:ProgramFiles\WindowsPowerShell\Modules

cd $Home\Documents\WindowsPowerShell\Modules

Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

## Demo Do-Speak
##Copy this module to C:\Program Files\Windows PowerShell\Modules\do-speak

Function Do-Speak {
 
    [CmdletBinding()]
     
    param
    (
     
    [Parameter(Position=0)]
     
    $Computer
     
    )
     
    If (!$computer)
     
    {
     
    $Text=Read-Host 'Enter Text'
     
    [Reflection.Assembly]::LoadWithPartialName('System.Speech') | Out-Null
    $object = New-Object System.Speech.Synthesis.SpeechSynthesizer
    $object.Speak($Text)
     
    }
     
    else {
     
    $cred=Get-Credential
     
    $PS=New-PSSession -ComputerName $Computer -Credential $cred
     
    Invoke-Command -Session $PS {
    $Text=Read-Host 'Enter Text'
     
    [Reflection.Assembly]::LoadWithPartialName('System.Speech') | Out-Null
    $object = New-Object System.Speech.Synthesis.SpeechSynthesizer
    $object.Speak($Text)
    }
     
    }
     
    }


#----------------------
## Demo Test-Gateway
##Copy Module to c:\Program Files\WindowsPowerShell\Modules\Test-Gateway

function Test-Gateway {
    param($Computer = $null,
     $Count = "1")
    If ($Computer -eq $null)
    {Test-Connection -Destination (Get-NetRoute -DestinationPrefix 0.0.0.0/0 | Select-Object -ExpandProperty Nexthop) -Count $Count}
     else
     {$Route=Invoke-Command -ComputerName $Computer {Get-NetRoute -DestinationPrefix 0.0.0.0/0 | Select-Object -ExpandProperty Nexthop}; Test-Connection -Source $Computer -Destination $Route -Count $Count}
     }
#-----------------
Get-Command Test-Gateway -ShowCommandInfo

##Retrieve a list of all software installed remotely

Get-WmiObject win32_product
Get-CimInstance win32_product
Get-CimInstance win32_product | Select-Object Name, PackageName, InstallDate | Out-GridView

(Get-ADComputer -Filter * -Searchbase "OU=Test,DC=sid-500,DC=com").Name | Out-File C:\Temp\Computer.txt | notepad C:\Temp\Computer.txt

Get-CimInstance -ComputerName (Get-Content C:\Temp\Computer.txt) -ClassName win32_product -ErrorAction SilentlyContinue| Select-Object PSComputerName, Name, PackageName, InstallDate | Out-GridView

#Install Windows Features and reboot

Enable-WindowsOptionalFeature -FeatureName Microsoft-Windows-Subsystem-Linux -Online
#--------------------------
Enable-WindowsOptionalFeature -FeatureName Microsoft-Windows-Subsystem-Linux -Online -NoRestart -OutVariable results
if ($results.RestartNeeded -eq $true) {
  Restart-Computer -Force
}
#--------------------------
$ProgPref = $ProgressPreference
$ProgressPreference = 'SilentlyContinue'
$results = Enable-WindowsOptionalFeature -FeatureName Microsoft-Windows-Subsystem-Linux -Online -NoRestart -WarningAction SilentlyContinue
$ProgressPreference = $ProgPref
if ($results.RestartNeeded -eq $true) {
  Restart-Computer -Force
}
#--------------------------
Get-Command -Noun WindowsCapability
Get-WindowsCapability -Name RSAT* -Online
Get-WindowsCapability -Name RSAT* -Online | Select-Object -Property DisplayName, State
Get-WindowsCapability -Name RSAT* -Online | Add-WindowsCapability -Online
Get-WindowsCapability -Name RSAT* -Online | Select-Object -Property DisplayName, State
Update-Help

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

#Update Git repository

git status

git remote show
git remote show origin

git diff https://github.com/Bravecold/skyshell.git

git checkout

git remote add upstream https://github.com/Bravecold/skyshell.git
git fetch upstream

git merge upstream/master
