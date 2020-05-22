#####################
 #Get-myCredential.ps1
 Param($User,$File)
 $password = Get-Content $File | ConvertTo-SecureString 
$credential = New-Object System.Management.Automation.PsCredential($user,$password)
 $credential
 #####################