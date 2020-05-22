Set-VpnConnection -Name "Contoso VPN Connection" -SplitTunneling $true

Add-VpnConnectionTriggerApplication -Name "Contoso VPN Connection" –ApplicationID "C:\Windows\System32\notepad.exe"

Get-VpnConnectionTrigger "Contoso VPN Connection"
