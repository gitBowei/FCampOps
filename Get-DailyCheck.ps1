#. En Powershell ISE ejecutar la siguiente sentencia y espera hasta que finalice el registro de Operations Manager.
Get-WinEvent -ListLog * -EA silentlycontinue  | Foreach {Get-WinEvent $_.LogName  | Where-Object {$_.LastWriteTime -gt ((Get-Date) - (New-TimeSpan -Day 1))} | Format-List -Property LogName, FileSize, LastWriteTime}

$time = (Get-Date) – (New-TimeSpan -Day 1)
 
#Get-WinEvent -ListLog * -EA silentlycontinue  | Foreach {Get-WinEvent –FilterHashtable @{logname=$_.LogName;level=2,3; starttime=$time } | group ID | sort-object -Descending "Count" | ft Name,Count -Wrap -AutoSize}

Get-WinEvent -ListLog * -EA silentlycontinue | sort-object -descending RecordCount | ?  {($_.RecordCount -notlike $null -and $_.RecordCount -notlike "0")}
Write-Output "Log System Error."
Get-EventLog -LogName system -EntryType "error" -After (Get-Date).AddHours(-24) | group EventID | sort-object -Descending "Count" | ft Name,Count -Wrap -AutoSize
Write-Output "Log System Warning." 
Get-EventLog -LogName system -EntryType "warning" -After (Get-Date).AddHours(-24) | group EventID | sort-object -Descending "Count" | ft Name,Count -Wrap -AutoSize
Write-Output "Log Application Error."
Get-EventLog -LogName application -EntryType "error" -After (Get-Date).AddHours(-24) | group EventID | sort-object -Descending "Count" | ft Name,Count -Wrap -AutoSize
Write-Output "Log Application Warning." 
Get-EventLog -LogName application -EntryType "warning" -After (Get-Date).AddHours(-24) | group EventID | sort-object -Descending "Count" | ft Name,Count -Wrap -AutoSize
Write-Output "Log Operations Manager Error."
Get-EventLog -LogName "Operations Manager" -EntryType "error" -After (Get-Date).AddHours(-24) | group EventID | sort-object -Descending "Count" | ft Name,Count -Wrap -AutoSize
Write-Output "Log Operations Manager Warning." 
Get-EventLog -LogName "Operations Manager"  -EntryType "warning" -After (Get-Date).AddHours(-24) | group EventID | sort-object -Descending "Count" | ft Name,Count -Wrap -AutoSize

# %windir%\system32\inetsrv\appcmd.exe add backup "IIS-23102018"

# perfmon && perfmon /rel && explorer /root, && dxdiag && sysdm.cpl && eventvwr /c: && services.msc && PowerShell_ISE && perfmon /report && taskmgr && resmon


#. Verificar que servicios automáticos están detenidos
Get-CimInstance win32_service -Filter "startmode = 'auto' AND state != 'running'"