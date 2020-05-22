# MyPath is the path where you saved DeployTemplate.ps1
# MyResourceGroup is the name of the Azure ResourceGroup that contains your Azure Automation account
# MyAutomationAccount is the name of your Automation account
$importParams = @{
    Path = 'C:\users\fcampo\documents\DeployTemplate.ps1'
    ResourceGroupName = 'fchresearch'
    AutomationAccountName = 'fchresearch'
    Type = 'PowerShell'
}
Import-AzureRmAutomationRunbook

# Publish the runbook
$publishParams = @{
    ResourceGroupName = 'fchresearch'
    AutomationAccountName = 'fchresearch'
    Name = 'DeployTemplate'
}
Publish-AzureRmAutomationRunbook @publishParams