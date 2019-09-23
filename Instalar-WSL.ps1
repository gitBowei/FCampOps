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