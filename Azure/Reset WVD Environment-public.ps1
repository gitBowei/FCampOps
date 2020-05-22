$tenant = "Agenciadetierras.gov.co"
$Hostpool = "ANTVDI"


## Remove Desktop Host Pool##
Remove-RdsSessionHost $tenant $Hostpool W10VDI.ant.local -Force
Remove-RdsSessionHost $tenant $Hostpool W10VDI-0.ant.local -Force
Remove-RdsSessionHost $tenant $Hostpool W10VDI-1.ant.local -Force
Remove-RdsSessionHost $tenant $Hostpool W10VDI-2.ant.local -Force
Remove-RdsSessionHost $tenant $Hostpool W10VDI-3.ant.local -Force
Remove-RdsSessionHost $tenant $Hostpool W10VDI-4.ant.local -Force
Remove-RdsSessionHost $tenant $Hostpool W10VDI-5.ant.local -Force
Remove-RdsSessionHost $tenant $Hostpool W10VDI-6.ant.local -Force
Remove-RdsAppGroup $tenant $Hostpool "Desktop Application Group"
Remove-RdsHostPool $tenant $Hostpool

## Remove Application Host Pool##
Remove-RdsRemoteApp $tenant $Hostpool AplicacionesANT "Asistencia" 
Remove-RdsRemoteApp $tenant $Hostpool AplicacionesANT "EscritorioRemoto" 
Remove-RdsRemoteApp $tenant $Hostpool AplicacionesANT "EXCEL"
Remove-RdsRemoteApp $tenant $Hostpool AplicacionesANT "OUTLOOK"
Remove-RdsRemoteApp $tenant $Hostpool AplicacionesANT "POWERPOINT"
Remove-RdsRemoteApp $tenant $Hostpool AplicacionesANT "Recortes"
Remove-RdsRemoteApp $tenant $Hostpool AplicacionesANT "WORD"

Remove-RdsAppGroup $tenant $Hostpool AplicacionesANT
Remove-RdsAppGroup $tenant $Hostpool "Desktop Application Group"

Remove-RdsSessionHost $tenant $Hostpool W10VDI.ant.local -Force
Remove-RdsSessionHost $tenant $Hostpool W10VDI-0.ant.local -Force
Remove-RdsSessionHost $tenant $Hostpool W10VDI-1.ant.local -Force
Remove-RdsSessionHost $tenant $Hostpool W10VDI-2.ant.local -Force
Remove-RdsSessionHost $tenant $Hostpool W10VDI-3.ant.local -Force
Remove-RdsSessionHost $tenant $Hostpool W10VDI-4.ant.local -Force
Remove-RdsSessionHost $tenant $Hostpool W10VDI-5.ant.local -Force
Remove-RdsSessionHost $tenant $Hostpool W10VDI-6.ant.local -Force
Remove-RdsHostPool $tenant $Hostpool

## Check System Groups ##

Get-RdsHostPool $tenant