Get-AppxPackage -AllUsers | Out-GridView

Get-AppxPackage -User CORP\Lori | Out-GridView

Get-AppxPackage -User CORP\Lori -name WinStore

Get-AppxLog | Out-GridView