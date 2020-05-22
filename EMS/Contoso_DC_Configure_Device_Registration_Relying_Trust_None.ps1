# Import the AD FS PowerShell module
Import-Module ADFS

# Create the relying party trust rule to all devices
$IssuanceAuthorizationRule = '@RuleTemplate = "AllowAllAuthzRule"  => issue(Type = "http://schemas.microsoft.com/authorization/claims/permit", Value = "true");'

# Set the new relying party trust rule for the "intranet.corp.contoso.com" relying party trust
Set-AdfsRelyingPartyTrust -TargetName "intranet.corp.contoso.com" -IssuanceAuthorizationRules $IssuanceAuthorizationRule
