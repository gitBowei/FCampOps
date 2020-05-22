Clear-Host
$Equipos=c:\temp\servidores.txt
Get-Content "$Equipos" |ForEach{
Get-WmiObject -Class Win32_service |Where-Object {$_.state -eq "Running"}|Group-Object -Property StartName |Format-Table Name, Count -auto |out-file c:\temp\ServiciosPPU.txt -Append
get-service | Where-Object {$_.status -eq "running"}| format-table -property MachineName, Name, DisplayName -auto |out-file c:\temp\ServiciosPPU.txt -Append
}
