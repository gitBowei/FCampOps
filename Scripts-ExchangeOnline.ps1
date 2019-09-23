#Conectarse a Exchange Online
$LiveCred = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/ -Credential $Cred -Authentication Basic -AllowRedirection

Import-PSSession $Session
#********************************************************************
#Conectarse a MSOnline
#Conectar MSOLUser
$cred=Get-Credential
Connect-MsolService -Credential $cred
#********************************************************************
#Para generar una tabla con formato HTML de las actualizaciones instaladas
wmic qfe list full /format:htable> hotfixes_%computername%.htm
### para activar un Windows
cscript c:\windows\system32\slmgr.vbs -ato
#**********************************************************************
Connect-SPOService -Url https://contoso-admin.sharepoint.com-credentialadmin@contoso.com

#**********************************************************************
Get-Mailbox <Mailbox to Check> | Get-MailboxPermission -User <Active Directory User>
#**********************************************************************
#Do you want to know what version of Exchange Server each of your servers is running? Type:
Get-ExchangeServer | Format-Table Name, *Version*
#**********************************************************************
New-Mailbox -Name $SharedMailboxDisplayName -Alias $SharedMailboxAlias -Shared -PrimarySMTPAddress $SharedMailboxUserName
}
#PrimarySMTPAddress LookCyzone@cyzone.com -office "Mensaje Luis Salcedo"
#PrimarySMTPAddress mensajecoo@belcorp.bizoffice "Mensaje Luis Salcedo"
#Se creo el buzon Compartido sacpis@belcorp.biz, se delegan privilegios de administracion total a la usuaria Adelinda Patricia Collazos Rojas de Revilla Alias:acollazos. Los demas usuarios NO Existen. De ser necesario una nueva delegacion por favor enviar los Display Name o LogOnName de las cuentas y abrir un nuevo requerimiento.
#Se escala para configuración.
#Se asignan privilegios de adminsitracion sobre la cuenta ar.tiendavirtual@lbel.com al usuario MarcelaGutierrez@belcorp.biz. Las cuentas pe.contactoesika y pe.contactocyzone NO se encuentran por favor enviar el Display de las cuentas para gestionar la solicitud.
#**********************************************************************
Get-RecipientPermission -Trustee joe@xyzcorp.com 
Set-RecipientPermission -identity joe@xyzcorp.com -User pemcervera@xyzcorp.com -AccessRights FullAccess
Remove-MailboxPermission tiendavirtualperu -User rguillen -AccessRights FullAccess
#RecipientPermission mensajecoo@belcorp.bizTrustee pemcervera@belcorp.bizAccessRights SendAs
Remove-RecipienTPermission tiendavirtualperu -Trustee rguillen -AccessRights SENDAS
Add-MailboxPermission bjimenez@belcorp.bizAccessRights FullAccess
Add-RecipientPermission ARESCRIBENOS -Trustee  dandrada -AccessRights SendAs
#Se creo la cuenta de correo compartida, sacpis@belcorp.biz con privilegios de adminsitracion para el usuario jxsierra. El mismo puede enviar mensajes desde dicho buzon. Se transfiere a sitio para configuracion.
#Se asignan privilegios de adminsitracion sobre la cuenta soporte_correo@belcorp.biz al usuario  japalomino, de acuerdo a la solicitud. El mismo puede enviar mensajes desde dicho buzón. Se transfiere a sitio para configuración.
#**********************************************************************
#Deshabilitación del acceso a un buzón de correo
Set-CASMailbox <Identity> -OWAEnabled $false -PopEnabled $false -ImapEnabled $false -MAPIEnabled $false -ActiveSyncEnabled $false -EwsEnabled $false
#Ejemplo:
Set-CASMailbox "Dirección de Ventas MX" -OWAEnabled $false -PopEnabled $false -ImapEnabled $false -MAPIEnabled $false -ActiveSyncEnabled $false -EwsEnabled $false
#Para volver a habilitar el acceso al buzón de correo, simplemente ejecute el mismo comando, pero establezca el valor del parámetro en $true en lugar de $false.
#**********************************************************************
#Modificar SMTP
Set-Mailbox -Name "PA.Sala Piso 24"-Alias PASalaPiso24 -EmailAddresses SMTP:PaSalaPiso24@belcorp.biz
#**********************************************************************
Get-MailboxPermission PESDESK -User CSALOMON
Get-RecipientPermission Sandra Perez Botero
#**********************************************************************
Get-Mailbox saerez@belcorp.biz | Select-Object DisplayName,Alias,PrimarySmtpAddress,RecipientType,RecipientTypeDetails
#*********************************************************************
#Reportes
Get-MailBox -Filter '(RecipientTypeDetails -eq "SharedMailbox")' | select RecipientTypeDetails,DisplayName, Alias, PrimarySmtpAddress | Export-Csv E:\ECS\sharedmailbox11mar.csv
#listado de usuarios sharedmailbox
#*- Ultimo logueo y Tamaño de Buzon
Get-Mailbox -ResultSize unlimited | Get-MailboxStatistics | ft DisplayName,itemcount,totalitemsize,lastlogontime -AutoSize -Wrap > "E:\ECS\Reportes\Reporte.csv" -Verbose
Get-Mailbox -ResultSize unlimited | Get-MailboxStatistics |ft DisplayName,ItemCount,TotalItemSize,LastLogonTime -AutoSize -Wrap | Export-Csv E:\ECS\LastLogonTime05abril.csv -Verbose -NoTypeInformation
Get-MailboxStatistics -ResultSize unlimited | Select displayname, lastlogontime | Export-Csv E:\ECS\lastlogon05.abr.csv -NoTypeInformation
Get-Mailbox -ResultSize Unlimited |Get-MailboxStatistics
last logon(verificado)
Get-Mailbox -ResultSize Unlimited | Get-MailboxStatistics | Select displayname, lastlogontime | Export-Csv E:\ECS\lastlogon05.abr.csv -NoTypeInformation -Verbose
#tamaño(verificado)
Get-Mailbox -ResultSize unlimited | Get-MailboxStatistics | Select-Object DisplayName,TotalItemSize,ItemCount | Export-Csv "E:\ECS\MailboxSizeReport05abr.csv" -Verbose
#lastlogon+tamaño(verificado)
Get-Mailbox -ResultSize unlimited | Get-MailboxStatistics | Select-Object DisplayName,TotalItemSize,ItemCount, lastlogontime | Export-Csv "E:\ECS\prueba.csv" -NoTypeInformation -Verbose
#**********************************************************************
Import-Module MsOnline

Connect-MsolService
Get-Msoluser -UserPrincipalName dilshansam@valakulu.net 


Get-MsolAccountSku

New-MsolUser -UserPrincipalName dilshansam@valakulu.netPassword Password1
Get-MsolAccountSku | Where-Object {$_.SkuPartNumber -eq 'ENTERPRISEPACK'} |
ForEach-Object {$_.ServiceStatus}
$options = New-MsolLicenseOptions -AccountSkuId msdivision:ENTERPRISEPACK -DisabledPlans MCOSTANDARD,SHAREPOINTWAC,SHAREPOINTENTERPRISE
Set-MsolUserLicense -UserPrincipalName dilshansam@valakulu.net -LicenseOptions $options
#*************
#Buscar Mensajes en la nube
Search-MessageTrackingReport -Identity "zarela.carvajal" -Sender "test.bpos@nuevaeps.com.co" -ByPassDelegateChecking -DoNotResolve | ForEach-Object { Get-MessageTrackingReport -Identity $_.MessageTrackingReportID -DetailLevel Verbose -BypassDelegateChecking -DoNotResolve -RecipientPathFilter "zarela.carvajal@nuevaeps.com.co" -ReportTemplate RecipientPath }
#***********
#Compartir Calendario
#For example:
#This example assigns permissions for Anna to access John's calendar mailbox folder and applies the readitems role to her access of that folder
Identity john@contoso.com:\CalendarUser anna@contoso.com 
#For more information about add mailbox folder permission, please refer to the article below:
Add-MailboxFolderPermission
#http://technet.microsoft.com/en-us/library/dd298062.aspx

#***********
#Importar Bulk..
Import-Csv -Path c:\users.csv | ForEach-Object {New-MsolUser -FirstName $_.FirstName -LastName $_.LastName -UserPrincipalName $_.UserPrincipalName -DisplayName "$($_.FirstName) $($_.LastName)" -LicenseAssignment ‘msdivision:ENTERPRISEPACK’ -UsageLocation US } | Export-Csv -Path c:\NewUsers.csv –NoTypeInformation
#***************
#Reporte de licencias MSOL
Get-MsolUser | Where-Object {$_.isLicensed -eq “TRUE”} | Export-Csv c:\path\AllUsersWithLicenses.CSV
#---- O ---
#Script to retrieve a licensing report from Office 365 and output it to CSV
# Copyright Microsoft @ 2012
# DISCLAIMER
# The sample scripts are not supported under any Microsoft standard support program or service.
# The sample scripts are provided AS IS without warranty of any kind.
# Microsoft further disclaims all implied warranties including, without limitation,
# any implied warranties of merchantability or of fitness for a particular purpose.
# The entire risk arising out of the use or performance of the sample scripts and documentation remains with you.
# In no event shall Microsoft, its authors, or anyone else involved in the creation, production,
# or delivery of the scripts be liable for any damages whatsoever (including, without limitation,
# damages for loss of business profits, business interruption, loss of business information,
# or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation,
# even if Microsoft has been advised of the possibility of such damages.
 
# change the username to a admin account in your tenant i.e. admin@contos.onmicrosoft.com 

$Username="usernotset"
# to set a new password delete this script and run SetupScript.ps1 again.
$pass="passnotset"
 
# check if the password and user are set to something
if(($pass -contains"notset")-or($Username -contains"notset"))
{
"You need to set your username and/or create an encrypted password for the admin account specified in this script before continuing."
Exit 2
}
 
# load the MSOnline PowerShell Module
# verify that the MSOnline module is installed and import into current powershell session
If (!([System.IO.File]::Exists(("{0}\modules\msonline\Microsoft.Online.Administration.Automation.PSModule.dll"-f $pshome))))
{
Write-EventLog -LogName Application -EntryType Error -EventId 99 -Source O365LicenseUpdate -Message"The Microsoft Online Services Module for PowerShell is not installed. The Script cannot continue."
write-log"Please download and install the Microsoft Online Services Module."
Exit 99
}
$getModuleResults = Get-Module
If (!$getModuleResults) {Import-Module MSOnline -ErrorAction SilentlyContinue}
Else {$getModuleResults | ForEach-Object {If (!($_.Name -eq"MSOnline")){Import-Module MSOnline -ErrorAction SilentlyContinue}}}
write-Eventlog -logname Application -Entrytype information -EventId 0 -source O365LicenseUpdate -message 'MSOnline module imported'
 
# create the password from the encrypted string and setup the credential object
$password = ConvertTo-SecureString $pass
$cred = New-Object -typename System.Management.Automation.PSCredential -argumentlist $Username,$password
$er =""
 
# Connect to Microsoft Online Service
Connect-MsolService -Credential $cred -errorAction silentlyContinue -errorvariable $er
if ($er -ne""){
# handle any logon errors
$message6 = 'Could not log on O365 with ' + $($Username) + ' to create your licensing report ' + $er
write-Eventlog -logname Application -Entrytype error -EventId 6 -source O365LicenseUpdate -message $message6
exit
}
else {
write-Eventlog -logname Application -Entrytype information -EventId 0 -source O365LicenseUpdate -message 'Logged In'
}
 
$outFile="licenses_{0:yyyyMMdd-HHmm}.csv"-f (Get-Date)
$users = Get-MsolUser -all
$header ="userPrincipaName,usageLocation,isLicensed,accountSKUid,servicePlan1,provisioningStatus1,servicePlan2,provisioningStatus2,servicePlan3,provisioningStatus3,servicePlan4,provisioningStatus4,servicePlan5,provisioningStatus5"
Out-File -FilePath $outfile -InputObject $header
 
foreach($usr in $users)
{
 
$lineOut=$usr.UserPrincipalName +","+ $usr.usageLocation +","+ $usr.isLicensed +","
foreach($lic in $usr.Licenses)
{
$lineOut = $lineOut + $lic.AccountSkuID
foreach($s in $lic.ServiceStatus)
{
$lineout = $lineout + $s.ServicePlan.ServiceName +","+ $s.ProvisioningStatus +","
}
}
Out-File -FilePath $outfile -Append -NoClobber -InputObject $lineOut
$lineOut = $null
}
 
Write-Host -ForeGroundColor yellow"Please review your output file at "$outFile
#*************************************************************
#Powershell
#Medir el tamaño de una carpeta remota.
((Get-ChildItem\\remoteServer\C$-Recurse) |Measure-Object -Sum Length).sum
Get-ChildItem\\remoteServer\C$-Recurse -Force
#Logs
get-eventlog -logname application | where { $_.timegenerated -gt [datetime]"2/28/12"} |measure
get-process| where{$_.pm -gt 20MB}
#Crear una maquina en Hyper-V
Create-VM -Name "VM01" -VirtualHardDisk $VHD -VMHost $VMHost -Path "C:\MyVMs"
dsquery user -inactive 7 | dsmod user -disabled yes
gwmi Win32_PhysicalMemory | select BankLabel,Capacity,DataWidth,DeviceLocator,MemoryType
get-wmiobject Win32_ComputerSystem | select @{name="TotalPhysicalMemory(MB)";expression={($_.TotalPhysicalMemory/1mb).tostring("N0")}},NumberOfProcessors
#*********************************************************
#Barra de progreso mientras copia...
#---------------------------------------------------------------------------------------------#
#--Script to copy files from one location to another with a cool Progressbar --#
# If you want to test it - Change the source path and target path with a relevant directory
# in your computer -
# $SOURCE_PATH
# $TARGET_PATH
#---------------------------------------------------------------------------------------------#
# Note : The script will copy only files from source to target, please use it carefully
# if the low disk space problem in target drive.
# Do not use C:\ drive or drive where Operating system in installed.
#---------------------------------------------------------------------------------------------#
$SOURCE_PATH="\\10.27.9.120\c$\Users\co1073152864.SYNAPSISIT"
$TARGET_PATH = "C:\Users\co80021375\Music"
$FILES_COLLECTION=ls
$SOURCE_PATH | where { $_.Mode -notcontains "d----" } | foreach { $_.FullName}
$FILES_COUNT=$FILES_COLLECTION.count for ( $t =0; $t -lt $FILES_COUNT ; $t++)  {$status = [int] (($t/$FILES_COUNT) * 100)
#--Get the full-file name and only leaf name of the file --#
$THIS_FILE_FULL_NAME = $FILES_COLLECTION[$t]
$THIS_FILE_NAME = Split-Path
$THIS_FILE_FULL_NAME -leaf
#--Set the target location --3
$THIS_FILE_TARGET = "${TARGET_PATH}\${THIS_FILE_NAME}"
#--write progress with progressbar --#
Write-Progress -id 1 -Activity "File-Copy Status - [$status]" -Status "Copying to $THIS_FILE_NAME to $TARGET_PATH " -PercentComplete $status#--Copy Step --#  Copy-Item $THIS_FILE_FULL_NAME $THIS_FILE_TARGET }
#---------------------------------------------------------------------------------------------#
# End of Code
#---------------------------------------------------------------------------------------------#
Enviar un SMTP desde PS.
$SENDER="mssqlmailac@foo.com"
$MAIL_SERVER="foo.com"
$NOTIFY_ID="som@foo.com"
$SUBJECT="This is Subject"
$MAIL_BODY="This is testing only"
$SMTP = new-object
Net.Mail.SmtpClient(${MAIL_SERVER})
$MSG = New-Object
System.Net.Mail.MailMessage "${SENDER}", "${NOTIFY_ID}", "${SUBJECT}" ,
${MAIL_BODY}
#--Adding this line would send HTML
formatted mail --#
$MSG.IsBodyHTML = $TRUE
$SMTP.Send($MSG)
#*********************************************************
#Reproducir un sonido por MP desde PS.
#--Initialize Object --#
$sound = new-Object System.Media.SoundPlayer
#--Modify the wav filename --#
$sound.SoundLocation="c:\WINDOWS\Media\notify.wav"$sound.Play()$sound.Stop()
#**********************************************************
#Mostrar el UPtime
clear
$uptime=net stats srv | where {$_ -match "since"} | foreach {$_.replace("Statistics since","") } |
foreach { $($((Get-Date) - (Get-Date $_)).Days).tostring().padleft(3,"0").tostring() + ":" +
$($((Get-Date) - (Get-Date $_)).Hours).tostring().padleft(2,"0").tostring() + ":" +
$($((Get-Date) - (Get-Date $_)).Minutes).tostring().padleft(2,"0").tostring() + ":" +
$($((Get-Date) - (Get-Date $_)).Seconds).tostring().padleft(2,"0").tostring()
} | foreach { $_.replace(" ", "") }
echo "Uptime of Host [$(hostname)]`t: $uptime (DD:HH:MM:SS)"
Ciclo cada 5 seg,
while ($true) {
Start-Sleep -s 5
cls
‘CPU Load is’
Get-WmiObject win32_processor | select LoadPercentage  |fl
}

#-------------------------------------------------------------------------------------------------
#Enviar MSG con Attachment
Add-PSSnapin Microsoft.Exchange.Management.Powershell.Admin -erroraction silentlyContinue
$file = "C:\folder\file.csv"
$mailboxdata = (Get-MailboxStatistics | select DisplayName, TotalItemSize,TotalDeletedItemSize, ItemCount, LastLoggedOnUserAccount, LastLogonTime)
$mailboxdata | export-csv "$file"
$smtpServer = "127.0.0.1"
$att = new-object Net.Mail.Attachment($file)
$msg = new-object Net.Mail.MailMessage
$smtp = new-object Net.Mail.SmtpClient($smtpServer)
$msg.From = "emailadmin@test.com"
$msg.To.Add("administrator1@test.com")
$msg.To.Add("administrator2@test.com")
$msg.Subject = "Notification from email server"
$msg.Body = "Attached is the email server mailbox report"
$msg.Attachments.Add($att)
$smtp.Send($msg)
$att.Dispose()

#-------------------------------------------------------------------------------------------------
#Mostrar Dialogo emergente
[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[System.Windows.Forms.MessageBox]::Show("We are proceeding with next step." , "Status" , 4)
#--------------------------------------------------------------------------------------------------
#Force directory synchronization using Windows PowerShell
#You can use the directory synchronization Windows PowerShell cmdlet to force synchronization. The cmdlet is installed when you install the Directory Sync tool.
#1.On the computer that is running the Directory Sync tool, navigate to the directory synchronization installation folder. By default, it is located here: %programfiles%\Microsoft Online Directory Sync.
#2.Double-click DirSyncConfigShell.psc1 to open a Windows PowerShell window with the cmdlets loaded.
#3.In the Windows PowerShell window, type Start-OnlineCoexistenceSync, and then press ENTER.

#Scripts Exchange
#Este elimina unos mensajes con contenido especifico de toda la organizacion o por cuenta
Get-Mailbox -Server SRVBOGEX2K7 -ResultSize Unlimited | Export-Mailbox
-SubjectKeywords "RV: favor especial" -IncludeFolders "\Inbox" -StartDate
"08/15/2012" -EndDate "08/15/2012" -DeleteContent -TargetMailbox AVianca
\DMG -TargetFolder DeleteMsgs -Confirm:$false
 
Get-Mailbox | Export-Mailbox -ContentKeywords "RV: favor especial"
-DeleteContent
 
Get-Mailbox -Server SRVBOGEX2K7 | Export-Mailbox -Identity "SRAMIREZ"
-TargetMailbox DGutierrez -TargetFolder ” ToDelete” -SenderKeywords
comunicacionesinternas@aviancataca.comRV: favor
especial” –StartDate “08/15/2012" –EndDate “08/15/2012" –DeleteContent
–MaxThreads 10
 
Get-Mailbox -Server SRVBOGEX2K7 | Export-Mailbox -Identity "SRAMIREZ"
-SubjectKeywords ”RV: favor especial” –StartDate “08/15/2012" –EndDate
“08/15/2012" –DeleteContent –MaxThreads 10
 
Get-Mailbox -database "MS07DB5" -ResultSize Unlimited | Export-Mailbox
-SubjectKeywords "RV:favor especial" -IncludeFolders "\Bandeja de entrada"
-StartDate "08/15/2012" -DeleteContent -Confirm $false
 
Get-Mailbox -database "MS07DB5" -ResultSize Unlimited | Export-Mailbox
-SubjectKeywords "RV: favor especial" -IncludeFolders "\Bandeja de entrada"
-StartDate "08/15/2012" -DeleteContent -TargetMailbox Dgutierrez
-TargetFolder Encontrados -Confirm $false 
 
Get-Mailbox -identity "cpalomino" -ResultSize Unlimited | Export-Mailbox
-SubjectKeywords "RV: favor especial" -SenderKeywords
comunicacionesinternas@aviancataca.com -IncludeFolders "\Sent Items"
-StartDate "08/15/2012" -DeleteContent -TargetMailbox dgutierrez
-TargetFolder ultimos -Confirm false
 
#"Get-Mailbox -identity ""DomainAdmin"" -ResultSize Unlimited |
#Export-Mailbox -SubjectKeywords ""RV: favor especial"" -IncludeFolder
#s ""\Bandeja de entrada"" -StartDate ""08/15/2012"" -DeleteContent
#-TargetMailbox Dgutierrez
#-TargetFolder ultimos1 -Confirm:$false -Baditemlimit 1000"
#Get-Mailbox -identity "RQUIJANO" -ResultSize Unlimited | Export-Mailbox
#-SubjectKeywords "RV: favor especial" -IncludeFolders "\Bandeja de entrada"
#-StartDate "08/15/2012" -DeleteContent -TargetMailbox Dgutierrez
#-TargetFolder RQUIJANO -Confirm:$false -Baditemlimit 1001
#"Get-Mailbox -identity ""AAETEAGA"" -ResultSize Unlimited | Export-Mailbox
#-SubjectKeywords ""RV: favor especial"" -IncludeFolder
#s ""\Bandeja de entrada"" -StartDate ""08/15/2012"" -DeleteContent
#-TargetMailbox Dgutierrez
#-TargetFolder ultimos1 -Confirm:$false -Baditemlimit 1002"
 
 
Get-Mailbox -Database "MS07DBINTERMEDIOS" -ResultSize Unlimited |
Export-Mailbox -SubjectKeywords "RV: favor especial" -IncludeFolders
"\Inbox" -StartDate "08/14/2012" -EndDate "08/16/2012" -DeleteContent
-TargetMailbox Dgutierrez -TargetFolder MS07DBINTERMEDIOS2 -Confirm:$false
-Baditemlimit 1000
 
Add-MailboxPermission –Id <UserMailbox> –User <Account to have permissions>
–AccessRights ‘Full Access’ –Confirm:$false

Set-Mailbox -Identity John -DeliverToMailboxAndForward $true -ForwardingSMTPAddress manuel@contoso.com 
 
#Asignarse permisos para importar y exportar
 
New-ManagementRoleAssignment -Role "Mailbox Import Export" -User clarota
 
#Realizar un backup de un .PST
 
New-MailboxExportRequest -Mailbox ssierra -FilePath \\SEXC01\PST\ssierra.pst

 
#Ver el tamaño del buzon especifico
 
Get-MailboxStatistics -Identity "mcampo"
 
#Ver el tamaño del buzon completo
 
Get-MailboxStatistics -Server SEXC01 | Sort-Object TotalItemSize –Descending | Format-List > c:\PST\size.csv
 
#Certificado Digital
 
Get-SendConnector | fl fqdn
 
Get-ExchangeCertificate | fl CertificateDomains
 
Get-ExchangeCertificate | fl thumbprint, services
 
Enable-ExchangeCertificate -Thumbprint 74A8901B9A60E59DEA024B0F3B2B42146AE8E439 -Services IMAP, POP, IIS, SMTP
 
Get-ExchangeCertificate | fl thumbprint, status, notafter
 
Add-MailboxPermission -Identity 'CN=Carolina Alejandra La Rota Nino,OU=Administradores,OU=Administracion,OU=Cuentas,DC=mincomunicaciones,DC=gov,DC=co' -User 'MINCOM\clarota' -AccessRights 'FullAccess'
 
 
#Lista un usuario 
 
 
get-user -identity besadmin | list
 
 
#Auditar un usuario
 
Set-Mailbox -Identity "Diego Molano Vega" -AuditEnabled $true
 
#Ver la auditoria
 
Search-MailboxAuditLog -Identity besadmin -LogonTypes Admin,Delegate -StartDate 8/7/2011 -EndDate 12/7/2011 -ResultSize 2000
 
 
#Ver tamaños de los buzones
 
Get-Mailbox | Get-MailboxStatistics | Sort-Object TotalItemSize –Descending | ft DisplayName,TotalItemSize,ItemCount,database | Format-List > c:\PST\file.csv
 
 
#Ver listado detallado de propiedades de cuentas, buzones y demas
 
Get-User -RecipientTypeDetails UserMailbox | Select-Object DisplayName,UserAccountControl, WindowsEmailAddress, WhenChanged, WhenCreated, Database, IssueWarningQuota, RulesQuota, SamAccountName, ProhibitSendQuota, Office  | Format-List > c:\PST\listado.csv
 
Get-Mailbox -identity jmedellin | list  | select-object  -IssueWarningQuota
 
Get-RoleGroupMember “View-Only Organization Management” 
 
Add-RoleGroupMember “View-Only Organization Management” -Member dirsync
 
Add-RoleGroupMember “Organization Management” -Member dirsync
 
Get-OrganizationConfig | Add-ADpermission -User dirsync -ExtendedRights “ms-Exch-Store-Admin”,“Send As”, “Receive As”
 
Get-OrganizationConfig | Get-AdPermission –User dirsync
 
Get-MailboxDatabase | Add-ADPermission –User dirsync –ExtendedRights “send as”, “receive as”,“ms-Exch-Store-Admin”

Get-MailboxDatabase | Get-AdPermission –User dirsync
 
#Exportar las IP de los conectores de relay.
 
(Get-ReceiveConnector "myrelay").RemoteIPRanges | select Lowerbound,Upperbound,RangeFormat | export-csv c:\rc.txt -NoTypeInformation

New-ReceiveConnector "WWB-Relay" -Server SRVWPRAPMAIL01 -Bindings 0.0.0.0:25 -RemoteIPRanges (Get-ReceiveConnector "SRVWWBMAIL01\Helpdesk").RemoteIPRanges

(Get-MoveRequest -MoveStatus Queued).count

$userlist = get-content .\usuariosK1.txt |foreach ( $user in $userlist ) {Get-ADUser "$user" -Properties Name, DistinguishedName| Select-Object Name, DistinguishedName}

#------------------------------------------
#Conectarse a Exchange Online
$LiveCred = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/ -Credential $Cred -Authentication Basic -AllowRedirection

Import-PSSession $Session
#********************************************************************
#Conectarse a MSOnline
Conectar MSOLUser
$cred=Get-Credential
Connect-MsolService -Credential $cred


#********************************************************************
#Para generar una tabla con formato HTML de las actualizaciones instaladas
wmic qfe list full /format:htable> hotfixes_%computername%.htm
### para activar un Windows
cscript c:\windows\system32\slmgr.vbs -ato
#**********************************************************************
Connect-SPOService -Url https://contoso-admin.sharepoint.com-credentialadmin@contoso.com

#**********************************************************************
Get-Mailbox <Mailbox to Check> | Get-MailboxPermission -User <Active Directory User>
#**********************************************************************
#Do you want to know what version of Exchange Server each of your servers is running? Type:
Get-ExchangeServer | Format-Table Name, *Version*

#**********************************************************************
New-Mailbox -Name $SharedMailboxDisplayName -Alias $SharedMailboxAlias -Shared -PrimarySMTPAddress $SharedMailboxUserName
}
PrimarySMTPAddress LookCyzone@cyzone.com -office "Mensaje Luis Salcedo"
PrimarySMTPAddress mensajecoo@belcorp.bizoffice "Mensaje Luis Salcedo"
Se creo el buzon Compartido sacpis@belcorp.biz, se delegan privilegios de administracion total a la usuaria Adelinda Patricia Collazos Rojas de Revilla Alias:acollazos. Los demas usuarios NO Existen. De ser necesario una nueva delegacion por favor enviar los Display Name o LogOnName de las cuentas y abrir un nuevo requerimiento.
Se escala para configuración.
Se asignan privilegios de adminsitracion sobre la cuenta ar.tiendavirtual@lbel.com al usuario MarcelaGutierrez@belcorp.biz. Las cuentas pe.contactoesika y pe.contactocyzone NO se encuentran por favor enviar el Display de las cuentas para gestionar la solicitud.
#**********************************************************************
Get-RecipientPermission -Trustee joe@xyzcorp.com 

#User pemcervera@belcorp.bizAccessRights FullAccess
Remove-MailboxPermission tiendavirtualperu -User rguillen -AccessRights FullAccess
#RecipientPermission mensajecoo@belcorp.bizTrustee pemcervera@belcorp.bizAccessRights SendAs
Remove-RecipienTPermission tiendavirtualperu -Trustee rguillen -AccessRights SENDAS
Add-MailboxPermission bjimenez@belcorp.bizAccessRights FullAccess
Add-RecipientPermission ARESCRIBENOS -Trustee  dandrada -AccessRights SendAs
#Se creo la cuenta de correo compartida, sacpis@belcorp.biz con privilegios de adminsitracion para el usuario jxsierra. El mismo puede enviar mensajes desde dicho buzon. Se transfiere a sitio para configuracion.
#Se asignan privilegios de adminsitracion sobre la cuenta soporte_correo@belcorp.biz al usuario  japalomino, de acuerdo a la solicitud. El mismo puede enviar mensajes desde dicho buzón. Se transfiere a sitio para configuración.
#**********************************************************************

#Deshabilitación del acceso a un buzón de correo
Set-CASMailbox <Identity> -OWAEnabled $false -PopEnabled $false -ImapEnabled $false -MAPIEnabled $false -ActiveSyncEnabled $false -EwsEnabled $false
#Ejemplo:
Set-CASMailbox "Dirección de Ventas MX" -OWAEnabled $false -PopEnabled $false -ImapEnabled $false -MAPIEnabled $false -ActiveSyncEnabled $false -EwsEnabled $false
#Para volver a habilitar el acceso al buzón de correo, simplemente ejecute el mismo comando, pero establezca el valor del parámetro en $true en lugar de $false.
#**********************************************************************

#Modificar SMTP
Set-Mailbox -Name "PA.Sala Piso 24"-Alias PASalaPiso24 -EmailAddresses SMTP:PaSalaPiso24@belcorp.biz
#**********************************************************************
Get-MailboxPermission PESDESK -User CSALOMON
Get-RecipientPermission Sandra Perez Botero
#**********************************************************************
Get-Mailbox saerez@belcorp.biz | Select-Object DisplayName,Alias,PrimarySmtpAddress,RecipientType,RecipientTypeDetails
#*********************************************************************
#Reportes
Get-MailBox -Filter '(RecipientTypeDetails -eq "SharedMailbox")' | select RecipientTypeDetails,DisplayName, Alias, PrimarySmtpAddress | Export-Csv E:\ECS\sharedmailbox11mar.csv

#listado de usuarios sharedmailbox
#*- Ultimo logueo y Tamaño de Buzon
Get-Mailbox -ResultSize unlimited | Get-MailboxStatistics | ft DisplayName,itemcount,totalitemsize,lastlogontime -AutoSize -Wrap > "E:\ECS\Reportes\Reporte.csv" -Verbose
Get-Mailbox -ResultSize unlimited | Get-MailboxStatistics |ft DisplayName,ItemCount,TotalItemSize,LastLogonTime -AutoSize -Wrap | Export-Csv E:\ECS\LastLogonTime05abril.csv -Verbose -NoTypeInformation
Get-MailboxStatistics -ResultSize unlimited | Select displayname, lastlogontime | Export-Csv E:\ECS\lastlogon05.abr.csv -NoTypeInformation
Get-Mailbox -ResultSize Unlimited |Get-MailboxStatistics

#last logon(verificado)
Get-Mailbox -ResultSize Unlimited | Get-MailboxStatistics | Select displayname, lastlogontime | Export-Csv E:\ECS\lastlogon05.abr.csv -NoTypeInformation -Verbose

#tamaño(verificado)
Get-Mailbox -ResultSize unlimited | Get-MailboxStatistics | Select-Object DisplayName,TotalItemSize,ItemCount | Export-Csv "E:\ECS\MailboxSizeReport05abr.csv" -Verbose
#lastlogon+tamaño(verificado)
Get-Mailbox -ResultSize unlimited | Get-MailboxStatistics | Select-Object DisplayName,TotalItemSize,ItemCount, lastlogontime | Export-Csv "E:\ECS\prueba.csv" -NoTypeInformation -Verbose
#**********************************************************************
Import-Module MsOnline

Connect-MsolService
Get-Msoluser -UserPrincipalName dilshansam@valakulu.net 


Get-MsolAccountSku

New-MsolUser -UserPrincipalName dilshansam@valakulu.netPassword Password1
Get-MsolAccountSku | Where-Object {$_.SkuPartNumber -eq 'ENTERPRISEPACK'} |
ForEach-Object {$_.ServiceStatus}
$options = New-MsolLicenseOptions -AccountSkuId msdivision:ENTERPRISEPACK -DisabledPlans MCOSTANDARD,SHAREPOINTWAC,SHAREPOINTENTERPRISE
Set-MsolUserLicense -UserPrincipalName dilshansam@valakulu.net -LicenseOptions $options
#*************
#Buscar Mensajes en la nube
Search-MessageTrackingReport -Identity "zarela.carvajal" -Sender "test.bpos@nuevaeps.com.co" -ByPassDelegateChecking -DoNotResolve | ForEach-Object { Get-MessageTrackingReport -Identity $_.MessageTrackingReportID -DetailLevel Verbose -BypassDelegateChecking -DoNotResolve -RecipientPathFilter "zarela.carvajal@nuevaeps.com.co" -ReportTemplate RecipientPath }
#**********
#Compartir Calendario
#For example:
#This example assigns permissions for Anna to access John's calendar mailbox folder and applies the readitems role to her access of that folder
 
#Identity john@contoso.com:\CalendarUser anna@contoso.com 

 
#For more information about add mailbox folder permission, please refer to the article below:
#Add-MailboxFolderPermission
#http://technet.microsoft.com/en-us/library/dd298062.aspx

# ***********
#Importar Bulk..
Import-Csv -Path c:\users.csv | ForEach-Object {New-MsolUser -FirstName $_.FirstName -LastName $_.LastName -UserPrincipalName $_.UserPrincipalName -DisplayName "$($_.FirstName) $($_.LastName)" -LicenseAssignment ‘msdivision:ENTERPRISEPACK’ -UsageLocation US } | Export-Csv -Path c:\NewUsers.csv –NoTypeInformation
#***************
#Reporte de licencias MSOL
Get-MsolUser | Where-Object {$_.isLicensed -eq “TRUE”} | Export-Csv c:\path\AllUsersWithLicenses.CSV
#---- O ---
#Script to retrieve a licensing report from Office 365 and output it to CSV
# Copyright Microsoft @ 2012
# DISCLAIMER
# The sample scripts are not supported under any Microsoft standard support program or service.
# The sample scripts are provided AS IS without warranty of any kind.
# Microsoft further disclaims all implied warranties including, without limitation,
# any implied warranties of merchantability or of fitness for a particular purpose.
# The entire risk arising out of the use or performance of the sample scripts and documentation remains with you.
# In no event shall Microsoft, its authors, or anyone else involved in the creation, production,
# or delivery of the scripts be liable for any damages whatsoever (including, without limitation,
# damages for loss of business profits, business interruption, loss of business information,
# or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation,
# even if Microsoft has been advised of the possibility of such damages.
 
# change the username to a admin account in your tenant i.e. admin@contos.onmicrosoft.com 

$Username="usernotset"
# to set a new password delete this script and run SetupScript.ps1 again.
$pass="passnotset"
 
# check if the password and user are set to something
if(($pass -contains"notset")-or($Username -contains"notset"))
{
"You need to set your username and/or create an encrypted password for the admin account specified in this script before continuing."
Exit 2
}
 
# load the MSOnline PowerShell Module
# verify that the MSOnline module is installed and import into current powershell session
If (!([System.IO.File]::Exists(("{0}\modules\msonline\Microsoft.Online.Administration.Automation.PSModule.dll"-f $pshome))))
{
Write-EventLog -LogName Application -EntryType Error -EventId 99 -Source O365LicenseUpdate -Message"The Microsoft Online Services Module for PowerShell is not installed. The Script cannot continue."
write-log"Please download and install the Microsoft Online Services Module."
Exit 99
}
$getModuleResults = Get-Module
If (!$getModuleResults) {Import-Module MSOnline -ErrorAction SilentlyContinue}
Else {$getModuleResults | ForEach-Object {If (!($_.Name -eq"MSOnline")){Import-Module MSOnline -ErrorAction SilentlyContinue}}}
write-Eventlog -logname Application -Entrytype information -EventId 0 -source O365LicenseUpdate -message 'MSOnline module imported'
 
# create the password from the encrypted string and setup the credential object
$password = ConvertTo-SecureString $pass
$cred = New-Object -typename System.Management.Automation.PSCredential -argumentlist $Username,$password
$er =""
 
# Connect to Microsoft Online Service
Connect-MsolService -Credential $cred -errorAction silentlyContinue -errorvariable $er
if ($er -ne""){
# handle any logon errors
$message6 = 'Could not log on O365 with ' + $($Username) + ' to create your licensing report ' + $er
write-Eventlog -logname Application -Entrytype error -EventId 6 -source O365LicenseUpdate -message $message6
exit
}
else {
write-Eventlog -logname Application -Entrytype information -EventId 0 -source O365LicenseUpdate -message 'Logged In'
}
 
$outFile="licenses_{0:yyyyMMdd-HHmm}.csv"-f (Get-Date)
$users = Get-MsolUser -all
$header ="userPrincipaName,usageLocation,isLicensed,accountSKUid,servicePlan1,provisioningStatus1,servicePlan2,provisioningStatus2,servicePlan3,provisioningStatus3,servicePlan4,provisioningStatus4,servicePlan5,provisioningStatus5"
Out-File -FilePath $outfile -InputObject $header
 
foreach($usr in $users)
{
 
$lineOut=$usr.UserPrincipalName +","+ $usr.usageLocation +","+ $usr.isLicensed +","
foreach($lic in $usr.Licenses)
{
$lineOut = $lineOut + $lic.AccountSkuID
foreach($s in $lic.ServiceStatus)
{
$lineout = $lineout + $s.ServicePlan.ServiceName +","+ $s.ProvisioningStatus +","
}
}
Out-File -FilePath $outfile -Append -NoClobber -InputObject $lineOut
$lineOut = $null
}
 
Write-Host -ForeGroundColor yellow"Please review your output file at "$outFile
#*************************************************************
#Powershell
#Medir el tamaño de una carpeta remota.
((Get-ChildItem\\remoteServer\C$-Recurse) |Measure-Object -Sum Length).sum
Get-ChildItem\\remoteServer\C$-Recurse -Force
#Logs
get-eventlog -logname application | where { $_.timegenerated -gt [datetime]"2/28/12"} |measure
get-process| where{$_.pm -gt 20MB}
#Crear una maquina en Hyper-V
Create-VM -Name "VM01" -VirtualHardDisk $VHD -VMHost $VMHost -Path "C:\MyVMs"
dsquery user -inactive 7 | dsmod user -disabled yes
gwmi Win32_PhysicalMemory | select BankLabel,Capacity,DataWidth,DeviceLocator,MemoryType
get-wmiobject Win32_ComputerSystem | select @{name="TotalPhysicalMemory(MB)";expression={($_.TotalPhysicalMemory/1mb).tostring("N0")}},NumberOfProcessors
#*********************************************************
#Barra de progreso mientras copia...
#---------------------------------------------------------------------------------------------#
#--Script to copy files from one location to another with a cool Progressbar --#
# If you want to test it - Change the source path and target path with a relevant directory
# in your computer -
# $SOURCE_PATH
# $TARGET_PATH
#---------------------------------------------------------------------------------------------#
# Note : The script will copy only files from source to target, please use it carefully
# if the low disk space problem in target drive.
# Do not use C:\ drive or drive where Operating system in installed.
#---------------------------------------------------------------------------------------------#
$SOURCE_PATH="\\10.27.9.120\c$\Users\co1073152864.SYNAPSISIT"
$TARGET_PATH = "C:\Users\co80021375\Music"
$FILES_COLLECTION=ls
$SOURCE_PATH | where { $_.Mode -notcontains "d----" } | foreach { $_.FullName}
$FILES_COUNT=$FILES_COLLECTION.count for ( $t =0; $t -lt $FILES_COUNT ; $t++)  {$status = [int] (($t/$FILES_COUNT) * 100)
#--Get the full-file name and only leaf name of the file --#
$THIS_FILE_FULL_NAME = $FILES_COLLECTION[$t]
$THIS_FILE_NAME = Split-Path
$THIS_FILE_FULL_NAME -leaf
#--Set the target location --3
$THIS_FILE_TARGET = "${TARGET_PATH}\${THIS_FILE_NAME}"
#--write progress with progressbar --#
Write-Progress -id 1 -Activity "File-Copy Status - [$status]" -Status "Copying to $THIS_FILE_NAME to $TARGET_PATH " -PercentComplete $status#--Copy Step --#  Copy-Item $THIS_FILE_FULL_NAME $THIS_FILE_TARGET }
#---------------------------------------------------------------------------------------------#
# End of Code
#---------------------------------------------------------------------------------------------#
#Enviar un SMTP desde PS.
$SENDER="mssqlmailac@foo.com"
$MAIL_SERVER="foo.com"
$NOTIFY_ID="som@foo.com"
$SUBJECT="This is Subject"
$MAIL_BODY="This is testing only"
$SMTP = new-object
Net.Mail.SmtpClient(${MAIL_SERVER})
$MSG = New-Object
System.Net.Mail.MailMessage "${SENDER}", "${NOTIFY_ID}", "${SUBJECT}" ,
${MAIL_BODY}
#--Adding this line would send HTML
#formatted mail --#
$MSG.IsBodyHTML = $TRUE
$SMTP.Send($MSG)
#*********************************************************
#Reproducir un sonido por MP desde PS.
#--Initialize Object --#
$sound = new-Object System.Media.SoundPlayer
#--Modify the wav filename --#
$sound.SoundLocation="c:\WINDOWS\Media\notify.wav"$sound.Play()$sound.Stop()
#**********************************************************
#Mostrar el UPtime
clear
$uptime=net stats srv | where {$_ -match "since"} | foreach {$_.replace("Statistics since","") } |
foreach { $($((Get-Date) - (Get-Date $_)).Days).tostring().padleft(3,"0").tostring() + ":" +
$($((Get-Date) - (Get-Date $_)).Hours).tostring().padleft(2,"0").tostring() + ":" +
$($((Get-Date) - (Get-Date $_)).Minutes).tostring().padleft(2,"0").tostring() + ":" +
$($((Get-Date) - (Get-Date $_)).Seconds).tostring().padleft(2,"0").tostring()
} | foreach { $_.replace(" ", "") }
echo "Uptime of Host [$(hostname)]`t: $uptime (DD:HH:MM:SS)"
Ciclo cada 5 seg,
while ($true) {
Start-Sleep -s 5
cls
‘CPU Load is’
Get-WmiObject win32_processor | select LoadPercentage  |fl
}
#-------------------------------------------------------------------------------------------------
#Enviar MSG con Attachment
Add-PSSnapin Microsoft.Exchange.Management.Powershell.Admin -erroraction silentlyContinue
$file = "C:\folder\file.csv"
$mailboxdata = (Get-MailboxStatistics | select DisplayName, TotalItemSize,TotalDeletedItemSize, ItemCount, LastLoggedOnUserAccount, LastLogonTime)
$mailboxdata | export-csv "$file"
$smtpServer = "127.0.0.1"
$att = new-object Net.Mail.Attachment($file)
$msg = new-object Net.Mail.MailMessage
$smtp = new-object Net.Mail.SmtpClient($smtpServer)
$msg.From = "emailadmin@test.com"
$msg.To.Add("administrator1@test.com")
$msg.To.Add("administrator2@test.com")
$msg.Subject = "Notification from email server"
$msg.Body = "Attached is the email server mailbox report"
$msg.Attachments.Add($att)
$smtp.Send($msg)
$att.Dispose()
#-------------------------------------------------------------------------------------------------
#Mostrar Dialogo emergente
[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[System.Windows.Forms.MessageBox]::Show("We are proceeding with next step." , "Status" , 4)
#--------------------------------------------------------------------------------------------------
#Force directory synchronization using Windows PowerShell
#You can use the directory synchronization Windows PowerShell cmdlet to force synchronization. The cmdlet is installed when you install the Directory Sync tool.
#1.On the computer that is running the Directory Sync tool, navigate to the directory synchronization installation folder. By default, it is located here: %programfiles%\Microsoft Online Directory Sync.
#2.Double-click DirSyncConfigShell.psc1 to open a Windows PowerShell window with the cmdlets loaded.
#3.In the Windows PowerShell window, type Start-OnlineCoexistenceSync, and then press ENTER.
#Scripts Exchange
 
#Este elimina unos mensajes con contenido especifico de toda la organizacion o por cuenta
Get-Mailbox -Server SRVBOGEX2K7 -ResultSize Unlimited | Export-Mailbox -SubjectKeywords "RV: favor especial" -IncludeFolders "\Inbox" -StartDate "08/15/2012" -EndDate "08/15/2012" -DeleteContent -TargetMailbox AVianca\DMG -TargetFolder DeleteMsgs -Confirm:$false
 
Get-Mailbox | Export-Mailbox -ContentKeywords "RV: favor especial" -DeleteContent
 
Get-Mailbox -Server SRVBOGEX2K7 | Export-Mailbox -Identity "SRAMIREZ" -TargetMailbox DGutierrez -TargetFolder ” ToDelete” -SenderKeywords comunicacionesinternas@aviancataca.comRV: favor especial” –StartDate “08/15/2012" –EndDate “08/15/2012" –DeleteContent –MaxThreads 10
 
Get-Mailbox -Server SRVBOGEX2K7 | Export-Mailbox -Identity "SRAMIREZ"
-SubjectKeywords ”RV: favor especial” –StartDate “08/15/2012" –EndDate
“08/15/2012" –DeleteContent –MaxThreads 10
  
Get-Mailbox -database "MS07DB5" -ResultSize Unlimited | Export-Mailbox
-SubjectKeywords "RV:favor especial" -IncludeFolders "\Bandeja de entrada"
-StartDate "08/15/2012" -DeleteContent -Confirm $false
 
Get-Mailbox -database "MS07DB5" -ResultSize Unlimited | Export-Mailbox
-SubjectKeywords "RV: favor especial" -IncludeFolders "\Bandeja de entrada"
-StartDate "08/15/2012" -DeleteContent -TargetMailbox Dgutierrez
-TargetFolder Encontrados -Confirm $false
 
Get-Mailbox -identity "cpalomino" -ResultSize Unlimited | Export-Mailbox
-SubjectKeywords "RV: favor especial" -SenderKeywords
comunicacionesinternas@aviancataca.com -IncludeFolders "\Sent Items"
-StartDate "08/15/2012" -DeleteContent -TargetMailbox dgutierrez
-TargetFolder ultimos -Confirm false
 
"Get-Mailbox -identity ""DomainAdmin"" -ResultSize Unlimited |
Export-Mailbox -SubjectKeywords ""RV: favor especial"" -IncludeFolder
s ""\Bandeja de entrada"" -StartDate ""08/15/2012"" -DeleteContent
-TargetMailbox Dgutierrez
-TargetFolder ultimos1 -Confirm:$false -Baditemlimit 1000"
Get-Mailbox -identity "RQUIJANO" -ResultSize Unlimited | Export-Mailbox
-SubjectKeywords "RV: favor especial" -IncludeFolders "\Bandeja de entrada"
-StartDate "08/15/2012" -DeleteContent -TargetMailbox Dgutierrez
-TargetFolder RQUIJANO -Confirm:$false -Baditemlimit 1001
"Get-Mailbox -identity ""AAETEAGA"" -ResultSize Unlimited | Export-Mailbox
-SubjectKeywords ""RV: favor especial"" -IncludeFolder
s ""\Bandeja de entrada"" -StartDate ""08/15/2012"" -DeleteContent
-TargetMailbox Dgutierrez
-TargetFolder ultimos1 -Confirm:$false -Baditemlimit 1002"
 
 Get-Mailbox -Database "MS07DBINTERMEDIOS" -ResultSize Unlimited |
Export-Mailbox -SubjectKeywords "RV: favor especial" -IncludeFolders
"\Inbox" -StartDate "08/14/2012" -EndDate "08/16/2012" -DeleteContent
-TargetMailbox Dgutierrez -TargetFolder MS07DBINTERMEDIOS2 -Confirm:$false
-Baditemlimit 1000
 
Add-MailboxPermission –Id <UserMailbox> –User <Account to have permissions>
–AccessRights ‘Full Access’ –Confirm:$false
Scripts Exchange
 
#______________________________________________________________
Set-Mailbox -Identity John -DeliverToMailboxAndForward $true -ForwardingSMTPAddress manuel@contoso.com 
 
Add-MailboxPermission –Id <UserMailbox> –User <Account to have permissions>
–AccessRights ‘Full Access’ –Confirm:$false
 
#Asignarse permisos para importar y exportar
 
New-ManagementRoleAssignment -Role "Mailbox Import Export" -User clarota
 
#Realizar un backup de un .PST
 
New-MailboxExportRequest -Mailbox ssierra -FilePath \\SEXC01\PST\ssierra.pst

 
#Ver el tamaño del buzon especifico
 
Get-MailboxStatistics -Identity "mcampo"
 
#Ver el tamaño del buzon completo
 
Get-MailboxStatistics -Server SEXC01 | Sort-Object TotalItemSize –Descending | Format-List > c:\PST\size.csv
 
 #Certificado Digital
 
Get-SendConnector | fl fqdn
 
Get-ExchangeCertificate | fl CertificateDomains
 
Get-ExchangeCertificate | fl thumbprint, services
 
Enable-ExchangeCertificate -Thumbprint 74A8901B9A60E59DEA024B0F3B2B42146AE8E439 -Services IMAP, POP, IIS, SMTP
  
Get-ExchangeCertificate | fl thumbprint, status, notafter
 
Add-MailboxPermission -Identity 'CN=Carolina Alejandra La Rota Nino,OU=Administradores,OU=Administracion,OU=Cuentas,DC=mincomunicaciones,DC=gov,DC=co' -User 'MINCOM\clarota' -AccessRights 'FullAccess'
 
 
#Lista un usuario 
 
get-user -identity besadmin | list
 
#Auditar un usuario
 
Set-Mailbox -Identity "Diego Molano Vega" -AuditEnabled $true
 
#Ver la auditoria
 
Search-MailboxAuditLog -Identity besadmin -LogonTypes Admin,Delegate -StartDate 8/7/2011 -EndDate 12/7/2011 -ResultSize 2000
 
#Ver tamaños de los buzones
 
Get-Mailbox | Get-MailboxStatistics | Sort-Object TotalItemSize –Descending | ft DisplayName,TotalItemSize,ItemCount,database | Format-List > c:\PST\file.csv
 
#Ver listado detallado de propiedades de cuentas, buzones y demas
 
Get-User -RecipientTypeDetails UserMailbox | Select-Object DisplayName,UserAccountControl, WindowsEmailAddress, WhenChanged, WhenCreated, Database, IssueWarningQuota, RulesQuota, SamAccountName, ProhibitSendQuota, Office  | Format-List > c:\PST\listado.csv
 
Get-Mailbox -identity jmedellin | list  | select-object  -IssueWarningQuota
 
Get-RoleGroupMember “View-Only Organization Management” 
 
Add-RoleGroupMember “View-Only Organization Management” -Member dirsync
 
Add-RoleGroupMember “Organization Management” -Member dirsync
 
Get-OrganizationConfig | Add-ADpermission -User dirsync -ExtendedRights “ms-Exch-Store-Admin”,“Send As”, “Receive As”
 
Get-OrganizationConfig | Get-AdPermission –User dirsync
 
Get-MailboxDatabase | Add-ADPermission –User dirsync –ExtendedRights “send as”, “receive as”,“ms-Exch-Store-Admin”

Get-MailboxDatabase | Get-AdPermission –User dirsync
 
#Exportar las IP de los conectores de relay.
 
(Get-ReceiveConnector "myrelay").RemoteIPRanges | select Lowerbound,Upperbound,RangeFormat | export-csv c:\rc.txt -NoTypeInformation
New-ReceiveConnector "WWB-Relay" -Server SRVWPRAPMAIL01 -Bindings 0.0.0.0:25 -RemoteIPRanges (Get-ReceiveConnector "SRVWWBMAIL01\Helpdesk").RemoteIPRanges
(Get-MoveRequest -MoveStatus Queued).count
 
#Pegado de <https://www.icloud.com/applications/notes/current/es-es/index.html> 
 
#…...............................................
 
 $userlist = get-content .\usuariosK1.txt 
 foreach ( $user in $userlist ) {Get-ADUser "$user" -Properties Name, DistinguishedName| Select-Object Name, DistinguishedName}
#------------------------------------------
