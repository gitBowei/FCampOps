$automationAccountName =  "fchresearch"
$runbookName = "httpTriggerPowerShell1"
$scriptPath = "c:\users\fcampo\documents\DeployTemplate.ps1"
$RGName = "fchresearch"

Import-AzureRMAutomationRunbook -Name $runbookName -Path $scriptPath `
-ResourceGroupName $RGName -AutomationAccountName $automationAccountName `
-Type PowerShellWorkflow