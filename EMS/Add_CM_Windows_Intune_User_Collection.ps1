Import-Module "C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1"

Set-Location "NYC:"

New-CMUserCollection -Name "Windows Intune Users" -LimitingCollectionName "All Users and User Groups"

Add-CMUserCollectionQueryMembershipRule -RuleName "Windows Intune Security Group" -CollectionName "Windows Intune Users" -QueryExpression 'SELECT *  FROM  SMS_R_User WHERE SMS_R_User.SecurityGroupName = "CORP\\Windows_Intune_Users"'
