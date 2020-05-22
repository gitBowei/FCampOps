   1 import-module WindowsAzure                                                                                        
   2 import-module Azure                                                                                               
   3 Import-AzurePublishSettingsFile "C:\Users\FabianAlberto\OneDrive\Pago por uso-Plataformas de MSDN-2-23-2015-cre...
   4 cd .\Documents                                                                                                    
   5 ls                                                                                                                
   6 Import-AzurePublishSettingsFile "C:\Users\FabianAlberto\Documents\Pago por uso-Plataformas de MSDN-2-23-2015-cr...
   7 $image = Get-AzureVMImage -ImageName "a699494373c04fc0bc8f2bb1389d6106__Windows-Server-2012-R2-201410.01-en.us-...
   8 Get-AzureVMImage -ImageName "*_Windows-Server-2012-R2-201410.01-en.us-127GB.vhd"                                  
   9 Get-AzureVMImage -ImageName "*Windows-Server-2012-R2"                                                             
  10 Get-AzureVMImage -ImageName "*2012"                                                                               
  11 Get-AzureVMImage |FT ImageName                                                                                    
  12 $image = Get-AzureVMImage -ImageName "a699494373c04fc0bc8f2bb1389d6106__Windows-Server-2012-R2-201504.01-en.us-...
  13 $vm = New-AzureVMConfig -Name "MultiNicVM" -InstanceSize "ExtraLarge" -Image $image.ImageName ?AvailabilitySetN...
  14 Select-AzureSubscription "Plataformas de MSDN"                                                                    
  15 Get-AzureStorageAccount |select StorageAccountName                                                                
  16 $vm = New-AzureVMConfig -Name "MultiNicVM" -InstanceSize "ExtraLarge" -Image $image.ImageName -MediaLocation po...
  17 $vm = New-AzureVMConfig -Name "MultiNicVM" -InstanceSize "ExtraLarge" -Image $image.ImageName                     
  18 Set-AzureSubscription -SubscriptionName "Plataformas de MSDN" -CurrentStorageAccountName "storagelabs"            
  19 $user = "fcampo"                                                                                                  
  20 $pwd = "1234abcd."                                                                                                
  21 $location = "South Central US"                                                                                    
  22 $img= "a699494373c04fc0bc8f2bb1389d6106__Windows-Server-2012-R2-201504.01-en.us-127GB.vhd"                        
  23 Get-AzureRoleSize                                                                                                 
  24 $size = "Small"                                                                                                   
  25 Test-AzureName -Service "Labcamp"                                                                                 
  26 $cloudService ="Labcamp"                                                                                          
  27 $vmconfig = New-AzureVMConfig -Name "RAS01" -ImageName $img -InstanceSize $size                                   
  28 $vmconfig |Add-AzureProvisioningConfig -Windows -AdminUsername $user -Password $pwd                               
  29 $vmConfig | Add-AzureDataDisk -CreateNew  -DiskSizeInGB 100 -DiskLabel "Data 1" -Lun 0                            
  30 $vmConfig | Add-AzureEndpoint -Name "RDP" -Protocol tcp -LocalPort 3389 -PublicPort Auto                          
  31 $vmConfig | Add-AzureEndpoint -Name "RDP" -Protocol tcp -LocalPort 3389                                           
  32 $vmConfig | Add-AzureNetworkInterfaceConfig -Name "Ethernet1" -SubnetName "Midtier"                               
  33 $vmConfig | Add-AzureNetworkInterfaceConfig -Name "Ethernet2" -SubnetName "Backend"                               

  34 $vmConfig | New-AzureVM -ServiceName $cloudService -Location $location       