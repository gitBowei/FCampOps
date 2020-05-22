Install-WindowsFeature –Name WindowsPowerShellWebAccess -IncludeManagementTools
Install-PswaWebApplication
Add-PswaAuthorizationRule -UserName contoso\anfisher -ComputerName VMM01 -ConfigurationName Windows.PowershellRemove-WindowsFeature –Name WindowsPowerShellWebAccess -IncludeManagementTools
#Uninstall-PswaWebApplication –webApplicationName PSWA
#Remove-PswaAuthorizationRule -id 2




Get-PswaAuthorizationRule