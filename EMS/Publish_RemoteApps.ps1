Import-Module RemoteDesktop

Get-RDAvailableApp -CollectionName "SessionCollection" | Where-Object {$_.DisplayName -eq "Paint"} | New-RDRemoteApp
Get-RDAvailableApp -CollectionName "SessionCollection" | Where-Object {$_.DisplayName -eq "WordPad"} | New-RDRemoteApp
Get-RDAvailableApp -CollectionName "SessionCollection" | Where-Object {$_.DisplayName -eq "Math Input Panel"} | New-RDRemoteApp

Get-RDRemoteApp -CollectionName "SessionCollection"
