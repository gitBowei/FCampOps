#Levantar la conexion a Azure
#Levantar la conexion a un Blob Storage
#Generar el listado de usuarios C/24H

#Levantar la conexion al Blob Storage
#Leer el archivo con los usuarios
#iniciar la conexion a ExO
#Realizar el barrido de correos

#Insertar al Azure Log Analytics

#--------------------------------------------
$dateStart = ([system.DateTime]::Now.AddHours(-1))

#Variables
$pw = convertto-securestring -AsPlainText -Force -String “MicrosoftMVP2020”
$usr = "fcampo@hotmail.com"
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $usr,$pw
Write-Progress -activity "Conectamos a Azure"
$SubscriptionName = "Microsoft Azure Sponsorship"
$StorageAccountName = "blobstoragecsj"
$ContainerName = "emailcsj"
$FileToUpload = "C:\Logs\Buzones.csv"

Connect-AzAccount 
Select-AzSubscription -SubscriptionName $SubscriptionName
Set-AzSubscription -CurrentStorageAccountName $StorageAccountName -SubscriptionName $SubscriptionName
# Upload a blob into a container.
Set-AzStorageBlobContent -Container $ContainerName -File $FileToUpload
#--------------------------------------------
Get-AzStorageAccount | select storageaccountname
$storageContainer = Get-AzStorageAccount | where {$_.StorageAccountName -eq 'blobstoragecsj'} | Get-AzStorageContainer
$FilePath = 'C:\logs\PrimarySMTP.csv'
$BlobName = 'Buzones.csv'
$storageContainer | Set-AzStorageBlobContent –File $FilePath –Blob $BlobName

#--------------------------------------------
#download blobs
$subname = "StorageSubscription"
$stAcc = "samstorage"
$stKey = "*************************** =="
$contName = "videocontainer"
$DestinationFolder = "D:\Sam\Videos"
$ctx = New-AzureStorageContext -StorageAccountName $stAcc -StorageAccountKey $stKey
$blobs = Get-AzureStorageBlob -Container $contName -Context $ctx
#Download blobs from a container.
New-Item -Path $DestinationFolder -ItemType Directory -Force
$blobs | Get-AzureStorageBlobContent -Destination $DestinationFolder -Context $ctx