#Hacer un inventario de software

Get-WmiObject win32_product

Get-CimInstance win32_product

Get-CimInstance win32_product | Select-Object Name, PackageName, InstallDate | Out-GridView

(Get-ADComputer -Filter * -Searchbase "OU=Test,DC=CampoHenriquez,DC=Lab").Name | Out-File C:\Temp\Computer.txt | notepad C:\Temp\Computer.txt

Get-CimInstance -ComputerName (Get-Content C:\Temp\Computer.txt) -ClassName win32_product -ErrorAction SilentlyContinue| Select-Object PSComputerName, Name, PackageName, InstallDate | Out-GridView
