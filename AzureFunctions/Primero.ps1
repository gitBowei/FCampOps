# Login to Azure
Login-AzureRmAccount

Select-AzureRmSubscription -SubscriptionName "Plataformas de MSDN"

# Get the access key for your storage account
$key = Get-AzureRmStorageAccountKey -ResourceGroupName 'fchresearch' -Name 'fchstorage'

# Create an Azure Storage context using the first access key
$context = New-AzureStorageContext -StorageAccountName 'fchstorage' -StorageAccountKey $key[0].value

# Create a file share named 'resource-templates' in your Azure Storage account
$fileShare = New-AzureStorageShare -Name 'resource-templates' -Context $context

# Add the TemplateTest.json file to the new file share
# "TemplatePath" is the path where you saved the TemplateTest.json file
$templateFile = 'C:\Users\fcampo\Documents\TemplateTest.json'
Set-AzureStorageFileContent -ShareName $fileShare.Name -Context $context -Source $templateFile