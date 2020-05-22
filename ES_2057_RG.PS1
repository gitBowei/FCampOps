Connect-AzAccount

Get-AZSubscription | Sort SubscriptionName | Select SubscriptionName

$subscrName="Microsoft Azure Sponsorship"
Select-AzSubscription -SubscriptionName $subscrName

Get-AZResourceGroup | Sort ResourceGroupName | Select ResourceGroupName

$rgName="ES_2057_Inst_rg"
$locName="EastUS2"
New-AZResourceGroup -Name $rgName -Location $locName

Get-AZStorageAccount | Sort StorageAccountName | Select StorageAccountName

Get-AZStorageAccountNameAvailability "landonhotel19inst"

$rgName="ES_2057_Inst_rg"
$saName="landonhotel19inst"
$locName=(Get-AZResourceGroup -Name $rgName).Location
New-AZStorageAccount -Name $saName -ResourceGroupName $rgName -Type Standard_LRS -Location $locName

$rgName="ES_2057_Inst_rg"
$locName=(Get-AZResourceGroup -Name $rgName).Location
$vnetName="EXSrvrVnet"
$SubnetName="EXSrvrSubnet"
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

$rgName="ES_2057_Inst_rg"
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
$vm=Set-AZVMSourceImage -VM $vm -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2012-R2-Datacenter -Version "latest"
$vm=Add-AZVMNetworkInterface -VM $vm -Id $nic.Id
New-AZVM -ResourceGroupName $rgName -Location $locName -VM $vm

## conecte al adVM y ejecute

$disk=Get-Disk | where {$_.PartitionStyle -eq "RAW"}
$diskNumber=$disk.Number
Initialize-Disk -Number $diskNumber
New-Partition -DiskNumber $diskNumber -UseMaximumSize -AssignDriveLetter
Format-Volume -DriveLetter F

Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
Install-ADDSForest -DomainName landonhotel.com -DatabasePath "F:\NTDS" -SysvolPath "F:\SYSVOL" -LogPath "F:\Logs"

Add-WindowsFeature RSAT-ADDS-Tools
New-ADUser -SamAccountName sp_farm_db -AccountPassword (read-host "Set user password" -assecurestring) -name "sp_farm_db" -enabled $true -PasswordNeverExpires $true -ChangePasswordAtLogon $false
New-ADUser -Name EXCHSVC -GivenName EXCHSVC -UserPrincipalName EXCHSVC -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText "p@ssw0rd" -Force) -Enabled $true
New-ADUser -Name SYSADMIN -GivenName EXCHADMIN -UserPrincipalName EXCHADMIN -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText "p@ssw0rd" -Force) -Enabled $true
New-ADUser -Name EFlores -GivenName "Maria Elena" -surname "Flores" -UserPrincipalName EFlores -EmailAddress EFlores@landonhotel.com -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText "p@ssw0rd" -Force) -Enabled $true
New-ADUser -Name Vgarcia -GivenName "Victor" -surname "Garcia" -UserPrincipalName Vgarcia -EmailAddress Vgarcia@landonhotel.com -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText "p@ssw0rd" -Force) -Enabled $true
New-ADUser -Name LRodriguez -GivenName "Lourdes" -surname "Rodriguez" -UserPrincipalName LRodriguez -EmailAddress LRodriguez@landonhotel.com -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText "p@ssw0rd" -Force) -Enabled $true
New-ADUser -Name JLSanchez -GivenName "Jorge Luis" -surname "Sanchez" -UserPrincipalName JLSanchez -EmailAddress JLSanchez@landonhotel.com -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText "p@ssw0rd" -Force) -Enabled $true
New-ADUser -Name CZambrano -GivenName "Cecilia" -surname "Zambrano" -UserPrincipalName CZambrano -EmailAddress CZambrano@landonhotel.com -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText "p@ssw0rd" -Force) -Enabled $true
New-ADUser -Name MSalazar -GivenName "Mariana " -surname "Salazar" -UserPrincipalName MSalazar -EmailAddress MSalazar@landonhotel.com -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText "p@ssw0rd" -Force) -Enabled $true
New-ADUser -Name JCTorres -GivenName "Juan Carlos" -surname "Torres" -UserPrincipalName JCTorres -EmailAddress JCTorres@landonhotel.com -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText "p@ssw0rd" -Force) -Enabled $true
New-ADUser -Name ALAndrade -GivenName "Ana Lucia" -surname "Andrade" -UserPrincipalName ALAndrade -EmailAddress ALAndrade@landonhotel.com -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText "p@ssw0rd" -Force) -Enabled $true
New-ADUser -Name MVera -GivenName "Miguel Angel" -surname "Vera" -UserPrincipalName MVera -EmailAddress MVera@landonhotel.com -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText "p@ssw0rd" -Force) -Enabled $true

## Fase 2- Creamos ahora la maquina de Exchange

$vmDNSName="mail76"
$rgName="ES_2057_Inst_rg"
$locName=(Get-AZResourceGroup -Name $rgName).Location
Test-AZDnsAvailability -DomainQualifiedName $vmDNSName -Location $locName

# Set up key variables
$subscrName="Microsoft Azure Sponsorship"
$rgName="ES_2057_Inst_rg"
$vmDNSName="mail76"
# Set the Azure subscription
Select-AzSubscription -SubscriptionName $subscrName
# Get the Azure location and storage account names
$locName=(Get-AZResourceGroup -Name $rgName).Location
$saName=(Get-AZStorageaccount | Where {$_.ResourceGroupName -eq $rgName}).StorageAccountName
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

Add-Computer -DomainName "landonhotel.com"
Install-WindowsFeature AS-HTTP-Activation, Server-Media-Foundation, NET-Framework-45-Features, RPC-over-HTTP-proxy, RSAT-Clustering, RSAT-Clustering-CmdInterface, RSAT-Clustering-Mgmt, RSAT-Clustering-PowerShell, WAS-Process-Model, Web-Asp-Net45, Web-Basic-Auth, Web-Client-Auth, Web-Digest-Auth, Web-Dir-Browsing, Web-Dyn-Compression, Web-Http-Errors, Web-Http-Logging, Web-Http-Redirect, Web-Http-Tracing, Web-ISAPI-Ext, Web-ISAPI-Filter, Web-Lgcy-Mgmt-Console, Web-Metabase, Web-Mgmt-Console, Web-Mgmt-Service, Web-Net-Ext45, Web-Request-Monitor, Web-Server, Web-Stat-Compression, Web-Static-Content, Web-Windows-Auth, Web-WMI, Windows-Identity-Foundation, RSAT-ADDS
Restart-Computer

## Configurar el Exchange
Write-Host (Get-AZPublicIpaddress -Name "40.84.58.22" -ResourceGroup $rgName).DnsSettings.Fqdn

## Desde exVM
## descarga los pre-requisitos, 
## https://go.microsoft.com/fwlink/p/?linkid=863265 ".NET Framework 4.7.2 "
## https://go.microsoft.com/fwlink/?linkid=327788 "Paquete redistribuible de Visual C++ para Visual Studio 2012"
## https://go.microsoft.com/fwlink/?linkid=2002913 "Paquete redistribuible de Visual C++ para Visual Studio 2013"
## https://go.microsoft.com/fwlink/p/?linkId=258269 "API administrada de comunicaciones unificadas de Microsoft 4.0, Core Runtime (64 bits)" 
## descarga el ISO de Exchange con el ultimo CU

e:
.\setup.exe /prepareSchema /IacceptExchangeServerLicenseTerms
.\setup.exe /prepareAD /OrganizationName:LandonHotel /IacceptExchangeServerLicenseTerms
.\setup.exe /mode:Install /role:Mailbox /OrganizationName:LandonHotel /IacceptExchangeServerLicenseTerms
Restart-Computer

<<<<<<< HEAD
$dnsName="mail76.eastus2.cloudapp.azure.com"
=======
# Desplegaremos un segundo servidor ExVM2
$rgName="ES_2057_Inst_rg"
$locName=(Get-AZResourceGroup -Name $rgName).Location

# Set up key variables
$subscrName="Microsoft Azure Sponsorship"
$rgName="ES_2057_Inst_rg"
$vnetName="EXSrvrVnet"
$SubnetName="EXSrvrSubnet"
# Set the Azure subscription
Select-AzSubscription -SubscriptionName $subscrName
# Get the Azure location and storage account names
$locName=(Get-AZResourceGroup -Name $rgName).Location
$saName=(Get-AZStorageaccount | Where {$_.ResourceGroupName -eq $rgName}).StorageAccountName
# Create an availability set for Exchange virtual machines
New-AZAvailabilitySet -ResourceGroupName $rgName -Name ex2AvailabilitySet -Location $locName -Sku Aligned  -PlatformUpdateDomainCount 5 -PlatformFaultDomainCount 2
# Specify the virtual machine name and size
$vmName="exVM2"
$vmSize="Standard_D3_v2"
$vnet=Get-AZVirtualNetwork -Name $vnetName -ResourceGroupName $rgName
$avSet=Get-AZAvailabilitySet -Name ex2AvailabilitySet -ResourceGroupName $rgName
$vm=New-AZVMConfig -VMName $vmName -VMSize $vmSize -AvailabilitySetId $avSet.Id
# Create the NIC for the virtual machine
$nicName=$vmName + "-NIC"
$pipName=$vmName + "-PublicIP"
$pip=New-AZPublicIpAddress -Name $pipName -ResourceGroupName $rgName -DomainNameLabel $vmDNSName -Location $locName -AllocationMethod Dynamic
$nic=New-AZNetworkInterface -Name $nicName -ResourceGroupName $rgName -Location $locName -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id -PrivateIpAddress "10.0.0.11"
# Create and configure the virtual machine
$cred=Get-Credential -Message "Type the name and password of the local administrator account for exVM2."
$vm=Set-AZVMOSDisk -VM $vm -Name ($vmName +"-OS") -DiskSizeInGB 128 -CreateOption FromImage -StorageAccountType "Standard_LRS"
$vm=Set-AZVMOperatingSystem -VM $vm -Windows -ComputerName $vmName -Credential $cred -ProvisionVMAgent -EnableAutoUpdate
$vm=Set-AZVMSourceImage -VM $vm -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2012-R2-Datacenter -Version "latest"
$vm=Add-AZVMNetworkInterface -VM $vm -Id $nic.Id
New-AZVM -ResourceGroupName $rgName -Location $locName -VM $vm

$dnsName="mail09.eastus2.cloudapp.azure.com"
>>>>>>> 3507dd10f3f1294a1e7b18bb1f8c575573abc2e0
$user1Name="chris@" + $dnsName
$user2Name="janet@" + $dnsName
$db=Get-MailboxDatabase
$dbName=$db.Name
$password = Read-Host "Enter password" -AsSecureString

New-Mailbox -UserPrincipalName $user1Name -Alias chris -Database $dbName -Name ChrisAshton -OrganizationalUnit Users -Password $password -FirstName Chris -LastName Ashton -DisplayName "Chris Ashton"
New-Mailbox -UserPrincipalName $user2Name -Alias janet -Database $dbName -Name JanetSchorr -OrganizationalUnit Users -Password $password -FirstName Janet -LastName Schorr -DisplayName "Janet Schorr"

## Fase 3- Creamos ahora la maquina de SQL Server
# Log in to Azure
Connect-AzAccount
# Set up key variables
$subscrName="Microsoft Azure Sponsorship"
$rgName="ES_2057_Inst_rg"
# Set the Azure subscription and location
Select-AzSubscription -SubscriptionName $subscrName
$locName=(Get-AzResourceGroup -Name $rgName).Location
# Create an availability set for SQL Server virtual machines
New-AzAvailabilitySet -ResourceGroupName $rgName -Name sqlAvailabilitySet -Location $locName -Sku Aligned  -PlatformUpdateDomainCount 5 -PlatformFaultDomainCount 2
# Create the SQL Server virtual machine
$vmName="sqlVM"
$vmSize="Standard_D3_V2"
$vnetName="EXSrvrVnet"
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
Add-Computer -DomainName "LandonHotel.com"
Restart-Computer

Get-Disk | Where PartitionStyle -eq "RAW" | Initialize-Disk -PartitionStyle GPT -PassThru | New-Partition -AssignDriveLetter -UseMaximumSize | Format-Volume -FileSystem NTFS -NewFileSystemLabel "SQL Data"
md f:\Data
md f:\Log
md f:\Backup

New-NetFirewallRule -DisplayName "SQL Server ports 1433, 1434, and 5022" -Direction Inbound -Protocol TCP -LocalPort 1433,1434,5022 -Action Allow

## Fase 4- Creamos ahora la maquina de SP Server
# Set up key variables
$subscrName="Microsoft Azure Sponsorship"
$rgName="ES_2057_Inst_rg"
$dnsName="landonhotel10nov2019"
# Set the Azure subscription
Select-AzSubscription -SubscriptionName $subscrName
# Get the location
$locName=(Get-AzResourceGroup -Name $rgName).Location
# Create an availability set for SharePoint virtual machines
New-AzAvailabilitySet -ResourceGroupName $rgName -Name spAvailabilitySet -Location $locName -Sku Aligned  -PlatformUpdateDomainCount 5 -PlatformFaultDomainCount 2
# Create the spVM virtual machine
$vmName="spVM"
$vmSize="Standard_D3_V2"
$vnetName="EXSrvrVnet"
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
Add-Computer -DomainName "LandonHotel.com"
Restart-Computer

New-NetFirewallRule -DisplayName "SQL Server ports 1433, 1434, and 5022" -Direction Inbound -Protocol TCP -LocalPort 1433,1434,5022 -Action Allow

Write-Host (Get-AzPublicIpaddress -Name "13.77.127.118" -ResourceGroup $rgName).DnsSettings.Fqdn

#Install Language Pack for Sharepoint in Spanish

# https://www.microsoft.com/es-ES/download/confirmation.aspx?id=57463

#Configurar Site Mailboxes
# https://docs.microsoft.com/en-us/sharepoint/administration/configure-site-mailboxes-in-sharepoint


##Desplegar un cliente

$rgName="ES_2057_Inst_rg"
$locName=(Get-AzResourceGroup -Name $rgName).Location
$vnet=Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $rgName
$pip=New-AzPublicIpAddress -Name CLIENT1-PIP -ResourceGroupName $rgName -Location $locName -AllocationMethod Dynamic
$nic=New-AzNetworkInterface -Name CLIENT1-NIC -ResourceGroupName $rgName -Location $locName -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id
$vm=New-AzVMConfig -VMName CLIENT1 -VMSize Standard_A1
$cred=Get-Credential -Message "Type the name and password of the local administrator account for CLIENT1."
$vm=Set-AzVMOperatingSystem -VM $vm -Windows -ComputerName CLIENT1 -Credential $cred -ProvisionVMAgent -EnableAutoUpdate
$vm=Set-AzVMSourceImage -VM $vm -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2016-Datacenter -Version "latest"
$vm=Add-AzVMNetworkInterface -VM $vm -Id $nic.Id
$vm=Set-AzVMOSDisk -VM $vm -Name "CLIENT1-OS" -DiskSizeInGB 128 -CreateOption FromImage -StorageAccountType "Standard_LRS"
New-AzVM -ResourceGroupName $rgName -Location $locName -VM $vm

#Desplegar un servidor para OOS
$rgName="ES_2057_Inst_rg"
$locName="EastUS2"
# Create an availability set for domain controller virtual machines
New-AZAvailabilitySet -ResourceGroupName $rgName -Name oosAvailabilitySet -Location $locName -Sku Aligned  -PlatformUpdateDomainCount 5 -PlatformFaultDomainCount 2
# Create the domain controller virtual machine
$vmName="oosVM"
$vmSize="Standard_D1_v2"
$vnetName="EXSrvrVnet"
$vnet=Get-AZVirtualNetwork -Name $vnetName -ResourceGroupName $rgName
$pip = New-AZPublicIpAddress -Name ($vmName + "-PIP") -ResourceGroupName $rgName -Location $locName -AllocationMethod Dynamic
$nic = New-AZNetworkInterface -Name ($vmName + "-NIC") -ResourceGroupName $rgName -Location $locName -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id -PrivateIpAddress 10.0.0.9
$avSet=Get-AZAvailabilitySet -Name oosAvailabilitySet -ResourceGroupName $rgName
$vm=New-AZVMConfig -VMName $vmName -VMSize $vmSize -AvailabilitySetId $avSet.Id
$vm=Set-AZVMOSDisk -VM $vm -Name ($vmName +"-OS") -DiskSizeInGB 128 -CreateOption FromImage -StorageAccountType "Standard_LRS"
$diskConfig=New-AZDiskConfig -AccountType "Standard_LRS" -Location $locName -CreateOption Empty -DiskSizeGB 20
$dataDisk1=New-AZDisk -DiskName ($vmName + "-DataDisk1") -Disk $diskConfig -ResourceGroupName $rgName
$vm=Add-AZVMDataDisk -VM $vm -Name ($vmName + "-DataDisk1") -CreateOption Attach -ManagedDiskId $dataDisk1.Id -Lun 1
$cred=Get-Credential -Message "Type the name and password of the local administrator account for ossVM."
$vm=Set-AZVMOperatingSystem -VM $vm -Windows -ComputerName adVM -Credential $cred -ProvisionVMAgent -EnableAutoUpdate
$vm=Set-AZVMSourceImage -VM $vm -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2012-R2-Datacenter -Version "latest"
$vm=Add-AZVMNetworkInterface -VM $vm -Id $nic.Id
New-AZVM -ResourceGroupName $rgName -Location $locName -VM $vm

## Detener / Iniciar las maquinas virtuales

$rgName="ES_2057_Inst_rg"
Stop-AZVM -Name exVM -ResourceGroupName $rgName -Force
Stop-AzVM -Name spVM -ResourceGroupName $rgName -Force
Stop-AzVM -Name sqlVM -ResourceGroupName $rgName -Force
Stop-AZVM -Name adVM -ResourceGroupName $rgName -Force


$rgName="ES_2057_Inst_rg"
Start-AZVM -Name adVM -ResourceGroupName $rgName
Start-AZVM -Name exVM -ResourceGroupName $rgName
Start-AzVM -Name sqlVM -ResourceGroupName $rgName
Start-AzVM -Name spVM -ResourceGroupName $rgName