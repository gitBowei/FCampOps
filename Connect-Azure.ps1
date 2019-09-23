Get-Command -Module MSOnline  Azure 
Connect-MsolService  Azure
Get-Mailbox
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned

Import-PSSession $(New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell -Authentication Basic -AllowRedirection -Credential $(Get-Credential))

Import-PSSession $(New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell -Authentication Basic -AllowRedirection -Credential $cred)  


(get-command).count

Coy54413


New-MsolUser -UserPrincipalName spencer@ASDLabsMOD692157.onmicrosoft.com -DisplayName "Spencer Low" -FirstName "Spencer" -LastName "Low"


Get-MsolUser -UserPrincipalName emilyb@ASDLabsMOD692157.onmicrosoft.com | fl

Set-MsolUser -UserPrincipalName emily@ASDLabsMOD692157.onmicrosoft.com -MobilePhone 123-555-9898


11..20 | % { New-MsolUser -UserPrincipalName "test$_@ASDLabsMOD692157.onmicrosoft.com" -DisplayName "Test $_" }


Get-MsolUser -test11_@ASDLabsMOD692157.onmicrosoft.com | Set-MsolUserLicense -AddLicenses (Get-MsolAccountSku).AccountSkuId¨


Get-MsolUser -userprincipalname spencer@ASDLabsMOD692157.onmicrosoft.com | Set-MsolUserLicense -AddLicenses (Get-MsolAccountSku).AccountSkuId
Get-MsolUser -userprincipalname test11@ASDLabsMOD692157.onmicrosoft.com | Set-MsolUserLicense -AddLicenses (Get-MsolAccountSku).AccountSkuId


Remove-MsolUser -UserPrincipalName Test13@ASDLabsMOD692157.onmicrosoft.com


Get-MsolUser | where {$_.userprincipalname -match "test*"} | Remove-MsolUser -Force


Restore-MsolUser -UserPrincipalName test$_@ASDLabsMOD692157.onmicrosoft.com

Restore-MsolUser -UserPrincipalName test11@ASDLabsMOD692157.onmicrosoft.com


Get-MsolUser -ReturnDeletedUsers | ft UserPrincipalName, SoftDeletionTimestamp


New-Mailbox -Alias hollyh -Name hollyh -FirstName Holly -LastName Holt -DisplayName "Holly Holt" -MicrosoftOnlineServicesID hollyh@ASDLabsMOD692157.onmicrosoft.com -Password (ConvertTo-SecureString -String 'Password1' -AsPlainText -Force) -ResetPasswordOnNextLogon $true



New-Mailbox -Alias hollyh -Name hollyh -FirstName Holly -LastName Holt -DisplayName "Holly Holt" -MicrosoftOnlineServicesID hollyh@ASDLabsMOD692157.onmicrosoft.com -Password (ConvertTo-SecureString -String 'Password1' -AsPlainText -Force) -ResetPasswordOnNextLogon $true


Set-Mailbox -Identity chris -DeliverToMailboxAndForward $true -ForwardingAddress cynthia@ASDLabsMOD692157.onmicrosoft.com



Set-DistributionGroup "Legal Team 1" -EmailAddresses SMTP:legal1@ASDLabsMOD692157.onmicrosoft.com,smtp:legalteam1@ASDLabsMOD692157.onmicrosoft.com


New-DistributionGroup -Name "Legal Team 1" -Alias LegalTeam -MemberJoinRestriction open



New-DynamicDistributionGroup -Name "Full Time Employees" -RecipientFilter {(RecipientTypeDetails -eq 'UserMailbox') -and (office -eq '123451')}


$FTE = Get-DynamicDistributionGroup "Medellin"

Get-Recipient -RecipientPreviewFilter $MDE.RecipientFilter


New-MailContact -Name "Alan Shen" -ExternalEmailAddress alans@fourthcoffee.com



New-MailUser -Name "RONALDO" -Alias rona -ExternalEmailAddress rona@realm.com -FirstName Rona -LastName Cristiano -
MicrosoftOnlineServicesID ronal@ASDLabsMOD692157.onmicrosoft.com -Password (ConvertTo-SecureString -String 'Password1' -AsPlainText -Force)
