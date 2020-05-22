# Import the AD FS PowerShell module
Import-Module ADFS

# Create the relying party trust rule for devices that are connected to the intranet
$NewIssuanceAuthorizationRule = '@RuleName = "Allow if device is on corporate network" c:[Type == "http://schemas.microsoft.com/ws/2012/01/insidecorporatenetwork", Value =~ "^(?i)true$"] => issue(Type = "http://schemas.microsoft.com/authorization/claims/permit", Value = "PermitUsersWithClaim");'

# Get the existing relying part trust
$RelyingPartTrust = Get-AdfsRelyingPartyTrust -Name "intranet.corp.contoso.com"

# Add the new relying party trust issuance authorization rule to the existing reul
$IssuanceAuthorizationRule = $RelyingPartTrust.IssuanceAuthorizationRules + "`n`n" + $NewIssuanceAuthorizationRule

# Set the new relying party trust rule for the "intranet.corp.contoso.com" relying party trust
Set-AdfsRelyingPartyTrust -TargetName "intranet.corp.contoso.com" -IssuanceAuthorizationRules $IssuanceAuthorizationRule
