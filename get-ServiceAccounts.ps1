##Consultar los usuarios que inician servicios localmente

Get-WmiObject Win32_Service -ComputerName localhost,W-Remote -Filter "name Like 'MSSQL%'" | ft __Server,State,Name,DisplayName,StartName -AutoSize

wmic service where "name Like 'MSSQL%'" get Name , StartName