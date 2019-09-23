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