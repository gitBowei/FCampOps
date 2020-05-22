## MVA PowerShell en espaniol
## Fabian Alberto Campo
## Enero 26 de 2018

#requires -Version 2.0

<#
 	.SYNOPSIS
        Este Script soporta los modulos que presentaremos en esta sesion de MVA y quedara disponible para su consulta posterior.
        		
    .DESCRIPTION
        Este script.
		
    .EXAMPLE
        C:\PS> MVA-PoSh

#>


##Modulo 1
## PowerShell en 5 minutos

Write-Host "Powershell tiene una estructura sencilla, es una composicion de un verbo en infinitivo, un guion al medio y un sustantivo singular" -ForegroundColor Yellow

Write-Host "Por ejemplo podemos encontrar un Get-Command, un Get-Help, o un Get-Service en mas de 800 cmd-lets" -ForegroundColor Yellow

Get-Command

Write-host "Si queremos saber que esta haciendo nuestro equipo, hacemos un get-process" -ForegroundColor Yellow

Get-process

Write-Host "Si la informacion es muy extensa, como en este caso, podemos ordenarla" -ForegroundColor Yellow

Update-Help

get-help Get-Process

get-help Get-Process -full

get-help Get-Process -detailed

get-help Get-Process -examples

get-help Get-Process -Online

Get-Service

Get-Service -Name Spooler |Stop-Service

Get-Service M* |Format-List



##Modulo 2
## Command-lets y Parametros

Get-Service M* |Format-Custom

Get-Service M* |Where-Object {$_.Status -eq "Running"}

Get-Service M* |Where-Object {$_.Status -eq "Stopped"}

Get-Service | Sort-Object Status

Get-Service | Sort-Object Status |Format-Table -GroupBy Status Name, DisplayName

Get-Service |Get-Member

Get-Process |Get-Member

Get-Service Spooler |Select-Object ServicesDependedOn

Show-Command Get-Service

Stop-Service M* -WhatIf

Stop-Service M* -Confirm

##Modulo 3
## Pasando resultados con el Pipe o Piping

Get-Process |sort CPU -Descending

Get-EventLog -LogName System -EntryType Error -Newest 10

Get-EventLog -LogName System -EntryType Error -Newest 10 |fl

Get-EventLog -LogName System -EntryType Error -Newest 10 |ogv


##Modulo 4
## Variables y Scripts

$var = "Hola MVA"

$var

Write-host "$var" -ForegroundColor Yellow

Get-Variable
#podemos manejar strings
$num = 123
$num

#Podemos contener listas o arrays tambien
$num = 1,2,3
$num

$var.GetType().FullName

$var.Length

$var[1]

[int[]] $var = (1,2,3)
$var[2] = "1234"
$var[2]

$v1 = "Hello "
$v2 = "world"
$v1+$v2

($var1+$var2).Length

#Comparar con -eq -ne -gt -lt -ge -le
"Juan Perez" -eq "Ramon Valdez"


#formatos
"{0:f2}" -f 12.4

"|{0,10:C}|" -f 12.4

"{0:hh:mm}" -f (get-date)

#Scripting

Get-ExecutionPolicy

Set-ExecutionPolicy Unrestricted
Get-ExecutionPolicy

runas /user:username PowerShell
##Mas info sobre seguridad en PoSh http://technet.microsoft.com/en-us/magazine/2007.09.powershell.aspx
#------------------------
#test.ps1
#Show Hello and time

"" #Blank line
"Hello"+$Env:USERNAME +"!"
"Time is" + "{0:HH}:{0:mm}" -f (get-Date)
"" #blank line
#------------------------

#Funciones
function get-soup (
    [switch] $please,
    [String] $soup = "chicken noodle"

    )
{
    if ($please){
        "Here's your $soup soup"
    }
    else {
        "No soup for you!"
    }
}
#------------------------


##Modulo 5
## Entornos y modulos

#---------
$User = "fabian.campo@campohenriquezlab.onmicrosoft.com"

$Pass = ConvertTo-SecureString "St3ph4n13." -AsPlainText -Force

$Cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $Pass

Import-Module MSOnline

Connect-msolservice -Credential $Cred

$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/ -Credential $Cred -Authentication Basic -AllowRedirection

Import-PSSession $Session

Import-Module LyncOnlineConnector

import-module microsoft.online.sharepoint.powershell

$Session = New-CsOnlinesession -Credential $Cred

Import-PSSession $Session

[string]$tenant = get-msoldomain | where {$_.name -like "*.onmicrosoft.com" -and -not($_.name -like "*mail.onmicrosoft.com")} | select name

$tenant

$tenant3 = $tenant -split("=")

[string]$tenant4 = $tenant3[1]

$tenant4

$tenant5 = $tenant4 -split(".on")

[string]$tenant6 = $tenant5[0]



$url = "https://" + $tenant6 + "-admin.sharepoint.com"



Connect-SPOService -Url $url -credential $Cred  
#---------

##Modulo 6
## Visual Studio Code y Powershell

$VSCode = "https://code.visualstudio.com/docs/?dv=win"
New-FileDownload -SourceFile $VSCode



##Modulo 7
## Registro, Certificados y otros almacenes

Get-psprovider

Get-psDrive

New-PsDrive -Name HKCS -PSProvider Registry -Root "HKEY_CLASSES_ROOT"

cd HKCS:
dir .ht*

$process = Get-WmiObject -Class win32_Process
$item.name
foreach ($item in $process)
{
    $item.name
}
