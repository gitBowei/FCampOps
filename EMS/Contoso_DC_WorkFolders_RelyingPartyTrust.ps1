# Define the variables used by the script
$ECSIdentifier = "https://Windows-Server-Work-Folders/V1"

# Load the AD FS PowerShell module
Import-Module ADFS

# Update the ADFS relying party trust (https://Windows-Server-Work-Folders/V1) with values that
# cannot be set in the AD FS user interface
Set-AdfsRelyingPartyTrust -TargetIdentifier $ECSIdentifier -EnableJWT $true -EncryptClaims $false -AutoUpdateEnabled $true -IssueOAuthRefreshTokensTo AllDevices
