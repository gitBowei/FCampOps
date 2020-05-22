Connect-AzAccount
Get-AZSubscription | Sort SubscriptionName | Select SubscriptionName
$subscrName="Microsoft Azure Sponsorship"
Select-AzSubscription -SubscriptionName $subscrName
Get-AZResourceGroup | Sort ResourceGroupName | Select ResourceGroupName
$rgName="ES2241lab"
$locName="westeurope"
New-AZResourceGroup -Name $rgName -Location $locName

Get-AZStorageAccount | Sort StorageAccountName | Select StorageAccountName

Get-AZStorageAccountNameAvailability "es2241labstor"

$rgName="ES2241lab"
$saName="es2242labstor"
$locName=(Get-AZResourceGroup -Name $rgName).Location
New-AZStorageAccount -Name $saName -ResourceGroupName $rgName -Type Standard_LRS -Location $locName

$rgName="ES2241lab"
$locName=(Get-AZResourceGroup -Name $rgName).Location
$exSubnet=New-AZVirtualNetworkSubnetConfig -Name EXSrvrSubnet -AddressPrefix 10.0.0.0/24
New-AZVirtualNetwork -Name EXSrvrVnet -ResourceGroupName $rgName -Location $locName -AddressPrefix 10.0.0.0/16 -Subnet $exSubnet -DNSServer 10.0.0.4
$rule1 = New-AZNetworkSecurityRuleConfig -Name "RDPTraffic" -Description "Allow RDP to all VMs on the subnet" -Access Allow -Protocol Tcp -Direction Inbound -Priority 100 -SourceAddressPrefix Internet -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389
$rule2 = New-AZNetworkSecurityRuleConfig -Name "ExchangeSecureWebTraffic" -Description "Allow HTTPS to the Exchange server" -Access Allow -Protocol Tcp -Direction Inbound -Priority 101 -SourceAddressPrefix Internet -SourcePortRange * -DestinationAddressPrefix "10.0.0.5/32" -DestinationPortRange 443
New-AZNetworkSecurityGroup -Name EXSrvrSubnet -ResourceGroupName $rgName -Location $locName -SecurityRules $rule1, $rule2
$vnet=Get-AZVirtualNetwork -ResourceGroupName $rgName -Name EXSrvrVnet
$nsg=Get-AZNetworkSecurityGroup -Name EXSrvrSubnet -ResourceGroupName $rgName
Set-AZVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name EXSrvrSubnet -AddressPrefix "10.0.0.0/24" -NetworkSecurityGroup $nsg
$vnet | Set-AzVirtualNetwork

$rgName="ES2241lab"
# Create an availability set for domain controller virtual machines
New-AZAvailabilitySet -ResourceGroupName $rgName -Name dcAvailabilitySet -Location $locName -Sku Aligned  -PlatformUpdateDomainCount 5 -PlatformFaultDomainCount 2
# Create the domain controller virtual machine
$vnet=Get-AZVirtualNetwork -Name EXSrvrVnet -ResourceGroupName $rgName
$pip = New-AZPublicIpAddress -Name adVM-NIC -ResourceGroupName $rgName -Location $locName -AllocationMethod Dynamic
$nic = New-AZNetworkInterface -Name adVM-NIC -ResourceGroupName $rgName -Location $locName -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id -PrivateIpAddress 10.0.0.4
$avSet=Get-AZAvailabilitySet -Name dcAvailabilitySet -ResourceGroupName $rgName
$vm=New-AZVMConfig -VMName adVM -VMSize Standard_D1_v2 -AvailabilitySetId $avSet.Id
$vm=Set-AZVMOSDisk -VM $vm -Name adVM-OS -DiskSizeInGB 128 -CreateOption FromImage -StorageAccountType "Standard_LRS"
$diskConfig=New-AZDiskConfig -AccountType "Standard_LRS" -Location $locName -CreateOption Empty -DiskSizeGB 20
$dataDisk1=New-AZDisk -DiskName adVM-DataDisk1 -Disk $diskConfig -ResourceGroupName $rgName
$vm=Add-AZVMDataDisk -VM $vm -Name adVM-DataDisk1 -CreateOption Attach -ManagedDiskId $dataDisk1.Id -Lun 1
$cred=Get-Credential -Message "Type the name and password of the local administrator account for adVM."
$vm=Set-AZVMOperatingSystem -VM $vm -Windows -ComputerName adVM -Credential $cred -ProvisionVMAgent -EnableAutoUpdate
$vm=Set-AZVMSourceImage -VM $vm -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2012-R2-Datacenter -Version "latest"
$vm=Add-AZVMNetworkInterface -VM $vm -Id $nic.Id
New-AZVM -ResourceGroupName $rgName -Location $locName -VM $vm

####
##En el servidor adVM
####
$disk=Get-Disk | where {$_.PartitionStyle -eq "RAW"}
$diskNumber=$disk.Number
Initialize-Disk -Number $diskNumber
New-Partition -DiskNumber $diskNumber -UseMaximumSize -AssignDriveLetter
Format-Volume -DriveLetter F

Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
Install-ADDSForest -DomainName landonhotel.com -DatabasePath "F:\NTDS" -SysvolPath "F:\SYSVOL" -LogPath "F:\Logs"
Add-WindowsFeature RSAT-ADDS-Tools

#####
# Fase 2/ la maquina de Exchange
#####

Connect-AzAccount

$vmDNSName="correoex2019lab01"
$rgName="ES2241lab"
$locName=(Get-AZResourceGroup -Name $rgName).Location
Test-AZDnsAvailability -DomainQualifiedName $vmDNSName -Location $locName

# Set up key variables
$subscrName="Microsoft Azure Sponsorship"
$rgName="ES2241lab"
$vmDNSName="correoex2019lab01"
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
$vnet=Get-AZVirtualNetwork -Name "EXSrvrVnet" -ResourceGroupName $rgName
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
$vm=Set-AZVMSourceImage -VM $vm -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2019-Datacenter -Version "latest"
$vm=Add-AZVMNetworkInterface -VM $vm -Id $nic.Id
New-AZVM -ResourceGroupName $rgName -Location $locName -VM $vm

####
#Ejecutar en la exVM
####

Add-Computer -DomainName "landonhotel.com"
Restart-Computer

####
# ahora Ejecutamos Localmente
####
Write-Host (Get-AZPublicIpaddress -Name "exVM-PublicIP" -ResourceGroup $rgName).DnsSettings.Fqdn

####
# de nuevo desde la exVM
####

Install-WindowsFeature AS-HTTP-Activation, Desktop-Experience, NET-Framework-45-Features, RPC-over-HTTP-proxy, RSAT-Clustering, RSAT-Clustering-CmdInterface, RSAT-Clustering-Mgmt, RSAT-Clustering-PowerShell, Web-Mgmt-Console, WAS-Process-Model, Web-Asp-Net45, Web-Basic-Auth, Web-Client-Auth, Web-Digest-Auth, Web-Dir-Browsing, Web-Dyn-Compression, Web-Http-Errors, Web-Http-Logging, Web-Http-Redirect, Web-Http-Tracing, Web-ISAPI-Ext, Web-ISAPI-Filter, Web-Lgcy-Mgmt-Console, Web-Metabase, Web-Mgmt-Console, Web-Mgmt-Service, Web-Net-Ext45, Web-Request-Monitor, Web-Server, Web-Stat-Compression, Web-Static-Content, Web-Windows-Auth, Web-WMI, Windows-Identity-Foundation, RSAT-ADDS-Tools
Restart-Computer
### Descargar el UCManagement
### Descargar el Iso de Exchange

$dnsName="<Internet DNS name of the exVM virtual machine>"
$user1Name="chris@" + $dnsName
$user2Name="janet@" + $dnsName
$db=Get-MailboxDatabase
$dbName=$db.Name
$password = Read-Host "Enter password" -AsSecureString

New-Mailbox -UserPrincipalName $user1Name -Alias chris -Database $dbName -Name ChrisAshton -OrganizationalUnit Users -Password $password -FirstName Chris -LastName Ashton -DisplayName "Chris Ashton"
New-Mailbox -UserPrincipalName $user2Name -Alias janet -Database $dbName -Name JanetSchorr -OrganizationalUnit Users -Password $password -FirstName Janet -LastName Schorr -DisplayName "Janet Schorr"




