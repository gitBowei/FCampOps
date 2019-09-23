#Esta es mi compilacion de rutinas para gestionar Office 365.
#Creado el 19 de Julio de 2017
$cred=get-credential -UserName fabian.campo@campohenriquezlab.onmicrosoft.com
Connect-MsolService -Credential $cred

#Crear una cuenta 
New-MsolUser –UserPrincipalName Stephanie.Campo@campohenriquezlab.onmicrosoft.com –DisplayName “Stephanie Campo” –FirstName “Stephanie” –LastName “Campo” –Password ‘Pa55w.rd’ –ForceChangePassword $false –UsageLocation “CO”

New-MsolUser –UserPrincipalName IronMan@campohenriquezlab.onmicrosoft.com –DisplayName “IronMan” –FirstName “Anthony” –LastName “Stark” –Password ‘Pa55w.rd’ –ForceChangePassword $false –UsageLocation “CO”

#Asignar una licencia
Get-MsolUser -UnlicensedUsersOnly

Set-MsolUserLicense -UserPrincipalName Stephanie.Campo@campohenriquezlab.onmicrosoft.com –AddLicenses “CampoHenriquezLab:ENTERPRISEPACK”

Set-MsolUserLicense -UserPrincipalName IronMan@CampoHenriquezLab.onmicrosoft.com –AddLicenses “CampoHenriquezLab:ENTERPRISEPACK”

#Remover la licencia de Office365
Set-MsolUser -UserPrincipalName IronMan@CampoHenriquezLab.onmicrosoft.com -blockcredential $true

#Eliminar un usuario de Office365
Remove-MsolUser –UserPrincipalName IronMan@CampoHenriquezLab.onmicrosoft.com –Force

#Listar los usuarios activos
Get-MsolUser

#Listar los usuarios eliminados
Get-MsolUser –ReturnDeletedUsers

#Restaurar un usuario eliminado
Restore-MsolUser –UserPrincipalName IronMan@CampoHenriquezLab.onmicrosoft.com

#Importar un lote desde un archivo CSV
Import-Csv -Path C:\labfiles\O365Users.csv | ForEach-Object { New-MsolUser -UserPrincipalName $_."UPN" -AlternateEmailAddresses $_."AltEmail" –FirstName $_."FirstName" -LastName $_."LastName" -DisplayName $_."DisplayName" –BlockCredential $False -ForceChangePassword $False -LicenseAssignment $_."LicenseAssignment" -Password $_."Password" -PasswordNeverExpires $True -Title $_."Title" -Department $_."Department" -Office $_."Office" -PhoneNumber $_."PhoneNumber" -MobilePhone $_."MobilePhone" -Fax $_."Fax" -StreetAddress $_."StreetAddress" -City $_."City" -State $_."State" -PostalCode $_."PostalCode" -Country $_."Country" -UsageLocation $_."UsageLocation" }

#Crear un nuevo grupo
New-MsolGroup –DisplayName “Marketing” –Description “Marketing department users”

$MktGrp = Get-MsolGroup | Where-Object {$_.DisplayName -eq "Marketing"}

$Catherine = Get-MsolUser | Where-Object {$_.DisplayName -eq "Catherine Richard"}

$Tameka = Get-MsolUser | Where-Object {$_.DisplayName -eq "Tameka Reed"}

Add-MsolGroupMember -GroupObjectId $MktGrp.ObjectId -GroupMemberType "User" -GroupMemberObjectId $Catherine.ObjectId

Add-MsolGroupMember -GroupObjectId $MktGrp.ObjectId -GroupMemberType "User" -GroupMemberObjectId $Tameka.ObjectId

Get-MsolGroupMember -GroupObjectId $MktGrp.ObjectId

#Configurar la politica de passwords
Set-MsolPasswordPolicy -DomainName “Adatumyyxxxxx.onmicrosoft.com” –ValidityPeriod “90” -NotificationDays “14”

#Establecer el password de un usuario
Set-MsolUserPassword –UserPrincipalName “Tameka@adatumyyxxxxx.hostdomain.com” –NewPassword ‘Pa$$w0rd123’

#Listar los usuarios que el password no caduca
Get-MsolUser | Set-MsolUser –PasswordNeverExpires $false

#Adicionar usuarios Administradores
Add-MsolRoleMember –RoleName “Service Support Administrator” –RoleMemberEmailAddress “Sallie@Adatumyyxxxxx.hostdomain.com”

Add-MsolRoleMember –RoleName “Company Administrator” –RoleMemberEmailAddress “Nona@Adatumyyxxxxx.hostdomain.com”

$role = Get-MsolRole –RoleName “Service Support Administrator”

Get-MsolRoleMember –RoleObjectId $role.ObjectId

$role = Get-MsolRole –RoleName “Billing Administrator”

Get-MsolRoleMember –RoleObjectId $role.ObjectId

$role = Get-MsolRole –RoleName “Company Administrator”

Get-MsolRoleMember –RoleObjectId $role.ObjectId

$credential = Get-Credential

connect-msolservice –credential $credential

$exchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange –ConnectionUri "https://outlook.office365.com/powershell-liveid/" -Credential $credential -Authentication "Basic" -AllowRedirection

Import-PSSession $exchangeSession -DisableNameChecking

Get-AcceptedDomain

New-Mailbox -Name "Conference Room" –Room

Set-mailbox “Conference room” –resourcecapacity “25”

Set-CalendarProcessing "Conference Room" -AutomateProcessing AutoAccept

New-Mailbox -Name "Demonstration Laptop” –Equipment

Set-CalendarProcessing "Demonstration Laptop” -AutomateProcessing AutoAccept

Import-Csv .\Externalcontacts.csv | %{New-MailContact -Name $_.Name –DisplayName $_.Name -ExternalEmailAddress $_.ExternalEmailAddress -FirstName $_.FirstName -LastName $_.LastName}

$Contacts = Import-CSV .\externalcontacts.csv

$contacts | ForEach {Set-Contact $_.Name -StreetAddress $_.StreetAddress –City $_.City -StateorProvince $_.StateorProvince -PostalCode $_.PostalCode -Phone $_.Phone -MobilePhone $_.MobilePhone -Pager $_.Pager -HomePhone $_.HomePhone –Company $_.Company -Title $_.Title -OtherTelephone $_.OtherTelephone –Department $_.Department -Fax $_.Fax -Initials $_.Initials -Notes $_.Notes -Office $_.Office -Manager $_.Manager}

#Sharepoint Online
Connect-SPOService –Url https://adatumyyxxxxx-admin.sharepoint.com –credential holly@Adatumyyxxxxx.hostdomain.com

New-SPOSite -Url https://Adatumyyxxxxx.sharepoint.com/sites/AcctsProj -Owner holly@Adatumyyxxxxx.hostdomain.com -StorageQuota 500 -NoWait -Template PROJECTSITE#0 –Title “Accounts Project”

#Skype for Business
$cred = Get-Credential

$SfBSession = New-CSOnlineSession –Credential $cred

Import-PSSession $SfBSession

Set-CsBroadcastMeetingConfiguration –EnableBroadcastMeeting $True

Get-CsBroadcastMeetingConfiguration

Set-CSPrivacyConfiguration -EnablePrivacyMode $True

Set-CSPushNotificationConfiguration -EnableApplePushNotification $False

Get-CSPrivacyConfiguration

Get-CSPushNotificationConfiguration

Set-CsTenantFederationConfiguration –AllowPublicUsers $True

Set-CsTenantFederationConfiguration –AllowFederatedUsers $True

$AllDomains = New-CsEdgeAllowAllKnownDomains $BlockedDomain = New-CsEdgeDomainPattern -Domain "litware.com" Set-CsTenantFederationConfiguration -AllowedDomains $AllDomains –BlockedDomains $BlockedDomain Get-CsTenantFederationConfiguration

Get-CsMeetingConfiguration

#Script by Carlos Alvarez Enable AADRM
$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic –AllowRedirection
Import-PSSession $Session
Set-IRMConfiguration –RMSOnlineKeySharingLocation https://sp-rms.na.aadrm.com/TenantManagement/ServicePartner.svc
Import-RMSTrustedPublishingDomain -RMSOnline -name "RMS Online"
Set-IRMConfiguration -ClientAccessServerEnabled $true
# get in https://portal.aadrm.com 
