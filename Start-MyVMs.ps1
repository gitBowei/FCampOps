import-module Azure
Import-AzurePublishSettingsFile -PublishSettingsFile '.\Downloads\Pay-As-You-Go Dev_Test-Plataformas de MSDN-8-11-2016-credentials.publishsettings'
Select-AzureSubscription -SubscriptionName "Plataformas de MSDN"
Get-AzureService -ServiceName CampoHenriquez
Start-AzureVM -ServiceName CampoHenriquez -Name ATLAS
#Servidor de Active Directory
Start-Sleep -Seconds 30
Start-AzureVM -ServiceName CampoHenriquez -Name Hades
#Servidor de SQL
Start-Sleep -Seconds 30
Start-AzureVM -ServiceName CampoHenriquez -Name Zeus
#Servidor de Exchange
Start-Sleep -Seconds 30
Start-AzureVM -ServiceName CampoHenriquez -Name Poseidon
Start-Sleep -Seconds 30
Start-AzureVM -ServiceName CampoHenriquez -Name ubuServer
#Servidor Ubuntu -No tiene interfaz grafica
Start-Sleep -Seconds 30
Start-AzureVM -ServiceName CampoHenriquez -Name Chronos
Start-Sleep -Seconds 30
Start-AzureVM -ServiceName CampoHenriquez -Name filoctetes
#Windows Server 2016 Nano Server
Start-Sleep -Seconds 30
Start-AzureVM -ServiceName CampoHenriquez -Name perseo
Start-Sleep -Seconds 30
Get-AzureVM -ServiceName CampoHenriquez |ft
