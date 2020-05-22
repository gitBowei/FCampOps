Import-Module RemoteDesktop

Get-RDRemoteApp -CollectionName "SessionCollection" | ForEach-Object {Remove-RDRemoteApp -CollectionName "SessionCollection" -Alias $_.Alias -Force}
