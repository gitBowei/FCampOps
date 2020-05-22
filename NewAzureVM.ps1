Import-Module azure
Import-AzurePublishSettingsFile 'C:\Users\FCamp\Downloads\Pago por uso-Plataformas de MSDN-8-26-2014-credentials.publishsettings'
Get-AzureSubscription
Select-AzureSubscription "Plataformas de MSDN"
Get-AzureStorageAccount |select StorageAccountName
Set-AzureSubscription -SubscriptionName "Plataformas de MSDN" -CurrentStorageAccountName "storagefch"
$user = "fcampo"
$pwd = "1234abcd."
Get-AzureLocation |select Name
$location = "South Central US"
Get-AzureVMImage |select ImageName
$img = "a699494373c04fc0bc8f2bb1389d6106__Windows-Server-2012-Datacenter-201408.01-en.us-127GB.vhd"
Get-AzureRoleSize |select InstanceSize
$size = "Small"
Set-AzureSubscription -SubscriptionName "Plataformas de MSDN" -CurrentStorageAccountName "stofch"
Test-AzureName -Service "fchService"
$cloudService = "fchService"
$vmconfig = New-AzureVMConfig -Name "SQL1FCH" -ImageName $img -InstanceSize $size
$vmconfig |Add-AzureProvisioningConfig -Windows -AdminUsername $user -Password $pwd
$vmConfig | Add-AzureDataDisk -CreateNew  -DiskSizeInGB 100 -DiskLabel "Data 1" -Lun 0
$vmConfig | Add-AzureDataDisk -CreateNew  -DiskSizeInGB 100 -DiskLabel "Data 2" -Lun 1
$vmConfig | Add-AzureEndpoint -Name "Web" -Protocol tcp -LocalPort 80 -PublicPort 80
$vmConfig | Add-AzureEndpoint -Name "RDP" -Protocol tcp -LocalPort 3389 -PublicPort 3389
$vmConfig | New-AzureVM -ServiceName $cloudService -Location $location