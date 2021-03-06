#variable que filtr:
#log: aplicacion 
#fuente :MSExchangeIS Mailbox Store
#eventos: entre 10044 y 10062 (relacionados con reparacion)
#tiempo: los ultimos 10 minutos = 600000 milisegundos

$queryeventos = @"
<QueryList>
  <Query Id="0" Path="Application">
    <Select Path="Application">*[System[Provider[@Name='MSExchangeIS Mailbox Store'] and ( (EventID &gt;= 10044 and EventID &lt;= 10062) ) and TimeCreated[timediff(@SystemTime) &lt;= 20000]]]</Select>
  </Query>
</QueryList>
"@
#Get-MailboxDatabase -Status | sort-object DatabaseSize| ft name, databasesize, MountedOnServer -AutoSize
$dbs = Get-MailboxDatabase -Status | sort-object DatabaseSize

foreach ($db in $dbs)
{
$database = $db.name
write-host -foregroundcolor darkyellow "working on DB: " $database

$salida = New-MailboxRepairRequest -Database $database -CorruptionType SearchFolder, FolderView,  AggregateCounts, ProvisionedFolder, MessagePtagCn, MessageId 
#write-host $salida 
$computermounted =  (Get-MailboxDatabase $database -Status | select-object *mount*ser*).mountedonserver
write-host "server: " $computermounted
write-host "Database: "   $salida.database
write-host "reques ID: " $salida.requestid
$valor_sal = 0
$esta_corrupto =0
do{
	$eventos = $null
	Start-Sleep -Milliseconds  10000
	write-host "."  -NoNewline
	$eventos = get-winevent -FilterXml $queryeventos -computername $computermounted -erroraction SilentlyContinue
#    write-output $eventos 
	$eval = $eventos | Where-Object { $_.message -match $salida.RequestID} |  Where-Object {$_.message -match "completed successfully" }
#	$eval = get-eventlog -LogName application -computername $salida.server  -Newest 100 | Where-Object { $_.message -match $salida.RequestID} |  Where-Object {$_.message -match "completed successfully" }
	$eval_corruto = $eventos | Where-Object { $_.message -match $database } | Where-Object {$_.message -match "Corruptions detected" }
#	$eval_corruto = get-eventlog -LogName application  -Newest 100 | Where-Object { $_.message -match $database } | Where-Object {$_.message -match "Corruptions detected" }
	$valor_sal = (Measure-Object -InputObject $eval).count
	$esta_corrupto = (Measure-Object -InputObject $eval_corruto).count
}while($valor_sal -eq 0)
if($esta_corrupto -ne 0){
	write-host -ForegroundColor RED "necesario ejecutar de nuevo este script en esta base de datos!!! $database"
} 
write-host 
write-host  "Database:  $database  done!" -ForegroundColor DarkGreen

}