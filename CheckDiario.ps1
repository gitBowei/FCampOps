#Script para validacion de dominios
#importamos las librerias de dominio
import-module activedirectory
#iniciamos una sesion remota en los controladores de dominio
$cred = get-credential synapsisit\_srv_co_admin
ping synco04dc01
ping synco04dc02
$s1 = new-pssession -computername synco04dc01 -Credential $cred
#Generamos un reporte de replicacion
invoke-command -session $s1 -scriptblock{repadmin /showrepl} |more
#buscamos errores en el Log de eventos
invoke-command -session $s1 -scriptblock{Get-EventLog -LogName system -Newest 5 -EntryType error |fl}
invoke-command -session $s1 -scriptblock{Get-WmiObject Win32_Service |Where-Object { $_.StartMode -eq 'Auto' -and $_.State -ne 'Running' } |Format-Table}
invoke-command -session $s1 -scriptblock{Get-WMIObject Win32_LogicalDisk}

$s3 = new-pssession -computername syncl03mta01 -Credential $cred
invoke-command -session $s3 -scriptblock{Get-WmiObject Win32_Service |Where-Object { $_.StartMode -eq 'Auto' -and $_.State -ne 'Running' } |Format-Table}
#C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -noexit -command ". 'E:\Program Files\Microsoft\Exchange Server\V14\bin\RemoteExchange.ps1'; Connect-ExchangeServer -auto"
#invoke-command -session $s3 -scriptblock{". 'E:\Program Files\Microsoft\Exchange Server\V14\bin\RemoteExchange.ps1'; Connect-ExchangeServer -auto"}
#invoke-command -session $s3 -scriptblock{get-mailqueue}
invoke-command -session $s3 -scriptblock{Get-EventLog -LogName system -Newest 5 -EntryType error |fl}
invoke-command -session $s3 -scriptblock{Get-WMIObject Win32_LogicalDisk}
#Ahora validamos el File server
$s4 = new-pssession -computername colsyc01is02.synapsisit.syngbl.int -Credential $cred
invoke-command -session $s4 -scriptblock{Get-EventLog -LogName system -Newest 5 -EntryType error |fl}
invoke-command -session $s4 -scriptblock{Get-WmiObject Win32_Service |Where-Object { $_.StartMode -eq 'Auto' -and $_.State -ne 'Running' } |Format-Table}
invoke-command -session $s4 -scriptblock{Get-WMIObject Win32_LogicalDisk}
