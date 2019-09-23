#Habilitar PowerShellWebAccess en W2012

Install-WindowsFeature –Name WindowsPowerShellWebAccess -IncludeManagementTools
Install-PswaWebApplication 
Add-PswaAuthorizationRule -UserName demo\sysadmin -ComputerName DC1DemoGlup -ConfigurationName windows.Powershell

#Remove-WindowsFeature –Name WindowsPowerShellWebAccess -IncludeManagementTools
#Uninstall-PswaWebApplication –webApplicationName PSWA 
#Remove-PswaAuthorizationRule -id 2

Get-PswaAuthorizationRule
