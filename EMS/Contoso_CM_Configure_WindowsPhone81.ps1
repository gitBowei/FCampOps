# Run the ConfigureWP8Settings-Field.vbs VBScript to obtain the Configuration Manager application ID (model name)
$Output = cscript.exe "C:\Program Files (x86)\Microsoft\Support Tool for Windows Intune Trial management of Windows Phone\Support Tool\ConfigureWP8Settings_Field.vbs" cm.corp.contoso.com QuerySSPModelName
$Output

# Parse the output of the ConfigureWP8Settings-Field.vbs VBScript to obtain just the ID (without any of the other output information)
$ModelName = $Output | Select-String -Pattern "Model Name:"
$ModelName = $($($ModelName.ToString()).TrimStart("Model Name:")).Trim() -replace "'", ""

# Display the Configuration Mangaer application ID (ModelName) obtained from the VBScript.
Write-Host "=================================================================================================="
Write-Host "The Configuration Manager application ID for the Windows Intune Company Portal app is:"
Write-Host "    $ModelName"
Write-Host "=================================================================================================="
 
# Configure the Windows Intune Trial Subscription to use our Windows Intune Company Portal app and certificate.
$Output = cscript.exe "C:\Program Files (x86)\Microsoft\Support Tool for Windows Intune Trial management of Windows Phone\Support Tool\ConfigureWP8Settings_Field.vbs" cm.corp.contoso.com SaveSettings $ModelName
$Output
