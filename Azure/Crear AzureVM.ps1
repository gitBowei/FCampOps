#Set Azure Subscription and Storage Container
$Subscription = "Pay-As-You-Go"
$Storage = "Storage Account Name"

Set-AzureSubscription -SubscriptionName $Subscription -CurrentStorageAccount $Storage

#Image Name - "Windows Server 2012 R2 Datacenter" or "Windows Server 2008 R2 SP1"
$Image = (Get-AzureVMImage |
Where { $_.ImageFamily -eq "Windows Server 2012 R2 Datacenter" } |
sort PublishedDate -Descending | Select-Object -First 1).ImageName

#VM Details
$VM = "VM Name"
$ServiceName = "Cloud Service Name"
$Location = "East US"
$VMSize = "Medium"
#Extra Small (A0) Shared 768 MB $0.02 (~$15/month)
#Small (A1) 1 1.75 GB $0.09 (~$67/month)
#Medium (A2) 2 3.5 GB $0.18 (~$134/month)
#Large (A3) 4 7 GB $0.36 (~$268/month)
#Extra Large (A4) 8 14 GB $0.72 (~$536/month)
$Domain = "domain.com"
$IP = "X.X.X.X"
$Subnet = "Subnet-1"
$TimeZone = "Eastern Standard Time"
$OU = 'CN=Computers,DC=ddomain,DC=com'
#Domain Join Credential
$AdminUser = "ADJoinAccount"
$AdminPasswd = "StrongPassword"

#Local Administrator Credential
$UserID = "LocalAdmin"
$Passwd = "StrongPassword"

#Create VM
New-AzureVMConfig -Name $VM -InstanceSize $VMSize -Image $Image -DiskLabel "OS" |
Add-AzureProvisioningConfig -WindowsDomain -AdminUserName $UserID -Password $Passwd -Domain $Domain -DomainPassword $AdminPasswd -DomainUserName $AdminUser -JoinDomain $Domain -TimeZone $TimeZone -MachineObjectOU $OU |
Set-AzureSubnet -SubnetNames $Subnet |
Set-AzureStaticVNetIP -IPAddress $IP |
New-AzureVM -ServiceName $ServiceName -Location $Location
