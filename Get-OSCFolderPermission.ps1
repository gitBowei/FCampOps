#--------------------------------------------------------------------------------- 
#The sample scripts are not supported under any Microsoft standard support 
#program or service. The sample scripts are provided AS IS without warranty  
#of any kind. Microsoft further disclaims all implied warranties including,  
#without limitation, any implied warranties of merchantability or of fitness for 
#a particular purpose. The entire risk arising out of the use or performance of  
#the sample scripts and documentation remains with you. In no event shall 
#Microsoft, its authors, or anyone else involved in the creation, production, or 
#delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, 
#loss of business information, or other pecuniary loss) arising out of the use 
#of or inability to use the sample scripts or documentation, even if Microsoft 
#has been advised of the possibility of such damages 
#--------------------------------------------------------------------------------- 

#requires -Version "2.0"

<#
    .SYNOPSIS
        This script can be list all of shared folder permission or ntfs permission.
                        
    .DESCRIPTION
        This script can be list all of shared folder permission or ntfs permission.
                        
            .PARAMETER  <SharedFolderNTFSPermission>
                        Lists all of ntfs permission of SharedFolder.
                        
            .PARAMETER   <ComputerName <string[]>
                        Specifies the computers on which the command runs. The default is the local computer. 
                        
            .PARAMETER  <Credential>
                        Specifies a user account that has permission to perform this action. 
                        
    .EXAMPLE
        C:\PS> Get-OSCFolderPermission -NTFSPermission
                        
                        This example lists all of ntfs permission of SharedFolder on the local computer.
                        
    .EXAMPLE
                        C:\PS> $cre = Get-Credential
        C:\PS> Get-OSCFolderPermission -ComputerName "APP" -Credential $cre
                        
                        This example lists all of share permission of SharedFolder on the APP remote computer.
                        
            .EXAMPLE
        C:\PS> Get-OSCFolderPermission -NTFSPermission -ComputerName "APP" | Export-Csv -Path "D:\Permission.csv" -NoTypeInformation
                        
                        This example will export report to csv file. If you attach the <NoTypeInformation> parameter with command, it will omits the type information 
                        from the CSV file. By default, the first line of the CSV file contains "#TYPE " followed by the fully-qualified name of the object type.
#>

Param
(
            [Parameter(Mandatory=$false)]
            [Alias('Computer')][String[]]$ComputerName=$Env:COMPUTERNAME,

            [Parameter(Mandatory=$false)]
            [Alias('NTFS')][Switch]$NTFSPermission,
            
            [Parameter(Mandatory=$false)]
            [Alias('Cred')][System.Management.Automation.PsCredential]$Credential
)

$RecordErrorAction = $ErrorActionPreference
#change the error action temporarily
$ErrorActionPreference = "SilentlyContinue"

Function GetSharedFolderPermission($ComputerName)
{
            #test server connectivity
            $PingResult = Test-Connection -ComputerName $ComputerName -Count 1 -Quiet
            if($PingResult)
            {
                        #check the credential whether trigger
                        if($Credential)
                        {
                                    $SharedFolderSecs = Get-WmiObject -Class Win32_LogicalShareSecuritySetting `
                                    -ComputerName $ComputerName -Credential $Credential -ErrorAction SilentlyContinue
                        }
                        else
                        {
                                    $SharedFolderSecs = Get-WmiObject -Class Win32_LogicalShareSecuritySetting `
                                    -ComputerName $ComputerName -ErrorAction SilentlyContinue
                        }
                        
                        foreach ($SharedFolderSec in $SharedFolderSecs) 
                        { 
                            $Objs = @() #define the empty array
                                    
                    $SecDescriptor = $SharedFolderSec.GetSecurityDescriptor()
                    foreach($DACL in $SecDescriptor.Descriptor.DACL)
                                    {  
                                               $DACLDomain = $DACL.Trustee.Domain
                                               $DACLName = $DACL.Trustee.Name
                                               if($DACLDomain -ne $null)
                                               {
                                    $UserName = "$DACLDomain\$DACLName"
                                               }
                                               else
                                               {
                                                           $UserName = "$DACLName"
                                               }
                                               
                                               #customize the property
                                               $Properties = @{'ComputerName' = $ComputerName
                                                                                               'ConnectionStatus' = "Success"
                                                                                               'SharedFolderName' = $SharedFolderSec.Name
                                                                                               'SecurityPrincipal' = $UserName
                                                                                               'FileSystemRights' = [Security.AccessControl.FileSystemRights]`
                                                                                               $($DACL.AccessMask -as [Security.AccessControl.FileSystemRights])
                                                                                               'AccessControlType' = [Security.AccessControl.AceType]$DACL.AceType}
                                               $SharedACLs = New-Object -TypeName PSObject -Property $Properties
                                               $Objs += $SharedACLs

                    }
                                    $Objs|Select-Object ComputerName,ConnectionStatus,SharedFolderName,SecurityPrincipal, `
                                    FileSystemRights,AccessControlType
                }  
            }
            else
            {
                        $Properties = @{'ComputerName' = $ComputerName
                                                                       'ConnectionStatus' = "Fail"
                                                                       'SharedFolderName' = "Not Available"
                                                                       'SecurityPrincipal' = "Not Available"
                                                                       'FileSystemRights' = "Not Available"
                                                                       'AccessControlType' = "Not Available"}
                        $SharedACLs = New-Object -TypeName PSObject -Property $Properties
                        $Objs += $SharedACLs
                        $Objs|Select-Object ComputerName,ConnectionStatus,SharedFolderName,SecurityPrincipal, `
                        FileSystemRights,AccessControlType
            }
}

Function GetSharedFolderNTFSPermission($ComputerName)
{
            #test server connectivity
            $PingResult = Test-Connection -ComputerName $ComputerName -Count 1 -Quiet
            if($PingResult)
            {
                        #check the credential whether trigger
                        if($Credential)
                        {
                                    $SharedFolders = Get-WmiObject -Class Win32_Share `
                                    -ComputerName $ComputerName -Credential $Credential -ErrorAction SilentlyContinue
                        }
                        else
                        {
                                    $SharedFolders = Get-WmiObject -Class Win32_Share `
                                    -ComputerName $ComputerName -ErrorAction SilentlyContinue
                        }

                        foreach($SharedFolder in $SharedFolders)
                        {
                                    $Objs = @()
                                    
                                    $SharedFolderPath = [regex]::Escape($SharedFolder.Path)
                                    if($Credential)
                                    {           
                                               $SharedNTFSSecs = Get-WmiObject -Class Win32_LogicalFileSecuritySetting `
                                               -Filter "Path='$SharedFolderPath'" -ComputerName $ComputerName  -Credential $Credential
                                    }
                                    else
                                    {
                                               $SharedNTFSSecs = Get-WmiObject -Class Win32_LogicalFileSecuritySetting `
                                               -Filter "Path='$SharedFolderPath'" -ComputerName $ComputerName
                                    }
                                    
                                    $SecDescriptor = $SharedNTFSSecs.GetSecurityDescriptor()
                                    foreach($DACL in $SecDescriptor.Descriptor.DACL)
                                    {  
                                               $DACLDomain = $DACL.Trustee.Domain
                                               $DACLName = $DACL.Trustee.Name
                                               if($DACLDomain -ne $null)
                                               {
                                    $UserName = "$DACLDomain\$DACLName"
                                               }
                                               else
                                               {
                                                           $UserName = "$DACLName"
                                               }
                                               
                                                #customize the property
                                               $Properties = @{'ComputerName' = $ComputerName
                                                                                               'ConnectionStatus' = "Success"
                                                                                               'SharedFolderName' = $SharedFolder.Name
                                                                                               'SecurityPrincipal' = $UserName
                                                                                               'FileSystemRights' = [Security.AccessControl.FileSystemRights]`
                                                                                               $($DACL.AccessMask -as [Security.AccessControl.FileSystemRights])
                                                                                               'AccessControlType' = [Security.AccessControl.AceType]$DACL.AceType
                                                                                               'AccessControlFalgs' = [Security.AccessControl.AceFlags]$DACL.AceFlags}
                                                                                               
                                               $SharedNTFSACL = New-Object -TypeName PSObject -Property $Properties
                        $Objs += $SharedNTFSACL
                    }
                                    $Objs |Select-Object ComputerName,ConnectionStatus,SharedFolderName,SecurityPrincipal,FileSystemRights, `
                                    AccessControlType,AccessControlFalgs -Unique
                        }
            }
            else
            {
                        $Properties = @{'ComputerName' = $ComputerName
                                                                       'ConnectionStatus' = "Fail"
                                                                       'SharedFolderName' = "Not Available"
                                                                       'SecurityPrincipal' = "Not Available"
                                                                       'FileSystemRights' = "Not Available"
                                                                       'AccessControlType' = "Not Available"
                                                                       'AccessControlFalgs' = "Not Available"}
                                                           
                        $SharedNTFSACL = New-Object -TypeName PSObject -Property $Properties
                $Objs += $SharedNTFSACL
                        $Objs |Select-Object ComputerName,ConnectionStatus,SharedFolderName,SecurityPrincipal,FileSystemRights, `
                        AccessControlType,AccessControlFalgs -Unique
            }
} 

foreach($CN in $ComputerName)
{
            
            if($NTFSPermission)
            {
                        GetSharedFolderNTFSPermission -ComputerName $CN
            }
            else
            {
                        GetSharedFolderPermission -ComputerName $CN
            }
}
#restore the error action
$ErrorActionPreference = $RecordErrorAction

Final Job-inventory-shared-FS.ps1

Import-SystemModules
$Daily =(get-date -uformat %d%m%Y)
$SRV = (Hostname)
$Path = "C:\XXX\"
$Inventory = ($Path + "Base\" + "Servers.txt")
$Path2dc = "C: \XXXXXX\"
$Logo = $Path + "Image\" + "XX.jpg"
$Logo2 = $Path + "Image\" + "XXX.jpg"
$AccountSRV1 = invoke-command -computername SRV1 -scriptblock {(Get-WmiObject -Class Win32_Share -Filter "Type=0").count}
$AccountSRV2 = invoke-command -computername SRV2 -scriptblock {(Get-WmiObject -Class Win32_Share -Filter "Type=0").count}
$AccountSRV3 = invoke-command -computername SRV1 -scriptblock {(Get-WmiObject -Class Win32_Share -Filter "Type=0").count}
$AccountSRVSummanry = ($AccountSRV1 + $AccountSRV2 + $AccountSRV2)

$report = $Path + "Inventory-Shared-FBP-Owner-" + $Daily +".htm"
$report2 = $Path + "Inventory-Shared-FBP-Permissions-" + $Daily +".htm"
$report3 = $Path + "Inventory-Shared-FBP-Size-" + $Daily +".htm"

$style = "<style>"
$style = $style + “BODY{font-family: Segoe UI Light; font-size: 10pt; Text-align:Center;}”
$style = $style + “TABLE{border: 1px solid black; border-collapse: collapse;}”
$style = $style + “TH{border: 1px solid black; background: #0080ff; padding: 5px;}”
$style = $style + “TD{border: 1px solid black; padding: 5px;}”
$style = $style + “”
$style = $style + "</style>"

invoke-command -computername (get-content $Inventory) -scriptblock {Get-WmiObject -Class Win32_Share -Filter "Type=0" |
    Select-Object @{"Label"="Nombre del Servidor";"Expression"={$_.__SERVER}}, `
    @{"Label"="Nombre de la carpeta";"Expression"={$_.Name}}, `
    @{"Label"="Estado de conexion";"Expression"={$_.Status}}, `
    @{"Label"="Ruta";"Expression"={$_.Path}}, `
    @{"Label"="Propietario";"Expression"={$_.Description}}} | Sort-Object @{expression=”Score”;Descending=$true},@{expression="Nombre de la carpeta";Ascending=$true} | select "Nombre del Servidor","Nombre de la carpeta","Estado de conexion","Propietario","Ruta","Tamaño (GB)" | ConvertTo-Html -head $style "Nombre del Servidor","Nombre de la carpeta","Estado de conexion","Propietario","Ruta","Tamaño (GB)"  -title "Inventario de Carpeta Compartida tipo Negocio o Personal con informacion de propietario" "<H2>Inventario de Carpeta Compartida tipo Negocio o Personal con informacion de propietario | Generado el $((get-date -f d-MM-yyyy).ToString()).</H2>" | Set-Content $report

Path\ListAllSharedFolderPermission.ps1 -ComputerName (get-content $Inventory) | ? {$_.SecurityPrincipal -notlike "Netbios Domain\Domain Admins"} |
    Select-Object @{"Label"="Nombre del Servidor";"Expression"={$_.ComputerName}}, `
    @{"Label"="Nombre de la carpeta";"Expression"={$_.SharedFolderName}}, `
    @{"Label"="Grupos de Control y Accesso";"Expression"={$_.SecurityPrincipal}}, `
    @{"Label"="Tipo de Permiso";"Expression"={$_.FileSystemRights}} | Sort-Object @{expression=”Score”;Descending=$true},@{expression="Nombre de la carpeta";Ascending=$true} | select "Nombre del Servidor","Nombre de la carpeta","Grupos de Control y Accesso","Tipo de Permiso" | ConvertTo-Html -head $style "Nombre del Servidor","Nombre de la carpeta","Grupos de Control y Accesso","Tipo de Permiso" -title "Inventario de Carpeta Compartida tipo Negocio o Personal con informacion de Permisos" "<H2> Inventario de Carpeta Compartida tipo Negocio o Personal con informacion de Permisos | Generado el $((get-date -f d-MM-yyyy).ToString()).</H2>" | Set-Content $report2

$Share = (Get-WmiObject -Class Win32_Share -Filter "Type=0" | select path)
$Share | foreach {get-item -path $_.path |
    select-Object @{"Label"="Letra";"Expression"={$_.Root}}, `
    @{"Label"="Ruta";"Expression"={$_.FullName}}, `
    @{"Label"="Fecha de creacion";"Expression"={(get-date ([datetime]$_.CreationTime) -uformat %d%/%m%/%Y)}}, `
    @{"Label"="Ultimo acceso";"Expression"={(get-date ([datetime]$_.LastAccessTime) -uformat %d%/%m%/%Y)}}, `
    @{"Label"="Ultima fecha de escritura";"Expression"={(get-date ([datetime]$_.LastWriteTime) -uformat %d%/%m%/%Y)}}, `
    @{"Label"="Tamaño (GB)";"Expression"={"{0:N2}" -f ((Get-ChildItem $_.FullName -Recurse | Measure-Object -Property Length -Sum ).Sum / 1GB )}}} | select "Letra","Ruta","Fecha de creacion","Ultimo acceso","Ultima fecha de escritura","Tamaño (GB)" | ConvertTo-Html -head $style "Letra","Ruta","Fecha de creacion","Ultimo acceso","Ultima fecha de escritura","Tamaño (GB)" -title "Inventario de Carpeta Compartida tipo Negocio o Personal CUSI01" "<H2>Inventario de Carpeta Compartida tipo Negocio o Personal CUSI01 | Generado el $((get-date -f d-MM-yyyy).ToString()).</H2>" | Set-Content $report3
         
$smtpServer = “mail.col.loc”
$smtpFrom = "Remitente@domain.internal>"
$smtpTo = "Destinatario@domain.interna"
$messageSubject = "Reporte diaro | Inventario de Carpeta Compartida tipo Negocio o Personal | $((get-date -f d-MM-yyyy).ToString()) "
$Attach = "$logo","$logo2","$report","$report2","$report3"

$style = "<style>"
$style = $style + “BODY{font-family: Segoe UI Light; font-size: 10pt; Text-align:Center;}”
$style = $style + “TABLE{border: 1px solid black; border-collapse: collapse;}”
$style = $style + “TH{border: 1px solid black; background: #0080ff; padding: 5px;}”
$style = $style + “TD{border: 1px solid black; padding: 5px;}”
$style = $style + “”
$style = $style + "</style>"

$message = ""
$message += "<p align=center><img src=XXXXXX.jpg /><br>"
$message += "<font size=""2"" face=""Segoe UI Light,sans-serif"">"
$message += "<h3 align=""center""> Reporte diario | Inventario de Carpeta Compartida tipo Negocio o Personal | Generado $((get-date -f d-MM-yyyy).ToString())</h3>"
$message += "</font>"

$style1 = "<style>"
$style1 = $style1 + “BODY{font-family: Segoe UI Light; font-size: 10pt; Text-align:Center;}”
$style1 = $style1 + “TABLE{border: 1px solid black; border-collapse: collapse;}”
$style1 = $style1 + “TH{border: 1px solid black; background: #0080ff; padding: 5px;}”
$style1 = $style1 + “TD{border: 1px solid black; padding: 5px;}”
$style1 = $style1 + “”
$style1 = $style1 + "</style>"

$message += "<font size=""1"" face=""Arial,sans-serif"">"
$message += "<h5 align=""center"">Estado de Almacenamiento de carpetas compartidas en los servidores Srv1, Srv2 y Srv3 $Daily30 </h5>"
$message += ""
$message +=invoke-command -computername (get-content $Inventory) -scriptblock {Get-WmiObject -Class Win32_LogicalDisk |
    Where-Object {$_.DriveType -ne 5 -and $_.Name -notmatch '^A:|C:$'} |
    Select-Object @{"Label"="Nombre del servidor";"Expression"={hostname}}, `
    @{"Label"="Letra";"Expression"={$_.Name}}, `
    @{"Label"="Tamano del disco (GB)";"Expression"={"{0:N}" -f ($_.Size/1GB) -as [float]}}, `
    @{"Label"="Espacio Usado (GB)";"Expression"={"{0:N}" -f ($_.Size/1GB - $_.FreeSpace/1GB) -as [float]}}, `
    @{"Label"="Espacio Libre (GB)";"Expression"={"{0:N}" -f ($_.FreeSpace/1GB) -as [float]}}, `
    @{"Label"="Espacio Libre en Porcentaje (%)";"Expression"={"{0:N}" -f ($_.FreeSpace/$_.Size*100) -as [float]}} } | Sort-Object -descending "Nombre del servidor"| select "Nombre del servidor","Letra","Tamano del disco (GB)","Espacio Usado (GB)","Espacio Libre (GB)","Espacio Libre en Porcentaje (%)" | ConvertTo-Html -Head $style1
$message += ""
$message += "<h5 align=""center"">Numero de carpetas compartidas en los servidores Srv1, Srv2 y Srv3 $Daily30 </h5>"
$message += "<h5 align=""center"">Total de carpetas Srv1: $AccountSRVBOGIS04 </h5>"
$message += "<h5 align=""center"">Total de carpetas Srv2: $AccountSRVBOGIS06 </h5>"
$message += "<h5 align=""center"">Total de carpetas Srv3: $AccountSRVCUSIS01 </h5>"
$message += "<h5 align=""center"">Total: $AccountSRVSummanry </h5>"
$message += "</font>"
$message += ""
$message += "<font size=""2"" face=""Segoe UI Light,sans-serif"">"
$message += "<h5 align=center>$Ms</h5>"
$message += "<p align=center><img src=XXX.jpg /><br>"
$message += ""
$message += ""
send-mailmessage -from $smtpFrom -to $smtpTo -smtpserver $smtpserver -subject $messageSubject -body $message -BodyAsHtml -attachments $Attach -Priority high
