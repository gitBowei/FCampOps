Connect-AzAccount
Get-AZSubscription | Select-Object SubscriptionName
$subscrName="Microsoft Azure Sponsorship"
Select-AzSubscription -SubscriptionName $subscrName
Get-AZResourceGroup | Select-Object ResourceGroupName
$rgName="AzureBootCamp_RG"
$locName="EastUS2"
New-AZResourceGroup -Name $rgName -Location $locName
Get-AZStorageAccount | Select-Object StorageAccountName
Get-AZStorageAccountNameAvailability "azurebootcamp2020"
$saName="azurebootcamp2020"
$locName=(Get-AZResourceGroup -Name $rgName).Location
New-AZStorageAccount -Name $saName -ResourceGroupName $rgName -Type Standard_LRS -Location $locName

$diskConfig = New-AzDiskConfig -Location $location -CreateOption Empty -DiskSizeGB 32 -Sku Standard_LRS
$diskName = 'azurebootcamp-disk1'
New-AzDisk -ResourceGroupName $rgName -DiskName $diskName -Disk $diskConfig

Get-AzDisk -ResourceGroupName $rgName -Name $diskName

New-AzDiskUpdateConfig -DiskSizeGB 64 | Update-AzDisk -ResourceGroupName $rgName -DiskName $diskName

Get-AzDisk -ResourceGroupName $rgName -Name $diskName

(Get-AzDisk -ResourceGroupName $rgName -Name $diskName).Sku

New-AzDiskUpdateConfig -Sku Premium_LRS | Update-AzDisk -ResourceGroupName $rgName -DiskName $diskName

(Get-AzDisk -ResourceGroupName $rgName -Name $diskName).Sku



$rgName="AzureBootCamp_RG"
$locName=(Get-AZResourceGroup -Name $rgName).Location
$vnetName="VNet01"
$SubnetName="Subnet01"
$Subnet=New-AZVirtualNetworkSubnetConfig -Name $SubnetName -AddressPrefix 10.0.0.0/27
New-AZVirtualNetwork -Name $vnetName -ResourceGroupName $rgName -Location $locName -AddressPrefix 10.0.0.0/24 -Subnet $Subnet -DNSServer 10.0.0.4
$rule1 = New-AZNetworkSecurityRuleConfig -Name "RDPTraffic" -Description "Allow RDP to all VMs on the subnet" -Access Allow -Protocol Tcp -Direction Inbound -Priority 100 -SourceAddressPrefix Internet -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389
$rule2 = New-AZNetworkSecurityRuleConfig -Name "ExchangeSecureWebTraffic" -Description "Allow HTTPS to the Exchange server" -Access Allow -Protocol Tcp -Direction Inbound -Priority 101 -SourceAddressPrefix Internet -SourcePortRange * -DestinationAddressPrefix "10.0.0.5/32" -DestinationPortRange 443
$rule3 = New-AZNetworkSecurityRuleConfig -Name "SharePointSecureWebTraffic" -Description "Allow HTTPS to the SharePoint server" -Access Allow -Protocol Tcp -Direction Inbound -Priority 102 -SourceAddressPrefix Internet -SourcePortRange * -DestinationAddressPrefix "10.0.0.7/32" -DestinationPortRange 80
New-AZNetworkSecurityGroup -Name $SubnetName -ResourceGroupName $rgName -Location $locName -SecurityRules $rule1, $rule2, $rule3
$vnet=Get-AZVirtualNetwork -ResourceGroupName $rgName -Name $vnetName
$nsg=Get-AZNetworkSecurityGroup -Name $SubnetName -ResourceGroupName $rgName
Set-AZVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $SubnetName -AddressPrefix "10.0.0.0/27" -NetworkSecurityGroup $nsg
$vnet | Set-AzVirtualNetwork

$rgName="AzureBootCamp_RG"
# Create an availability set for domain controller virtual machines
New-AZAvailabilitySet -ResourceGroupName $rgName -Name dcAvailabilitySet -Location $locName -Sku Aligned  -PlatformUpdateDomainCount 5 -PlatformFaultDomainCount 2
# Create the domain controller virtual machine
$vmName="adVM"
$vmSize="Standard_D1_v2"
$vnet=Get-AZVirtualNetwork -Name $vnetName -ResourceGroupName $rgName
$pip = New-AZPublicIpAddress -Name ($vmName + "-PIP") -ResourceGroupName $rgName -Location $locName -AllocationMethod Dynamic
$nic = New-AZNetworkInterface -Name ($vmName + "-NIC") -ResourceGroupName $rgName -Location $locName -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id -PrivateIpAddress 10.0.0.4
$avSet=Get-AZAvailabilitySet -Name dcAvailabilitySet -ResourceGroupName $rgName
$vm=New-AZVMConfig -VMName $vmName -VMSize $vmSize -AvailabilitySetId $avSet.Id
$vm=Set-AZVMOSDisk -VM $vm -Name ($vmName +"-OS") -DiskSizeInGB 128 -CreateOption FromImage -StorageAccountType "Standard_LRS"
$diskConfig=New-AZDiskConfig -AccountType "Standard_LRS" -Location $locName -CreateOption Empty -DiskSizeGB 20
$dataDisk1=New-AZDisk -DiskName ($vmName + "-DataDisk1") -Disk $diskConfig -ResourceGroupName $rgName
$vm=Add-AZVMDataDisk -VM $vm -Name ($vmName + "-DataDisk1") -CreateOption Attach -ManagedDiskId $dataDisk1.Id -Lun 1
$cred=Get-Credential -Message "Type the name and password of the local administrator account for adVM."
$vm=Set-AZVMOperatingSystem -VM $vm -Windows -ComputerName adVM -Credential $cred -ProvisionVMAgent -EnableAutoUpdate
$vm=Set-AZVMSourceImage -VM $vm -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2019-Datacenter -Version "latest"
$vm=Add-AZVMNetworkInterface -VM $vm -Id $nic.Id
New-AZVM -ResourceGroupName $rgName -Location $locName -VM $vm

## conecte al adVM y ejecute

$disk=Get-Disk | Where-Object {$_.PartitionStyle -eq "RAW"}
$diskNumber=$disk.Number
Initialize-Disk -Number $diskNumber
New-Partition -DiskNumber $diskNumber -UseMaximumSize -AssignDriveLetter
Format-Volume -DriveLetter F

Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
Install-ADDSForest -DomainName CampoVelandia.lab -DatabasePath "F:\NTDS" -SysvolPath "F:\SYSVOL" -LogPath "F:\Logs"

Add-WindowsFeature RSAT-ADDS-Tools
New-ADUser -Name sp_farm_db -GivenName sp_farm_db -UserPrincipalName sp_farm_db -SamAccountName sp_farm_db -AccountPassword (ConvertTo-SecureString -AsPlainText "p@ssw0rd" -Force) -enabled $true -PasswordNeverExpires $true -ChangePasswordAtLogon $false
New-ADUser -Name sqladmin -GivenName sqladmin -UserPrincipalName sqladmin_db -SamAccountName sqladmin -AccountPassword (ConvertTo-SecureString -AsPlainText "p@ssw0rd" -Force) -enabled $true -PasswordNeverExpires $true -ChangePasswordAtLogon $false
New-ADUser -Name EXCHSVC -GivenName EXCHSVC -UserPrincipalName EXCHSVC -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText "p@ssw0rd" -Force) -enabled $true -PasswordNeverExpires $true -ChangePasswordAtLogon $false
New-ADUser -Name EXCHADMIN -GivenName EXCHADMIN -UserPrincipalName EXCHADMIN -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText "p@ssw0rd" -Force) -enabled $true -PasswordNeverExpires $true -ChangePasswordAtLogon $false
New-ADUser -Name EFlores -GivenName "Maria Elena" -surname "Flores" -UserPrincipalName EFlores -EmailAddress EFlores@CampoVelandia.lab -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText "p@ssw0rd" -Force) -Enabled $true
New-ADUser -Name Vgarcia -GivenName "Victor" -surname "Garcia" -UserPrincipalName Vgarcia -EmailAddress Vgarcia@CampoVelandia.lab -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText "p@ssw0rd" -Force) -Enabled $true
New-ADUser -Name LRodriguez -GivenName "Lourdes" -surname "Rodriguez" -UserPrincipalName LRodriguez -EmailAddress LRodriguez@CampoVelandia.lab -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText "p@ssw0rd" -Force) -Enabled $true
New-ADUser -Name JLSanchez -GivenName "Jorge Luis" -surname"Sanchez" -UserPrincipalName JLSanchez -EmailAddress JLSanchez@CampoVelandia.lab -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText "p@ssw0rd" -Force) -Enabled $true
New-ADUser -Name CZambrano -GivenName "Cecilia" -surname "Zambrano" -UserPrincipalName CZambrano -EmailAddress CZambrano@CampoVelandia.lab -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText "p@ssw0rd" -Force) -Enabled $true
New-ADUser -Name MSalazar -GivenName "Mariana " -surname "Salazar" -UserPrincipalName MSalazar -EmailAddress MSalazar@CampoVelandia.lab -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText "p@ssw0rd" -Force) -Enabled $true
New-ADUser -Name JCTorres -GivenName "Juan Carlos" -surname "Torres" -UserPrincipalName JCTorres -EmailAddress JCTorres@CampoVelandia.lab -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText "p@ssw0rd" -Force) -Enabled $true
New-ADUser -Name ALAndrade -GivenName "Ana Lucia" -surname"Andrade" -UserPrincipalName ALAndrade -EmailAddress ALAndrade@CampoVelandia.lab -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText "p@ssw0rd" -Force) -Enabled $true
New-ADUser -Name MVera -GivenName "Miguel Angel" -surname"Vera" -UserPrincipalName MVera -EmailAddress MVera@CampoVelandia.lab -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText "p@ssw0rd" -Force) -Enabled $true

## Fase 2- Creamos ahora la maquina de Exchange

$vmDNSName="mail2433"
$rgName="AzureBootCamp_RG"
$locName=(Get-AZResourceGroup -Name $rgName).Location
Test-AZDnsAvailability -DomainQualifiedName $vmDNSName -Location $locName

# Set up key variables
$subscrName="Microsoft Azure Sponsorship"
$rgName="AzureBootCamp_RG"
$vmDNSName="mail2433"
# Set the Azure subscription
Select-AzSubscription -SubscriptionName $subscrName
# Get the Azure location and storage account names
$locName=(Get-AZResourceGroup -Name $rgName).Location
$saName=(Get-AZStorageaccount | Where-Object {$_.ResourceGroupName -eq $rgName}).StorageAccountName
# Create an availability set for Exchange virtual machines
New-AZAvailabilitySet -ResourceGroupName $rgName -Name exAvailabilitySet -Location $locName -Sku Aligned  -PlatformUpdateDomainCount 5 -PlatformFaultDomainCount 2
# Specify the virtual machine name and size
$vmName="exVM"
$vmSize="Standard_D3_v2"
$vnet=Get-AZVirtualNetwork -Name $vnetName -ResourceGroupName $rgName
$avSet=Get-AZAvailabilitySet -Name exAvailabilitySet -ResourceGroupName $rgName
$vm=New-AZVMConfig -VMName $vmName -VMSize $vmSize -AvailabilitySetId $avSet.Id
# Create the NIC for the virtual machine
$nicName=$vmName + "-NIC"
$pipName=$vmName + "-PublicIP"
$pip=New-AZPublicIpAddress -Name $pipName -ResourceGroupName $rgName -DomainNameLabel $vmDNSName -Location $locName -AllocationMethod Dynamic
$nic=New-AZNetworkInterface -Name $nicName -ResourceGroupName $rgName -Location $locName -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id -PrivateIpAddress "10.0.0.5"
# Create and configure the virtual machine
$cred=Get-Credential -Message "Type the name and password of the local administrator account for exVM."
$vm=Set-AZVMOSDisk -VM $vm -Name ($vmName +"-OS") -DiskSizeInGB 128 -CreateOption FromImage -StorageAccountType "Standard_LRS"
$vm=Set-AZVMOperatingSystem -VM $vm -Windows -ComputerName $vmName -Credential $cred -ProvisionVMAgent -EnableAutoUpdate
$vm=Set-AZVMSourceImage -VM $vm -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2012-R2-Datacenter -Version "latest"
$vm=Add-AZVMNetworkInterface -VM $vm -Id $nic.Id
New-AZVM -ResourceGroupName $rgName -Location $locName -VM $vm

## Conectese a exVM y ejecute

Add-Computer -DomainName "CampoVelandia.lab"
Install-WindowsFeature AS-HTTP-Activation, Desktop-Experience, NET-Framework-45-Features, RPC-over-HTTP-proxy, RSAT-Clustering, RSAT-Clustering-CmdInterface, RSAT-Clustering-Mgmt, RSAT-Clustering-PowerShell, Web-Mgmt-Console, WAS-Process-Model, Web-Asp-Net45, Web-Basic-Auth, Web-Client-Auth, Web-Digest-Auth, Web-Dir-Browsing, Web-Dyn-Compression, Web-Http-Errors, Web-Http-Logging, Web-Http-Redirect, Web-Http-Tracing, Web-ISAPI-Ext, Web-ISAPI-Filter, Web-Lgcy-Mgmt-Console, Web-Metabase, Web-Mgmt-Console, Web-Mgmt-Service, Web-Net-Ext45, Web-Request-Monitor, Web-Server, Web-Stat-Compression, Web-Static-Content, Web-Windows-Auth, Web-WMI, Windows-Identity-Foundation, RSAT-ADDS-Tools
Restart-Computer

## Configurar el Exchange
Write-Host (Get-AZPublicIpaddress -Name "51.137.40.212" -ResourceGroup $rgName).DnsSettings.Fqdn

## Desde exVM
## descarga los pre-requisitos, Visual C++ redis, UC Managed API https://www.microsoft.com/download/details.aspx?id=34992 y el .Net 4.7.2
## descarga el ISO de Exchange con el ultimo CU

F:
.\setup.exe /prepareSchema /IacceptExchangeServerLicenseTerms
.\setup.exe /prepareAD /OrganizationName:LandonHotel /IacceptExchangeServerLicenseTerms
.\setup.exe /mode:Install /role:Mailbox /OrganizationName:LandonHotel /IacceptExchangeServerLicenseTerms
Restart-Computer

$dnsName="mail.eastus2.cloudapp.azure.com"
$user1Name="EFlores@" + $dnsName
$user2Name="Vgarcia@" + $dnsName
$user3Name="LRodriguez@" + $dnsName
$user4Name="JLSanchez@" + $dnsName
$user5Name="CZambrano@" + $dnsName
$user6Name="MSalazar@" + $dnsName
$user7Name="JCTorres@" + $dnsName
$user8Name="ALAndrade@" + $dnsName
$user9Name="MVera@" + $dnsName
$db=Get-MailboxDatabase
$dbName=$db.Name
$password = Read-Host "Enter password" -AsSecureString

New-Mailbox -UserPrincipalName $user1Name -Alias EFlores -Database $dbName -Name EFlores -OrganizationalUnit Users -Password $password -FirstName "Maria Elena" -LastName "Flores" -DisplayName "Maria Elena Flores"
New-Mailbox -UserPrincipalName $user2Name -Alias Vgarcia -Database $dbName -Name Vgarcia -OrganizationalUnit Users -Password $password -FirstName "Victor" -LastName "Garcia" -DisplayName "Victor Garcia"
New-Mailbox -UserPrincipalName $user3Name -Alias LRodriguez -Database $dbName -Name LRodriguez -OrganizationalUnit Users -Password $password -FirstName "Lourdes" -LastName "Rodriguez" -DisplayName "Lourdes Rodriguez"
New-Mailbox -UserPrincipalName $user4Name -Alias JLSanchez -Database $dbName -Name JLSanchez -OrganizationalUnit Users -Password $password -FirstName "Jorge Luis" -LastName "Sanchez" -DisplayName "Jorge Luis Sanchez"
New-Mailbox -UserPrincipalName $user5Name -Alias CZambrano -Database $dbName -Name CZambrano -OrganizationalUnit Users -Password $password -FirstName "Cecilia" -LastName "Zambrano" -DisplayName "Cecilia Zambrano"
New-Mailbox -UserPrincipalName $user6Name -Alias MSalazar -Database $dbName -Name MSalazar -OrganizationalUnit Users -Password $password -FirstName "Mariana" -LastName "Salazar" -DisplayName "Mariana Salazar"
New-Mailbox -UserPrincipalName $user7Name -Alias JCTorres -Database $dbName -Name JCTorres -OrganizationalUnit Users -Password $password -FirstName "Juan Carlos" -LastName "Torres" -DisplayName "Juan Carlos Torres"
New-Mailbox -UserPrincipalName $user8Name -Alias ALAndrade -Database $dbName -Name ALAndrade -OrganizationalUnit Users -Password $password -FirstName "Ana Lucia" -LastName "Andrade" -DisplayName "Ana Lucia Andrade"
New-Mailbox -UserPrincipalName $user9Name -Alias MVera -Database $dbName -Name MVera -OrganizationalUnit Users -Password $password -FirstName "Miguel Angel" -LastName "Vera" -DisplayName "Miguel Angel Vera"

## Fase 3- Creamos ahora la maquina de SQL Server
# Log in to Azure
Connect-AzAccount
# Set up key variables
$subscrName="Microsoft Azure Sponsorship"
$rgName="AzureBootCamp_RG"
# Set the Azure subscription and location
Select-AzSubscription -SubscriptionName $subscrName
$locName=(Get-AzResourceGroup -Name $rgName).Location
# Create an availability set for SQL Server virtual machines
New-AzAvailabilitySet -ResourceGroupName $rgName -Name sqlAvailabilitySet -Location $locName -Sku Aligned  -PlatformUpdateDomainCount 5 -PlatformFaultDomainCount 2
# Create the SQL Server virtual machine
$vmName="sqlVM"
$vmSize="Standard_D3_V2"
$vnetName="Vnet01"
$vnet=Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $rgName
$pip=New-AzPublicIpAddress -Name ($vmName + "-PIP") -ResourceGroupName $rgName -Location $locName -AllocationMethod Dynamic
$nic=New-AzNetworkInterface -Name ($vmName + "-NIC") -ResourceGroupName $rgName -Location $locName -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id -PrivateIpAddress "10.0.0.6"
$avSet=Get-AzAvailabilitySet -Name sqlAvailabilitySet -ResourceGroupName $rgName 
$vm=New-AzVMConfig -VMName $vmName -VMSize $vmSize -AvailabilitySetId $avSet.Id
$vm=Set-AzVMOSDisk -VM $vm -Name ($vmName +"-OS") -DiskSizeInGB 128 -CreateOption FromImage -StorageAccountType "Standard_LRS"
$diskSize=100
$diskConfig=New-AzDiskConfig -AccountType "Standard_LRS" -Location $locName -CreateOption Empty -DiskSizeGB $diskSize
$dataDisk1=New-AzDisk -DiskName ($vmName + "-SQLData") -Disk $diskConfig -ResourceGroupName $rgName
$vm=Add-AzVMDataDisk -VM $vm -Name ($vmName + "-SQLData") -CreateOption Attach -ManagedDiskId $dataDisk1.Id -Lun 1
$cred=Get-Credential -Message "Type the name and password of the local administrator account of the SQL Server computer." 
$vm=Set-AzVMOperatingSystem -VM $vm -Windows -ComputerName $vmName -Credential $cred -ProvisionVMAgent -EnableAutoUpdate
$vm=Set-AzVMSourceImage -VM $vm -PublisherName MicrosoftSQLServer -Offer SQL2017-WS2016 -Skus Standard -Version "latest"
$vm=Add-AzVMNetworkInterface -VM $vm -Id $nic.Id
New-AzVM -ResourceGroupName $rgName -Location $locName -VM $vm

## Connect sqlVM 
Add-Computer -DomainName "CampoVelandia.lab"
Restart-Computer

Get-Disk | Where-Object PartitionStyle -eq "RAW" | Initialize-Disk -PartitionStyle GPT -PassThru | New-Partition -AssignDriveLetter -UseMaximumSize | Format-Volume -FileSystem NTFS -NewFileSystemLabel "SQL Data"
New-Item -ItemType "directory" -Path "f:\Data"
New-Item -ItemType "directory" -Path "f:\Log"
New-Item -ItemType "directory" -Path "f:\Backup"

New-NetFirewallRule -DisplayName "SQL Server ports 1433, 1434, and 5022" -Direction Inbound -Protocol TCP -LocalPort 1433,1434,5022 -Action Allow

## Fase 4- Creamos ahora la maquina de SP Server
# Log in to Azure
Connect-AzAccount
# Set up key variables
$subscrName="Microsoft Azure Sponsorship"
$rgName="AzureBootCamp_RG"
$dnsName="CampoVelandia"
# Set the Azure subscription
Select-AzSubscription -SubscriptionName $subscrName
# Get the location
$locName=(Get-AzResourceGroup -Name $rgName).Location
# Create an availability set for SharePoint virtual machines
New-AzAvailabilitySet -ResourceGroupName $rgName -Name spAvailabilitySet -Location $locName -Sku Aligned  -PlatformUpdateDomainCount 5 -PlatformFaultDomainCount 2
# Create the spVM virtual machine
$vmName="spVM"
$vmSize="Standard_D3_V2"
$vnetName="Vnet01"
$vm=New-AzVMConfig -VMName $vmName -VMSize $vmSize
$pip=New-AzPublicIpAddress -Name ($vmName + "-PIP") -ResourceGroupName $rgName -DomainNameLabel $dnsName -Location $locName -AllocationMethod Dynamic
$vnet=Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $rgName
$nic=New-AzNetworkInterface -Name ($vmName + "-NIC") -ResourceGroupName $rgName -Location $locName -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id -PrivateIpAddress "10.0.0.7"
$avSet=Get-AzAvailabilitySet -Name spAvailabilitySet -ResourceGroupName $rgName 
$vm=New-AzVMConfig -VMName $vmName -VMSize $vmSize -AvailabilitySetId $avSet.Id
$vm=Set-AzVMOSDisk -VM $vm -Name ($vmName +"-OS") -DiskSizeInGB 128 -CreateOption FromImage -StorageAccountType "Standard_LRS"
$cred=Get-Credential -Message "Type the name and password of the local administrator account."
$vm=Set-AzVMOperatingSystem -VM $vm -Windows -ComputerName $vmName -Credential $cred -ProvisionVMAgent -EnableAutoUpdate
$vm=Set-AzVMSourceImage -VM $vm -PublisherName "MicrosoftSharePoint" -Offer "MicrosoftSharePointServer" -Skus "2019" -Version "latest"
$vm=Add-AzVMNetworkInterface -VM $vm -Id $nic.Id
New-AzVM -ResourceGroupName $rgName -Location $locName -VM $vm

## Connect spVM 
Add-Computer -DomainName "CampoVelandia.lab"
Restart-Computer

New-NetFirewallRule -DisplayName "SQL Server ports 1433, 1434, and 5022" -Direction Inbound -Protocol TCP -LocalPort 1433,1434,5022 -Action Allow

Write-Host (Get-AzPublicIpaddress -Name "104.208.155.20" -ResourceGroup $rgName).DnsSettings.Fqdn


## Detener / Iniciar las maquinas virtuales

$rgName="AzureBootCamp_RG"
Stop-AZVM -Name exVM -ResourceGroupName $rgName -Force
Stop-AzVM -Name spVM -ResourceGroupName $rgName -Force
Stop-AzVM -Name sqlVM -ResourceGroupName $rgName -Force
Stop-AZVM -Name adVM -ResourceGroupName $rgName -Force


$rgName="AzureBootCamp_RG"
Start-AZVM -Name adVM -ResourceGroupName $rgName
Start-AZVM -Name exVM -ResourceGroupName $rgName
Start-AzVM -Name sqlVM -ResourceGroupName $rgName
Start-AzVM -Name spVM -ResourceGroupName $rgName




