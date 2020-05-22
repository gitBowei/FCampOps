$Credential=Get-Credential
$Password=$Credential.GetNetworkCredential().password
$SecureString=ConvertTo-SecureString $Password -asplaintext -force
$EncryptedStringASCII=ConvertFrom-SecureString $SecureString
Out-File -FilePath credpasssecure.txt -inputobject $EncryptedStringASCII
$EncryptedStringASCII=Get-Content credpasssecure.txt
$SecurePassword=ConvertFrom-SecureString $EncryptedStringASCII
$Credential=New-Object System.Management.Automation.PsCredential ('o365admin@contosohat..onmicrosoft.com',$SecurePassword)
