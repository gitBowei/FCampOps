
# Install the Work Folders server feature on SYNC
Install-WindowsFeature -ComputerName "sync.corp.contoso.com" -Name "FS-SyncShareService" -IncludeAllSubFeature -IncludeManagementTools

# Install the Internet Information Services (IIS) managment tools (including PowerShell module) server feature on SYNC
Install-WindowsFeature -ComputerName "sync.corp.contoso.com" -Name "Web-Mgmt-Console"

