# Con este Script habilitamos la conectividad de Powershell remoto, y permitimos la conexion a diferentes host cliente.
Enable-PSRemoting –force
Get-Item WSMan:\localhost\Client\TrustedHosts
Set-Item WSMan:\localhost\Client\TrustedHosts -Value *
Get-Item WSMan:\localhost\Client\TrustedHosts