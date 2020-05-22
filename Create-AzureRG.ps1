#Pasos para crear ambiente de trabajo en Power Shell
#Crear el ResourseGroup
New-AzureRmResourseGroup

#Crear la red virtual VirtualNetwork
New-AzureRmVirtualNetwork

#Crear una subred Subnet (por el portal)
#Subnetconfig  
Get-AzureRmVirtualNetworkSubnetConfig

#crear PublicIpAddress 
Get-AzureRmPublicIpAddress

#Crear geteway 
New-AzureRmVirtualNetworkGatewayIpConfig

#Certificado root
#Certificado cliente
#Crear la VPN
#Descargar cliente VPN
#Instalar certificado cliente
New-AzureRmVpnClientRootCertificate
New-AzureRmVirtualNetworkGateway
Get-AzureRmVpnClientPackage
 
#Nueva MV
 
New-AzureRmmconfig -vmName -vmSize Standard_D2
Set-AzureRmVmOperatingSystem -Windows -ComputerName -Credentials $(get-credential) -ProvisionVmAgent -Vm 
Set-AzureRmVmSourceImage -Vm -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2012-R2-DataCenter" -Version "4.0.20160518" 

#Asignar una variable (nic) el resultado de 
New-AzurermVirtualNetworkInteface -ResourceGroupName -Name -subnet $(get-AzureRmVirtualNetworkSubnetConfig
        -Location -PrivateIpAddress
Set-AzureRmOsDisk -vm 
        -name <nombre> vhduri <url_blob_vhds_disco> -createoption fromimage
add-AzureRmNetworkinteface -vm con la variable vmconfig
        -id el id de la interfaz de red
                                
Stop-AzureRmVm -Name XXX -ResourceGroupName XXX
