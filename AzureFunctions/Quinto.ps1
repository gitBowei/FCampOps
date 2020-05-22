# Set up the parameters for the runbook
$runbookParams = @{
    ResourceGroupName = 'fchresearch'
    StorageAccountName = 'fchstorage'
    StorageAccountKey = $key[0].Value # We got this key earlier
    StorageFileName = 'TemplateTest.json' 
}

# Set up parameters for the Start-AzureRmAutomationRunbook cmdlet
$startParams = @{
    ResourceGroupName = 'fchresearch'
    AutomationAccountName = 'fchresearch'
    Name = 'DeployTemplate'
    Parameters = $runbookParams
}

# Start the runbook
$job = Start-AzureRmAutomationRunbook @startParams